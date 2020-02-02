//=============================================================================
// FX_SpaceFighter_SkaarjPlasma
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class FX_SpaceFighter_SkaarjPlasma extends Emitter
	notplaceable;

simulated function SetRedColor()
{
	Emitters[0].ColorScale[0].Color = class'Canvas'.static.MakeColor(255, 64, 0);
	Emitters[0].ColorScale[1].Color = Emitters[0].ColorScale[0].Color;

	Emitters[1].ColorScale[0].Color = class'Canvas'.static.MakeColor(255,128, 96);
	Emitters[1].ColorScale[1].Color = class'Canvas'.static.MakeColor(255, 64, 48);

	Emitters[2].ColorScale[0].Color = class'Canvas'.static.MakeColor(200, 64, 64);
	Emitters[2].ColorScale[1].Color = Emitters[2].ColorScale[0].Color;
}

simulated function SetScale( float Scale )
{
	Emitters[0].StartLocationOffset.X = 240 * Scale;
	Emitters[0].StartSizeRange.X.Min = 128 * Scale;
	Emitters[0].StartSizeRange.X.Max = 160 * Scale;

	Emitters[1].StartLocationOffset.X = 250 * Scale;
	Emitters[1].LifetimeRange.Min = 2.5 * Scale;
	Emitters[1].LifetimeRange.Max = Emitters[1].LifetimeRange.Min;
	Emitters[1].StartSizeRange.X.Min = 16 * Scale;
	Emitters[1].StartSizeRange.X.Max = 45 * Scale;

	Emitters[2].StartLocationOffset.X = 257 * Scale;
	Emitters[2].StartLocationOffset.Y = -10 * Scale;
    Emitters[2].StartLocationRange.Y.Min = 10 * Scale;
	Emitters[2].StartLocationRange.Y.Max = Emitters[2].StartLocationRange.Y.Min;
	Emitters[2].StartSizeRange.X.Min = 2.5 * Scale;
	Emitters[2].StartSizeRange.X.Max = Emitters[2].StartSizeRange.X.Min;
	Emitters[2].StartSizeRange.Y.Min = 5.0 * Scale;
	Emitters[2].StartSizeRange.Y.Max = Emitters[2].StartSizeRange.Y.Min;
	Emitters[2].StartSizeRange.Z.Min = Emitters[2].StartSizeRange.Y.Min;
	Emitters[2].StartSizeRange.Z.Max = Emitters[2].StartSizeRange.Y.Min;
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         ColorScale(0)=(Color=(B=255,G=128,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=128,A=255))
         Opacity=0.660000
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         StartLocationOffset=(X=240.000000)
         SpinCCWorCW=(Y=0.000000,Z=0.000000)
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=128.000000,Max=160.000000))
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'EpicParticles.Flares.SoftFlare'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.080000,Max=0.160000)
         WarmupTicksPerSecond=1.000000
         RelativeWarmupTime=5.000000
     End Object
     Emitters(0)=SpriteEmitter'UT2k4AssaultFull.FX_SpaceFighter_SkaarjPlasma.SpriteEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         UseColorScale=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ColorScale(0)=(Color=(B=255,G=128,R=96))
         ColorScale(1)=(RelativeTime=0.660000,Color=(B=255,G=64,R=48))
         ColorScale(2)=(RelativeTime=1.000000)
         Opacity=0.660000
         FadeOutStartTime=2.000000
         FadeInEndTime=0.080000
         CoordinateSystem=PTCS_Relative
         DetailMode=DM_High
         StartLocationOffset=(X=250.000000)
         SpinsPerSecondRange=(X=(Min=0.250000,Max=0.330000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=2.000000)
         SizeScale(1)=(RelativeTime=0.100000,RelativeSize=1.200000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.330000)
         StartSizeRange=(X=(Min=16.000000,Max=45.000000))
         DrawStyle=PTDS_Brighten
         Texture=Texture'EpicParticles.Smoke.StellarFog1aw'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.500000,Max=2.500000)
         StartVelocityRange=(X=(Min=-200.000000,Max=-200.000000))
         WarmupTicksPerSecond=1.000000
         RelativeWarmupTime=5.000000
     End Object
     Emitters(1)=SpriteEmitter'UT2k4AssaultFull.FX_SpaceFighter_SkaarjPlasma.SpriteEmitter3'

     Begin Object Class=MeshEmitter Name=MeshEmitter1
         StaticMesh=StaticMesh'AS_Weapons_SM.Projectiles.Skaarj_Energy'
         UseMeshBlendMode=False
         RenderTwoSided=True
         UseColorScale=True
         SpinParticles=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=200,G=64,R=64))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=200,G=64,R=64))
         Opacity=0.660000
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartLocationOffset=(X=257.000000,Y=-10.000000)
         StartLocationRange=(Y=(Min=10.000000,Max=10.000000))
         SpinCCWorCW=(X=1.000000,Y=1.000000,Z=1.000000)
         SpinsPerSecondRange=(Z=(Min=1.100000,Max=1.100000))
         StartSizeRange=(X=(Min=2.500000,Max=2.500000),Y=(Min=5.000000,Max=5.000000),Z=(Min=5.000000,Max=5.000000))
         InitialParticlesPerSecond=1.000000
         SecondsBeforeInactive=0.000000
         WarmupTicksPerSecond=1.000000
         RelativeWarmupTime=1.000000
     End Object
     Emitters(2)=MeshEmitter'UT2k4AssaultFull.FX_SpaceFighter_SkaarjPlasma.MeshEmitter1'

     bNoDelete=False
     bHardAttach=True
     bDirectional=True
}
