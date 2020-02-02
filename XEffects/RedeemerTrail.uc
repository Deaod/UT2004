class RedeemerTrail extends Emitter;

#exec OBJ LOAD FILE=EpicParticles.utx

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ColorScale(0)=(Color=(B=255,G=223,R=140))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=206,G=255,R=254))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=151,G=232,R=255))
         FadeInEndTime=0.050000
         CoordinateSystem=PTCS_Relative
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=2.000000,Max=2.000000)
         StartSpinRange=(X=(Min=0.250000,Max=0.250000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=10.000000,Max=10.000000),Z=(Min=5.000000,Max=5.000000))
         Texture=Texture'EpicParticles.Smoke.Smokepuff2'
         LifetimeRange=(Min=0.300000,Max=0.300000)
         StartVelocityRange=(X=(Min=-125.000000,Max=-150.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
         StartVelocityRadialRange=(Min=-10.000000,Max=-10.000000)
     End Object
     Emitters(0)=SpriteEmitter'XEffects.RedeemerTrail.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=50.000000)
         ColorScale(0)=(Color=(B=176,G=223,R=255))
         ColorScale(1)=(RelativeTime=0.125000,Color=(B=176,G=223,R=255,A=190))
         ColorScale(2)=(RelativeTime=0.500000,Color=(B=200,G=200,R=200,A=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=80,G=80,R=80,A=255))
         FadeInEndTime=0.500000
         MaxParticles=80
         StartLocationOffset=(X=-16.000000)
         StartLocationRange=(X=(Min=-16.000000,Max=16.000000))
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=20.000000,Max=20.000000),Y=(Min=20.000000,Max=20.000000))
         InitialParticlesPerSecond=40.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'EpicParticles.Smoke.Smokepuff'
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(1)=SpriteEmitter'XEffects.RedeemerTrail.SpriteEmitter1'

     AutoDestroy=True
     bNoDelete=False
     Style=STY_Masked
     bHardAttach=True
     bDirectional=True
}
