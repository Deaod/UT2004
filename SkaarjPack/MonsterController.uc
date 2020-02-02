//=============================================================================
// Monster Controller - simple AI that always has and hunts down player enemy
//=============================================================================
class MonsterController extends ScriptedController;

// AI Magic numbers - distance based, so scale to bot speed/weapon range
const MAXSTAKEOUTDIST = 2000;
const ENEMYLOCATIONFUZZ = 1200;
const TACTICALHEIGHTADVANTAGE = 320;
const MINSTRAFEDIST = 200;
const MINVIEWDIST = 200;

//AI flags
var		bool		bCanFire;			// used by TacticalMove and Charging states
var		bool		bStrafeDir;
var		bool		bLeadTarget;		// lead target with projectile attack
var		bool		bChangeDir;			// tactical move boolean
var		bool		bEnemyIsVisible;
var		bool		bMustCharge;
var		bool		bJustLanded;
var		bool		bRecommendFastMove;
var		bool		bHasFired;
var		bool		bForcedDirection;

// Advanced AI attributes.
var	float			AcquireTime;		// time at which current enemy was acquired
var float			LoseEnemyCheckTime;
var float			StartTacticalTime;
var vector			HidingSpot;
var float			ChallengeTime;

// modifiable AI attributes
var float			Accuracy;			// -1 to 1 (0 is default, higher is more accurate)
var	float			StrafingAbility;	// -1 to 1 (higher uses strafing more)
var	float			CombatStyle;		// -1 to 1 = low means tends to stay off and snipe, high means tends to charge and melee
var float			ReactionTime;

// Team AI attributes
var string			GoalString;			// for debugging - used to show what bot is thinking (with 'ShowDebug')
var string			SoakString;			// for debugging - shows problem when soaking

// ChooseAttackMode() state
var	int			ChoosingAttackLevel;
var float		ChooseAttackTime;
var int			ChooseAttackCounter;
var float		EnemyVisibilityTime;
var	pawn		VisibleEnemy;
var pawn		OldEnemy;
var float		StopStartTime;
var float		LastRespawnTime;
var float		FailedHuntTime;
var Pawn		FailedHuntEnemy;

var int		NumRandomJumps;			// attempts to free monster from being stuck

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetCombatTimer();
	if ( UnrealMPGameInfo(Level.Game).bSoaking )
		bSoaking = true;
}

function FearThisSpot(AvoidMarker aSpot)
{
	if ( Skill > 1 + 4.5 * FRand() )
		Super.FearThisSpot(aSpot);
}

function SetCombatTimer()
{
	SetTimer(1.2 - 0.09 * FMin(10,Skill+ReactionTime), True);
}

function WaitForMover(Mover M)
{
	Super.WaitForMover(M);
	StopStartTime = Level.TimeSeconds;
}

function TimedFireWeaponAtEnemy()
{
	if ( (Enemy == None) || FireWeaponAt(Enemy) )
		SetCombatTimer();
	else
		SetTimer(0.1, True);
}

function bool FireWeaponAt(Actor A)
{
	if ( A == None )
		A = Enemy;
	if ( (A == None) || (Focus != A) )
		return false;
	Target = A;
	Monster(Pawn).RangedAttack(Target);
	return false;
}

function bool CanAttack(Actor Other)
{
	// return true if in range of current weapon
	return Monster(Pawn).CanAttack(Other);
}

function StopFiring()
{
	Monster(Pawn).StopFiring();
	bCanFire = false;
	bFire = 0;
	bAltFire = 0;
}

//===========================================================================

function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local string S;

	Super.DisplayDebug(Canvas,YL, YPos);

	Canvas.SetDrawColor(255,255,255);
	Canvas.DrawText("     "$GoalString, false);

	YPos += 2*YL;
	Canvas.SetPos(4,YPos);

	if ( Enemy != None )
	{
		Canvas.DrawText("Enemy Dist "$VSize(Enemy.Location - Pawn.Location)$" Acquired "$bEnemyAcquired);
		YPos += YL;
		Canvas.SetPos(4,YPos);
	}

	Canvas.DrawText("Weapons: "$S, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("PERSONALITY: CombatStyle "$CombatStyle$" Strafing "$StrafingAbility);
	YPos += YL;
	Canvas.SetPos(4,YPos);
}

function bool FindNewEnemy()
{
	local Pawn BestEnemy;
	local bool bSeeNew, bSeeBest;
	local float BestDist, NewDist;
	local Controller C;

	if ( Level.Game.bGameEnded )
		return false;
	for ( C=Level.ControllerList; C!=None; C=C.NextController )
		if ( C.bIsPlayer && (C.Pawn != None) )
		{
			if ( BestEnemy == None )
			{
				BestEnemy = C.Pawn;
				BestDist = VSize(BestEnemy.Location - Pawn.Location);
				bSeeBest = CanSee(BestEnemy);
			}
			else
			{
				NewDist = VSize(C.Pawn.Location - Pawn.Location);
				if ( !bSeeBest || (NewDist < BestDist) )
				{
					bSeeNew = CanSee(C.Pawn);
					if ( bSeeNew || (!bSeeBest && (NewDist < BestDist))  )
					{
						BestEnemy = C.Pawn;
						BestDist = NewDist;
						bSeeBest = bSeeNew;
					}
				}
			}
		}

	if ( BestEnemy == Enemy )
		return false;

	if ( BestEnemy != None )
	{
		ChangeEnemy(BestEnemy,CanSee(BestEnemy));
		return true;
	}
	return false;
}

function ChangeEnemy(Pawn NewEnemy, bool bCanSeeNewEnemy)
{
	OldEnemy = Enemy;
	Enemy = NewEnemy;
	EnemyChanged(bCanSeeNewEnemy);
}

function bool SetEnemy( Pawn NewEnemy, optional bool bHateMonster )
{
	local float EnemyDist;
	local bool bNewMonsterEnemy;

	if ( (NewEnemy == None) || (NewEnemy.Health <= 0) || (NewEnemy.Controller == None) || (NewEnemy == Enemy) )
		return false;

	bNewMonsterEnemy = bHateMonster && (Level.Game.NumPlayers < 4) && !Monster(Pawn).SameSpeciesAs(NewEnemy) && !NewEnemy.Controller.bIsPlayer;
	if ( !NewEnemy.Controller.bIsPlayer	&& !bNewMonsterEnemy )
			return false;

	if ( (bNewMonsterEnemy && LineOfSightTo(NewEnemy)) || (Enemy == None) || !EnemyVisible() )
	{
		ChangeEnemy(NewEnemy,CanSee(NewEnemy));
		return true;
	}

	if ( !CanSee(NewEnemy) )
		return false;

	if ( !bHateMonster && (Monster(Enemy) != None) && NewEnemy.Controller.bIsPlayer )
		return false;

	EnemyDist = VSize(Enemy.Location - Pawn.Location);
	if ( EnemyDist < Pawn.MeleeRange )
		return false;

	if ( EnemyDist > 1.7 * VSize(NewEnemy.Location - Pawn.Location))
	{
		ChangeEnemy(NewEnemy,CanSee(NewEnemy));
		return true;
	}
	return false;
}

function HearNoise(float Loudness, Actor NoiseMaker)
{
	if ( ((ChooseAttackCounter < 2) || (ChooseAttackTime != Level.TimeSeconds)) && SetEnemy(NoiseMaker.instigator) )
		WhatToDoNext(2);
}

event SeePlayer(Pawn SeenPlayer)
{
	if ( ((ChooseAttackCounter < 2) || (ChooseAttackTime != Level.TimeSeconds)) && SetEnemy(SeenPlayer) )
		WhatToDoNext(3);
	if ( Enemy == SeenPlayer )
	{
		VisibleEnemy = Enemy;
		EnemyVisibilityTime = Level.TimeSeconds;
		bEnemyIsVisible = true;
	}
}

function bool ClearShot(Vector TargetLoc, bool bImmediateFire)
{
	local bool bSeeTarget;

	if ( VSize(Enemy.Location - TargetLoc) > MAXSTAKEOUTDIST )
		return false;

	bSeeTarget = FastTrace(TargetLoc, Pawn.Location + Pawn.EyeHeight * vect(0,0,1));
	// if pawn is crouched, check if standing would provide clear shot
	if ( !bImmediateFire && !bSeeTarget && Pawn.bIsCrouched )
		bSeeTarget = FastTrace(TargetLoc, Pawn.Location + (Pawn.Default.EyeHeight + Pawn.Default.CollisionHeight - Pawn.CollisionHeight) * vect(0,0,1));

	if ( !bSeeTarget || !FastTrace(TargetLoc , Enemy.Location + Enemy.BaseEyeHeight * vect(0,0,1)) );
		return false;
	if ( (Monster(Pawn).SplashDamage() && (VSize(Pawn.Location - TargetLoc) < Monster(Pawn).GetDamageRadius()))
		|| !FastTrace(TargetLoc + vect(0,0,0.9) * Enemy.CollisionHeight, Pawn.Location) )
	{
		StopFiring();
		return false;
	}
	return true;
}

/* CheckIfShouldCrouch()
returns true if target position still can be shot from crouched position,
or if couldn't hit it from standing position either
*/
function CheckIfShouldCrouch(vector StartPosition, vector TargetPosition, float probability)
{
	local actor HitActor;
	local vector HitNormal,HitLocation, X,Y,Z, projstart;

	if ( !Pawn.bCanCrouch || (!Pawn.bIsCrouched && (FRand() > probability))
		|| (Skill < 3 * FRand())
		|| Monster(Pawn).RecommendSplashDamage() )
	{
		Pawn.bWantsToCrouch = false;
		return;
	}

	GetAxes(Rotation,X,Y,Z);
	projStart = Monster(Pawn).GetFireStart(X,Y,Z);
	projStart = projStart + StartPosition - Pawn.Location;
	projStart.Z = projStart.Z - 1.8 * (Pawn.CollisionHeight - Pawn.CrouchHeight);
	HitActor = 	Trace(HitLocation, HitNormal, TargetPosition , projStart, false);
	if ( HitActor == None )
	{
		Pawn.bWantsToCrouch = true;
		return;
	}

	projStart.Z = projStart.Z + 1.8 * (Pawn.Default.CollisionHeight - Pawn.CrouchHeight);
	HitActor = 	Trace(HitLocation, HitNormal, TargetPosition , projStart, false);
	if ( HitActor == None )
	{
		Pawn.bWantsToCrouch = false;
		return;
	}
	Pawn.bWantsToCrouch = true;
}

function Trigger( actor Other, pawn EventInstigator )
{
	if ( (Other == Pawn) || (Pawn.Health <= 0) )
		return;
	SetEnemy(EventInstigator,true);
}

function SetEnemyInfo(bool bNewEnemyVisible)
{
	AcquireTime = Level.TimeSeconds;
	if ( bNewEnemyVisible )
	{
		LastSeenTime = Level.TimeSeconds;
		LastSeenPos = Enemy.Location;
		LastSeeingPos = Pawn.Location;
		bEnemyInfoValid = true;
	}
	else
	{
		LastSeenTime = -1000;
		bEnemyInfoValid = false;
	}
}

// EnemyChanged() called when current enemy changes
function EnemyChanged(bool bNewEnemyVisible)
{
	bEnemyAcquired = false;
	SetEnemyInfo(bNewEnemyVisible);
	Monster(Pawn).PlayChallengeSound();
}

function bool StrafeFromDamage(float Damage, class<DamageType> DamageType, bool bFindDest);

//**********************************************************************

function bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume)
{
	local vector jumpDir;

	if ( newVolume.bWaterVolume )
	{
		if (!Pawn.bCanSwim)
			MoveTimer = -1.0;
		else if (Pawn.Physics != PHYS_Swimming)
			Pawn.setPhysics(PHYS_Swimming);
	}
	else if (Pawn.Physics == PHYS_Swimming)
	{
		if ( Pawn.bCanFly )
			 Pawn.SetPhysics(PHYS_Flying);
		else
		{
			Pawn.SetPhysics(PHYS_Falling);
			if ( Pawn.bCanWalk && (Abs(Pawn.Acceleration.X) + Abs(Pawn.Acceleration.Y) > 0)
				&& (Destination.Z >= Pawn.Location.Z)
				&& Pawn.CheckWaterJump(jumpDir) )
				Pawn.JumpOutOfWater(jumpDir);
		}
	}
	return false;
}

event NotifyMissedJump()
{
	if ( Pawn.bCanFly )
		Pawn.SetPhysics(PHYS_Flying);
}

function Possess(Pawn aPawn)
{
	Super.Possess(aPawn);
	InitializeSkill(DeathMatch(Level.Game).AdjustedDifficulty);
	Pawn.MaxFallSpeed = 1.1 * Pawn.default.MaxFallSpeed; // so bots will accept a little falling damage for shorter routes
	Pawn.SetMovementPhysics();
	if (Pawn.Physics == PHYS_Walking)
		Pawn.SetPhysics(PHYS_Falling);
	WhatToDoNext(1);
	enable('NotifyBump');
}

function InitializeSkill(float InSkill)
{
	Skill = FClamp(InSkill, 0, 7);
	ReSetSkill();
}

function ResetSkill()
{
	local float AdjustedYaw;

	bLeadTarget = ( Skill >= 4 );
	SetCombatTimer();
	SetPeripheralVision();
	if ( Skill + ReactionTime > 7 )
		RotationRate.Yaw = 90000;
	else if ( Skill + ReactionTime >= 4 )
		RotationRate.Yaw = 20000 + 7000 * (skill + ReactionTime);
	else
		RotationRate.Yaw = 30000 + 4000 * (skill + ReactionTime);
    AdjustedYaw = (0.75 + 0.05 * ReactionTime) * RotationRate.Yaw;
	AcquisitionYawRate = AdjustedYaw;
	SetMaxDesiredSpeed();
}

function SetMaxDesiredSpeed()
{
	if ( Pawn != None )
	{
		if ( Skill > 3 )
			Pawn.MaxDesiredSpeed = 1;
		else
			Pawn.MaxDesiredSpeed = 0.6 + 0.1 * Skill;
	}
}

function SetPeripheralVision()
{
	if ( Pawn == None )
		return;
	if ( Skill < 2 )
		Pawn.PeripheralVision = 0.7;
	else if ( Skill > 5 )
		Pawn.PeripheralVision = 0;
	else
		Pawn.PeripheralVision = 1.0 - 0.2 * skill;

	Pawn.SightRadius = Pawn.Default.SightRadius;
}

//=============================================================================
function WhatToDoNext(byte CallingByte)
{
	if ( ChoosingAttackLevel > 0 )
		log("CHOOSEATTACKAGAIN in state "$GetStateName()$" enemy "$GetEnemyName()$" old enemy "$GetOldEnemyName()$" CALLING BYTE "$CallingByte);

	if ( ChooseAttackTime == Level.TimeSeconds )
	{
		ChooseAttackCounter++;
		if ( ChooseAttackCounter > 3 )
			log("CHOOSEATTACKSERIAL in state "$GetStateName()$" enemy "$GetEnemyName()$" old enemy "$GetOldEnemyName()$" CALLING BYTE "$CallingByte);
	}
	else
	{
		ChooseAttackTime = Level.TimeSeconds;
		ChooseAttackCounter = 0;
	}
	if ( Monster(Pawn).bTryToWalk && (Pawn.Physics == PHYS_Flying) && (ChoosingAttackLevel == 0) && (ChooseAttackCounter == 0) )
		TryToWalk();
	ChoosingAttackLevel++;
	ExecuteWhatToDoNext();
	ChoosingAttackLevel--;
}

/* Check if just above ground - if so land
*/
function TryToWalk()
{
	local vector HitLocation, HitNormal, Extent;
	local actor HitActor;

	if ( Pawn.PhysicsVolume.bWaterVolume )
		return;

	Extent = Pawn.GetCollisionExtent();
	HitActor = Trace(HitLocation, HitNormal, Pawn.Location - vect(0,0,100), Pawn.Location, false, Extent);
	if ( (HitActor != None) && HitActor.bWorldGeometry && (HitNormal.Z > MINFLOORZ) )
		Pawn.SetPhysics(PHYS_Falling);
}

function string GetOldEnemyName()
{
	if ( OldEnemy == None )
		return "NONE";
	else
		return OldEnemy.GetHumanReadableName();
}

function string GetEnemyName()
{
	if ( Enemy == None )
		return "NONE";
	else
		return Enemy.GetHumanReadableName();
}

function ExecuteWhatToDoNext()
{
	bHasFired = false;
	GoalString = "WhatToDoNext at "$Level.TimeSeconds;
	if ( Pawn == None )
	{
		warn(GetHumanReadableName()$" WhatToDoNext with no pawn");
		return;
	}

	if ( bPreparingMove && Monster(Pawn).bShotAnim )
	{
		Pawn.Acceleration = vect(0,0,0);
		GotoState('WaitForAnim');
		return;
	}
	if (Pawn.Physics == PHYS_None)
		Pawn.SetMovementPhysics();
	if ( (Pawn.Physics == PHYS_Falling) && DoWaitForLanding() )
		return;
	if ( (Enemy != None) && ((Enemy.Health <= 0) || (Enemy.Controller == None)) )
		Enemy = None;

	if ( Level.Game.bGameEnded && (Enemy != None) && Enemy.Controller.bIsPlayer )
		Enemy = None;

	if ( (Enemy == None) || !EnemyVisible() )
		FindNewEnemy();

	if ( Enemy != None )
		ChooseAttackMode();
	else
	{
		GoalString = "WhatToDoNext Wander or Camp at "$Level.TimeSeconds;
		WanderOrCamp(true);
	}
}

function bool DoWaitForLanding()
{
	GotoState('WaitingForLanding');
	return true;
}

function bool EnemyVisible()
{
	if ( (EnemyVisibilityTime == Level.TimeSeconds) && (VisibleEnemy == Enemy) )
		return bEnemyIsVisible;
	VisibleEnemy = Enemy;
	EnemyVisibilityTime = Level.TimeSeconds;
	bEnemyIsVisible = LineOfSightTo(Enemy);
	return bEnemyIsVisible;
}

function FightEnemy(bool bCanCharge)
{
	local vector X,Y,Z;
	local float enemyDist;
	local float AdjustedCombatStyle, Aggression;
	local bool bFarAway, bOldForcedCharge;
	local NavigationPoint N;

	if ( (Enemy == None) || (Pawn == None) )
		log("HERE 3 Enemy "$Enemy$" pawn "$Pawn);

	if ( (Enemy == FailedHuntEnemy) && (Level.TimeSeconds == FailedHuntTime) )
	{
		if ( !Enemy.Controller.bIsPlayer )
			FindNewEnemy();

		if ( Enemy == FailedHuntEnemy )
		{
			GoalString = "FAILED HUNT - HANG OUT";
			if ( EnemyVisible() )
				bCanCharge = false;
			else if ( (LastRespawnTime != Level.TimeSeconds) && ((LastSeenTime == 0) || (Level.TimeSeconds - LastSeenTime) > 15) && !Pawn.PlayerCanSeeMe() )
			{
				LastRespawnTime = Level.TimeSeconds;
				EnemyVisibilityTime = 0;
				N = Level.Game.FindPlayerStart(self,1);
				Pawn.SetLocation(N.Location+(Pawn.CollisionHeight - N.CollisionHeight) * vect(0,0,1));
			}
			if ( !EnemyVisible() )
			{
				WanderOrCamp(true);
				return;
			}
		}
	}

	bOldForcedCharge = bMustCharge;
	bMustCharge = false;
	enemyDist = VSize(Pawn.Location - Enemy.Location);
	AdjustedCombatStyle = CombatStyle;
	Aggression = 1.5 * FRand() - 0.8 + 2 * AdjustedCombatStyle
				+ FRand() * (Normal(Enemy.Velocity - Pawn.Velocity) Dot Normal(Enemy.Location - Pawn.Location));
	if ( Enemy.Weapon != None )
		Aggression += 2 * Enemy.Weapon.SuggestDefenseStyle();
	if ( enemyDist > MAXSTAKEOUTDIST )
		Aggression += 0.5;
	if ( (Pawn.Physics == PHYS_Walking) || (Pawn.Physics == PHYS_Falling) )
	{
		if (Pawn.Location.Z > Enemy.Location.Z + TACTICALHEIGHTADVANTAGE)
			Aggression = FMax(0.0, Aggression - 1.0 + AdjustedCombatStyle);
		else if ( (Skill < 4) && (enemyDist > 0.65 * MAXSTAKEOUTDIST) )
		{
			bFarAway = true;
			Aggression += 0.5;
		}
		else if (Pawn.Location.Z < Enemy.Location.Z - Pawn.CollisionHeight) // below enemy
			Aggression += CombatStyle;
	}

	if ( !EnemyVisible() )
	{
		GoalString = "Enemy not visible";
		if ( !bCanCharge )
		{
			GoalString = "Stake Out";
			DoStakeOut();
		}
		else
		{
			GoalString = "Hunt";
			GotoState('Hunting');
		}
		return;
	}

	// see enemy - decide whether to charge it or strafe around/stand and fire
	Target = Enemy;
	if( Monster(Pawn).PreferMelee() || (bCanCharge && bOldForcedCharge) )
	{
		GoalString = "Charge";
		DoCharge();
		return;
	}

	if ( bCanCharge && (Skill < 5) && bFarAway && (Aggression > 1) && (FRand() < 0.5) )
	{
		GoalString = "Charge closer";
		DoCharge();
		return;
	}

	if ( !Monster(Pawn).PreferMelee() && (FRand() > 0.17 * (skill - 1)) && !DefendMelee(enemyDist) )
	{
		GoalString = "Ranged Attack";
		DoRangedAttackOn(Enemy);
		return;
	}

	if ( bCanCharge )
	{
		if ( Aggression > 1 )
		{
			GoalString = "Charge 2";
			DoCharge();
			return;
		}
	}

	if ( !Pawn.bCanStrafe )
	{
		GoalString = "Ranged Attack";
		DoRangedAttackOn(Enemy);
		return;
	}

	GoalString = "Do tactical move";
	if ( !Monster(Pawn).RecommendSplashDamage() && Monster(Pawn).bCanDodge && (FRand() < 0.7) && (FRand()*Skill > 3) )
	{
		GetAxes(Pawn.Rotation,X,Y,Z);
		GoalString = "Try to Duck ";
		if ( FRand() < 0.5 )
		{
			Y *= -1;
			TryToDuck(Y, true);
		}
		else
			TryToDuck(Y, false);
	}
	DoTacticalMove();
}

function DoRangedAttackOn(Actor A)
{
	Target = A;
	GotoState('RangedAttack');
}

/* ChooseAttackMode()
Handles tactical attacking state selection - choose which type of attack to do from here
*/
function ChooseAttackMode()
{
	GoalString = " ChooseAttackMode last seen "$(Level.TimeSeconds - LastSeenTime);
	// should I run away?
	if ( (Enemy == None) || (Pawn == None) )
		log("HERE 1 Enemy "$Enemy$" pawn "$Pawn);
	GoalString = "ChooseAttackMode FightEnemy";
	FightEnemy(true);
}

event SoakStop(string problem)
{
	local UnrealPlayer PC;

	log(problem);
	SoakString = problem;
	GoalString = SoakString@GoalString;
	ForEach DynamicActors(class'UnrealPlayer',PC)
	{
		PC.SoakPause(Pawn);
		break;
	}
}

function bool FindRoamDest()
{
	local actor BestPath;

	if ( Pawn.FindAnchorFailedTime == Level.TimeSeconds )
	{
		// couldn't find an anchor.
		GoalString = "No anchor "$Level.TimeSeconds;
		if ( Pawn.LastValidAnchorTime > 5 )
		{
			if ( bSoaking )
				SoakStop("NO PATH AVAILABLE!!!");
			else
			{
				if ( NumRandomJumps > 4 )
				{
					Pawn.Health = 0;
					Pawn.Died( self, class'Suicided', Pawn.Location );
					return true;
				}
				else
				{
					// jump
					NumRandomJumps++;
					if ( Physics != PHYS_Falling )
					{
						Pawn.SetPhysics(PHYS_Falling);
						Pawn.Velocity = 0.5 * Pawn.GroundSpeed * VRand();
						Pawn.Velocity.Z = Pawn.JumpZ;
					}
				}
			}
		}
		//log(self$" Find Anchor failed!");
		return false;
	}
	NumRandomJumps = 0;
	GoalString = "Find roam dest "$Level.TimeSeconds;
	// find random NavigationPoint to roam to
	if ( (RouteGoal == None) || (Pawn.Anchor == RouteGoal)
		|| Pawn.ReachedDestination(RouteGoal) )
	{
		RouteGoal = FindRandomDest();
		BestPath = RouteCache[0];
		if ( RouteGoal == None )
		{
			if ( bSoaking && (Physics != PHYS_Falling) )
				SoakStop("COULDN'T FIND ROAM DESTINATION");
			return false;
		}
	}
	if ( BestPath == None )
		BestPath = FindPathToward(RouteGoal,false);
	if ( BestPath != None )
	{
		MoveTarget = BestPath;
		GotoState('Roaming');
		return true;
	}
	if ( bSoaking && (Physics != PHYS_Falling) )
		SoakStop("COULDN'T FIND ROAM PATH TO "$RouteGoal);
	RouteGoal = None;
	return false;
}

function bool TestDirection(vector dir, out vector pick)
{
	local vector HitLocation, HitNormal, dist;
	local actor HitActor;

	pick = dir * (MINSTRAFEDIST + 2 * MINSTRAFEDIST * FRand());

	HitActor = Trace(HitLocation, HitNormal, Pawn.Location + pick + 1.5 * Pawn.CollisionRadius * dir , Pawn.Location, false);
	if (HitActor != None)
	{
		pick = HitLocation + (HitNormal - dir) * 2 * Pawn.CollisionRadius;
		if ( !FastTrace(pick, Pawn.Location) )
			return false;
	}
	else
		pick = Pawn.Location + pick;

	dist = pick - Pawn.Location;
	if (Pawn.Physics == PHYS_Walking)
		dist.Z = 0;

	return (VSize(dist) > MINSTRAFEDIST);
}

function Restart()
{
	Super.Restart();
	ReSetSkill();
	GotoState('Roaming','DoneRoaming');
}

function CancelCampFor(Controller C);

function bool AdjustAround(Pawn Other)
{
	local float speed;
	local vector VelDir, OtherDir, SideDir;

	speed = VSize(Pawn.Acceleration);
	if ( speed < Pawn.WalkingPct * Pawn.GroundSpeed )
		return false;

	VelDir = Pawn.Acceleration/speed;
	VelDir.Z = 0;
	OtherDir = Other.Location - Pawn.Location;
	OtherDir.Z = 0;
	OtherDir = Normal(OtherDir);
	if ( (VelDir Dot OtherDir) > 0.8 )
	{
		bAdjusting = true;
		SideDir.X = VelDir.Y;
		SideDir.Y = -1 * VelDir.X;
		if ( (SideDir Dot OtherDir) > 0 )
			SideDir *= -1;
		AdjustLoc = Pawn.Location + 1.5 * Other.CollisionRadius * (0.5 * VelDir + SideDir);
	}
}

function DirectedWander(vector WanderDir)
{
	GoalString = "DIRECTED WANDER "$GoalString;
	Pawn.bWantsToCrouch = Pawn.bIsCrouched;
	if ( TestDirection(WanderDir,Destination) )
		GotoState('RestFormation', 'Moving');
	else
		GotoState('RestFormation', 'Begin');
}

event bool NotifyBump(actor Other)
{
	local Pawn P;

	Disable('NotifyBump');
	P = Pawn(Other);
	if ( (P == None) || (P.Controller == None) || (Enemy == P) )
		return false;
	if ( SetEnemy(P) )
	{
		WhatToDoNext(4);
		return false;
	}

	if ( Enemy == P )
		return false;

	if ( !AdjustAround(P) )
		CancelCampFor(P.Controller);
	return false;
}

function SetFall()
{
	if (Pawn.bCanFly)
	{
		Pawn.SetPhysics(PHYS_Flying);
		return;
	}
	if ( Pawn.bNoJumpAdjust )
	{
		Pawn.bNoJumpAdjust = false;
		return;
	}
	else
	{
		Pawn.Velocity = EAdjustJump(Pawn.Velocity.Z,Pawn.GroundSpeed);
		Pawn.Acceleration = vect(0,0,0);
	}
}

function bool NotifyLanded(vector HitNormal)
{
	local vector Vel2D;

	if ( MoveTarget != None )
	{
		Vel2D = Pawn.Velocity;
		Vel2D.Z = 0;
		if ( (Vel2D Dot (MoveTarget.Location - Pawn.Location)) < 0 )
		{
			Pawn.Acceleration = vect(0,0,0);
			if ( NavigationPoint(MoveTarget) != None )
				Pawn.Anchor = NavigationPoint(MoveTarget);
			MoveTimer = -1;
		}
	}
	return false;
}

/* FindBestPathToward()
Assumes the desired destination is not directly reachable.
It tries to set Destination to the location of the best waypoint, and returns true if successful
*/
function bool FindBestPathToward(Actor A, bool bCheckedReach, bool bAllowDetour)
{
	if ( !bCheckedReach && ActorReachable(A) )
		MoveTarget = A;
	else
		MoveTarget = FindPathToward(A,false);

	if ( MoveTarget != None )
		return true;
	else
	{
		if ( (A == Enemy) && (A != None) )
		{
			FailedHuntTime = Level.TimeSeconds;
			FailedHuntEnemy = Enemy;
		}
		if ( bSoaking && (Physics != PHYS_Falling) )
			SoakStop("COULDN'T FIND BEST PATH TO "$A);
	}
	return false;
}

function bool NeedToTurn(vector targ)
{
	local vector LookDir,AimDir;
	LookDir = Vector(Pawn.Rotation);
	LookDir.Z = 0;
	LookDir = Normal(LookDir);
	AimDir = targ - Pawn.Location;
	AimDir.Z = 0;
	AimDir = Normal(AimDir);

	return ((LookDir Dot AimDir) < 0.93);
}

/* NearWall()
returns true if there is a nearby barrier at eyeheight, and
changes FocalPoint to a suggested place to look
*/
function bool NearWall(float walldist)
{
	local actor HitActor;
	local vector HitLocation, HitNormal, ViewSpot, ViewDist, LookDir;

	LookDir = vector(Rotation);
	ViewSpot = Pawn.Location + Pawn.BaseEyeHeight * vect(0,0,1);
	ViewDist = LookDir * walldist;
	HitActor = Trace(HitLocation, HitNormal, ViewSpot + ViewDist, ViewSpot, false);
	if ( HitActor == None )
		return false;

	ViewDist = Normal(HitNormal Cross vect(0,0,1)) * walldist;
	if (FRand() < 0.5)
		ViewDist *= -1;

	Focus = None;
	if ( FastTrace(ViewSpot + ViewDist, ViewSpot) )
	{
		FocalPoint = Pawn.Location + ViewDist;
		return true;
	}

	if ( FastTrace(ViewSpot - ViewDist, ViewSpot) )
	{
		FocalPoint = Pawn.Location - ViewDist;
		return true;
	}

	FocalPoint = Pawn.Location - LookDir * 300;
	return true;
}

// check for line of sight to target deltatime from now.
function bool CheckFutureSight(float deltatime)
{
	local vector FutureLoc;

	if ( Target == None )
		Target = Enemy;
	if ( Target == None )
		return false;

	if ( Pawn.Acceleration == vect(0,0,0) )
		FutureLoc = Pawn.Location;
	else
		FutureLoc = Pawn.Location + Pawn.GroundSpeed * Normal(Pawn.Acceleration) * deltaTime;

	if ( Pawn.Base != None )
		FutureLoc += Pawn.Base.Velocity * deltaTime;
	//make sure won't run into something
	if ( !FastTrace(FutureLoc, Pawn.Location) && (Pawn.Physics != PHYS_Falling) )
		return false;

	//check if can still see target
	if ( FastTrace(Target.Location + Target.Velocity * deltatime, FutureLoc) )
		return true;

	return false;
}

function float AdjustAimError(float aimerror, float TargetDist, bool bDefendMelee, bool bInstantProj, bool bLeadTargetNow )
{
	if ( (Pawn(Target) != None) && (Pawn(Target).Visibility < 2) )
		aimerror *= 2.5;

	// figure out the relative motion of the target across the bots view, and adjust aim error
	// based on magnitude of relative motion
	aimerror = aimerror * FMin(5,(12 - 11 *
		(Normal(Target.Location - Pawn.Location) Dot Normal((Target.Location + 1.2 * Target.Velocity) - (Pawn.Location + Pawn.Velocity)))));

	// if enemy is charging straight at bot with a melee weapon, improve aim
	if ( bDefendMelee )
		aimerror *= 0.5;

	if ( Target.Velocity == vect(0,0,0) )
		aimerror *= 0.6;

	// aiming improves over time if stopped
	if ( Stopped() && (Level.TimeSeconds > StopStartTime) )
	{
		if ( (Skill+Accuracy) > 4 )
			aimerror *= 0.9;
		aimerror *= FClamp((2 - 0.08 * FMin(skill,7) - FRand())/(Level.TimeSeconds - StopStartTime + 0.4),0.7,1.0);
	}

	// adjust aim error based on skill
	if ( !bDefendMelee )
		aimerror *= (3.3 - 0.37 * (FClamp(skill+Accuracy,0,8.5) + 0.5 * FRand()));

	// Bots don't aim as well if recently hit, or if they or their target is flying through the air
	if ( ((skill < 7) || (FRand()<0.5)) && (Level.TimeSeconds - Pawn.LastPainTime < 0.2) )
		aimerror *= 1.3;
	if ( (Pawn.Physics == PHYS_Falling) || (Target.Physics == PHYS_Falling) )
		aimerror *= 1.6;

	// Bots don't aim as well at recently acquired targets (because they haven't had a chance to lock in to the target)
	if ( AcquireTime > Level.TimeSeconds - 0.5 - 0.6 * (7 - skill) )
	{
		aimerror *= 1.5;
		if ( bInstantProj )
			aimerror *= 1.5;
	}

	return (Rand(2 * aimerror) - aimerror);
}

/*
AdjustAim()
Returns a rotation which is the direction the bot should aim - after introducing the appropriate aiming error
*/
function rotator AdjustAim(FireProperties FiredAmmunition, vector projStart, int aimerror)
{
	local rotator FireRotation, TargetLook;
	local float FireDist, TargetDist, ProjSpeed;
	local actor HitActor;
	local vector FireSpot, FireDir, TargetVel, HitLocation, HitNormal;
	local int realYaw;
	local bool bDefendMelee, bClean, bLeadTargetNow;

	if ( FiredAmmunition.ProjectileClass != None )
		projspeed = FiredAmmunition.ProjectileClass.default.speed;

	// make sure bot has a valid target
	if ( Target == None )
	{
		Target = Enemy;
		if ( Target == None )
			return Rotation;
	}
	FireSpot = Target.Location;
	TargetDist = VSize(Target.Location - Pawn.Location);

	// perfect aim at stationary objects
	if ( Pawn(Target) == None )
	{
		if ( !FiredAmmunition.bTossed )
			return rotator(Target.Location - projstart);
		else
		{
			FireDir = AdjustToss(projspeed,ProjStart,Target.Location,true);
			SetRotation(Rotator(FireDir));
			return Rotation;
		}
	}

	bLeadTargetNow = FiredAmmunition.bLeadTarget && bLeadTarget;
	bDefendMelee = ( (Target == Enemy) && DefendMelee(TargetDist) );
	aimerror = AdjustAimError(aimerror,TargetDist,bDefendMelee,FiredAmmunition.bInstantHit, bLeadTargetNow);

	// lead target with non instant hit projectiles
	if ( bLeadTargetNow )
	{
		TargetVel = Target.Velocity;
		// hack guess at projecting falling velocity of target
		if ( Target.Physics == PHYS_Falling )
		{
			if ( Target.PhysicsVolume.Gravity.Z <= Target.PhysicsVolume.Default.Gravity.Z )
				TargetVel.Z = FMin(TargetVel.Z + FMax(-400, Target.PhysicsVolume.Gravity.Z * FMin(1,TargetDist/projSpeed)),0);
			else
				TargetVel.Z = FMin(0, TargetVel.Z);
		}
		// more or less lead target (with some random variation)
		FireSpot += FMin(1, 0.7 + 0.6 * FRand()) * TargetVel * TargetDist/projSpeed;
		FireSpot.Z = FMin(Target.Location.Z, FireSpot.Z);

		if ( (Target.Physics != PHYS_Falling) && (FRand() < 0.55) && (VSize(FireSpot - ProjStart) > 1000) )
		{
			// don't always lead far away targets, especially if they are moving sideways with respect to the bot
			TargetLook = Target.Rotation;
			if ( Target.Physics == PHYS_Walking )
				TargetLook.Pitch = 0;
			bClean = ( ((Vector(TargetLook) Dot Normal(Target.Velocity)) >= 0.71) && FastTrace(FireSpot, ProjStart) );
		}
		else // make sure that bot isn't leading into a wall
			bClean = FastTrace(FireSpot, ProjStart);
		if ( !bClean)
		{
			// reduce amount of leading
			if ( FRand() < 0.3 )
				FireSpot = Target.Location;
			else
				FireSpot = 0.5 * (FireSpot + Target.Location);
		}
	}

	bClean = false; //so will fail first check unless shooting at feet
	if ( FiredAmmunition.bTrySplash && (Pawn(Target) != None) && ((Skill >=4) || bDefendMelee)
		&& (((Target.Physics == PHYS_Falling) && (Pawn.Location.Z + 80 >= Target.Location.Z))
			|| ((Pawn.Location.Z + 19 >= Target.Location.Z) && (bDefendMelee || (skill > 6.5 * FRand() - 0.5)))) )
	{
	 	HitActor = Trace(HitLocation, HitNormal, FireSpot - vect(0,0,1) * (Target.CollisionHeight + 6), FireSpot, false);
 		bClean = (HitActor == None);
		if ( !bClean )
		{
			FireSpot = HitLocation + vect(0,0,3);
			bClean = FastTrace(FireSpot, ProjStart);
		}
		else
			bClean = ( (Target.Physics == PHYS_Falling) && FastTrace(FireSpot, ProjStart) );
	}

	if ( !bClean )
	{
		//try middle
		FireSpot.Z = Target.Location.Z;
 		bClean = FastTrace(FireSpot, ProjStart);
	}
	if ( FiredAmmunition.bTossed && !bClean && bEnemyInfoValid )
	{
		FireSpot = LastSeenPos;
	 	HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
		if ( HitActor != None )
		{
			bCanFire = false;
			FireSpot += 2 * Target.CollisionHeight * HitNormal;
		}
		bClean = true;
	}

	if( !bClean )
	{
		// try head
 		FireSpot.Z = Target.Location.Z + 0.9 * Target.CollisionHeight;
 		bClean = FastTrace(FireSpot, ProjStart);
	}
	if ( !bClean && (Target == Enemy) && bEnemyInfoValid )
	{
		FireSpot = LastSeenPos;
		if ( Pawn.Location.Z >= LastSeenPos.Z )
			FireSpot.Z -= 0.4 * Enemy.CollisionHeight;
	 	HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
		if ( HitActor != None )
		{
			FireSpot = LastSeenPos + 2 * Enemy.CollisionHeight * HitNormal;
			if ( Monster(Pawn).SplashDamage() && (Skill >= 4) )
			{
			 	HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
				if ( HitActor != None )
					FireSpot += 2 * Enemy.CollisionHeight * HitNormal;
			}
			bCanFire = false;
		}
	}

	// adjust for toss distance
	if ( FiredAmmunition.bTossed )
		FireDir = AdjustToss(projspeed,ProjStart,FireSpot,true);
	else
		FireDir = FireSpot - ProjStart;

	FireRotation = Rotator(FireDir);
	realYaw = FireRotation.Yaw;
	InstantWarnTarget(Target,FiredAmmunition,vector(FireRotation));

	FireRotation.Yaw = SetFireYaw(FireRotation.Yaw + aimerror);
	FireDir = vector(FireRotation);
	// avoid shooting into wall
	FireDist = FMin(VSize(FireSpot-ProjStart), 400);
	FireSpot = ProjStart + FireDist * FireDir;
	HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
	if ( HitActor != None )
	{
		if ( HitNormal.Z < 0.7 )
		{
			FireRotation.Yaw = SetFireYaw(realYaw - aimerror);
			FireDir = vector(FireRotation);
			FireSpot = ProjStart + FireDist * FireDir;
			HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
		}
		if ( HitActor != None )
		{
			FireSpot += HitNormal * 2 * Target.CollisionHeight;
			if ( Skill >= 4 )
			{
				HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
				if ( HitActor != None )
					FireSpot += Target.CollisionHeight * HitNormal;
			}
			FireDir = Normal(FireSpot - ProjStart);
			FireRotation = rotator(FireDir);
		}
	}

	SetRotation(FireRotation);
	return FireRotation;
}

function ReceiveWarning(Pawn shooter, float projSpeed, vector FireDir)
{
	local float enemyDist, DodgeSkill;
	local vector X,Y,Z, enemyDir;

	// AI controlled creatures may duck if not falling
	DodgeSkill = Skill + Monster(Pawn).DodgeSkillAdjust;
	if ( (Pawn.health <= 0) || (DodgeSkill < 4) || (Enemy == None) || !Monster(Pawn).bCanDodge
		|| (Pawn.Physics == PHYS_Falling) || (Pawn.Physics == PHYS_Swimming)
		|| (FRand() > 0.2 * DodgeSkill - 0.4) )
		return;

	// and projectile time is long enough
	enemyDist = VSize(shooter.Location - Pawn.Location);
	if (enemyDist/projSpeed < 0.11 + 0.15 * FRand())
		return;
	// only if tight FOV
	GetAxes(Pawn.Rotation,X,Y,Z);
	enemyDir = (shooter.Location - Pawn.Location)/enemyDist;
	if ((enemyDir Dot X) < 0.8)
		return;
	if ( (FireDir Dot Y) > 0 )
	{
		Y *= -1;
		TryToDuck(Y, true);
	}
	else
		TryToDuck(Y, false);
}

function bool TryToDuck(vector duckDir, bool bReversed)
{
	local vector HitLocation, HitNormal, Extent;
	local actor HitActor;
	local bool bSuccess, bDuckLeft;

	if ( Pawn.PhysicsVolume.bWaterVolume
		|| (Pawn.PhysicsVolume.Gravity.Z > Pawn.PhysicsVolume.Default.Gravity.Z) )
		return false;

	duckDir.Z = 0;
	bDuckLeft = !bReversed;
	Extent = Pawn.GetCollisionExtent();
	HitActor = Trace(HitLocation, HitNormal, Pawn.Location + 240 * duckDir, Pawn.Location, false, Extent);
	bSuccess = ( (HitActor == None) || (VSize(HitLocation - Pawn.Location) > 150) );
	if ( !bSuccess )
	{
		bDuckLeft = !bDuckLeft;
		duckDir *= -1;
		HitActor = Trace(HitLocation, HitNormal, Pawn.Location + 240 * duckDir, Pawn.Location, false, Extent);
		bSuccess = ( (HitActor == None) || (VSize(HitLocation - Pawn.Location) > 150) );
	}
	if ( !bSuccess )
		return false;

	if ( HitActor == None )
		HitLocation = Pawn.Location + 240 * duckDir;

	HitActor = Trace(HitLocation, HitNormal, HitLocation - MAXSTEPHEIGHT * vect(0,0,1), HitLocation, false, Extent);
	if (HitActor == None)
		return false;

	if ( bDuckLeft )
		UnrealPawn(Pawn).CurrentDir = DCLICK_Left;
	else
		UnrealPawn(Pawn).CurrentDir = DCLICK_Right;
	UnrealPawn(Pawn).Dodge(UnrealPawn(Pawn).CurrentDir);
	return true;
}

function NotifyKilled(Controller Killer, Controller Killed, pawn KilledPawn)
{
	if ( Killer == self )
		Celebrate();
	if ( (KilledPawn == Enemy) || (Killed != None && Killed.bIsPlayer && (Enemy == None)) )
	{
		Enemy = None;
		FindNewEnemy();
	}
}

function Actor FaceMoveTarget()
{
	if ( MoveTarget != Enemy )
		StopFiring();
	return MoveTarget;
}

function bool ShouldStrafeTo(Actor WayPoint)
{
	local NavigationPoint N;

	if ( Monster(Pawn).bAlwaysStrafe )
		return true;

	if ( Skill + StrafingAbility < 3 )
		return false;

	if ( WayPoint == Enemy )
	{
		if ( Monster(Pawn).PreferMelee() )
			return false;
		return ( Skill + StrafingAbility < 5 * FRand() - 1 );
	}
	else if ( Pickup(WayPoint) == None )
	{
		N = NavigationPoint(WayPoint);
		if ( (N == None) || N.bNeverUseStrafing )
			return false;

		if ( N.FearCost > 200 )
			return true;
		if ( N.bAlwaysUseStrafing && (FRand() < 0.8) )
			return true;
	}
	if ( Pawn(WayPoint) != None )
		return ( Skill + StrafingAbility < 5 * FRand() - 1 );

	if ( Skill + StrafingAbility < 7 * FRand() - 1 )
		return false;

	if ( Enemy == None )
		return ( FRand() < 0.4 );

	if ( EnemyVisible() )
		return ( FRand() < 0.85 );
	return ( FRand() < 0.6 );
}

function Actor FaceActor(float StrafingModifier)
{
	local float RelativeDir;

	bRecommendFastMove = false;
	if ( (Enemy == None) || (Level.TimeSeconds - LastSeenTime > 6 - StrafingModifier) )
		return FaceMoveTarget();
	if ( MoveTarget == Enemy )
		return Enemy;
	if ( Level.TimeSeconds - LastSeenTime > 4 - StrafingModifier)
		return FaceMoveTarget();
	if ( (Skill > 2.5) && (GameObject(MoveTarget) != None) )
		return Enemy;
	RelativeDir = Normal(Enemy.Location - Pawn.Location - vect(0,0,1) * (Enemy.Location.Z - Pawn.Location.Z))
			Dot Normal(MoveTarget.Location - Pawn.Location - vect(0,0,1) * (MoveTarget.Location.Z - Pawn.Location.Z));

	if ( RelativeDir > 0.85 )
		return Enemy;
	if ( (RelativeDir > 0.3) && (Bot(Enemy.Controller) != None) && (MoveTarget == Enemy.Controller.MoveTarget) )
		return Enemy;
	if ( skill + StrafingAbility < 2 + FRand() )
		return FaceMoveTarget();

	if ( (RelativeDir < 0.3)
		|| (Skill + StrafingAbility < (5 + StrafingModifier) * FRand())
		|| (0.4*RelativeDir + 0.8 < FRand()) )
		return FaceMoveTarget();

	return Enemy;
}

function WanderOrCamp(bool bMayCrouch)
{
	GotoState('RestFormation');
}

event float Desireability(Pickup P)
{
	return -1;
}

function DamageAttitudeTo(Pawn Other, float Damage)
{
	if ( (Pawn.health > 0) && (Damage > 0) && SetEnemy(Other,true) )
		WhatToDoNext(5);
}

//**********************************************************************************
// AI States

//=======================================================================================================
// No goal/no enemy states

state NoGoal
{
}

function bool Formation()
{
	return false;
}

state RestFormation extends NoGoal
{
	ignores EnemyNotVisible;

	function CancelCampFor(Controller C)
	{
		DirectedWander(Normal(Pawn.Location - C.Pawn.Location));
	}

	function bool Formation()
	{
		return true;
	}

	function Timer()
	{
		SetCombatTimer();
		enable('NotifyBump');
	}


	function PickDestination()
	{
		if ( TestDirection(VRand(),Destination) )
			return;
		TestDirection(VRand(),Destination);
	}

	function BeginState()
	{
		Enemy = None;
		Pawn.bCanJump = false;
		Pawn.bAvoidLedges = true;
		Pawn.bStopAtLedges = true;
		Pawn.SetWalking(true);
		MinHitWall += 0.15;
	}

	function EndState()
	{
		MonitoredPawn = None;
		MinHitWall -= 0.15;
		if ( Pawn != None )
		{
			Pawn.bStopAtLedges = false;
			Pawn.bAvoidLedges = false;
			Pawn.SetWalking(false);
			if (Pawn.JumpZ > 0)
				Pawn.bCanJump = true;
		}
	}

	event MonitoredPawnAlert()
	{
		WhatToDoNext(6);
	}

Begin:
	WaitForLanding();
Camping:
	Pawn.Acceleration = vect(0,0,0);
	Focus = None;
	FocalPoint = VRand();
	NearWall(MINVIEWDIST);
	FinishRotation();
	Sleep(3 + FRand());
Moving:
	WaitForLanding();
	PickDestination();
WaitForAnim:
	if ( Monster(Pawn).bShotAnim )
	{
		Sleep(0.5);
		Goto('WaitForAnim');
	}
	MoveTo(Destination,,true);
	if ( Pawn.bCanFly && (Physics == PHYS_Walking) )
		SetPhysics(PHYS_Flying);
	WhatToDoNext(8);
	Goto('Begin');
}

function Celebrate()
{
	Pawn.PlayVictoryAnimation();
}

//=======================================================================================================
// Move To Goal states

state MoveToGoal
{
	function Timer()
	{
		SetCombatTimer();
		enable('NotifyBump');
	}
}

state MoveToGoalNoEnemy extends MoveToGoal
{
}

state MoveToGoalWithEnemy extends MoveToGoal
{
	function Timer()
	{
		TimedFireWeaponAtEnemy();
	}
}

state Roaming extends MoveToGoalNoEnemy
{
	ignores EnemyNotVisible;

	function MayFall()
	{
		Pawn.bCanJump = ( (MoveTarget != None)
					&& ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('Pickup')) );
	}

Begin:
	SwitchToBestWeapon();
	WaitForLanding();
	MoveToward(MoveTarget,FaceActor(1),,ShouldStrafeTo(MoveTarget));
DoneRoaming:
	WaitForLanding();
	WhatToDoNext(12);
	if ( bSoaking )
		SoakStop("STUCK IN ROAMING!");
}

//=======================================================================================================================
// Tactical Combat states

function DoStakeOut()
{
	GotoState('StakeOut');
}

function DoCharge()
{
	if ( Enemy.PhysicsVolume.bWaterVolume )
	{
		if ( !Pawn.bCanSwim )
		{
			DoTacticalMove();
			return;
		}
	}
	else if ( !Pawn.bCanFly && !Pawn.bCanWalk )
	{
		DoTacticalMove();
		return;
	}
	GotoState('Charging');
}

function DoTacticalMove()
{
	GotoState('TacticalMove');
}

/* DefendMelee()
return true if defending against melee attack
*/
function bool DefendMelee(float Dist)
{
	return ( (Enemy.Weapon != None) && Enemy.Weapon.bMeleeWeapon && (Dist < 1000) );
}

state Charging extends MoveToGoalWithEnemy
{
ignores SeePlayer, HearNoise;

	/* MayFall() called by engine physics if walking and bCanJump, and
		is about to go off a ledge.  Pawn has opportunity (by setting
		bCanJump to false) to avoid fall
	*/
	function MayFall()
	{
		if ( MoveTarget != Enemy )
			return;

		Pawn.bCanJump = ActorReachable(Enemy);
		if ( !Pawn.bCanJump )
			MoveTimer = -1.0;
	}

	function bool TryToDuck(vector duckDir, bool bReversed)
	{
		if ( FRand() < 0.6 )
			return Global.TryToDuck(duckDir, bReversed);
		if ( MoveTarget == Enemy )
			return TryStrafe(duckDir);
	}

	function bool StrafeFromDamage(float Damage, class<DamageType> DamageType, bool bFindDest)
	{
		local vector sideDir;

		if ( FRand() * Damage < 0.15 * CombatStyle * Pawn.Health )
			return false;

		if ( !bFindDest )
			return true;

		sideDir = Normal( Normal(Enemy.Location - Pawn.Location) Cross vect(0,0,1) );
		if ( (Pawn.Velocity Dot sidedir) > 0 )
			sidedir *= -1;

		return TryStrafe(sideDir);
	}

	function bool TryStrafe(vector sideDir)
	{
		local vector extent, HitLocation, HitNormal;
		local actor HitActor;

		Extent = Pawn.GetCollisionExtent();
		HitActor = Trace(HitLocation, HitNormal, Pawn.Location + MINSTRAFEDIST * sideDir, Pawn.Location, false, Extent);
		if (HitActor != None)
		{
			sideDir *= -1;
			HitActor = Trace(HitLocation, HitNormal, Pawn.Location + MINSTRAFEDIST * sideDir, Pawn.Location, false, Extent);
		}
		if (HitActor != None)
			return false;

		if ( Pawn.Physics == PHYS_Walking )
		{
			HitActor = Trace(HitLocation, HitNormal, Pawn.Location + MINSTRAFEDIST * sideDir - MAXSTEPHEIGHT * vect(0,0,1), Pawn.Location + MINSTRAFEDIST * sideDir, false, Extent);
			if ( HitActor == None )
				return false;
		}
		Destination = Pawn.Location + 2 * MINSTRAFEDIST * sideDir;
		GotoState('TacticalMove', 'DoStrafeMove');
		return true;
	}

	function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
	{
		local float pick;
		local vector sideDir;
		local bool bWasOnGround;

		Super.NotifyTakeHit(InstigatedBy,HitLocation, Damage,DamageType,Momentum);

		bWasOnGround = (Pawn.Physics == PHYS_Walking);
		if ( Pawn.health <= 0 )
			return;
		if ( StrafeFromDamage(damage, damageType, true) )
			return;
		else if ( bWasOnGround && (MoveTarget == Enemy) &&
					(Pawn.Physics == PHYS_Falling) ) //weave
		{
			pick = 1.0;
			if ( bStrafeDir )
				pick = -1.0;
			sideDir = Normal( Normal(Enemy.Location - Pawn.Location) Cross vect(0,0,1) );
			sideDir.Z = 0;
			Pawn.Velocity += pick * Pawn.GroundSpeed * 0.7 * sideDir;
			if ( FRand() < 0.2 )
				bStrafeDir = !bStrafeDir;
		}
	}

	event bool NotifyBump(actor Other)
	{
		if ( Other == Enemy )
		{
			DoRangedAttackOn(Enemy);
			return false;
		}
		return Global.NotifyBump(Other);
	}

	function Timer()
	{
		enable('NotifyBump');
		Target = Enemy;
		TimedFireWeaponAtEnemy();
	}

	function EnemyNotVisible()
	{
		WhatToDoNext(15);
	}

	function EndState()
	{
		if ( (Pawn != None) && Pawn.JumpZ > 0 )
			Pawn.bCanJump = true;
	}

Begin:
	if (Pawn.Physics == PHYS_Falling)
	{
		Focus = Enemy;
		Destination = Enemy.Location;
		WaitForLanding();
	}
	if ( Enemy == None )
		WhatToDoNext(16);
WaitForAnim:
	if ( Monster(Pawn).bShotAnim )
	{
		Sleep(0.35);
		Goto('WaitForAnim');
	}
	if ( !FindBestPathToward(Enemy, false,true) )
		GotoState('TacticalMove');
Moving:
	MoveToward(MoveTarget,FaceActor(1),,ShouldStrafeTo(MoveTarget));
	WhatToDoNext(17);
	if ( bSoaking )
		SoakStop("STUCK IN CHARGING!");
}

function bool IsStrafing()
{
	return false;
}

state TacticalMove
{
ignores SeePlayer, HearNoise;

	function bool IsStrafing()
	{
		return true;
	}

	function ReceiveWarning(Pawn shooter, float projSpeed, vector FireDir)
	{
		if ( bCanFire && (FRand() < 0.4) )
			return;

		Super.ReceiveWarning(shooter, projSpeed, FireDir);
	}

	function SetFall()
	{
		Pawn.Acceleration = vect(0,0,0);
		Destination = Pawn.Location;
		Global.SetFall();
	}

	function bool NotifyHitWall(vector HitNormal, actor Wall)
	{
		if (Pawn.Physics == PHYS_Falling)
			return false;
		if ( Enemy == None )
		{
			WhatToDoNext(18);
			return false;
		}
		if ( bChangeDir || (FRand() < 0.5)
			|| (((Enemy.Location - Pawn.Location) Dot HitNormal) < 0) )
		{
			Focus = Enemy;
			WhatToDoNext(19);
		}
		else
		{
			bChangeDir = true;
			Destination = Pawn.Location - HitNormal * FRand() * 500;
		}
		return true;
	}

	function Timer()
	{
		enable('NotifyBump');
		Target = Enemy;
		if ( Enemy != None )
			TimedFireWeaponAtEnemy();
		else
			SetCombatTimer();
	}

	function EnemyNotVisible()
	{
		StopFiring();
		if ( FastTrace(Enemy.Location, LastSeeingPos) )
			GotoState('TacticalMove','RecoverEnemy');
		else
			WhatToDoNext(20);
		Disable('EnemyNotVisible');
	}

	function PawnIsInPain(PhysicsVolume PainVolume)
	{
		Destination = Pawn.Location - MINSTRAFEDIST * Normal(Pawn.Velocity);
	}

	/* PickDestination()
	Choose a destination for the tactical move, based on aggressiveness and the tactical
	situation. Make sure destination is reachable
	*/
	function PickDestination()
	{
		local vector pickdir, enemydir, enemyPart, Y;
		local float strafeSize;

		if ( Pawn == None )
		{
			warn(self$" Tactical move pick destination with no pawn");
			return;
		}
		bChangeDir = false;
		if ( Pawn.PhysicsVolume.bWaterVolume && !Pawn.bCanSwim && Pawn.bCanFly)
		{
			Destination = Pawn.Location + 75 * (VRand() + vect(0,0,1));
			Destination.Z += 100;
			return;
		}

		enemydir = Normal(Enemy.Location - Pawn.Location);
		Y = (enemydir Cross vect(0,0,1));
		if ( Pawn.Physics == PHYS_Walking )
		{
			Y.Z = 0;
			enemydir.Z = 0;
		}
		else
			enemydir.Z = FMax(0,enemydir.Z);

		strafeSize = FClamp((2 * FRand() - 0.65),-0.7,0.7);
		strafeSize = FMax(0.4 * FRand() - 0.2,strafeSize);
		enemyPart = enemydir * strafeSize;
		if ( Pawn.bCanFly )
		{
			if ( Pawn.Location.Z - Enemy.Location.Z < 1000 )
				enemyPart = enemyPart + FRand() * vect(0,0,1);
			else
				enemyPart = enemyPart - FRand() * vect(0,0,0.7);
		}
		strafeSize = FMax(0.0, 1 - Abs(strafeSize));
		pickdir = strafeSize * Y;
		if ( bStrafeDir )
			pickdir *= -1;
		bStrafeDir = !bStrafeDir;

		if ( EngageDirection(enemyPart + pickdir, false) )
			return;

		if ( EngageDirection(enemyPart - pickdir,false) )
			return;

		bForcedDirection = true;
		StartTacticalTime = Level.TimeSeconds;
		EngageDirection(EnemyPart + PickDir, true);
	}

	function bool EngageDirection(vector StrafeDir, bool bForced)
	{
		local actor HitActor;
		local vector HitLocation, collspec, MinDest, HitNormal;

		// successfully engage direction if can trace out and down
		MinDest = Pawn.Location + MINSTRAFEDIST * StrafeDir;
		if ( !bForced )
		{
			collSpec = Pawn.GetCollisionExtent();
			collSpec.Z = FMax(6, Pawn.CollisionHeight - Pawn.CollisionRadius);

			HitActor = Trace(HitLocation, HitNormal, MinDest, Pawn.Location, false, collSpec);
			if ( HitActor != None )
				return false;

			if ( Pawn.Physics == PHYS_Walking )
			{
				collSpec.X = FMin(14, 0.5 * Pawn.CollisionRadius);
				collSpec.Y = collSpec.X;
				HitActor = Trace(HitLocation, HitNormal, minDest - (Pawn.CollisionRadius + MAXSTEPHEIGHT) * vect(0,0,1), minDest, false, collSpec);
				if ( HitActor == None )
				{
					HitNormal = -1 * StrafeDir;
					return false;
				}
			}
		}
		Destination = MinDest + StrafeDir * (0.5 * MINSTRAFEDIST
											+ FMin(VSize(Enemy.Location - Pawn.Location), MINSTRAFEDIST * (FRand() + FRand())));
		return true;
	}

	function BeginState()
	{
		bForcedDirection = false;
		if ( Skill < 4 )
			Pawn.MaxDesiredSpeed = 0.4 + 0.08 * skill;
		MinHitWall += 0.15;
		Pawn.bAvoidLedges = true;
		Pawn.bStopAtLedges = true;
		Pawn.bCanJump = false;
		bAdjustFromWalls = false;
	}

	function EndState()
	{
		bAdjustFromWalls = true;
		if ( Pawn == None )
			return;
		SetMaxDesiredSpeed();
		Pawn.bAvoidLedges = false;
		Pawn.bStopAtLedges = false;
		MinHitWall -= 0.15;
		if (Pawn.JumpZ > 0)
			Pawn.bCanJump = true;
	}

TacticalTick:
	Sleep(0.02);
Begin:
	if (Pawn.Physics == PHYS_Falling)
	{
		Focus = Enemy;
		Destination = Enemy.Location;
		WaitForLanding();
	}
	PickDestination();

DoMove:
	if ( !Pawn.bCanStrafe )
	{
		StopFiring();
WaitForAnim:
		if ( Monster(Pawn).bShotAnim )
		{
			Sleep(0.5);
			Goto('WaitForAnim');
		}
		MoveTo(Destination);
	}
	else
	{
DoStrafeMove:
		MoveTo(Destination, Enemy);
	}
	if ( bForcedDirection && (Level.TimeSeconds - StartTacticalTime < 0.2) )
	{
		if ( Skill > 2 + 3 * FRand() )
		{
			bMustCharge = true;
			WhatToDoNext(51);
		}
		GoalString = "RangedAttack from failed tactical";
		DoRangedAttackOn(Enemy);
	}
	if ( (Enemy == None) || EnemyVisible() || !FastTrace(Enemy.Location, LastSeeingPos) || Monster(Pawn).PreferMelee() || !Pawn.bCanStrafe )
		Goto('FinishedStrafe');
	//CheckIfShouldCrouch(LastSeeingPos,Enemy.Location, 0.5);

RecoverEnemy:
	GoalString = "Recover Enemy";
	HidingSpot = Pawn.Location;
	StopFiring();
	Sleep(0.1 + 0.2 * FRand());
	Destination = LastSeeingPos + 4 * Pawn.CollisionRadius * Normal(LastSeeingPos - Pawn.Location);
	MoveTo(Destination, Enemy);

	if ( FireWeaponAt(Enemy) )
	{
		Pawn.Acceleration = vect(0,0,0);
		if ( Monster(Pawn).SplashDamage() )
		{
			StopFiring();
			Sleep(0.05);
		}
		else
			Sleep(0.1 + 0.3 * FRand() + 0.06 * (7 - FMin(7,Skill)));
		if ( FRand() > 0.5 )
		{
			Enable('EnemyNotVisible');
			Destination = HidingSpot + 4 * Pawn.CollisionRadius * Normal(HidingSpot - Pawn.Location);
			Goto('DoMove');
		}
	}
FinishedStrafe:
	WhatToDoNext(21);
	if ( bSoaking )
		SoakStop("STUCK IN TACTICAL MOVE!");
}

function bool IsHunting()
{
	return false;
}

state Hunting extends MoveToGoalWithEnemy
{
ignores EnemyNotVisible;

	/* MayFall() called by] engine physics if walking and bCanJump, and
		is about to go off a ledge.  Pawn has opportunity (by setting
		bCanJump to false) to avoid fall
	*/
	function bool IsHunting()
	{
		return true;
	}

	function MayFall()
	{
		Pawn.bCanJump = ( (MoveTarget == None) || (MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('Pickup') );
	}

	function SeePlayer(Pawn SeenPlayer)
	{
		if ( SeenPlayer == Enemy )
		{
			if ( Level.timeseconds - ChallengeTime > 7 )
			{
				ChallengeTime = Level.TimeSeconds;
				Monster(Pawn).PlayChallengeSound();
			}
			VisibleEnemy = Enemy;
			EnemyVisibilityTime = Level.TimeSeconds;
			bEnemyIsVisible = true;
			Focus = Enemy;
			WhatToDoNext(22);
		}
		else
			Global.SeePlayer(SeenPlayer);
	}

	function Timer()
	{
		SetCombatTimer();
		StopFiring();
	}

	function PickDestination()
	{
		local vector nextSpot, ViewSpot,Dir;
		local float posZ;
		local bool bCanSeeLastSeen;

		// If no enemy, or I should see him but don't, then give up
		if ( (Enemy == None) || (Enemy.Health <= 0) )
		{
			Enemy = None;
			WhatToDoNext(23);
			return;
		}

		if ( Pawn.JumpZ > 0 )
			Pawn.bCanJump = true;

		if ( ActorReachable(Enemy) )
		{
			Destination = Enemy.Location;
			MoveTarget = None;
			return;
		}

		ViewSpot = Pawn.Location + Pawn.BaseEyeHeight * vect(0,0,1);
		bCanSeeLastSeen = bEnemyInfoValid && FastTrace(LastSeenPos, ViewSpot);

		if ( FindBestPathToward(Enemy, true,true) )
			return;

		if ( bSoaking && (Physics != PHYS_Falling) )
			SoakStop("COULDN'T FIND PATH TO ENEMY "$Enemy);

		MoveTarget = None;
		if ( !bEnemyInfoValid )
		{
			Enemy = None;
			WhatToDoNext(26);
			return;
		}

		Destination = LastSeeingPos;
		bEnemyInfoValid = false;
		if ( FastTrace(Enemy.Location, ViewSpot)
			&& VSize(Pawn.Location - Destination) > Pawn.CollisionRadius )
			{
				SeePlayer(Enemy);
				return;
			}

		posZ = LastSeenPos.Z + Pawn.CollisionHeight - Enemy.CollisionHeight;
		nextSpot = LastSeenPos - Normal(Enemy.Velocity) * Pawn.CollisionRadius;
		nextSpot.Z = posZ;
		if ( FastTrace(nextSpot, ViewSpot) )
			Destination = nextSpot;
		else if ( bCanSeeLastSeen )
		{
			Dir = Pawn.Location - LastSeenPos;
			Dir.Z = 0;
			if ( VSize(Dir) < Pawn.CollisionRadius )
			{
				GoalString = "Stakeout 3 from hunt";
				GotoState('StakeOut');
				return;
			}
			Destination = LastSeenPos;
		}
		else
		{
			Destination = LastSeenPos;
			if ( !FastTrace(LastSeenPos, ViewSpot) )
			{
				// check if could adjust and see it
				if ( PickWallAdjust(Normal(LastSeenPos - ViewSpot)) || FindViewSpot() )
				{
					if ( Pawn.Physics == PHYS_Falling )
						SetFall();
					else
						GotoState('Hunting', 'AdjustFromWall');
				}
				else
				{
					GoalString = "Stakeout 2 from hunt";
					GotoState('StakeOut');
					return;
				}
			}
		}
	}

	function bool FindViewSpot()
	{
		local vector X,Y,Z;

		GetAxes(Rotation,X,Y,Z);

		// try left and right

		if ( FastTrace(Enemy.Location, Pawn.Location + 2 * Y * Pawn.CollisionRadius) )
		{
			Destination = Pawn.Location + 2.5 * Y * Pawn.CollisionRadius;
			return true;
		}

		if ( FastTrace(Enemy.Location, Pawn.Location - 2 * Y * Pawn.CollisionRadius) )
		{
			Destination = Pawn.Location - 2.5 * Y * Pawn.CollisionRadius;
			return true;
		}
		if ( FRand() < 0.5 )
			Destination = Pawn.Location - 2.5 * Y * Pawn.CollisionRadius;
		else
			Destination = Pawn.Location - 2.5 * Y * Pawn.CollisionRadius;
		return true;
	}

	function EndState()
	{
		if ( (Pawn != None) && (Pawn.JumpZ > 0) )
			Pawn.bCanJump = true;
	}

AdjustFromWall:
	MoveTo(Destination, MoveTarget);

Begin:
	WaitForLanding();
	if ( CanSee(Enemy) )
		SeePlayer(Enemy);
WaitForAnim:
	if ( Monster(Pawn).bShotAnim )
	{
		Sleep(0.35);
		Goto('WaitForAnim');
	}
	PickDestination();
	if ( Level.timeseconds - ChallengeTime > 10 )
	{
		ChallengeTime = Level.TimeSeconds;
		Monster(Pawn).PlayChallengeSound();
	}

SpecialNavig:
	if (MoveTarget == None)
		MoveTo(Destination);
	else
		MoveToward(MoveTarget,FaceActor(10),,(FRand() < 0.75) && ShouldStrafeTo(MoveTarget));

	WhatToDoNext(27);
	if ( bSoaking )
		SoakStop("STUCK IN HUNTING!");
}

function bool Stopped()
{
	return bPreparingMove;
}


state StakeOut
{
ignores EnemyNotVisible;

	function bool CanAttack(Actor Other)
	{
		return true;
	}

	function bool Stopped()
	{
		return true;
	}

	event SeePlayer(Pawn SeenPlayer)
	{
		if ( SeenPlayer == Enemy )
		{
			VisibleEnemy = Enemy;
			EnemyVisibilityTime = Level.TimeSeconds;
			bEnemyIsVisible = true;
			if ( FRand() < 0.5 )
			{
				Focus = Enemy;
				FireWeaponAt(Enemy);
			}
			WhatToDoNext(28);
		}
		else if ( SetEnemy(SeenPlayer) )
		{
			if ( Enemy == SeenPlayer )
			{
				VisibleEnemy = Enemy;
				EnemyVisibilityTime = Level.TimeSeconds;
				bEnemyIsVisible = true;
			}
			WhatToDoNext(29);
		}
	}
	/* DoStakeOut()
	called by ChooseAttackMode - if called in this state, means stake out twice in a row
	*/
	function DoStakeOut()
	{
		SetFocus();
		if ( (FRand() < 0.3) || !FastTrace(FocalPoint + vect(0,0,0.9) * Enemy.CollisionHeight, Pawn.Location + vect(0,0,0.8) * Pawn.CollisionHeight) )
			FindNewStakeOutDir();
		GotoState('StakeOut','Begin');
	}

	function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
	{
		Super.NotifyTakeHit(InstigatedBy,HitLocation, Damage,DamageType,Momentum);
		if ( (Pawn.Health > 0) && (Damage > 0) )
		{
			if ( InstigatedBy == Enemy )
				AcquireTime = Level.TimeSeconds;
			WhatToDoNext(30);
		}
	}

	function Timer()
	{
		enable('NotifyBump');
		SetCombatTimer();
	}

	function rotator AdjustAim(FireProperties FiredAmmunition, vector projStart, int aimerror)
	{
		local vector FireSpot;
		local actor HitActor;
		local vector HitLocation, HitNormal;

		FireSpot = FocalPoint;

		HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
		if( HitActor != None )
		{
			FireSpot += 2 * Enemy.CollisionHeight * HitNormal;
			if ( !FastTrace(FireSpot, ProjStart) )
			{
				FireSpot = FocalPoint;
				StopFiring();
			}
		}

		SetRotation(Rotator(FireSpot - ProjStart));
		return Rotation;
	}

	function FindNewStakeOutDir()
	{
		local NavigationPoint N, Best;
		local vector Dir, EnemyDir;
		local float Dist, BestVal, Val;

		EnemyDir = Normal(Enemy.Location - Pawn.Location);
		for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		{
			Dir = N.Location - Pawn.Location;
			Dist = VSize(Dir);
			if ( (Dist < MAXSTAKEOUTDIST) && (Dist > MINSTRAFEDIST) )
			{
				Val = (EnemyDir Dot Dir/Dist);
				if ( Level.Game.bTeamgame )
					Val += FRand();
				if ( (Val > BestVal) && LineOfSightTo(N) )
				{
					BestVal = Val;
					Best = N;
				}
			}
		}
		if ( Best != None )
			FocalPoint = Best.Location + 0.5 * Pawn.CollisionHeight * vect(0,0,1);
	}

	function SetFocus()
	{
		if ( bEnemyInfoValid )
			FocalPoint = LastSeenPos;
		else
			FocalPoint = Enemy.Location;
	}

	function BeginState()
	{
		StopStartTime = Level.TimeSeconds;
		Pawn.Acceleration = vect(0,0,0);
		Pawn.bCanJump = false;
		SetFocus();
		if ( !bEnemyInfoValid || !ClearShot(FocalPoint,false) || ((Level.TimeSeconds - LastSeenTime > 6) && (FRand() < 0.5)) )
			FindNewStakeOutDir();
	}

	function EndState()
	{
		if ( (Pawn != None) && (Pawn.JumpZ > 0) )
			Pawn.bCanJump = true;
	}

Begin:
	Pawn.Acceleration = vect(0,0,0);
	Focus = None;
	CheckIfShouldCrouch(Pawn.Location,FocalPoint, 1);
	FinishRotation();
	if ( Monster(Pawn).HasRangedAttack() && (FRand() < 0.5) && (VSize(Enemy.Location - FocalPoint) < 150)
		 && (Level.TimeSeconds - LastSeenTime < 4) && ClearShot(FocalPoint,true) )
	{
		FireWeaponAt(Enemy);
	}
	else
		StopFiring();
	Sleep(1 + FRand());
	// check if uncrouching would help
	if ( Pawn.bIsCrouched
		&& !FastTrace(FocalPoint, Pawn.Location + Pawn.EyeHeight * vect(0,0,1))
		&& FastTrace(FocalPoint, Pawn.Location + (Pawn.Default.EyeHeight + Pawn.Default.CollisionHeight - Pawn.CollisionHeight) * vect(0,0,1)) )
	{
		Pawn.bWantsToCrouch = false;
		Sleep(0.15 + 0.05 * (1 + FRand()) * (10 - skill));
	}
	WhatToDoNext(31);
	if ( bSoaking )
		SoakStop("STUCK IN STAKEOUT!");
}

state RangedAttack
{
ignores SeePlayer, HearNoise, Bump;

	function bool Stopped()
	{
		return true;
	}

	function CancelCampFor(Controller C)
	{
		DoTacticalMove();
	}

	function StopFiring()
	{
		Global.StopFiring();
		if ( bHasFired )
		{
			bHasFired = false;
			WhatToDoNext(32);
		}
	}

	function EnemyNotVisible()
	{
		//let attack animation complete
		WhatToDoNext(33);
	}

	function Timer()
	{
		if ( Monster(Pawn).PreferMelee() )
		{
			SetCombatTimer();
			StopFiring();
			WhatToDoNext(34);
		}
		else
			TimedFireWeaponAtEnemy();
	}

	function DoRangedAttackOn(Actor A)
	{
		Target = A;
		GotoState('RangedAttack');
	}

	function BeginState()
	{
		StopStartTime = Level.TimeSeconds;
		bHasFired = false;
		Pawn.Acceleration = vect(0,0,0); //stop
		if ( Target == None )
			Target = Enemy;
		if ( Target == None )
			log(GetHumanReadableName()$" no target in ranged attack");
	}

Begin:
	bHasFired = false;
	GoalString = "Ranged attack";
	Focus = Target;
	Sleep(0.0);
	if ( Enemy != None )
		CheckIfShouldCrouch(Pawn.Location,Enemy.Location, 1);
	if ( NeedToTurn(Target.Location) )
	{
		Focus = Target;
		FinishRotation();
	}
	bHasFired = true;
	if ( Target == Enemy )
		TimedFireWeaponAtEnemy();
	else
		FireWeaponAt(Target);
	Sleep(0.1);
	if ( Monster(Pawn).PreferMelee() || (Target == None) || (Target != Enemy) || Monster(Pawn).bBoss )
		WhatToDoNext(35);
	if ( Enemy != None )
		CheckIfShouldCrouch(Pawn.Location,Enemy.Location, 1);
	Focus = Target;
	Sleep(FMax(Monster(Pawn).RangedAttackTime(),0.2 + (0.5 + 0.5 * FRand()) * 0.4 * (7 - Skill)));
	WhatToDoNext(36);
	if ( bSoaking )
		SoakStop("STUCK IN RANGEDATTACK!");
}

function GameHasEnded()
{
}

State WaitForAnim
{
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange, Falling, TakeDamage, ReceiveWarning;

	event AnimEnd(int Channel)
	{
		Pawn.AnimEnd(Channel);
		if ( !Monster(Pawn).bShotAnim )
			WhatToDoNext(99);
	}
}

State WaitingForLanding
{
	function bool DoWaitForLanding()
	{
		if ( bJustLanded )
			return false;
		BeginState();
		return true;
	}

	function bool NotifyLanded(vector HitNormal)
	{
		bJustLanded = true;
		Super.NotifyLanded(HitNormal);
		WhatToDoNext(50);
		return false;
	}

	function Timer()
	{
		if ( Focus == Enemy )
			TimedFireWeaponAtEnemy();
		else
			SetCombatTimer();
	}

	function BeginState()
	{
		bJustLanded = false;
		if ( (MoveTarget != None) && ((Enemy == None) ||(Focus != Enemy)) )
			FaceActor(1.5);
		if ( (Enemy == None) || (Focus != Enemy) )
			StopFiring();
	}
}

defaultproperties
{
     bLeadTarget=True
     CombatStyle=0.200000
     FovAngle=85.000000
}
