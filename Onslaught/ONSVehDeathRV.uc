class ONSVehDeathRV extends Emitter;

#exec OBJ LOAD FILE="..\Textures\ExplosionTex.utx"
#exec OBJ LOAD FILE="..\StaticMeshes\ONSDeadVehicles-SM.usx"

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter20
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         ColorScale(0)=(Color=(A=255))
         ColorScale(1)=(RelativeTime=0.400000,Color=(A=255))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=6
         DetailMode=DM_High
         StartLocationRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-64.000000,Max=64.000000))
         AddLocationFromOtherEmitter=1
         StartLocationShape=PTLS_Sphere
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'ExplosionTex.Framed.SmokeReOrdered'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.600000,Max=0.800000)
         InitialDelayRange=(Min=0.100000,Max=0.100000)
         AddVelocityFromOtherEmitter=1
     End Object
     Emitters(0)=SpriteEmitter'Onslaught.ONSVehDeathRV.SpriteEmitter20'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter15
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         MaxParticles=20
         StartLocationRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-32.000000,Max=32.000000))
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         InitialParticlesPerSecond=100.000000
         Texture=Texture'ExplosionTex.Framed.exp1_frames'
         TextureUSubdivisions=2
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.400000,Max=0.600000)
         StartVelocityRadialRange=(Min=-50.000000,Max=-100.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(1)=SpriteEmitter'Onslaught.ONSVehDeathRV.SpriteEmitter15'

     Begin Object Class=MeshEmitter Name=MeshEmitter17
         StaticMesh=StaticMesh'ONSDeadVehicles-SM.RVexploded.RVgun'
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-600.000000)
         MaxParticles=1
         DetailMode=DM_High
         StartLocationOffset=(X=-64.000000,Z=48.000000)
         UseRotationFrom=PTRS_Actor
         SpinCCWorCW=(Y=0.000000)
         SpinsPerSecondRange=(Y=(Min=1.000000,Max=2.000000))
         InitialParticlesPerSecond=5000.000000
         LifetimeRange=(Min=1.500000,Max=2.000000)
         StartVelocityRange=(X=(Min=-100.000000,Max=-200.000000),Z=(Min=500.000000,Max=800.000000))
     End Object
     Emitters(2)=MeshEmitter'Onslaught.ONSVehDeathRV.MeshEmitter17'

     Begin Object Class=MeshEmitter Name=MeshEmitter18
         StaticMesh=StaticMesh'ONSDeadVehicles-SM.RVexploded.RVrail'
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-500.000000)
         MaxParticles=1
         DetailMode=DM_High
         StartLocationOffset=(Y=-20.000000,Z=16.000000)
         UseRotationFrom=PTRS_Actor
         SpinCCWorCW=(Z=1.000000)
         SpinsPerSecondRange=(Y=(Max=0.100000),Z=(Min=1.000000,Max=2.000000))
         InitialParticlesPerSecond=5000.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(Y=(Min=-300.000000,Max=-400.000000),Z=(Min=400.000000,Max=500.000000))
     End Object
     Emitters(3)=MeshEmitter'Onslaught.ONSVehDeathRV.MeshEmitter18'

     Begin Object Class=MeshEmitter Name=MeshEmitter21
         StaticMesh=StaticMesh'ONSDeadVehicles-SM.RVexploded.RVrail'
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-500.000000)
         MaxParticles=1
         DetailMode=DM_High
         StartLocationOffset=(Y=20.000000,Z=16.000000)
         UseRotationFrom=PTRS_Actor
         SpinCCWorCW=(Z=0.000000)
         SpinsPerSecondRange=(Y=(Max=0.100000),Z=(Min=1.000000,Max=2.000000))
         StartSizeRange=(X=(Min=-1.000000,Max=-1.000000))
         InitialParticlesPerSecond=5000.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(Y=(Min=300.000000,Max=400.000000),Z=(Min=200.000000,Max=300.000000))
     End Object
     Emitters(4)=MeshEmitter'Onslaught.ONSVehDeathRV.MeshEmitter21'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter28
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         ColorScale(0)=(Color=(A=255))
         ColorScale(1)=(RelativeTime=1.000000)
         MaxParticles=5
         DetailMode=DM_SuperHigh
         AddLocationFromOtherEmitter=6
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Max=16.000000)
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartSizeRange=(X=(Min=40.000000,Max=60.000000))
         InitialParticlesPerSecond=6.500000
         Texture=Texture'ExplosionTex.Framed.exp1_frames'
         TextureUSubdivisions=2
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(5)=SpriteEmitter'Onslaught.ONSVehDeathRV.SpriteEmitter28'

     Begin Object Class=MeshEmitter Name=MeshEmitter22
         StaticMesh=StaticMesh'ONSDeadVehicles-SM.RVexploded.Rvtire'
         UseMeshBlendMode=False
         UseParticleColor=True
         UseCollision=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-300.000000)
         ExtentMultiplier=(X=0.500000,Y=0.500000,Z=0.500000)
         DampingFactorRange=(X=(Min=0.400000,Max=0.400000),Y=(Min=0.400000,Max=0.400000),Z=(Min=0.300000,Max=0.300000))
         ColorScale(0)=(Color=(B=192,G=192,R=192,A=255))
         ColorScale(1)=(RelativeTime=0.850000,Color=(B=128,G=128,R=128,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
         MaxParticles=1
         DetailMode=DM_High
         StartLocationOffset=(X=80.000000,Y=64.000000,Z=-32.000000)
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Max=0.300000),Y=(Max=0.300000),Z=(Max=0.300000))
         StartSpinRange=(X=(Max=1.000000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(X=(Min=300.000000,Max=500.000000),Y=(Min=300.000000,Max=500.000000),Z=(Min=100.000000,Max=100.000000))
     End Object
     Emitters(6)=MeshEmitter'Onslaught.ONSVehDeathRV.MeshEmitter22'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter30
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         MaxParticles=5
         DetailMode=DM_SuperHigh
         AddLocationFromOtherEmitter=8
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Max=16.000000)
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartSizeRange=(X=(Min=40.000000,Max=60.000000))
         InitialParticlesPerSecond=6.500000
         Texture=Texture'ExplosionTex.Framed.exp1_frames'
         TextureUSubdivisions=2
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(7)=SpriteEmitter'Onslaught.ONSVehDeathRV.SpriteEmitter30'

     Begin Object Class=MeshEmitter Name=MeshEmitter23
         StaticMesh=StaticMesh'ONSDeadVehicles-SM.RVexploded.Rvtire'
         UseMeshBlendMode=False
         UseParticleColor=True
         UseCollision=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-300.000000)
         ExtentMultiplier=(X=0.500000,Y=0.500000,Z=0.500000)
         DampingFactorRange=(X=(Min=0.400000,Max=0.400000),Y=(Min=0.400000,Max=0.400000),Z=(Min=0.300000,Max=0.300000))
         ColorScale(0)=(Color=(B=192,G=192,R=192,A=255))
         ColorScale(1)=(RelativeTime=0.850000,Color=(B=128,G=128,R=128,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
         MaxParticles=1
         DetailMode=DM_High
         StartLocationOffset=(X=80.000000,Y=-64.000000,Z=-32.000000)
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Max=0.300000),Y=(Max=0.300000),Z=(Max=0.300000))
         StartSpinRange=(X=(Max=1.000000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(X=(Min=200.000000,Max=300.000000),Y=(Min=-300.000000,Max=-500.000000),Z=(Min=100.000000,Max=100.000000))
     End Object
     Emitters(8)=MeshEmitter'Onslaught.ONSVehDeathRV.MeshEmitter23'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter31
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         MaxParticles=5
         DetailMode=DM_SuperHigh
         AddLocationFromOtherEmitter=10
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Max=16.000000)
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartSizeRange=(X=(Min=40.000000,Max=60.000000))
         InitialParticlesPerSecond=6.500000
         Texture=Texture'ExplosionTex.Framed.exp1_frames'
         TextureUSubdivisions=2
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(9)=SpriteEmitter'Onslaught.ONSVehDeathRV.SpriteEmitter31'

     Begin Object Class=MeshEmitter Name=MeshEmitter24
         StaticMesh=StaticMesh'ONSDeadVehicles-SM.RVexploded.Rvtire'
         UseCollision=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-300.000000)
         ExtentMultiplier=(X=0.500000,Y=0.500000,Z=0.500000)
         DampingFactorRange=(X=(Min=0.400000,Max=0.400000),Y=(Min=0.400000,Max=0.400000),Z=(Min=0.300000,Max=0.300000))
         ColorScale(0)=(Color=(B=192,G=192,R=192,A=255))
         ColorScale(1)=(RelativeTime=0.850000,Color=(B=128,G=128,R=128,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
         MaxParticles=1
         DetailMode=DM_High
         StartLocationOffset=(X=-80.000000,Y=64.000000,Z=-32.000000)
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Max=0.300000),Y=(Max=0.300000),Z=(Max=0.300000))
         StartSpinRange=(X=(Max=1.000000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(X=(Min=-300.000000,Max=-400.000000),Y=(Min=300.000000,Max=500.000000),Z=(Min=50.000000,Max=100.000000))
     End Object
     Emitters(10)=MeshEmitter'Onslaught.ONSVehDeathRV.MeshEmitter24'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter32
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         MaxParticles=5
         DetailMode=DM_SuperHigh
         AddLocationFromOtherEmitter=12
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Max=16.000000)
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartSizeRange=(X=(Min=40.000000,Max=60.000000))
         InitialParticlesPerSecond=6.500000
         Texture=Texture'ExplosionTex.Framed.exp1_frames'
         TextureUSubdivisions=2
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(11)=SpriteEmitter'Onslaught.ONSVehDeathRV.SpriteEmitter32'

     Begin Object Class=MeshEmitter Name=MeshEmitter25
         StaticMesh=StaticMesh'ONSDeadVehicles-SM.RVexploded.Rvtire'
         UseMeshBlendMode=False
         UseParticleColor=True
         UseCollision=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-300.000000)
         ExtentMultiplier=(X=0.500000,Y=0.500000,Z=0.500000)
         DampingFactorRange=(X=(Min=0.400000,Max=0.400000),Y=(Min=0.400000,Max=0.400000),Z=(Min=0.300000,Max=0.300000))
         ColorScale(0)=(Color=(B=192,G=192,R=192,A=255))
         ColorScale(1)=(RelativeTime=0.850000,Color=(B=128,G=128,R=128,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
         MaxParticles=1
         DetailMode=DM_High
         StartLocationOffset=(X=-80.000000,Y=-64.000000,Z=-32.000000)
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Max=0.300000),Y=(Max=0.300000),Z=(Max=0.300000))
         StartSpinRange=(X=(Max=1.000000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(X=(Min=-200.000000,Max=-300.000000),Y=(Min=-300.000000,Max=-500.000000),Z=(Min=100.000000,Max=100.000000))
     End Object
     Emitters(12)=MeshEmitter'Onslaught.ONSVehDeathRV.MeshEmitter25'

     Begin Object Class=MeshEmitter Name=MeshEmitter5
         StaticMesh=StaticMesh'AW-2004Particles.Debris.Veh_Debris2'
         UseParticleColor=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-400.000000)
         ColorScale(0)=(Color=(B=192,G=192,R=192,A=255))
         ColorScale(1)=(RelativeTime=0.850000,Color=(B=128,G=128,R=128,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
         MaxParticles=15
         DetailMode=DM_SuperHigh
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=8.000000,Max=8.000000)
         SpinsPerSecondRange=(X=(Max=0.200000),Y=(Max=0.200000),Z=(Max=0.200000))
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         StartSizeRange=(X=(Min=0.500000),Y=(Min=0.500000),Z=(Min=0.500000))
         InitialParticlesPerSecond=5000.000000
         DrawStyle=PTDS_AlphaBlend
         LifetimeRange=(Min=1.500000,Max=2.000000)
         StartVelocityRadialRange=(Min=300.000000,Max=800.000000)
         VelocityLossRange=(X=(Min=0.500000,Max=1.000000),Y=(Min=0.500000,Max=1.000000),Z=(Min=0.500000,Max=1.000000))
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(13)=MeshEmitter'Onslaught.ONSVehDeathRV.MeshEmitter5'

     Begin Object Class=MeshEmitter Name=MeshEmitter6
         StaticMesh=StaticMesh'AW-2004Particles.Debris.Veh_Debris1'
         RenderTwoSided=True
         UseParticleColor=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-800.000000)
         ColorScale(0)=(Color=(B=192,G=192,R=192,A=255))
         ColorScale(1)=(RelativeTime=0.850000,Color=(B=128,G=128,R=128,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
         MaxParticles=15
         DetailMode=DM_SuperHigh
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=8.000000,Max=8.000000)
         SpinsPerSecondRange=(X=(Max=0.200000),Y=(Max=0.200000),Z=(Max=0.200000))
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         StartSizeRange=(X=(Min=0.500000),Y=(Min=0.500000),Z=(Min=0.500000))
         InitialParticlesPerSecond=5000.000000
         DrawStyle=PTDS_AlphaBlend
         LifetimeRange=(Min=1.500000,Max=2.000000)
         StartVelocityRange=(Z=(Min=100.000000,Max=300.000000))
         StartVelocityRadialRange=(Min=300.000000,Max=800.000000)
         VelocityLossRange=(X=(Min=0.500000,Max=1.000000),Y=(Min=0.500000,Max=1.000000),Z=(Min=0.500000,Max=1.000000))
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(14)=MeshEmitter'Onslaught.ONSVehDeathRV.MeshEmitter6'

     AutoDestroy=True
     bNoDelete=False
}
