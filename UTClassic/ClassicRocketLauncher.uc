class ClassicRocketLauncher extends RocketLauncher
	HideDropDown
	CacheExempt;


simulated event ClientStartFire(int Mode)
{
	if ( Mode == 0 )
	{
		SetTightSpread(false);
	}
    else if ( FireMode[0].bIsFiring || (FireMode[0].NextFireTime > Level.TimeSeconds) )
    {
		if ( FireMode[0].Load > 0 )
			SetTightSpread(true);
		return;
    }
    Super(Weapon).ClientStartFire(Mode);
}

defaultproperties
{
     FireModeClass(0)=Class'UTClassic.ClassicRocketMultifire'
     FireModeClass(1)=Class'UTClassic.ClassicGrenadeFire'
     SelectAnimRate=0.750000
     BringUpTime=0.600000
     MinReloadPct=1.000000
     PickupClass=Class'UTClassic.ClassicRocketLauncherPickup'
}
