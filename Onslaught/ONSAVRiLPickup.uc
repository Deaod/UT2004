//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSAVRiLPickup extends UTWeaponPickup;

#exec OBJ LOAD FILE=VMWeaponsSM.usx

static function StaticPrecache(LevelInfo L)
{
	L.AddPrecacheMaterial(Texture'VMWeaponsTX.PlayerWeaponsGroup.AVRiLtex');
	L.AddPrecacheMaterial(Texture'AW-2004Particles.Weapons.DustSmoke');
    L.AddPrecacheMaterial(Texture'ONSInterface-TX.avrilRETICLE');
    L.AddPrecacheMaterial(Texture'VMWeaponsTX.PlayerWeaponsGroup.LGRreticleRed');
	L.AddPrecacheStaticMesh(StaticMesh'VMWeaponsSM.AVRiLGroup.AVRiLprojectileSM');
	L.AddPrecacheStaticMesh(StaticMesh'VMWeaponsSM.AVRiLsm');
}

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'VMWeaponsTX.PlayerWeaponsGroup.AVRiLtex');
	Level.AddPrecacheMaterial(Texture'VMParticleTextures.VehicleExplosions.VMExp2_framesANIM');
	Level.AddPrecacheMaterial(Texture'AW-2004Particles.Weapons.DustSmoke');
    Level.AddPrecacheMaterial(Texture'ONSInterface-TX.avrilRETICLE');
    Level.AddPrecacheMaterial(Texture'VMWeaponsTX.PlayerWeaponsGroup.LGRreticleRed');
	super.UpdatePrecacheMaterials();
}

simulated function UpdatePrecacheStaticMeshes()
{
	super.UpdatePrecacheStaticMeshes();
	Level.AddPrecacheStaticMesh(StaticMesh'VMWeaponsSM.AVRiLGroup.AVRiLprojectileSM');
	Level.AddPrecacheStaticMesh(StaticMesh'VMWeaponsSM.AVRiLsm');
}

defaultproperties
{
     StandUp=(Y=0.250000,Z=0.000000)
     MaxDesireability=0.700000
     InventoryType=Class'Onslaught.ONSAVRiL'
     PickupMessage="You got the AVRiL."
     PickupSound=Sound'PickupSounds.FlakCannonPickup'
     PickupForce="ONSAVRiLPickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'VMWeaponsSM.PlayerWeaponsGroup.AVRiLsm'
     DrawScale=0.050000
}
