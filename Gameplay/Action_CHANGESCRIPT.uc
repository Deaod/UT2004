class ACTION_ChangeScript extends ScriptedAction;

var(Action) name NextScriptTag;
var ScriptedSequence NextScript;

function ScriptedSequence GetScript(ScriptedSequence S)
{
	if ( (NextScript == None) && (NextScriptTag != 'None') )
	{
		ForEach S.AllActors(class'ScriptedSequence', NextScript, NextScriptTag )
			break;
		if ( NextScript == None )
		{
			Warn("No Next script found for "$self$" in "$S);
			return S;
		}
	}
	return NextScript;
}

function bool InitActionFor(ScriptedController C)
{
	C.bBroken = true;
	return true;	
}

defaultproperties
{
     ActionString="Change script"
     bValidForTrigger=False
}
