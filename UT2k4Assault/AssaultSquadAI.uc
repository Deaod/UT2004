class AssaultSquadAI extends SquadAI;

var Pawn FocusPawn;
var bool bVehicleEntriesInitialized;
var array<Trigger_ASUseAndRespawn> EntryTriggers;

function Reset()
{
	Super.Reset();

	FocusPawn = None;
}

function bool ShouldSuppressEnemy(Bot B)
{
	return ( (VSize(B.Pawn.Location - B.FocalPoint) > 300)
			&& (Level.TimeSeconds - B.LastSeenTime < 8) );
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
		{
			if ( SquadObjective.Objective_Info_Defender != SquadObjective.Default.Objective_Info_Defender )
				return SquadObjective.Objective_Info_Defender;
			return DefendString@SquadObjective.GetHumanReadableName();
		}
		if ( CurrentOrders == 'attack' )
		{
			if ( SquadObjective.Objective_Info_Attacker != SquadObjective.Default.Objective_Info_Attacker )
				return SquadObjective.Objective_Info_Attacker;
			return AttackString@SquadObjective.GetHumanReadableName();
		}
	}
	return string(CurrentOrders);
}

function bool NeverBail(Pawn P)
{
	if ( Team.Size == 1 )
		return false;
	if ( (Team.Size == 2) && P.bStationary )
		return false;
	return true;
}

function float MaxVehicleDist(Pawn P)
{
	if ( GetOrders() != 'Attack' )
		return 3000;
	if ( SquadObjective == None )
		return 8000;
	return FMin(8000, VSize(P.Location - SquadObjective.Location));
}

function Vehicle GetKeyVehicle(Bot B)
{
	local Vehicle V;

	if ( ASGameInfo(Level.Game).KeyVehicle != None )
		return ASGameInfo(Level.Game).KeyVehicle;

	V = Vehicle(SquadLeader.Pawn);
	if ( (V != None) && V.bKeyVehicle )
		ASGameInfo(Level.Game).KeyVehicle = V;

	if ( (V == None) || (B.Enemy == None) || V.bKeyVehicle )
		return V;

	return None;
}

function Vehicle GetLinkVehicle(Bot B)
{
	local Vehicle V;

	if ( (ASGameInfo(Level.Game).KeyVehicle != None) && B.SameTeamAs(ASGameInfo(Level.Game).KeyVehicle.Controller) )
		return ASGameInfo(Level.Game).KeyVehicle;

	if ( (SquadObjective != None) && (SquadObjective.DefenderTeamIndex == Team.TeamIndex) && (DestroyVehicleObjective(SquadObjective) != None)
	     && (DestroyVehicleObjective(SquadObjective).TargetVehicle != None) )
	     	return DestroyVehicleObjective(SquadObjective).TargetVehicle;

	V = Vehicle(SquadLeader.Pawn);
	if ( V == None )
		return None;
	if ( V.bKeyVehicle )
		ASGameInfo(Level.Game).KeyVehicle = V;

	if ( (B.Enemy == None) || Vehicle(SquadLeader.Pawn).bKeyVehicle )
		return Vehicle(SquadLeader.Pawn);
	return None;
}

function BotEnteredVehicle(Bot B)
{
	if ( PlayerController(SquadLeader) == None )
		PickNewLeader();
	Super.BotEnteredVehicle(B);
}

// don't actually merge squads in assault
function MergeWith(SquadAI S)
{
	if ( SquadObjective != S.SquadObjective )
	{
		SquadObjective = S.SquadObjective;
		NetUpdateTime = Level.Timeseconds - 1;
	}
}

function PickNewLeader()
{
	local Bot B;

	for ( B=SquadMembers; B!=None; B=B.NextSquadMember )
		if ( (Vehicle(B.Pawn) != None) && !B.Pawn.bStationary )
			break;

	if ( B == None )
	{
		// pick a leader that isn't out of the game
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

function bool AssignSquadResponsibility(Bot B)
{
	local Trigger_ASUseAndRespawn T,Best;
	local float BestDist, NewDist;
	local int i;
	local Controller C;
	local class<Pawn> FocusPawnClass;

	if ( (SquadObjective == None) || SquadObjective.bDisabled || !SquadObjective.bActive || !UnrealMPGameInfo(Level.Game).CanDisableObjective( SquadObjective ) )
 	{
		Team.AI.FindNewObjectiveFor(self,true);
		if ( (SquadObjective == None) || SquadObjective.bDisabled || !SquadObjective.bActive )
		{
			if ( (PlayerController(SquadLeader) != None) && (HoldSpot(B.GoalScript) == None) )
			{
				if (CheckVehicle(B))
					return true;
				return TellBotToFollow(B,SquadLeader);
			}
			if ( B.Enemy == None && !B.Pawn.bStationary )
			{
				// suggest inventory hunt
				if ( B.FindInventoryGoal(0) )
				{
					B.SetAttractionState();
					return true;
				}
			}
			return false;
		}
	}

	if ( (Vehicle(B.Pawn) != None) && !B.Pawn.bStationary && Vehicle(B.Pawn).bKeyVehicle && (SquadObjective.DefenderTeamIndex != Team.TeamIndex) )
	{
		if ( SquadObjective.bDisabled || !SquadObjective.bActive )
		{
			B.GoalString = "Objective already disabled";
			return false;
		}
		B.GoalString = "Disable Objective "$SquadObjective;
		return SquadObjective.TellBotHowToDisable(B);
	}

	// hack for getting into spacefighters
	if ( SquadObjective.bMustBoardVehicleFirst )
	{
		if ( Vehicle(B.Pawn) == None )
		{
			if ( Trigger_ASUseAndRespawn(B.RouteGoal) != None )
			{
				if ( B.Pawn.ReachedDestination(B.RouteGoal) )
				{
					Trigger_ASUseAndRespawn(B.RouteGoal).UsedBy(B.Pawn);
					B.GoalString = "Getting in vehicle";
					return Super.AssignSquadResponsibility(B);
				}
			}
			else
			{
				if ( !bVehicleEntriesInitialized )
				{
					bVehicleEntriesInitialized = true;
					ForEach DynamicActors(class'Trigger_ASUseAndRespawn', T)
						EntryTriggers[EntryTriggers.Length] = T;
				}
				for ( i=0; i<EntryTriggers.Length; i++ )
				{
					T = EntryTriggers[i];

					if ( Level.TimeSeconds > T.LastFailTime )
					{
						NewDist = VSize(B.Pawn.Location - T.Location);
						if ( (Best == None) || (NewDist < BestDist)  )
						{
							Best = T;
							BestDist = NewDist;
						}
					}
				}
				B.RouteGoal = Best;
			}
			if ( B.RouteGoal != None )
			{
				B.MoveTarget = B.FindPathToward(B.RouteGoal, false);
				if ( B.MoveTarget != None )
				{
					B.GoalString = "Move to vehicle entry trigger "$B.RouteGoal;
					B.SetAttractionState();
					return true;
				}
				else
				{
					Trigger_ASUseAndRespawn(B.RouteGoal).LastFailTime = Level.TimeSeconds + 10;
				}
			}
		}
		else if ( B.Pawn.bThumped && (B.Enemy != None) && (ProximityObjective(SquadObjective) == None) )
			return false;
		else if ( GetOrders() == 'Defend' )
		{
			if ( B.Enemy == None )
			{
				for ( i=0; i<ArrayCount(Enemies); i++ )
					if ( Enemies[i] != None )
					{
						SetEnemy(B,Enemies[i]);
						if ( B.Enemy != None )
							break;
					}
				if ( B.Enemy == None )
				{
					for ( C=Level.ControllerList; C!=None; C=C.NextController )
						if ( (C.Pawn != None) && C.bIsPlayer && !C.SameTeamAs(B) )
						{
							SetEnemy(B,C.Pawn);
							if ( B.Enemy != None )
								break;
						}
				}
			}
			return false;
		}
	}

	FocusPawnClass = ObjectiveConstraintClass();
	FocusPawn = GetKeyVehicle(B);

	if ( (FocusPawn != None) && (B.Pawn != FocusPawn) && (FocusPawnClass != None)
		&& ClassIsChildOf(FocusPawn.Class,FocusPawnClass) && !ClassIsChildOf(B.Pawn.Class,FocusPawnClass) )
	{
		if ( GetOrders() == 'ATTACK' )
		{
			if ( FocusPawn.Controller != None )
			{
				B.GoalString = "Support Key Vehicle";
				if ( (B.Pawn.Weapon != None) && B.Pawn.Weapon.FocusOnLeader(false) )
					B.FireWeaponAt(B.Focus);
				if ( (B.Pawn.GetVehicleBase() == FocusPawn)
				     || ((VSize(FocusPawn.Location - B.Pawn.Location) < 800) && (VSize(FocusPawn.Velocity) < 100)) )
					return false;
				B.FindBestPathToward(FocusPawn,false,true);
				if ( B.StartMoveToward(FocusPawn) )
					return true;
			}
		}
		else if ( B.Enemy == None )
		{
			if ( FocusPawn.Controller == None )
			{
				B.GoalString = "Attack Key Vehicle";
				if ( B.CanAttack(FocusPawn) )
				{
					B.DoRangedAttackOn(FocusPawn);
					return true;
				}
				B.FindBestPathToward(FocusPawn,false,true);
				if ( B.StartMoveToward(FocusPawn) )
					return true;
			}
			else
			{
				B.GoalString = "Fight Key Vehicle";
				SetEnemy(B,FocusPawn);
			}
			if ( B.Enemy == FocusPawn )
				return false;
		}
		else if ( B.Enemy == FocusPawn )
			return false;
	}
	return Super.AssignSquadResponsibility(B);
}

function class<Pawn> ObjectiveConstraintClass()
{
	if ( DestroyableObjective(SquadObjective) != None )
		return DestroyableObjective(SquadObjective).ConstraintPawnClass;
	if ( ProximityObjective(SquadObjective) != None )
		return ProximityObjective(SquadObjective).ConstraintPawnClass;
	return None;
}

function bool MustKeepEnemy(Pawn E)
{
	if ( (E.PlayerReplicationInfo != None) && (E.PlayerReplicationInfo.HasFlag != None) )
		return true;
	if ( (SquadObjective != None) && SquadObjective.NearObjective(E) )
		return true;
	if ( (Vehicle(E) != None) && Vehicle(E).bKeyVehicle )
		return true;
	return false;
}

function byte PriorityObjective(Bot B)
{
	if ( B.PlayerReplicationInfo.HasFlag != None )
		return 2;
	if ( (Vehicle(B.Pawn) != None) && Vehicle(B.Pawn).bKeyVehicle )
		return 2;
	return 0;
}

function float ModifyThreat(float current, Pawn NewThreat, bool bThreatVisible, Bot B)
{
	local class<Pawn> FocusPawnClass;

	if ( GetOrders() == 'Defend' )
	{
		FocusPawnClass = ObjectiveConstraintClass();
		if ( (FocusPawnClass != None) && !ClassIsChildOf(NewThreat.Class,FocusPawnClass) )
			return current - 0.5;
	}

	if ( bThreatVisible && (NewThreat.PlayerReplicationInfo != None)
		&& ((NewThreat.PlayerReplicationInfo.HasFlag != None) || ((Vehicle(NewThreat) != None) && Vehicle(NewThreat).bKeyVehicle)) )
	{
		if ( (VSize(B.Pawn.Location - NewThreat.Location) < 2500) || B.Pawn.Weapon.bSniping )
			return current + 6;
		else
			return current + 1.5;
	}
	else if ( (SquadObjective != None) && (SquadObjective.DefenderTeamIndex == Team.TeamIndex)
			&& (SquadObjective.MyBaseVolume != None) && NewThreat.IsInVolume(SquadObjective.MyBaseVolume) )
		return current + 1.5;
	else if ( NewThreat.IsHumanControlled() )
		return current + 0.5;
	else if ( NewThreat.bStationary && bThreatVisible )
		return current + 0.3;
	else
		return current;
}

function name GetOrders()
{
	bFreelanceAttack = true;
	return Super.GetOrders();
}

function float AssessThreat( Bot B, Pawn NewThreat, bool bThreatVisible )
{
	local float ThreatValue, Dist;

	if ( (Vehicle(B.Pawn) == None) || !Vehicle(B.Pawn).bKeyVehicle )
		return Super.AssessThreat(B, NewThreat, bThreatVisible);

	ThreatValue = 1;
	Dist = VSize(NewThreat.Location - B.Pawn.Location);
	if ( Dist < 4000 )
	{
		ThreatValue += 0.2;
		if ( Dist < 2500 )
			ThreatValue += 0.2;
		if ( Dist < 1500 )
			ThreatValue += 0.2;
		if ( Dist < 1000 )
			ThreatValue += 0.2;
	}

	if ( bThreatVisible )
		ThreatValue += 3;
	if ( (NewThreat != B.Enemy) && (B.Enemy != None) )
	{
		if ( !bThreatVisible )
			ThreatValue -= 5;
		else if ( Level.TimeSeconds - B.LastSeenTime > 2 )
			ThreatValue += 1;
		ThreatValue -= 0.5;
	}

	ThreatValue = ModifyThreat(ThreatValue,NewThreat,bThreatVisible,B);
	return ThreatValue;
}

defaultproperties
{
     GatherThreshold=0.000000
     MaxSquadSize=3
     bRoamingSquad=False
     bAddTransientCosts=True
}
