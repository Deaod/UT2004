//=============================================================================
// AssaultRiflePickup.
//=============================================================================
class AssaultRiflePickup extends UTWeaponPickup;

defaultproperties
{
     StandUp=(Y=0.250000,Z=0.000000)
     MaxDesireability=0.400000
     InventoryType=Class'XWeapons.AssaultRifle'
     PickupMessage="You got the Assault Rifle."
     PickupSound=Sound'PickupSounds.AssaultRiflePickup'
     PickupForce="AssaultRiflePickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'NewWeaponPickups.AssaultPickupSM'
     DrawScale=0.500000
}
