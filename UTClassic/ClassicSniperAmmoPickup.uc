class ClassicSniperAmmoPickup extends UTAmmoPickup;

defaultproperties
{
     AmmoAmount=10
     InventoryType=Class'UTClassic.ClassicSniperAmmo'
     PickupMessage="You picked up sniper ammo."
     PickupSound=Sound'PickupSounds.SniperAmmoPickup'
     PickupForce="SniperAmmoPickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'NewWeaponStatic.ClassicSniperAmmoM'
     PrePivot=(Z=16.000000)
     CollisionHeight=16.000000
}
