//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSFreeRoamingEnergyEffect extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter66
         UseDirectionAs=PTDU_Normal
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         ColorScale(1)=(RelativeTime=0.200000,Color=(G=128,R=128))
         ColorScale(2)=(RelativeTime=0.800000,Color=(G=128,R=128))
         ColorScale(3)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=4
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.500000)
         Texture=Texture'AW-2004Particles.Fire.BlastMark'
         LifetimeRange=(Min=2.000000,Max=2.000000)
         WarmupTicksPerSecond=0.800000
         RelativeWarmupTime=0.500000
     End Object
     Emitters(0)=SpriteEmitter'Onslaught.ONSFreeRoamingEnergyEffect.SpriteEmitter66'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter10
         UseDirectionAs=PTDU_Right
         UseColorScale=True
         UseRevolution=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         DetermineVelocityByLocationDifference=True
         ScaleSizeXByVelocity=True
         UseVelocityScale=True
         ColorScale(1)=(RelativeTime=0.100000,Color=(B=16,G=228,R=239))
         ColorScale(2)=(RelativeTime=0.400000,Color=(G=128,R=128))
         ColorScale(3)=(RelativeTime=0.600000)
         ColorScale(4)=(RelativeTime=0.800000,Color=(B=4,G=173,R=230))
         ColorScale(5)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=300
         StartLocationShape=PTLS_Polar
         StartLocationPolarRange=(X=(Max=65536.000000),Y=(Min=16384.000000,Max=16384.000000),Z=(Min=64.000000,Max=96.000000))
         RevolutionsPerSecondRange=(Z=(Min=-1.000000,Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=0.400000,RelativeSize=0.800000)
         SizeScale(3)=(RelativeTime=0.600000,RelativeSize=1.000000)
         SizeScale(4)=(RelativeTime=0.800000,RelativeSize=3.000000)
         SizeScale(5)=(RelativeTime=1.000000,RelativeSize=0.800000)
         StartSizeRange=(X=(Min=2.000000,Max=5.000000))
         ScaleSizeByVelocityMultiplier=(X=0.010000)
         Texture=Texture'EpicParticles.Flares.FlashFlare1'
         LifetimeRange=(Min=1.800000,Max=1.800000)
         StartVelocityRange=(Z=(Min=80.000000,Max=250.000000))
         StartVelocityRadialRange=(Min=5.000000,Max=-5.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
         VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
         VelocityScale(1)=(RelativeTime=0.600000,RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
         VelocityScale(2)=(RelativeTime=1.000000,RelativeVelocity=(X=-1.000000,Y=-1.000000,Z=-1.000000))
     End Object
     Emitters(1)=SpriteEmitter'Onslaught.ONSFreeRoamingEnergyEffect.SpriteEmitter10'

     bNoDelete=False
}
