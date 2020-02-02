//=============================================================================
// SuperShockRiflePickup
//=============================================================================
class SuperShockRiflePickup extends UTWeaponPickup;

defaultproperties
{
     MaxDesireability=0.650000
     InventoryType=Class'XWeapons.SuperShockRifle'
     PickupMessage="You got the Super Shock Rifle."
     PickupSound=Sound'PickupSounds.ShockRiflePickup'
     PickupForce="ShockRiflePickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.ShockRiflePickup'
     DrawScale=0.500000
}
