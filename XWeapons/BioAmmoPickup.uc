class BioAmmoPickup extends UTAmmoPickup;

#exec OBJ LOAD FILE=PickupSounds.uax

simulated function PostBeginPlay()
{
	local actor HitActor;
	local vector HitLocation, HitNormal;
	
	Super.PostBeginPlay();
	
	// check to see if imbedded (stupid LD)
	HitActor = Trace(HitLocation, HitNormal, Location - CollisionHeight * vect(0,0,1), Location + CollisionHeight * vect(0,0,1), false);
	if ( (HitActor != None) && HitActor.bWorldGeometry )
		SetLocation(HitLocation + vect(0,0,1) * CollisionHeight);
}

defaultproperties
{
     AmmoAmount=20
     MaxDesireability=0.320000
     InventoryType=Class'XWeapons.BioAmmo'
     PickupMessage="You picked up some Bio-Rifle ammo"
     PickupSound=Sound'PickupSounds.FlakAmmoPickup'
     PickupForce="FlakAmmoPickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.BioAmmoPickup'
     PrePivot=(Z=10.500000)
     CollisionHeight=8.250000
}
