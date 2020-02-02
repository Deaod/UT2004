class ONSVehDeathHoverTank extends Emitter;

#exec OBJ LOAD FILE="..\Textures\ExplosionTex.utx"
#exec OBJ LOAD FILE="..\StaticMeshes\ONSDeadVehicles-SM.usx"

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter64
         RespawnDeadParticles=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(Z=-400.000000)
         MaxParticles=3
         StartLocationRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000))
         UseRotationFrom=PTRS_Actor
         StartSizeRange=(X=(Min=0.000000,Max=0.000000))
         InitialParticlesPerSecond=20.000000
         Texture=Texture'ExplosionTex.Framed.SmokeReOrdered'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Min=400.000000,Max=500.000000))
     End Object
     Emitters(0)=SpriteEmitter'Onslaught.ONSVehDeathHoverTank.SpriteEmitter64'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter68
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         UseRandomSubdivision=True
         ColorScale(0)=(Color=(A=192))
         ColorScale(1)=(RelativeTime=1.000000)
         DetailMode=DM_SuperHigh
         AddLocationFromOtherEmitter=5
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'AW-2004Particles.Fire.MuchSmoke1'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(1)=SpriteEmitter'Onslaught.ONSVehDeathHoverTank.SpriteEmitter68'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter67
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         DetailMode=DM_SuperHigh
         AddLocationFromOtherEmitter=5
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=80.000000,Max=120.000000))
         Texture=Texture'ExplosionTex.Framed.we1_frames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.400000,Max=0.600000)
         AddVelocityFromOtherEmitter=5
         AddVelocityMultiplierRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.200000,Max=0.200000))
     End Object
     Emitters(2)=SpriteEmitter'Onslaught.ONSVehDeathHoverTank.SpriteEmitter67'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter65
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         MaxParticles=20
         DetailMode=DM_High
         AddLocationFromOtherEmitter=0
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=0.800000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         InitialParticlesPerSecond=30.000000
         Texture=Texture'ExplosionTex.Framed.exp1_frames'
         TextureUSubdivisions=2
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(3)=SpriteEmitter'Onslaught.ONSVehDeathHoverTank.SpriteEmitter65'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter66
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         MaxParticles=8
         StartLocationRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-120.000000,Max=120.000000),Z=(Min=-32.000000,Max=32.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=0.800000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=2.000000)
         Texture=Texture'ExplosionTex.Framed.exp2_frames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.400000,Max=0.600000)
         StartVelocityRadialRange=(Min=-100.000000,Max=-100.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(4)=SpriteEmitter'Onslaught.ONSVehDeathHoverTank.SpriteEmitter66'

     Begin Object Class=MeshEmitter Name=MeshEmitter43
         StaticMesh=StaticMesh'ONSDeadVehicles-SM.TANKexploded.TankTurret'
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-800.000000)
         MaxParticles=1
         DetailMode=DM_High
         StartLocationOffset=(X=-30.000000,Z=40.000000)
         UseRotationFrom=PTRS_Actor
         SpinCCWorCW=(Y=0.000000)
         SpinsPerSecondRange=(Y=(Min=0.500000,Max=1.000000))
         InitialParticlesPerSecond=5000.000000
         LifetimeRange=(Min=1.500000,Max=2.000000)
         StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=1100.000000,Max=1500.000000))
     End Object
     Emitters(5)=MeshEmitter'Onslaught.ONSVehDeathHoverTank.MeshEmitter43'

     Begin Object Class=MeshEmitter Name=MeshEmitter44
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
         InitialDelayRange=(Min=0.150000,Max=0.150000)
         StartVelocityRadialRange=(Min=300.000000,Max=800.000000)
         VelocityLossRange=(X=(Min=0.500000,Max=1.000000),Y=(Min=0.500000,Max=1.000000),Z=(Min=0.500000,Max=1.000000))
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(6)=MeshEmitter'Onslaught.ONSVehDeathHoverTank.MeshEmitter44'

     Begin Object Class=MeshEmitter Name=MeshEmitter45
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
     Emitters(7)=MeshEmitter'Onslaught.ONSVehDeathHoverTank.MeshEmitter45'

     AutoDestroy=True
     bNoDelete=False
}
