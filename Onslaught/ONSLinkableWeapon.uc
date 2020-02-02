//-----------------------------------------------------------
// Works just like ONSWeapon only allows for child weapons
// that aim at the same target as the parent.
//-----------------------------------------------------------
class ONSLinkableWeapon extends ONSWeapon
    native
    abstract;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var ONSWeapon ChildWeapon;  // Child weapons automatically inherit the aim location and firing events of the parent

replication
{
    reliable if (bNetDirty && bNetOwner && Role == ROLE_Authority)
        ChildWeapon;
}

event bool AttemptFire(Controller C, bool bAltFire)
{
  	if(Role != ROLE_Authority || bForceCenterAim)
		return False;

	if (FireCountdown <= 0)
	{
		CalcWeaponFire();
		if (bCorrectAim)
			WeaponFireRotation = AdjustAim(bAltFire);
		if (Spread > 0)
			WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand()*FRand()*Spread);

        	DualFireOffset *= -1;

		Instigator.MakeNoise(1.0);
		if (bAltFire)
		{
			FireCountdown = AltFireInterval;
			AltFire(C);
		}
		else
		{
		    FireCountdown = FireInterval;
		    Fire(C);
		}
		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

		if (ChildWeapon != None)
            ChildWeapon.AttemptFire(C, bAltFire);

	    return True;
	}

	return False;
}

simulated function Destroyed()
{
	if (ChildWeapon != None)
        ChildWeapon.Destroy();

    Super.Destroyed();
}

defaultproperties
{
}
