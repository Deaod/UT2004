class MinigunAmmoPickup extends UTAmmoPickup;

defaultproperties
{
     AmmoAmount=50
     InventoryType=Class'XWeapons.MinigunAmmo'
     PickupMessage="You picked up 50 bullets."
     PickupSound=Sound'PickupSounds.MinigunAmmoPickup'
     PickupForce="MinigunAmmoPickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.MinigunAmmoPickup'
     CollisionHeight=12.750000
}
