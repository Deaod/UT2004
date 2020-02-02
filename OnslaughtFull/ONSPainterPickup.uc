class ONSPainterPickup extends PainterPickup;

#exec OBJ LOAD FILE=..\Textures\VMWeaponsTX.utx
#exec OBJ LOAD FILE=..\Textures\VMParticleTextures.utx
#exec OBJ LOAD FILE=..\StaticMeshes\VMWeaponsSM.usx

static function StaticPrecache(LevelInfo L)
{
	L.AddPrecacheMaterial(Texture'VMWeaponsTX.PlayerWeaponsGroup.bomberBomb');
	L.AddPrecacheMaterial(Texture'ONSFullTextures.PlayerWeaponsGroup.TargetPainterTEX');
	L.AddPrecacheMaterial(Texture'VMWeaponsTX.PlayerWeaponsGroup.trailsEmitterRED');
	L.AddPrecacheMaterial(Texture'XEffectMat.Ion.painter_beam');
	L.AddPrecacheMaterial(Texture'XGameShaders.ZoomFX.fulloverlay');
	L.AddPrecacheMaterial(Texture'XGameShaders.ZoomFX.scanline');
	L.AddPrecacheMaterial(Texture'XWeapons_rc.Icons.SniperBorder');
	L.AddPrecacheMaterial(Texture'XWeapons_rc.Icons.SniperFocus');
	L.AddPrecacheMaterial(Texture'XWeapons_rc.Icons.SniperArrows');
	L.AddPrecacheMaterial(Texture'Engine.WhiteTexture');
	L.AddPrecacheMaterial(Texture'VMParticleTextures.LeviathanParticleEffects.rainbowSpikes');
	L.AddPrecacheMaterial(Texture'VMParticleTextures.LeviathanParticleEffects.darkEnergy');
	L.AddPrecacheMaterial(Texture'VMParticleTextures.LeviathanParticleEffects.LEVsingBLIP');
	L.AddPrecacheMaterial(Texture'ONSFullTextures.BomberGroup.BomberColorRed');
	L.AddPrecacheMaterial(Texture'ONSFullTextures.BomberGroup.bomberNOcolor');
	L.AddPrecacheMaterial(Texture'AW-2004Explosions.Fire.Part_explode2');
	L.AddPrecacheMaterial(Texture'EpicParticles.Smoke.Smokepuff');
	L.AddPrecacheMaterial(Texture'EpicParticles.Shaders.Grad_Falloff');
	L.AddPrecacheMaterial(Texture'EpicParticles.Fire.IonBurn');
	L.AddPrecacheMaterial(Texture'EpicParticles.Beams.WhiteStreak01aw');

	L.AddPrecacheStaticMesh(StaticMesh'VMWeaponsSM.PlayerWeaponsGroup.bomberBomb');
}

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'VMWeaponsTX.PlayerWeaponsGroup.bomberBomb');
	Level.AddPrecacheMaterial(Texture'ONSFullTextures.PlayerWeaponsGroup.TargetPainterTEX');
	Level.AddPrecacheMaterial(Texture'VMWeaponsTX.PlayerWeaponsGroup.trailsEmitterRED');
	Level.AddPrecacheMaterial(Texture'XEffectMat.Ion.painter_beam');
	Level.AddPrecacheMaterial(Texture'XGameShaders.ZoomFX.fulloverlay');
	Level.AddPrecacheMaterial(Texture'XGameShaders.ZoomFX.scanline');
	Level.AddPrecacheMaterial(Texture'XWeapons_rc.Icons.SniperBorder');
	Level.AddPrecacheMaterial(Texture'XWeapons_rc.Icons.SniperFocus');
	Level.AddPrecacheMaterial(Texture'XWeapons_rc.Icons.SniperArrows');
	Level.AddPrecacheMaterial(Texture'VMParticleTextures.LeviathanParticleEffects.rainbowSpikes');
	Level.AddPrecacheMaterial(Texture'VMParticleTextures.LeviathanParticleEffects.darkEnergy');
	Level.AddPrecacheMaterial(Texture'VMParticleTextures.LeviathanParticleEffects.LEVsingBLIP');
	Level.AddPrecacheMaterial(Texture'Engine.WhiteTexture');
	Level.AddPrecacheMaterial(Texture'ONSFullTextures.BomberGroup.bomberNOcolor');
	Level.AddPrecacheMaterial(Texture'ONSFullTextures.BomberGroup.BomberColorRed');
	Level.AddPrecacheMaterial(Texture'AW-2004Explosions.Fire.Part_explode2');
	Level.AddPrecacheMaterial(Texture'EpicParticles.Smoke.Smokepuff');
	Level.AddPrecacheMaterial(Texture'EpicParticles.Shaders.Grad_Falloff');
	Level.AddPrecacheMaterial(Texture'EpicParticles.Fire.IonBurn');
	Level.AddPrecacheMaterial(Texture'EpicParticles.Beams.WhiteStreak01aw');

	super.UpdatePrecacheMaterials();
}

defaultproperties
{
     InventoryType=Class'OnslaughtFull.ONSPainter'
     RespawnTime=60.000000
     PickupMessage="You got the Target Painter."
     StaticMesh=StaticMesh'ONSFullStaticMeshes.TargetPainter.TargetPainterStatic'
     DrawScale=0.175000
}
