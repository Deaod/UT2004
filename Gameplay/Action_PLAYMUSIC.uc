class ACTION_PlayMusic extends ScriptedAction;

var(Action) string				Song;
var(Action) Actor.EMusicTransition	Transition;
var(Action) bool				bAffectAllPlayers;

function bool InitActionFor(ScriptedController C)
{
	local PlayerController P;
	local Controller A;

	if( bAffectAllPlayers )
	{
		For ( A=C.Level.ControllerList; A!=None; A=A.nextController )
			if ( A.IsA('PlayerController') )
				PlayerController(A).ClientSetMusic( Song, Transition );
	}
	else
	{
		// Only affect the one player.
		P = PlayerController(C.GetInstigator().Controller);
		if( P==None )
			return false;
			
		// Go to music.
		P.ClientSetMusic( Song, Transition );
	}	
	return false;	
}

function string GetActionString()
{
	return ActionString@Song;
}

defaultproperties
{
     Transition=MTRAN_Fade
     bAffectAllPlayers=True
     ActionString="play song"
}
