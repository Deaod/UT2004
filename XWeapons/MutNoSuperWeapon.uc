//=============================================================================
// NoSuperWeapon - removes Redeemer and Painter
//=============================================================================
class MutNoSuperWeapon extends Mutator;

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
	bSuperRelevant = 0;
    if ( xWeaponBase(Other) != None )
    {
		if ( xWeaponBase(Other).WeaponType == class'Painter' )
			xWeaponBase(Other).WeaponType = class'SniperRifle';
		else if ( xWeaponBase(Other).WeaponType == class'Redeemer' )
			xWeaponBase(Other).WeaponType = class'RocketLauncher';
		else
			return true;
	}
	else if ( WeaponPickup(Other) != None )
	{
		if ( string(Other.Class) == "xWeapons.PainterPickup" )
			ReplaceWith( Other, "xWeapons.SniperRiflePickup");
		else if ( string(Other.Class) == "xWeapons.RedeemerPickup" )
			ReplaceWith( Other, "xWeapons.RocketLauncherPickup");
		else
			return true;
	}
	else
		return true;

	return false;
}

defaultproperties
{
     GroupName="SuperWeapon"
     FriendlyName="No SuperWeapons"
     Description="SuperWeapon pickups are removed from the map."
}
