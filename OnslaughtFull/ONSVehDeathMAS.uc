class ONSVehDeathMAS extends Emitter;

#exec OBJ LOAD FILE="..\Textures\ExplosionTex.utx"
#exec OBJ LOAD FILE="..\StaticMeshes\ONSFullStaticMeshes.usx"

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter50
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         StartLocationRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-50.000000,Max=150.000000))
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         InitialParticlesPerSecond=20.000000
         Texture=Texture'ExplosionTex.Framed.exp1_frames'
         TextureUSubdivisions=2
         TextureVSubdivisions=4
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(0)=SpriteEmitter'OnslaughtFull.ONSVehDeathMAS.SpriteEmitter50'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter51
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         MaxParticles=20
         DetailMode=DM_High
         StartLocationRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-50.000000,Max=150.000000))
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         InitialParticlesPerSecond=100.000000
         Texture=Texture'ExplosionTex.Framed.we1_frames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=1.000000,Max=1.000000)
         InitialDelayRange=(Min=0.700000,Max=0.700000)
     End Object
     Emitters(1)=SpriteEmitter'OnslaughtFull.ONSVehDeathMAS.SpriteEmitter51'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter53
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         MaxParticles=20
         StartLocationRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-50.000000,Max=150.000000))
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         InitialParticlesPerSecond=100.000000
         Texture=Texture'ExplosionTex.Framed.exp2_frames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=1.000000,Max=1.000000)
         InitialDelayRange=(Min=0.700000,Max=0.700000)
         StartVelocityRadialRange=(Min=-40.000000,Max=-50.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(2)=SpriteEmitter'OnslaughtFull.ONSVehDeathMAS.SpriteEmitter53'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter55
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         MaxParticles=3
         DetailMode=DM_High
         StartLocationOffset=(Z=100.000000)
         StartLocationRange=(X=(Min=-50.000000,Max=50.000000))
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.250000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=400.000000,Max=400.000000))
         InitialParticlesPerSecond=20.000000
         Texture=Texture'ExplosionTex.Framed.exp2_frames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.700000,Max=0.700000)
         InitialDelayRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(3)=SpriteEmitter'OnslaughtFull.ONSVehDeathMAS.SpriteEmitter55'

     Begin Object Class=MeshEmitter Name=MeshEmitter34
         StaticMesh=StaticMesh'ParticleMeshes.Complex.ExplosionRing'
         UseParticleColor=True
         UseColorScale=True
         RespawnDeadParticles=False
         Disabled=True
         Backup_Disabled=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=28,G=141,R=255))
         ColorScale(1)=(RelativeTime=0.850000,Color=(B=28,G=141,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=1
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=8.000000)
         InitialParticlesPerSecond=500.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
         InitialDelayRange=(Min=0.600000,Max=0.600000)
     End Object
     Emitters(4)=MeshEmitter'OnslaughtFull.ONSVehDeathMAS.MeshEmitter34'

     Begin Object Class=MeshEmitter Name=MeshEmitter39
         StaticMesh=StaticMesh'ParticleMeshes.Complex.ExplosionRing'
         UseParticleColor=True
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=28,G=141,R=255))
         ColorScale(1)=(RelativeTime=0.850000,Color=(B=28,G=141,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=1
         StartLocationOffset=(Z=100.000000)
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=8.000000)
         InitialParticlesPerSecond=500.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
         InitialDelayRange=(Min=0.700000,Max=0.700000)
     End Object
     Emitters(5)=MeshEmitter'OnslaughtFull.ONSVehDeathMAS.MeshEmitter39'

     Begin Object Class=MeshEmitter Name=MeshEmitter35
         StaticMesh=StaticMesh'ONSFullStaticMeshes.LEVexploded.BayDoor'
         UseMeshBlendMode=False
         UseParticleColor=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-900.000000)
         ColorScale(0)=(Color=(B=192,G=192,R=192,A=255))
         ColorScale(1)=(RelativeTime=0.950000,Color=(B=128,G=128,R=128,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
         MaxParticles=1
         DetailMode=DM_High
         StartLocationOffset=(Y=75.000000,Z=150.000000)
         UseRotationFrom=PTRS_Actor
         SpinCCWorCW=(Z=0.000000)
         SpinsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         LifetimeRange=(Min=2.000000,Max=2.000000)
         InitialDelayRange=(Min=0.550000,Max=0.550000)
         StartVelocityRange=(Y=(Min=200.000000,Max=300.000000),Z=(Min=800.000000,Max=1000.000000))
     End Object
     Emitters(6)=MeshEmitter'OnslaughtFull.ONSVehDeathMAS.MeshEmitter35'

     Begin Object Class=MeshEmitter Name=MeshEmitter37
         StaticMesh=StaticMesh'ONSFullStaticMeshes.LEVexploded.BayDoor'
         UseMeshBlendMode=False
         UseParticleColor=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-900.000000)
         ColorScale(0)=(Color=(B=192,G=192,R=192,A=255))
         ColorScale(1)=(RelativeTime=0.950000,Color=(B=128,G=128,R=128,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
         MaxParticles=1
         DetailMode=DM_High
         StartLocationOffset=(Y=-75.000000,Z=150.000000)
         UseRotationFrom=PTRS_Actor
         SpinCCWorCW=(Z=1.000000)
         SpinsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         LifetimeRange=(Min=2.000000,Max=2.000000)
         InitialDelayRange=(Min=0.550000,Max=0.550000)
         StartVelocityRange=(Y=(Min=-200.000000,Max=-300.000000),Z=(Min=800.000000,Max=1000.000000))
     End Object
     Emitters(7)=MeshEmitter'OnslaughtFull.ONSVehDeathMAS.MeshEmitter37'

     Begin Object Class=MeshEmitter Name=MeshEmitter38
         StaticMesh=StaticMesh'ONSFullStaticMeshes.LEVexploded.MainGun'
         UseMeshBlendMode=False
         UseParticleColor=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-900.000000)
         ColorScale(0)=(Color=(B=192,G=192,R=192,A=255))
         ColorScale(1)=(RelativeTime=0.900000,Color=(B=128,G=128,R=128,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
         MaxParticles=1
         DetailMode=DM_High
         StartLocationOffset=(Z=120.000000)
         UseRotationFrom=PTRS_Actor
         SpinCCWorCW=(Y=1.000000)
         SpinsPerSecondRange=(Y=(Min=0.300000,Max=0.500000),Z=(Max=1.000000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         LifetimeRange=(Min=2.000000,Max=2.000000)
         InitialDelayRange=(Min=0.700000,Max=0.700000)
         StartVelocityRange=(X=(Min=100.000000,Max=200.000000),Z=(Min=1200.000000,Max=1500.000000))
     End Object
     Emitters(8)=MeshEmitter'OnslaughtFull.ONSVehDeathMAS.MeshEmitter38'

     Begin Object Class=MeshEmitter Name=MeshEmitter27
         StaticMesh=StaticMesh'ONSFullStaticMeshes.LEVexploded.SideFlap'
         UseMeshBlendMode=False
         UseParticleColor=True
         UseCollision=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-800.000000)
         DampingFactorRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.100000,Max=0.100000))
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=0.850000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
         MaxParticles=1
         StartLocationOffset=(Y=200.000000)
         SpinCCWorCW=(Y=1.000000,Z=1.000000)
         SpinsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
         RotationDampingFactorRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=0.200000,Max=0.200000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         LifetimeRange=(Min=1.000000,Max=1.500000)
         InitialDelayRange=(Min=0.700000,Max=0.700000)
         StartVelocityRange=(Y=(Min=600.000000,Max=800.000000),Z=(Min=300.000000,Max=500.000000))
     End Object
     Emitters(9)=MeshEmitter'OnslaughtFull.ONSVehDeathMAS.MeshEmitter27'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter26
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         MaxParticles=20
         StartLocationOffset=(Y=-10.000000)
         StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
         AddLocationFromOtherEmitter=9
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Max=150.000000))
         InitialParticlesPerSecond=40.000000
         Texture=Texture'ExplosionTex.Framed.exp1_frames'
         TextureUSubdivisions=2
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.500000,Max=0.500000)
         InitialDelayRange=(Min=0.700000,Max=0.700000)
     End Object
     Emitters(10)=SpriteEmitter'OnslaughtFull.ONSVehDeathMAS.SpriteEmitter26'

     Begin Object Class=MeshEmitter Name=MeshEmitter40
         StaticMesh=StaticMesh'ONSFullStaticMeshes.LEVexploded.SideFlap'
         UseMeshBlendMode=False
         UseParticleColor=True
         UseCollision=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-800.000000)
         DampingFactorRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.100000,Max=0.100000))
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=0.850000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
         MaxParticles=1
         StartLocationOffset=(Y=-200.000000)
         SpinCCWorCW=(Y=1.000000,Z=0.000000)
         SpinsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
         RotationDampingFactorRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=0.200000,Max=0.200000))
         StartSizeRange=(X=(Min=-1.000000,Max=-1.000000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         LifetimeRange=(Min=1.000000,Max=1.500000)
         InitialDelayRange=(Min=0.700000,Max=0.700000)
         StartVelocityRange=(Y=(Min=-600.000000,Max=-800.000000),Z=(Min=300.000000,Max=500.000000))
     End Object
     Emitters(11)=MeshEmitter'OnslaughtFull.ONSVehDeathMAS.MeshEmitter40'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter39
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         MaxParticles=20
         StartLocationOffset=(Y=10.000000)
         StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
         AddLocationFromOtherEmitter=11
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Max=150.000000))
         InitialParticlesPerSecond=40.000000
         Texture=Texture'ExplosionTex.Framed.exp1_frames'
         TextureUSubdivisions=2
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.500000,Max=0.500000)
         InitialDelayRange=(Min=0.700000,Max=0.700000)
     End Object
     Emitters(12)=SpriteEmitter'OnslaughtFull.ONSVehDeathMAS.SpriteEmitter39'

     Begin Object Class=MeshEmitter Name=MeshEmitter41
         StaticMesh=StaticMesh'AW-2004Particles.Debris.Veh_Debris1'
         UseParticleColor=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-1500.000000)
         ColorScale(0)=(Color=(B=128,G=128,R=128,A=255))
         ColorScale(1)=(RelativeTime=0.800000,Color=(B=128,G=128,R=128,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
         MaxParticles=30
         StartLocationRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-200.000000,Max=200.000000))
         SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         StartSizeRange=(X=(Min=0.125000,Max=2.000000))
         InitialParticlesPerSecond=5000.000000
         DrawStyle=PTDS_AlphaBlend
         LifetimeRange=(Min=1.000000,Max=1.500000)
         InitialDelayRange=(Min=0.600000,Max=0.600000)
         StartVelocityRange=(X=(Min=-800.000000,Max=800.000000),Y=(Min=-800.000000,Max=800.000000),Z=(Min=500.000000,Max=1500.000000))
     End Object
     Emitters(13)=MeshEmitter'OnslaughtFull.ONSVehDeathMAS.MeshEmitter41'

     AutoDestroy=True
     bNoDelete=False
}
