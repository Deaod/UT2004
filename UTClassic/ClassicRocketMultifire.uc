class ClassicRocketMultifire extends RocketMultifire;

function ModeTick(float dt)
{
    // auto fire if loaded last rocket
    if (HoldTime > 0.0 && Load >= Weapon.AmmoAmount(ThisModeNum) && !bNowWaiting)
    {
        bIsFiring = false;
    }

    Super(ProjectileFire).ModeTick(dt);

    if ( (Load <= 5) && HoldTime >= FireRate*Load)
    {
        if (Instigator.IsLocallyControlled())
        	RocketLauncher(Weapon).PlayLoad(false);
		else
			ServerPlayLoading();
        Load = Load + 1.0;
    }
}

event ModeDoFire()
{
	MaxHoldTime = 0;
	Super.ModeDoFire();
	MaxHoldTime = Default.MaxHoldTime;
}

function DoFireEffect()
{
	Weapon.GetFireMode(0).NextFireTime = Level.TimeSeconds + FireRate;
	Weapon.GetFireMode(1).NextFireTime = Level.TimeSeconds + FireRate;

	Super.DoFireEffect();
}

defaultproperties
{
     MaxLoad=6
     MaxHoldTime=7.700000
     FireAnimRate=0.760000
     FireRate=1.250000
}
