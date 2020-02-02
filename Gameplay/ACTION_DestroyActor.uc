class ACTION_DestroyActor extends ScriptedAction;

var(Action) name DestroyTag;

function bool InitActionFor(ScriptedController C)
{
	local Actor a;

	if(DestroyTag != 'None')
	{
		ForEach C.AllActors(class'Actor', a, DestroyTag)
		{
			a.Destroy();
		}
	}

	return false;
}

defaultproperties
{
     ActionString="Destroy actor"
}
