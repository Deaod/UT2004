class ACTION_SetCorona extends ScriptedAction;

var(Action) bool bCorona;
var(Action) name HideActorTag;

function bool InitActionFor(ScriptedController C)
{
	local Actor A;
	
	if ( HideActorTag != '' )
	{
		ForEach C.AllActors(class'Actor',A,HideActorTag)
			A.bCorona = bCorona;
	}
	return false;	
}

defaultproperties
{
}
