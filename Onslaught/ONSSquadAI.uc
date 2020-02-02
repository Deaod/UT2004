class ONSSquadAI extends SquadAI;

var bool bDefendingSquad;
var float LastFailedNodeTeleportTime;
var float MaxObjectiveGetOutDist; //cached highest ObjectiveGetOutDist of all the vehicles available on this level

function Reset()
{
	Super.Reset();
	bDefendingSquad = false;
}

function name GetOrders()
{
	local name NewOrders;

	if ( PlayerController(SquadLeader) != None )
		NewOrders = 'Human';
	else if ( bFreelance && !bFreelanceAttack && !bFreelanceDefend )
		NewOrders = 'Freelance';
	else if ( bDefendingSquad || bFreelanceDefend || (SquadObjective != None && SquadObjective.DefenseSquad == self) )
		NewOrders = 'Defend';
	else
		NewOrders = 'Attack';
	if ( NewOrders != CurrentOrders )
	{
		CurrentOrders = NewOrders;
		NetUpdateTime = Level.Timeseconds - 1;
	}
	return CurrentOrders;
}

function byte PriorityObjective(Bot B)
{
	local ONSPowerCore Core;

	if (GetOrders() == 'Defend')
	{
		Core = ONSPowerCore(SquadObjective);
		if (Core != None && (Core.DefenderTeamIndex == Team.TeamIndex) && Core.bUnderAttack)
			return 1;
	}
	else if (CurrentOrders == 'Attack')
	{
		Core = ONSPowerCore(SquadObjective);
		if (Core != None)
		{
			if (Core.bFinalCore)
			{
				if (B.Enemy != None && Core.BotNearObjective(B))
					return 1;
			}
			else if (VSize(B.Pawn.Location - Core.Location) < 1000)
				return 1;
		}
	}
	return 0;
}

function SetDefenseScriptFor(Bot B)
{
	local ONSPowerCore Core;

	//don't look for defense scripts when heading for neutral node
	Core = ONSPowerCore(SquadObjective);
	if (Core == None || (Core.DefenderTeamIndex == Team.TeamIndex && (Core.CoreStage == 2 || Core.CoreStage == 0)) )
	{
		Super.SetDefenseScriptFor(B);
		return;
	}

	if (B.GoalScript != None)
		B.FreeScript();
}

function float MaxVehicleDist(Pawn P)
{
	if ( GetOrders() != 'Attack' || SquadObjective == None )
		return 3000;
	return FMin(3000, VSize(P.Location - SquadObjective.Location));
}

/* FindPathToObjective()
Returns path a bot should use moving toward a base
*/
function bool FindPathToObjective(Bot B, Actor O)
{
	local vehicle OldVehicle;

	if ( B.Pawn.bStationary )
		return false;

	if ( O == None )
	{
		O = SquadObjective;
		if ( O == None )
		{
			B.GoalString = "No SquadObjective";
			return false;
		}
	}

	if ( ONSPowerNode(O) != None && (ONSPowerNode(O).CoreStage != 0 || ONSPowerCore(O).DefenderTeamIndex == Team.TeamIndex) )
	{
		B.MoveTarget = None;
		if ( (Vehicle(B.Pawn) != None) && (B.Pawn.Location.Z - O.Location.Z < 500)
		     && (VSize(B.Pawn.Location - O.Location) < Vehicle(B.Pawn).ObjectiveGetOutDist) && B.LineOfSightTo(O) )
		{
			if ( Vehicle(B.Pawn).bKeyVehicle )
				return false;
			OldVehicle = Vehicle(B.Pawn);
			B.DirectionHint = Normal(O.Location - OldVehicle.Location);
			Vehicle(B.Pawn).KDriverLeave(false);
			if (  Vehicle(B.Pawn) == None )
			{
				if ( ONSChopperCraft(OldVehicle) != None )
				{
					OldVehicle.KAddImpulse( ONSChopperCraft(OldVehicle).PushForce*Vector(OldVehicle.Rotation), OldVehicle.Location );
				}
				if ( (B.Pawn.Physics == PHYS_Falling) && B.DoWaitForLanding() )
				{
					B.Pawn.Velocity.Z = 0;
					return true;
				}
			}
		}

		if ( B.ActorReachable(O) )
		{
			if ( (Vehicle(B.Pawn) != None) && Vehicle(B.Pawn).bKeyVehicle )
				return false;
			if ( (Vehicle(B.Pawn) != None) && (B.Pawn.Location.Z - O.Location.Z < 500) )
			{
				B.DirectionHint = Normal(O.Location - B.Pawn.Location);
				Vehicle(B.Pawn).KDriverLeave(false);
			}
			if ( B.Pawn.ReachedDestination(O) )
			{
				//log(B.GetHumanReadableName()$" Force touch for reached objective");
				O.Touch(B.Pawn);
				return false;
			}
			if ( OldVehicle != None )
				OldVehicle.TeamUseTime = Level.TimeSeconds + 6;
			B.RouteGoal = O;
			B.RouteCache[0] = None;
			B.GoalString = "almost at "$O;
			B.MoveTarget = O;
			B.SetAttractionState();
			return true;
		}
		if ( OldVehicle != None )
			OldVehicle.UsedBy(B.Pawn);
	}

	if ( Super.FindPathToObjective(B,O) )
		return true;

	if ( Vehicle(B.Pawn) != None && !Vehicle(B.Pawn).bKeyVehicle && (B.Enemy == None || !B.EnemyVisible()) )
	{
		if (B.Pawn.HasWeapon() && Vehicle(B.Pawn).MaxDesireability > 0.5)
			Vehicle(B.Pawn).bDefensive = true; //have bots use it as a turret instead
		else
			Vehicle(B.Pawn).VehicleLostTime = Level.TimeSeconds + 20;
		//log(B.PlayerReplicationInfo.PlayerName$" Abandoning "$Vehicle(B.Pawn)$" because can't reach "$O);
		B.DirectionHint = Normal(O.Location - B.Pawn.Location);
		Vehicle(B.Pawn).KDriverLeave(false);
	}
	return false;
}

function bool CheckVehicle(Bot B)
{
	local ONSPowerCore Nearest, Best, Core;
	local GameObjective O;
	local float NewRating, BestRating;
	local byte SourceDist;
	local weapon SuperWeap;
	local int i;
	local Vehicle V;

	if ( (ONSVehicle(B.Pawn) != None) && ((B.Skill + B.Tactics >= 3) || ONSVehicle(B.Pawn).bKeyVehicle) && ONSVehicle(B.Pawn).IsArtillery() )
	{
		if ( ONSVehicle(B.Pawn).IsDeployed() )
		{
			// if possible, just target and fire at nodes or important enemies
			if ( (SquadObjective != None) && (SquadObjective.DefenderTeamIndex != Team.TeamIndex) && (ONSPowerCore(SquadObjective) != None)
				&& ONSPowerCore(SquadObjective).LegitimateTargetOf(B) && B.Pawn.CanAttack(SquadObjective) )
			{
				B.DoRangedAttackOn(SquadObjective);
				B.GoalString = "Artillery Attack Objective";
				return true;
			}
			if ( (B.Enemy != None) && B.Pawn.CanAttack(B.Enemy) )
			{
				B.DoRangedAttackOn(B.Enemy);
				B.GoalString = "Artillery Attack Enemy";
				return true;
			}
			// check squad enemies
			for ( i=0; i<8; i++ )
			{
				if ( (Enemies[i] != None) && (Enemies[i] != B.Enemy) && B.Pawn.CanAttack(Enemies[i]) ) 
				{
					B.DoRangedAttackOn(Enemies[i]);
					B.GoalString = "Artillery Attack Squad Enemy";
					return true;
				}
			}
			// check other nodes
			for ( O=Team.AI.Objectives; O!=None; O=O.NextObjective )
			{
				Core = ONSPowerCore(O);
				if ( (Core != None) && Core.PoweredBy(Team.TeamIndex) && (Core.DefenderTeamIndex != Team.TeamIndex) && Core.LegitimateTargetOf(B) && B.Pawn.CanAttack(Core) )
				{
					B.DoRangedAttackOn(Core);
					B.GoalString = "Artillery Attack Other Node";
					return true;
				}
			}

			// check important enemies
			for ( V=Level.Game.VehicleList; V!=None; V=V.NextVehicle )
			{
				if ( (V.Controller != None) && !V.bCanFly && (V.ImportantVehicle() || V.IsArtillery()) && !V.Controller.SameTeamAs(B) && B.Pawn.CanAttack(V) )
				{
					B.DoRangedAttackOn(V);
					B.GoalString = "Artillery Attack important vehicle";
					return true;
				}
			}
			if ( (VSize(B.Pawn.Location - SquadObjective.Location) > Vehicle(B.Pawn).ObjectiveGetOutDist) || !B.Pawn.CanAttack(SquadObjective) )
				ONSVehicle(B.Pawn).MayUndeploy();
		}
		else if ( !B.Pawn.IsFiring() && (B.Enemy != None) && B.Pawn.CanAttack(B.Enemy) )
		{
			B.Focus = B.Enemy;
			B.FireWeaponAt(B.Enemy);
		}
	}

	if ( SquadObjective != None )
	{
		if ( GetOrders() == 'Attack' )
		{
			if ( (ONSPowerCore(SquadObjective) != None) && ONSPowerCore(SquadObjective).PoweredBy(1 - Team.TeamIndex)
				&& ((Vehicle(B.Pawn) == None) || !Vehicle(B.Pawn).bKeyVehicle) )
			{
				SuperWeap = B.HasSuperWeapon();
				if ( (SuperWeap != None) &&  B.LineOfSightTo(SquadObjective) )
				{
					if ( Vehicle(B.Pawn) != None )
					{
						B.DirectionHint = Normal(SquadObjective.Location - B.Pawn.Location);
	     				Vehicle(B.Pawn).KDriverLeave(false);
					}
	     			return SquadObjective.TellBotHowToDisable(B);
				}
			}			
		}
		else if ( Vehicle(B.Pawn) != None && GetOrders() == 'Defend' && !Vehicle(B.Pawn).bDefensive
			&& VSize(B.Pawn.Location - SquadObjective.Location) < 1600 && !Vehicle(B.Pawn).bKeyVehicle 
			&& ((B.Enemy == None) || (Level.TimeSeconds - B.LastSeenTime > 4) || (!Vehicle(B.Pawn).ImportantVehicle() && !B.EnemyVisible())) )
		{
				B.DirectionHint = Normal(SquadObjective.Location - B.Pawn.Location);
	     		Vehicle(B.Pawn).KDriverLeave(false);
	     		return false;
		}
	}	
	if (Vehicle(B.Pawn) == None && ONSPowerCore(SquadObjective) != None)
	{
		if (ONSPowerCore(SquadObjective).CoreStage == 0)
		{
			if ( GetOrders() == 'Defend' && (B.Enemy == None || (!B.EnemyVisible() && Level.TimeSeconds - B.LastSeenTime > 3))
			     && VSize(B.Pawn.Location - SquadObjective.Location) < GetMaxObjectiveGetOutDist()
			     && ONSPowerCore(SquadObjective).Health < ONSPowerCore(SquadObjective).DamageCapacity
			     && ((B.Pawn.Weapon != None && B.Pawn.Weapon.CanHeal(SquadObjective)) || (B.Pawn.PendingWeapon != None && B.Pawn.PendingWeapon.CanHeal(SquadObjective))) )
				return false;
		}
		if (ONSPowerCore(SquadObjective).CoreStage == 2)
		{
			if ( (B.Enemy == None || !B.EnemyVisible()) && VSize(B.Pawn.Location - SquadObjective.Location) < GetMaxObjectiveGetOutDist() )
				return false;
		}
		if ((ONSPowerCore(SquadObjective).CoreStage == 4 || ONSPowerCore(SquadObjective).CoreStage == 1) && VSize(B.Pawn.Location - SquadObjective.Location) < GetMaxObjectiveGetOutDist())
			return false;
	}

	if (Super.CheckVehicle(B))
		return true;
	if ( Vehicle(B.Pawn) != None || (B.Enemy != None && B.EnemyVisible()) || LastFailedNodeTeleportTime > Level.TimeSeconds - 20 || ONSPowerCore(SquadObjective) == None
	     || ONSPlayerReplicationInfo(B.PlayerReplicationInfo) == None || ONSPowerCore(SquadObjective).HasUsefulVehicles(B) || B.Skill + B.Tactics < 2 + FRand() )
		return false;

	//no vehicles around
	if (VSize(B.Pawn.Location - SquadObjective.Location) > 5000 && !B.LineOfSightTo(SquadObjective))
	{
		//really want a vehicle to get to SquadObjective, so teleport to a different node to find one
		if (ONSPowerCore(B.RouteGoal) != None && ONSPlayerReplicationInfo(B.PlayerReplicationInfo).GetCurrentNode() == B.RouteGoal)
		{
			SourceDist = ONSPowerCore(B.RouteGoal).FinalCoreDistance[Abs(1 - Team.TeamIndex)];
			for (O = Team.AI.Objectives; O != None; O = O.NextObjective)
				if (O != B.RouteGoal && ONSOnslaughtGame(Level.Game).ValidSpawnPoint(ONSPowerCore(O), Team.TeamIndex))
				{
					NewRating = ONSPowerCore(O).TeleportRating(B, Team.TeamIndex, SourceDist);
					if (NewRating > BestRating || (NewRating == BestRating && FRand() < 0.5))
					{
						Best = ONSPowerCore(O);
						BestRating = NewRating;
					}
				}

			if (Best != None)
				ONSPlayerReplicationInfo(B.PlayerReplicationInfo).TeleportTo(Best);
			else
				LastFailedNodeTeleportTime = Level.TimeSeconds;

			return false;
		}

		Nearest = ONSPowerCore(SquadObjective).ClosestTo(B.Pawn);
		if ( Nearest == None || Nearest.CoreStage != 0 || Nearest.DefenderTeamIndex != Team.TeamIndex
		     || VSize(Nearest.Location - B.Pawn.Location) > 2000 )
			return false;

		B.MoveTarget = B.FindPathToward(Nearest, false);
		if (B.MoveTarget != None)
		{
			B.RouteGoal = Nearest;
			B.GoalString = "Node teleport from "$B.RouteGoal;
			B.SetAttractionState();
			return true;
		}
	}

	return false;
}

function BotEnteredVehicle(Bot B)
{
	local bot SquadMate, Best;
	local float BestDist, NewDist;

	Super.BotEnteredVehicle(B);

	if ( !Level.Game.JustStarted(20) || (ONSVehicle(B.Pawn) == None) || !ONSVehicle(B.Pawn).FastVehicle()
		|| (self == Team.AI.FreelanceSquad) || (Team.AI.FreelanceSquad == None) )
		return;

	// don't do on teams with humans, since this might contradict their orders
	if ( Level.NetMode == NM_Standalone )
	{
		if ( Level.GetLocalPlayerController().PlayerReplicationInfo.Team == Team )
			return;
	}
	else if ( !UnrealMPGameInfo(Level.Game).bPlayersVsBots )
		return;

	// if in fast vehicle, and freelance squad doesn't have one, switch
	for ( SquadMate=Team.AI.FreelanceSquad.SquadMembers; SquadMate!=None; SquadMate=SquadMate.NextSquadMember )
	{
		if ( (ONSVehicle(SquadMate.Pawn) != None) && ONSVehicle(SquadMate.Pawn).FastVehicle() )
			return;
		else if ( Best == None )
		{
			Best = SquadMate;
			if ( Best.Pawn != None )
				BestDist = VSize(B.Pawn.Location - SquadObjective.Location);
			else
				BestDist = 1000000;
		}
		else if (SquadMate.Pawn != None )
		{
			NewDist = VSize(SquadMate.Pawn.Location - SquadObjective.Location);
			if ( NewDist < BestDist )
			{
				Best = SquadMate;
				BestDist = NewDist;
			}
		}
	}

	// make the switch
	SwitchBots(B,Best);
}

//return a value indicating how useful this vehicle is to the bot
function float VehicleDesireability(Vehicle V, Bot B)
{
	local float Rating;

	if (CurrentOrders == 'Defend')
	{
		if ((SquadObjective == None || VSize(SquadObjective.Location - B.Pawn.Location) < 2000) && Super.VehicleDesireability(V, B) <= 0)
			return 0;
		if (V.Health < V.HealthMax * 0.125 && B.Enemy != None && B.EnemyVisible())
			return 0;
		Rating = V.BotDesireability(self, Team.TeamIndex, SquadObjective);
		if (Rating <= 0)
			return 0;

		if (V.bDefensive)
		{
			if (ONSPowerCore(SquadObjective) != None)
			{
				//turret can't hit priority enemy
				if ( V.bStationary && B.Enemy != None && ONSPowerCore(SquadObjective).LastDamagedBy == B.Enemy.PlayerReplicationInfo
				     && !FastTrace(B.Enemy.Location + B.Enemy.CollisionHeight * vect(0,0,1), V.Location) )
					return 0;
				if (ONSPowerCore(SquadObjective).ClosestTo(V) != SquadObjective)
					return 0;
			}
			if (ONSStationaryWeaponPawn(V) != None && !ONSStationaryWeaponPawn(V).bPowered)
				return 0;
		}
		if ( V.SpokenFor(B) )
			return Rating * V.NewReservationCostMultiplier(B.Pawn);
		return Rating;
	}

	return Super.VehicleDesireability(V, B);
}

function bool CheckSpecialVehicleObjectives(Bot B)
{
	local ONSPowerCore Core;
	local SquadAI S;

	if ( ONSTeamAI(Team.AI).OverrideCheckSpecialVehicleObjectives(B) )
		return false;

	if (Size > 1)
		return Super.CheckSpecialVehicleObjectives(B);

	//if bot is the only bot headed to a neutral (unclaimed) node, that's more important, so don't head to any SpecialVehicleObjectives
	Core = ONSPowerCore(SquadObjective);
	if (Core == None || Core.CoreStage != 4 || !Core.PoweredBy(Team.TeamIndex))
		return Super.CheckSpecialVehicleObjectives(B);

	for (S = Team.AI.Squads; S != None; S = S.NextSquad)
		if (S != self && S.SquadObjective == Core)
			return Super.CheckSpecialVehicleObjectives(B);

	return false;
}

function float GetMaxObjectiveGetOutDist()
{
	local SVehicleFactory F;

	if (MaxObjectiveGetOutDist == 0.0)
		foreach DynamicActors(class'SVehicleFactory', F)
			if (F.VehicleClass != None)
				MaxObjectiveGetOutDist = FMax(MaxObjectiveGetOutDist, F.VehicleClass.default.ObjectiveGetOutDist);

	return MaxObjectiveGetOutDist;
}

function bool CheckSquadObjectives(Bot B)
{
	local bool bResult;

	if ( (B.Enemy != None) && (B.Enemy == ONSTeamAI(Team.AI).FinalCore.LastAttacker) )
	{
		if ( B.NeedWeapon() && B.FindInventoryGoal(0) )
		{
			B.GoalString = "Need weapon or ammo";
			B.SetAttractionState();
			return true;
		}
		return false;
	}

	if ( !ONSTeamAI(Team.AI).bAllNodesTaken && (self == Team.AI.FreelanceSquad) )
	{
		// keep moving to any unpowered nodes if current objective is constructing
		if ( ONSPowerCore(SquadObjective).DefenderTeamIndex == Team.TeamIndex )
			Team.AI.ReAssessStrategy();
	}
	bResult = Super.CheckSquadObjectives(B);

	if (!bResult && CurrentOrders == 'Freelance' && B.Enemy == None && ONSPowerCore(SquadObjective) != None)
	{
		if (ONSPowerCore(SquadObjective).PoweredBy(Team.TeamIndex))
		{
			B.GoalString = "Disable Objective "$SquadObjective;
			return SquadObjective.TellBotHowToDisable(B);
		}
		else if (!B.LineOfSightTo(SquadObjective))
		{
			B.GoalString = "Harass enemy at "$SquadObjective;
			return FindPathToObjective(B, SquadObjective);
		}
	}

	return bResult;
}

function float ModifyThreat(float current, Pawn NewThreat, bool bThreatVisible, Bot B)
{
	if ( NewThreat.PlayerReplicationInfo != None && ONSPowerCore(SquadObjective) != None
	     && ONSPowerCore(SquadObjective).LastDamagedBy == NewThreat.PlayerReplicationInfo
	     && ONSPowerCore(SquadObjective).bUnderAttack )
	{
		if ( NewThreat == ONSTeamAI(Team.AI).FinalCore.LastAttacker )
			return current + 6;
		if (!bThreatVisible)
			return current + 0.5;
		if ( (VSize(B.Pawn.Location - NewThreat.Location) < 2000) || B.Pawn.IsA('Vehicle') || B.Pawn.Weapon.bSniping
			|| ONSPowerCore(SquadObjective).Health < ONSPowerCore(SquadObjective).DamageCapacity * 0.5 )
			return current + 6;
		else
			return current + 1.5;
	}
	else
		return current;
}

function bool MustKeepEnemy(Pawn E)
{
	if ( (E.PlayerReplicationInfo != None) && (ONSPowerCore(SquadObjective) != None) )
	{
		if ( ONSPowerCore(SquadObjective).bUnderAttack && (ONSPowerCore(SquadObjective).LastDamagedBy == E.PlayerReplicationInfo) )
			return true;
		if ( E == ONSTeamAI(Team.AI).FinalCore.LastAttacker )
			return true;
	}
	return false;
}

//don't actually merge squads, because they could be two defending squads from different teams going to same neutral powernode
function MergeWith(SquadAI S)
{
	if ( SquadObjective != S.SquadObjective )
	{
		SquadObjective = S.SquadObjective;
		NetUpdateTime = Level.Timeseconds - 1;
	}
}

defaultproperties
{
     GatherThreshold=0.000000
     MaxSquadSize=3
     bAddTransientCosts=True
}
