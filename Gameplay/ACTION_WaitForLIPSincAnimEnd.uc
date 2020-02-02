// ifdef WITH_LIPSINC

class ACTION_WaitForLIPSincAnimEnd extends LatentScriptedAction;

function bool CompleteOnLIPSincAnim()
{
	return true;
}


// endif

defaultproperties
{
     ActionString="Wait for LIPSincAnimEnd"
     bValidForTrigger=False
}
