class ClassicFlakCannon extends FlakCannon
	HideDropDown
	CacheExempt;

defaultproperties
{
     FireModeClass(0)=Class'UTClassic.ClassicFlakFire'
     FireModeClass(1)=Class'UTClassic.ClassicFlakAltFire'
     SelectAnimRate=0.750000
     BringUpTime=0.600000
     MinReloadPct=1.000000
     PickupClass=Class'UTClassic.ClassicFlakCannonPickup'
}
