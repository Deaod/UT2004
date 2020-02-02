//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSGrenadePickup extends UTWeaponPickup;

static function StaticPrecache(LevelInfo L)
{
	L.AddPrecacheMaterial(Texture'VMWeaponsTX.PlayerWeaponsGroup.GrenadeTex');
	L.AddPrecacheMaterial(Texture'EpicParticles.Smoke.Smokepuff2');
	L.AddPrecacheMaterial(Texture'AW-2004Particles.Fire.GrenadeTest');
	L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.AirBlast');

	L.AddPrecacheStaticMesh(StaticMesh'VMWeaponsSM.PlayerWeaponsGroup.VMGrenade');
	L.AddPrecacheStaticMesh(default.StaticMesh);
}

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'VMWeaponsTX.PlayerWeaponsGroup.GrenadeTex');
	Level.AddPrecacheMaterial(Texture'EpicParticles.Smoke.Smokepuff2');
	Level.AddPrecacheMaterial(Texture'AW-2004Particles.Fire.GrenadeTest');
	Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.AirBlast');
	super.UpdatePrecacheMaterials();
}

simulated function UpdatePrecacheStaticMeshes()
{
	super.UpdatePrecacheStaticMeshes();
	Level.AddPrecacheStaticMesh(StaticMesh'VMWeaponsSM.PlayerWeaponsGroup.VMGrenade');
}

defaultproperties
{
     StandUp=(Y=0.250000,Z=0.000000)
     MaxDesireability=0.700000
     InventoryType=Class'Onslaught.ONSGrenadeLauncher'
     PickupMessage="You got the Grenade Launcher."
     PickupSound=Sound'PickupSounds.FlakCannonPickup'
     PickupForce="ONSGrenadePickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'ONSWeapons-SM.GrenadeLauncherPickup'
     DrawScale=0.250000
}
