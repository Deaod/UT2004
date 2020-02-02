//=============================================================================
// ShieldGunPickup.
//=============================================================================
class ShieldGunPickup extends UTWeaponPickup;

defaultproperties
{
     MaxDesireability=0.390000
     InventoryType=Class'XWeapons.ShieldGun'
     PickupMessage="You got the Shield Gun."
     PickupSound=Sound'PickupSounds.ShieldGunPickup'
     PickupForce="ShieldGunPickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.ShieldGunPickup'
     DrawScale=0.500000
}
