class RocketAmmoPickup extends UTAmmoPickup;

defaultproperties
{
     AmmoAmount=9
     MaxDesireability=0.300000
     InventoryType=Class'XWeapons.RocketAmmo'
     PickupMessage="You picked up a rocket pack."
     PickupSound=Sound'PickupSounds.RocketAmmoPickup'
     PickupForce="RocketAmmoPickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.RocketAmmoPickup'
     DrawScale=0.700000
     PrePivot=(Z=2.500000)
     CollisionHeight=13.500000
}
