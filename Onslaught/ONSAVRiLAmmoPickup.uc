//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSAVRiLAmmoPickup extends UTAmmoPickup;

defaultproperties
{
     AmmoAmount=5
     InventoryType=Class'Onslaught.ONSAVRiLAmmo'
     PickupMessage="You picked up some anti-vehicle rockets"
     PickupSound=Sound'PickupSounds.FlakAmmoPickup'
     PickupForce="FlakAmmoPickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'ONSWeapons-SM.AVRILammo'
     DrawScale=0.400000
}
