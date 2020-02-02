class FlakAmmoPickup extends UTAmmoPickup;

defaultproperties
{
     AmmoAmount=10
     MaxDesireability=0.320000
     InventoryType=Class'XWeapons.FlakAmmo'
     PickupMessage="You picked up 10 Flak Shells."
     PickupSound=Sound'PickupSounds.FlakAmmoPickup'
     PickupForce="FlakAmmoPickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.FlakAmmoPickup'
     DrawScale=0.800000
     PrePivot=(Z=6.500000)
     CollisionHeight=8.250000
}
