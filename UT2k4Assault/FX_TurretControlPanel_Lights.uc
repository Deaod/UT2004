//=============================================================================
// FX_TurretControlPanel_Lights
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class FX_TurretControlPanel_Lights extends Emitter
	notplaceable;


simulated function SetColorGreen()
{
	Emitters[0].ColorScale[1].Color = class'Canvas'.static.MakeColor(128, 200, 64);
	Emitters[0].ColorScale[2].Color = class'Canvas'.static.MakeColor(128, 200, 64);

	Emitters[1].ColorScale[1].Color = class'Canvas'.static.MakeColor(128, 200, 64);
	Emitters[1].ColorScale[2].Color = class'Canvas'.static.MakeColor(128, 200, 64);

	Emitters[2].ColorScale[1].Color = class'Canvas'.static.MakeColor(128, 200, 64);
	Emitters[2].ColorScale[2].Color = class'Canvas'.static.MakeColor(128, 200, 64);

	Emitters[3].ColorScale[1].Color = class'Canvas'.static.MakeColor(128, 200, 64);
	Emitters[3].ColorScale[2].Color = class'Canvas'.static.MakeColor(128, 200, 64);

	Emitters[4].ColorScale[1].Color = class'Canvas'.static.MakeColor(128, 200, 64);
	Emitters[4].ColorScale[2].Color = class'Canvas'.static.MakeColor(128, 200, 64);

	Emitters[5].ColorScale[1].Color = class'Canvas'.static.MakeColor(128, 200, 64);
	Emitters[5].ColorScale[2].Color = class'Canvas'.static.MakeColor(128, 200, 64);
}

simulated function SetColorRed()
{
	Emitters[0].ColorScale[1].Color = class'Canvas'.static.MakeColor(255, 96, 64);
	Emitters[0].ColorScale[2].Color = class'Canvas'.static.MakeColor(255, 96, 64);

	Emitters[1].ColorScale[1].Color = class'Canvas'.static.MakeColor(255, 96, 64);
	Emitters[1].ColorScale[2].Color = class'Canvas'.static.MakeColor(255, 96, 64);

	Emitters[2].ColorScale[1].Color = class'Canvas'.static.MakeColor(255, 96, 64);
	Emitters[2].ColorScale[2].Color = class'Canvas'.static.MakeColor(255, 96, 64);

	Emitters[3].ColorScale[1].Color = class'Canvas'.static.MakeColor(255, 96, 64);
	Emitters[3].ColorScale[2].Color = class'Canvas'.static.MakeColor(255, 96, 64);

	Emitters[4].ColorScale[1].Color = class'Canvas'.static.MakeColor(255, 96, 64);
	Emitters[4].ColorScale[2].Color = class'Canvas'.static.MakeColor(255, 96, 64);

	Emitters[5].ColorScale[1].Color = class'Canvas'.static.MakeColor(255, 96, 64);
	Emitters[5].ColorScale[2].Color = class'Canvas'.static.MakeColor(255, 96, 64);
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter51
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.330000,Color=(B=64,G=255,R=128))
         ColorScale(2)=(RelativeTime=0.660000,Color=(B=64,G=255,R=128))
         ColorScale(3)=(RelativeTime=1.000000)
         Opacity=0.660000
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartLocationOffset=(X=-7.000000,Y=34.000000,Z=1.000000)
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=0.010000,Max=0.030000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=10.000000,Max=30.000000))
         InitialParticlesPerSecond=1.500000
         Texture=Texture'AS_FX_TX.Flares.Laser_Flare'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.000000,Max=2.000000)
     End Object
     Emitters(0)=SpriteEmitter'UT2k4Assault.FX_TurretControlPanel_Lights.SpriteEmitter51'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter52
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.330000,Color=(B=64,G=255,R=128))
         ColorScale(2)=(RelativeTime=0.660000,Color=(B=64,G=255,R=128))
         ColorScale(3)=(RelativeTime=1.000000)
         Opacity=0.660000
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartLocationOffset=(X=-7.000000,Y=-34.000000,Z=1.000000)
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=0.010000,Max=0.030000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=10.000000,Max=30.000000))
         InitialParticlesPerSecond=1.500000
         Texture=Texture'AS_FX_TX.Flares.Laser_Flare'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.000000,Max=2.000000)
     End Object
     Emitters(1)=SpriteEmitter'UT2k4Assault.FX_TurretControlPanel_Lights.SpriteEmitter52'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter53
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.330000,Color=(B=64,G=255,R=128))
         ColorScale(2)=(RelativeTime=0.660000,Color=(B=64,G=255,R=128))
         ColorScale(3)=(RelativeTime=1.000000)
         Opacity=0.660000
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartLocationOffset=(X=8.000000,Y=27.000000,Z=42.000000)
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=0.010000,Max=0.030000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=10.000000,Max=30.000000))
         InitialParticlesPerSecond=1.500000
         Texture=Texture'AS_FX_TX.Flares.Laser_Flare'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.000000,Max=2.000000)
     End Object
     Emitters(2)=SpriteEmitter'UT2k4Assault.FX_TurretControlPanel_Lights.SpriteEmitter53'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter54
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.330000,Color=(B=64,G=255,R=128))
         ColorScale(2)=(RelativeTime=0.660000,Color=(B=64,G=255,R=128))
         ColorScale(3)=(RelativeTime=1.000000)
         Opacity=0.660000
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartLocationOffset=(X=8.000000,Y=-27.000000,Z=42.000000)
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=0.010000,Max=0.030000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=10.000000,Max=30.000000))
         InitialParticlesPerSecond=1.500000
         Texture=Texture'AS_FX_TX.Flares.Laser_Flare'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.000000,Max=2.000000)
     End Object
     Emitters(3)=SpriteEmitter'UT2k4Assault.FX_TurretControlPanel_Lights.SpriteEmitter54'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter55
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.330000,Color=(B=64,G=255,R=128))
         ColorScale(2)=(RelativeTime=0.660000,Color=(B=64,G=255,R=128))
         ColorScale(3)=(RelativeTime=1.000000)
         Opacity=0.660000
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartLocationOffset=(Y=38.000000,Z=23.000000)
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=0.010000,Max=0.030000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=10.000000,Max=30.000000))
         InitialParticlesPerSecond=1.500000
         Texture=Texture'AS_FX_TX.Flares.Laser_Flare'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.000000,Max=2.000000)
     End Object
     Emitters(4)=SpriteEmitter'UT2k4Assault.FX_TurretControlPanel_Lights.SpriteEmitter55'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter56
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.330000,Color=(B=64,G=255,R=128))
         ColorScale(2)=(RelativeTime=0.660000,Color=(B=64,G=255,R=128))
         ColorScale(3)=(RelativeTime=1.000000)
         Opacity=0.660000
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartLocationOffset=(Y=-38.000000,Z=23.000000)
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=0.010000,Max=0.030000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=10.000000,Max=30.000000))
         InitialParticlesPerSecond=1.500000
         Texture=Texture'AS_FX_TX.Flares.Laser_Flare'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.000000,Max=2.000000)
     End Object
     Emitters(5)=SpriteEmitter'UT2k4Assault.FX_TurretControlPanel_Lights.SpriteEmitter56'

     bNoDelete=False
     bDirectional=True
}
