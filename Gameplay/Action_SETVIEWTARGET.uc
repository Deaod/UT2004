class ACTION_SetViewTarget extends ScriptedAction;

var(Action) name ViewTargetTag;
var Actor ViewTarget;

function bool InitActionFor(ScriptedController C)
{
	if ( ViewTargetTag == 'Enemy' )
		C.ScriptedFocus = C.Enemy;
	else if ( ViewTargetTag == '' )
		C.ScriptedFocus = None;
	else
	{
		if ( (ViewTarget == None) && (ViewTargetTag != 'None') )
			ForEach C.AllActors(class'Actor',ViewTarget,ViewTargetTag)
				break;

		if ( ViewTarget == None )
			C.bBroken = true;
		C.ScriptedFocus = ViewTarget;
	}
	return false;	
}

function String GetActionString()
{
	return ActionString@ViewTarget@ViewTargetTag;
}

	

defaultproperties
{
     ActionString="set viewtarget"
     bValidForTrigger=False
}
