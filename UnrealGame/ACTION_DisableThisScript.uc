class ACTION_DisableThisScript extends ScriptedAction;

function bool InitActionFor(ScriptedController C)
{
	if ( UnrealScriptedSequence(C.SequenceScript) != None )
		UnrealScriptedSequence(C.SequenceScript).bDisabled = true;
	return false;	
}

defaultproperties
{
     ActionString="disable this script"
}
