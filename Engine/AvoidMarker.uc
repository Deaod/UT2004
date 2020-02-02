//=============================================================================
// AvoidMarker.
// Creatures will tend to back away when near this spot
//=============================================================================
class AvoidMarker extends Triggers
	native
	notPlaceable;

var byte TeamNum;

function Touch( actor Other )
{
	if ( (Pawn(Other) != None)&& RelevantTo(Pawn(Other)) )
		Pawn(Other).Controller.FearThisSpot(self);
}

function bool RelevantTo(Pawn P)
{
	return ( (AIController(P.Controller) != None) 
			&& ((P.Controller.PlayerReplicationInfo == None) || (P.Controller.PlayerReplicationInfo.Team == None) || (P.Controller.PlayerReplicationInfo.Team.TeamIndex != TeamNum)) );
}

function StartleBots()
{
	local Pawn P;
	
	ForEach CollidingActors(class'Pawn', P, CollisionRadius)
		if ( RelevantTo(P) )
			AIController(P.Controller).Startle(self);
}

defaultproperties
{
     TeamNum=255
     CollisionRadius=100.000000
}
