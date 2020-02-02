class MutUseLightning extends Mutator;

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
	local int i;
	local WeaponLocker L;

	bSuperRelevant = 0;
    if ( xWeaponBase(Other) != None )
    {
		if ( xWeaponBase(Other).WeaponType == class'UTClassic.ClassicSniperRifle' )
			xWeaponBase(Other).WeaponType = class'XWeapons.SniperRifle';
	}
	else if ( ClassicSniperRiflePickup(Other) != None )
		ReplaceWith( Other, "XWeapons.SniperRiflePickup");
	else if ( ClassicSniperAmmoPickup(Other) != None )
		ReplaceWith( Other, "XWeapons.SniperAmmoPickup");
	else if ( WeaponLocker(Other) != None )
	{
		L = WeaponLocker(Other);
		for (i = 0; i < L.Weapons.Length; i++)
			if (L.Weapons[i].WeaponClass == class'ClassicSniperRifle')
				L.Weapons[i].WeaponClass = class'SniperRifle';
		return true;
	}
	else
		return true;
	return false;
}

defaultproperties
{
     GroupName="Arena"
     FriendlyName="Lightning Guns"
     Description="Replace all sniper rifles with lightning guns."
}
