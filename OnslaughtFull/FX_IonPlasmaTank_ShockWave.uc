//=============================================================================
// FX_IonPlasmaTank_ShockWave
//=============================================================================
// Created by Laurent Delayen (C) 2003 Epic Games
//=============================================================================

class FX_IonPlasmaTank_ShockWave extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter77
         UseDirectionAs=PTDU_Normal
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.330000,Color=(B=255,G=192,R=160))
         ColorScale(2)=(RelativeTime=0.670000,Color=(B=255,G=192,R=160))
         ColorScale(3)=(RelativeTime=1.000000)
         Opacity=0.670000
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartLocationOffset=(Z=-32.000000)
         StartLocationRange=(Z=(Min=-16.000000,Max=16.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=10.000000)
         StartSizeRange=(X=(Min=75.000000))
         InitialParticlesPerSecond=4.000000
         Texture=Texture'AW-2004Particles.Energy.AirBlast'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.670000,Max=0.670000)
     End Object
     Emitters(0)=SpriteEmitter'OnslaughtFull.FX_IonPlasmaTank_ShockWave.SpriteEmitter77'

     Begin Object Class=MeshEmitter Name=MeshEmitter1
         StaticMesh=StaticMesh'AS_Weapons_SM.fX.ShockRing'
         RenderTwoSided=True
         UseParticleColor=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.330000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=0.670000,Color=(B=255,G=255,R=255))
         ColorScale(3)=(RelativeTime=1.000000)
         Opacity=0.200000
         CoordinateSystem=PTCS_Relative
         MaxParticles=6
         StartLocationRange=(Z=(Max=64.000000))
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=15.000000)
         StartSizeRange=(X=(Min=0.330000,Max=0.670000),Y=(Min=0.330000,Max=0.670000),Z=(Min=0.500000,Max=1.500000))
         InitialParticlesPerSecond=8.000000
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.670000,Max=0.670000)
     End Object
     Emitters(1)=MeshEmitter'OnslaughtFull.FX_IonPlasmaTank_ShockWave.MeshEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter78
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.330000,Color=(B=255,G=128,R=128))
         ColorScale(2)=(RelativeTime=0.670000,Color=(B=255,G=128,R=128))
         ColorScale(3)=(RelativeTime=1.000000)
         Opacity=0.900000
         CoordinateSystem=PTCS_Relative
         MaxParticles=4
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=8.000000)
         StartSizeRange=(X=(Min=50.000000))
         InitialParticlesPerSecond=6.000000
         Texture=Texture'EpicParticles.Smoke.Maelstrom01aw'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.670000,Max=0.670000)
     End Object
     Emitters(2)=SpriteEmitter'OnslaughtFull.FX_IonPlasmaTank_ShockWave.SpriteEmitter78'

     AutoDestroy=True
     bNoDelete=False
     RemoteRole=ROLE_DumbProxy
     bDirectional=True
}
