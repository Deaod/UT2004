class ACTION_Run extends ScriptedAction;

function bool InitActionFor(ScriptedController C)
{
	C.Pawn.ShouldCrouch(false);
	C.Pawn.SetWalking(false);
	return false;	
}

defaultproperties
{
     ActionString="Run"
     bValidForTrigger=False
}
