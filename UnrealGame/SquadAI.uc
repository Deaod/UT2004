//=============================================================================
// SquadAI.
// operational AI control for TeamGame
//
//=============================================================================
class SquadAI extends ReplicationInfo;

var UnrealTeamInfo Team;
var Controller SquadLeader;
var TeamPlayerReplicationInfo LeaderPRI;
var SquadAI NextSquad;	// list of squads on a team
var GameObjective SquadObjective;
var int Size;
var AssaultPath AlternatePath;	// path to use for attacking base
var name AlternatePathTag;
var Bot SquadMembers;
var float GatherThreshold;
var localized string SupportString, DefendString, AttackString, HoldString, FreelanceString;
var localized string SupportStringTrailer;
var name CurrentOrders;
var Pawn Enemies[8];
var int MaxSquadSize;
var bool bFreelance;
var bool bFreelanceAttack;
var bool bFreelanceDefend;
var bool bRoamingSquad;
var bool bAddTransientCosts;
var UnrealScriptedSequence FreelanceScripts;

var RestingFormation RestingFormation;
var class<RestingFormation> RestingFormationClass;

replication
{
	reliable if ( Role == ROLE_Authority )
		LeaderPRI, CurrentOrders, SquadObjective, bFreelance;
}

function Reset()
{
	local int i;

	Super.Reset();

	NetUpdateTime = Level.Timeseconds - 1;
	SquadObjective = None;
	AlternatePath = None;
	for ( i=0; i<8; i++ )
		Enemies[i] = None;
}

function AssignCombo(Bot B)
{
	if ( (B.Enemy != None) && B.EnemyVisible() )
	{
		if ( CurrentOrders == 'Defend' )
			B.TryCombo("DMRandom");
		else
			B.TryCombo("Random");
	}
}

function CriticalObjectiveWarning(Pawn NewEnemy)
{
	local Bot M;

	if ( !ValidEnemy(NewEnemy) )
		return;

	AddEnemy(NewEnemy);

	// reassess squad member enemies
	if ( !MustKeepEnemy(NewEnemy) )
		return;

	for	( M=SquadMembers; M!=None; M=M.NextSquadMember )
	{
		if ( (M.Enemy == None) )
			FindNewEnemyFor(M,false);
	}
}

function bool ShouldSuppressEnemy(Bot B)
{
	return ( (FRand() < 0.7) && (VSize(B.Enemy.Location - B.FocalPoint) < 350)
			&& (Level.TimeSeconds - B.LastSeenTime < 4) );
}

function bool AllowDetourTo(Bot B,NavigationPoint N)
{
	return true;
}

function RestingFormation GetRestingFormation()
{
	if ( RestingFormation == None )
		RestingFormation = spawn(RestingFormationClass,self);
	return RestingFormation;
}

function Destroyed()
{
	if ( Team != None )
		Team.AI.RemoveSquad(self);
	if ( RestingFormation != None )
		RestingFormation.Destroy();
	Super.Destroyed();
}

function bool AllowTranslocationBy(Bot B)
{
	return true;
}

function bool AllowImpactJumpBy(Bot B)
{
	return true;
}

function actor SetFacingActor(Bot B)
{
	return None;
}

function Vehicle GetKeyVehicle(Bot B)
{
	if ( Vehicle(SquadLeader.Pawn) == None )
		return None;

	if ( Vehicle(SquadLeader.Pawn).bKeyVehicle )
		return Vehicle(SquadLeader.Pawn);
	return None;
}

function Vehicle GetLinkVehicle(Bot B)
{
	if ( Vehicle(SquadLeader.Pawn) == None )
		return None;

	if ( (B.Enemy == None) || Vehicle(SquadLeader.Pawn).bKeyVehicle )
		return Vehicle(SquadLeader.Pawn);
	return None;
}

/* GetFacingRotation()
return the direction the squad is moving towards its objective
*/
function rotator GetFacingRotation()
{
	local rotator Rot;
	// FIXME - use path to objective, rather than just direction

	if ( SquadObjective == None )
		Rot = SquadLeader.Rotation;
	else if ( SquadObjective.DefenderTeamIndex == Team.TeamIndex )
		Rot.Yaw = Rand(65536);
	else if ( SquadLeader.Pawn != None )
		Rot = rotator(SquadObjective.Location - SquadLeader.Pawn.Location);
	else
		Rot.Yaw = Rand(65536);

	Rot.Pitch = 0;
	Rot.Roll = 0;
	return Rot;
}

function actor FormationCenter()
{
	if ( (SquadObjective != None) && (SquadObjective.DefenderTeamIndex == Team.TeamIndex) )
		return SquadObjective;
	return SquadLeader.Pawn;
}

/* MergeEnemiesFrom()
Add squad S enemies to my list.
returns false if no enemies were added to my list
*/
function bool MergeEnemiesFrom(SquadAI S)
{
	local int i;
	local bool bNew, bAdd;

	if ( S == None )
		return false;
	for ( i=0; i<ArrayCount(Enemies); i++ )
	{
		if ( S.Enemies[i] != None )
			bAdd = AddEnemy(S.Enemies[i]);
		bNew = bNew || bAdd;
	}
	return bNew;
}

/* LostEnemy()
Bot lost track of enemy.  Change enemy for this bot, clear from list if no one can see it
*/
function bool LostEnemy(Bot B)
{
	local pawn Lost;
	local bool bFound;
	local Bot M;

	if ( (B.Enemy.Health <= 0) || (B.Enemy.Controller == None) )
	{
		B.Enemy = None;
		RemoveEnemy(B.Enemy);
		FindNewEnemyFor(B,false);
		return true;
	}

	if ( MustKeepEnemy(B.Enemy) )
		return false;
	Lost = B.Enemy;
	B.Enemy = None;

	for	( M=SquadMembers; M!=None; M=M.NextSquadMember )
		if ( (M != B) && (M.Enemy == Lost) && !M.LostContact(5) )
		{
			bFound = true;
			break;
		}

	if ( bFound )
		B.Enemy = Lost;
	else
	{
		RemoveEnemy(Lost);
		FindNewEnemyFor(B,false);
	}
	return (B.Enemy != Lost);
}

function bool MustKeepEnemy(Pawn E)
{
	return false;
}

/* AddEnemy()
adds an enemy - returns false if enemy was already on list
*/
function bool AddEnemy(Pawn NewEnemy)
{
	local int i;
	local Bot M;
	local bool bCurrentEnemy;

	for ( i=0; i<ArrayCount(Enemies); i++ )
		if ( Enemies[i] == NewEnemy )
			return false;
	for ( i=0; i<ArrayCount(Enemies); i++ )
		if ( Enemies[i] == None )
		{
			Enemies[i] = NewEnemy;
			return true;
		}
	for ( i=0; i<ArrayCount(Enemies); i++ )
	{
		bCurrentEnemy = false;
		for	( M=SquadMembers; M!=None; M=M.NextSquadMember )
			if ( M.Enemy ==	Enemies[i] )
			{
				bCurrentEnemy = true;
				break;
			}
		if ( !bCurrentEnemy )
		{
			Enemies[i] = NewEnemy;
			return true;
		}
	}
	//log("FAILED TO ADD ENEMY");
	return false;
}

function bool ValidEnemy(Pawn NewEnemy)
{
	return ( (NewEnemy != None) && !NewEnemy.bAmbientCreature && (NewEnemy.Health > 0) && (NewEnemy.Controller != None)	&& !FriendlyToward(NewEnemy) );
}

function bool SetEnemy( Bot B, Pawn NewEnemy )
{
	local Bot M;
	local bool bResult;

	if ( (NewEnemy == B.Enemy) || !ValidEnemy(NewEnemy) )
		return false;

	// add new enemy to enemy list - return if already there
	if ( !AddEnemy(NewEnemy) )
		return false;

	// reassess squad member enemies
	if ( MustKeepEnemy(NewEnemy) )
	{
		for	( M=SquadMembers; M!=None; M=M.NextSquadMember )
		{
			if ( (M != B) && (M.Enemy != NewEnemy) )
				FindNewEnemyFor(M,(M.Enemy !=None) && M.EnemyVisible());
		}
	}
	bResult = FindNewEnemyFor(B,(B.Enemy !=None) && B.EnemyVisible());
	if ( bResult && (B.Enemy == NewEnemy) )
		B.AcquireTime = Level.TimeSeconds;
	return bResult;

}

function byte PriorityObjective(Bot B)
{
	return 0;
}

function bool IsOnSquad(Controller C)
{
	if ( Bot(C) != None )
		return ( Bot(C).Squad == self );

	return ( C == SquadLeader );
}

function RemoveEnemy(Pawn E)
{
	local Bot B;
	local int i;

	for ( i=0; i<ArrayCount(Enemies); i++ )
		if ( Enemies[i] == E )
			Enemies[i] = None;

	if ( Level.Game.bGameEnded )
		return;

	for	( B=SquadMembers; B!=None; B=B.NextSquadMember )
		if ( B.Enemy == E )
		{
			B.Enemy = None;
			FindNewEnemyFor(B,false);
			if ( (B.Pawn != None) && (B.Enemy == None) && !B.bIgnoreEnemyChange )
			{
				if ( B.InLatentExecution(B.LATENT_MOVETOWARD) && (NavigationPoint(B.MoveTarget) != None)
					&& !B.bPreparingMove )
					B.GotoState('Roaming');
				else
					B.WhatToDoNext(42);
			}
		}
}

function NotifyKilled(Controller Killer, Controller Killed, pawn KilledPawn)
{
	local Bot B;

	if ( Killed == None )
		return;

	// if teammate killed, no need to update enemy list
	if ( (Team != None) && (Killed.PlayerReplicationInfo != None)
		&& (Killed.PlayerReplicationInfo.Team == Team) )
	{
		if ( IsOnSquad(Killed) )
		{
			// check if death was witnessed
			for	( B=SquadMembers; B!=None; B=B.NextSquadMember )
				if ( (B != Killed) && B.LineOfSightTo(KilledPawn) )
				{
					B.SendMessage(None, 'OTHER', B.GetMessageIndex('MANDOWN'), 10, 'TEAM');
					break;
				}
		}
		return;
	}
	RemoveEnemy(KilledPawn);

	B = Bot(Killer);
	if ( (B != None) && (B.Squad == self) && (B.Enemy == None) && (B.Pawn != None) && AllowTaunt(B) )
	{
		B.Target = KilledPawn;
		B.Celebrate();
	}
}

function bool FindNewEnemyFor(Bot B, bool bSeeEnemy)
{
	local int i;
	local Pawn BestEnemy, OldEnemy;
	local bool bSeeNew;
	local float BestThreat,NewThreat;

	if ( B.Pawn == None )
		return true;
	if ( (B.Enemy != None) && MustKeepEnemy(B.Enemy) && B.EnemyVisible() )
		return false;

	BestEnemy = B.Enemy;
	OldEnemy = B.Enemy;
	if ( BestEnemy != None )
	{
		if ( (BestEnemy.Health < 0) || (BestEnemy.Controller == None) )
		{
			B.Enemy = None;
			BestEnemy = None;
		}
		else
		{
			if ( ModifyThreat(0,BestEnemy,bSeeEnemy,B) > 5 )
				return false;
			BestThreat = AssessThreat(B,BestEnemy,bSeeEnemy);
		}
	}
	for ( i=0; i<ArrayCount(Enemies); i++ )
	{
		if ( (Enemies[i] != None) && (Enemies[i].Health > 0) && (Enemies[i].Controller != None) )
		{
			if ( BestEnemy == None )
			{
				BestEnemy = Enemies[i];
				bSeeEnemy = B.CanSee(Enemies[i]);
				BestThreat = AssessThreat(B,BestEnemy,bSeeEnemy);
			}
			else if ( Enemies[i] != BestEnemy )
			{
				if ( VSize(Enemies[i].Location - B.Pawn.Location) < 1500 )
					bSeeNew = B.LineOfSightTo(Enemies[i]);
				else
					bSeeNew = B.CanSee(Enemies[i]);	// only if looking at him
				NewThreat = AssessThreat(B,Enemies[i],bSeeNew);
				if ( NewThreat > BestThreat )
				{
					BestEnemy = Enemies[i];
					BestThreat = NewThreat;
					bSeeEnemy = bSeeNew;
				}
			}
		}
		else
			Enemies[i] = None;
	}
	B.Enemy = BestEnemy;
	if ( (B.Enemy != OldEnemy) && (B.Enemy != None) )
	{
		B.EnemyChanged(bSeeEnemy);
		return true;
	}
	return false;
}

/* ModifyThreat()
return a modified version of the threat value passed in for a potential enemy
*/
function float ModifyThreat(float current, Pawn NewThreat, bool bThreatVisible, Bot B)
{
	return current;
}

function bool UnderFire(Pawn NewThreat, Bot Ignored)
{
	local Bot B;

	for ( B=SquadMembers; B!=None; B=B.NextSquadMember )
	{
		if ( (B != Ignored) && (B.Pawn != None) && (B.Enemy == NewThreat) && (B.Focus == NewThreat)
			&& (VSize(Ignored.Pawn.Location - NewThreat.Location + NewThreat.Velocity) > VSize(B.Pawn.Location - NewThreat.Location + NewThreat.Velocity))
			&& B.EnemyVisible() )
			return true;
	}
	return false;
}

function float AssessThreat( Bot B, Pawn NewThreat, bool bThreatVisible )
{
	local float ThreatValue, NewStrength, Dist;

	NewStrength = B.RelativeStrength(NewThreat);
	ThreatValue = FClamp(NewStrength, 0, 1);
	Dist = VSize(NewThreat.Location - B.Pawn.Location);
	if ( Dist < 2000 )
	{
		ThreatValue += 0.2;
		if ( Dist < 1500 )
			ThreatValue += 0.2;
		if ( Dist < 1000 )
			ThreatValue += 0.2;
		if ( Dist < 500 )
			ThreatValue += 0.2;
	}

	if ( bThreatVisible )
		ThreatValue += 1;
	if ( (NewThreat != B.Enemy) && (B.Enemy != None) )
	{
		if ( !bThreatVisible )
			ThreatValue -= 5;
		else if ( Level.TimeSeconds - B.LastSeenTime > 2 )
			ThreatValue += 1;
		if ( Dist > 0.7 * VSize(B.Enemy.Location - B.Pawn.Location) )
			ThreatValue -= 0.25;
		ThreatValue -= 0.2;

		if ( B.IsHunting() && (NewStrength < 0.2)
			&& (Level.TimeSeconds - FMax(B.LastSeenTime,B.AcquireTime) < 2.5) )
			ThreatValue -= 0.3;
	}

	ThreatValue = ModifyThreat(ThreatValue,NewThreat,bThreatVisible,B);
	if ( NewThreat.IsHumanControlled() )
			ThreatValue += 0.25;

	//log(B.GetHumanReadableName()$" assess threat "$ThreatValue$" for "$NewThreat.GetHumanReadableName());
	return ThreatValue;
}

/*
Return true if squad should defer to C
*/
function bool ShouldDeferTo(Controller C)
{
	return ( C == SquadLeader );
}

/* WaitAtThisPosition()
Called by bot to see if its pawn should stay in this position
returns true if bot has human leader holding near this position
*/
function bool WaitAtThisPosition(Pawn P)
{
	if ( Bot(P.Controller).NeedWeapon() || (PlayerController(SquadLeader) == None) || (SquadLeader.Pawn == None) )
		return false;
	return CloseToLeader(P);
}

function bool WanderNearLeader(Bot B)
{
	if ( (Vehicle(B.Pawn) != None) || B.NeedWeapon() || (PlayerController(SquadLeader) == None) || (SquadLeader.Pawn == None) || !CloseToLeader(B.Pawn) )
		return false;
	if ( B.FindInventoryGoal(0.0005) )
		return true;
}

function bool NearFormationCenter(Pawn P)
{
	local Actor Center;

	Center = FormationCenter();
	if ( Center == None )
		return true;
	if ( Center == SquadLeader.Pawn )
	{
		if ( PlayerController(SquadLeader) != None )
			return CloseToLeader(P);
		else
			return false;
	}
	if ( VSize(Center.Location - P.Location) > GetRestingFormation().FormationSize )
		return false;
	return ( P.Controller.LineOfSightTo(Center) );
}

/* CloseToLeader()
Called by bot to see if his pawn is in an acceptable position relative to the squad leader
*/
function bool CloseToLeader(Pawn P)
{
	local float dist;

	if ( (P == None) || (SquadLeader.Pawn == None) )
		return true;

	if ( Vehicle(P) == None )
	{
		if ( (Vehicle(SquadLeader.Pawn) != None)
			&& (Vehicle(SquadLeader.Pawn).OpenPositionFor(P) != None) )
			return false;
	}
	else if ( (PlayerController(SquadLeader) != None)
		&& (Vehicle(SquadLeader.Pawn) == None) )
	{
		return false;
	}

	if ( (P.GetVehicleBase() == SquadLeader.Pawn)
		|| (SquadLeader.Pawn.GetVehicleBase() == P) )
		return true;

	// for certain games, have bots wait for leader for a while
	if ( (P.Base != None) && (SquadLeader.Pawn.Base != None) && (SquadLeader.Pawn.Base != P.Base) )
		return false;

	dist = VSize(P.Location - SquadLeader.Pawn.Location);
	if ( dist > GetRestingFormation().FormationSize )
		return false;

	// check if leader is moving away
	if ( PhysicsVolume.bWaterVolume )
	{
		if ( VSize(SquadLeader.Pawn.Velocity) > 0 )
			return false;
	}
	else if ( VSize(SquadLeader.Pawn.Velocity) > SquadLeader.Pawn.WalkingPct * SquadLeader.Pawn.GroundSpeed )
		return false;

	return ( P.Controller.LineOfSightTo(SquadLeader.Pawn) );
}

function MergeWith(SquadAI S)
{
	local Bot B,Prev;

	if ( S == self )
		return;

	for ( B=SquadMembers; B!=None; B=B.NextSquadMember )
	{
		if ( Prev != None )
			S.AddBot(Prev);
		Prev = B;
	}
	if ( Prev != None )
		S.AddBot(Prev);
	Destroy();
}

function Initialize(UnrealTeamInfo T, GameObjective O, Controller C)
{
	Team = T;
	SetLeader(C);
	SetObjective(O,false);
}

function SetAlternatePath(bool bResetSquad)
{
	local AssaultPath List[16];
	local int i,num;
	local AssaultPath A;
	local float sum,r;
	local bot S;

	AlternatePath = None;
	AlternatePathTag = 'None';
	if ( bResetSquad )
	{
		for ( S=SquadMembers; S!=None; S=S.NextSquadMember )
		{
			S.bFinalStretch = false;
			S.bReachedGatherPoint = false;
		}
	}

	for ( A=SquadObjective.AlternatePaths; A!=None; A=A.NextPath )
	{
		if ( A.bEnabled && A.bFirstPath && !A.bReturnOnly )
		{
			List[num] = A;
			num++;
			if ( num > 15 )
				break;
		}
	}

	//if ( (num < 2) && (Bot(SquadLeader) != None) && Bot(SquadLeader).bSoaking )
	//	Bot(SquadLeader).SoakStop("UNHAPPY BECAUSE THERE ARE ONLY "$num$" ASSAULTPATHS TO "$SquadObjective);

	if ( num > 0 )
	{
		for ( i=0; i<num; i++ )
			sum += List[i].Priority;
		r = FRand() * sum;
		sum = 0;
		for ( i=0; i<num; i++ )
		{
			sum += List[i].Priority;
			if ( r <= sum )
			{
				AlternatePath = List[i];
				AlternatePathTag = List[i].PickTag();
				return;
			}
		}
		AlternatePath = List[0];
		AlternatePathTag = List[0].PickTag();
	}
}

function bool TryToIntercept(Bot B, Pawn P, Actor RouteGoal)
{
	if ( (P == B.Enemy) && B.Pawn.RecommendLongRangedAttack() && (P != None) && B.LineOfSightTo(P) )
	{
		B.FightEnemy(false,0);
		return true;
	}

	if ( (P == None) || (NavigationPoint(RouteGoal) == None) || (B.Skill + B.Tactics < 4) )
		return FindPathToObjective(B,P);

	B.MoveTarget = None;
	if ( B.ActorReachable(P) )
	{
		B.GoalString = "almost to "$P;
		if ( B.Enemy != P )
			SetEnemy(B,P);
		if ( B.Enemy != None )
		{
			B.FightEnemy(true,0);
			return true;
		}
		else
		{
			log("Not attacking intercepted enemy!");
			B.MoveTarget = P;
			B.SetAttractionState();
			return true;
		}
	}
	B.MoveTarget = B.FindPathToIntercept(P,RouteGoal,true);
	if ( B.MoveTarget == None )
	{
		if ( P == B.Enemy )
		{
			B.FailedHuntEnemy = B.Enemy;
			B.FailedHuntTime = Level.TimeSeconds;
		}
	}
	else if ( B.Pawn.ReachedDestination(B.MoveTarget) )
		return false;
	return B.StartMoveToward(P);
}

/* FindPathToObjective()
Returns path a bot should use moving toward a base
*/
function bool FindPathToObjective(Bot B, Actor O)
{
	local Bot S;
	local float N, GatherWaitTime;
	local vehicle V;

	if ( B.Pawn.bStationary )
	{
		V = B.Pawn.getVehicleBase();
		if ( V == None )
		{
			V = Vehicle(B.Pawn);
			if ( V == None )
				return false;
		}
		if ( (DestroyableObjective(O) == None) && (SquadObjective.VehiclePath != None) && V.ReachedDestination(SquadObjective.VehiclePath) )
		{
			Vehicle(B.Pawn).TeamUseTime = Level.TimeSeconds + 12;
			Vehicle(B.Pawn).KDriverLeave(false);
		}
		else
			return false;
	}
	if ( O == None )
	{
		O = SquadObjective;
		if ( O == None )
		{
			B.GoalString = "No SquadObjective";
			return false;
		}
	}

	if ( (O == SquadObjective) && (Vehicle(B.Pawn) != None) && (SquadObjective.VehiclePath != None) )
	{
		if ( (DestroyableObjective(SquadObjective) == None) && B.Pawn.ReachedDestination(SquadObjective.VehiclePath) )
		{
			if ( Vehicle(B.Pawn).bKeyVehicle )
			{
				if ( Team.Size == Vehicle(B.Pawn).NumPassengers() )
				{
					Vehicle(B.Pawn).TeamUseTime = Level.TimeSeconds + 14;
					Vehicle(B.Pawn).bKeyVehicle = false;
					Vehicle(B.Pawn).KDriverLeave(false);
				}
				else
				{
					if ( B.Enemy != None )
					{
						B.FightEnemy(false, 0);
						return true;
					}
					else
					{
						B.GotoState('RestFormation','Pausing');
						return true;
					}
				}
			}
			else
			{
				Vehicle(B.Pawn).TeamUseTime = Level.TimeSeconds + 14;
				Vehicle(B.Pawn).KDriverLeave(false);
			}
		}
		else
			O = SquadObjective.VehiclePath;
	}

	if ( B.bFinalStretch || (O != SquadObjective) || SquadObjective.BotNearObjective(B) )
		return B.SetRouteToGoal(O);
	if ( (AlternatePath == None) || (AlternatePath.AssociatedObjective != SquadObjective) )
		SetAlternatePath(false);
	if ( AlternatePath == None )
		return B.SetRouteToGoal(O);

	B.MoveTarget = None;
	if ( B.ActorReachable(O) )
	{
		if ( B.Pawn.ReachedDestination(O) )
		{
			O.Touch(B.Pawn);
			return false;
		}
		B.RouteGoal = O;
		B.RouteCache[0] = None;
		B.GoalString = "almost at "$O;
		B.MoveTarget = O;
		B.SetAttractionState();
		return true;
	}

	if ( B.bReachedGatherPoint || B.Pawn.ReachedDestination(AlternatePath) )
	{
		B.GoalString = "Find path to "$O$" now near "$AlternatePath;
		B.MoveTarget = AlternatePath;
		if ( !B.bReachedGatherPoint )
		{
			B.bReachedGatherPoint = true;
			B.GatherTime = Level.TimeSeconds;
		}
		if ( (B.Enemy != None) && B.EnemyVisible() )
			GatherWaitTime = 3;
		else
			GatherWaitTime = 8;

		if ( (Level.TimeSeconds - B.GatherTime > GatherWaitTime) || (GatherThreshold < 1) )
			N = Size;
		else
		{
			// check if should update alternatepath, because squad has reached it
			for ( S=SquadMembers; S!=None; S=S.NextSquadMember )
				if ( (S.Pawn != None) && (S.bReachedGatherPoint || S.bFinalStretch) )
					N += 1;
		}
		if ( AlternatePath.bNoGrouping || (N/Size >= GatherThreshold) || (GatherThreshold < 1) )
		{
			for ( S=SquadMembers; S!=None; S=S.NextSquadMember )
				S.bReachedGatherPoint = false;
			AlternatePath = AlternatePath.FindNextPath(AlternatePathTag);
			if ( AlternatePath == None )
			{
				B.GoalString = "Final stretch to "$O;
				SetFinalStretch(true);
				B.FindBestPathToward(O,true,true);
			}
			else
				B.FindBestPathToward(AlternatePath,true,true);
			return B.StartMoveToward(O);
		}
		else if ( B.Enemy != None )
		{
			if ( B.LostContact(7) )
				B.LoseEnemy();
			if ( B.Enemy != None )
			{
				B.FightEnemy(false, 0);
				return true;
			}
		}
		B.GoalString = "Waiting for Squad";
		B.WanderOrCamp(true);
		return true;
	}
	else
	{
		B.GoalString = "Find path to "$O$" through "$AlternatePath;
		if ( !B.FindBestPathToward(AlternatePath,true,true) )
		{
			B.GoalString = "Find path to "$O$" no path to alternate path";
			if ( B.bSoaking && (Physics != PHYS_Falling) )
				B.SoakStop("COULDN'T FIND PATH TO ALTERNATEPATH "$AlternatePath);
			B.FindBestPathToward(O,true,true);
		}
		if ( B.MoveTarget == AlternatePath )
		{
			B.GatherTime = Level.TimeSeconds;
			B.bReachedGatherPoint = true;
		}
	}
	return B.StartMoveToward(O);
}

function SetFinalStretch(bool bValue)
{
	local Bot S;

	for ( S=SquadMembers; S!=None; S=S.NextSquadMember )
		S.bFinalStretch = bValue;
}

function SetLeader(Controller C)
{
	SquadLeader = C;
	if ( LeaderPRI != C.PlayerReplicationInfo )
	{
		LeaderPRI = TeamPlayerReplicationInfo(C.PlayerReplicationInfo);
		NetUpdateTime = Level.Timeseconds - 1;
	}
	if ( Bot(C) != None )
		AddBot(Bot(C));
}

function RemovePlayer(PlayerController P)
{
	local GameObjective NewObjective;
	if ( SquadLeader != P )
		return;
	if ( SquadMembers == None )
	{
		destroy();
		return;
	}

	NewObjective = Team.AI.GetPriorityAttackObjectiveFor(self);
	if ( NewObjective != SquadObjective )
	{
		SquadObjective = NewObjective;
		NetUpdateTime = Level.Timeseconds - 1;
	}
	PickNewLeader();
}

function RemoveBot(Bot B)
{
	local Bot Prev;

	if ( B.Squad != self )
		return;

	B.Squad = None;
	Size --;

	if ( SquadMembers == B )
	{
		SquadMembers = B.NextSquadMember;
		if ( SquadMembers == None )
		{
			destroy();
			return;
		}
	}
	else
	{
		for ( Prev=SquadMembers; Prev!=None; Prev=Prev.NextSquadMember )
			if ( Prev.NextSquadMember == B )
			{
				Prev.NextSquadMember = B.NextSquadMember;
				break;
			}
	}
	if ( SquadLeader == B )
		PickNewLeader();
}

function AddBot(Bot B)
{
	if ( B.Squad == self )
		return;
	if ( B.Squad != None )
		B.Squad.RemoveBot(B);

	Size++;

	B.NextSquadMember = SquadMembers;
	SquadMembers = B;
	B.Squad = self;
	if ( TeamPlayerReplicationInfo(B.PlayerReplicationInfo) != None )
		TeamPlayerReplicationInfo(B.PlayerReplicationInfo).Squad = self;
}

function SwitchBots(Bot MyBot, Bot OtherBot)
{
	local SquadAI OtherSquad;

	OtherSquad = OtherBot.Squad;
	if ( Size == 1 )
	{
		SquadMembers = None;
		MyBot.Squad = None;
		Size = 0;
	}

	OtherSquad.AddBot(MyBot);
	AddBot(OtherBot);
	if ( Size == 1 )
		PickNewLeader();
}

function SetDefenseScriptFor(Bot B)
{
	local UnrealScriptedSequence S;

	if ( (B.GoalScript != None) && SquadObjective.OwnsDefenseScript(B.GoalScript) && (!B.GoalScript.bNotInVehicle || Vehicle(B.Pawn) == None) )
	{
		if ( !B.bEnemyEngaged && !B.Pawn.ReachedDestination(B.GoalScript.GetMoveTarget()) )
			return;
		B.bEnemyEngaged = (B.Enemy != None);

		// possibly stay with same defense point if right on it
		if ( !B.GoalScript.bRoamingScript
			&& (B.bEnemyEngaged || B.GoalScript.bDontChangeScripts || ((FRand() < 0.85) && B.Pawn.ReachedDestination(B.GoalScript.GetMoveTarget()))) )
			return;
	}

	// log("SET NEW GOALSCRIPT FOR "$B.PlayerReplicationInfo.PlayerName);
	if ( B.GoalScript != None )
	{
		B.GoalScript.bAvoid = true;
		B.FreeScript();
	}
	for ( S=SquadObjective.DefenseScripts; S!=None; S=S.NextScript )
		if ( S.HigherPriorityThan(B.GoalScript, B) )
			B.GoalScript = S;

	if ( B.GoalScript != None )
		B.GoalScript.CurrentUser = B;
}

function SetFreelanceScriptFor(Bot B)
{
	local UnrealScriptedSequence S;

	// possibly stay with same defense point if right on it
	if ( (B.GoalScript != None)	&& !B.GoalScript.bRoamingScript
		&& (B.GoalScript.bDontChangeScripts || ((FRand() < 0.8)	&& B.Pawn.ReachedDestination(B.GoalScript.GetMoveTarget()))) )
		return;

	if ( B.GoalScript != None )
	{
		B.GoalScript.bAvoid = true;
		B.FreeScript();
	}
	// find a freelance script
	if ( FreelanceScripts == None )
		ForEach AllActors(class'UnrealScriptedSequence',S)
			if ( S.bFreelance && S.bFirstScript )
			{
				FreelanceScripts = S;
				break;
			}

	for ( S=FreelanceScripts; S!=None; S=S.NextScript )
		if ( S.HigherPriorityThan(B.GoalScript, B) )
			B.GoalScript = S;

	if ( B.GoalScript != None )
		B.GoalScript.CurrentUser = B;
}

function SetObjective(GameObjective O, bool bForceUpdate)
{
	local bot M;

	//Log(SquadLeader.PlayerReplicationInfo.PlayerName$" SET OBJECTIVE"@O@"Forced update"@bForceUpdate);
	if ( SquadObjective == O )
	{
		if ( SquadObjective == None )
			return;
		if ( (SquadObjective.DefenderTeamIndex == Team.TeamIndex) && (SquadObjective.DefenseSquad == None) )
			SquadObjective.DefenseSquad = self;
		if ( !bForceUpdate )
			return;
	}
	else
	{
		if ( (SquadObjective != None) && (SquadObjective.DefenderTeamIndex == Team.TeamIndex) && (SquadObjective.DefenseSquad == self) )
			SquadObjective.DefenseSquad = None;
		NetUpdateTime = Level.Timeseconds - 1;
		SquadObjective = O;
		if ( SquadObjective != None )
		{
			if ( (SquadObjective.DefenderTeamIndex == Team.TeamIndex) && (SquadObjective.DefenseSquad == None) )
					SquadObjective.DefenseSquad = self;
			SetAlternatePath(true);
		}
	}
	for	( M=SquadMembers; M!=None; M=M.NextSquadMember )
		if ( M.Pawn != None )
			Retask(M);
}

function Retask(bot B)
{
	if ( (Vehicle(B.Pawn) != None) && B.Pawn.bStationary && (Vehicle(B.Pawn).GetVehicleBase() == None) )
	{
		//get out of turrets when objective changes
		Vehicle(B.Pawn).KDriverLeave(false);
		B.bPreparingMove = false;
		B.MoveTarget = None; //so bot won't immediately get back in
		B.RouteGoal = None;
		B.WhatToDoNext(65);
	}
	else if ( B.InLatentExecution(B.LATENT_MOVETOWARD) )
	{
		if ( B.bPreparingMove )
		{
			B.bPreparingMove = false;
			B.WhatToDoNext(63);
		}
		else if ( (B.Pawn.Physics == PHYS_Falling) && (JumpSpot(B.Movetarget) != None) )
			return;
		else if ( (B.MoveTimer > 0.3) && (Vehicle(B.Pawn) == None) )
		{
			B.MoveTimer = 0.05 + 0.15 * FRand();
		}
	}
	else
	{
		B.RetaskTime = Level.TimeSeconds + 0.05 + 0.15 * FRand();
		GotoState('Retasking');
	}
}

State Retasking
{
	function Tick(float DeltaTime)
	{
		local Bot M;
		local bool bStillTicking;

		for	( M=SquadMembers; M!=None; M=M.NextSquadMember )
			if ( (M.Pawn != None) && (M.RetaskTime > 0) )
			{
				if ( Level.TimeSeconds > M.RetaskTime )
					M.WhatToDoNext(43);
				else
					bStillTicking = true;
			}

		if ( !bStillTicking )
			GotoState('');
	}
}

function name GetOrders()
{
	local name NewOrders;

	if ( PlayerController(SquadLeader) != None )
		NewOrders = 'Human';
	else if ( bFreelance && !bFreelanceAttack && !bFreelanceDefend )
		NewOrders = 'Freelance';
	else if ( (SquadObjective != None) && (SquadObjective.DefenderTeamIndex == Team.TeamIndex) )
		NewOrders = 'Defend';
	else
		NewOrders = 'Attack';
	if ( NewOrders != CurrentOrders )
	{
		NetUpdateTime = Level.Timeseconds - 1;
		CurrentOrders = NewOrders;
	}
	return CurrentOrders;
}

simulated function String GetOrderStringFor(TeamPlayerReplicationInfo PRI)
{
	if ( (LeaderPRI != None) && !LeaderPRI.bBot )
	{
		// FIXME - holding replication
		if ( PRI.bHolding )
			return HoldString;

		return SupportString@LeaderPRI.PlayerName@SupportStringTrailer;
	}
	if ( bFreelance || (SquadObjective == None) )
		return FreelanceString;
	else
	{
		GetOrders();
		if ( CurrentOrders == 'defend' )
			return DefendString@SquadObjective.GetHumanReadableName();
		if ( CurrentOrders == 'attack' )
			return AttackString@SquadObjective.GetHumanReadableName();
	}
	return string(CurrentOrders);
}

simulated function String GetShortOrderStringFor(TeamPlayerReplicationInfo PRI)
{
	if ( (LeaderPRI != None) && !LeaderPRI.bBot )
	{
		// FIXME - holding replication
		if ( PRI.bHolding )
			return HoldString;

		return SupportString;
	}
	if ( bFreelance || (SquadObjective == None) )
		return FreelanceString;
	else
	{
		GetOrders();
		if ( CurrentOrders == 'defend' )
			return DefendString;
		if ( CurrentOrders == 'attack' )
			return AttackString;
	}
	return string(CurrentOrders);
}

function int GetSize()
{
	if ( PlayerController(SquadLeader) != None )
		return Size + 1; // add 1 for leader
	else
		return Size;
}

function PickNewLeader()
{
	local Bot B;

	// FIXME - pick best based on distance to objective

	// pick a leader that isn't out of the game or in a vehicle turret
	for ( B=SquadMembers; B!=None; B=B.NextSquadMember )
		if ( !B.PlayerReplicationInfo.bOutOfLives && (B.Pawn == None || !B.Pawn.bStationary || B.Pawn.GetVehicleBase() == None) )
			break;

	if ( B == None )
	{
		for ( B=SquadMembers; B!=None; B=B.NextSquadMember )
			if ( !B.PlayerReplicationInfo.bOutOfLives )
				break;
	}
		
	if ( SquadLeader != B )
	{
		SquadLeader = B;
		if ( SquadLeader == None )
			LeaderPRI = None;
		else
			LeaderPRI = TeamPlayerReplicationInfo(SquadLeader.PlayerReplicationInfo);
		NetUpdateTime = Level.Timeseconds - 1;
	}
}

function bool TellBotToFollow(Bot B, Controller C)
{
	local Pawn Leader;
	local GameObjective O, Best;
	local float NewDist, BestDist;

	if ( (C == None) || C.bDeleteMe )
	{
		PickNewLeader();
		C = SquadLeader;
	}

	if ( B == C )
		return false;

	B.GoalString = "Follow Leader";
	Leader = C.Pawn;
	if ( Leader == None )
		return false;

	if ( CloseToLeader(B.Pawn) )
	{
		if ( !B.bInitLifeMessage )
		{
			B.bInitLifeMessage = true;
		  	B.SendMessage(SquadLeader.PlayerReplicationInfo, 'OTHER', B.GetMessageIndex('GOTYOURBACK'), 10, 'TEAM');
		}
		if ( B.Enemy == None )
		{
			// look for destroyable objective
			for ( O=Team.AI.Objectives; O!=None; O=O.NextObjective )
			{
				if ( !O.bDisabled && (DestroyableObjective(O) != None)
					&& ((Best == None) || (Best.DefensePriority < O.DefensePriority)) )
				{
					NewDist = VSize(B.Pawn.Location - O.Location);
					if ( ((Best == None) || (NewDist < BestDist)) && B.LineOfSightTo(O) )
					{
						Best = O;
						BestDist = NewDist;
					}
				}
			}
			if ( Best != None )
			{
				if (Best.DefenderTeamIndex != Team.TeamIndex)
				{
					if (Best.TellBotHowToDisable(B))
						return true;
				}
				else if (BestDist < 1600 && DestroyableObjective(Best).TellBotHowToHeal(B))
				return true;
			}

			if ( B.FindInventoryGoal(0.0004) )
			{
				B.SetAttractionState();
				return true;
			}
			B.WanderOrCamp(true);
			return true;
		}
		else if ( (B.Pawn.Weapon != None) && B.Pawn.Weapon.FocusOnLeader(false) )
		{
			B.FightEnemy(false,0);
			return true;
		}
		return false;
	}
	else if ( B.SetRouteToGoal(Leader) )
		return true;
	else
	{
		B.GoalString = "Can't reach leader";
		return false;
	}
}

function bool AllowTaunt(Bot B)
{
	return ( FRand() < 0.5 );
}

function AddTransientCosts(Bot B, float f)
{
	local Bot S;

	for ( S=SquadMembers; S!=None; S=S.NextSquadMember )
		if ( (S != B) && (NavigationPoint(S.MoveTarget) != None) && S.InLatentExecution(S.LATENT_MOVETOWARD) )
			NavigationPoint(S.MoveTarget).TransientCost = 1000 * f;
}

function bool AssignSquadResponsibility(Bot B)
{
	// set new defense script
	if ( (GetOrders() == 'Defend') && !B.Pawn.bStationary )
		SetDefenseScriptFor(B);
	else if ( (B.GoalScript != None) && (HoldSpot(B.GoalScript) == None) )
		B.FreeScript();

	AssignCombo(B);

	if ( bAddTransientCosts )
		AddTransientCosts(B,1);
	// check for major game objective responsibility
	if ( CheckSquadObjectives(B) )
		return true;

	if ( B.Enemy == None && !B.Pawn.bStationary )
	{
		// suggest inventory hunt
		// FIXME - don't load up on unnecessary ammo in DM
		if ( B.FindInventoryGoal(0) )
		{
			B.SetAttractionState();
			return true;
		}

		// roam around level?
		if ( ((B == SquadLeader) && bRoamingSquad) || (GetOrders() == 'Freelance') )
			return B.FindRoamDest();
	}
	return false;
}

function float MaxVehicleDist(Pawn P)
{
	return 3000;
}

function bool NeverBail(Pawn P)
{
	return ( (Vehicle(P) != None) && Vehicle(P).bKeyVehicle );
}

function BotEnteredVehicle(Bot B)
{
	if ( (PlayerController(SquadLeader) != None) )
	{
		if ( (SquadLeader.Pawn != None) && (B.Pawn.GetVehicleBase() == SquadLeader.Pawn) )
			B.SendMessage(None, 'OTHER', B.GetMessageIndex('INPOSITION'), 10, 'TEAM');
	}
	else if (B.Pawn.bStationary && B.Pawn.GetVehicleBase() != None)
		PickNewLeader();
}

/* go to squad vehicle (driven by squad leader - or squad leader objective), if nearby,
else try to find vehicle
*/
function bool CheckVehicle(Bot B)
{
	local Actor BestPath, BestEntry;
	local Vehicle SquadVehicle, V, MainVehicle;
	local float NewDist, BestDist, NewRating, BestRating, BaseRadius;
	local Bot S;
	local PlayerController PC;
	local bool bSkip;

	if ( (Vehicle(B.Pawn) == None) && (Vehicle(B.RouteGoal) != None) && (NavigationPoint(B.Movetarget) != None) )
	{
		if ( VSize(B.Pawn.Location - B.RouteGoal.Location) < B.Pawn.CollisionRadius + Vehicle(B.RouteGoal).EntryRadius * 1.5 )
			B.MoveTarget = B.RouteGoal;
	}
	if ( (Vehicle(B.Pawn) == None) && (Vehicle(B.MoveTarget) != None) )
	{
		if ( Vehicle(B.MoveTarget).PlayerStartTime > Level.TimeSeconds )
		{
			PC = Level.GetLocalPlayerController();
			bSkip = ( (PC != None) && (PC.PlayerReplicationInfo.Team == Team) && (PC.Pawn != None) && (Vehicle(PC.Pawn) == None) );
		}
		if ( !bSkip )
			V = Vehicle(B.MoveTarget).FindEntryVehicle(B.Pawn);
		if ( V != None )
		{
			//consider healing vehicle before getting in
			if ( !V.bKeyVehicle && (V.Health < V.HealthMax) && (B.Enemy == None || !B.EnemyVisible()) && B.CanAttack(V) )
			{
				//get in and out to steal vehicle for team so bot can heal it
				if (V.GetTeamNum() != Team.TeamIndex)
				{
					V.UsedBy(B.Pawn);
					V.KDriverLeave(false);
				}

				if (V.TeamLink(Team.TeamIndex))
				{
					if (B.Pawn.Weapon != None && B.Pawn.Weapon.CanHeal(V))
					{
						B.GoalString = "Heal "$V;
						B.DoRangedAttackOn(V.GetAimTarget());
						return true;
					}
					else
					{
						B.SwitchToBestWeapon();
						if (B.Pawn.PendingWeapon != None && B.Pawn.PendingWeapon.CanHeal(V))
						{
							B.GoalString = "Heal "$V;
							B.DoRangedAttackOn(V.GetAimTarget());
							return true;
						}
					}
				}
			}
			if ( V.GetVehicleBase() != None )
				BaseRadius = V.GetVehicleBase().CollisionRadius;
			else
				BaseRadius = V.CollisionRadius;
			if ( VSize(B.Pawn.Location - V.Location) < B.Pawn.CollisionRadius + BaseRadius + V.EntryRadius )
			{
				V.UsedBy(B.Pawn);
				if ( Vehicle(B.Pawn) != None )
					BotEnteredVehicle(B);
				return false;
			}
		}
	}
	if ( B.LastSearchTime == Level.TimeSeconds )
		return false;

	if ( Vehicle(B.Pawn) != None )
	{
		if ( !NeverBail(B.Pawn) )
		{
			if ( Vehicle(B.Pawn).StuckCount > 3 )
			{
				// vehicle is stuck
				Vehicle(B.Pawn).VehicleLostTime = Level.TimeSeconds + 20;
				Vehicle(B.Pawn).KDriverLeave(false);
				return false;
			}
			else if ( (B.Pawn.Health < B.Pawn.HealthMax*0.125) && !B.Pawn.bStationary && (B.Skill + B.Tactics > 4 + 7 * FRand()) )
			{
				//about to blow up, bail
				Vehicle(B.Pawn).VehicleLostTime = Level.TimeSeconds + 10;
				Vehicle(B.Pawn).KDriverLeave(false);
				return false;
			}
		}

		V = B.Pawn.GetVehicleBase();
		if ( (V != None) && !V.bKeyVehicle )
		{
			// if in passenger seat of a multi-person vehicle, get out if no driver
			if ( V.Driver == None && (SquadLeader == B || SquadLeader.RouteGoal == None
			     || (SquadLeader.RouteGoal != V && !SquadLeader.RouteGoal.IsJoinedTo(V))) )
			{
				Vehicle(B.Pawn).KDriverLeave(false);
				return false;
			}
		}

		if (!B.Pawn.bStationary && PriorityObjective(B) == 0)
			return CheckSpecialVehicleObjectives(B);

		return false;
	}
	if (SpecialVehicleObjective(B.RouteGoal) != None && CheckSpecialVehicleObjectives(B))
		return true;

	if ( (Vehicle(SquadLeader.Pawn) != None) && (VSize(SquadLeader.Pawn.Location - B.Pawn.Location) < 4000) )
	{
		SquadVehicle = Vehicle(SquadLeader.Pawn).OpenPositionFor(B.Pawn);
		if ( SquadVehicle != None )
			MainVehicle = Vehicle(SquadLeader.Pawn);
	}
	else if ( PlayerController(SquadLeader) != None )
		return false;

	BestDist = MaxVehicleDist(B.Pawn);
	if ( SquadVehicle == None )
	{
		for ( S=SquadMembers; S!=None; S=S.NextSquadMember )
			if ( (Vehicle(S.Pawn) != None) && (VSize(S.Pawn.Location - B.Pawn.Location) < BestDist) )
			{
				SquadVehicle = Vehicle(S.Pawn).OpenPositionFor(B.Pawn);
				if ( SquadVehicle != None )
					break;
			}
	}

	if ( (SquadVehicle == None) && (Vehicle(SquadLeader.RouteGoal) != None) && !Vehicle(SquadLeader.RouteGoal).Occupied()
	     && Vehicle(SquadLeader.Routegoal).IndependentVehicle() && VSize(SquadLeader.RouteGoal.Location - B.Pawn.Location) < BestDist )
		SquadVehicle = Vehicle(SquadLeader.RouteGoal).OpenPositionFor(B.Pawn);

	if ( (SquadVehicle == None) && (Vehicle(B.RouteGoal) != None) && !Vehicle(B.RouteGoal).Occupied() && Vehicle(B.RouteGoal).IndependentVehicle() 
		&& !Vehicle(B.RouteGoal).ChangedReservation(B.Pawn) )
		SquadVehicle = vehicle(B.RouteGoal);

	if ( (SquadVehicle != None) && (SquadVehicle.PlayerStartTime > Level.TimeSeconds) )
	{
		PC = Level.GetLocalPlayerController();
		if ( (PC != None) && (PC.PlayerReplicationInfo.Team == Team) && (PC.Pawn != None) && (Vehicle(PC.Pawn) == None) )
			SquadVehicle = None;
	}

	if ( SquadVehicle == None )
	{
		// look for nearby vehicle
		GetOrders();
		for ( V=Level.Game.VehicleList; V!=None; V=V.NextVehicle )
		{
			NewDist = VSize(B.Pawn.Location - V.Location);
			if (NewDist < BestDist)
			{
				NewRating = VehicleDesireability(V, B);
				if (NewRating > 0)
				{
					NewRating += BestDist / NewDist * 0.01;
					if ( NewRating > BestRating && ( V.bTeamLocked || V.StronglyRecommended(Self, Team.TeamIndex, SquadObjective)
									 || V.FastTrace(V.Location, B.Pawn.Location + B.Pawn.CollisionHeight * vect(0,0,1)) ) )
					{
						SquadVehicle = V;
						BestRating = NewRating;
					}
				}
			}
		}
	}

	if ( SquadVehicle == None )
		return false;

	BestEntry = SquadVehicle.GetMoveTargetFor(B.Pawn);

	if ( B.Pawn.ReachedDestination(BestEntry) )
	{
		SquadVehicle.UsedBy(B.Pawn);
		return false;
	}

	if ( B.ActorReachable(BestEntry) )
	{
		B.RouteGoal = SquadVehicle;
		B.MoveTarget = BestEntry;
		SquadVehicle.SetReservation(B);
		B.GoalString = "Go to vehicle 1 "$BestEntry;
		B.SetAttractionState();
		return true;
	}

	BestPath = B.FindPathToward(BestEntry,B.Pawn.bCanPickupInventory && (Vehicle(B.Pawn) == None));
	if ( BestPath != None )
	{
		B.RouteGoal = SquadVehicle;
		SquadVehicle.SetReservation(B);
		B.MoveTarget = BestPath;
		B.GoalString = "Go to vehicle 2 "$BestPath;
		B.SetAttractionState();
		return true;
	}

	if ( (VSize(BestEntry.Location - B.Pawn.Location) < 1200)
		&& B.LineOfSightTo(BestEntry) )
	{
		B.RouteGoal = SquadVehicle;
		SquadVehicle.SetReservation(B);
		B.MoveTarget = BestEntry;
		B.GoalString = "Go to vehicle 3 "$BestEntry;
		B.SetAttractionState();
		return true;
	}
	return false;
}

//return a value indicating how useful this vehicle is to the bot
function float VehicleDesireability(Vehicle V, Bot B)
{
	local float result;

	if ( !V.bCanCarryFlag && (B.PlayerReplicationInfo.HasFlag != None) )
		return 0;
	if ((CurrentOrders == 'Defend') != V.bDefensive)
		return 0;
	if (V.Health < V.HealthMax * 0.125 && B.Enemy != None && B.EnemyVisible())
		return 0;
	result = V.BotDesireability(self, Team.TeamIndex, SquadObjective);
	if ( V.SpokenFor(B) )
		return result * V.NewReservationCostMultiplier(B.Pawn);
	return result;
}

function bool CheckSpecialVehicleObjectives(Bot B)
{
	local UnrealMPGameInfo G;
	local SpecialVehicleObjective O, Best;

	G = UnrealMPGameInfo(Level.Game);
	if (G == None)
		return false;

	Best = SpecialVehicleObjective(B.RouteGoal);
	if (Best != None)
	{
		if (Vehicle(B.Pawn) == None)
		{
			if ( Best.bEnabled && !B.Pawn.ReachedDestination(Best.AssociatedActor)
			     && B.FindBestPathToward(Best.AssociatedActor, false, true) )
			{
				B.RouteGoal = Best;
				B.GoalString = "Reached SpecialVehicleObjective, now heading for "$B.RouteGoal;
				B.SetAttractionState();
				return true;
			}
			else
				return false;
		}
		else if ( !Best.IsAccessibleTo(B.Pawn) || Vehicle(B.Pawn).bKeyVehicle )
		{
			if (Team != None && Team.TeamIndex < 4 && Best.TeamOwner[Team.TeamIndex] == B.Pawn)
				Best.TeamOwner[Team.TeamIndex] = None;
			Best = None;
		}
	}

	if ( (Best == None) && ((Vehicle(B.Pawn) == None) || !Vehicle(B.Pawn).bKeyVehicle) )
		for (O = G.SpecialVehicleObjectives; O != None; O = O.NextSpecialVehicleObjective)
			if ( O.IsAccessibleTo(B.Pawn) && (Team == None || Team.TeamIndex >= 4 || O.TeamOwner[Team.TeamIndex] == None)
			     && (Best == None || FRand() < 0.5) )
				Best = O;

	if (Best != None)
	{
		if (B.Pawn.ReachedDestination(Best))
		{
			Vehicle(B.Pawn).KDriverLeave(false);
			if (B.FindBestPathToward(Best.AssociatedActor, false, true))
			{
				B.RouteGoal = Best;
				B.GoalString = "Reached SpecialVehicleObjective, now heading for "$Best.AssociatedActor;
				B.SetAttractionState();
				return true;
			}
		}

		if (B.ActorReachable(Best))
		{
			B.RouteGoal = Best;
			B.MoveTarget = Best;
			B.GoalString = "Head for reachable SpecialVehicleObjective "$Best;
			B.SetAttractionState();
			return true;
		}
		B.MoveTarget = B.FindPathToward(Best, B.Pawn.bCanPickupInventory && (Vehicle(B.Pawn) == None));
		if (B.MoveTarget != None)
		{
			B.RouteGoal = Best;
			B.GoalString = "Head for SpecialVehicleObjective "$Best;
			B.SetAttractionState();
			return true;
		}
	}

	return false;
}

function bool OverrideFollowPlayer(Bot B)
{
	local GameObjective PickedObjective;

	PickedObjective = Team.AI.GetPriorityAttackObjectiveFor(self);
	if ( (PickedObjective == None) )
		return false;
	if ( PickedObjective.BotNearObjective(B) )
	{
		if ( PickedObjective.DefenderTeamIndex == Team.TeamIndex )
		{
			if (DestroyableObjective(PickedObjective) != None)
				return DestroyableObjective(PickedObjective).TellBotHowToHeal(B);
			else
				return false;
		}
		else
			return PickedObjective.TellBotHowToDisable(B);
	}
	if ( PickedObjective.DefenderTeamIndex == Team.TeamIndex )
		return false;
	if ( (DestroyableObjective(PickedObjective) != None) && B.LineOfSightTo(PickedObjective) )
		return PickedObjective.TellBotHowToDisable(B);
	return false;
}

function bool CheckSquadObjectives(Bot B)
{
	local Actor DesiredPosition;
	local bool bInPosition, bMovingToSuperPickup;
	local float SuperDist;
	//local vehicle VBase;

	if ( (HoldSpot(B.GoalScript) == None) && CheckVehicle(B) )
		return true;

	// might have gotten out of vehicle and been killed
	if ( B.Pawn == None )
		return true;

	if ( B.NeedWeapon() && B.FindInventoryGoal(0) )
	{
		B.GoalString = "Need weapon or ammo";
		B.SetAttractionState();
		return true;
	}

	if ( (PlayerController(SquadLeader) != None) && (SquadLeader.Pawn != None) )
	{
		if ( HoldSpot(B.GoalScript) == None )
		{
			// attack objective if close by
			if ( OverrideFollowPlayer(B) )
				return true;

			// follow human leader
			return TellBotToFollow(B,SquadLeader);
		}
		// hold position as ordered (position specified by goalscript)
	}
	if ( ShouldDestroyTranslocator(B) )
		return true;

	if ( B.Pawn.bStationary && (Vehicle(B.Pawn) != None) )
	{
		if ( HoldSpot(B.GoalScript) != None )
		{
			if ( HoldSpot(B.GoalScript).HoldVehicle != B.Pawn )
				Vehicle(B.Pawn).KDriverLeave(false);
		}
		else if ( Vehicle(B.Pawn).StronglyRecommended(self, Team.TeamIndex, SquadObjective) )
		{
			if ( B.GoalScript != None )
				B.FreeScript();
			return false;
		}
	}
	// see if should get superweapon/ pickup
	if ( B.Pawn.bCanPickupInventory && (B.Skill > 1) && (HoldSpot(B.GoalScript) == None) && (Vehicle(B.Pawn) == None) )
	{
		if ( PriorityObjective(B) > 0 )
			SuperDist = 800;
		else if ( GetOrders() == 'Attack' )
			SuperDist = 3000;
		else if ( (GetOrders() == 'Defend') && (B.Enemy != None) )
			SuperDist = 1200;
		else
			SuperDist = 3200;
		bMovingToSuperPickup = ( (InventorySpot(B.RouteGoal) != None)
								&& InventorySpot(B.RouteGoal).bSuperPickup
								&& (B.RouteDist < 1.1*SuperDist)
								&& (InventorySpot(B.RouteGoal).markedItem != None)
								&&  InventorySpot(B.RouteGoal).markedItem.ReadyToPickup(2)
								&& (B.Desireability(InventorySpot(B.RouteGoal).markedItem) > 0) );
		if ( (bMovingToSuperPickup && B.FindBestPathToward(B.RouteGoal, false, true))
			||  (Team.AI.SuperPickupAvailable(B)
				&& (B.Pawn.Anchor != None) && B.Pawn.ReachedDestination(B.Pawn.Anchor)
				&& B.FindSuperPickup(SuperDist)) )
		{
			if ( Level.TimeSeconds - B.Pawn.SpawnTime > 5 )
				B.bFinalStretch = true;
			B.GoalString = "Get super pickup "$InventorySpot(B.RouteGoal).markedItem;
			B.SetAttractionState();
			return true;
		}
	}

	if ( B.GoalScript != None )
	{
		DesiredPosition = B.GoalScript.GetMoveTarget();
		bInPosition = (B.Pawn == DesiredPosition) || B.Pawn.ReachedDestination(DesiredPosition);
		if ( bInPosition && (Vehicle(DesiredPosition) != None) )
		{
			if ( (Vehicle(B.Pawn) != None) && (B.Pawn != DesiredPosition) )
				Vehicle(B.Pawn).KDriverLeave(false);
			if ( Vehicle(B.Pawn) == None )
				Vehicle(DesiredPosition).UsedBy(B.Pawn);
		}
		if ( bInPosition && B.GoalScript.bRoamingScript && (GetOrders() == 'Freelance') )
			return false;
		if ( !bInPosition )
			B.ClearScript();
	}
	else if ( SquadObjective == None )
		return TellBotToFollow(B,SquadLeader);
	else if ( GetOrders() == 'Freelance' )
		return false;
	else
	{
		if ( SquadObjective.DefenderTeamIndex != Team.TeamIndex )
		{
			if ( SquadObjective.bDisabled || !SquadObjective.bActive )
			{
				B.GoalString = "Objective already disabled";
				return false;
			}
			B.GoalString = "Disable Objective "$SquadObjective;
			/*if ( B.Pawn.bStationary )
			{
				VBase = B.Pawn.GetVehicleBase();
				if ( (VBase != None) && (VBase.Controller != None) )
					return false;
			}*/
			return SquadObjective.TellBotHowToDisable(B);
		}
		DesiredPosition = SquadObjective;
		bInPosition = ( (VSize(SquadObjective.Location - B.Pawn.Location) < 1200) && B.LineOfSightTo(SquadObjective) );
	}

	if ( B.Enemy != None )
	{
		if ( (B.GoalScript != None) && B.GoalScript.bRoamingScript )
		{
			B.GoalString = "Attack enemy freely";
			return false;
		}
		if ( B.LostContact(5) )
			B.LoseEnemy();
		if ( B.Enemy != None )
		{
			if ( B.EnemyVisible() || (Level.TimeSeconds - B.LastSeenTime < 3 && (SquadObjective == None || !SquadObjective.TeamLink(Team.TeamIndex))) )
			{
				B.FightEnemy(false, 0);
				return true;
			}
		}
	}
	if ( bInPosition )
	{
		B.GoalString = "Near "$DesiredPosition;
		if ( !B.bInitLifeMessage )
		{
			B.bInitLifeMessage = true;
			B.SendMessage(None, 'OTHER', B.GetMessageIndex('INPOSITION'), 10, 'TEAM');
		}

		if ( B.GoalScript != None )
			B.GoalScript.TakeOver(B.Pawn);
		else
		{
			if (DestroyableObjective(SquadObjective) != None && DestroyableObjective(SquadObjective).TellBotHowToHeal(B))
				return true;

			if (B.Enemy != None && (B.EnemyVisible() || Level.TimeSeconds - B.LastSeenTime < 3))
			{
				B.FightEnemy(false, 0);
				return true;
			}

			B.WanderOrCamp(true);
		}
		return true;
	}

	if (B.Pawn.bStationary)
		return false;

	B.GoalString = "Follow path to "$DesiredPosition;
	B.FindBestPathToward(DesiredPosition,false,true);
	if ( B.StartMoveToward(DesiredPosition) )
		return true;

	if ( (B.GoalScript != None) && (DesiredPosition == B.GoalScript) )
	{
		if ( (B.Pawn.Anchor != None) && B.Pawn.ReachedDestination(B.Pawn.Anchor) )
			log(B.PlayerReplicationInfo.PlayerName$" had no path to "$B.GoalScript$" from "$B.Pawn.Anchor);
		else
			log(B.PlayerReplicationInfo.PlayerName$" had no path to "$B.GoalScript);

		B.GoalScript.bAvoid = true;
		B.FreeScript();
		if ( (SquadObjective != None) && (VSize(B.Pawn.Location - SquadObjective.Location) > 1200) )
		{
			B.FindBestPathToward(SquadObjective,false,true);
			if ( B.StartMoveToward(SquadObjective) )
				return true;
		}
	}
	return false;
}

function bool ShouldDestroyTranslocator(Bot B)
{
	local UnrealMPGameInfo G;
	local TranslocatorBeacon T;

	if ( (Vehicle(B.Pawn) != None) || (B.Enemy != None) || (B.Skill < 2) )
		return false;
	G = UnrealMPGameInfo(Level.Game);
	if ( G == None )
		return false;

	for ( T=G.BeaconList; T!=None; T=T.NextBeacon )
	{
		if ( !T.Disrupted() && (T.Instigator != None) && (T.Instigator.Controller != None)
			&& !B.SameTeamAs(T.Instigator.Controller)
			&& (VSize(B.Pawn.Location - T.Location) < 1500)
			&& B.LineOfSightTo(T) )
		{
			B.GoalString = "Destroy Translocator";
			B.DoRangedAttackOn(T);
			return true;
		}
	}
	return false;
}

function float BotSuitability(Bot B)
{
	if ( class<UnrealPawn>(B.PawnClass) == None )
		return 0;

	if ( GetOrders() == 'Defend' )
		return (1.0 - class<UnrealPawn>(B.PawnClass).Default.AttackSuitability);
	return class<UnrealPawn>(B.PawnClass).Default.AttackSuitability;
}

/* PickBotToReassign()
pick a bot to lose
*/
function bot PickBotToReassign()
{
	local Bot B,Best;
	local float Val, BestVal;
	local float Suitability, BestSuitability;

	// pick bot furthest from SquadObjective, with highest suitability
	for	( B=SquadMembers; B!=None; B=B.NextSquadMember )
		if ( !B.PlayerReplicationInfo.bOutOfLives )
		{
			Val = VSize(B.Pawn.Location - SquadObjective.Location);
			if ( B == SquadLeader )
				Val -= 10000000.0;
			Suitability = BotSuitability(B);
			if ( (Best == None) || (Suitability > BestSuitability)
				|| ((Suitability == BestSuitability) && (Val > BestVal)) )
			{
				Best = B;
				BestVal = Val;
				BestSuitability = Suitability;
			}
		}
	return Best;
}

function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local string EnemyList;
	local int i;

	Canvas.SetDrawColor(255,255,255);
	if ( SquadObjective == None )
		Canvas.DrawText("     ORDERS "$GetOrders()$" on "$GetItemName(string(self))$" no objective. Leader "$SquadLeader.GetHumanReadableName(), false);
	else
		Canvas.DrawText("     ORDERS "$GetOrders()$" on "$GetItemName(string(self))$" objective "$GetItemName(string(SquadObjective))$". Leader "$SquadLeader.GetHumanReadableName(), false);

	YPos += YL;
	Canvas.SetPos(4,YPos);
	EnemyList = "     Enemies: ";
	for ( i=0; i<ArrayCount(Enemies); i++ )
		if ( Enemies[i] != None )
			EnemyList = EnemyList@Enemies[i].GetHumanReadableName();
	Canvas.DrawText(EnemyList, false);

	YPos += YL;
	Canvas.SetPos(4,YPos);
}

/* BeDevious()
return true if bot should use guile in hunting opponent (more expensive)
*/
function bool BeDevious()
{
	return false;
}

function bool PickRetreatDestination(Bot B)
{
	// FIXME - fall back to other squad members (furthest), or defense objective, or home base
	return B.PickRetreatDestination();
}

/* ClearPathForLeader()
make all squad members close to leader get out of his way
*/
function bool ClearPathFor(Controller C)
{
	local Bot B;
	local bool bForceDefer;
	local vector Dir;
	local float DirZ;

	bForceDefer = ShouldDeferTo(C);

	for ( B=SquadMembers; B!=None; B=B.NextSquadMember )
		if ( (B != C) && (B.Pawn != None) )
		{
			Dir = B.Pawn.Location - C.Pawn.Location;
			DirZ = Dir.Z;
			Dir.Z = 0;
			if ( (Abs(Dir.Z) < B.Pawn.CollisionHeight + C.Pawn.CollisionHeight)
				&& (VSize(Dir) < 8 * B.Pawn.CollisionRadius) )
			{
				if ( bForceDefer )
					B.ClearPathFor(C);
				else
					B.CancelCampFor(C);
			}
		}
	return bForceDefer;
}

function bool IsDefending(Bot B)
{
	if ( GetOrders() == 'Defend' )
		return true;

	return ( B.GoalScript != None );
}

/* CautiousAdvance()
return true if bot should advanced cautiously (crouched)
*/
function bool CautiousAdvance(Bot B)
{
	return false;
}

function bool FriendlyToward(Pawn Other)
{
	if ( Team == None )
		return false;
	return Team.AI.FriendlyToward(Other);
}

defaultproperties
{
     GatherThreshold=0.600000
     SupportString="supporting"
     DefendString="defending"
     AttackString="attacking"
     HoldString="holding"
     FreelanceString="Sweeper"
     MaxSquadSize=2
     bRoamingSquad=True
     RestingFormationClass=Class'UnrealGame.RestingFormation'
     NetUpdateFrequency=1.000000
}
