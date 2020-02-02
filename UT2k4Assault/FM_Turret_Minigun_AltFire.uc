class FM_Turret_Minigun_AltFire extends WeaponFire;

simulated function bool AllowFire()
{
    return true;
}

defaultproperties
{
     bModeExclusive=False
}
