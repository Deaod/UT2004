// ifdef WITH_LIPSinc

class ACTION_PlayLIPSinc extends ScriptedAction;

var(Action)		name			LIPSincAnimName;
var(Action)		float			Volume;
var(Action)		float			Radius;
var(Action)		float			Pitch;

function bool InitActionFor(ScriptedController C)
{
	C.Pawn.PlayLIPSincAnim(LIPSincAnimName, Volume, Radius, Pitch);
	return false;
}

function string GetActionString()
{
	return ActionString;
}


// endif

defaultproperties
{
     Volume=1.000000
     Radius=80.000000
     Pitch=1.000000
     ActionString="Play LIPSinc"
}
