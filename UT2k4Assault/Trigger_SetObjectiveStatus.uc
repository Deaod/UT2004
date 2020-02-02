//=============================================================================
// Trigger_SetObjectiveStatus
//=============================================================================

class Trigger_SetObjectiveStatus extends Triggers;

var(Action) name	ObjectiveTag;
var(Action) bool	bActive;

event Trigger( Actor Other, Pawn EventInstigator )
{
	local GameObjective GO;

	if ( Role < Role_Authority )
		return;

	for ( GO=UnrealTeamInfo(Level.Game.GameReplicationInfo.Teams[0]).AI.Objectives; GO!=None; GO=GO.NextObjective )
		if ( ObjectiveTag == GO.Tag )
			GO.SetActive( bActive );
}

defaultproperties
{
     bActive=True
     bCollideActors=False
}
