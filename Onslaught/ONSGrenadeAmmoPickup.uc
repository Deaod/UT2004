//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSGrenadeAmmoPickup extends UTAmmoPickup;

defaultproperties
{
     AmmoAmount=5
     InventoryType=Class'Onslaught.ONSGrenadeAmmo'
     PickupMessage="You picked up some grenades"
     PickupSound=Sound'PickupSounds.FlakAmmoPickup'
     PickupForce="FlakAmmoPickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'ONSWeapons-SM.GrenadeLauncherAmmo'
     DrawScale=0.250000
}
