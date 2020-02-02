class SniperAmmoPickup extends UTAmmoPickup;

defaultproperties
{
     AmmoAmount=10
     InventoryType=Class'XWeapons.SniperAmmo'
     PickupMessage="You picked up lightning ammo."
     PickupSound=Sound'PickupSounds.SniperAmmoPickup'
     PickupForce="SniperAmmoPickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.SniperAmmoPickup'
     CollisionHeight=19.000000
}
