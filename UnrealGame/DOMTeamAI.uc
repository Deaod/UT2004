class DOMTeamAI extends TeamAI;

var SquadAI PrimaryDefender;

function bool DominationPending()
{
	local GameObjective O;

	for ( O=Objectives; O!=None; O=O.NextObjective )
		if ( (O.DefenderTeamIndex == Team.TeamIndex) || (O.DefenderTeamIndex == 255) )
			return false;
	return true;
}

function CheckFreelanceObjective(SquadAI S)
{
	local GameObjective O, Best;
	
	if ( (S.SquadObjective != None) 
		&& ((S.SquadObjective.DefenderTeamIndex != Team.TeamIndex) || DominationPending()) )
		return;

	// check if any unowned objectives
	for ( O=Objectives; O!=None; O=O.NextObjective )
	{
		if ( (DominationPoint(O) != None)
			&& ((Best == None) || (Best.DefenderTeamIndex == Team.TeamIndex)) )
			Best = O;
	}
	if ( Best != S.SquadObjective )
	{
		S.SquadObjective = Best;
		NetUpdateTime = Level.Timeseconds - 1;
		S.SetFinalStretch(false);
	}
}

function bool StayFreelance(SquadAI S)
{
	if ( (S.SquadObjective != None) 
		&& ((S.SquadObjective.DefenderTeamIndex != Team.TeamIndex) || DominationPending()) )
		return false;
	
	return (  (S.SquadObjective == None) || (S.SquadObjective.DefenderTeamIndex == Team.TeamIndex) ); 
}		

function bool PutOnDefense(Bot B)
{
	local GameObjective O;

	O = GetLeastDefendedObjective();
	if ( O != None )
	{
		if ( PrimaryDefender == None )
			PrimaryDefender = AddSquadWithLeader(B, O);
		else
			PrimaryDefender.AddBot(B);
		return true;
	}
	return false;
}

/* FindNewObjectiveFor()
pick a new objective for a squad that has completed its current objective
*/
function FindNewObjectiveFor(SquadAI S, bool bForceUpdate)
{
	local GameObjective O;
	
	if ( PlayerController(S.SquadLeader) != None )
		return;
	if ( S.bFreelance )
		O = GetPriorityFreelanceObjective();
	else if ( S.SquadObjective != None )	
		O = S.SquadObjective;
	else if ( S.GetOrders() == 'Attack' )
		O = GetPriorityAttackObjectiveFor(S);
	if ( O == None )
		O = GetLeastDefendedObjective();
	S.SetObjective(O, bForceUpdate);
}

function GameObjective GetLeastDefendedObjective()
{
	local GameObjective O, Best;

	for ( O=Objectives; O!=None; O=O.NextObjective )
	{
		if ( (DominationPoint(O) != None) && DominationPoint(O).CheckPrimaryTeam(Team.TeamIndex)
			&& ((Best == None) || (Best.DefensePriority	< O.DefensePriority)
				|| ((Best.DefensePriority == O.DefensePriority) && (Best.GetNumDefenders() < O.GetNumDefenders()))) )
			Best = O;
	}
	return Best;
}

function GameObjective GetPriorityAttackObjectiveFor(SquadAI AttackSquad)
{
	local GameObjective O, Best;

	for ( O=Objectives; O!=None; O=O.NextObjective )
	{
		if ( (DominationPoint(O) != None) && !DominationPoint(O).CheckPrimaryTeam(Team.TeamIndex)
			&& ((Best == None) || (Best.DefenderTeamIndex == Team.TeamIndex)) )
			Best = O;
	}
	return Best;
}

function GameObjective GetPriorityFreelanceObjective()
{
	local GameObjective O, Best;
	for ( O=Objectives; O!=None; O=O.NextObjective )
	{
		if ( (DominationPoint(O) != None)
			&& ((Best == None) || (Best.DefenderTeamIndex == Team.TeamIndex)) )
			Best = O;
	}
	return Best;
}

function SetBotOrders(Bot NewBot, RosterEntry R)
{
	if ( Team.Size == 1 )
		OrderList[0] = 'FREELANCE';
		
	Super.SetBotOrders(NewBot,R);
}

function SetOrders(Bot B, name NewOrders, Controller OrderGiver)
{
	local GameObjective O, Best;
	local SquadAI S;
	local float BestDist;
	local TeamPlayerReplicationInfo PRI;
	local byte Picked;
	
	PRI = TeamPlayerReplicationInfo(B.PlayerReplicationInfo);
	if ( HoldSpot(B.GoalScript) != None )
	{
		PRI.bHolding = false;
		B.FreeScript();
	}

	if ( (NewOrders == 'HOLD') && (PlayerController(OrderGiver) != None) )
	{
		BestDist = 2000;
		for ( O=Objectives; O!=None; O=O.NextObjective )
			if ( (VSize(PlayerController(OrderGiver).ViewTarget.Location - O.Location) < BestDist) && OrderGiver.LineOfSightTo(O) )
			{
				Best = O;
				BestDist = VSize(PlayerController(OrderGiver).ViewTarget.Location - O.Location);
			} 
			if ( Best != None )
			{
				if ( B.Squad.SquadObjective != Best )
				{
					for ( S=Squads; S!=None; S=S.NextSquad )
						if ( (S.SquadObjective == Best) && (PlayerController(S.SquadLeader) == None) )
						{
							S.AddBot(B);
							return;
						}
					AddSquadWithLeader(B, Best);
					return;
				}
			}
	}

	Picked = 255;
	
	if ( NewOrders == 'Defend' )
		Picked = 1;
	else if ( NewOrders == 'Attack' )
		Picked = 0;
		
	if ( Picked == 255 )
		Super.SetOrders(B,NewOrders,OrderGiver);
	else
	{
		if ( (PrimaryDefender != None) && (DominationPoint(PrimaryDefender.SquadObjective).PrimaryTeam == Picked) )
			PrimaryDefender.AddBot(B);
		else if ( (AttackSquad != None) && (DominationPoint(AttackSquad.SquadObjective).PrimaryTeam == Picked) )
			AttackSquad.AddBot(B);
		else
		{
			// find objective, and add new squad
			for ( O=Objectives; O!=None; O=O.NextObjective )
				if ( (DominationPoint(O) != None) && (DominationPoint(O).PrimaryTeam == Picked) )
					break;
				
			if ( DominationPoint(O) != None )
			{
				if ( PrimaryDefender == None )
					PrimaryDefender = AddSquadWithLeader(B, O);
				else if ( AttackSquad == None )
					AttackSquad = AddSquadWithLeader(B, O);
			}
		}
	}	
}

defaultproperties
{
     SquadType=Class'UnrealGame.DOMSquadAI'
     OrderList(0)="Attack"
     OrderList(1)="Defend"
     OrderList(2)="Attack"
     OrderList(4)="Defend"
     OrderList(6)="Freelance"
}
