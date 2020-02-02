//=============================================================================
// GravityTrigger
//=============================================================================
// Changes gravity ALL physics volumes.
//=============================================================================

class GravityTrigger extends Triggers;

var() float GravityZ;
var() name	VolumeTag;


event Trigger( Actor Other, Pawn EventInstigator )
{
    local PhysicsVolume	PV;
    local vector				XYDir;
    local float					ZDiff, Time;
    local JumpPad				J;
	local NavigationPoint		N;

	if ( Role < Role_Authority )
		return;
    
	ForEach AllActors(class'PhysicsVolume', PV, VolumeTag)
	{
		// Change Physics Volume Gravity
		PV.Gravity.Z = FMax(PV.Gravity.Z, GravityZ);
		PV.NetUpdateTime = Level.TimeSeconds - 1;
		PV.bAlwaysRelevant = true;
		PV.RemoteRole = ROLE_DumbProxy;

		if ( PV.IsA('DefaultPhysicsVolume') )
			Level.DefaultGravity = PV.Gravity.Z; 

		// Adjust JumpPads
		for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
			if ( N.IsA('JumpPad') && PV.Encompasses( N ) )
			{
				J = JumpPad(N);
				if ( J != None )
				{
					XYDir = J.JumpTarget.Location - J.Location;
					ZDiff = XYDir.Z;
					Time = 2.5f * J.JumpZModifier * Sqrt(Abs(ZDiff/GravityZ));
					J.JumpVelocity = XYDir/Time; 
					J.JumpVelocity.Z = ZDiff/Time - 0.5f * GravityZ * Time;
				}
			}
	}
}

defaultproperties
{
     GravityZ=-300.000000
     bCollideActors=False
}
