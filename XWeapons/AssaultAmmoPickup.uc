class AssaultAmmoPickup extends UTAmmoPickup;

defaultproperties
{
     AmmoAmount=4
     InventoryType=Class'XWeapons.GrenadeAmmo'
     PickupMessage="You got a box of grenades and bullets."
     PickupSound=Sound'PickupSounds.AssaultAmmoPickup'
     PickupForce="AssaultAmmoPickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.AssaultAmmoPickup'
     TransientSoundVolume=0.400000
     CollisionHeight=12.500000
}
