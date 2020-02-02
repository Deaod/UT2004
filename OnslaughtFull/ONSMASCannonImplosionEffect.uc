//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSMASCannonImplosionEffect extends Emitter;

#exec OBJ LOAD FILE=..\Textures\AW-2004Particles.utx

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         RespawnDeadParticles=False
         UniformSize=True
         AutomaticInitialSpawning=False
         MaxParticles=1
         StartSizeRange=(X=(Min=0.000000,Max=0.000000))
         Sounds(0)=(Sound=Sound'ONSVehicleSounds-S.MAS.MASBIGFire01',Radius=(Min=4000.000000,Max=4000.000000),Pitch=(Min=1.000000,Max=1.000000),Weight=1,Volume=(Min=255.000000,Max=255.000000),Probability=(Min=100.000000,Max=100.000000))
         SpawningSound=PTSC_LinearLocal
         SpawningSoundProbability=(Min=100.000000,Max=100.000000)
         InitialParticlesPerSecond=500000.000000
         LifetimeRange=(Min=5.800000,Max=5.800000)
     End Object
     Emitters(0)=SpriteEmitter'OnslaughtFull.ONSMASCannonImplosionEffect.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter20
         UseDirectionAs=PTDU_Right
         UseColorScale=True
         RespawnDeadParticles=False
         UseRevolution=True
         UseRevolutionScale=True
         UniformSize=True
         ScaleSizeXByVelocity=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.100000,Color=(B=255,G=255,R=155))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=211,G=171,R=192))
         ColorScale(3)=(RelativeTime=1.000000)
         MaxParticles=100
         StartLocationShape=PTLS_Polar
         StartLocationPolarRange=(X=(Max=65536.000000),Y=(Min=20000.000000,Max=8000.000000),Z=(Min=1000.000000,Max=1000.000000))
         RevolutionsPerSecondRange=(Z=(Min=0.200000,Max=-0.200000))
         RevolutionScale(0)=(RelativeRevolution=(Z=0.200000))
         RevolutionScale(1)=(RelativeTime=0.200000,RelativeRevolution=(Z=0.200000))
         RevolutionScale(2)=(RelativeTime=0.400000,RelativeRevolution=(Z=-0.030000))
         RevolutionScale(3)=(RelativeTime=0.600000,RelativeRevolution=(Z=0.200000))
         RevolutionScale(4)=(RelativeTime=0.800000,RelativeRevolution=(Z=-0.700000))
         RevolutionScale(5)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=-10.000000,Max=-10.000000))
         ScaleSizeByVelocityMultiplier=(X=0.010000)
         InitialParticlesPerSecond=100.000000
         Texture=Texture'AW-2004Particles.Weapons.PlasmaShaft'
         LifetimeRange=(Min=1.400000,Max=1.400000)
         StartVelocityRadialRange=(Min=750.000000,Max=750.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(1)=SpriteEmitter'OnslaughtFull.ONSMASCannonImplosionEffect.SpriteEmitter20'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter17
         UseColorScale=True
         RespawnDeadParticles=False
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.200000,Color=(A=128))
         ColorScale(2)=(RelativeTime=0.800000,Color=(A=128))
         ColorScale(3)=(RelativeTime=1.000000)
         MaxParticles=1
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartSizeRange=(X=(Min=150.000000,Max=150.000000))
         InitialParticlesPerSecond=5000.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'AW-2004Particles.Weapons.LargeSpot'
         LifetimeRange=(Min=3.000000,Max=3.000000)
     End Object
     Emitters(2)=SpriteEmitter'OnslaughtFull.ONSMASCannonImplosionEffect.SpriteEmitter17'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         UseDirectionAs=PTDU_Right
         UseColorScale=True
         RespawnDeadParticles=False
         UseRevolution=True
         UseRevolutionScale=True
         UniformSize=True
         ScaleSizeXByVelocity=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.400000,Color=(B=255,G=255,R=155))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=211,G=171,R=192))
         ColorScale(3)=(RelativeTime=1.000000)
         Opacity=0.400000
         MaxParticles=20
         StartLocationShape=PTLS_Polar
         StartLocationPolarRange=(X=(Max=65536.000000),Y=(Min=24000.000000,Max=4000.000000),Z=(Min=2000.000000,Max=2000.000000))
         RevolutionsPerSecondRange=(Z=(Min=0.200000,Max=-0.200000))
         RevolutionScale(0)=(RelativeRevolution=(Z=0.200000))
         RevolutionScale(1)=(RelativeTime=0.200000,RelativeRevolution=(Z=0.200000))
         RevolutionScale(2)=(RelativeTime=0.400000,RelativeRevolution=(Z=-0.030000))
         RevolutionScale(3)=(RelativeTime=0.600000,RelativeRevolution=(Z=0.200000))
         RevolutionScale(4)=(RelativeTime=0.800000,RelativeRevolution=(Z=-0.700000))
         RevolutionScale(5)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=-30.000000,Max=-30.000000))
         ScaleSizeByVelocityMultiplier=(X=0.007500)
         InitialParticlesPerSecond=50000.000000
         Texture=Texture'AW-2004Particles.Weapons.PlasmaShaft'
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRadialRange=(Min=1000.000000,Max=1000.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(3)=SpriteEmitter'OnslaughtFull.ONSMASCannonImplosionEffect.SpriteEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter14
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=215,G=215,R=64))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=208,G=74,R=194))
         ColorScale(3)=(RelativeTime=1.000000)
         MaxParticles=20
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=200.000000,Max=200.000000))
         InitialParticlesPerSecond=10.000000
         Texture=Texture'AW-2004Particles.Fire.BlastMark'
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(4)=SpriteEmitter'OnslaughtFull.ONSMASCannonImplosionEffect.SpriteEmitter14'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter15
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=215,G=215,R=64))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=208,G=74,R=194))
         ColorScale(3)=(RelativeTime=1.000000)
         MaxParticles=6
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=200.000000,Max=200.000000))
         InitialParticlesPerSecond=4.000000
         Texture=Texture'AW-2004Particles.Energy.EclipseCircle'
         LifetimeRange=(Min=0.900000,Max=0.900000)
         InitialDelayRange=(Min=0.400000,Max=0.400000)
     End Object
     Emitters(5)=SpriteEmitter'OnslaughtFull.ONSMASCannonImplosionEffect.SpriteEmitter15'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter18
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.100000,Color=(B=249,G=175,R=85))
         ColorScale(2)=(RelativeTime=0.850000,Color=(B=242,G=220,R=91))
         ColorScale(3)=(RelativeTime=0.900000,Color=(B=6,G=89,R=215))
         ColorScale(4)=(RelativeTime=1.000000)
         Opacity=0.700000
         MaxParticles=3
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.700000,RelativeSize=6.000000)
         SizeScale(2)=(RelativeTime=0.850000,RelativeSize=6.000000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=12.000000)
         StartSizeRange=(X=(Max=130.000000))
         InitialParticlesPerSecond=9.000000
         Texture=Texture'AW-2004Particles.Fire.BlastMark'
         LifetimeRange=(Min=1.400000,Max=1.400000)
         InitialDelayRange=(Min=1.700000,Max=1.700000)
     End Object
     Emitters(6)=SpriteEmitter'OnslaughtFull.ONSMASCannonImplosionEffect.SpriteEmitter18'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter11
         UseDirectionAs=PTDU_Forward
         UseColorScale=True
         RespawnDeadParticles=False
         UseRevolutionScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         DetermineVelocityByLocationDifference=True
         AutomaticInitialSpawning=False
         UseVelocityScale=True
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=255,G=128))
         ColorScale(3)=(RelativeTime=1.000000)
         MaxParticles=300
         StartLocationRange=(Z=(Min=-1.000000,Max=1.000000))
         StartLocationShape=PTLS_All
         SphereRadiusRange=(Min=2.000000,Max=2.000000)
         RevolutionsPerSecondRange=(Z=(Max=1.000000))
         RevolutionScale(1)=(RelativeTime=0.125000)
         RevolutionScale(2)=(RelativeTime=0.400000,RelativeRevolution=(X=0.200000,Y=0.200000,Z=0.200000))
         RevolutionScale(3)=(RelativeTime=1.000000,RelativeRevolution=(X=1.000000,Y=1.000000,Z=1.000000))
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.250000,RelativeSize=3.000000)
         SizeScale(2)=(RelativeTime=0.500000,RelativeSize=12.000000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=3.000000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000))
         InitialParticlesPerSecond=30000.000000
         Texture=Texture'EpicParticles.Flares.FlashFlare1'
         LifetimeRange=(Min=1.500000,Max=1.500000)
         InitialDelayRange=(Min=1.500000,Max=1.500000)
         StartVelocityRadialRange=(Min=-800.000000,Max=-800.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
         VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
         VelocityScale(1)=(RelativeTime=0.300000,RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
         VelocityScale(2)=(RelativeTime=0.400000,RelativeVelocity=(X=0.010000,Y=0.010000,Z=0.010000))
         VelocityScale(3)=(RelativeTime=1.000000,RelativeVelocity=(X=0.010000,Y=0.010000,Z=0.010000))
     End Object
     Emitters(7)=SpriteEmitter'OnslaughtFull.ONSMASCannonImplosionEffect.SpriteEmitter11'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter35
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=226,G=190,R=65))
         ColorScale(2)=(RelativeTime=0.950000,Color=(B=240,G=89,R=180))
         ColorScale(3)=(RelativeTime=1.000000)
         Opacity=0.500000
         MaxParticles=3
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=900.000000,Max=900.000000))
         InitialParticlesPerSecond=2500.000000
         Texture=Texture'AW-2004Particles.Energy.EclipseCircle'
         LifetimeRange=(Min=0.800000,Max=0.800000)
         InitialDelayRange=(Min=2.000000,Max=2.000000)
     End Object
     Emitters(8)=SpriteEmitter'OnslaughtFull.ONSMASCannonImplosionEffect.SpriteEmitter35'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter21
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         ColorMultiplierRange=(X=(Min=0.700000,Max=0.700000))
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=5.000000,Max=5.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
         StartSizeRange=(X=(Min=300.000000,Max=300.000000))
         InitialParticlesPerSecond=100.000000
         Texture=Texture'ExplosionTex.Framed.exp2_framesP'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.500000,Max=0.500000)
         InitialDelayRange=(Min=3.000000,Max=3.000000)
         StartVelocityRadialRange=(Min=-3000.000000,Max=-3000.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(9)=SpriteEmitter'OnslaughtFull.ONSMASCannonImplosionEffect.SpriteEmitter21'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter27
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         ColorMultiplierRange=(X=(Min=0.600000,Max=0.600000),Y=(Min=0.900000,Max=0.900000))
         MaxParticles=15
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=1000.000000,Max=1000.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=4.500000)
         StartSizeRange=(X=(Min=300.000000,Max=300.000000))
         InitialParticlesPerSecond=100.000000
         Texture=Texture'ExplosionTex.Framed.exp2_framesP'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.500000,Max=0.500000)
         InitialDelayRange=(Min=3.150000,Max=3.150000)
     End Object
     Emitters(10)=SpriteEmitter'OnslaughtFull.ONSMASCannonImplosionEffect.SpriteEmitter27'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter34
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         ColorMultiplierRange=(X=(Min=0.550000,Max=0.550000),Y=(Min=0.850000,Max=0.850000))
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=1500.000000,Max=1500.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=2.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=6.000000)
         StartSizeRange=(X=(Min=300.000000,Max=300.000000))
         InitialParticlesPerSecond=100.000000
         Texture=Texture'ExplosionTex.Framed.exp2_framesP'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.500000,Max=0.500000)
         InitialDelayRange=(Min=3.300000,Max=3.300000)
     End Object
     Emitters(11)=SpriteEmitter'OnslaughtFull.ONSMASCannonImplosionEffect.SpriteEmitter34'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter44
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         ColorMultiplierRange=(X=(Min=0.550000,Max=0.550000),Y=(Min=0.850000,Max=0.850000))
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=2200.000000,Max=2200.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=3.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=8.000000)
         StartSizeRange=(X=(Min=300.000000,Max=300.000000))
         InitialParticlesPerSecond=100.000000
         Texture=Texture'ExplosionTex.Framed.exp2_framesP'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.500000,Max=0.500000)
         InitialDelayRange=(Min=3.450000,Max=3.450000)
     End Object
     Emitters(12)=SpriteEmitter'OnslaughtFull.ONSMASCannonImplosionEffect.SpriteEmitter44'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter12
         RespawnDeadParticles=False
         Disabled=True
         Backup_Disabled=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         ColorMultiplierRange=(X=(Min=0.550000,Max=0.550000),Y=(Min=0.850000,Max=0.850000))
         MaxParticles=12
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=3000.000000,Max=3000.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=3.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=8.000000)
         StartSizeRange=(X=(Min=300.000000,Max=300.000000))
         InitialParticlesPerSecond=100.000000
         Texture=Texture'ExplosionTex.Framed.exp2_framesP'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.500000,Max=0.500000)
         InitialDelayRange=(Min=3.600000,Max=3.600000)
     End Object
     Emitters(13)=SpriteEmitter'OnslaughtFull.ONSMASCannonImplosionEffect.SpriteEmitter12'

     Begin Object Class=MeshEmitter Name=MeshEmitter2
         StaticMesh=StaticMesh'AW-2004Particles.Shapes.NodeHealRing'
         UseParticleColor=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=215,G=189,R=111))
         ColorScale(1)=(RelativeTime=0.500000,Color=(G=88,R=125))
         ColorScale(2)=(RelativeTime=1.000000)
         Opacity=0.500000
         MaxParticles=8
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=35.000000)
         InitialParticlesPerSecond=500.000000
         LifetimeRange=(Min=0.800000,Max=0.800000)
         InitialDelayRange=(Min=3.200000,Max=3.200000)
     End Object
     Emitters(14)=MeshEmitter'OnslaughtFull.ONSMASCannonImplosionEffect.MeshEmitter2'

     AutoDestroy=True
     bNoDelete=False
     AmbientGlow=254
     bUnlit=False
     SoundVolume=255
     SoundRadius=1500.000000
}
