class ONSPRVRearGunCharge extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter4
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=50,G=50,R=50))
         ColorScale(1)=(RelativeTime=0.300000,Color=(B=255,G=255))
         ColorScale(2)=(RelativeTime=0.500000,Color=(B=255,G=128,R=128,A=255))
         ColorScale(3)=(RelativeTime=0.850000,Color=(B=255,G=128,R=128))
         ColorScale(4)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         StartLocationOffset=(Y=12.000000)
         StartLocationShape=PTLS_Sphere
         SpinsPerSecondRange=(X=(Max=1.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.500000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartSizeRange=(X=(Min=20.000000,Max=20.000000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'AW-2004Particles.Weapons.PlasmaStar'
         LifetimeRange=(Min=3.000000,Max=3.000000)
     End Object
     Emitters(0)=SpriteEmitter'Onslaught.ONSPRVRearGunCharge.SpriteEmitter4'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter5
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=255,G=128,R=128))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=255,G=150,R=128))
         ColorScale(3)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=8
         StartLocationOffset=(Y=12.000000)
         SpinsPerSecondRange=(X=(Max=0.500000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=50.000000,Max=50.000000))
         InitialParticlesPerSecond=8.000000
         Texture=Texture'AW-2004Particles.Energy.BurnFlare'
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(1)=SpriteEmitter'Onslaught.ONSPRVRearGunCharge.SpriteEmitter5'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter6
         UseDirectionAs=PTDU_Up
         UseColorScale=True
         RespawnDeadParticles=False
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=255,G=255,R=255))
         ColorScale(3)=(RelativeTime=1.000000)
         ColorMultiplierRange=(X=(Min=0.300000,Max=0.400000),Y=(Min=0.300000,Max=0.300000))
         CoordinateSystem=PTCS_Relative
         MaxParticles=100
         StartLocationShape=PTLS_Polar
         StartLocationPolarRange=(X=(Min=-8192.000000,Max=8192.000000),Y=(Min=8192.000000,Max=24576.000000),Z=(Min=80.000000,Max=80.000000))
         StartSizeRange=(X=(Min=3.000000,Max=3.000000),Y=(Min=5.000000,Max=5.000000))
         InitialParticlesPerSecond=100.000000
         Texture=Texture'AW-2004Particles.Energy.SparkHead'
         LifetimeRange=(Min=0.800000,Max=0.800000)
         StartVelocityRadialRange=(Min=-100.000000,Max=-100.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(2)=SpriteEmitter'Onslaught.ONSPRVRearGunCharge.SpriteEmitter6'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter8
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=128,R=128))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=255,G=128,R=128))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=128,R=128))
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         StartLocationOffset=(Y=12.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=0.250000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=15.000000,Max=20.000000))
         InitialParticlesPerSecond=2000.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'AW-2004Particles.Weapons.PlasmaFlare'
         LifetimeRange=(Min=0.050000,Max=0.050000)
         InitialDelayRange=(Min=1.500000,Max=1.500000)
     End Object
     Emitters(3)=SpriteEmitter'Onslaught.ONSPRVRearGunCharge.SpriteEmitter8'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter9
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=128,R=128))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=255,G=128,R=128))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=128,R=128))
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartLocationOffset=(Y=12.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=0.250000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000))
         InitialParticlesPerSecond=2000.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'AW-2004Particles.Weapons.PlasmaFlare'
         LifetimeRange=(Min=0.200000,Max=0.200000)
         InitialDelayRange=(Min=1.500000,Max=1.500000)
     End Object
     Emitters(4)=SpriteEmitter'Onslaught.ONSPRVRearGunCharge.SpriteEmitter9'

     Begin Object Class=BeamEmitter Name=BeamEmitter1
         BeamDistanceRange=(Min=60.000000,Max=60.000000)
         DetermineEndPointBy=PTEP_Distance
         LowFrequencyNoiseRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-5.000000,Max=5.000000))
         HighFrequencyNoiseRange=(X=(Min=-2.000000,Max=2.000000),Y=(Min=-2.000000,Max=2.000000),Z=(Min=-2.000000,Max=2.000000))
         UseColorScale=True
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=255,G=255,R=255))
         ColorScale(3)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=4
         StartLocationOffset=(X=-5.000000,Y=12.000000)
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=4.000000,Max=4.000000)
         UseRotationFrom=PTRS_Normal
         StartSizeRange=(X=(Min=5.000000,Max=5.000000))
         Texture=Texture'EpicParticles.Beams.HotBolt04aw'
         LifetimeRange=(Min=0.100000,Max=0.100000)
         InitialDelayRange=(Min=1.250000,Max=1.250000)
         StartVelocityRange=(X=(Min=-1.000000,Max=-1.000000),Z=(Min=0.050000,Max=0.050000))
     End Object
     Emitters(5)=BeamEmitter'Onslaught.ONSPRVRearGunCharge.BeamEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=50,G=50,R=50))
         ColorScale(1)=(RelativeTime=0.300000,Color=(B=255,G=255))
         ColorScale(2)=(RelativeTime=0.500000,Color=(B=255,G=128,R=128,A=255))
         ColorScale(3)=(RelativeTime=0.850000,Color=(B=255,G=128,R=128))
         ColorScale(4)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         StartLocationOffset=(Y=-12.000000)
         StartLocationShape=PTLS_Sphere
         SpinsPerSecondRange=(X=(Max=1.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.500000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartSizeRange=(X=(Min=20.000000,Max=20.000000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'AW-2004Particles.Weapons.PlasmaStar'
         LifetimeRange=(Min=3.000000,Max=3.000000)
     End Object
     Emitters(6)=SpriteEmitter'Onslaught.ONSPRVRearGunCharge.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=255,G=128,R=128))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=255,G=150,R=128))
         ColorScale(3)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=8
         StartLocationOffset=(Y=-12.000000)
         SpinsPerSecondRange=(X=(Max=0.500000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=50.000000,Max=50.000000))
         InitialParticlesPerSecond=8.000000
         Texture=Texture'AW-2004Particles.Energy.BurnFlare'
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(7)=SpriteEmitter'Onslaught.ONSPRVRearGunCharge.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=128,R=128))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=255,G=128,R=128))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=128,R=128))
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         StartLocationOffset=(Y=-12.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=0.250000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=15.000000,Max=20.000000))
         InitialParticlesPerSecond=2000.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'AW-2004Particles.Weapons.PlasmaFlare'
         LifetimeRange=(Min=0.100000,Max=0.100000)
         InitialDelayRange=(Min=1.500000,Max=1.500000)
     End Object
     Emitters(8)=SpriteEmitter'Onslaught.ONSPRVRearGunCharge.SpriteEmitter3'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter7
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=128,R=128))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=255,G=128,R=128))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=128,R=128))
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartLocationOffset=(Y=-12.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=0.250000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000))
         InitialParticlesPerSecond=2000.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'AW-2004Particles.Weapons.PlasmaFlare'
         LifetimeRange=(Min=0.100000,Max=0.100000)
         InitialDelayRange=(Min=1.500000,Max=1.500000)
     End Object
     Emitters(9)=SpriteEmitter'Onslaught.ONSPRVRearGunCharge.SpriteEmitter7'

     Begin Object Class=BeamEmitter Name=BeamEmitter0
         BeamDistanceRange=(Min=60.000000,Max=60.000000)
         DetermineEndPointBy=PTEP_Distance
         LowFrequencyNoiseRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-5.000000,Max=5.000000))
         HighFrequencyNoiseRange=(X=(Min=-2.000000,Max=2.000000),Y=(Min=-2.000000,Max=2.000000),Z=(Min=-2.000000,Max=2.000000))
         UseColorScale=True
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=255,G=255,R=255))
         ColorScale(3)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=4
         StartLocationOffset=(X=-5.000000,Y=-12.000000)
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=4.000000,Max=4.000000)
         UseRotationFrom=PTRS_Normal
         StartSizeRange=(X=(Min=5.000000,Max=5.000000))
         Texture=Texture'EpicParticles.Beams.HotBolt04aw'
         LifetimeRange=(Min=0.100000,Max=0.100000)
         InitialDelayRange=(Min=1.250000,Max=1.250000)
         StartVelocityRange=(X=(Min=-1.000000,Max=-1.000000),Z=(Min=0.050000,Max=0.050000))
     End Object
     Emitters(10)=BeamEmitter'Onslaught.ONSPRVRearGunCharge.BeamEmitter0'

     bNoDelete=False
}
