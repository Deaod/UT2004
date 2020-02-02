class ACTION_PlayAnim extends ScriptedAction;

var(Action) name BaseAnim;
var(Action) float BlendInTime;
var(Action) float BlendOutTime;
var(Action) float AnimRate;
var(Action) byte AnimIterations;
var(Action) bool bLoopAnim;
var(Action) float StartFrame;

function bool InitActionFor(ScriptedController C)
{
	// play appropriate animation
	C.AnimsRemaining = AnimIterations;
	if ( PawnPlayBaseAnim(C,true) )
		C.CurrentAnimation = self;
	return false;	
}

function SetCurrentAnimationFor(ScriptedController C)
{
	if ( C.Pawn.IsAnimating(0) )
		C.CurrentAnimation = self;
	else
		C.CurrentAnimation = None;
}

function bool PawnPlayBaseAnim(ScriptedController C, bool bFirstPlay)
{
	if ( BaseAnim == '' )
		return false;
	
	C.bControlAnimations = true;
	if ( bFirstPlay )
		C.Pawn.PlayAnim(BaseAnim,AnimRate,BlendInTime);
	else if ( bLoopAnim || (C.AnimsRemaining > 0) )
		C.Pawn.LoopAnim(BaseAnim,AnimRate);
	else
		return false;
		
	if( StartFrame > 0.0 )
		C.Pawn.SetAnimFrame( StartFrame, 0, 1);
				
	return true;
}

function string GetActionString()
{
	return ActionString@BaseAnim;
}

defaultproperties
{
     BlendInTime=0.200000
     BlendOutTime=0.200000
     AnimRate=1.000000
     ActionString="play animation"
     bValidForTrigger=False
}
