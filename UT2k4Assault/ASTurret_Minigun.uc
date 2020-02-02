//=============================================================================
// ASTurret_Minigun
//=============================================================================

class ASTurret_Minigun extends ASTurret;

function Pawn CheckForHeadShot(Vector loc, Vector ray, float AdditionalScale)
{
    local vector	X, Y, Z, newray;
	local float		Angle, Side;

    GetAxes(Rotation, X, Y, Z);

    if ( Driver != None )
    {
        // Remove the Z component of the ray
        newray = ray;
        newray.Z = 0;

		Angle = abs(newray dot X);
		Side = NewRay dot Y;
        if (  Angle < 0.7 && Side < 0 && Driver.IsHeadShot(loc, ray, AdditionalScale) )			// left
            return Driver;
        else if (  Angle < 0.82 && Side > 0 && Driver.IsHeadShot(loc, ray, AdditionalScale) )	// right
            return Driver;
    }

    return None;
}


static function StaticPrecache(LevelInfo L)
{
    super.StaticPrecache( L );

	L.AddPrecacheMaterial( Material'AS_Weapons_TX.Minigun.ASMinigun1' );		// Skins
	L.AddPrecacheMaterial( Material'AS_Weapons_TX.Minigun.ASMinigun2' );
	L.AddPrecacheMaterial( Material'AS_Weapons_TX.Minigun.ChaingunTop' );
	//L.AddPrecacheMaterial( Material'AS_Weapons_TX.Minigun.ChaingunTopALPHA' );

	L.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp7_frames' );			// Explosion Effect
	L.AddPrecacheMaterial( Material'EpicParticles.Flares.SoftFlare' );
	L.AddPrecacheMaterial( Material'AW-2004Particles.Fire.MuchSmoke2t' );
	L.AddPrecacheMaterial( Material'AS_FX_TX.Trails.Trail_red' );
	L.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp1_frames' );
	L.AddPrecacheMaterial( Material'EmitterTextures.MultiFrame.rockchunks02' );

	L.AddPrecacheStaticMesh( StaticMesh'AS_Weapons_SM.ASMinigun_Base' );
	L.AddPrecacheStaticMesh( StaticMesh'AS_Weapons_SM.ASMinigun_Swivel' );
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh( StaticMesh'AS_Weapons_SM.ASMinigun_Base' );
	Level.AddPrecacheStaticMesh( StaticMesh'AS_Weapons_SM.ASMinigun_Swivel' );

	super.UpdatePrecacheStaticMeshes();
}


simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial( Material'AS_Weapons_TX.Minigun.ASMinigun1' );		// Skins
	Level.AddPrecacheMaterial( Material'AS_Weapons_TX.Minigun.ASMinigun2' );
	Level.AddPrecacheMaterial( Material'AS_Weapons_TX.Minigun.ChaingunTop' );
	//Level.AddPrecacheMaterial( Material'AS_Weapons_TX.Minigun.ChaingunTopALPHA' );

	Level.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp7_frames' );			// Explosion Effect
	Level.AddPrecacheMaterial( Material'EpicParticles.Flares.SoftFlare' );
	Level.AddPrecacheMaterial( Material'AW-2004Particles.Fire.MuchSmoke2t' );
	Level.AddPrecacheMaterial( Material'AS_FX_TX.Trails.Trail_red' );
	Level.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp1_frames' );
	Level.AddPrecacheMaterial( Material'EmitterTextures.MultiFrame.rockchunks02' );

	super.UpdatePrecacheMaterials();
}

defaultproperties
{
     TurretBaseClass=Class'UT2k4Assault.ASTurret_Minigun_Base'
     TurretSwivelClass=Class'UT2k4Assault.ASTurret_Minigun_Swivel'
     RotationInertia=0.500000
     RotPitchConstraint=(Min=10000.000000,Max=5000.000000)
     RotationSpeed=10.000000
     CamAbsLocation=(Z=50.000000)
     CamRelLocation=(X=100.000000,Z=50.000000)
     CamDistance=(X=-400.000000,Z=50.000000)
     CamRotationInertia=0.010000
     DefaultWeaponClassName="UT2k4Assault.Weapon_Turret_Minigun"
     VehicleProjSpawnOffset=(X=160.000000,Y=-15.000000,Z=66.000000)
     bCHZeroYOffset=False
     bDrawDriverInTP=True
     bAutoTurret=False
     bRemoteControlled=False
     bDrawMeshInFP=True
     DrivePos=(X=-20.000000,Y=13.000000,Z=81.000000)
     ExitPositions(0)=(Y=100.000000,Z=100.000000)
     ExitPositions(1)=(Y=-100.000000,Z=100.000000)
     EntryRadius=120.000000
     FPCamPos=(X=-25.000000,Y=13.000000,Z=93.000000)
     DriverDamageMult=0.450000
     VehiclePositionString="manning a Minigun Turret"
     VehicleNameString="Minigun Turret"
     HealthMax=500.000000
     Health=500
     Mesh=SkeletalMesh'AS_Vehicles_M.minigun_turret'
     DrawScale=0.420000
     SoundRadius=1024.000000
     CollisionRadius=60.000000
}
