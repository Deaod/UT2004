class GibHead extends Gib;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( Instigator != None )
	{
		SetDrawScale(Instigator.HeadScale * DrawScale);
		SetCollisionSize(CollisionRadius * Instigator.HeadScale, CollisionHeight * Instigator.HeadScale);
	}
}

defaultproperties
{
}
