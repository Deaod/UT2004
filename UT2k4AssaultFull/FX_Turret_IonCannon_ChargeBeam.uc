//=============================================================================
// FX_Turret_IonCannon_ChargeBeam
//=============================================================================
// Created by Laurent Delayen (C) 2003 Epic Games
//=============================================================================

class FX_Turret_IonCannon_ChargeBeam extends Emitter
	notplaceable;


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     Begin Object Class=BeamEmitter Name=BeamEmitter7
         BeamDistanceRange=(Min=590.000000,Max=590.000000)
         DetermineEndPointBy=PTEP_Distance
         RotatingSheets=3
         LowFrequencyPoints=2
         HighFrequencyPoints=2
         UseColorScale=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=64,R=160))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=128,R=128))
         Opacity=0.660000
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartSizeRange=(X=(Min=15.000000,Max=50.000000))
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'AS_FX_TX.Beams.HotBolt_1'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.080000,Max=0.160000)
         StartVelocityRange=(X=(Min=0.001000,Max=0.001000))
     End Object
     Emitters(0)=BeamEmitter'UT2k4AssaultFull.FX_Turret_IonCannon_ChargeBeam.BeamEmitter7'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter15
         UseColorScale=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=64,R=160))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=128,R=128))
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartSizeRange=(X=(Min=75.000000))
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'EpicParticles.Flares.SoftFlare'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.080000,Max=0.160000)
     End Object
     Emitters(1)=SpriteEmitter'UT2k4AssaultFull.FX_Turret_IonCannon_ChargeBeam.SpriteEmitter15'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter21
         UseColorScale=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=64,R=160))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=128,R=128))
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartLocationOffset=(X=590.000000)
         StartSizeRange=(X=(Min=75.000000))
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'EpicParticles.Flares.SoftFlare'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.080000,Max=0.160000)
     End Object
     Emitters(2)=SpriteEmitter'UT2k4AssaultFull.FX_Turret_IonCannon_ChargeBeam.SpriteEmitter21'

     bNoDelete=False
     bHardAttach=True
     bDirectional=True
}
