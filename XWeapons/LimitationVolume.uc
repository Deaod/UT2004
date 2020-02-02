// ====================================================================
//  Class:  XWeapons.LimitationVolume
//  Parent: Engine.Volume
//
//  Used to limit where various objects can go.
// ====================================================================

class LimitationVolume extends Volume;

var (Limits) bool bLimitTransDisc;
var (Limits) bool bLimitProjectiles;
var (Limits) class<Actor> LimitEffectClass;

event touch( Actor Other )
{
	if ( ((bLimitTransDisc) && (TransBeacon(Other)!=None)) || ((bLimitProjectiles) && (Projectile(Other)!=None)) )
	{
	
		if (LimitEffectClass!=None)
			Spawn(LimitEffectClass,,,Other.Location, Other.Rotation);
		Projectile(Other).bNoFX = true;
		Other.Destroy();
	}
		
}

defaultproperties
{
}
