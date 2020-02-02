class ZoomSuperShockBeamFire extends SuperShockBeamFire
	config;

var config bool bAllowMultiHit;

function bool AllowMultiHit()
{
	return bAllowMultiHit;
}

defaultproperties
{
     bAllowMultiHit=True
     DamageType=Class'XWeapons.ZoomSuperShockBeamDamage'
}
