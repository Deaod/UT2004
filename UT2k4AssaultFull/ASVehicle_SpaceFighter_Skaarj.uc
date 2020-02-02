//=============================================================================
// ASVehicle_SpaceFighter_Skaarj
//=============================================================================

class ASVehicle_SpaceFighter_Skaarj extends ASVehicle_SpaceFighter_Human;

function vector GetBotError(vector StartLocation)
{
	local vector Err;
	
	Err = Super.GetBotError(StartLocation);
	
	if ( (Level.NetMode != NM_Standalone) || (PlayerReplicationInfo == None) || (PlayerReplicationInfo.Team != Level.GetLocalPlayerController().PlayerReplicationInfo.Team) )
		return Err;

	return 1.1 * Err;		
}

simulated function AnimateSkelMesh( float SpeedPct )
{
	SetAnimFrame( FClamp(SpeedPct, 0.f, 0.9f) );
}

simulated function PlayTakeOff()
{
	// Play Take Off animation
	PlayAnim('TakeOff', 0.1);
}

simulated function DrawHealthInfo( Canvas C, PlayerController PC )
{
	class'HUD_Assault'.static.DrawCustomHealthInfo( C, PC, true );
}

static function StaticPrecache(LevelInfo L)
{
    super.StaticPrecache( L );

	L.AddPrecacheMaterial( Material'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Skaarj1' );		// Skins
	L.AddPrecacheMaterial( Material'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Skaarj2' );

	L.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp7_frames' );			// Explosion Effect
	L.AddPrecacheMaterial( Material'EpicParticles.Flares.SoftFlare' );
	L.AddPrecacheMaterial( Material'AW-2004Particles.Fire.MuchSmoke2t' );
	L.AddPrecacheMaterial( Material'AS_FX_TX.Trails.Trail_red' );
	L.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp1_frames' );
	L.AddPrecacheMaterial( Material'EmitterTextures.MultiFrame.rockchunks02' );

	L.AddPrecacheMaterial( Texture'AS_FX_TX.Trails.Trail_blue' );				// FX
	L.AddPrecacheMaterial( Texture'AS_FX_TX.Trails.Trail_red' );
	L.AddPrecacheMaterial( Texture'EpicParticles.Flares.FlashFlare1' );
	L.AddPrecacheMaterial( Texture'AS_FX_TX.Flares.Laser_Flare' );
	L.AddPrecacheMaterial( Material'XEffectMat.RedShell' );
	L.AddPrecacheMaterial( Material'XEffectMat.BlueShell' );
	L.AddPrecacheMaterial( Texture'AS_FX_TX.Beams.LaserTex' );
	L.AddPrecacheMaterial( Texture'EpicParticles.Flares.FlickerFlare' );
	L.AddPrecacheMaterial( Texture'EpicParticles.Smoke.StellarFog1aw' );
	L.AddPrecacheMaterial( Texture'XGameShaders.Trans.TransRingEnergy' );

	L.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Grey' );		// HUD
	L.AddPrecacheMaterial( Texture'InterfaceContent.WhileSquare' );
	L.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Solid' );
	L.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Speed_Solid' );
	L.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.AssaultRadar' );

	L.AddPrecacheStaticMesh( StaticMesh'WeaponStaticMesh.Shield' );
	L.AddPrecacheStaticMesh( StaticMesh'AS_Vehicles_SM.Vehicles.SpaceFighter_Skaarj_FP' );
	L.AddPrecacheStaticMesh( StaticMesh'AS_Weapons_SM.Projectiles.Skaarj_Energy' );
}


simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh( StaticMesh'WeaponStaticMesh.Shield' );
	Level.AddPrecacheStaticMesh( StaticMesh'AS_Vehicles_SM.Vehicles.SpaceFighter_Skaarj_FP' );
	Level.AddPrecacheStaticMesh( StaticMesh'AS_Weapons_SM.Projectiles.Skaarj_Energy' );

	super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial( Material'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Skaarj1' );		// Skins
	Level.AddPrecacheMaterial( Material'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Skaarj2' );

	Level.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp7_frames' );			// Explosion Effect
	Level.AddPrecacheMaterial( Material'EpicParticles.Flares.SoftFlare' );
	Level.AddPrecacheMaterial( Material'AW-2004Particles.Fire.MuchSmoke2t' );
	Level.AddPrecacheMaterial( Material'AS_FX_TX.Trails.Trail_red' );
	Level.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp1_frames' );
	Level.AddPrecacheMaterial( Material'EmitterTextures.MultiFrame.rockchunks02' );

	Level.AddPrecacheMaterial( Texture'AS_FX_TX.Trails.Trail_blue' );				// FX
	Level.AddPrecacheMaterial( Texture'AS_FX_TX.Trails.Trail_red' );
	Level.AddPrecacheMaterial( Texture'EpicParticles.Flares.FlashFlare1' );
	Level.AddPrecacheMaterial( Texture'AS_FX_TX.Flares.Laser_Flare' );
	Level.AddPrecacheMaterial( Material'XEffectMat.RedShell' );
	Level.AddPrecacheMaterial( Material'XEffectMat.BlueShell' );
	Level.AddPrecacheMaterial( Texture'AS_FX_TX.Beams.LaserTex' );
	Level.AddPrecacheMaterial( Texture'EpicParticles.Flares.FlickerFlare' );
	Level.AddPrecacheMaterial( Texture'EpicParticles.Smoke.StellarFog1aw' );
	Level.AddPrecacheMaterial( Texture'XGameShaders.Trans.TransRingEnergy' );

	Level.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Grey' );		// HUD
	Level.AddPrecacheMaterial( Texture'InterfaceContent.WhileSquare' );
	Level.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Solid_Skaarj' );
	Level.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Speed_Solid_Skaarj' );
	Level.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.AssaultRadar' );

	super.UpdatePrecacheMaterials();
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     bHumanShip=False
     FlyingAnim="Flying"
     TrailOffset=67.000000
     RocketOffset=(X=0.000000,Z=-20.000000)
     WeaponInfoTexture=Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Solid_Skaarj'
     SpeedInfoTexture=Texture'AS_FX_TX.HUD.SpaceHUD_Speed_Solid_Skaarj'
     DefaultWeaponClassName="UT2k4AssaultFull.Weapon_SpaceFighter_Skaarj"
     VehicleProjSpawnOffset=(X=55.000000,Y=45.000000,Z=0.000000)
     DefaultCrosshair=Texture'Crosshairs.HUD.Crosshair_Triad3'
     FPCamPos=(X=-20.000000)
     VehicleNameString="Skaarj Spacefighter"
     AmbientSound=Sound'AssaultSounds.SkaarjShip.SkShipEng01'
     Mesh=SkeletalMesh'AS_VehiclesFull_M.SpaceFighter_Skaarj'
     DrawScale=0.350000
}
