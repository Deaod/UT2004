class DOMSquadAI extends SquadAI;

function AssignCombo(Bot B)
{
	if ( GetOrders() != 'Attack' )
		Super.AssignCombo(B);
}

function name GetOrders()
{
	local name NewOrders;
	
	if ( PlayerController(SquadLeader) != None )
		NewOrders = 'Human';
	else if ( bFreelance && DOMTeamAI(Team.AI).StayFreelance(self) )
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

function byte PriorityObjective(Bot B)
{
	if ( DomTeamAI(Team.AI).DominationPending() )
		return 2;
	return 0;
}

function bool AssignSquadResponsibility(Bot B)
{
	if ( GetOrders() == 'Attack' )
		B.TryCombo("Random");

	if ( bFreelance )
		DOMTeamAI(Team.AI).CheckFreelanceObjective(self);

	if ( (DominationPoint(SquadObjective) != None) && !DominationPoint(SquadObjective).bControllable && B.FindInventoryGoal(0.0001) )
	{
		B.GoalString = "Need weapon or ammo";
		B.SetAttractionState();
		return true;
	}
			
	return Super.AssignSquadResponsibility(B);
}

defaultproperties
{
     GatherThreshold=0.000000
     MaxSquadSize=5
}
