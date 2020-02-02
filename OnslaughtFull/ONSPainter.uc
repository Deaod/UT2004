class ONSPainter extends Painter;

var float MinZDist;

function bool CanBomb(vector MarkLocation, float NeededRadius)
{
	if (!FastTrace(MarkLocation + MinZDist * vect(0,0,1), MarkLocation))
		return false;

	if (NeededRadius <= 0 || ONSPainterFire(FireMode[0]) == None)
		return true;

	MarkLocation += vect(0,0,100);
	return ( FastTrace(MarkLocation + vect(1,0,0) * NeededRadius, MarkLocation) && FastTrace(MarkLocation + vect(-1,0,0) * NeededRadius, MarkLocation)
		 && FastTrace(MarkLocation + vect(0,1,0) * NeededRadius, MarkLocation) && FastTrace(MarkLocation + vect(0,-1,0) * NeededRadius, MarkLocation) );
}

function float GetAIRating()
{
	local Bot B;
	local vector HitLocation, HitNormal;

	B = Bot(Instigator.Controller);
	if ( B == None )
		return AIRating;
	if ( B.IsShootingObjective() && Trace(HitLocation, HitNormal, B.Target.Location - vect(0,0,2000), B.Target.Location, false) != None )
	{
		MarkLocation = HitLocation;
		if ( CanBomb(MarkLocation, 0) )
			return AIRating;
	}
	if ( (B.Enemy == None) || (Instigator.Location.Z < B.Enemy.Location.Z) || !B.EnemyVisible() )
		return 0;
	MarkLocation = B.Enemy.Location - B.Enemy.CollisionHeight * vect(0,0,2);
	if ( CanBomb(MarkLocation, 0) )
		return 2.0;
	if ( TerrainInfo(B.Enemy.Base) == None )
		return 0;
	return 0.1;
}

defaultproperties
{
     MinZDist=5000.000000
     FireModeClass(0)=Class'OnslaughtFull.ONSPainterFire'
     PutDownAnim="Deselect"
     SelectAnimRate=3.100000
     PutDownAnimRate=2.800000
     Description="The Target Painter, similar to the Ion Painter, fires a harmless, low power laser with its primary fire. Unlike the Ion Painter, however, this weapon calls in a bomber that launches a string of bombs in the direction the user is facing, centered on the painted target. The bombs will easily incinerate the target and any unfortunates that happen to be nearby."
     DisplayFOV=45.000000
     Priority=28
     SmallViewOffset=(X=100.000000,Y=22.000000,Z=-32.500000)
     CenteredOffsetY=-7.000000
     CenteredRoll=0
     CenteredYaw=-500
     PickupClass=Class'OnslaughtFull.ONSPainterPickup'
     PlayerViewOffset=(X=100.000000,Y=22.000000,Z=-32.500000)
     PlayerViewPivot=(Yaw=350)
     AttachmentClass=Class'OnslaughtFull.ONSPainterAttachment'
     ItemName="Target Painter"
     Mesh=SkeletalMesh'ONSFullAnimations.TargetPainter'
     DrawScale=0.600000
     AmbientGlow=64
}
