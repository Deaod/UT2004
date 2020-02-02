class Action_ChangeObjectiveTeam extends ScriptedAction;

var(Action) name ObjectiveTag;
var(Action) byte NewTeam;

function bool InitActionFor(ScriptedController C)
{
	local GameObjective O;

	if (ObjectiveTag != 'None')
		ForEach C.AllActors(class'GameObjective', O, ObjectiveTag)
			O.SetTeam(NewTeam);

	return false;
}

defaultproperties
{
     ActionString="Change game objective team"
}
