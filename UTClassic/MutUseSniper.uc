class MutUseSniper extends Mutator;

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
	local int i;
	local WeaponLocker L;

	bSuperRelevant = 0;
    if ( xWeaponBase(Other) != None )
    {
		if ( xWeaponBase(Other).WeaponType == class'XWeapons.SniperRifle' )
			xWeaponBase(Other).WeaponType = class'UTClassic.ClassicSniperRifle';
	}
	else if ( SniperRiflePickup(Other) != None )
		ReplaceWith( Other, "UTClassic.ClassicSniperRiflePickup");
	else if ( SniperAmmoPickup(Other) != None )
		ReplaceWith( Other, "UTClassic.ClassicSniperAmmoPickup");
	else if ( WeaponLocker(Other) != None )
	{
		L = WeaponLocker(Other);
		for (i = 0; i < L.Weapons.Length; i++)
			if (L.Weapons[i].WeaponClass == class'SniperRifle')
				L.Weapons[i].WeaponClass = class'ClassicSniperRifle';
		return true;
	}
	else
		return true;
	return false;
}

defaultproperties
{
     GroupName="Arena"
     FriendlyName="Sniper Rifles"
     Description="Replace all lightning guns with sniper rifles."
}
