class FX_HoldObjective extends Emitter;

#exec OBJ LOAD FILE=EpicParticles.utx
#exec OBJ LOAD FILE=AS_FX_TX.utx
#exec OBJ LOAD FILE=AW-2004Particles.utx

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter165
         UseDirectionAs=PTDU_Forward
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         Opacity=0.750000
         MaxParticles=1
         SpinCCWorCW=(X=1.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=0.250000,Max=0.250000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.700000)
         InitialParticlesPerSecond=9999.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'EpicParticles.Flares.SoftFlare'
         LifetimeRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(Z=(Min=0.100000,Max=0.100000))
     End Object
     Emitters(0)=SpriteEmitter'UnrealGame.FX_HoldObjective.SpriteEmitter165'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter166
         UseDirectionAs=PTDU_Up
         UseColorScale=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-24.000000)
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=1
         StartLocationOffset=(Z=192.000000)
         SizeScale(0)=(RelativeSize=1.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=15.000000,Max=15.000000))
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'EpicParticles.JumpPad.PointArrows'
         LifetimeRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(Z=(Min=-16.000000,Max=-16.000000))
     End Object
     Emitters(1)=SpriteEmitter'UnrealGame.FX_HoldObjective.SpriteEmitter166'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter167
         UseDirectionAs=PTDU_Normal
         UseColorScale=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=1
         StartLocationRange=(Y=(Min=50.000000,Max=50.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=20.000000,Max=20.000000))
         InitialParticlesPerSecond=9999.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'AS_FX_TX.Emitter.HoldArrow'
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(Y=(Min=-20.000000,Max=-20.000000))
     End Object
     Emitters(2)=SpriteEmitter'UnrealGame.FX_HoldObjective.SpriteEmitter167'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter168
         UseDirectionAs=PTDU_Normal
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=1
         StartLocationRange=(X=(Min=50.000000,Max=50.000000))
         StartSpinRange=(X=(Min=16384.000000,Max=16384.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=20.000000,Max=20.000000))
         InitialParticlesPerSecond=9999.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'AS_FX_TX.Emitter.HoldArrow'
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(X=(Min=-20.000000,Max=-20.000000))
     End Object
     Emitters(3)=SpriteEmitter'UnrealGame.FX_HoldObjective.SpriteEmitter168'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter169
         UseDirectionAs=PTDU_Normal
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=1
         StartLocationRange=(Y=(Min=-50.000000,Max=-50.000000))
         StartSpinRange=(X=(Min=32768.000000,Max=32768.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=20.000000,Max=20.000000))
         InitialParticlesPerSecond=9999.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'AS_FX_TX.Emitter.HoldArrow'
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(Y=(Min=20.000000,Max=20.000000))
     End Object
     Emitters(4)=SpriteEmitter'UnrealGame.FX_HoldObjective.SpriteEmitter169'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter171
         UseDirectionAs=PTDU_Normal
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         Opacity=0.250000
         MaxParticles=2
         SpinsPerSecondRange=(X=(Min=0.001000,Max=0.010000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartSizeRange=(X=(Min=80.000000,Max=80.000000))
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'AW-2004Particles.Energy.EclipseCircle'
         LifetimeRange=(Min=3.000000,Max=3.000000)
     End Object
     Emitters(6)=SpriteEmitter'UnrealGame.FX_HoldObjective.SpriteEmitter171'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter172
         UseDirectionAs=PTDU_Normal
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=1
         StartLocationRange=(X=(Min=-50.000000,Max=-50.000000))
         StartSpinRange=(X=(Min=-16384.000000,Max=-16384.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=20.000000,Max=20.000000))
         InitialParticlesPerSecond=9999.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'AS_FX_TX.Emitter.HoldArrow'
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(X=(Min=20.000000,Max=20.000000))
     End Object
     Emitters(7)=SpriteEmitter'UnrealGame.FX_HoldObjective.SpriteEmitter172'

     bNoDelete=False
}
