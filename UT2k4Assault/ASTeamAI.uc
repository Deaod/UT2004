//=============================================================================
// AssaultTeamAI
//=============================================================================

class ASTeamAI extends TeamAI;

var SquadAI CurrentDefenseSquad;

function CriticalObjectiveWarning(GameObjective G, Pawn NewEnemy)
{
	local SquadAI S;
	
	for ( S=Squads; S!=None; S=S.NextSquad )
		if ( S.SquadObjective == G )
			S.CriticalObjectiveWarning(NewEnemy);
}

function GameObjective GetPriorityAttackObjectiveFor(SquadAI AttackSquad)
{
	local GameObjective O, OldObjective;
	local float BestDist, R;
	local bool bSwitch;
	local SquadAI S;

	for ( O=Objectives; O!=None; O=O.NextObjective )
		O.bIsBeingAttacked = false;
	for ( S=Squads; S!=None; S=S.NextSquad )
		if ( (S != AttackSquad) && (S.SquadObjective != None) && (S.Size > 0) )
			S.SquadObjective.bIsBeingAttacked = true;
			
	if ( AttackSquad != None )
		PickedObjective = AttackSquad.SquadObjective;
		
	if ( (PickedObjective == None) || PickedObjective.bDisabled || !PickedObjective.bActive || (PickedObjective.DefenderTeamIndex == Team.TeamIndex) || !UnrealMPGameInfo(Level.Game).CanDisableObjective( PickedObjective ) )
	{
		OldObjective = PickedObjective;
		PickedObjective = None;
	}
	BestDist = 800;
		
	for ( O=Objectives; O!=None; O=O.NextObjective )
	{
		if ( !O.bDisabled && O.bActive && !O.bIgnoredObjective && (O.DefenderTeamIndex != Team.TeamIndex) && UnrealMPGameInfo(Level.Game).CanDisableObjective( O ) )
		{
			if ( PickedObjective == None )
				bSwitch = true;
			else if ( (OldObjective != None) && (VSize(O.Location - OldObjective.Location) < BestDist) )
				bSwitch = true;
			else if ( O.bIsBeingAttacked )
			{
				if ( !PickedObjective.bIsBeingAttacked || O.bOptionalObjective )
					continue; 	
				else if ( PickedObjective.bOptionalObjective || (FRand() < 0.35) )
					bSwitch = true;
			}
			else if ( PickedObjective.bIsBeingAttacked )
				bSwitch = true;
			else 
			{
				R = FRand();
				if ( PickedObjective.bOptionalObjective )
				{
					// sometimes skip optional objectives, but prioritize them at highest priority
					if ( PickedObjective.DefensePriority >= O.DefensePriority )
						R *= 1.4;
					else
						R *= 0.6;
				}
				else if ( PickedObjective.DefensePriority > O.DefensePriority )
					R *= 1.4;
				else if ( PickedObjective.DefensePriority < O.DefensePriority ) 
					R *= 0.7;
				bSwitch = ( R < 0.3 );
			}
					
			if ( bSwitch )
			{
				PickedObjective = O;
				if ( OldObjective != None )
					BestDist = VSize(O.Location - OldObjective.Location);
			}
		}
	}
	
	return PickedObjective;
}

function GameObjective GetLeastDefendedObjective()
{
	local GameObjective O, Best;

	for ( O=Objectives; O!=None; O=O.NextObjective )
	{
		if ( !O.bDisabled && O.bActive && !O.bIgnoredObjective && (O.DefenderTeamIndex == Team.TeamIndex) && UnrealMPGameInfo(Level.Game).CanDisableObjective(O) )
		{
			if ( (O.DefenseSquad != None) && (O.DefenseSquad.SquadObjective != O) )
				O.DefenseSquad = None;
			if ( Best == None )
				Best = O;
			else if ( O.DefenseSquad == None )
			{
				if ( (Best.DefenseSquad != None) || (!O.bOptionalObjective && (Best.DefensePriority > O.DefensePriority)) )
					Best = O;
			}
			else if ( Best.DefenseSquad == None )
				Best = Best;
			else if ( O.DefenseSquad.Size < Best.DefenseSquad.Size )
				Best = O;
			else if ( Best.bOptionalObjective && (Best.DefenseSquad.Size >= Best.DefenseSquad.MaxSquadSize) )
				Best = O;
		}
	}
	return Best;
}

/* SetOrders()
Called when player gives orders to bot
*/
function SetOrders(Bot B, name NewOrders, Controller OrderGiver)
{
	local TeamPlayerReplicationInfo PRI;
	
	PRI = TeamPlayerReplicationInfo(B.PlayerReplicationInfo);
	if ( HoldSpot(B.GoalScript) != None )
	{
		PRI.bHolding = false;
		B.FreeScript();
	}
	if ( NewOrders == 'Hold' )
	{
		PRI.bHolding = true;
		PutBotOnSquadLedBy(OrderGiver,B);
		B.GoalScript = PlayerController(OrderGiver).ViewTarget.Spawn(class'HoldSpot');
		if ( Vehicle(PlayerController(OrderGiver).ViewTarget) != None )
			HoldSpot(B.GoalScript).HoldVehicle = Vehicle(PlayerController(OrderGiver).ViewTarget);
		if ( PlayerController(OrderGiver).ViewTarget.Physics == PHYS_Ladder )
			B.GoalScript.SetPhysics(PHYS_Ladder);
	}
	else if ( NewOrders == 'Follow' )
	{
		B.FreeScript();
		PutBotOnSquadLedBy(OrderGiver,B);
	}
	else if ( NewOrders == 'Freelance' )
	{
		PutOnFreelance(B);
		return;
	}
}

function bool PutOnDefense(Bot B)
{
	local GameObjective O;

	O = GetLeastDefendedObjective();
	if ( O != None )
	{
		if ( O.DefenseSquad == None )
		{
			O.DefenseSquad = AddSquadWithLeader(B, O);
			return true;
		}
		else if ( O.DefenseSquad.Size <  O.DefenseSquad.MaxSquadSize )
		{
			O.DefenseSquad.AddBot(B);
			return true;
		}
	}
	if ( (CurrentDefenseSquad == None) || (CurrentDefenseSquad.Size >= CurrentDefenseSquad.MaxSquadSize) )
		CurrentDefenseSquad = AddSquadWithLeader(B,None);
	else
		CurrentDefenseSquad.AddBot(B);
	return true;
}

/*
SetBotOrders - based on RosterEntry recommendations
FIXME - need assault type pick leader when leader dies for attacking
freelance squad - backs up defenders under attack, or joins in attacks
*/
function SetBotOrders(Bot NewBot, RosterEntry R)
{
	local SquadAI HumanSquad;
	local name NewOrders;
	
	if ( Objectives == None )
		SetObjectiveLists();
	
	if ( (R != None) && R.RecommendSupport() )
		NewOrders = 'FOLLOW';
	else if ( Team.TeamIndex == ASGameInfo(Level.Game).CurrentAttackingTeam ) 
		NewOrders = 'ATTACK';
	else
		NewOrders = 'DEFEND';

	// log(NewBot$" set Initial orders "$NewOrders);	
	if ( (NewOrders == 'DEFEND') && PutOnDefense(NewBot) )
		return;

	if ( NewOrders == 'ATTACK' )
	{
		PutOnOffense(NewBot);
		return;
	}

	if ( NewOrders == 'FOLLOW' )
	{
		// Follow any human player
		HumanSquad = AddHumanSquad();
		if ( HumanSquad != None )				
		{
			HumanSquad.AddBot(NewBot);
			return;
		}
	}
	PutOnOffense(NewBot);
}	

defaultproperties
{
     SquadType=Class'UT2k4Assault.AssaultSquadAI'
}
