//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSRedEnergyEffect extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter12
         UseDirectionAs=PTDU_Normal
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(G=128,R=128))
         ColorScale(1)=(RelativeTime=0.200000,Color=(G=128,R=128))
         ColorScale(2)=(RelativeTime=0.900000,Color=(R=255))
         ColorScale(3)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartSizeRange=(X=(Min=80.000000))
         InitialParticlesPerSecond=50.000000
         Texture=Texture'AW-2004Particles.Fire.BlastMark'
         LifetimeRange=(Min=1.200000,Max=1.200000)
     End Object
     Emitters(0)=SpriteEmitter'Onslaught.ONSRedEnergyEffect.SpriteEmitter12'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter13
         UseDirectionAs=PTDU_Right
         UseColorScale=True
         RespawnDeadParticles=False
         UseRevolution=True
         UseRevolutionScale=True
         UniformSize=True
         DetermineVelocityByLocationDifference=True
         ScaleSizeXByVelocity=True
         AutomaticInitialSpawning=False
         UseVelocityScale=True
         ColorScale(0)=(Color=(G=190,R=250))
         ColorScale(1)=(RelativeTime=0.100000,Color=(G=190,R=250))
         ColorScale(2)=(RelativeTime=0.400000,Color=(R=255))
         ColorScale(3)=(RelativeTime=0.600000,Color=(R=128))
         ColorScale(4)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=200
         StartLocationRange=(Z=(Max=256.000000))
         StartLocationShape=PTLS_All
         StartLocationPolarRange=(X=(Max=65536.000000),Y=(Min=16384.000000,Max=16384.000000),Z=(Min=64.000000,Max=96.000000))
         RevolutionsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
         RevolutionScale(0)=(RelativeRevolution=(X=1.000000,Y=1.000000,Z=1.000000))
         RevolutionScale(1)=(RelativeTime=0.500000,RelativeRevolution=(X=0.500000,Y=0.500000,Z=0.500000))
         RevolutionScale(2)=(RelativeTime=1.000000)
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=0.400000,RelativeSize=0.800000)
         SizeScale(3)=(RelativeTime=0.600000,RelativeSize=1.000000)
         SizeScale(4)=(RelativeTime=0.800000,RelativeSize=3.000000)
         SizeScale(5)=(RelativeTime=1.000000,RelativeSize=0.800000)
         StartSizeRange=(X=(Min=2.000000,Max=10.000000))
         ScaleSizeByVelocityMultiplier=(X=0.010000)
         InitialParticlesPerSecond=50000.000000
         Texture=Texture'EpicParticles.Flares.FlashFlare1'
         LifetimeRange=(Min=1.200000,Max=1.200000)
         StartVelocityRadialRange=(Min=20.000000,Max=20.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
         VelocityScale(1)=(RelativeTime=0.400000,RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
         VelocityScale(2)=(RelativeTime=0.800000,RelativeVelocity=(X=20.000000,Y=20.000000,Z=-20.000000))
         VelocityScale(3)=(RelativeTime=1.000000,RelativeVelocity=(X=0.200000,Y=0.200000,Z=0.200000))
     End Object
     Emitters(1)=SpriteEmitter'Onslaught.ONSRedEnergyEffect.SpriteEmitter13'

     AutoDestroy=True
     bNoDelete=False
}
