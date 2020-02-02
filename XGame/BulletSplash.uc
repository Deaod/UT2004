class BulletSplash extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter29
         UseDirectionAs=PTDU_Up
         UseColorScale=True
         RespawnDeadParticles=False
         UniformSize=True
         ScaleSizeXByVelocity=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-210.000000)
         ColorScale(0)=(Color=(B=245,G=240,R=137))
         ColorScale(1)=(RelativeTime=0.800000,Color=(B=223,G=231,R=88))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=20
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.400000,RelativeSize=0.700000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.300000)
         StartSizeRange=(X=(Min=4.000000,Max=5.000000))
         ScaleSizeByVelocityMultiplier=(X=0.010000,Y=0.010000)
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'AW-2004Particles.Energy.SparkHead'
         LifetimeRange=(Min=0.800000,Max=0.800000)
         StartVelocityRange=(X=(Min=-40.000000,Max=40.000000),Y=(Min=-40.000000,Max=40.000000),Z=(Min=60.000000,Max=150.000000))
     End Object
     Emitters(0)=SpriteEmitter'XGame.BulletSplash.SpriteEmitter29'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter30
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         Acceleration=(Z=-200.000000)
         ColorScale(0)=(Color=(B=255,G=250,R=200))
         ColorScale(1)=(RelativeTime=0.800000,Color=(B=108,G=106,R=74))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=8
         StartLocationRange=(Z=(Max=15.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.400000)
         StartSizeRange=(X=(Min=10.000000,Max=20.000000))
         InitialParticlesPerSecond=500.000000
         Texture=Texture'XGame.Water.xSplashBase'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-8.000000,Max=8.000000),Y=(Min=-8.000000,Max=8.000000),Z=(Min=70.000000,Max=90.000000))
         VelocityLossRange=(X=(Max=0.360000),Y=(Max=0.360000))
     End Object
     Emitters(1)=SpriteEmitter'XGame.BulletSplash.SpriteEmitter30'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter31
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         Acceleration=(Z=-160.000000)
         ColorScale(0)=(Color=(B=255,G=250,R=200))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=250,R=200))
         FadeOutStartTime=0.500000
         MaxParticles=12
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartSizeRange=(X=(Min=20.000000,Max=30.000000))
         InitialParticlesPerSecond=500.000000
         Texture=Texture'XGame.Water.xWaterDrops2'
         TextureUSubdivisions=1
         TextureVSubdivisions=2
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=70.000000,Max=100.000000))
     End Object
     Emitters(2)=SpriteEmitter'XGame.BulletSplash.SpriteEmitter31'

     AutoDestroy=True
     bNoDelete=False
     bHighDetail=True
}
