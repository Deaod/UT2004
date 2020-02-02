class CTFSquadAI extends SquadAI;

var float LastSeeFlagCarrier;
var CTFFlag FriendlyFlag, EnemyFlag;
var AssaultPath ReturnPath;	// alternate path to use by flag carrier returning to base
var name ReturnPathTag;
var NavigationPoint HidePath;

function AssignCombo(Bot B)
{
	if ( GetOrders() != 'Attack' )
		Super.AssignCombo(B);
}

function bool AllowDetourTo(Bot B,NavigationPoint N)
{
	if ( B.PlayerReplicationInfo.HasFlag != EnemyFlag )
		return true;

	if ( (B.RouteGoal != FriendlyFlag.HomeBase) || !FriendlyFlag.bHome )
		return true;
	return ( N.LastDetourWeight * B.RouteDist > 2 );
}

/* FindPathToObjective()
Returns path a bot should use moving toward a base
*/
function bool FindPathToObjective(Bot B, Actor O)
{
	if ( (Vehicle(B.Pawn) != None) && ((CTFFlag(O) != None) || (CTFBase(O) != None))
		&& (VSize(B.Pawn.Location - O.Location) < 1000) && B.LineOfSightTo(O) )
	{
		B.FormerVehicle = Vehicle(B.Pawn);
		Vehicle(B.Pawn).TeamUseTime = Level.TimeSeconds + 6;
		Vehicle(B.Pawn).KDriverLeave(false);
		if ( (Vehicle(B.Pawn) == None) && (B.Pawn.Physics == PHYS_Falling) && B.DoWaitForLanding() )
		{
			B.Pawn.Velocity.Z = 0;
			return true;
		}
	}

	if ( (B.PlayerReplicationInfo.HasFlag != EnemyFlag) || (O != FriendlyFlag.HomeBase) )
		return Super.FindPathToObjective(B, O);

	if ( B.bFinalStretch || (ReturnPath == None) || ((O == SquadObjective) && SquadObjective.BotNearObjective(B)) )
		return B.SetRouteToGoal(O);

	B.MoveTarget = None;
	if ( B.ActorReachable(O) )
	{
		if ( (Vehicle(B.Pawn) != None) && (B.Pawn.Location.Z - O.Location.Z < 500) && ((CTFFlag(O) != None) || (CTFBase(O) != None)) )
			Vehicle(B.Pawn).KDriverLeave(false);
		if ( B.Pawn.ReachedDestination(O) )
		{
			O.Touch(B.Pawn);
			return false;
		}
		B.RouteGoal = O;
		B.RouteCache[0] = None;
		B.GoalString = B.GoalString@"almost at "$O;
		B.MoveTarget = O;
		B.bFinalStretch = true;
		B.SetAttractionState();
		return true;
	}

	if ( B.Pawn.ReachedDestination(ReturnPath) )
	{
		B.GoalString = B.GoalString@"Find path to "$O$" now near "$ReturnPath;
		B.MoveTarget = ReturnPath;
		ReturnPath = ReturnPath.FindPreviousPath(ReturnPathTag);
		if ( ReturnPath == None )
		{
			B.bFinalStretch = true;
			B.FindBestPathToward(O,true,true);
		}
		else
			B.FindBestPathToward(ReturnPath,true,true);
	}
	else
	{
		B.GoalString = B.GoalString@"Find path to "$O$" through "$ReturnPath;
		if ( !B.FindBestPathToward(ReturnPath,true,true) )
		{
			B.GoalString = B.GoalString@"Find path to "$O$" no path to ReturnPath";
			if ( B.bSoaking && (Physics != PHYS_Falling) )
				B.SoakStop("COULDN'T FIND PATH TO RETURNPATH "$ReturnPath);
			B.FindBestPathToward(O,true,true);
		}
	}
	return B.StartMoveToward(O);
}

function bool AllowTranslocationBy(Bot B)
{
	return ( B.Pawn != EnemyFlag.Holder );
}

/* GoPickupFlag()
have bot go pickup dropped friendly flag
*/
function bool GoPickupFlag(Bot B)
{
	if ( FindPathToObjective(B,FriendlyFlag) )
	{
		if ( Level.TimeSeconds - CTFTeamAI(Team.AI).LastGotFlag > 6 )
		{
			CTFTeamAI(Team.AI).LastGotFlag = Level.TimeSeconds;
			B.SendMessage(None, 'OTHER', B.GetMessageIndex('GOTOURFLAG'), 20, 'TEAM');
		}
		B.GoalString = "Pickup friendly flag";
		return true;
	}
	return false;
}

function actor FormationCenter()
{
	if ( (SquadObjective != None) && (SquadObjective.DefenderTeamIndex == Team.TeamIndex) )
		return SquadObjective;
	if ( (EnemyFlag.Holder != None) && (GetOrders() != 'Defend') && !SquadLeader.IsA('PlayerController') )
		return EnemyFlag.Holder;
	return SquadLeader.Pawn;
}

function bool VisibleToEnemiesOf(Actor A, Bot B)
{
	if ( (B.Enemy != None) && FastTrace(A.Location, B.Enemy.Location + B.Enemy.CollisionHeight * vect(0,0,1)) )
		return true;
	return false;
}

function NavigationPoint FindHidePathFor(Bot B)
{
	local NavigationPoint N;
	local InventorySpot Best;
	local float NewD, BestD;
	local int MyTeamNum, EnemyTeamNum;

	MyTeamNum = Team.TeamIndex;
	if ( MyTeamNum == 0 )
		EnemyTeamNum = 1;

	// look for nearby inventory
	// stay away from enemies, and enemy base
	// don't go too far

	For ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		if ( (InventorySpot(N) != None)
			&& (N.BaseVisible[EnemyTeamNum] == 0)
			&& (N.BaseDist[MyTeamNum] < FMin(2400,0.7*N.BaseDist[EnemyTeamNum])) )
		{
			if ( Best == None )
			{
				if ( !VisibleToEnemiesOf(N,B) )
				{
					Best = InventorySpot(N);
					if ( (Best.markedItem != None) && Best.markedItem.ReadyToPickup(3) )
						BestD = Best.markedItem.BotDesireability(B.Pawn);
				}
			}
			else if ( ((Best.markedItem == None) || !Best.markedItem.ReadyToPickup(3)) && (InventorySpot(N).markedItem != None) )
			{
				if ( (InventorySpot(N).markedItem.ReadyToPickup(3) || (FRand() < 0.5))
					&& !VisibleToEnemiesOf(N,B)  )
				{
					Best = InventorySpot(N);
					BestD = Best.markedItem.BotDesireability(B.Pawn);
				}
			}
			else if ( (InventorySpot(N).markedItem != None) && InventorySpot(N).markedItem.ReadyToPickup(3) )
			{
				NewD = InventorySpot(N).markedItem.BotDesireability(B.Pawn);
				if ( (NewD > BestD) && !VisibleToEnemiesOf(N,B) )
				{
					Best = InventorySpot(N);
					BestD = NewD;
				}
			}
		}
	return Best;
}

function bool CheckVehicle(Bot B)
{
	if ( (EnemyFlag.Holder == None) && (VSize(B.Pawn.Location - EnemyFlag.Position().Location) < 1600) )
		return false;
	if ( (B.PlayerReplicationInfo.HasFlag != None) && (VSize(B.Pawn.Location - FriendlyFlag.HomeBase.Location) < 1600) )
		return false;

	return Super.CheckVehicle(B);
}

/* OrdersForFlagCarrier()
Tell bot what to do if he's carrying the flag
*/
function bool OrdersForFlagCarrier(Bot B)
{
	if ( CheckVehicle(B) )
	{
		B.GoalString = "Go to vehicle";
		B.SetAttractionState();
		return true;
	}

	if ( B.Pawn.Health < 40 )
		B.TryCombo("xGame.ComboDefensive");
	else
		B.TryCombo("xGame.ComboSpeed");

	// pickup dropped flag if see it nearby
	// FIXME - don't use pure distance - also check distance returned from pathfinding
	if ( !FriendlyFlag.bHome )
	{
		// if one-on-one ctf, then get flag back
		if ( Team.Size == 1 )
		{
			// make sure healthed/armored/ammoed up
			if ( B.NeedWeapon() && B.FindInventoryGoal(0) )
			{
				B.SetAttractionState();
				return true;
			}

			if ( FriendlyFlag.Holder == None )
			{
				if ( GoPickupFlag(B) )
					return true;
				return false;
			}
			else
			{
				if ( (B.Enemy != None) && (B.Enemy.PlayerReplicationInfo != None) && (B.Enemy.PlayerReplicationInfo.HasFlag != FriendlyFlag) )
					FindNewEnemyFor(B,(B.Enemy != None) && B.LineOfSightTo(B.Enemy));
				if ( Level.TimeSeconds - LastSeeFlagCarrier > 6 )
					LastSeeFlagCarrier = Level.TimeSeconds;
				B.GoalString = "Attack enemy flag carrier";
				if ( B.IsSniping() )
					return false;
				B.bPursuingFlag = true;
				return ( TryToIntercept(B,FriendlyFlag.Holder,EnemyFlag.Homebase) );
			}
		}
		// otherwise, only get if convenient
		if ( (FriendlyFlag.Holder == None) && B.LineOfSightTo(FriendlyFlag.Position())
			&& (VSize(B.Pawn.Location - FriendlyFlag.Location) < 1500.f)
			&& GoPickupFlag(B) )
			return true;

		// otherwise, go hide
		if ( HidePath != None )
		{
			if ( B.Pawn.ReachedDestination(HidePath) )
			{
				if ( ((B.Enemy == None) || (Level.TimeSeconds - B.LastSeenTime > 7)) && (FRand() < 0.7) )
				{
					HidePath = None;
					if ( B.Enemy == None )
						B.WanderOrCamp(true);
					else
						B.DoStakeOut();
					return true;
				}
			}
			else if ( B.SetRouteToGoal(HidePath) )
				return true;
		}
	}
	else 
		B.bPursuingFlag = false;
	HidePath = None;

	// super pickups if nearby
	// see if should get superweapon/ pickup
	if ( (B.Skill > 2) && (Vehicle(B.Pawn) == None) )
	{
		if ( (!FriendlyFlag.bHome || (VSize(FriendlyFlag.HomeBase.Location - B.Pawn.Location) > 2000))
				&& Team.AI.SuperPickupAvailable(B)
				&& (B.Pawn.Anchor != None) && B.Pawn.ReachedDestination(B.Pawn.Anchor)
				&& B.FindSuperPickup(800) )
		{
			B.GoalString = "Get super pickup";
			B.SetAttractionState();
			return true;
		}
	}

	if ( (B.Enemy != None) && (B.Pawn.Health < 60 ))
		B.SendMessage(None, 'OTHER', B.GetMessageIndex('NEEDBACKUP'), 25, 'TEAM');
	B.GoalString = "Return to Base with enemy flag!";
	if ( !FindPathToObjective(B,FriendlyFlag.HomeBase) )
	{
		B.GoalString = "No path to home base for flag carrier";
		// FIXME - suicide after a while
		return false;
	}
	if ( B.MoveTarget == FriendlyFlag.HomeBase )
	{
		B.GoalString = "Near my Base with enemy flag!";
		if ( !FriendlyFlag.bHome )
		{
			B.SendMessage(None, 'OTHER', B.GetMessageIndex('NEEDOURFLAG'), 25, 'TEAM');
			B.GoalString = "NEED OUR FLAG BACK!";
			if ( B.Skill > 1 )
				HidePath = FindHidePathFor(B);
			if ( (HidePath != None) && B.SetRouteToGoal(HidePath) )
				return true;
			return false;
		}
		if ( VSize(B.Pawn.Location - FriendlyFlag.Location) < FriendlyFlag.HomeBase.CollisionRadius )
			FriendlyFlag.Touch(B.Pawn);
	}
	return true;
}

function bool MustKeepEnemy(Pawn E)
{
	if ( (E != None) && (E.PlayerReplicationInfo != None) && (E.PlayerReplicationInfo.HasFlag == FriendlyFlag) && (E.Health > 0) )
		return true;
	return false;
}

function bool NearEnemyBase(Bot B)
{
	if ( (B.Pawn.Region.Zone == EnemyFlag.HomeBase.Region.Zone)
		&& (B.Pawn.Region.Zone != FriendlyFlag.HomeBase.Region.Zone)
		&& (FriendlyFlag.bHome || (B.Pawn.Region.Zone != FriendlyFlag.Position().Region.Zone)) )
		return true;

	return EnemyFlag.Homebase.BotNearObjective(B);
}

function bool NearHomeBase(Bot B)
{
	if ( (B.Pawn.Region.Zone == FriendlyFlag.HomeBase.Region.Zone)
		&& (B.Pawn.Region.Zone != EnemyFlag.HomeBase.Region.Zone) )
		return true;

	if ( !FriendlyFlag.bHome
		&& (B.Pawn.Region.Zone == FriendlyFlag.Position().Region.Zone)
		&& (FriendlyFlag.HomeBase.Region.Zone != EnemyFlag.HomeBase.Region.Zone) )
		return true;

	return FriendlyFlag.Homebase.BotNearObjective(B);
}

function bool FlagNearBase()
{
	if ( Level.TimeSeconds - FriendlyFlag.TakenTime < FriendlyFlag.HomeBase.BaseExitTime )
		return true;

	if ( (FriendlyFlag.Position().Region.Zone == FriendlyFlag.HomeBase.Region.Zone)
		&& (FriendlyFlag.HomeBase.Region.Zone != EnemyFlag.HomeBase.Region.Zone) )
		return true;

	return ( VSize(FriendlyFlag.Position().Location - FriendlyFlag.HomeBase.Location) < FriendlyFlag.HomeBase.BaseRadius );
}

function bool OverrideFollowPlayer(Bot B)
{
	if ( !EnemyFlag.bHome )
		return false;
		
	if ( EnemyFlag.HomeBase.BotNearObjective(B) )
		return EnemyFlag.HomeBase.TellBotHowToDisable(B);
	return false;
}

function bool CheckSquadObjectives(Bot B)
{
	local bool bSeeFlag;
	local actor FlagCarrierTarget;
	local controller FlagCarrier;

	if ( B.PlayerReplicationInfo.HasFlag == EnemyFlag  )
		return OrdersForFlagCarrier(B);

	AddTransientCosts(B,1);
	if ( !FriendlyFlag.bHome  )
	{
		bSeeFlag = B.LineOfSightTo(FriendlyFlag.Position());
		if ( Team.Size == 1 )
		{
			if ( B.NeedWeapon() && B.FindInventoryGoal(0) )
			{
				B.SetAttractionState();
				return true;
			}

			// keep attacking if 1-0n-1
			if ( (FriendlyFlag.Holder != None) || (VSize(B.Pawn.Location - FriendlyFlag.Position().Location) > VSize(B.Pawn.Location - EnemyFlag.Position().Location)) )
				return FindPathToObjective(B,EnemyFlag.Position());
		}
		if ( bSeeFlag )
		{
			if ( FriendlyFlag.Holder == None )
			{
				if ( GoPickupFlag(B) )
					return true;
			}
			else
			{
				if ( (B.Enemy == None) || ((B.Enemy.PlayerReplicationInfo != None) && (B.Enemy.PlayerReplicationInfo.HasFlag != FriendlyFlag)) )
					FindNewEnemyFor(B,(B.Enemy != None) && B.LineOfSightTo(B.Enemy));
				if ( Level.TimeSeconds - LastSeeFlagCarrier > 6 )
				{
					LastSeeFlagCarrier = Level.TimeSeconds;
					B.SendMessage(None, 'OTHER', B.GetMessageIndex('ENEMYFLAGCARRIERHERE'), 10, 'TEAM');
				}
				B.GoalString = "Attack enemy flag carrier";
				if ( B.IsSniping() )
					return false;
				B.bPursuingFlag = true;
				return ( TryToIntercept(B,FriendlyFlag.Holder,EnemyFlag.Homebase) );
			}
		}

		if ( GetOrders() == 'Attack' )
		{
			// break off attack only if needed
			if ( B.bPursuingFlag || bSeeFlag || (B.LastRespawnTime > FriendlyFlag.TakenTime) || NearHomeBase(B)
				|| ((Level.TimeSeconds - FriendlyFlag.TakenTime > FriendlyFlag.HomeBase.BaseExitTime) && !NearEnemyBase(B)) )
			{
				B.bPursuingFlag = true;
				B.GoalString = "Go after enemy holding flag rather than attacking";
				if ( FriendlyFlag.Holder != None )
					return TryToIntercept(B,FriendlyFlag.Holder,EnemyFlag.Homebase);
				else if ( GoPickupFlag(B) )
					return true;

			}
			else if ( B.bReachedGatherPoint )
				B.GatherTime = Level.TimeSeconds - 10;
		}
		else if ( (PlayerController(SquadLeader) == None) && !B.IsSniping()
			&& ((CurrentOrders != 'Defend') || bSeeFlag || B.bPursuingFlag || FlagNearBase()) )
		{
			// FIXME - try to leave one defender at base
			B.bPursuingFlag = true;
			B.GoalString = "Go find my flag";
			if ( FriendlyFlag.Holder != None )
				return TryToIntercept(B,FriendlyFlag.Holder,EnemyFlag.Homebase);
			else if ( GoPickupFlag(B) )
				return true;
		}
	}
	B.bPursuingFlag = false;

	if ( (SquadObjective == EnemyFlag.Homebase) && (B.Enemy != None) && FriendlyFlag.Homebase.BotNearObjective(B)
		&& (Level.TimeSeconds - B.LastSeenTime < 3) )
	{
		if ( !EnemyFlag.bHome && (EnemyFlag.Holder == None ) && B.LineOfSightTo(EnemyFlag.Position()) )
			return FindPathToObjective(B,EnemyFlag.Position());

		B.SendMessage(None, 'OTHER', B.GetMessageIndex('INCOMING'), 15, 'TEAM');
		B.GoalString = "Intercept incoming enemy!";
		return false;
	}

	if ( EnemyFlag.Holder == None )
	{
		if ( !EnemyFlag.bHome || EnemyFlag.Homebase.BotNearObjective(B) )
		{
			B.GoalString = "Near enemy flag!";
			return FindPathToObjective(B,EnemyFlag.Position());
		}
	}
	else if ( (GetOrders() != 'Defend') && !SquadLeader.IsA('PlayerController') )
	{
		// make flag carrier squad leader if on same squad
		FlagCarrier = EnemyFlag.Holder.Controller;
		if ( (FlagCarrier == None) && (EnemyFlag.Holder.DrivenVehicle != None) )
			FlagCarrier = EnemyFlag.Holder.DrivenVehicle.Controller;
			
		if ( (SquadLeader != FlagCarrier) && IsOnSquad(FlagCarrier) )
			SetLeader(FlagCarrier);

		if ( (B.Enemy != None) && B.Enemy.LineOfSightTo(FlagCarrier.Pawn) )
		{
			B.GoalString = "Fight enemy threatening flag carrier";
			B.FightEnemy(true,0);
			return true;
		}

		if ( ((FlagCarrier.MoveTarget == FriendlyFlag.HomeBase)
			|| (FlagCarrier.RouteCache[1] == FriendlyFlag.HomeBase))
			&& (B.Enemy != None)
			&& B.LineOfSightTo(FriendlyFlag.HomeBase) )
		{
			B.GoalString = "Fight enemy while waiting for flag carrier to score";
			if ( B.LostContact(7) )
				B.LoseEnemy();
			if ( B.Enemy != None )
			{
				B.FightEnemy(false,0);
				return true;
			}
		}

		if ( (AIController(FlagCarrier) != None) && (FlagCarrier.MoveTarget != None)
			&& (FlagCarrier.InLatentExecution(FlagCarrier.LATENT_MOVETOWARD)) )
		{
			if ( (FlagCarrier.RouteCache[0] == FlagCarrier.MoveTarget)
				&& (FlagCarrier.RouteCache[1] != None) )
				FlagCarrierTarget = FlagCarrier.RouteCache[1];
			else
				FlagCarrierTarget = FlagCarrier.MoveTarget;
		}
		else
			FlagCarrierTarget = FlagCarrier.Pawn;
		FindPathToObjective(B,FlagCarrierTarget);
		if ( (B.MoveTarget == FlagCarrierTarget) || (B.MoveTarget == FlagCarrier.MoveTarget) )
		{
			if ( B.Enemy != None )
			{
				B.GoalString = "Fight enemy while waiting for flag carrier";
				if ( B.LostContact(7) )
					B.LoseEnemy();
				if ( B.Enemy != None )
				{
					B.FightEnemy(false,0);
					return true;
				}
			}
			if ( !B.bInitLifeMessage )
			{
				B.bInitLifeMessage = true;
				B.SendMessage(EnemyFlag.Holder.PlayerReplicationInfo, 'OTHER', B.GetMessageIndex('GOTYOURBACK'), 10, 'TEAM');
			}
			if ( (B.MoveTarget == FlagCarrier.Pawn)
				&& ((VSize(B.Pawn.Location - FlagCarrier.Pawn.Location) < 250) || (FlagCarrier.Pawn.Acceleration == vect(0,0,0))) )
				return false;
			if ( B.Pawn.ReachedDestination(FlagCarrierTarget) || (FlagCarrier.Pawn.Acceleration == vect(0,0,0))
				|| (FlagCarrier.MoveTarget == FriendlyFlag.HomeBase) || (FlagCarrier.RouteCache[1] == FriendlyFlag.HomeBase) )
			{
				B.WanderOrCamp(true);
				B.GoalString = "Back up the flag carrier!";
				return true;
			}
		}

		B.GoalString = "Find the flag carrier - move to "$B.MoveTarget;
		return ( B.MoveTarget != None );
	}
	return Super.CheckSquadObjectives(B);
}

function EnemyFlagTakenBy(Controller C)
{
	local Bot M;
	local AssaultPath List[16];
	local int i,num;
	local AssaultPath A;
	local float sum,r;

	if ( Bot(C) != None )
	{
		ReturnPath = None;
		ReturnPathTag = '';
		if ( EnemyFlag.IsHome() )
		{
			if ( FRand() < 0.2 )
			{
				Bot(C).bFinalStretch = true;
				return;
			}
			Bot(C).bFinalStretch = false;
			// set return path
			for ( A=EnemyFlag.HomeBase.AlternatePaths; A!=None; A=A.NextPath )
			{
				if ( A.bEnabled && A.bLastPath && !A.bNoReturn )
				{
					List[num] = A;
					num++;
					if ( num > 15 )
						break;
				}
			}
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
						ReturnPath = List[i];
						ReturnPathTag = List[i].PickTag();
						return;
					}
				}
				ReturnPath = List[0];
				ReturnPathTag = List[0].PickTag();
			}
		}
		else
			Bot(C).bFinalStretch = true;
	}

	if ( (PlayerController(SquadLeader) == None) && (SquadLeader != C) )
		SetLeader(C);

	for	( M=SquadMembers; M!=None; M=M.NextSquadMember )
		if ( (M.MoveTarget == EnemyFlag) || (M.MoveTarget == EnemyFlag.HomeBase) )
			M.MoveTimer = FMin(M.MoveTimer,0.05 + 0.15 * FRand());
}

function bool AllowTaunt(Bot B)
{
	return ( (FRand() < 0.5) && (PriorityObjective(B) < 1));
}

function bool ShouldDeferTo(Controller C)
{
	if ( C.PlayerReplicationInfo.HasFlag != None )
		return true;
	return Super.ShouldDeferTo(C);
}

function byte PriorityObjective(Bot B)
{
	if ( B.PlayerReplicationInfo.HasFlag != None )
	{
		if ( FriendlyFlag.HomeBase.BotNearObjective(B) )
			return 255;
		return 2;
	}

	if ( FriendlyFlag.Holder != None )
		return 1;

	return 0;
}

function float ModifyThreat(float current, Pawn NewThreat, bool bThreatVisible, Bot B)
{
	if ( (NewThreat.PlayerReplicationInfo != None)
		&& (NewThreat.PlayerReplicationInfo.HasFlag != None)
		&& bThreatVisible )
	{
		if ( (VSize(B.Pawn.Location - NewThreat.Location) < 1500) || (B.Pawn.Weapon != None && B.Pawn.Weapon.bSniping)
			|| (VSize(NewThreat.Location - EnemyFlag.HomeBase.Location) < 2000) )
			return current + 6;
		else
			return current + 1.5;
	}
	else if ( NewThreat.IsHumanControlled() )
		return current + 0.5;
	else
		return current;
}

defaultproperties
{
     MaxSquadSize=3
}
