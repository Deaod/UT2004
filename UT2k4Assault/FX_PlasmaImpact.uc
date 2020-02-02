//=============================================================================
// FX_PlasmaImpact
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class FX_PlasmaImpact extends Emitter
	notplaceable;

simulated function PreBeginPlay()
{
	if ( Level.DetailMode < DM_SuperHigh )	// switch to lower res
	{
		Emitters[0].Disabled = true;
		Emitters[2].Disabled = false;
	}

	SetScale( 1.f );
	super.PreBeginPlay();
}

simulated function SetRedColor()
{
	Emitters[0].ColorScale[0].Color = class'Canvas'.static.MakeColor(200, 160, 96);
	Emitters[0].ColorScale[1].Color = class'Canvas'.static.MakeColor(200,  80, 48);
	Emitters[2].ColorScale[0].Color = Emitters[0].ColorScale[0].Color;
	Emitters[2].ColorScale[1].Color = Emitters[0].ColorScale[1].Color;

	Emitters[1].ColorScale[0].Color = Emitters[0].ColorScale[0].Color;
	Emitters[1].ColorScale[1].Color = Emitters[0].ColorScale[1].Color;
}

simulated function SetGreenColor()
{
	Emitters[0].ColorScale[0].Color = class'Canvas'.static.MakeColor(128, 255, 64);
	Emitters[0].ColorScale[1].Color = class'Canvas'.static.MakeColor( 64, 255, 32);
	Emitters[2].ColorScale[0].Color = Emitters[0].ColorScale[0].Color;
	Emitters[2].ColorScale[1].Color = Emitters[0].ColorScale[1].Color;

	Emitters[1].ColorScale[0].Color = Emitters[0].ColorScale[0].Color;
	Emitters[1].ColorScale[1].Color = Emitters[0].ColorScale[1].Color;
}

simulated function SetYellowColor()
{
	Emitters[0].ColorScale[0].Color = class'Canvas'.static.MakeColor(255, 255, 64);
	Emitters[0].ColorScale[1].Color = class'Canvas'.static.MakeColor(192, 255, 32);
	Emitters[2].ColorScale[0].Color = Emitters[0].ColorScale[0].Color;
	Emitters[2].ColorScale[1].Color = Emitters[0].ColorScale[1].Color;

	Emitters[1].ColorScale[0].Color = Emitters[0].ColorScale[0].Color;
	Emitters[1].ColorScale[1].Color = Emitters[0].ColorScale[1].Color;
}

simulated function SetScale( float Scale )
{
	Scale = Scale*0.75;
	Emitters[0].StartSizeRange.X.Min = 2 * Scale;
	Emitters[0].StartSizeRange.X.Max = 50 * Scale;
	Emitters[0].StartVelocityRange.X.Min = 75 * Scale;
	Emitters[0].StartVelocityRange.X.Max = 300 * Scale;
	Emitters[0].StartVelocityRange.Y.Min = -300 * Scale;
	Emitters[0].StartVelocityRange.Y.Max = Emitters[0].StartVelocityRange.X.Max;
	Emitters[0].StartVelocityRange.Z.Min = Emitters[0].StartVelocityRange.Y.Min;
	Emitters[0].StartVelocityRange.Z.Max = Emitters[0].StartVelocityRange.Y.Max;

	Emitters[1].StartSizeRange.X.Min = 25 * Scale;
	Emitters[1].StartSizeRange.X.Max = 50 * Scale;

	Emitters[2].StartSizeRange = Emitters[0].StartSizeRange;
	Emitters[2].StartVelocityRange = Emitters[0].StartVelocityRange;
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter34
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=128,R=64))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=255,G=128,R=64))
         ColorScale(2)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=20
         SpinsPerSecondRange=(X=(Min=0.100000,Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=2.000000,Max=50.000000))
         InitialParticlesPerSecond=300.000000
         Texture=Texture'AS_FX_TX.Flares.Laser_Flare'
         LifetimeRange=(Min=0.400000,Max=0.600000)
         StartVelocityRange=(X=(Min=75.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Min=-300.000000,Max=300.000000))
     End Object
     Emitters(0)=SpriteEmitter'UT2k4Assault.FX_PlasmaImpact.SpriteEmitter34'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter35
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=128,R=64))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=255,G=128,R=64))
         ColorScale(2)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         SpinsPerSecondRange=(X=(Min=0.010000,Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=25.000000,Max=50.000000))
         InitialParticlesPerSecond=30.000000
         Texture=Texture'AS_FX_TX.Flares.Laser_Flare'
         LifetimeRange=(Min=0.670000,Max=0.670000)
     End Object
     Emitters(1)=SpriteEmitter'UT2k4Assault.FX_PlasmaImpact.SpriteEmitter35'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter36
         UseColorScale=True
         RespawnDeadParticles=False
         Disabled=True
         Backup_Disabled=True
         SpinParticles=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=128,R=64))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=255,G=128,R=64))
         ColorScale(2)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         SpinsPerSecondRange=(X=(Min=0.100000,Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=2.000000,Max=50.000000))
         InitialParticlesPerSecond=300.000000
         Texture=Texture'AS_FX_TX.Flares.Laser_Flare'
         LifetimeRange=(Min=0.400000,Max=0.600000)
         StartVelocityRange=(X=(Min=75.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Min=-300.000000,Max=300.000000))
     End Object
     Emitters(2)=SpriteEmitter'UT2k4Assault.FX_PlasmaImpact.SpriteEmitter36'

     AutoDestroy=True
     bNoDelete=False
     bDirectional=True
}
