class UTAmmoPickup extends Ammo;

function RespawnEffect()
{
	spawn(class'PlayerSpawnEffect');
}

defaultproperties
{
     MessageClass=Class'UnrealGame.PickupMessagePlus'
}
