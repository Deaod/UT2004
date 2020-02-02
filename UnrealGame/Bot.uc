//=============================================================================
// Bot.
//=============================================================================
class Bot extends ScriptedController;

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
var		bool		bFrustrated;
var		bool		bInitLifeMessage;
var		bool		bReachedGatherPoint;
var		bool		bFinalStretch;
var		bool		bJumpy;				// likes to jump around if true OBSOLETE - use Jumpiness
var		bool		bHasTranslocator;
var		bool		bHasImpactHammer;
var		bool		bTacticalDoubleJump;
var		bool		bWasNearObjective;
var		bool		bPlannedShot;
var		bool		bHasFired;
var		bool		bForcedDirection;
var		bool		bFireSuccess;
var		bool		bStoppedFiring;
var		bool		bEnemyIsVisible;
var		bool		bTranslocatorHop;
var		bool		bEnemyEngaged;
var		bool		bMustCharge;
var		bool		bPursuingFlag;
var		bool		bJustLanded;
var		bool		bSingleTestSection;		// used in ReviewJumpSpots;
var		bool		bRecommendFastMove;
var		bool		bDodgingForward;
var		bool		bInstantAck;
var		bool		bShieldSelf;
var		bool		bIgnoreEnemyChange;		// to prevent calling whattodonext() again on enemy change
var		bool		bHasSuperWeapon;

var		actor		TranslocationTarget;
var		actor		RealTranslocationTarget;
var		actor		ImpactTarget;
var		float		TranslocFreq;
var		float		NextTranslocTime;

var name	OldMessageType;
var int		OldMessageID;

// Advanced AI attributes.
var	vector			HidingSpot;
var	float			Aggressiveness;		// 0.0 to 1.0 (typically)
var float			LastAttractCheck;
var NavigationPoint BlockedPath;
var	float			AcquireTime;		// time at which current enemy was acquired
var float			Aggression;
var float			LoseEnemyCheckTime;
var actor			StartleActor;
var	float			StartTacticalTime;
var float			LastUnderFire;

// modifiable AI attributes
var float			BaseAlertness;
var float			Accuracy;			// -1 to 1 (0 is default, higher is more accurate)
var	float		    BaseAggressiveness; // 0 to 1 (0.3 default, higher is more aggressive)
var	float			StrafingAbility;	// -1 to 1 (higher uses strafing more)
var	float			CombatStyle;		// -1 to 1 = low means tends to stay off and snipe, high means tends to charge and melee
var float			Tactics;
var float			TranslocUse;		// 0 to 1 - higher means more likely to use
var float			ReactionTime;
var float			Jumpiness;			// 0 to 1
var class<Weapon>	FavoriteWeapon;

// Team AI attributes
var string			GoalString;			// for debugging - used to show what bot is thinking (with 'ShowDebug')
var string			SoakString;			// for debugging - shows problem when soaking
var SquadAI			Squad;
var Bot				NextSquadMember;	// linked list of members of this squad

var float			ReTaskTime;			// time when squad will retask bot (delayed to avoid hitches)

// Scripted Sequences
var UnrealScriptedSequence GoalScript;	// ScriptedSequence bot is moving toward (assigned by TeamAI)
var UnrealScriptedSequence EnemyAcquisitionScript;

var Vehicle FormerVehicle;

enum EScriptFollow
{
	FOLLOWSCRIPT_IgnoreAllStimuli,
	FOLLOWSCRIPT_IgnoreEnemies,
	FOLLOWSCRIPT_StayOnScript,
	FOLLOWSCRIPT_LeaveScriptForCombat
};
var EScriptFollow ScriptedCombat;

var int FormationPosition;

// ChooseAttackMode() state
var	int			ChoosingAttackLevel;
var float		ChooseAttackTime;
var int			ChooseAttackCounter;
var float		EnemyVisibilityTime;
var	pawn		VisibleEnemy;
var pawn		OldEnemy;		//FIXME TEMP
var float		StopStartTime;
var float		LastRespawnTime;
var float		FailedHuntTime;
var Pawn		FailedHuntEnemy;

// inventory searh
var float		LastSearchTime;
var float		LastSearchWeight;
var float		CampTime;
var int LastTaunt;

var int		NumRandomJumps;			// attempts to free bot from being stuck
var string ComboNames[4];

// weapon check
var float LastFireAttempt;
var float GatherTime;

var() name OrderNames[16];
var name OldOrders;
var Controller OldOrderGiver;

// 1vs1 Enemy location model
var vector LastKnownPosition;
var vector LastKillerPosition;

// for testing
var NavigationPoint TestStart;
var int TestPath;
var name TestLabel;

const AngleConvert = 0.0000958738;	// 2*PI/65536

function Destroyed()
{
	Squad.RemoveBot(self);
	if ( GoalScript != None )
		GoalScript.FreeScript();
	Super.Destroyed();
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetCombatTimer();
	Aggressiveness = BaseAggressiveness;
	if ( UnrealMPGameInfo(Level.Game).bSoaking )
		bSoaking = true;
}

/* HasSuperWeapon() - returns superweapon if bot has one in inventory
*/
function weapon HasSuperWeapon()
{
	local Pawn CheckPawn;
	local Inventory Inv;

	if ( !bHasSuperWeapon )
		return None;

	if ( Vehicle(Pawn) != None )
		CheckPawn = Vehicle(Pawn).Driver;
	else
		CheckPawn = Pawn;

	if ( CheckPawn == None )
	{
		bHasSuperWeapon = false;
		return None;
	}

	for ( Inv=CheckPawn.Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if ( (Weapon(Inv) != None) && (Weapon(Inv).Default.InventoryGroup == 0)	&& Weapon(Inv).HasAmmo() )
			return Weapon(Inv);
	}

	bHasSuperWeapon = false;
	return None;
}

function NotifyAddInventory(inventory NewItem)
{
	if ( bHasSuperWeapon )
		return;

	bHasSuperWeapon = (Weapon(NewItem) != None) && (Weapon(NewItem).Default.InventoryGroup == 0);
}

function bool ShouldKeepShielding()
{
	if ( (Enemy == None) || (HoldObjective(Squad.SquadObjective) == None) || !Pawn.ReachedDestination(Squad.SquadObjective) )
		bShieldSelf = false;
	else
		Pawn.bWantsToCrouch = true;

	return bShieldSelf;
}

/* called before start of navigation network traversal to allow setup of transient navigation flags
*/
event SetupSpecialPathAbilities()
{
	bAllowedToTranslocate = CanUseTranslocator();
	bAllowedToImpactJump = CanImpactJump();
}

event bool NotifyHitWall(vector HitNormal, actor Wall)
{
	local Vehicle V;

	if ( (Vehicle(Wall) != None) && (Vehicle(Pawn) == None) )
	{
		if ( Wall == RouteGoal || (Vehicle(RouteGoal) != None && Wall == Vehicle(RouteGoal).GetVehicleBase()) )
		{
			V = Vehicle(Wall).FindEntryVehicle(Pawn);
			if ( V != None )
			{
				V.UsedBy(Pawn);
				if (Vehicle(Pawn) != None)
				{
					Squad.BotEnteredVehicle(self);
					WhatToDoNext(52);
				}
			}
			return true;
		}
		LastBlockingVehicle = Vehicle(Wall);
		if ( (Vehicle(Wall).Controller != None) || (FRand() < 0.9) )
			return false;
		bNotifyApex = true;
		bPendingDoubleJump = true;
		Pawn.SetPhysics(PHYS_Falling);
		Pawn.Velocity = Destination - Pawn.Location;
		Pawn.Velocity.Z = 0;
		Pawn.Velocity = Pawn.GroundSpeed * Normal(Pawn.Velocity);
		Pawn.Velocity.Z = Pawn.JumpZ;
	}
	return false;
}

function GetOutOfVehicle()
{
	if ( Vehicle(Pawn) == None )
		return;

	Vehicle(Pawn).PlayerStartTime = Level.TimeSeconds + 20;
	Vehicle(Pawn).KDriverLeave(false);
}

function bool CanDoubleJump(Pawn Other)
{
	return ( Pawn.bCanDoubleJump || (Pawn.PhysicsVolume.Gravity.Z > Pawn.PhysicsVolume.Default.Gravity.Z) );
}

function TryCombo(string ComboName)
{
	if ( !Pawn.InCurrentCombo() && !NeedsAdrenaline() )
	{
		if ( ComboName ~= "Random" )
			ComboName = ComboNames[Rand(ArrayCount(ComboNames))];
		else if ( ComboName ~= "DMRandom" )
			ComboName = ComboNames[1 + Rand(ArrayCount(ComboNames) - 1)];
		ComboName = Level.Game.NewRecommendCombo(ComboName, self);
		Pawn.DoComboName(ComboName);
		if ( !Pawn.InCurrentCombo() )
			log("WARNING - bot failed to start combo!");
	}
}

function FearThisSpot(AvoidMarker aSpot)
{
	if ( Skill > 1 + 4.5 * FRand() )
		Super.FearThisSpot(aSpot);
}

function Startle(Actor Feared)
{
	if ( Vehicle(Pawn) != None )
		return;
	GoalString = "STARTLED!";
	StartleActor = Feared;
	GotoState('Startled');
}

function SetCombatTimer()
{
	SetTimer(1.2 - 0.09 * FMin(10,Skill+ReactionTime), True);
}

function bool AutoTaunt()
{
	return true;
}

function bool DontReuseTaunt(int T)
{
	if ( T == LastTaunt )
		return true;

	if( T == Level.LastTaunt[0] || T == Level.LastTaunt[1] )
		return true;

	LastTaunt = T;

	Level.LastTaunt[1] = Level.LastTaunt[0];
	Level.LastTaunt[0] = T;

	return false;
}

function InitPlayerReplicationInfo()
{
	Super.InitPlayerReplicationInfo();
}

function Pawn GetMyPlayer()
{
	if ( PlayerController(Squad.SquadLeader) != None )
		return Squad.SquadLeader.Pawn;
	return Super.GetMyPlayer();
}

function UpdatePawnViewPitch()
{
    if (Pawn != None)
        Pawn.SetViewPitch(Rotation.Pitch);
}

//===========================================================================
// Weapon management functions

simulated function float RateWeapon(Weapon w)
{
	return (W.GetAIRating() + FRand() * 0.05);
}

function bool CanImpactJump()
{
	return ( bHasImpactHammer && (Pawn.Health >= 80) && (Skill >= 5) && Squad.AllowImpactJumpBy(self) );
}

function bool CanUseTranslocator()
{
	return ( bHasTranslocator && (skill >= 2) && (Level.TimeSeconds > NextTranslocTime) && Squad.AllowTranslocationBy(self) );
}

function ImpactJump()
{
	local vector RealDestination;

	// FIXME - charge up hack in here
	Pawn.Weapon.FireHack(0);
	// find correct initial velocity
	RealDestination = Destination;
	Destination = ImpactTarget.Location;
	bPlannedJump = true;
	Pawn.SetPhysics(PHYS_Falling);
	Pawn.Velocity = SuggestFallVelocity(Destination, Pawn.Location, Pawn.JumpZ+900, Pawn.GroundSpeed);
	if ( Pawn.Velocity.Z > 900 )
	{
		Pawn.Velocity.Z = Pawn.Velocity.Z - 0.5 * Pawn.JumpZ;
		bNotifyApex = true;
		bPendingDoubleJump = true;
	}
	Destination = RealDestination;
	ImpactTarget = None;
	bPreparingMove = false;
}

function WaitForMover(Mover M)
{
	Super.WaitForMover(M);
	StopStartTime = Level.TimeSeconds;
}

/* WeaponFireAgain()
Notification from weapon when it is ready to fire (either just finished firing,
or just finished coming up/reloading).
Returns true if weapon should fire.
If it returns false, can optionally set up a weapon change
*/
function bool WeaponFireAgain(float RefireRate, bool bFinishedFire)
{
	LastFireAttempt = Level.TimeSeconds;
	if ( Target == None )
		Target = Enemy;
	if ( Target != None )
	{
		if ( !Pawn.IsFiring() )
		{
			if ( (Pawn.Weapon != None && Pawn.Weapon.bMeleeWeapon) || (!NeedToTurn(Target.Location) && Pawn.CanAttack(Target)) )
			{
				Focus = Target;
				bCanFire = true;
				bStoppedFiring = false;
				if (Pawn.Weapon != None)
					bFireSuccess = Pawn.Weapon.BotFire(bFinishedFire);
				else
				{
					Pawn.ChooseFireAt(Target);
					bFireSuccess = true;
				}
				return bFireSuccess;
			}
			else
			{
				bCanFire = false;
			}
		}
		else if ( bCanFire && ShouldFireAgain(RefireRate) )
		{
			if ( (Target != None) && (Focus == Target) && !Target.bDeleteMe )
			{
				bStoppedFiring = false;
				if (Pawn.Weapon != None)
					bFireSuccess = Pawn.Weapon.BotFire(bFinishedFire);
				else
				{
					Pawn.ChooseFireAt(Target);
					bFireSuccess = true;
				}
				return bFireSuccess;
			}
		}
	}
	StopFiring();
	return false;
}

function bool ShouldFireAgain(float RefireRate)
{
	local DestroyableObjective ObjectiveTarget;

	if ( FRand() < RefireRate )
		return true;

	if ( Pawn.FireOnRelease() && (Pawn.Weapon == None || !Pawn.Weapon.bMeleeWeapon) )
		return false;

	if ( Pawn(Target) != None )
		return ( (Pawn.bStationary || Pawn(Target).bStationary) && (Pawn(Target).Health > 0) );

	if ( ShootTarget(Target) != None )
		ObjectiveTarget = DestroyableObjective(Target.Owner);
	else
		ObjectiveTarget = DestroyableObjective(Target);
	if ( ObjectiveTarget != None && ObjectiveTarget.DamageCapacity > 0 && ObjectiveTarget.bActive
	     && !ObjectiveTarget.bDisabled )
		return true;

	return false;
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
	if ( Pawn.Weapon != None )
	{
		if ( Pawn.Weapon.HasAmmo() )
			return WeaponFireAgain(Pawn.Weapon.RefireRate(),false);
	}
	else
		return WeaponFireAgain(Pawn.RefireRate(),false);

	return false;
}

function bool CanAttack(Actor Other)
{
	// return true if in range of current weapon
	return Pawn.CanAttack(Other);
}

function StopFiring()
{
	if ( (Pawn != None) && Pawn.StopWeaponFiring() )
		bStoppedFiring = true;

	bCanFire = false;
	bFire = 0;
	bAltFire = 0;
}

function ChangedWeapon()
{
	if ( Pawn.Weapon != None )
		Pawn.Weapon.SetHand(0);
}

function float WeaponPreference(Weapon W)
{
	local float WeaponStickiness;

	if ( (GoalScript != None) && (GoalScript.WeaponPreference != None)
		&& ClassIsChildOf(W.class, GoalScript.WeaponPreference)
		&& Pawn.ReachedDestination(GoalScript.GetMoveTarget()) )
		return 0.3;

	if ( (Target != None) && (Pawn(Target) == None) )
		return 0;

	if ( (FavoriteWeapon != None) && (ClassIsChildOf(W.class, FavoriteWeapon)) )
	{
		if ( W == Pawn.Weapon )
			return 0.3;
		return 0.15;
	}

	if ( W == Pawn.Weapon )
	{
		WeaponStickiness = 0.1 * W.MinReloadPct;
		if ( (Pawn.Weapon.AIRating < 0.5) || (Enemy == None) )
			return WeaponStickiness + 0.1;
		else if ( skill < 5 )
			return WeaponStickiness + 0.6 - 0.1 * skill;
		else
			return WeaponStickiness + 0.1;
	}
	return 0;
}

function bool ProficientWithWeapon()
{
	local float proficiency;

	if ( (Pawn == None) || (Pawn.Weapon == None) )
		return false;
	proficiency = skill;
	if ( (FavoriteWeapon != None) && ClassIsChildOf(Pawn.Weapon.class, FavoriteWeapon) )
		proficiency += 2;

	return ( proficiency > 2 + FRand() * 4 );
}

function bool CanComboMoving()
{
	if ( (Skill >= 5) && ClassIsChildOf(Pawn.Weapon.class, FavoriteWeapon) )
		return true;
	if ( Skill >= 7 )
		return (FRand() < 0.9);
	return ( Skill - 3 > 4 * FRand() );
}

function bool CanCombo()
{
	if ( Stopped() )
		return true;

	if ( Pawn.Physics == PHYS_Falling )
		return false;

	if ( (Pawn.Acceleration == vect(0,0,0)) || (MoveTarget == Enemy) )
		return true;

	return CanComboMoving();
}

//===========================================================================

function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local weapon best[5], moving, temp;
	local bool bFound;
	local int i;
	local inventory inv;
	local string S;

	Super.DisplayDebug(Canvas,YL, YPos);

	Canvas.SetDrawColor(255,255,255);
	Squad.DisplayDebug(Canvas,YL,YPos);
	if ( GoalScript != None )
		Canvas.DrawText("     "$GoalString$" goalscript "$GetItemName(string(GoalScript))$" Sniping "$IsSniping()$" ReTaskTime "$ReTaskTime, false);
	else
		Canvas.DrawText("     "$GoalString$" ReTaskTime "$ReTaskTime, false);

	YPos += 2*YL;
	Canvas.SetPos(4,YPos);

	if ( Enemy != None )
	{
		Canvas.DrawText("Enemy Dist "$VSize(Enemy.Location - Pawn.Location)$" Strength "$RelativeStrength(Enemy)$" Acquired "$bEnemyAcquired$" LastSeenTime "$(Level.TimeSeconds - LastSeenTime)$ " AcquireTime "$(Level.TimeSeconds - AcquireTime));
		YPos += YL;
		Canvas.SetPos(4,YPos);
	}

	for ( inv=Pawn.Inventory; inv!=None; inv=inv.Inventory )
	{
		if ( Weapon(Inv) != None )
		{
			bFound = false;
			for ( i=0; i<5; i++ )
				if ( Best[i] == None )
				{
					bFound = true;
					Best[i] = Weapon(Inv);
					break;
				}
			if ( !bFound )
			{
				Moving = Weapon(Inv);
				for ( i=0; i<5; i++ )
					if ( Best[i].CurrentRating < Moving.CurrentRating )
					{
						Temp = Moving;
						Moving = Best[i];
						Best[i] = Temp;
					}
			}
		}
	}

	Canvas.DrawText("Weapons Fire last attempt at "$LastFireAttempt$" success "$bFireSuccess$" stopped firing "$bStoppedFiring, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	for ( i=0; i<5; i++ )
		if ( Best[i] != None )
			S = S@GetItemName(string(Best[i]))@Best[i].CurrentRating;

	Canvas.DrawText("Weapons: "$S, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("PERSONALITY: Alertness "$BaseAlertness$" Accuracy "$Accuracy$" Favorite Weap "$FavoriteWeapon);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("    Aggressiveness "$BaseAggressiveness$" CombatStyle "$CombatStyle$" Strafing "$StrafingAbility$" Tactics "$Tactics$" TranslocUse "$TranslocUse);
	YPos += YL;
	Canvas.SetPos(4,YPos);
}

function name GetOrders()
{
	if ( HoldSpot(GoalScript) != None )
		return 'Hold';
	if ( PlayerController(Squad.SquadLeader) != None )
		return 'Follow';
	return Squad.GetOrders();
}

function actor GetOrderObject()
{
	if ( PlayerController(Squad.SquadLeader) != None )
		return Squad.SquadLeader;
	return Squad.SquadObjective;
}

/* YellAt()
Tell idiot to stop shooting me
*/
function YellAt(Pawn Moron)
{
	local float Threshold;

	if ( PlayerController(Moron.Controller) == None )
		Threshold = 0.95;
	else if ( Enemy == None )
		Threshold = 0.3;
	else
		Threshold = 0.7;
	if ( FRand() < Threshold )
		return;

	SendMessage(Moron.PlayerReplicationInfo, 'FRIENDLYFIRE', 0, 5, 'TEAM');
}

function byte GetMessageIndex(name PhraseName)
{
	if ( PlayerReplicationInfo.VoiceType == None )
		return 0;
	return PlayerReplicationInfo.Voicetype.Static.GetMessageIndex(PhraseName);
}

function SendMessage(PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait, name BroadcastType)
{
	// limit frequency of same message
	if ( (MessageType == OldMessageType) && (MessageID == OldMessageID)
		&& (Level.TimeSeconds - OldMessageTime < Wait) )
		return;

	if ( Level.Game.bGameEnded || Level.Game.bWaitingToStartMatch )
		return;

	OldMessageID = MessageID;
	OldMessageType = MessageType;

	SendVoiceMessage(PlayerReplicationInfo, Recipient, MessageType, MessageID, BroadcastType);
}

/* SetOrders()
Called when player gives orders to bot
*/
function SetOrders(name NewOrders, Controller OrderGiver)
{
	if ( PlayerReplicationInfo.Team != OrderGiver.PlayerReplicationInfo.Team )
		return;

	Aggressiveness = BaseAggressiveness;
	if ( (NewOrders == 'Hold') || (NewOrders == 'Follow') )
		Aggressiveness += 1;

	if ( bInstantAck )
		SendMessage(OrderGiver.PlayerReplicationInfo, 'ACK', 255, 5, 'TEAM');
	else
		SendMessage(OrderGiver.PlayerReplicationInfo, 'ACK', 0, 5, 'TEAM');
	bInstantAck = false;
	UnrealTeamInfo(PlayerReplicationInfo.Team).AI.SetOrders(self,NewOrders,OrderGiver);
	WhatToDoNext(1);
}

// Give bot orders but remember old orders, which are restored by calling ClearTemporaryOrders()
function SetTemporaryOrders(name NewOrders, Controller OrderGiver)
{
	if (OldOrders == 'None')
	{
		OldOrders = GetOrders();
		OldOrderGiver = Squad.SquadLeader;
		if (OldOrderGiver == None)
			OldOrderGiver = OrderGiver;
	}
	SetOrders(NewOrders, OrderGiver);
}

// Return bot to its previous orders
function ClearTemporaryOrders()
{
	if (OldOrders != 'None')
	{
		Aggressiveness = BaseAggressiveness;
		if ( (OldOrders == 'Hold') || (OldOrders == 'Follow') )
			Aggressiveness += 1;

		UnrealTeamInfo(PlayerReplicationInfo.Team).AI.SetOrders(self,OldOrders,OldOrderGiver);

		OldOrders = 'None';
		OldOrderGiver = None;
	}
}

function HearNoise(float Loudness, Actor NoiseMaker)
{
	if ( ((ChooseAttackCounter < 2) || (ChooseAttackTime != Level.TimeSeconds)) && (NoiseMaker != None) && Squad.SetEnemy(self,NoiseMaker.instigator) )
		WhatToDoNext(2);
}

event SeePlayer(Pawn SeenPlayer)
{
	if ( ((ChooseAttackCounter < 2) || (ChooseAttackTime != Level.TimeSeconds)) && Squad.SetEnemy(self,SeenPlayer) )
		WhatToDoNext(3);
	if ( Enemy == SeenPlayer )
	{
		VisibleEnemy = Enemy;
		EnemyVisibilityTime = Level.TimeSeconds;
		bEnemyIsVisible = true;
	}
}

function SetAttractionState()
{
	if ( Enemy != None )
		GotoState('FallBack');
	else
		GotoState('Roaming');
}

function bool ClearShot(Vector TargetLoc, bool bImmediateFire)
{
	local bool bSeeTarget;

	if ( (Enemy == None) || (VSize(Enemy.Location - TargetLoc) > MAXSTAKEOUTDIST) )
		return false;

	bSeeTarget = FastTrace(TargetLoc, Pawn.Location + Pawn.EyeHeight * vect(0,0,1));
	// if pawn is crouched, check if standing would provide clear shot
	if ( !bImmediateFire && !bSeeTarget && Pawn.bIsCrouched )
		bSeeTarget = FastTrace(TargetLoc, Pawn.Location + (Pawn.Default.EyeHeight + Pawn.Default.CollisionHeight - Pawn.CollisionHeight) * vect(0,0,1));

	if ( !bSeeTarget || !FastTrace(TargetLoc , Enemy.Location + Enemy.BaseEyeHeight * vect(0,0,1)) );
		return false;
	if ( (Pawn.Weapon.SplashDamage() && (VSize(Pawn.Location - TargetLoc) < Pawn.Weapon.GetDamageRadius()))
		|| !FastTrace(TargetLoc + vect(0,0,0.9) * Enemy.CollisionHeight, Pawn.Location) )
	{
		StopFiring();
		return false;
	}
	return true;
}

function bool CanStakeOut()
{
	local float relstr;

	relstr = RelativeStrength(Enemy);

	if ( bFrustrated || !bEnemyInfoValid
		 || (VSize(Enemy.Location - Pawn.Location) > 0.5 * (MAXSTAKEOUTDIST + (FRand() * relstr - CombatStyle) * MAXSTAKEOUTDIST))
		 || (Level.TimeSeconds - FMax(LastSeenTime,AcquireTime) > 2.5 + FMax(-1, 3 * (FRand() + 2 * (relstr - CombatStyle))) )
		 || !ClearShot(LastSeenPos,false) )
		return false;
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
		|| Pawn.Weapon.RecommendSplashDamage() )
	{
		Pawn.bWantsToCrouch = false;
		return;
	}

	GetAxes(Rotation,X,Y,Z);
	projStart = Pawn.Weapon.GetFireStart(X,Y,Z);
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

function bool IsSniping()
{
	return ( (GoalScript != None) && GoalScript.bSniping && Pawn.Weapon != None && Pawn.Weapon.bSniping
			&& Pawn.ReachedDestination(GoalScript.GetMovetarget()) );
}

function FreeScript()
{
	if ( GoalScript != None )
	{
		GoalScript.FreeScript();
		GoalScript = None;
	}
}

function bool AssignSquadResponsibility()
{
	if ( LastAttractCheck == Level.TimeSeconds )
		return false;
	LastAttractCheck = Level.TimeSeconds;

	return Squad.AssignSquadResponsibility(self);
}

/* RelativeStrength()
returns a value indicating the relative strength of other
> 0 means other is stronger than controlled pawn

Since the result will be compared to the creature's aggressiveness, it should be
on the same order of magnitude (-1 to 1)
*/

function float RelativeStrength(Pawn Other)
{
	local float compare;
	local int adjustedOther;

	if ( Pawn == None )
	{
		warn("Relative strength with no pawn in state "$GetStateName());
		return 0;
	}
	adjustedOther = 0.5 * (Other.health + Other.Default.Health);
	compare = 0.01 * float(adjustedOther - Pawn.health);
	compare = compare - Pawn.AdjustedStrength() + Other.AdjustedStrength();

	if ( Pawn.Weapon != None )
	{
		compare -= 0.5 * Pawn.DamageScaling * Pawn.Weapon.CurrentRating;
		if ( Pawn.Weapon.AIRating < 0.5 )
		{
			compare += 0.3;
			if ( (Other.Weapon != None) && (Other.Weapon.AIRating > 0.5) )
				compare += 0.3;
		}
	}
	if ( Other.Weapon != None )
		compare += 0.5 * Other.DamageScaling * Other.Weapon.AIRating;

	if ( Other.Location.Z > Pawn.Location.Z + TACTICALHEIGHTADVANTAGE )
		compare += 0.2;
	else if ( Pawn.Location.Z > Other.Location.Z + TACTICALHEIGHTADVANTAGE )
		compare -= 0.15;

	return Pawn.ModifyThreat(compare, Other);
}

function Trigger( actor Other, pawn EventInstigator )
{
	if ( Super.TriggerScript(Other,EventInstigator) )
		return;
	if ( (Other == Pawn) || (Pawn.Health <= 0) )
		return;
	Squad.SetEnemy(self,EventInstigator);
}

function SetEnemyInfo(bool bNewEnemyVisible)
{
	local Bot b;

	bEnemyEngaged = true;
	if ( bNewEnemyVisible )
	{
		AcquireTime = Level.TimeSeconds;
		LastSeenTime = Level.TimeSeconds;
		LastSeenPos = Enemy.Location;
		LastSeeingPos = Pawn.Location;
		bEnemyInfoValid = true;
	}
	else
	{
		LastSeenTime = -1000;
		bEnemyInfoValid = false;
		For ( B=Squad.SquadMembers; B!=None; B=B.NextSquadMember )
			if ( B.Enemy == Enemy )
				AcquireTime = FMax(AcquireTime, B.AcquireTime);
	}
}

// EnemyChanged() called by squad when current enemy changes
function EnemyChanged(bool bNewEnemyVisible)
{
	bEnemyAcquired = false;
	SetEnemyInfo(bNewEnemyVisible);
	//log(GetHumanReadableName()$" chooseattackmode from enemychanged at "$Level.TimeSeconds);
}

function BotVoiceMessage(name messagetype, byte MessageID, Controller Sender)
{
    if ( !Level.Game.bTeamGame || (Sender.PlayerReplicationInfo.Team != PlayerReplicationInfo.Team) )
		return;
	if ( messagetype == 'ORDER' )
		SetOrders(OrderNames[messageID], Sender);
}

function bool StrafeFromDamage(float Damage, class<DamageType> DamageType, bool bFindDest);

//**********************************************************************

function bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume)
{
	local vector jumpDir;

	if ( Vehicle(Pawn) != None )
		return false;

	if ( newVolume.bWaterVolume )
	{
		bPlannedJump = false;
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
			{
				Pawn.JumpOutOfWater(jumpDir);
				bNotifyApex = true;
				bPendingDoubleJump = true;
			}
		}
	}
	return false;
}

/* MayDodgeToMoveTarget()
called when starting MoveToGoal(), based on DodgeToGoalPct
Know have CurrentPath, with end lower than start
*/
event MayDodgeToMoveTarget()
{
	local vector Dir,X,Y,Z, DodgeV,NewDir;
	local float Dist,NewDist, RealJumpZ;
	local Actor OldMoveTarget;

	if ( (Pawn.Physics != PHYS_Walking) || ((FRand() > 0.85) && (RoadPathNode(MoveTarget) == None)) )
		return;

	if ( (bTranslocatorHop || (Focus != MoveTarget)) && (Skill+Jumpiness < 6) )
		return;

	// never in low grav
	if ( Pawn.PhysicsVolume.Gravity.Z > Pawn.PhysicsVolume.Default.Gravity.Z )
		return;

	Dir = MoveTarget.Location - Pawn.Location;
	Dist = VSize(Dir);
	OldMoveTarget = MoveTarget;

	// only dodge if far enough to destination
	if ( (Dist < 800) || (Dir.Z < 0) )
	{
		// maybe change movetarget
		if ( ((PathNode(MoveTarget) == None) && (PlayerStart(MoveTarget) == None)) || (MoveTarget != RouteCache[0]) || (RouteCache[0] == None) )
		{
			if ( Dist < 800 )
				return;
		}
		else if ( RouteCache[1] != None )
		{
			if ( Pawn.Location.Z + MAXSTEPHEIGHT < RouteCache[1].Location.Z )
			{
				if ( Dist < 800 )
					return;
			}

			NewDir = RouteCache[1].Location - Pawn.Location;
			NewDist = VSize(NewDir);
			if ( (NewDist > 800) && CanMakePathTo(RouteCache[1]) )
			{
				Dist = NewDist;
				Dir = NewDir;
				MoveTarget = RouteCache[1];
			}
			else if ( Dist < 800 )
				return;
		}
	}
	if ( Focus == OldMoveTarget )
		Focus = MoveTarget;
	Destination = MoveTarget.Location;
	GetAxes(Pawn.Rotation,X,Y,Z);

	if ( Abs(X Dot Dir) > Abs(Y Dot Dir) )
	{
		if ( (X Dot Dir) > 0 )
			UnrealPawn(Pawn).CurrentDir = DCLICK_Forward;
		else
			UnrealPawn(Pawn).CurrentDir = DCLICK_Back;
	}
	else if ( (Y Dot Dir) < 0 )
		UnrealPawn(Pawn).CurrentDir = DCLICK_Left;
	else
		UnrealPawn(Pawn).CurrentDir = DCLICK_Right;

	bPlannedJump = true;
	Pawn.PerformDodge(UnrealPawn(Pawn).CurrentDir, Normal(Dir), vect(0,0,0));
	if ( !bTranslocatorHop )
	{
		bNotifyApex = true;
		bPendingDoubleJump = true;
		bDodgingForward = true;
	}

	// if below, make sure really far
	if ( Dir.Z < -1 * Pawn.CollisionHeight )
	{
		Pawn.Velocity.Z = 0;
		RealJumpZ = Pawn.JumpZ;
		DodgeV = UnrealPawn(Pawn).BotDodge(vect(1,0,0));
		Pawn.JumpZ = DodgeV.Z;
		Pawn.Velocity = EAdjustJump(Pawn.Velocity.Z,DodgeV.X);
		Pawn.JumpZ = RealJumpZ;
	}
	Pawn.Acceleration = vect(0,0,0);
}

event NotifyJumpApex()
{
	local vector HitLocation, HitNormal,Dir,Extent;
	local actor HitActor;

	if ( bDodgingForward )
	{
		Extent = Pawn.GetCollisionExtent();
		bDodgingForward = false;
		Dir = Pawn.Velocity;
		Dir.Z = 0;
		HitActor = Trace(HitLocation, HitNormal, Pawn.Location + 140*Normal(Dir) + vect(0,0,32), Pawn.Location, false, Extent);
		if ( HitActor != None )
		{
			bNotifyApex = false;
			bPendingDoubleJump = false;
			return;
		}
		else
			bPendingDoubleJump = true;
	}
	Super.NotifyJumpApex();
}

event NotifyMissedJump()
{
	local NavigationPoint N;
	local actor OldMoveTarget;
	local vector Loc2D, NavLoc2D;
	local float BestDist, NewDist;

	OldMoveTarget = MoveTarget;
	if ( !bHasTranslocator )
		MoveTarget = None;

	if ( MoveTarget == None )
	{
		// find an acceptable path
		if ( bHasTranslocator && (skill >= 2) )
		{
			for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
			{
				if ( (VSize(N.Location - Pawn.Location) < 1500)
					&& LineOfSightTo(N) )
				{
					MoveTarget = N;
					break;
				}
			}
		}
		else
		{
			Loc2D = Pawn.Location;
			Loc2D.Z = 0;
			for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
			{
				if ( N.Location.Z < Pawn.Location.Z )
				{
					NavLoc2D = N.Location;
					NavLoc2D.Z = 0;
					NewDist = VSize(NavLoc2D - Loc2D);
					if ( (NewDist <= Pawn.Location.Z - N.Location.Z)
						&& ((MoveTarget == None) || (BestDist > NewDist))  && LineOfSightTo(N) )
					{
						MoveTarget = N;
						BestDist = NewDist;
					}
				}
			}
		}
		if ( MoveTarget == None )
		{
			MoveTarget = OldMoveTarget;
			return;
		}
	}

	// pass the ball first
	if ( Pawn.Weapon.IsA('BallLauncher') )
	{
		if ( PlayerReplicationInfo.HasFlag != None )
		{
			Pawn.Weapon.SetAITarget(MoveTarget);
			bPlannedShot = true;
			Target = MoveTarget;
			Pawn.Weapon.BotFire(false);
		}
	}
	else if ( bHasTranslocator && (skill >= 2) )
	{
		if ( !bPreparingMove || (TranslocationTarget != MoveTarget) )
		{
			bPreparingMove = true;
			TranslocationTarget = MoveTarget;
			RealTranslocationTarget = MoveTarget;
			ImpactTarget = MoveTarget;
			Focus = MoveTarget;
			if ( Pawn.Weapon.IsA('TransLauncher') )
			{
				Pawn.PendingWeapon = None;
				Pawn.Weapon.SetTimer(0.2,false);
			}
			else
				SwitchToBestWeapon();
		}
	}
	MoveTimer = 1.0;
}

function Reset()
{
	Super.Reset();

	ResetSkill();
	bFrustrated = false;
	bInitLifeMessage = false;
	bReachedGatherPoint = false;
	bFinalStretch = false;
	bHasSuperWeapon = false;
	StartleActor = None;
	GoalScript = None;
	if ( Pawn == None )
		GotoState('Dead');
}

function Possess(Pawn aPawn)
{
	Super.Possess(aPawn);
	bPlannedJump = false;
	ResetSkill();
	Pawn.MaxFallSpeed = 1.1 * Pawn.default.MaxFallSpeed; // so bots will accept a little falling damage for shorter routes
	Pawn.SetMovementPhysics();
	if (Pawn.Physics == PHYS_Walking)
		Pawn.SetPhysics(PHYS_Falling);
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

	// give gametype a chance to adjust skill of bot
	DeathMatch(Level.Game).TweakSkill(self);

	if ( Skill < 3 )
		DodgeToGoalPct = 0;
	else
		DodgeToGoalPct = 3*Jumpiness + Skill / 6;
	Aggressiveness = BaseAggressiveness;
	if ( Pawn != None )
		Pawn.bCanDoubleJump = ( (Skill >= 3) && Pawn.CanMultiJump() );
	bLeadTarget = ( Skill >= 4 );
	SetCombatTimer();
	SetPeripheralVision();
	if ( Skill + ReactionTime > 7 )
		RotationRate.Yaw = 90000;
	else if ( Skill + ReactionTime >= 4 )
		RotationRate.Yaw = 7000 + 10000 * (skill + ReactionTime);
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
	if ( Pawn.bStationary || (Pawn.Physics == PHYS_Flying) )
	{
		bSlowerZAcquire = false;
		Pawn.PeripheralVision = -0.7;
		return;
	}

	bSlowerZAcquire = true;
	if ( Skill < 2 )
		Pawn.PeripheralVision = 0.7;
	else if ( Skill > 6 )
	{
		bSlowerZAcquire = false;
		Pawn.PeripheralVision = -0.2;
	}
	else
		Pawn.PeripheralVision = 1.0 - 0.2 * skill;

	Pawn.PeripheralVision = FMin(Pawn.PeripheralVision - BaseAlertness, 0.8);
	Pawn.SightRadius = Pawn.Default.SightRadius;
}

/*
SetAlertness()
Change creature's alertness, and appropriately modify attributes used by engine for determining
seeing and hearing.
SeePlayer() is affected by PeripheralVision, and also by SightRadius and the target's visibility
HearNoise() is affected by HearingThreshold
*/
function SetAlertness(float NewAlertness)
{
	if ( Pawn.Alertness != NewAlertness )
	{
		Pawn.PeripheralVision += 0.707 * (Pawn.Alertness - NewAlertness); //Used by engine for SeePlayer()
		Pawn.Alertness = NewAlertness;
	}
}

function WasKilledBy(Controller Other)
{
	local Controller C;

	if ( Pawn.bUpdateEyeHeight )
	{
		for ( C=Level.ControllerList; C!=None; C=C.NextController )
			if ( C.IsA('PlayerController') && (PlayerController(C).ViewTarget == Pawn) && (PlayerController(C).RealViewTarget == None) )
				PlayerController(C).ViewNextBot();
	}
	if ( (Other != None) && (Other.Pawn != None) )
		LastKillerPosition = Other.Pawn.Location;
}

//=============================================================================
function WhatToDoNext(byte CallingByte)
{
	//if ( ChoosingAttackLevel > 0 )
	//	log("CHOOSEATTACKAGAIN in state "$GetStateName()$" enemy "$GetEnemyName()$" old enemy "$GetOldEnemyName()$" CALLING BYTE "$CallingByte);

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
	OldEnemy = Enemy;
	ChoosingAttackLevel++;
	ExecuteWhatToDoNext();
	ChoosingAttackLevel--;
	RetaskTime = 0;
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
	else if ( (Pawn.Weapon == None) && (Vehicle(Pawn) == None) )
		warn(GetHumanReadableName()$" WhatToDoNext with no weapon, "$Pawn$" health "$Pawn.health);
	if ( Enemy == None )
	{
		if ( Level.Game.TooManyBots(self) )
		{
			if ( Pawn != None )
			{
				if ( (Vehicle(Pawn) != None) && (Vehicle(Pawn).Driver != None) )
					Vehicle(Pawn).Driver.KilledBy(Vehicle(Pawn).Driver);
				else
				{
					Pawn.Health = 0;
					Pawn.Died( self, class'Suicided', Pawn.Location );
				}
			}
			Destroy();
			return;
		}
		BlockedPath = None;
		bFrustrated = false;
		if (Target == None || (Pawn(Target) != None && Pawn(Target).Health <= 0))
			StopFiring();
	}

	if ( ScriptingOverridesAI() && ShouldPerformScript() )
		return;
	if (Pawn.Physics == PHYS_None)
		Pawn.SetMovementPhysics();
	if ( (Pawn.Physics == PHYS_Falling) && DoWaitForLanding() )
		return;
	if ( (StartleActor != None) && !StartleActor.bDeleteMe && (VSize(StartleActor.Location - Pawn.Location) < StartleActor.CollisionRadius)  )
	{
		Startle(StartleActor);
		return;
	}
	bIgnoreEnemyChange = true;
	if ( (Enemy != None) && ((Enemy.Health <= 0) || (Enemy.Controller == None)) )
		LoseEnemy();
	if ( Enemy == None )
		Squad.FindNewEnemyFor(self,false);
	else if ( !Squad.MustKeepEnemy(Enemy) && !EnemyVisible() )
	{
		// decide if should lose enemy
		if ( Squad.IsDefending(self) )
		{
			if ( LostContact(4) )
				LoseEnemy();
		}
		else if ( LostContact(7) )
			LoseEnemy();
	}
	bIgnoreEnemyChange = false;
	if ( AssignSquadResponsibility() )
	{
		// might have gotten out of vehicle and been killed
		if ( Pawn == None )
			return;
		SwitchToBestWeapon();
		return;
	}
	if ( ShouldPerformScript() )
		return;
	if ( Enemy != None )
		ChooseAttackMode();
	else
	{
		GoalString = "WhatToDoNext Wander or Camp at "$Level.TimeSeconds;
		WanderOrCamp(true);
	}
	SwitchToBestWeapon();
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

function VehicleFightEnemy(bool bCanCharge, float EnemyStrength)
{
	if ( Pawn.bStationary || Vehicle(Pawn).bKeyVehicle )
	{
		if ( !EnemyVisible() )
		{
			GoalString = "Stake Out";
			DoStakeOut();
		}
		else
			DoRangedAttackOn(Enemy);
		return;
	}
	if ( !bFrustrated && Pawn.HasWeapon() && Pawn.TooCloseToAttack(Enemy) )
	{
		GoalString = "Retreat";
		if ( (PlayerReplicationInfo.Team != None) && (FRand() < 0.05) )
			SendMessage(None, 'Other', GetMessageIndex('INJURED'), 15, 'TEAM');
		DoRetreat();
		return;
	}
	if ( ((Enemy == FailedHuntEnemy) && (Level.TimeSeconds == FailedHuntTime)) || Vehicle(Pawn).bKeyVehicle )
	{
		GoalString = "FAILED HUNT - HANG OUT";
		if ( Pawn.HasWeapon() && EnemyVisible() )
			DoRangedAttackOn(Enemy);
		else
			WanderOrCamp(true);
		return;
	}
	if ( !EnemyVisible() )
	{
		if ( Squad.MustKeepEnemy(Enemy) )
		{
			GoalString = "Hunt priority enemy";
			GotoState('Hunting');
			return;
		}
		GoalString = "Enemy not visible";
		if ( !bCanCharge || (Squad.IsDefending(self) && LostContact(4)) )
		{
			GoalString = "Stake Out";
			DoStakeOut();
		}
		else if ( ((Aggression < 1) && !LostContact(3+2*FRand()) || IsSniping()) && CanStakeOut() )
		{
			GoalString = "Stake Out2";
			DoStakeOut();
		}
		else
		{
			GoalString = "Hunt";
			GotoState('Hunting');
		}
		return;
	}

	BlockedPath = None;
	Target = Enemy;

	if ( Pawn.bCanFly && !Enemy.bCanFly && (FRand() < 0.17 * (skill + Tactics - 1)) )
	{
		GoalString = "Do tactical move";
		DoTacticalMove();
		return;
	}

	if ( Pawn.RecommendLongRangedAttack() )
	{
		GoalString = "Long Ranged Attack";
		DoRangedAttackOn(Enemy);
		return;
	}
	GoalString = "Charge";
	DoCharge();
}


function FightEnemy(bool bCanCharge, float EnemyStrength)
{
	local vector X,Y,Z;
	local float enemyDist;
	local float AdjustedCombatStyle;
	local bool bFarAway, bOldForcedCharge;

	if ( (Squad == None) || (Enemy == None) || (Pawn == None) )
		log("HERE 3 Squad "$Squad$" Enemy "$Enemy$" pawn "$Pawn);

	if ( Vehicle(Pawn) != None )
	{
		VehicleFightEnemy(bCanCharge, EnemyStrength);
		return;
	}
	if ( (Enemy == FailedHuntEnemy) && (Level.TimeSeconds == FailedHuntTime) )
	{
		GoalString = "FAILED HUNT - HANG OUT";
		if ( EnemyVisible() )
			bCanCharge = false;
		else if ( FindInventoryGoal(0) )
		{
			SetAttractionState();
			return;
		}
		else
		{
			WanderOrCamp(true);
			return;
		}
	}

	bOldForcedCharge = bMustCharge;
	bMustCharge = false;
	enemyDist = VSize(Pawn.Location - Enemy.Location);
	AdjustedCombatStyle = CombatStyle + Pawn.Weapon.SuggestAttackStyle();
	Aggression = 1.5 * FRand() - 0.8 + 2 * AdjustedCombatStyle - 0.5 * EnemyStrength
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
		if ( Squad.MustKeepEnemy(Enemy) )
		{
			GoalString = "Hunt priority enemy";
			GotoState('Hunting');
			return;
		}
		GoalString = "Enemy not visible";
		if ( !bCanCharge )
		{
			GoalString = "Stake Out - no charge";
			DoStakeOut();
		}

		else if ( Squad.IsDefending(self) && LostContact(4) && ClearShot(LastSeenPos, false) )
		{
			GoalString = "Stake Out "$LastSeenPos;
			DoStakeOut();
		}
		else if ( (((Aggression < 1) && !LostContact(3+2*FRand())) || IsSniping()) && CanStakeOut() )
		{
			GoalString = "Stake Out2";
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
	BlockedPath = None;
	Target = Enemy;

	if( Pawn.Weapon.bMeleeWeapon || (bCanCharge && bOldForcedCharge) )
	{
		GoalString = "Charge";
		DoCharge();
		return;
	}
	if ( Pawn.RecommendLongRangedAttack() )
	{
		GoalString = "Long Ranged Attack";
		DoRangedAttackOn(Enemy);
		return;
	}

	if ( bCanCharge && (Skill < 5) && bFarAway && (Aggression > 1) && (FRand() < 0.5) )
	{
		GoalString = "Charge closer";
		DoCharge();
		return;
	}

	if ( Pawn.Weapon.RecommendRangedAttack() || IsSniping() || ((FRand() > 0.17 * (skill + Tactics - 1)) && !DefendMelee(enemyDist)) )
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
	GoalString = "Do tactical move";
	if ( !Pawn.Weapon.RecommendSplashDamage() && (FRand() < 0.7) && (3*Jumpiness + FRand()*Skill > 3) )
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
	local float EnemyStrength, WeaponRating, RetreatThreshold;

	GoalString = " ChooseAttackMode last seen "$(Level.TimeSeconds - LastSeenTime);
	// should I run away?
	if ( (Squad == None) || (Enemy == None) || (Pawn == None) )
		log("HERE 1 Squad "$Squad$" Enemy "$Enemy$" pawn "$Pawn);
	EnemyStrength = RelativeStrength(Enemy);

	if ( Vehicle(Pawn) != None )
	{
		VehicleFightEnemy(true, EnemyStrength);
		return;
	}
	if ( !bFrustrated && !Squad.MustKeepEnemy(Enemy) )
	{
		RetreatThreshold = Aggressiveness;
		if ( Pawn.Weapon.CurrentRating > 0.5 )
			RetreatThreshold = RetreatThreshold + 0.35 - skill * 0.05;
		if ( EnemyStrength > RetreatThreshold )
		{
			GoalString = "Retreat";
			if ( (PlayerReplicationInfo.Team != None) && (FRand() < 0.05) )
				SendMessage(None, 'Other', GetMessageIndex('INJURED'), 15, 'TEAM');
			DoRetreat();
			return;
		}
	}
	if ( (Squad.PriorityObjective(self) == 0) && (Skill + Tactics > 2) && ((EnemyStrength > -0.3) || (Pawn.Weapon.AIRating < 0.5)) )
	{
		if ( Pawn.Weapon.AIRating < 0.5 )
		{
			if ( EnemyStrength > 0.3 )
				WeaponRating = 0;
			else
				WeaponRating = Pawn.Weapon.CurrentRating/2000;
		}
		else if ( EnemyStrength > 0.3 )
			WeaponRating = Pawn.Weapon.CurrentRating/2000;
		else
			WeaponRating = Pawn.Weapon.CurrentRating/1000;

		// fallback to better pickup?
		if ( FindInventoryGoal(WeaponRating) )
		{
			if ( InventorySpot(RouteGoal) == None )
				GoalString = "fallback - inventory goal is not pickup but "$RouteGoal;
			else
				GoalString = "Fallback to better pickup "$InventorySpot(RouteGoal).markedItem$" hidden "$InventorySpot(RouteGoal).markedItem.bHidden;
			GotoState('FallBack');
			return;
		}
	}
	GoalString = "ChooseAttackMode FightEnemy";
	FightEnemy(true, EnemyStrength);
}

function bool FindSuperPickup(float MaxDist)
{
	local actor BestPath;
	local Pickup P;

	if ( (LastSearchTime == Level.TimeSeconds) || !Pawn.bCanPickupInventory || (Vehicle(Pawn) != None) )
		return false;

	if ( (DeathMatch(Level.Game) != None) && !DeathMatch(Level.Game).WantsPickups(self) )
		return false;

	LastSearchTime = Level.TimeSeconds;
	LastSearchWeight = -1;

	BestPath = FindBestSuperPickup(MaxDist);
	if ( BestPath != None )
	{
		MoveTarget = BestPath;
		if ( Pickup(RouteGoal) != None )
			P = Pickup(RouteGoal);
		else if ( InventorySpot(RouteGoal) != None )
			P = InventorySpot(RouteGoal).MarkedItem;
		if ( (P != None) && (PlayerReplicationInfo.Team != None)
			&& (PlayerReplicationInfo.Team.TeamIndex < 4) )
			P.TeamOwner[PlayerReplicationInfo.Team.TeamIndex] = self;
		return true;
	}
	return false;
}


function bool FindInventoryGoal(float BestWeight)
{
	local actor BestPath;

	if ( (LastSearchTime == Level.TimeSeconds) && (LastSearchWeight >= BestWeight) )
		return false;

	if ( (DeathMatch(Level.Game) != None) && !DeathMatch(Level.Game).WantsPickups(self) )
		return false;

	if ( !Pawn.bCanPickupInventory  || (Vehicle(Pawn) != None) )
		return false;

	LastSearchTime = Level.TimeSeconds;
	LastSearchWeight = BestWeight;

	 // look for inventory
	if ( (Skill > 3) && (Enemy == None) )
		RespawnPredictionTime = 4;
	else
		RespawnPredictionTime = 0;
	BestPath = FindBestInventoryPath(BestWeight);
	if ( BestPath != None )
	{
		MoveTarget = BestPath;
		return true;
	}
	return false;
}

function bool PickRetreatDestination()
{
	local actor BestPath;

	if ( FindInventoryGoal(0) )
		return true;

	if ( (RouteGoal == None) || (Pawn.Anchor == RouteGoal)
		|| Pawn.ReachedDestination(RouteGoal) )
	{
		RouteGoal = FindRandomDest();
		BestPath = RouteCache[0];
		if ( RouteGoal == None )
			return false;
	}

	if ( BestPath == None )
		BestPath = FindPathToward(RouteGoal,Pawn.bCanPickupInventory  && (Vehicle(Pawn) == None));
	if ( BestPath != None )
	{
		MoveTarget = BestPath;
		return true;
	}
	RouteGoal = None;
	return false;
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
				if ( (NumRandomJumps > 4) || PhysicsVolume.bWaterVolume )
				{
					Pawn.Health = 0;
					if ( (Vehicle(Pawn) != None) && (Vehicle(Pawn).Driver != None) )
						Vehicle(Pawn).Driver.KilledBy(Vehicle(Pawn).Driver);
					else
						Pawn.Died( self, class'Suicided', Pawn.Location );
					return true;
				}
				else
				{
					// jump
					NumRandomJumps++;
					if ( (Vehicle(Pawn) == None) && (Pawn.Physics != PHYS_Falling) )
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
		// first look for a scripted sequence
		Squad.SetFreelanceScriptFor(self);
		if ( GoalScript != None )
		{
			RouteGoal = GoalScript.GetMoveTarget();
			BestPath = None;
		}
		else
		{
			RouteGoal = FindRandomDest();
			BestPath = RouteCache[0];
		}
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
		SetAttractionState();
		return true;
	}
	if ( bSoaking && (Physics != PHYS_Falling) )
		SoakStop("COULDN'T FIND ROAM PATH TO "$RouteGoal);
	RouteGoal = None;
	FreeScript();
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
	if ( !bVehicleTransition )
	{
		Super.Restart();
		ReSetSkill();
		GotoState('Roaming','DoneRoaming');
		ClearTemporaryOrders();
	}
}

function bool CheckPathToGoalAround(Pawn P)
{
	return false;
}

function CancelCampFor(Controller C);

function ClearPathFor(Controller C)
{
	if ( Vehicle(Pawn) != None )
		return;
	if ( AdjustAround(C.Pawn) )
		return;
	if ( Enemy != None )
	{
		if ( EnemyVisible() && Pawn.bCanStrafe )
		{
			GotoState('TacticalMove');
			return;
		}
	}
	else if ( Stopped() && !Pawn.bStationary )
		DirectedWander(Normal(Pawn.Location - C.Pawn.Location));
}

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
	local Vehicle V;

	if ( (Vehicle(Other) != None) && (Vehicle(Pawn) == None) )
	{
		if ( Other == RouteGoal || (Vehicle(RouteGoal) != None && Other == Vehicle(RouteGoal).GetVehicleBase()) )
		{
			V = Vehicle(Other).FindEntryVehicle(Pawn);
			if ( V != None )
			{
				V.UsedBy(Pawn);
				if (Vehicle(Pawn) != None)
				{
					Squad.BotEnteredVehicle(self);
					WhatToDoNext(53);
				}
			}
			return true;
		}
	}

	Disable('NotifyBump');
	P = Pawn(Other);
	if ( (P == None) || (P.Controller == None) || (Enemy == P) )
		return false;
	if ( Squad.SetEnemy(self,P) )
	{
		WhatToDoNext(4);
		return false;
	}

	if ( Enemy == P )
		return false;

	if ( CheckPathToGoalAround(P) )
		return false;

	if ( !AdjustAround(P) )
		CancelCampFor(P.Controller);
	return false;
}

function bool PriorityObjective()
{
	return (Squad.PriorityObjective(self) > 0);
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
		bPlannedJump = true;
		Pawn.Velocity = EAdjustJump(Pawn.Velocity.Z,Pawn.GroundSpeed);
		Pawn.Acceleration = vect(0,0,0);
	}
}

function bool NotifyLanded(vector HitNormal)
{
	local vector Vel2D;

	bInDodgeMove = false;
	bPlannedJump = false;
	bNotifyFallingHitWall = false;
	bDodgingForward = false;
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
		else
		{
			if ( (RoadPathNode(MoveTarget) != None) && InLatentExecution(LATENT_MOVETOWARD) && (FRand() < 0.85)
				&& (FRand() < DodgeToGoalPct) && (Pawn.Location.Z + MAXSTEPHEIGHT >= MoveTarget.Location.Z)
				&& (VSize(MoveTarget.Location - Pawn.Location) > 800) )
				bNotifyPostLanded = true;
		}
	}
	return false;
}

event NotifyPostLanded()
{
	bNotifyPostLanded = false;
	if ( (Pawn != None) && (Pawn.Physics == PHYS_Walking) && (CurrentPath != None)
			&& ((CurrentPath.reachFlags & 257) == CurrentPath.reachFlags) )
	{
		MayDodgeToMoveTarget();
	}
}

function bool StartMoveToward(Actor O)
{
	if ( MoveTarget == None )
	{
		if ( (O == Enemy) && (O != None) )
		{
			FailedHuntTime = Level.TimeSeconds;
			FailedHuntEnemy = Enemy;
		}
		if ( bSoaking && (Pawn.Physics != PHYS_Falling) )
			SoakStop("COULDN'T FIND ROUTE TO "$O.GetHumanReadableName());
		GoalString = "No path to "$O.GetHumanReadableName()@"("$O$")";
	}
	else
		SetAttractionState();
	return ( MoveTarget != None );
}

function bool SetRouteToGoal(Actor A)
{
	if (Pawn.bStationary)
		return false;

	RouteGoal = A;
	FindBestPathToward(A,false,true);
	return StartMoveToward(A);
}

event bool AllowDetourTo(NavigationPoint N)
{
	return Squad.AllowDetourTo(self,N);
}

/* FindBestPathToward()
Assumes the desired destination is not directly reachable.
It tries to set Destination to the location of the best waypoint, and returns true if successful
*/
function bool FindBestPathToward(Actor A, bool bCheckedReach, bool bAllowDetour)
{
	local vehicle VBase;

	if ( !bCheckedReach && ActorReachable(A) )
		MoveTarget = A;
	else
		MoveTarget = FindPathToward(A,(bAllowDetour && Pawn.bCanPickupInventory  && (Vehicle(Pawn) == None) && (NavigationPoint(A) != None)));

	if ( MoveTarget != None )
		return true;
	else
	{
		if ( Vehicle(Pawn) != None )
		{
			if ( Pawn.Physics == PHYS_Flying )
			{
				if ( (A == Enemy) && (A != None) )
					LoseEnemy();
			}
			else if ( !Vehicle(Pawn).bKeyVehicle )
			{
				if ( Pawn.bStationary )
				{
					if ( (Vehicle(Pawn) != None) && Vehicle(Pawn).StronglyRecommended(Squad,Squad.Team.TeamIndex, Squad.SquadObjective) )
						return false;
					VBase = Pawn.GetVehicleBase();
				}
				if ( (VBase == None) || (VBase.Controller == None) )
				{
					Vehicle(Pawn).VehicleLostTime = Level.TimeSeconds + 20;
					//log(PlayerReplicationInfo.PlayerName$" 1 Abandoning "$Pawn$" because can't reach "$A);
					DirectionHint = Normal(A.Location - Pawn.Location);
					Vehicle(Pawn).KDriverLeave(false);
					MoveTarget = FindPathToward(A,(bAllowDetour && (NavigationPoint(A) != None)));
					if ( MoveTarget != None )
						return true;
				}
			}
		}

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
	return Pawn.NeedToTurn(targ);
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
	local float aimdist, desireddist, NewAngle;
	local vector VelDir, AccelDir;

	if ( Target.IsA('ONSMortarCamera') )
		return 0;

	if ( Pawn(Target) != None )
	{
		if ( Pawn(Target).Visibility < 2 )
			aimerror *= 2.5;
	}

	// figure out the relative motion of the target across the bots view, and adjust aim error
	// based on magnitude of relative motion
	aimerror = aimerror * FMin(5,(12 - 11 *
		(Normal(Target.Location - Pawn.Location) Dot Normal((Target.Location + 1.2 * Target.Velocity) - (Pawn.Location + Pawn.Velocity)))));

	if ( (Pawn(Target) != None) && Pawn(Target).bStationary )
	{
		aimerror *= 0.15;
		return (Rand(2 * aimerror) - aimerror);
	}

	// if enemy is charging straight at bot with a melee weapon, improve aim
	if ( bDefendMelee )
		aimerror *= 0.5;

	if ( Target.Velocity == vect(0,0,0) )
		aimerror *= 0.2 + 0.1 * (7 - FMin(7,Skill));
	else if ( Skill + Accuracy > 5 )
	{
		VelDir = Target.Velocity;
		VelDir.Z = 0;
		AccelDir = Target.Acceleration;
		AccelDir.Z = 0;
		if ( (AccelDir == vect(0,0,0)) || (Normal(VelDir) Dot Normal(AccelDir) > 0.95) )
			aimerror *= 0.8;
	}

	// aiming improves over time if stopped
	if ( Stopped() && (Level.TimeSeconds > StopStartTime) )
	{
		if ( (Skill+Accuracy) > 4 )
			aimerror *= 0.75;

		if ( Pawn.Weapon != None && Pawn.Weapon.bSniping )
			aimerror *= FClamp((1.5 - 0.08 * FMin(skill,7) - 0.8 * FRand())/(Level.TimeSeconds - StopStartTime + 0.4),0.3,1.0);
		else
			aimerror *= FClamp((2 - 0.08 * FMin(skill,7) - FRand())/(Level.TimeSeconds - StopStartTime + 0.4),0.7,1.0);
	}

	// adjust aim error based on skill
	if ( !bDefendMelee )
		aimerror *= (3.3 - 0.38 * (FClamp(skill+Accuracy,0,8) + 0.5 * FRand()));

	// Bots don't aim as well if recently hit, or if they or their target is flying through the air
	if ( ((skill < 6) || (FRand()<0.5)) && (Level.TimeSeconds - Pawn.LastPainTime < 0.2) )
		aimerror *= 1.3;
	if ( (Pawn.Physics == PHYS_Falling) || (Target.Physics == PHYS_Falling) )
		aimerror *= (1.6 - 0.04*(Skill+Accuracy));

	// Bots don't aim as well at recently acquired targets (because they haven't had a chance to lock in to the target)
	if ( AcquireTime > Level.TimeSeconds - 0.5 - 0.5 * (7 - FMin(7,skill)) )
	{
		aimerror *= 1.5;
		if ( bInstantProj )
			aimerror *= 1.5;
	}

	aimerror = 2 * aimerror * FRand() - aimerror;
	if ( abs(aimerror) > 700 )
	{
		if ( bInstantProj )
			DesiredDist = 100;
		else
			DesiredDist = 320;
		DesiredDist += Target.CollisionRadius;
		aimdist = tan(AngleConvert * aimerror) * targetdist;
		if ( abs(aimdist) > DesiredDist )
		{
			NewAngle = ATan(DesiredDist,TargetDist)/AngleConvert;
			if ( aimerror > 0 )
				aimerror = NewAngle;
			else
				aimerror = -1 * NewAngle;
		}
	}
	return aimerror;
}

/*
AdjustAim()
Returns a rotation which is the direction the bot should aim - after introducing the appropriate aiming error
*/
function rotator AdjustAim(FireProperties FiredAmmunition, vector projStart, int aimerror)
{
	local rotator FireRotation, TargetLook;
	local float FireDist, TargetDist, ProjSpeed,TravelTime;
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

	if ( Pawn(Target) != None )
		Target = Pawn(Target).GetAimTarget();

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
		TravelTime = TargetDist/projSpeed;
		// hack guess at projecting falling velocity of target
		if ( Target.Physics == PHYS_Falling )
		{
			if ( Target.PhysicsVolume.Gravity.Z <= Target.PhysicsVolume.Default.Gravity.Z )
				TargetVel.Z = FMin(TargetVel.Z + FMax(-400, Target.PhysicsVolume.Gravity.Z * FMin(1,TargetDist/projSpeed)),0);
			else
			{
				TargetVel.Z = TargetVel.Z + 0.5 * TravelTime * Target.PhysicsVolume.Gravity.Z;
				FireSpot = Target.Location + TravelTime*TargetVel;
			 	HitActor = Trace(HitLocation, HitNormal, FireSpot, Target.Location, false);
			 	bLeadTargetNow = false;
			 	if ( HitActor != None )
			 		FireSpot = HitLocation + vect(0,0,2);
			}
		}

		if ( bLeadTargetNow )
		{
			// more or less lead target (with some random variation)
			FireSpot += FMin(1, 0.7 + 0.6 * FRand()) * TargetVel * TravelTime;
			FireSpot.Z = FMin(Target.Location.Z, FireSpot.Z);
		}
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
	if ( Pawn.Weapon != None && Pawn.Weapon.bSniping && Stopped() && (Skill > 5 + 6 * FRand()) )
	{
		// try head
 		FireSpot.Z = Target.Location.Z + 0.9 * Target.CollisionHeight;
 		bClean = FastTrace(FireSpot, ProjStart);
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
			if ( Pawn.Weapon != None && Pawn.Weapon.SplashDamage() && (Skill >= 4) )
			{
			 	HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
				if ( HitActor != None )
					FireSpot += 2 * Enemy.CollisionHeight * HitNormal;
			}
			if ( Pawn.Weapon != None && Pawn.Weapon.RefireRate() < 0.99 )
				bCanFire = false;
		}
	}

	// adjust for toss distance
	if ( FiredAmmunition.bTossed )
		FireDir = AdjustToss(projspeed,ProjStart,FireSpot,true);
	else
	{
		FireDir = FireSpot - ProjStart;
		if ( Pawn(Target) != None )
			FireDir = FireDir + Pawn(Target).GetTargetLocation() - Target.Location;
	}

	FireRotation = Rotator(FireDir);
	realYaw = FireRotation.Yaw;

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
	InstantWarnTarget(Target,FiredAmmunition,vector(FireRotation));
	ShotTarget = Pawn(Target);

	SetRotation(FireRotation);
	return FireRotation;
}

event DelayedWarning()
{
	local vector X,Y,Z, Dir, LineDist, FuturePos, HitLocation, HitNormal;
	local actor HitActor;
	local float dist;

	if ( (Pawn == None) || (WarningProjectile == None) || (WarningProjectile.Velocity == vect(0,0,0)) )
		return;
	if ( Enemy == None )
	{
		Squad.SetEnemy(self, WarningProjectile.Instigator);
		return;
	}

	// check if still on target, else ignore

	Dir = Normal(WarningProjectile.Velocity);
	FuturePos = Pawn.Location + Pawn.Velocity * VSize(WarningProjectile.Location - Pawn.Location)/VSize(WarningProjectile.Velocity);
	LineDist = FuturePos - (WarningProjectile.Location + (Dir Dot (FuturePos - WarningProjectile.Location)) * Dir);
	dist = VSize(LineDist);
	if ( dist > 230 + Pawn.CollisionRadius )
		return;
	if ( dist > 1.2 * Pawn.CollisionHeight )
	{
		if ( WarningProjectile.Damage <= 40 )
			return;

		if ( (WarningProjectile.Physics == PHYS_Projectile) && (dist > Pawn.CollisionHeight + 100) && !WarningProjectile.IsA('ShockProjectile') )
		{
			HitActor = Trace(HitLocation, HitNormal, WarningProjectile.Location + WarningProjectile.Velocity, WarningProjectile.Location, false);
			if ( HitActor == None )
				return;
		}
	}

	GetAxes(Pawn.Rotation,X,Y,Z);
	X.Z = 0;
	Dir = WarningProjectile.Location - Pawn.Location;
	Dir.Z = 0;

	// make sure still looking at projectile
	if ((Normal(Dir) Dot Normal(X)) < 0.7)
		return;

	// decide which way to duck
	if ( (WarningProjectile.Velocity Dot Y) > 0 )
	{
		Y *= -1;
		TryToDuck(Y, true);
	}
	else
		TryToDuck(Y, false);
}

function ReceiveProjectileWarning(Projectile proj)
{
	local float enemyDist, projTime;
	local vector X,Y,Z, enemyDir;

	LastUnderFire = Level.TimeSeconds;

	// bots may duck if not falling or swimming
	if ( (Pawn.health <= 0) || (Skill < 2) || (Enemy == None)
		|| (Pawn.Physics == PHYS_Swimming)
		|| ((Level.NetMode == NM_Standalone) && (PlayerReplicationInfo.HasFlag == None) && (Level.TimeSeconds - Pawn.LastRenderTime > 3)) )
		return;

	// and projectile time is long enough
	enemyDist = VSize(proj.Location - Pawn.Location);

	if ( proj.Speed > 0 )
	{
		projTime = enemyDist/proj.Speed;
		if ( projTime < 0.35 - 0.03*(Skill+ReactionTime) )
			return;
		if ( projTime < 2 - (0.265 + FRand()*0.2) * (skill + ReactionTime) )
			return;

		if ( (WarningProjectile != None) && (VSize(WarningProjectile.Location - Pawn.Location)/WarningProjectile.Speed < projTime) )
			return;

		// check if tight FOV
		if ( (projTime < 1.2) || (WarningProjectile != None) )
		{
			GetAxes(Rotation,X,Y,Z);
			enemyDir = proj.Location - Pawn.Location;
			enemyDir.Z = 0;
			X.Z = 0;
			if ((Normal(enemyDir) Dot Normal(X)) < 0.7)
				return;
		}
		if ( Skill + ReactionTime >= 7 )
			WarningDelay = Level.TimeSeconds + FMax(0.08,FMax(0.35 - 0.025*(Skill + ReactionTime)*(1 + FRand()), projTime - 0.65));
		else
			WarningDelay = Level.TimeSeconds + FMax(0.08,FMax(0.35 - 0.02*(Skill + ReactionTime)*(1 + FRand()), projTime - 0.65));
		WarningProjectile = proj;
	}
}

function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	LastUnderFire = Level.TimeSeconds;
	Super.NotifyTakeHit(InstigatedBy,HitLocation,Damage,DamageType,Momentum);
}

/* Receive warning now only for instant hit shots and vehicle run-over warnings */
function ReceiveWarning(Pawn shooter, float projSpeed, vector FireDir)
{
	local float enemyDist, projTime;
	local vector X,Y,Z, enemyDir;
	local bool bResult;

	LastUnderFire = Level.TimeSeconds;

	// AI controlled creatures may duck if not falling
	if ( Pawn.bStationary || !Pawn.bCanStrafe || (Pawn.health <= 0) )
		return;
	if ( Enemy == None )
	{
		Squad.SetEnemy(self, shooter);
		return;
	}
	if ( (Skill < 4) || (Pawn.Physics == PHYS_Falling) || (Pawn.Physics == PHYS_Swimming)
		|| (FRand() > 0.2 * skill - 0.33) )
		return;

	enemyDist = VSize(shooter.Location - Pawn.Location);

	if ( (enemyDist > 2000) && Vehicle(shooter) == None && !Stopped() )
		return;

	// only if tight FOV
	GetAxes(Pawn.Rotation,X,Y,Z);
	enemyDir = shooter.Location - Pawn.Location;
	enemyDir.Z = 0;
	X.Z = 0;
	if ((Normal(enemyDir) Dot Normal(X)) < 0.7)
		return;

	if ( projSpeed > 0 && Vehicle(shooter) == None )
	{
		projTime = enemyDist/projSpeed;
		if ( projTime < 0.11 + 0.15 * FRand())
		{
			if ( Stopped() && (Pawn.MaxRotation == 0) )
				GotoState('TacticalMove');
			return;
		}
	}

	if ( FRand() * (Skill + 4) < 4 )
	{
		if ( Stopped() && (Pawn.MaxRotation == 0) )
			GotoState('TacticalMove');
		return;
	}

	if ( (FireDir Dot Y) > 0 )
	{
		Y *= -1;
		bResult = TryToDuck(Y, true);
	}
	else
		bResult = TryToDuck(Y, false);

	if (bResult && projspeed > 0 && Vehicle(shooter) != None)
	{
		bNotifyApex = true;
		bPendingDoubleJump = true;
	}

	// FIXME - if duck fails, try back jump if splashdamage landing
}

event NotifyFallingHitWall( vector HitNormal, actor HitActor)
{
	bNotifyFallingHitWall = false;
	TryWallDodge(HitNormal, HitActor);
}

event MissedDodge()
{
	local Actor HitActor;
	local vector HitNormal, HitLocation, Extent, Vel2D;

	if ( Pawn.CanDoubleJump() && (Abs(Pawn.Velocity.Z) < 100) )
	{
		Pawn.DoDoubleJump(false);
		bPendingDoubleJump = false;
	}

	Extent = Pawn.CollisionRadius * vect(1,1,0);
	Extent.Z = Pawn.CollisionHeight;
	HitActor = trace(HitLocation, HitNormal, Pawn.Location - (20 + 3*MAXSTEPHEIGHT) * vect(0,0,1), Pawn.Location, false, Extent);
	Vel2D = Pawn.Velocity;
	Vel2D.Z = 0;
	if ( HitActor != None )
	{
		Pawn.Acceleration = -1 * Pawn.AccelRate * Normal(Vel2D);
		Pawn.Velocity.X = 0;
		Pawn.Velocity.Z = 0;
		return;
	}
	Pawn.Acceleration = Pawn.AccelRate * Normal(Vel2D);
}


function bool TryWallDodge(vector HitNormal, actor HitActor)
{
	local vector X,Y,Z, Dir, TargetDir, NewHitNormal, HitLocation, Extent;
	local float DP;
	local Actor NewHitActor;

	if ( !Pawn.bCanWallDodge || (Abs(HitNormal.Z) > 0.7) || !HitActor.bWorldGeometry )
		return false;

	if ( (Pawn.Velocity.Z < -150) && (FRand() < 0.4) )
		return false;

	// check that it was a legit, visible wall
	Extent = Pawn.CollisionRadius * vect(1,1,0);
	Extent.Z = 0.5 * Pawn.CollisionHeight;
	NewHitActor = Trace(HitLocation, NewHitNormal, Pawn.Location - 32*HitNormal, Pawn.Location, false, Extent);
	if ( NewHitActor == None )
		return false;

	GetAxes(Pawn.Rotation,X,Y,Z);

	Dir = HitNormal;
	Dir.Z = 0;
	Dir = Normal(Dir);

	if ( InLatentExecution(LATENT_MOVETOWARD) )
	{
		TargetDir = MoveTarget.Location - Pawn.Location;
		TargetDir.Z = 0;
		TargetDir = Normal(TargetDir);
		DP = HitNormal Dot TargetDir;
		if ( (DP >= 0)
			&& (VSize(MoveTarget.Location - Pawn.Location) > 200) )
		{
			if ( DP < 0.7 )
				Dir = Normal( TargetDir + HitNormal * (1 - DP) );
			else
				Dir = TargetDir;
		}
	}
	if ( Abs(X Dot Dir) > Abs(Y Dot Dir) )
	{
		if ( (X Dot Dir) > 0 )
			UnrealPawn(Pawn).CurrentDir = DCLICK_Forward;
		else
			UnrealPawn(Pawn).CurrentDir = DCLICK_Back;
	}
	else if ( (Y Dot Dir) < 0 )
		UnrealPawn(Pawn).CurrentDir = DCLICK_Left;
	else
		UnrealPawn(Pawn).CurrentDir = DCLICK_Right;

 	bPlannedJump = true;
	Pawn.PerformDodge(UnrealPawn(Pawn).CurrentDir, Dir,Normal(Dir Cross vect(0,0,1)));
	return true;
}

function ChangeStrafe();

function bool TryToDuck(vector duckDir, bool bReversed)
{
	local vector HitLocation, HitNormal, Extent, Start;
	local actor HitActor;
	local bool bSuccess, bDuckLeft, bWallHit, bChangeStrafe;
	local float MinDist,Dist;

	if ( Vehicle(Pawn) != None )
		return Pawn.Dodge(DCLICK_None);
	if ( Pawn.bStationary )
		return false;
	if ( Stopped() && (Pawn.MaxRotation == 0) )
		GotoState('TacticalMove');
	else if ( FRand() < 0.6 )
		bChangeStrafe = IsStrafing();


	if ( (Skill < 3) || Pawn.PhysicsVolume.bWaterVolume || (Pawn.Physics == PHYS_Falling)
		|| (Pawn.PhysicsVolume.Gravity.Z > Pawn.PhysicsVolume.Default.Gravity.Z) )
		return false;
    if ( Pawn.bIsCrouched || Pawn.bWantsToCrouch || (Pawn.Physics != PHYS_Walking) )
        return false;

	duckDir.Z = 0;
	duckDir *= 335;
	bDuckLeft = bReversed;
	Extent = Pawn.GetCollisionExtent();
	Start = Pawn.Location + vect(0,0,25);
	HitActor = Trace(HitLocation, HitNormal, Start + duckDir, Start, false, Extent);

	MinDist = 150;
	Dist = VSize(HitLocation - Pawn.Location);
	if ( (HitActor == None) || ( Dist > 150) )
	{
		if ( HitActor == None )
			HitLocation = Start + duckDir;

		HitActor = Trace(HitLocation, HitNormal, HitLocation - MAXSTEPHEIGHT * vect(0,0,2.5), HitLocation, false, Extent);
		bSuccess = ( (HitActor != None) && (HitNormal.Z >= 0.7) );
	}
	else
	{
		bWallHit = Pawn.bCanWallDodge && (Skill + 2*Jumpiness > 5);
		MinDist = 30 + MinDist - Dist;
	}

	if ( !bSuccess )
	{
		bDuckLeft = !bDuckLeft;
		duckDir *= -1;
		HitActor = Trace(HitLocation, HitNormal, Start + duckDir, Start, false, Extent);
		bSuccess = ( (HitActor == None) || (VSize(HitLocation - Pawn.Location) > MinDist) );
		if ( bSuccess )
		{
			if ( HitActor == None )
				HitLocation = Start + duckDir;

			HitActor = Trace(HitLocation, HitNormal, HitLocation - MAXSTEPHEIGHT * vect(0,0,2.5), HitLocation, false, Extent);
			bSuccess = ( (HitActor != None) && (HitNormal.Z >= 0.7) );
		}
	}
	if ( !bSuccess )
	{
		if ( bChangeStrafe )
			ChangeStrafe();
		return false;
	}

	if ( Pawn.bCanWallDodge && (Skill + 2*Jumpiness > 3 + 3*FRand()) )
		bNotifyFallingHitWall = true;

	if ( bNotifyFallingHitWall && bWallHit )
		bDuckLeft = !bDuckLeft; // plan to wall dodge
	if ( bDuckLeft )
		UnrealPawn(Pawn).CurrentDir = DCLICK_Left;
	else
		UnrealPawn(Pawn).CurrentDir = DCLICK_Right;

	bInDodgeMove = true;
	DodgeLandZ = Pawn.Location.Z;
	Pawn.Dodge(UnrealPawn(Pawn).CurrentDir);
	return true;
}

function NotifyKilled(Controller Killer, Controller Killed, pawn KilledPawn)
{
	Squad.NotifyKilled(Killer,Killed,KilledPawn);
}

function Actor FaceMoveTarget()
{
	if ( (MoveTarget != Enemy) && (MoveTarget != Target) )
		StopFiring();
	return MoveTarget;
}

function bool ShouldStrafeTo(Actor WayPoint)
{
	local NavigationPoint N;

	if ( (Vehicle(Pawn) != None) && !Vehicle(Pawn).bFollowLookDir )
		return true;

	if ( Skill + StrafingAbility < 3 )
		return false;

	if ( WayPoint == Enemy )
	{
		if ( Pawn.Weapon != None && Pawn.Weapon.bMeleeWeapon )
			return false;
		return ( Skill + StrafingAbility > 5 * FRand() - 1 );
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
	if ( (Pawn(WayPoint) != None) || ((Squad.SquadLeader != None) && (WayPoint == Squad.SquadLeader.MoveTarget)) )
		return ( Skill + StrafingAbility > 5 * FRand() - 1 );

	if ( Skill + StrafingAbility < 6 * FRand() - 1 )
		return false;

	if ( !bFinalStretch && (Enemy == None) )
		return ( FRand() < 0.4 );

	if ( (Level.TimeSeconds - LastUnderFire < 2) )
		return true;
	if ( (Enemy != None) && EnemyVisible() )
		return ( FRand() < 0.85 );
	return ( FRand() < 0.6 );
}

function Actor AlternateTranslocDest()
{
	if ( (PathNode(MoveTarget) == None) || (MoveTarget != RouteCache[0]) || (RouteCache[0] == None) )
		return None;
	if ( (PathNode(RouteCache[1]) == None) && (InventorySpot(RouteCache[1]) == None) && GameObjective(RouteCache[1]) == None )
	{
		if ( (FRand() < 0.5) && (GameObject(RouteGoal) != None)
			&& (VSize(RouteGoal.Location - Pawn.Location) < 2000)
			&& LineOfSightTo(RouteGoal) )
			return RouteGoal;
		return None;
	}
	if ( (FRand() < 0.3)
		&& (GameObjective(RouteCache[1]) == None)
		&& ((PathNode(RouteCache[2]) != None) || (InventorySpot(RouteCache[2]) != None) || (GameObjective(RouteCache[2]) != None))
		&& LineOfSightTo(RouteCache[2]) )
		return RouteCache[2];
	if ( LineOfSightTo(RouteCache[1]) )
		return RouteCache[1];
	return None;
}

function Actor FaceActor(float StrafingModifier)
{
	local float RelativeDir, Dist, MinDist;
	local actor SquadFace, N;
	local bool bEnemyNotEngaged, bTranslocTactics, bCatchup;

	if ( (DestroyableObjective(Focus) != None) && (Focus == Squad.SquadObjective) && (Squad.GetOrders() == 'ATTACK') && Pawn.IsFiring() )
		return Focus;
	bTranslocatorHop = false;
	SquadFace = Squad.SetFacingActor(self);
	if ( SquadFace != None )
		return SquadFace;
	if ( (Pawn.Weapon != None) && Pawn.Weapon.FocusOnLeader(false) )
	{
		if ( Vehicle(Focus) != None )
			FireWeaponAt(Focus);
		return Focus;
	}
	// translocator hopping
	if ( CanUseTranslocator() )
	{
		bEnemyNotEngaged = (Enemy == None)||(Level.TimeSeconds - LastSeenTime > 1);
		bCatchup = ((Pawn(RouteGoal) != None) && !SameTeamAs(Pawn(RouteGoal).Controller)) || (GameObject(RouteGoal) != None);
		if ( bEnemyNotEngaged )
		{
			if ( bCatchup )
				bTranslocTactics = (Skill + Tactics > 2 + 2*FRand());
			else
				bTranslocTactics = (Skill + Tactics > 4);
		}
		bTranslocTactics = bTranslocTactics || (Skill + Tactics > 2.5 + 3 * FRand());
		if (  bTranslocTactics && (TranslocUse > FRand()) && (Vehicle(Pawn) == None)
			&& (TranslocFreq < Level.TimeSeconds + 6 + 9 * FRand())
			&& ((NavigationPoint(Movetarget) != None) || (GameObject(MoveTarget) != None))
			&& (LiftCenter(MoveTarget) == None)
			&& (bEnemyNotEngaged || bRecommendFastMove || (GameObject(MoveTarget) != None) || (VSize(Enemy.Location - Pawn.Location) > ENEMYLOCATIONFUZZ * (1 + FRand()))
				|| (bCatchup && (FRand() < 0.65) && (!LineOfSightTo(RouteGoal) || (GameObject(RouteGoal) != None)))) )
		{
			bRecommendFastMove = false;
			bTranslocatorHop = true;
			TranslocationTarget = MoveTarget;
			RealTranslocationTarget = TranslocationTarget;
			Focus = MoveTarget;
			Dist = VSize(Pawn.Location - MoveTarget.Location);
			MinDist = 300 + 40 * FMax(0,TranslocFreq - Level.TimeSeconds);
			if ( (GameObject(RouteGoal) != None) && (VSize(Pawn.Location - RouteGoal.Location) < 1000 + 1200 * FRand()) && LineOfSightTo(RouteGoal) )
			{
				TranslocationTarget = RouteGoal;
				RealTranslocationTarget = TranslocationTarget;
				Dist = VSize(Pawn.Location - TranslocationTarget.Location);
				Focus = RouteGoal;
			}
			else if ( MinDist + 200 + 1000 * FRand() > Dist )
			{
				N = AlternateTranslocDest();
				if ( N != None )
				{
					TranslocationTarget = N;
					RealTranslocationTarget = TranslocationTarget;
					Dist = VSize(Pawn.Location - TranslocationTarget.Location);
					Focus = N;
				}
			}
			if ( (Dist < MinDist) || ((Dist < MinDist + 150) && !Pawn.Weapon.IsA('TransLauncher')) )
			{
				TranslocationTarget = None;
				RealTranslocationTarget = TranslocationTarget;
				bTranslocatorHop = false;
			}
			else
			{
				SwitchToBestWeapon();
				return Focus;
			}
		}
	}
	bRecommendFastMove = false;
	if ( (!Pawn.bCanStrafe && (Vehicle(Pawn) == None || !Vehicle(Pawn).bSeparateTurretFocus))
	     || (Enemy == None) || (Level.TimeSeconds - LastSeenTime > 6 - StrafingModifier) )
		return FaceMoveTarget();

	if ( (MoveTarget == Enemy) || (Vehicle(Pawn) != None) || ((skill + StrafingAbility >= 6) && !Pawn.Weapon.bMeleeWeapon)
		|| (VSize(MoveTarget.Location - Pawn.Location) < 4 * Pawn.CollisionRadius) )
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

	if ( (Pawn.Weapon != None && Pawn.Weapon.bMeleeWeapon && (RelativeDir < 0.3))
		|| (Skill + StrafingAbility < (5 + StrafingModifier) * FRand())
		|| (0.4*RelativeDir + 0.8 < FRand()) )
		return FaceMoveTarget();

	return Enemy;
}

function WanderOrCamp(bool bMayCrouch)
{
	Pawn.bWantsToCrouch = bMayCrouch && (Pawn.bIsCrouched || (FRand() < 0.75));
	GotoState('RestFormation');
}

function bool NeedWeapon()
{
	local inventory Inv;

	if ( Vehicle(Pawn) != None )
		return false;
	if ( Pawn.Weapon.AIRating > 0.5 )
		return ( !Pawn.Weapon.HasAmmo() );

	// see if have some other good weapon, currently not in use
	for ( Inv=Pawn.Inventory; Inv!=None; Inv=Inv.Inventory )
		if ( (Weapon(Inv) != None) && (Weapon(Inv).AIRating > 0.5) && Weapon(Inv).HasAmmo() )
			return false;

	return true;
}

event float Desireability(Pickup P)
{
	if ( !Pawn.IsInLoadout(P.InventoryType) )
		return -1;
	return P.BotDesireability(Pawn);
}

event float SuperDesireability(Pickup P)
{
	if ( !SuperPickupNotSpokenFor(P) )
		return 0;
	return P.BotDesireability(Pawn);
}

function bool SuperPickupNotSpokenFor(Pickup P)
{
	local Bot CurrentOwner;

	if ( PlayerReplicationInfo.Team == None )
		return true;

	CurrentOwner = Bot(P.TeamOwner[PlayerReplicationInfo.Team.TeamIndex]);

	if ( (CurrentOwner == None ) || (CurrentOwner == self)
		|| (CurrentOwner.Pawn == None)
		|| ((CurrentOwner.RouteGoal != P.myMarker) && (CurrentOwner.RouteGoal != P) && (CurrentOwner.MoveTarget != P)
			&& (CurrentOwner.RouteGoal != P.myMarker)) )
	{
		P.TeamOwner[PlayerReplicationInfo.Team.TeamIndex] = None;
		return true;
	}

	// decide if better than current owner
	if ( (Squad.GetOrders() == 'Defend')
		|| (CurrentOwner.MoveTarget == P)
		|| (CurrentOwner.MoveTarget == P.myMarker) )
		return false;
	if ( PlayerReplicationInfo.HasFlag != None )
		return true;
	if ( CurrentOwner.RouteCache[1] == P.myMarker )
		return false;
	if ( CurrentOwner.Squad.GetOrders() == 'Defend' )
		return true;
	return false;
}

function DamageAttitudeTo(Pawn Other, float Damage)
{
	if ( (Pawn.health > 0) && (Damage > 0) && Squad.SetEnemy(self,Other) )
		WhatToDoNext(5);
}

function bool IsRetreating()
{
	return false;
}

//**********************************************************************************
// AI States

//=======================================================================================================
// No goal/no enemy states

state NoGoal
{
	function EnemyChanged(bool bNewEnemyVisible)
	{
		if ( EnemyAcquisitionScript != None )
		{
			bEnemyAcquired = false;
			SetEnemyInfo(bNewEnemyVisible);
			EnemyAcquisitionScript.TakeOver(Pawn);
		}
		else
			Global.EnemyChanged(bNewEnemyVisible);
	}
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
		if (Pawn.Weapon != None && Pawn.Weapon.ShouldFireWithoutTarget())
			Pawn.Weapon.BotFire(false);
		SetCombatTimer();
		enable('NotifyBump');
	}

	function BeginState()
	{
		Enemy = None;
		//SetAlertness(0.2);
		Pawn.bCanJump = false;
		Pawn.bAvoidLedges = true;
		Pawn.bStopAtLedges = true;
		Pawn.SetWalking(true);
		MinHitWall += 0.15;
		SwitchToBestWeapon();
	}

	function EndState()
	{
		MonitoredPawn = None;
		Squad.GetRestingFormation().LeaveFormation(self);
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

	function PickDestination()
	{
		FormationPosition = Squad.GetRestingFormation().RecommendPositionFor(self);
		Destination = Squad.GetRestingFormation().GetLocationFor(FormationPosition,self);
	}

Begin:
	WaitForLanding();
	if ( Pawn.bStationary )
		Goto('Pausing');

	if ( (Vehicle(Pawn) != None) && (!Vehicle(Pawn).bTurnInPlace || (Pawn.FindAnchorFailedTime != Level.TimeSeconds)) )
	{
		if ( (Squad.SquadLeader == self) || (Squad.SquadLeader.Pawn == None)
			|| (Pawn.GetVehicleBase() == Squad.SquadLeader.Pawn) )
			Goto('Camping');
		else
			Goto('Pausing');
	}
	PickDestination();

Moving:
	if ( Pawn.bStationary )
		Goto('Pausing');
	if ( (Vehicle(Pawn) != None) && (!Vehicle(Pawn).bTurnInPlace || (Pawn.FindAnchorFailedTime != Level.TimeSeconds)) )
	{
		if ( (Squad.SquadLeader == self) || (Squad.SquadLeader.Pawn == None)
			|| (Pawn.GetVehicleBase() == Squad.SquadLeader.Pawn) )
			Goto('Camping');
		else
			Goto('Pausing');
	}
	if ( Vehicle(Pawn) != None && Pawn.GetVehicleBase() != None)
		StartMonitoring(Pawn.GetVehicleBase(),Squad.GetRestingFormation().FormationSize);
	else if ( (Squad.SquadLeader != self) && (Squad.SquadLeader.Pawn != None) && (Squad.FormationCenter() == Squad.SquadLeader.Pawn) )
		StartMonitoring(Squad.SquadLeader.Pawn,Squad.GetRestingFormation().FormationSize);
	else
		MonitoredPawn = None;
	MoveTo(Destination,,true);
	WaitForLanding();
Pausing:
	if ( !Squad.NearFormationCenter(Pawn) )
	{
		Focus = None;
		FocalPoint = Squad.GetRestingFormation().GetViewPointFor(self,FormationPosition);
		Pawn.Acceleration = vect(0,0,0);
		if ( Pawn.bStationary )
			Sleep(2.0);
		Sleep(0.5);
		WhatToDoNext(7);
	}
Camping:
	Pawn.Acceleration = vect(0,0,0);
	Focus = None;
	FocalPoint = Squad.GetRestingFormation().GetViewPointFor(self,FormationPosition);
	NearWall(MINVIEWDIST);
	FinishRotation();
	if ( Vehicle(Pawn) != None && Pawn.GetVehicleBase() != None)
		StartMonitoring(Pawn.GetVehicleBase(),Squad.GetRestingFormation().FormationSize);
	else if ( (Squad.SquadLeader.Pawn != None) && (Squad.FormationCenter() == Squad.SquadLeader.Pawn) )
		StartMonitoring(Squad.SquadLeader.Pawn,Squad.GetRestingFormation().FormationSize);
	else
		MonitoredPawn = None;
	Sleep(3 + FRand());
	WaitForLanding();
	if ( !Squad.WaitAtThisPosition(Pawn) )
	{
		if ( Squad.WanderNearLeader(self) )
			SetAttractionState();
		else
			WhatToDoNext(8);
	}
	if ( FRand() < 0.6 )
		Goto('Camping');
	Goto('Begin');

ShortWait:
	Pawn.Acceleration = vect(0,0,0);
	if ( (Vehicle(Pawn) == None) || Vehicle(Pawn).bTurnInPlace )
	{
		Focus = None;
		FocalPoint = Squad.GetRestingFormation().GetViewPointFor(self,FormationPosition);
		NearWall(MINVIEWDIST);
		FinishRotation();
	}
TauntWait:
	Sleep(CampTime);
	WaitForLanding();
	WhatToDoNext(9);
}

event RecoverFromBadStateCode()
{
	bBadStateCode = false;
	CampTime = 0.5;
	GotoState('RestFormation', 'TauntWait');
}

function Celebrate()
{
	Pawn.PlayVictoryAnimation();
}

function ForceGiveWeapon()
{
    local Vector TossVel, LeaderVel;

    if ( (Pawn == None) || (Pawn.Weapon == None) || (Squad.SquadLeader.Pawn == None) || !LineOfSightTo(Squad.SquadLeader.Pawn) )
        return;

    if ( Pawn.CanThrowWeapon() )
    {
        TossVel = Vector(Pawn.Rotation);
        TossVel.Z = 0;
        TossVel = Normal(TossVel);
        LeaderVel = Normal(Squad.SquadLeader.Pawn.Location - Pawn.Location);
        if ( (TossVel Dot LeaderVel) > 0.7 )
			TossVel = LeaderVel;
        TossVel = TossVel * ((Pawn.Velocity Dot TossVel) + 500) + Vect(0,0,200);
        Pawn.TossWeapon(TossVel);
        SwitchToBestWeapon();
    }
}

function ForceCelebrate()
{
	local bool bRealCrouch;

	Pawn.bWantsToCrouch = false;
	bRealCrouch = Pawn.bCanCrouch;
	Pawn.bCanCrouch = false;
	if ( Enemy == None )
	{
		CampTime = 3;
		GotoState('RestFormation','TauntWait');
		if ( Squad.SquadLeader.Pawn != None )
			FocalPoint = Squad.SquadLeader.Pawn.Location;
	}
	StopFiring();
	Celebrate();
	Pawn.bCanCrouch = bRealCrouch;
}


//=======================================================================================================
// Move To Goal states

state Startled
{
	ignores EnemyNotVisible,SeePlayer,HearNoise;

	function Startle(Actor Feared)
	{
		GoalString = "STARTLED!";
		StartleActor = Feared;
		BeginState();
	}

	function BeginState()
	{
		// FIXME - need FindPathAwayFrom()
		Pawn.Acceleration = Pawn.Location - StartleActor.Location;
		Pawn.Acceleration.Z = 0;
		Pawn.bIsWalking = false;
		Pawn.bWantsToCrouch = false;
		if ( Pawn.Acceleration == vect(0,0,0) )
			Pawn.Acceleration = VRand();
		Pawn.Acceleration = Pawn.AccelRate * Normal(Pawn.Acceleration);
	}
Begin:
	Sleep(0.5);
	WhatToDoNext(11);
	Goto('Begin');
}

state MoveToGoal
{
	function bool CheckPathToGoalAround(Pawn P)
	{
		if ( (MoveTarget == None) || (Bot(P.Controller) == None) || !SameTeamAs(P.Controller) )
			return false;

		if ( Bot(P.Controller).Squad.ClearPathFor(self) )
			return true;
		return false;
	}

	function Timer()
	{
		SetCombatTimer();
		enable('NotifyBump');
	}

	function BeginState()
	{
		Pawn.bWantsToCrouch = Squad.CautiousAdvance(self);
	}
}

state MoveToGoalNoEnemy extends MoveToGoal
{
	function EnemyChanged(bool bNewEnemyVisible)
	{
		if ( EnemyAcquisitionScript != None )
		{
			bEnemyAcquired = false;
			SetEnemyInfo(bNewEnemyVisible);
			EnemyAcquisitionScript.TakeOver(Pawn);
		}
		else
			Global.EnemyChanged(bNewEnemyVisible);
	}
}

state MoveToGoalWithEnemy extends MoveToGoal
{
	function Timer()
	{
		TimedFireWeaponAtEnemy();
	}
}

function float GetDesiredOffset()
{
	if ( (Squad.SquadLeader == None) || (MoveTarget != Squad.SquadLeader.Pawn) )
		return 0;

	return Squad.GetRestingFormation().FormationSize*0.5;
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
	if ( Pawn.bCanPickupInventory && (InventorySpot(MoveTarget) != None) && (Squad.PriorityObjective(self) == 0) && (Vehicle(Pawn) == None) )
	{
		MoveTarget = InventorySpot(MoveTarget).GetMoveTargetFor(self,5);
		if ( (Pickup(MoveTarget) != None) && !Pickup(MoveTarget).ReadyToPickup(0) )
		{
			CampTime = MoveTarget.LatentFloat;
			GoalString = "Short wait for inventory "$MoveTarget;
			GotoState('RestFormation','ShortWait');
		}
	}
	MoveToward(MoveTarget,FaceActor(1),GetDesiredOffset(),ShouldStrafeTo(MoveTarget));
DoneRoaming:
	WaitForLanding();
	WhatToDoNext(12);
	if ( bSoaking )
		SoakStop("STUCK IN ROAMING!");
}

state Fallback extends MoveToGoalWithEnemy
{
	function bool FireWeaponAt(Actor A)
	{
		if ( (A == Enemy) && (Pawn.Weapon != None) && (Pawn.Weapon.AIRating < 0.5)
			&& (Level.TimeSeconds - Pawn.SpawnTime < DeathMatch(Level.Game).SpawnProtectionTime)
			&& (Squad.PriorityObjective(self) == 0)
			&& (InventorySpot(Routegoal) != None) )
		{
			// don't fire if still spawn protected, and no good weapon
			return false;
		}
		return Global.FireWeaponAt(A);
	}

	function bool IsRetreating()
	{
		return ( (Pawn.Acceleration Dot (Pawn.Location - Enemy.Location)) > 0 );
	}

	event bool NotifyBump(actor Other)
	{
		local Pawn P;
		local Vehicle V;

		if ( (Vehicle(Other) != None) && (Vehicle(Pawn) == None) )
		{
			if ( Other == RouteGoal || (Vehicle(RouteGoal) != None && Other == Vehicle(RouteGoal).GetVehicleBase()) )
			{
				V = Vehicle(RouteGoal).FindEntryVehicle(Pawn);
				if ( V != None )
				{
					V.UsedBy(Pawn);
					if (Vehicle(Pawn) != None)
					{
						Squad.BotEnteredVehicle(self);
						WhatToDoNext(54);
					}
				}
				return true;
			}
		}

		Disable('NotifyBump');
		if ( MoveTarget == Other )
		{
			if ( MoveTarget == Enemy && Pawn.HasWeapon() )
			{
				TimedFireWeaponAtEnemy();
				DoRangedAttackOn(Enemy);
			}
			return false;
		}

		P = Pawn(Other);
		if ( (P == None) || (P.Controller == None) )
			return false;
		if ( !SameTeamAs(P.Controller) && (MoveTarget == RouteCache[0]) && (RouteCache[1] != None) && P.ReachedDestination(MoveTarget) )
		{
			MoveTimer = VSize(RouteCache[1].Location - Pawn.Location)/(Pawn.GroundSpeed * Pawn.DesiredSpeed) + 1;
			MoveTarget = RouteCache[1];
		}
		Squad.SetEnemy(self,P);
		if ( Enemy == Other )
		{
			Focus = Enemy;
			TimedFireWeaponAtEnemy();
		}
		if ( CheckPathToGoalAround(P) )
			return false;

		AdjustAround(P);
		return false;
	}

	function MayFall()
	{
		Pawn.bCanJump = ( (MoveTarget != None)
					&& ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('Pickup')) );
	}

	function EnemyNotVisible()
	{
		if ( Squad.FindNewEnemyFor(self,false) || (Enemy == None) )
			WhatToDoNext(13);
		else
		{
			enable('SeePlayer');
			disable('EnemyNotVisible');
		}
	}

	function EnemyChanged(bool bNewEnemyVisible)
	{
		bEnemyAcquired = false;
		SetEnemyInfo(bNewEnemyVisible);
		if ( bNewEnemyVisible )
		{
			disable('SeePlayer');
			enable('EnemyNotVisible');
		}
	}

Begin:
	WaitForLanding();

Moving:
	if ( Pawn.bCanPickupInventory && (InventorySpot(MoveTarget) != None) && (Vehicle(Pawn) == None) )
		MoveTarget = InventorySpot(MoveTarget).GetMoveTargetFor(self,0);
	MoveToward(MoveTarget,FaceActor(1),GetDesiredOffset(),ShouldStrafeTo(MoveTarget));
	WhatToDoNext(14);
	if ( bSoaking )
		SoakStop("STUCK IN FALLBACK!");
	goalstring = goalstring$" STUCK IN FALLBACK!";
}

//=======================================================================================================================
// Tactical Combat states

/* LostContact()
return true if lost contact with enemy
*/
function bool LostContact(float MaxTime)
{
	if ( Enemy == None )
		return true;

	if ( Enemy.Visibility < 2 )
		MaxTime = FMax(2,MaxTime - 2);
	if ( Level.TimeSeconds - FMax(LastSeenTime,AcquireTime) > MaxTime )
		return true;

	return false;
}

/* LoseEnemy()
get rid of old enemy, if squad lets me
*/
function bool LoseEnemy()
{
	if ( Enemy == None )
		return true;
	if ( (Enemy.Health > 0) && (Enemy.Controller != None) && (LoseEnemyCheckTime > Level.TimeSeconds - 0.2) )
		return false;
	LoseEnemyCheckTime = Level.TimeSeconds;
	if ( Squad.LostEnemy(self) )
	{
		bFrustrated = false;
		return true;
	}
	// still have same enemy
	return false;
}

function DoStakeOut()
{
	GotoState('StakeOut');
}

function DoCharge()
{
	if ( Vehicle(Pawn) != None )
	{
		GotoState('VehicleCharging');
		return;
	}
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
	if ( !Pawn.bCanStrafe || (Pawn.MaxRotation != 0) )
	{
		if (Pawn.HasWeapon())
			DoRangedAttackOn(Enemy);
		else
			WanderOrCamp(true);
	}
	else
		GotoState('TacticalMove');
}

function DoRetreat()
{
	if ( Squad.PickRetreatDestination(self) )
	{
		GotoState('Retreating');
		return;
	}

	// if nothing, then tactical move
	if ( EnemyVisible() )
	{
		GoalString= "No retreat because frustrated";
		bFrustrated = true;
		if ( Pawn.Weapon != None && Pawn.Weapon.bMeleeWeapon )
			GotoState('Charging');
		else if ( Vehicle(Pawn) != None )
			GotoState('VehicleCharging');
		else
			DoTacticalMove();
		return;
	}
	GoalString = "Stakeout because no retreat dest";
	DoStakeOut();
}

/* DefendMelee()
return true if defending against melee attack
*/
function bool DefendMelee(float Dist)
{
	return ( (Enemy.Weapon != None) && Enemy.Weapon.bMeleeWeapon && (Dist < 1000) );
}

state Retreating extends Fallback
{
	function bool IsRetreating()
	{
		return true;
	}

	function Actor FaceActor(float StrafingModifier)
	{
		return Global.FaceActor(2);
	}

	function BeginState()
	{
		Pawn.bWantsToCrouch = Squad.CautiousAdvance(self);
	}
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
		if ( !Pawn.bCanStrafe )
			return false;
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
		LastUnderFire = Level.TimeSeconds;

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
		if ( (Other == Enemy)
			&& (Pawn.Weapon != None) && !Pawn.Weapon.bMeleeWeapon && (FRand() > 0.4 + 0.1 * skill) )
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
	if ( !FindBestPathToward(Enemy, false,true) )
		DoTacticalMove();
Moving:
	if ( Pawn.Weapon.bMeleeWeapon ) // FIXME HACK
		FireWeaponAt(Enemy);
	MoveToward(MoveTarget,FaceActor(1),,ShouldStrafeTo(MoveTarget));
	WhatToDoNext(17);
	if ( bSoaking )
		SoakStop("STUCK IN CHARGING!");
}

state VehicleCharging extends MoveToGoalWithEnemy
{
	ignores SeePlayer, HearNoise;

	function Timer()
	{
		Target = Enemy;
		TimedFireWeaponAtEnemy();
	}

	function FindDestination()
	{
		local actor HitActor;
		local vector HitLocation, HitNormal, Cross;

		if ( MoveTarget == None )
		{
			Destination = Pawn.Location;
			return;
		}
		Destination = Pawn.Location + 5000 * Normal(Pawn.Location - MoveTarget.Location);
		HitActor = Trace(HitLocation, HitNormal, Destination, Pawn.Location, false);

		if ( HitActor == None )
			return;

		Cross = Normal((Destination - Pawn.Location) cross vect(0,0,1));
		Destination = Destination + 1000 * Cross;
		HitActor = Trace(HitLocation, HitNormal, Destination, Pawn.Location, false);
		if ( HitActor == None )
			return;

		Destination = Destination - 2000 * Cross;
		HitActor = Trace(HitLocation, HitNormal, Destination, Pawn.Location, false);
		if ( HitActor == None )
			return;

		Destination = Destination + 1000 * Cross - 3000 * Normal(Pawn.Location - MoveTarget.Location);
	}

	function EnemyNotVisible()
	{
		WhatToDoNext(15);
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
	if ( Pawn.Physics == PHYS_Flying )
	{
		if ( VSize(Enemy.Location - Pawn.Location) < 1200 )
		{
			FindDestination();
			MoveTo(Destination, None, false);
			if ( Enemy == None )
				WhatToDoNext(91);
		}
		MoveTarget = Enemy;
	}
	else if ( !FindBestPathToward(Enemy, false,true) )
	{
		if (Pawn.HasWeapon())
			GotoState('RangedAttack');
		else
			WanderOrCamp(true);
	}
Moving:
	FireWeaponAt(Enemy);
	MoveToward(MoveTarget,FaceActor(1),,ShouldStrafeTo(MoveTarget));
	WhatToDoNext(17);
	if ( bSoaking )
		SoakStop("STUCK IN VEHICLECHARGING!");
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

	function SetFall()
	{
		Pawn.Acceleration = vect(0,0,0);
		Destination = Pawn.Location;
		Global.SetFall();
	}

	function bool NotifyHitWall(vector HitNormal, actor Wall)
	{
		local Vehicle V;

		if ( Vehicle(Wall) != None && Vehicle(Pawn) == None )
		{
			if ( Wall == RouteGoal || (Vehicle(RouteGoal) != None && Wall == Vehicle(RouteGoal).GetVehicleBase()) )
			{
				V = Vehicle(Wall).FindEntryVehicle(Pawn);
				if ( V != None )
				{
					V.UsedBy(Pawn);
					if (Vehicle(Pawn) != None)
					{
						Squad.BotEnteredVehicle(self);
						WhatToDoNext(55);
					}
				}
				return true;
			}
			return false;
		}
		if (Pawn.Physics == PHYS_Falling)
		{
			NotifyFallingHitWall(HitNormal, Wall);
			return false;
		}
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
		if ( (Enemy != None) && !bNotifyApex )
			TimedFireWeaponAtEnemy();
		else
			SetCombatTimer();
	}

	function EnemyNotVisible()
	{
		StopFiring();
		if ( aggressiveness > relativestrength(enemy) )
		{
			if ( FastTrace(Enemy.Location, LastSeeingPos) )
				GotoState('TacticalMove','RecoverEnemy');
			else
				WhatToDoNext(20);
		}
		Disable('EnemyNotVisible');
	}

	function PawnIsInPain(PhysicsVolume PainVolume)
	{
		Destination = Pawn.Location - MINSTRAFEDIST * Normal(Pawn.Velocity);
	}

	function ChangeStrafe()
	{
		local vector Dir;

		Dir = Vector(Pawn.Rotation);
		Destination = Destination +  2 * (Pawn.Location - Destination + Dir * ((Destination - Pawn.Location) Dot Dir));
	}

	/* PickDestination()
	Choose a destination for the tactical move, based on aggressiveness and the tactical
	situation. Make sure destination is reachable
	*/
	function PickDestination()
	{
		local vector pickdir, enemydir, enemyPart, Y, LookDir;
		local float strafeSize;
		local bool bFollowingPlayer;

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

		bFollowingPlayer = ( (PlayerController(Squad.SquadLeader) != None) && (Squad.SquadLeader.Pawn != None)
							&& (VSize(Pawn.Location - Squad.SquadLeader.Pawn.Location) < 1600) );

		strafeSize = FClamp(((2 * Aggression + 1) * FRand() - 0.65),-0.7,0.7);
		if ( Squad.MustKeepEnemy(Enemy) )
			strafeSize = FMax(0.4 * FRand() - 0.2,strafeSize);

		enemyPart = enemydir * strafeSize;
		strafeSize = FMax(0.0, 1 - Abs(strafeSize));
		pickdir = strafeSize * Y;
		if ( bStrafeDir )
			pickdir *= -1;
		if ( bFollowingPlayer )
		{
			// try not to get in front of squad leader
			LookDir = vector(Squad.SquadLeader.Rotation);
			if ( (LookDir dot (Pawn.Location + (enemypart + pickdir)*MINSTRAFEDIST - Squad.SquadLeader.Pawn.Location))
				> FMax(0,(LookDir dot (Pawn.Location + (enemypart - pickdir)*MINSTRAFEDIST - Squad.SquadLeader.Pawn.Location))) )
			{
				bStrafeDir = !bStrafeDir;
				pickdir *= -1;
			}

		}

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
		local bool bWantJump;

		// successfully engage direction if can trace out and down
		MinDest = Pawn.Location + MINSTRAFEDIST * StrafeDir;
		if ( !bForced )
		{
			collSpec = Pawn.GetCollisionExtent();
			collSpec.Z = FMax(6, Pawn.CollisionHeight - MAXSTEPHEIGHT);

			bWantJump = (Vehicle(Pawn) == None) && (Pawn.Physics != PHYS_Falling) && ((FRand() < 0.05 * Skill + 0.6 * Jumpiness) || (Pawn.Weapon.SplashJump() && ProficientWithWeapon()))
				&& (Enemy.Location.Z - Enemy.CollisionHeight <= Pawn.Location.Z + MAXSTEPHEIGHT - Pawn.CollisionHeight)
				&& !NeedToTurn(Enemy.Location);

			HitActor = Trace(HitLocation, HitNormal, MinDest, Pawn.Location, false, collSpec);
			if ( (HitActor != None) && (!bWantJump || !Pawn.bCanWallDodge) )
				return false;

			if ( Pawn.Physics == PHYS_Walking )
			{
				collSpec.X = FMin(14, 0.5 * Pawn.CollisionRadius);
				collSpec.Y = collSpec.X;
				HitActor = Trace(HitLocation, HitNormal, minDest - (3 * MAXSTEPHEIGHT) * vect(0,0,1), minDest, false, collSpec);
				if ( HitActor == None )
				{
					HitNormal = -1 * StrafeDir;
					return false;
				}
			}

			if ( bWantJump )
			{
				if ( Pawn.Weapon.SplashJump() )
					StopFiring();
					bNotifyApex = true;
					bTacticalDoubleJump = true;

				// try jump move
				bPlannedJump = true;
				DodgeLandZ = Pawn.Location.Z;
				bInDodgeMove = true;
				Pawn.SetPhysics(PHYS_Falling);
				Pawn.Velocity = SuggestFallVelocity(MinDest, Pawn.Location, 1.5*Pawn.JumpZ, Pawn.GroundSpeed);
				Pawn.Velocity.Z = Pawn.JumpZ;
				Pawn.Acceleration = vect(0,0,0);
				if ( Pawn.bCanWallDodge && (Skill + 2*Jumpiness > 3 + 3*FRand()) )
					bNotifyFallingHitWall = true;
				Destination = MinDest;
				return true;
			}
		}
		Destination = MinDest + StrafeDir * (0.5 * MINSTRAFEDIST
											+ FMin(VSize(Enemy.Location - Pawn.Location), MINSTRAFEDIST * (FRand() + FRand())));
		return true;
	}

	event NotifyJumpApex()
	{
		if ( bTacticalDoubleJump && !bPendingDoubleJump && (FRand() < 0.4) && (Skill > 2 + 5 * FRand()) )
		{
			bTacticalDoubleJump = false;
			bNotifyApex = true;
			bPendingDoubleJump = true;
		}
		else if ( Pawn.CanAttack(Enemy) )
			TimedFireWeaponAtEnemy();
		Global.NotifyJumpApex();
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
		Pawn.bWantsToCrouch = Squad.CautiousAdvance(self);
	}

	function EndState()
	{
		if ( !bPendingDoubleJump )
			bNotifyApex = false;
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
	if ( Enemy == None )
	{
		sleep(0.01);
		Goto('FinishedStrafe');
	}
	if (Pawn.Physics == PHYS_Falling)
	{
		Focus = Enemy;
		Destination = Enemy.Location;
		WaitForLanding();
	}
	if ( Enemy == None )
		Goto('FinishedStrafe');
	PickDestination();

DoMove:
	if ( (Pawn.Weapon != None) && Pawn.Weapon.FocusOnLeader(false) )
		MoveTo(Destination, Focus);
	else if ( !Pawn.bCanStrafe )
	{
		StopFiring();
		MoveTo(Destination);
	}
	else
	{
DoStrafeMove:
		MoveTo(Destination, Enemy);
	}
	if ( bForcedDirection && (Level.TimeSeconds - StartTacticalTime < 0.2) )
	{
		if ( !Pawn.HasWeapon() || Skill > 2 + 3 * FRand() )
		{
			bMustCharge = true;
			WhatToDoNext(51);
		}
		GoalString = "RangedAttack from failed tactical";
		DoRangedAttackOn(Enemy);
	}
	if ( (Enemy == None) || EnemyVisible() || !FastTrace(Enemy.Location, LastSeeingPos) || (Pawn.Weapon != None && Pawn.Weapon.bMeleeWeapon) )
		Goto('FinishedStrafe');

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
		if ( (Pawn.Weapon != None) && Pawn.Weapon.SplashDamage() )
		{
			StopFiring();
			Sleep(0.05);
		}
		else
			Sleep(0.1 + 0.3 * FRand() + 0.06 * (7 - FMin(7,Skill)));
		if ( (FRand() + 0.3 > Aggression) )
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

function bool FindViewSpot()
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

	function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
	{
		LastUnderFire = Level.TimeSeconds;
		Super.NotifyTakeHit(InstigatedBy,HitLocation, Damage,DamageType,Momentum);
		if ( (Pawn.Health > 0) && (Damage > 0) )
			bFrustrated = true;
	}

	function SeePlayer(Pawn SeenPlayer)
	{
		if ( SeenPlayer == Enemy )
		{
			VisibleEnemy = Enemy;
			EnemyVisibilityTime = Level.TimeSeconds;
			bEnemyIsVisible = true;
			BlockedPath = None;
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
		local int i;

		// If no enemy, or I should see him but don't, then give up
		if ( (Enemy == None) || (Enemy.Health <= 0) )
		{
			LoseEnemy();
			WhatToDoNext(23);
			return;
		}

		if ( Pawn.JumpZ > 0 )
			Pawn.bCanJump = true;

		if ( ActorReachable(Enemy) )
		{
			BlockedPath = None;
			if ( (LostContact(5) && (((Enemy.Location - Pawn.Location) Dot vector(Pawn.Rotation)) < 0))
				&& LoseEnemy() )
			{
				WhatToDoNext(24);
				return;
			}
			Destination = Enemy.Location;
			MoveTarget = None;
			return;
		}

		ViewSpot = Pawn.Location + Pawn.BaseEyeHeight * vect(0,0,1);
		bCanSeeLastSeen = bEnemyInfoValid && FastTrace(LastSeenPos, ViewSpot);

		if ( Squad.BeDevious() )
		{
			if ( BlockedPath == None )
			{
				// block the first path visible to the enemy
				if ( FindPathToward(Enemy,false) != None )
				{
					for ( i=0; i<16; i++ )
					{
						if ( NavigationPoint(RouteCache[i]) == None )
							break;
						else if ( Enemy.Controller.LineOfSightTo(RouteCache[i]) )
						{
							BlockedPath = NavigationPoint(RouteCache[i]);
							break;
						}
					}
				}
				else if ( CanStakeOut() )
				{
					GoalString = "Stakeout from hunt";
					GotoState('StakeOut');
					return;
				}
				else if ( LoseEnemy() )
				{
					WhatToDoNext(25);
					return;
				}
				else
				{
					GoalString = "Retreat from hunt";
					DoRetreat();
					return;
				}
			}
			// control path weights
			if ( BlockedPath != None )
				BlockedPath.TransientCost = 1500;
		}
		if ( FindBestPathToward(Enemy, true,true) )
			return;

		if ( bSoaking && (Physics != PHYS_Falling) )
			SoakStop("COULDN'T FIND PATH TO ENEMY "$Enemy);

		MoveTarget = None;
		if ( !bEnemyInfoValid && LoseEnemy() )
		{
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
				else if ( (Pawn.Physics == PHYS_Flying) && LoseEnemy() )
				{
					WhatToDoNext(411);
					return;
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
		local bool bAlwaysTry;

		if ( Enemy == None )
			return false;

		GetAxes(Rotation,X,Y,Z);

		// try left and right
		// if frustrated, always move if possible
		bAlwaysTry = bFrustrated;
		bFrustrated = false;

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
		if ( bAlwaysTry )
		{
			if ( FRand() < 0.5 )
				Destination = Pawn.Location - 2.5 * Y * Pawn.CollisionRadius;
			else
				Destination = Pawn.Location - 2.5 * Y * Pawn.CollisionRadius;
			return true;
		}

		return false;
	}

	function BeginState()
	{
		Pawn.bWantsToCrouch = Squad.CautiousAdvance(self);
		//SetAlertness(0.5);
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
	PickDestination();
SpecialNavig:
	if (MoveTarget == None)
		MoveTo(Destination);
	else
		MoveToward(MoveTarget,FaceActor(10),,(FRand() < 0.75) && ShouldStrafeTo(MoveTarget));

	WhatToDoNext(27);
	if ( bSoaking )
		SoakStop("STUCK IN HUNTING!");
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
			if ( ((Pawn.Weapon == None) || !Pawn.Weapon.FocusOnLeader(false)) && (FRand() < 0.5) )
			{
				Focus = Enemy;
				FireWeaponAt(Enemy);
			}
			WhatToDoNext(28);
		}
		else if ( Squad.SetEnemy(self,SeenPlayer) )
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
			bFrustrated = true;
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
			if ( Enemy != None )
				FireSpot += 2 * Enemy.CollisionHeight * HitNormal;
			if ( !FastTrace(FireSpot, ProjStart) )
			{
				FireSpot = FocalPoint;
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
		if ( (Pawn.Weapon != None) && Pawn.Weapon.FocusOnLeader(false) )
			Focus = Focus;
		else if ( bEnemyInfoValid )
			FocalPoint = LastSeenPos;
		else
			FocalPoint = Enemy.Location;
	}

	function BeginState()
	{
		StopStartTime = Level.TimeSeconds;
		Pawn.Acceleration = vect(0,0,0);
		Pawn.bCanJump = false;
		//SetAlertness(0.5);
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
	if ( (Pawn.Weapon != None) && Pawn.Weapon.FocusOnLeader(false) )
		Focus = Focus;
	CheckIfShouldCrouch(Pawn.Location,FocalPoint, 1);
	FinishRotation();
	if ( (Pawn.Weapon != None) && Pawn.Weapon.FocusOnLeader(false) )
		FireWeaponAt(Focus);
	else if ( (Pawn.Weapon != None) && !Pawn.Weapon.bMeleeWeapon && Squad.ShouldSuppressEnemy(self) && ClearShot(FocalPoint,true) )
	{
		FireWeaponAt(Enemy);
	}
	else if ( Vehicle(Pawn) != None )
		FireWeaponAt(Enemy);
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

function bool Stopped()
{
	return bPreparingMove;
}

function bool IsShootingObjective()
{
	return false;
}

state RangedAttack
{
ignores SeePlayer, HearNoise, Bump;

	function bool Stopped()
	{
		return true;
	}

	function bool IsShootingObjective()
	{
		return (Target != None && (Target == Squad.SquadObjective || Target.Owner == Squad.SquadObjective));
	}

	function CancelCampFor(Controller C)
	{
		DoTacticalMove();
	}

	function StopFiring()
	{
		if ( (Pawn != None) && Pawn.RecommendLongRangedAttack() && Pawn.IsFiring() )
			return;
		Global.StopFiring();
		if ( bHasFired )
		{
			if ( IsSniping() )
				Pawn.bWantsToCrouch = (Skill > 2);
			else
			{
				bHasFired = false;
				WhatToDoNext(32);
			}
		}
	}

	function EnemyNotVisible()
	{
		//let attack animation complete
		if ( (Target == Enemy) && !Pawn.RecommendLongRangedAttack() )
			WhatToDoNext(33);
	}

	function Timer()
	{
		if ( (Pawn.Weapon != None) && Pawn.Weapon.bMeleeWeapon )
		{
			SetCombatTimer();
			StopFiring();
			WhatToDoNext(34);
		}
		else if ( Target == Enemy )
			TimedFireWeaponAtEnemy();
		else
			FireWeaponAt(Target);
	}

	function DoRangedAttackOn(Actor A)
	{
		if ( (Pawn.Weapon != None) && Pawn.Weapon.FocusOnLeader(false) )
			Target = Focus;
		else
			Target = A;
		GotoState('RangedAttack');
	}

	function BeginState()
	{
		StopStartTime = Level.TimeSeconds;
		bHasFired = false;
		if ( (Pawn.Physics != PHYS_Flying) || (Pawn.MinFlySpeed == 0) )
		Pawn.Acceleration = vect(0,0,0); //stop
		if ( Vehicle(Pawn) != None )
		{
			Vehicle(Pawn).Steering = 0;
			Vehicle(Pawn).Throttle = 0;
			Vehicle(Pawn).Rise = 0;
		}
		if ( (Pawn.Weapon != None) && Pawn.Weapon.FocusOnLeader(false) )
			Target = Focus;
		else if ( Target == None )
			Target = Enemy;
		if ( Target == None )
			log(GetHumanReadableName()$" no target in ranged attack");
	}

Begin:
	bHasFired = false;
	if ( (Pawn.Weapon != None) && Pawn.Weapon.bMeleeWeapon )
		SwitchToBestWeapon();
	GoalString = GoalString@"Ranged attack";
	Focus = Target;
	Sleep(0.0);
	if ( Target == None )
		WhatToDoNext(335);

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
	if ( ((Pawn.Weapon != None) && Pawn.Weapon.bMeleeWeapon) || (Target == None) || ((Target != Enemy) && (GameObjective(Target) == None) && (Enemy != None) && EnemyVisible()) )
		WhatToDoNext(35);
	if ( Enemy != None )
		CheckIfShouldCrouch(Pawn.Location,Enemy.Location, 1);
	Focus = Target;
	Sleep(FMax(Pawn.RangedAttackTime(),0.2 + (0.5 + 0.5 * FRand()) * 0.4 * (7 - Skill)));
	WhatToDoNext(36);
	if ( bSoaking )
		SoakStop("STUCK IN RANGEDATTACK!");
}


state ShieldSelf
{
ignores SeePlayer, HearNoise, Bump, EnemyNotVisible;

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
	}

	function BeginState()
	{
		StopStartTime = Level.TimeSeconds;
		bHasFired = false;
		if ( Target == None )
			Target = Enemy;
		if ( Target == None )
			log(GetHumanReadableName()$" no target in shield self");
	}

Begin:
	bHasFired = false;
	SwitchToBestWeapon();
	TimedFireWeaponAtEnemy();
	Focus = Target;
	Sleep(0.0);
	if ( NeedToTurn(Target.Location) )
	{
		Focus = Target;
		FinishRotation();
	}
KeepShielding:
	FireWeaponAt(Target);
	if ( Pawn.IsFiring() )
		Sleep(0.5);
	else
		Sleep(0.1);
	bHasFired = true;
	if ( ShouldKeepShielding() )
		Goto('KeepShielding');
	WhatToDoNext(136);
	if ( bSoaking )
		SoakStop("STUCK IN SHIELDSELF!");
}

state Dead
{
ignores SeePlayer, EnemyNotVisible, HearNoise, ReceiveWarning, NotifyLanded, NotifyPhysicsVolumeChange,
		NotifyHeadVolumeChange,NotifyLanded,NotifyHitWall,NotifyBump;

	event DelayedWarning() {}

	function DoRangedAttackOn(Actor A)
	{
	}

	function WhatToDoNext(byte CallingByte)
	{
		//log(self$" WhatToDoNext while dead CALLED BY "$CallingByte);
	}

	function Celebrate()
	{
		log(self$" Celebrate while dead");
	}

	function bool SetRouteToGoal(Actor A)
	{
		log(self$" SetRouteToGoal while dead");
return true;
	}

	function SetAttractionState()
	{
		log(self$" SetAttractionState while dead");
	}

	function EnemyChanged(bool bNewEnemyVisible)
	{
		log(self$" EnemyChanged while dead");
	}

	function WanderOrCamp(bool bMayCrouch)
	{
		log(self$" WanderOrCamp while dead");
	}

	function Timer() {}

	function BeginState()
	{
		if ( Level.Game.TooManyBots(self) )
		{
			Destroy();
			return;
		}
		if ( (GoalScript != None) && (HoldSpot(GoalScript) == None) )
			FreeScript();
		if ( NavigationPoint(MoveTarget) != None )
			NavigationPoint(MoveTarget).FearCost = 2 * NavigationPoint(MoveTarget).FearCost + 600;
		Enemy = None;
		StopFiring();
		FormerVehicle = None;
		bFrustrated = false;
		BlockedPath = None;
		bInitLifeMessage = false;
		bPlannedJump = false;
		bInDodgeMove = false;
		bReachedGatherPoint = false;
		bFinalStretch = false;
		bWasNearObjective = false;
		bPreparingMove = false;
		bEnemyEngaged = false;
		bPursuingFlag = false;
		bHasSuperWeapon = false;
		RouteGoal = None;
		MoveTarget = None;
	}

Begin:
	if ( Level.Game.bGameEnded )
		GotoState('GameEnded');
	Sleep(0.2);
TryAgain:
	if ( UnrealMPGameInfo(Level.Game) == None )
		destroy();
	else
	{
		Sleep(0.25 + UnrealMPGameInfo(Level.Game).SpawnWait(self));
		LastRespawnTime = Level.TimeSeconds;
		Level.Game.ReStartPlayer(self);
		Goto('TryAgain');
	}

MPStart:
	Sleep(0.75 + FRand());
	Level.Game.ReStartPlayer(self);
	Goto('TryAgain');
}

state FindAir
{
ignores SeePlayer, HearNoise, Bump;

	function bool NotifyHeadVolumeChange(PhysicsVolume NewHeadVolume)
	{
		Global.NotifyHeadVolumeChange(newHeadVolume);
		if ( !newHeadVolume.bWaterVolume )
			WhatToDoNext(37);
		return false;
	}

	function bool NotifyHitWall(vector HitNormal, actor Wall)
	{
		//change directions
		Destination = MINSTRAFEDIST * (Normal(Destination - Pawn.Location) + HitNormal);
		return true;
	}

	function Timer()
	{
		if ( (Enemy != None) && EnemyVisible() )
			TimedFireWeaponAtEnemy();
		else
			SetCombatTimer();
	}

	function EnemyNotVisible() {}

/* PickDestination()
*/
	function PickDestination(bool bNoCharge)
	{
		Destination = VRand();
		Destination.Z = 1;
		Destination = Pawn.Location + MINSTRAFEDIST * Destination;
	}

	function BeginState()
	{
		Pawn.bWantsToCrouch = false;
		bAdjustFromWalls = false;
	}

	function EndState()
	{
		bAdjustFromWalls = true;
	}

Begin:
	PickDestination(false);

DoMove:
	if ( Enemy == None )
		MoveTo(Destination);
	else
		MoveTo(Destination, Enemy);
	WhatToDoNext(38);
}

function SetEnemyReaction(int AlertnessLevel)
{
	ScriptedCombat = FOLLOWSCRIPT_LeaveScriptForCombat;
		Enable('HearNoise');
		Enable('SeePlayer');
		Enable('SeeMonster');
		Enable('NotifyBump');

/*
	if ( AlertnessLevel == 0 )
	{
		ScriptedCombat = FOLLOWSCRIPT_IgnoreAllStimuli;
		bGodMode = true;
	}
	else
		bGodMode = false;

	if ( AlertnessLevel < 2 )
	{
		ScriptedCombat = FOLLOWSCRIPT_IgnoreEnemies;
		Disable('HearNoise');
		Disable('SeePlayer');
		Disable('SeeMonster');
		Disable('NotifyBump');
	}
	else
	{
		Enable('HearNoise');
		Enable('SeePlayer');
		Enable('SeeMonster');
		Enable('NotifyBump');
		if ( AlertnessLevel == 2 )
			ScriptedCombat = FOLLOWSCRIPT_StayOnScript;
		else
			ScriptedCombat = FOLLOWSCRIPT_LeaveScriptForCombat;
	}
*/
}

state GameEnded
{
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange, Falling, TakeDamage, ReceiveWarning;

	event DelayedWarning() {}

	function SwitchToBestWeapon() {}

	function WhatToDoNext(byte CallingByte)
	{
		log(self$" WhatToDoNext while gameended CALLED BY "$CallingByte);
	}

	function Celebrate()
	{
		log(self$" Celebrate while gameended");
	}

	function SetAttractionState()
	{
		log(self$" SetAttractionState while gameended");
	}

	function EnemyChanged(bool bNewEnemyVisible)
	{
		log(self$" EnemyChanged while gameended");
	}

	function WanderOrCamp(bool bMayCrouch)
	{
		log(self$" WanderOrCamp while gameended");
	}

	function Timer()
	{
		if ( DeathMatch(Level.Game) != None )
		{
			if ( (DeathMatch(Level.Game).EndGameFocus == Pawn) && (Pawn != None) )
			{
				Pawn.PlayVictoryAnimation();
				//UnrealPawn(Pawn).bKeepTaunting = true;
			}
			else if ( (TeamGame(Level.Game) != None) && TeamGame(Level.Game).bPlayersVsBots )
			{
				if ( !TeamGame(Level.Game).PickEndGameTauntFor(self) )
					SetTimer(1 + 5*FRand(),false);
			}
		}
	}

	function BeginState()
	{
		Super.BeginState();

		SetTimer(3.0, false);
	}
}

function SetNewScript(ScriptedSequence NewScript)
{
	Super.SetNewScript(NewScript);
	GoalScript = UnrealScriptedSequence(NewScript);
	if ( GoalScript != None )
	{
		if ( FRand() < GoalScript.EnemyAcquisitionScriptProbability )
			EnemyAcquisitionScript = GoalScript.EnemyAcquisitionScript;
		else
			EnemyAcquisitionScript = None;
	}
}

function bool ScriptingOverridesAI()
{
	return false;
	//return ( (GoalScript != None) && (ScriptedCombat != FOLLOWSCRIPT_LeaveScriptForCombat) );
}

function bool ShouldPerformScript()
{
	if ( GoalScript != None )
	{
		if ( (Enemy != None) && (ScriptedCombat == FOLLOWSCRIPT_LeaveScriptForCombat) )
		{
			SequenceScript = None;
			ClearScript();
			return false;
		}
		if ( SequenceScript != GoalScript )
			SetNewScript(GoalScript);
		GotoState('Scripting','Begin');
		return true;
	}
	return false;
}

State Scripting
{
	ignores EnemyNotVisible;

	function Restart() {}

	function UnPossess()
	{
		Global.UnPossess();
	}

	function Timer()
	{
		Super.Timer();
		enable('NotifyBump');
	}

	function CompleteAction()
	{
		ActionNum++;
		WhatToDoNext(39);
	}

	/* UnPossess()
	scripted sequence is over - return control to PendingController
	*/
	function LeaveScripting()
	{
		if ( (SequenceScript == GoalScript) && (HoldSpot(GoalScript) == None) )
		{
			FreeScript();
			Global.WhatToDoNext(40);
		}
		else
			WanderOrCamp(true);
	}

	function EndState()
	{
		Super.EndState();
		SetCombatTimer();
		if ( (Pawn != None) && (Pawn.Health > 0) )
			Pawn.bPhysicsAnimUpdate = Pawn.Default.bPhysicsAnimUpdate;
	}

	function ClearPathFor(Controller C)
	{
		CancelCampFor(C);
	}

	function CancelCampFor(Controller C)
	{
		if ( Pawn.Velocity == vect(0,0,0) )
			DirectedWander(Normal(Pawn.Location - C.Pawn.Location));
	}

	function AbortScript()
	{
		if ( (SequenceScript == GoalScript) && (HoldSpot(GoalScript) == None) )
			FreeScript();
		WanderOrCamp(true);
	}

	function SetMoveTarget()
	{
		Super.SetMoveTarget();
		if ( Pawn.ReachedDestination(Movetarget) )
		{
			ActionNum++;
			GotoState('Scripting','Begin');
			return;
		}
		if ( (Enemy != None) && (ScriptedCombat == FOLLOWSCRIPT_StayOnScript) )
			GotoState('Fallback');
	}

	function MayShootAtEnemy()
	{
		if ( Enemy != None )
		{
			Target = Enemy;
			GotoState('Scripting','ScriptedRangedAttack');
		}
	}

ScriptedRangedAttack:
	GoalString = "Scripted Ranged Attack";
	Focus = Enemy;
	WaitToSeeEnemy();
	if ( Target != None )
		FireWeaponAt(Target);
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

Begin:
	if ( Pawn.PhysicsVolume.bWaterVolume )
		WhatToDoNext(150);
	if ( Pawn.PhysicsVolume.Gravity.Z > 0.9 * Pawn.PhysicsVolume.Default.Gravity.Z )
	{
     	if ( (MoveTarget == None) || (MoveTarget.Location.Z > Pawn.Location.Z) )
	    {
		    NotifyMissedJump();
		    if ( MoveTarget != None )
			    MoveToward(MoveTarget,Focus,,true);
	    }
	    else if (Physics != PHYS_Falling)
	    	WhatToDoNext(151);
	    else
	    {
		    Sleep(0.5);
		    Goto('Begin');
	    }
	}
	WaitForLanding();
	WhatToDoNext(50);
}

State Testing
{
ignores SeePlayer, EnemyNotVisible, HearNoise, ReceiveWarning, NotifyLanded, NotifyPhysicsVolumeChange,
		NotifyHeadVolumeChange,NotifyLanded,NotifyHitWall,NotifyBump;

	function WhatToDoNext(byte CallingByte)
	{
		//log(self$" WhatToDoNext while dead CALLED BY "$CallingByte);
	}

	function Celebrate()
	{
		log(self$" Celebrate while dead");
	}

	function SetAttractionState()
	{
		log(self$" SetAttractionState while dead");
	}

	function EnemyChanged(bool bNewEnemyVisible)
	{
		log(self$" EnemyChanged while dead");
	}

	function WanderOrCamp(bool bMayCrouch)
	{
		log(self$" WanderOrCamp while dead");
	}

	function bool AvoidCertainDeath()
	{
		Pawn.SetLocation(TestStart.Location);
		MoveTimer = -1.0;
		return true;
	}

	function Timer() {}

	function FindNextMoveTarget()
	{
		local NavigationPoint N;
		local bool bFoundStart;
		local int i;

		bFoundStart = ( TestStart == None );
		Pawn.Health = 100;
		for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		{
			if ( N == TestStart )
				bFoundStart = true;
			if ( bFoundStart && (TestPath < N.PathList.Length) )
			{
				for ( i=TestPath; i<N.PathList.length; i++ )
					if ( (JumpSpot(N.PathList[i].End) != None) && N.PathList[i].bForced )
					{
						log("Test translocation from "$N$" to "$(N.PathList[i].End));
						Pawn.SetLocation(N.Location + (Pawn.CollisionHeight - N.CollisionHeight) * vect(0,0,1));
						Pawn.Anchor = N;
						TestStart = N;
						TestPath = i+1;
						MoveTarget = N.PathList[i].End;
						JumpSpot(N.PathList[i].End).bOnlyTranslocator = true;
						ClientSetRotation(rotator(MoveTarget.Location - Pawn.Location));
						return;
					}
			}
			if ( N == TestStart )
				Testpath = 0;
		}
		TestStart = None;
		TestPath = 0;
		if ( bSingleTestSection )
			GotoState('Testing','AllFinished');
		else
			GotoState('Testing','Finished');
	}

	function FindNextJumpTarget()
	{
		local NavigationPoint N;
		local bool bFoundStart;
		local int i;

		bFoundStart = ( TestStart == None );
		Pawn.Health = 100;
		for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		{
			if ( N == TestStart )
				bFoundStart = true;
			if ( bFoundStart && (JumpPad(N) == None) && (TestPath < N.PathList.Length) )
			{
				for ( i=TestPath; i<N.PathList.length; i++ )
					if ( (JumpSpot(N.PathList[i].End) != None) && N.PathList[i].bForced )
					{
						JumpSpot(N.PathList[i].End).bOnlyTranslocator = JumpSpot(N.PathList[i].End).bRealOnlyTranslocator;
						if ( (JumpSpot(N.PathList[i].End).SpecialCost(Pawn, N.PathList[i]) < 1000000) )
 						{
							log("Test "$GoalString$" from "$N$" to "$(N.PathList[i].End));
							Pawn.SetLocation(N.Location + (Pawn.CollisionHeight - N.CollisionHeight) * vect(0,0,1));
							Pawn.Anchor = N;
							TestStart = N;
							TestPath = i+1;
							MoveTarget = N.PathList[i].End;
							ClientSetRotation(rotator(MoveTarget.Location - Pawn.Location));
							return;
						}
					}
			}
			if ( N == TestStart )
				TestPath = 0;
		}
		TestStart = None;
		TestPath = 0;
		if ( bSingleTestSection )
			GotoState('Testing','AllFinished');
		else
			GotoState('Testing',TestLabel);
	}

	function SetLowGrav(bool bSet)
	{
		local PhysicsVolume V;

		if ( bSet )
		{
			ForEach AllActors(class'PhysicsVolume', V)
				V.Gravity.Z = FMax(V.Gravity.Z,-300);
		}
		else
		{
			ForEach AllActors(class'PhysicsVolume', V)
				V.Gravity.Z = V.Default.Gravity.Z;
		}
	}

	function EndState()
	{
		log(self$" leaving test state");
	}

	function BeginState()
	{
		bHasImpactHammer = false;
		bAllowedToImpactJump = false;
		log(self$" entering test state");
		SetTimer(0.0,false);
		Skill = 7;
	}

Begin:
	if ( Pawn.Weapon == None )
	{
	    Pawn.PendingWeapon = Weapon(Pawn.FindInventoryType(class<Inventory>(DynamicLoadObject("XWeapons.Translauncher",class'class'))));
		Pawn.ChangedWeapon();
		Sleep(0.5);
	}
	bAllowedToTranslocate = true;
	bHasTranslocator = true;
	GoalString = "TRANSLOCATING";
	FindNextMoveTarget();
	Pawn.Acceleration = vect(0,0,0);
	MoveToward(MoveTarget);
	if ( !Pawn.ReachedDestination(MoveTarget) )
		log("FAILED to reach "$MoveTarget);
	else if ( Pawn.Health < 100 )
		log("TOOK DAMAGE "$(100-Pawn.Health)$" but succeeded");
	else
		log("Success!");
	Goto('Begin');
Finished:
	if ( !bAllowedToImpactJump )
	{
	    Pawn.GiveWeapon("XWeapons.ShieldGun");
		bAllowedToImpactJump = true;
		Sleep(0.5);
	}
	TestLabel = 'FinishedJumping';
	bAllowedToTranslocate = false;
	bHasImpactHammer = true;
	bHasTranslocator = false;
	Pawn.bCanDoubleJump = true;
	GoalString = "DOUBLE/IMPACT JUMPING";
	FindNextJumpTarget();
	Pawn.Acceleration = vect(0,0,0);
	MoveToward(MoveTarget);
	if ( !Pawn.ReachedDestination(MoveTarget) )
		log("FAILED to reach "$MoveTarget);
	else if ( Pawn.Health < 100 )
		log("TOOK DAMAGE "$(100-Pawn.Health)$" but succeeded");
	else
		log("Success!");
	Goto('Finished');

FinishedJumping:
	Pawn.bCanDoubleJump = true;
	Pawn.Health = 100;
	bHasImpactHammer = false;
	bAllowedToTranslocate = false;
	bHasTranslocator = false;
	bAllowedToImpactJump = false;
	TestLabel = 'FinishedComboJumping';
	Pawn.JumpZ = Pawn.Default.JumpZ * 1.5;
	Pawn.GroundSpeed = Pawn.Default.GroundSpeed * 1.4;
	GoalString = "COMBO JUMPING";
	FindNextJumpTarget();
	Pawn.Acceleration = vect(0,0,0);
	MoveToward(MoveTarget);
	if ( !Pawn.ReachedDestination(MoveTarget) )
		log("FAILED to reach "$MoveTarget);
	else if ( Pawn.Health < 100 )
		log("TOOK DAMAGE "$(100-Pawn.Health)$" but succeeded");
	else
		log("Success!");
	Goto('FinishedJumping');

FinishedComboJumping:
	Pawn.bCanDoubleJump = true;
	TestLabel = 'AllFinished';
	bHasImpactHammer = false;
	bAllowedToTranslocate = false;
	bHasTranslocator = false;
	bAllowedToImpactJump = false;
	SetLowGrav(true);
	Pawn.GroundSpeed = Pawn.Default.GroundSpeed;
	Pawn.JumpZ = Pawn.Default.JumpZ;
	GoalString = "LOWGRAV JUMPING";
	FindNextJumpTarget();
	Pawn.Acceleration = vect(0,0,0);
	MoveToward(MoveTarget);
	if ( !Pawn.ReachedDestination(MoveTarget) )
		log("FAILED to reach "$MoveTarget);
	else if ( Pawn.Health < 100 )
		log("TOOK DAMAGE "$(100-Pawn.Health)$" but succeeded");
	else
		log("Success!");
	Goto('FinishedComboJumping');
AllFinished:
	SetLowGrav(false);
	bSingleTestSection = false;
	Pawn.PlayVictoryAnimation();
}

defaultproperties
{
     bLeadTarget=True
     Aggressiveness=0.400000
     LastAttractCheck=-10000.000000
     BaseAggressiveness=0.400000
     CombatStyle=0.200000
     TranslocUse=1.000000
     ScriptedCombat=FOLLOWSCRIPT_LeaveScriptForCombat
     LastSearchTime=-10000.000000
     ComboNames(0)="xGame.ComboSpeed"
     ComboNames(1)="xGame.ComboBerserk"
     ComboNames(2)="xGame.ComboDefensive"
     ComboNames(3)="xGame.ComboInvis"
     OrderNames(0)="Defend"
     OrderNames(1)="HOLD"
     OrderNames(2)="Attack"
     OrderNames(3)="Follow"
     OrderNames(4)="Freelance"
     OrderNames(10)="Attack"
     OrderNames(11)="Defend"
     OrderNames(12)="Defend"
     OrderNames(13)="Attack"
     OrderNames(14)="Attack"
     FovAngle=85.000000
     bIsPlayer=True
     OldMessageTime=-100.000000
     PlayerReplicationInfoClass=Class'UnrealGame.TeamPlayerReplicationInfo'
}
