class ACTION_FadeView extends LatentScriptedAction;

var(Action) float FadeTime;
var(Action) vector TargetFlash;

function bool InitActionFor(ScriptedController C)
{

	return true;	
}

function string GetActionString()
{
	return ActionString@FadeTime;
}


function bool TickedAction()
{
	return true;
}

function bool StillTicking(ScriptedController C, float DeltaTime)
{
	local bool bXDone,bYDone,bZDone;
	local vector V;

	V = C.GetInstigator().PhysicsVolume.ViewFlash - (C.Instigator.PhysicsVolume.Default.ViewFlash - TargetFlash) * (DeltaTime/FadeTime);

	if( V.X < TargetFlash.X ) { V.X = TargetFlash.X; bXDone = True; }
	if( V.Y < TargetFlash.Y ) { V.Y = TargetFlash.Y; bYDone = True; }
	if( V.Z < TargetFlash.Z ) { V.Z = TargetFlash.Z; bZDone = True; }

	C.GetInstigator().PhysicsVolume.ViewFlash = V;

	if(bXDone && bYDone && bZDone)
		return false;
	return true;
}

defaultproperties
{
     FadeTime=5.000000
     TargetFlash=(X=-2.000000,Y=-2.000000,Z=-2.000000)
     ActionString="fade view"
}
