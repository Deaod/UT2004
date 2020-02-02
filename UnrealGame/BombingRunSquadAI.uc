class BombingRunSquadAI extends SquadAI;

var float LastSeeFlagCarrier;
var GameObject Bomb;
var GameObjective EnemyBase, HomeBase, BombBase;
var float ScoringRand;
var class<ShootSpot> ShootSpotClass[2];
var bot SelfPasser, PassTarget;

function AssignCombo(Bot B)
{
	if ( GetOrders() != 'Attack' )
		Super.AssignCombo(B);
}

function bool AllowDetourTo(Bot B,NavigationPoint N)
{
	if ( B.Pawn != Bomb.Holder )
		return true;

	return ( N.LastDetourWeight * B.RouteDist > 3 );
}

function bool AllowTranslocationBy(Bot B)
{
	return ( B.Pawn != Bomb.Holder );
}

function bool AllowImpactJumpBy(Bot B)
{
	return ( B.Pawn != Bomb.Holder );
}

function actor SetFacingActor(Bot B)
{
	if ( B.Pawn != Bomb.Holder )
		return None;

	if ( (B.Enemy == None) || (B.Skill < 4)
		|| (VSize(EnemyBase.Location - B.Pawn.Location) > 2500) )
		return B.Movetarget;
	if ( ShootSpot(B.MoveTarget) != None )
		return EnemyBase;
	return B.MoveTarget;
}

/* GoPickupBomb()
have bot go pickup dropped bomb
*/
function bool GoPickupBomb(Bot B)
{
	if ( !Bomb.CanBePickedUpBy(B.Pawn) )
		return false;

	if ( B.Pawn.TouchingActor(Bomb) )
	{
		Bomb.Touch(B.Pawn);
		return false;
	}
	if ( FindPathToObjective(B,Bomb.Position()) )
	{
		if ( Level.TimeSeconds - BombingRunTeamAI(Team.AI).LastGotFlag > 15 )
		{
			BombingRunTeamAI(Team.AI).LastGotFlag = Level.TimeSeconds;
			B.SendMessage(None, 'OTHER', B.GetMessageIndex('GOTENEMYFLAG'), 20, 'TEAM');
		}
		B.GoalString = "Pick up bomb";
		return true;
	}
	return false;
}

function actor FormationCenter()
{
	if ( (SquadObjective != None) && (SquadObjective.DefenderTeamIndex == Team.TeamIndex) )
		return SquadObjective;
	if ( (Bomb.Holder != None) && (GetOrders() != 'Defend') && !SquadLeader.IsA('PlayerController') )
		return Bomb.Holder;
	return SquadLeader.Pawn;
}

function bool PreferShootScore(Bot B)
{
	local TeamInfo EnemyTeam;
	local bool bNeedTouchDown;
	local DeathMatch G;

	if ( !EnemyBase.bHasShootSpots )
		return false;
	if ( (B.Enemy == None) || (Level.TimeSeconds - B.LastSeenTime > 4) )
		return false;
	if ( Team == Level.GRI.Teams[0] )
		EnemyTeam = Level.GRI.Teams[1];
	else
		EnemyTeam = Level.GRI.Teams[0];

	G = DeathMatch(Level.Game);
	if ( (G.GoalScore > 0) && (Team.Score > G.GoalScore - 7) && (Team.Score < G.GoalScore - 3) )
		bNeedTouchDown = true;
	else if ( Team.Score > EnemyTeam.Score )
		bNeedTouchDown = ( Team.Score < EnemyTeam.Score + 3 );
	else
		bNeedTouchDown = ( EnemyTeam.Score > Team.Score + 3 );

	if ( bNeedTouchDown )
	{
		if ( (G.TimeLimit > 0) && (G.RemainingTime < 90) )
			return false;
		return ( EnemyBase.GetDifficulty() < ScoringRand + 0.3 );
	}
	if ( B.Pawn.Weapon.IsA('SuperShockRifle') && (FRand() < 0.5) )
		return true;

	if ( B.Pawn.Health < 30 )
		return ( EnemyBase.GetDifficulty() < ScoringRand - 0.3 );

	return ( EnemyBase.GetDifficulty() < ScoringRand );
}

function bool TryPassTo(vector V, Bot CarrierBot, Pawn Recipient)
{
	local Pawn Carrier;

	Carrier = CarrierBot.Pawn;

	if ( ((Recipient.Health + Recipient.ShieldStrength >= FMin(60,Carrier.Health))
					|| Recipient.InCurrentCombo() || (Recipient.Controller.Adrenaline == Recipient.Controller.AdrenalineMax))
				&& (VSize(Recipient.Location - Carrier.Location) < 3500)
				&& ((V Dot Normal(Recipient.Location - Carrier.Location)) > 0.5)
				&& (Recipient.IsHumanControlled()
					|| (CarrierBot.Focus == CarrierBot.MoveTarget)
					|| (Recipient.Controller.MoveTarget == CarrierBot.RouteCache[0])
					|| (Recipient.Controller.MoveTarget == CarrierBot.RouteCache[1])
					|| (Recipient.Controller.MoveTarget == CarrierBot.RouteCache[2]))
				&& Carrier.LineOfSightTo(Recipient) )
	{
		PassTarget = Bot(Recipient.Controller);
		Carrier.Weapon.SetAITarget(Recipient);
		CarrierBot.bPlannedShot = true;
		CarrierBot.Target = Recipient;
		Carrier.Weapon.BotFire(false);
		return true;
	}
	return false;
}

/* OrdersForBombCarrier()
Tell bot what to do if he's carrying the flag
*/
function bool OrdersForBombCarrier(Bot B)
{
	local bot S;
	local vector V;
	local controller C;
	local PlayerController PC;
	local bool bPassing, bCanPass, bSelfPass;

	B.TryCombo("xGame.ComboSpeed");

	if ( (B.Enemy != None) && (B.Pawn.Health < 60 ))
		B.SendMessage(None, 'OTHER', B.GetMessageIndex('NEEDBACKUP'), 25, 'TEAM');

	B.bPlannedShot = false;
	SelfPasser = None;
	PassTarget = None;

	// decide whether to pass ball
	if ( (VSize(B.Pawn.Location - EnemyBase.Location) > 3000)
		&& (VSize(B.Pawn.Location - HomeBase.Location) > 3000)
		&& !B.Pawn.InCurrentCombo() )
			bCanPass = true;

	bSelfPass = GameObject(B.PlayerReplicationInfo.HasFlag).CanBeThrownBy(B.Pawn)
				&& bCanPass && (B.TranslocFreq < Level.TimeSeconds + 12) && (B.Skill + B.Tactics > 3 + 4*FRand())
				&& ((B.Enemy == None) || (VSize(B.Pawn.Location - HomeBase.Location) > 5000));

	if ( bCanPass )
	{
		// check for nearby teammate to pass to
		// first check for human player
		V = vector(B.Pawn.Rotation);
		for ( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			PC = PlayerController(C);
			if ( (PC != None) && B.SameTeamAs(PC) && (PC.Pawn != None) && TryPassTo(V,B,PC.Pawn) )
			{
				bCanPass = false;		// so don't try to pass to bot squadmate
				bPassing = true;
				break;
			}
			else
				PC = None;
		}
		if ( bCanPass )
		{
			for ( S=SquadMembers; S!=None; S=S.NextSquadMember )
			{
				if ( (S.Pawn != None)
					&& ((S.Pawn.Physics != PHYS_Falling) || (S.Pawn.PhysicsVolume.Gravity.Z < -900))
					&& TryPassTo(V,B,S.Pawn) )
				{
					bPassing = true;
					break;
				}
			}
		}
	}

	if ( !bPassing && PreferShootScore(B) )
	{
		if ( (ShootSpot(B.Pawn.Anchor) != None) && B.Pawn.ReachedDestination(B.Pawn.Anchor) )
		{
			B.bPlannedShot = true;
			B.Pawn.Weapon.SetAITarget(EnemyBase);
			B.DoRangedAttackOn(EnemyBase);
			return true;
		}
		if ( AlternatePath == None )
		{
			B.MoveTarget = B.FindPathTowardNearest(ShootSpotClass[Team.TeamIndex],false);
			if ( B.MoveTarget != None )
			{
				if ( bSelfPass )
					PassToSelf(B);
				B.GoalString = "Move to shoot spot "$B.RouteGoal;
				B.SetAttractionState();
				return true;
			}
			if ( B.bSoaking )
				B.SoakStop("NO PATH TO SHOOTSPOT");
		}
	}
	if ( !FindPathToObjective(B,EnemyBase) )
	{
		B.GoalString = "No path to enemy base for bomb carrier";
		return false;
	}
	if ( B.MoveTarget == EnemyBase )
	{
		B.GoalString = "Near enemy Base with bomb!";
		if ( B.Pawn.ReachedDestination(EnemyBase) )
			EnemyBase.Touch(B.Pawn);
	}
	else if ( bPassing )
		B.bRecommendFastMove = true;
	else if ( bSelfPass )
		PassToSelf(B);
	return true;
}

function PassToSelf( Bot B )
{
	if ( (B.Pawn.PhysicsVolume.Gravity.Z == B.Pawn.PhysicsVolume.Default.Gravity.Z)
		&& (B.MoveTarget.Location.Z <= B.Pawn.Location.Z + B.Pawn.CollisionHeight + MAXSTEPHEIGHT)
		&& (VSize(B.MoveTarget.Location - B.Pawn.Location) > 500)
		&& ((vector(B.Pawn.Rotation) Dot Normal(B.MoveTarget.Location - B.Pawn.Location)) > 0.7) )
	{
		SelfPasser = B;
		B.Pawn.Weapon.SetAITarget(B.Movetarget);
		B.bPlannedShot = true;
		B.Target = B.Movetarget;
		B.Pawn.Weapon.BotFire(false);
	}
}

function bool MustKeepEnemy(Pawn E)
{
	if ( (E == Bomb.Holder) && (E != None) && (E.Health > 0) )
		return true;
	return false;
}

function bool OverrideFollowPlayer(Bot B)
{
	if ( !Bomb.bHome )
		return false;
		
	if ( Bomb.HomeBase.BotNearObjective(B) )
		return Bomb.HomeBase.TellBotHowToDisable(B);
	return false;
}

function bool CheckSquadObjectives(Bot B)
{
	local bool bSeeBomb, bOnBombHolderTeam;
	local actor BombPosition;
	local actor BombCarrierTarget;
	local controller BombCarrier;

	B.bRecommendFastMove = false;
	if ( Bomb.Holder == B.Pawn )
		return OrdersForBombCarrier(B);
	else if ( Bomb.Holder == None )
		ScoringRand = FRand();

	if ( Bomb.bHome )
	{
		PassTarget = None;
		SelfPasser = None;
	}
	else if ( Bomb.Holder != None )
	{
		PassTarget = None;
		SelfPasser = None;
		bOnBombHolderTeam = B.SameTeamAs(Bomb.Holder.Controller);
	}

	if ( (Bomb.bHome || bOnBombHolderTeam) &&  B.NeedWeapon() && B.FindInventoryGoal(0) )
	{
		B.GoalString = "Need weapon or ammo";
		B.SetAttractionState();
		return true;
	}
	BombPosition = Bomb.Position();
	bSeeBomb = B.LineOfSightTo(BombPosition);
	if ( !bSeeBomb && B.NeedWeapon() && B.FindInventoryGoal(0) )
	{
		B.GoalString = "Need weapon or ammo";
		B.SetAttractionState();
		return true;
	}
	if ( bOnBombHolderTeam && (GetOrders() != 'Defend')
		&& (!SquadLeader.IsA('PlayerController')
			|| ((SquadLeader == Bomb.Holder.Controller) && (B.GetOrders() =='Follow'))) )
	{
		// make bomb carrier squad leader if on same squad
		BombCarrier = Bomb.Holder.Controller;
		if ( (SquadLeader != BombCarrier) && IsOnSquad(BombCarrier) )
			SetLeader(BombCarrier);

		if ( (B.Enemy != None) && B.Enemy.LineOfSightTo(BombCarrier.Pawn) && (B.Skill + B.StrafingAbility < 3) )
		{
			B.GoalString = "Fight enemy threatening flag carrier";
			B.FightEnemy(true,0);
			return true;
		}

		if ( AIController(BombCarrier) == None )
		{
			if ( bSeeBomb )
			{
				if ( BombCarrier.Pawn.Velocity != vect(0,0,0) )
				{
					if ( VSize(BombCarrier.Pawn.Location - B.Pawn.Location) < 3000 )
					{
						B.bRecommendFastMove = true;
						BombCarrierTarget = EnemyBase;
					}
				}
				else if ( (B.Skill > 3) && (VSize(BombCarrier.Pawn.Location - B.Pawn.Location) < 1500) )
				{
					B.bRecommendFastMove = true;
					BombCarrierTarget = EnemyBase;
				}
				else
					BombCarrierTarget = BombCarrier.Pawn;
			}
			else
				BombCarrierTarget = BombCarrier.Pawn;
		}
		else if ( (BombCarrier.MoveTarget != None)
				&& (BombCarrier.Pawn.Velocity != vect(0,0,0)) )
		{
			if ( (BombCarrier.RouteCache[0] == BombCarrier.MoveTarget)
				&& (BombCarrier.RouteCache[1] != None) )
			{
				AddTransientCosts(B,0.5);
				B.bRecommendFastMove = true;
				if ( VSize(BombCarrier.Pawn.Location - B.Pawn.Location) < 1700 )
					BombCarrierTarget = BombCarrier.RouteGoal;
				else if ( (BombCarrier.RouteCache[2] != None) )
				{
					if ( (BombCarrier.RouteCache[3] != None)
						&& (FRand() < 0.7) )
						BombCarrierTarget = BombCarrier.RouteCache[3];
					else
						BombCarrierTarget = BombCarrier.RouteCache[2];
				}
				else
					BombCarrierTarget = BombCarrier.RouteCache[1];
			}
			else
				BombCarrierTarget = BombCarrier.MoveTarget;
		}
		else
			BombCarrierTarget = BombCarrier.Pawn;
		FindPathToObjective(B,BombCarrierTarget);

		if ( (B.MoveTarget == EnemyBase) || B.Pawn.ReachedDestination(BombCarrierTarget) )
		{
			if ( B.Enemy != None )
			{
				B.GoalString = "Fight enemy while waiting for flag carrier";
				if ( B.LostContact(8) )
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
				B.SendMessage(BombCarrier.PlayerReplicationInfo, 'OTHER', B.GetMessageIndex('GOTYOURBACK'), 10, 'TEAM');
			}
			B.WanderOrCamp(true);
			B.GoalString = "Back up the flag carrier!";
			return true;
		}
		B.GoalString = "Find the "$BombCarrierTarget$" - move to "$B.MoveTarget;
		return ( B.MoveTarget != None );
	}
	AddTransientCosts(B,1);
	if ( bSeeBomb )
	{
		if ( Bomb.Holder == None )
		{
			if ( !Bomb.bHome && GoPickupBomb(B) )
				return true;
		}
		else if ( !bOnBombHolderTeam )
		{
			if ( B.Enemy != Bomb.Holder )
				FindNewEnemyFor(B,(B.Enemy != None) && B.LineOfSightTo(B.Enemy));
			if ( Level.TimeSeconds - LastSeeFlagCarrier > 6 )
			{
				LastSeeFlagCarrier = Level.TimeSeconds;
				B.SendMessage(None, 'OTHER', B.GetMessageIndex('ENEMYBALLCARRIERHERE'), 10, 'TEAM');
			}
			B.GoalString = "Attack enemy bomb carrier";
			if ( B.IsSniping() )
				return false;
			return ( TryToIntercept(B,Bomb.Holder,HomeBase) );
		}
	}

	if ( Bomb.bHome )
	{
		if ( BombBase.BotNearObjective(B) )
		{
			B.GoalString = "Near bomb base!";
			return FindPathToObjective(B,BombBase);
		}
		else if ( GetOrders() == 'Attack' )
		{
			B.GoalString = "Go to bomb base!";
			return FindPathToObjective(B,BombBase);
		}
	}
	else if ( GetOrders() == 'Attack' )
	{
		B.GoalString = "Go to bomb";
		if ( Bomb.Holder != None )
			return TryToIntercept(B,Bomb.Holder,Homebase);
		else
			return FindPathToObjective(B,Bomb);
	}
	return Super.CheckSquadObjectives(B);
}

function BombTakenBy(Controller C)
{
	local Bot M;

	if ( VSize(Bomb.Location - BombBase.Location) < 500 )
		SetAlternatePath(true);
	else if ( (Bot(C) == None) || (Bomb.OldTeam != Team) )
		SetFinalStretch(true);
	SelfPasser = None;
	PassTarget = None;

	if ( SquadLeader != C )
		SetLeader(C);

	for	( M=SquadMembers; M!=None; M=M.NextSquadMember )
		if ( (M.MoveTarget == Bomb) || (M.MoveTarget == BombBase) )
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
		if ( EnemyBase.BotNearObjective(B) )
			return 255;
		return 2;
	}

	if ( Bomb.Holder != None )
		return 1;

	return 0;
}

function float ModifyThreat(float current, Pawn NewThreat, bool bThreatVisible, Bot B)
{
	if ( (NewThreat.PlayerReplicationInfo != None)
		&& (NewThreat.PlayerReplicationInfo.HasFlag != None)
		&& bThreatVisible )
	{
		if ( (VSize(NewThreat.Location - HomeBase.Location) > 5000)
			&& (VSize(NewThreat.Location - B.Pawn.Location) > 1500)
			&& UnderFire(NewThreat,B) )
		{
			if ( NewThreat.IsHumanControlled() )
				return current + 1;
			return current + 0.5;
		}
		if ( (VSize(B.Pawn.Location - NewThreat.Location) < 1500) || B.Pawn.Weapon.bSniping )
			return current + 6;
		else
			return current + 1.5;
	}
	else if ( NewThreat.IsHumanControlled() )
		return current + 0.4;
	else
		return current;
}

defaultproperties
{
     ShootSpotClass(0)=Class'UnrealGame.BlueShootSpot'
     ShootSpotClass(1)=Class'UnrealGame.RedShootSpot'
     GatherThreshold=0.100000
     MaxSquadSize=3
}
