//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSRVChainGunFireEffect extends ONSWeaponAmbientEmitter;

simulated function SetEmitterStatus(bool bEnabled)
{
	Emitters[0].UseCollision = ( !Level.bDropDetail && (Level.DetailMode != DM_Low) && (VSize(Level.GetLocalPlayerController().ViewTarget.Location - Location) < 1600));
	if(bEnabled)
	{
		Emitters[0].ParticlesPerSecond = 20.0;
		Emitters[0].InitialParticlesPerSecond = 20.0;
		Emitters[0].AllParticlesDead = false;

		Emitters[1].ParticlesPerSecond = 30.0;
		Emitters[1].InitialParticlesPerSecond = 30.0;
		Emitters[1].AllParticlesDead = false;
	}
	else
	{
		Emitters[0].ParticlesPerSecond = 0.0;
		Emitters[0].InitialParticlesPerSecond = 0.0;

		Emitters[1].ParticlesPerSecond = 0.0;
		Emitters[1].InitialParticlesPerSecond = 0.0;
	}
}

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter0
         StaticMesh=StaticMesh'VMmeshEmitted.EJECTA.EjectedBRASSsm'
         UseCollision=True
         RespawnDeadParticles=False
         SpawnOnlyInDirectionOfNormal=True
         SpinParticles=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-500.000000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         MaxParticles=30
         StartLocationOffset=(X=-80.000000,Y=-6.000000,Z=10.000000)
         MeshNormal=(Z=0.000000)
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Min=0.100000,Max=1.000000),Y=(Min=0.100000,Max=1.000000),Z=(Min=0.100000,Max=1.000000))
         StartSizeRange=(X=(Min=0.050000,Max=0.050000),Y=(Min=0.050000,Max=0.050000),Z=(Min=0.050000,Max=0.050000))
         LifetimeRange=(Min=1.500000,Max=1.500000)
         StartVelocityRange=(X=(Min=-150.000000,Max=150.000000),Y=(Min=-250.000000,Max=-250.000000),Z=(Min=50.000000,Max=150.000000))
         StartVelocityRadialRange=(Min=-250.000000,Max=250.000000)
     End Object
     Emitters(0)=MeshEmitter'Onslaught.ONSRVChainGunFireEffect.MeshEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
         CoordinateSystem=PTCS_Relative
         MaxParticles=6
         StartLocationOffset=(Z=10.000000)
         StartLocationShape=PTLS_Sphere
         UseRotationFrom=PTRS_Normal
         SpinsPerSecondRange=(X=(Min=7.000000,Max=11.000000))
         SizeScale(0)=(RelativeTime=0.250000,RelativeSize=0.750000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=0.100000)
         StartSizeRange=(X=(Min=20.000000,Max=20.000000))
         Texture=Texture'VMParticleTextures.TankFiringP.CloudParticleOrangeBMPtex'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.050000,Max=0.050000)
         WarmupTicksPerSecond=50.000000
         RelativeWarmupTime=2.000000
     End Object
     Emitters(1)=SpriteEmitter'Onslaught.ONSRVChainGunFireEffect.SpriteEmitter0'

     CullDistance=4000.000000
     bNoDelete=False
     DrawScale3D=(X=0.250000,Y=0.250000,Z=0.250000)
     bUnlit=False
     bHardAttach=True
}
