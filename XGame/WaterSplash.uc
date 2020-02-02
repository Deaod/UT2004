class WaterSplash extends Emitter;

#exec TEXTURE IMPORT NAME=xCausticRing2 FILE=TEXTURES\CausticRing2.bmp GROUP=Water Alpha=1 DXT=5
#exec TEXTURE IMPORT NAME=xSplashBase FILE=TEXTURES\SplashBase.tga GROUP=Water Alpha=1 DXT=5
#exec TEXTURE IMPORT NAME=xWaterDrops2 FILE=TEXTURES\WaterDrops2.tga GROUP=Water Alpha=1 DXT=5

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter9
         UseDirectionAs=PTDU_Normal
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=234,R=168))
         ColorScale(1)=(RelativeTime=0.600000,Color=(B=253,G=253,R=253))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=3
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=20.000000))
         InitialParticlesPerSecond=32.000000
         Texture=Texture'XGame.Water.xCausticRing2'
         LifetimeRange=(Min=0.800000,Max=0.800000)
     End Object
     Emitters(0)=SpriteEmitter'XGame.WaterSplash.SpriteEmitter9'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter10
         UseDirectionAs=PTDU_Up
         UseColorScale=True
         RespawnDeadParticles=False
         UniformSize=True
         ScaleSizeXByVelocity=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-180.000000)
         ColorScale(0)=(Color=(B=245,G=240,R=137))
         ColorScale(1)=(RelativeTime=0.800000,Color=(B=223,G=231,R=88))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=25
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.400000,RelativeSize=0.700000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.300000)
         StartSizeRange=(X=(Min=4.000000,Max=5.000000))
         ScaleSizeByVelocityMultiplier=(X=0.010000,Y=0.010000)
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'AW-2004Particles.Energy.SparkHead'
         LifetimeRange=(Min=0.800000,Max=0.800000)
         StartVelocityRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=85.000000,Max=140.000000))
     End Object
     Emitters(1)=SpriteEmitter'XGame.WaterSplash.SpriteEmitter10'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter11
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         Acceleration=(Z=-180.000000)
         ColorScale(0)=(Color=(B=255,G=250,R=200))
         ColorScale(1)=(RelativeTime=0.800000,Color=(B=255,G=250,R=200))
         ColorScale(2)=(RelativeTime=1.000000)
         StartLocationRange=(Z=(Max=15.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.800000)
         StartSizeRange=(X=(Min=10.000000,Max=20.000000))
         InitialParticlesPerSecond=50.000000
         Texture=Texture'XGame.Water.xSplashBase'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         LifetimeRange=(Min=0.800000,Max=0.800000)
         StartVelocityRange=(Z=(Min=50.000000,Max=85.000000))
     End Object
     Emitters(2)=SpriteEmitter'XGame.WaterSplash.SpriteEmitter11'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter12
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         Acceleration=(Z=-150.000000)
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
         LifetimeRange=(Min=1.200000,Max=1.200000)
         StartVelocityRange=(X=(Min=-24.000000,Max=24.000000),Y=(Min=-24.000000,Max=24.000000),Z=(Min=70.000000,Max=115.000000))
     End Object
     Emitters(3)=SpriteEmitter'XGame.WaterSplash.SpriteEmitter12'

     AutoDestroy=True
     bNoDelete=False
     bHighDetail=True
}
