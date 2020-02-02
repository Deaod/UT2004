class ACTION_SetObjectiveActiveStatus extends ScriptedAction;

var(Action) name	ObjectiveTag;
var(Action) bool	bActive;

function bool InitActionFor(ScriptedController C)
{
	local GameObjective GO;

	if ( ObjectiveTag != 'None' )
	{
		for ( GO=UnrealTeamInfo(C.Level.Game.GameReplicationInfo.Teams[0]).AI.Objectives; GO!=None; GO=GO.NextObjective )
			if ( ObjectiveTag == GO.Tag )
				GO.SetActive( bActive );
	}
	return false;	
}

function string GetActionString()
{
	return ActionString @ ObjectiveTag;
}

defaultproperties
{
     bActive=True
     ActionString="Change Objective's Active Status"
}
