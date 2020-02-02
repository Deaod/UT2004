//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSMineLayerPickup extends UTWeaponPickup;

#exec OBJ LOAD FILE=VMWeaponsSM.usx

static function StaticPrecache(LevelInfo L)
{
	L.AddPrecacheMaterial(Texture'VMWeaponsTX.PlayerWeaponsGroup.SpiderMineTEX');
	L.AddPrecacheMaterial(Shader'VMWeaponsTX.PlayerWeaponsGroup.ParasiteMineImplantTEXshad');
	L.AddPrecacheMaterial(Texture'VMWeaponsTX.PlayerWeaponsGroup.SpiderMineBLUETEX');
	L.AddPrecacheMaterial(Texture'XGameShaders.WeaponShaders.bio_flash');
	L.AddPrecacheMaterial(Texture'AW-2004Particles.Weapons.BeamFragment');
	L.AddPrecacheStaticMesh(default.StaticMesh);
}

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'VMWeaponsTX.PlayerWeaponsGroup.SpiderMineTEX');
	Level.AddPrecacheMaterial(Shader'VMWeaponsTX.PlayerWeaponsGroup.ParasiteMineImplantTEXshad');
	Level.AddPrecacheMaterial(Texture'VMWeaponsTX.PlayerWeaponsGroup.SpiderMineBLUETEX');
	Level.AddPrecacheMaterial(Texture'XGameShaders.WeaponShaders.bio_flash');
	Level.AddPrecacheMaterial(Texture'AW-2004Particles.Weapons.BeamFragment');
	super.UpdatePrecacheMaterials();
}

defaultproperties
{
     StandUp=(Y=0.250000,Z=0.000000)
     MaxDesireability=0.700000
     InventoryType=Class'Onslaught.ONSMineLayer'
     PickupMessage="You got the Mine Layer."
     PickupSound=Sound'PickupSounds.FlakCannonPickup'
     PickupForce="ONSMineLayerPickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'ONSWeapons-SM.MineLayerPickup'
     DrawScale=0.300000
}
