//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSMineAmmoPickup extends UTAmmoPickup;

defaultproperties
{
     AmmoAmount=8
     InventoryType=Class'Onslaught.ONSMineAmmo'
     PickupMessage="You picked up some parasite mines"
     PickupSound=Sound'PickupSounds.FlakAmmoPickup'
     PickupForce="FlakAmmoPickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'ONSWeapons-SM.MineLayerAmmo'
     DrawScale=0.400000
}
