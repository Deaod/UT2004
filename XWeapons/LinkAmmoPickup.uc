class LinkAmmoPickup extends UTAmmoPickup;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	if ( Level.Game.bAllowVehicles )
		MaxDesireability *= 1.9;
}

defaultproperties
{
     AmmoAmount=50
     MaxDesireability=0.240000
     InventoryType=Class'XWeapons.LinkAmmo'
     PickupMessage="You picked up link charges."
     PickupSound=Sound'PickupSounds.LinkAmmoPickup'
     PickupForce="LinkAmmoPickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.LinkAmmoPickup'
     CollisionHeight=10.500000
}
