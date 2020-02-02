class ONSHoverBikeHoverDust extends Emitter;

#exec OBJ LOAD FILE=..\Textures\AW-2004Particles.utx

var	bool	bDustActive;

simulated function SetDustColor(color DustColor)
{
	local color DustColorZeroAlpha, BlackColor;

	// Ignore if dust color if black.
	if(DustColor.R == 0 && DustColor.G == 0 && DustColor.B == 0)
	{
		DustColor.R=128;
		DustColor.G=100;
		DustColor.B=64;
	}
//		return;

	DustColor.A = 255;

	DustColorZeroAlpha = DustColor;
	DustColorZeroAlpha.A = 0;

	BlackColor.R = 0;
	BlackColor.G = 0;
	BlackColor.B = 0;
	BlackColor.A = 0;

	Emitters[0].ColorScale[0].Color = DustColorZeroAlpha;
	Emitters[0].ColorScale[1].Color = DustColor;
	Emitters[0].ColorScale[2].Color = DustColor;
	Emitters[0].ColorScale[3].Color = DustColorZeroAlpha;

	Emitters[1].ColorScale[0].Color = BlackColor;
	Emitters[1].ColorScale[1].Color = DustColor;
	Emitters[1].ColorScale[2].Color = DustColor;
	Emitters[1].ColorScale[3].Color = BlackColor;
}

simulated function UpdateHoverDust(bool bActive, float HoverHeight)
{
	local float Force;

	Force = 1 - HoverHeight;

	if(!bActive)
	{
		Emitters[0].ParticlesPerSecond = 0;
		Emitters[0].InitialParticlesPerSecond = 0;
		Emitters[1].Disabled = true;
		return;
	}
	else
	{
		Emitters[0].ParticlesPerSecond = 100;
		Emitters[0].InitialParticlesPerSecond = 100;
		Emitters[0].AllParticlesDead = false;
		Emitters[1].Disabled = (Level.DetailMode == DM_Low);
	}

	// Dust
	Emitters[0].StartVelocityRadialRange.Min = -650 + (Force * -100);
	Emitters[0].StartVelocityRadialRange.Max = Emitters[0].StartVelocityRadialRange.Min - 100;

	Emitters[0].StartLocationPolarRange.Z.Min = 10 + (HoverHeight * 30);
	Emitters[0].StartLocationPolarRange.Z.Max = Emitters[0].StartLocationPolarRange.Z.Min;

	// Rings
	Emitters[1].StartSizeRange.X.Min = 30 + (HoverHeight * 40);
	Emitters[1].StartSizeRange.X.Max = Emitters[1].StartSizeRange.X.Min + 20;

	Emitters[1].Opacity = FClamp(2.5 * Force, 0, 0.8);
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
         UseVelocityScale=True
         Acceleration=(Z=500.000000)
         ColorScale(0)=(Color=(B=96,G=128,R=164))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=96,G=128,R=164,A=255))
         ColorScale(2)=(RelativeTime=0.500000,Color=(B=64,G=100,R=128,A=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=68,G=104,R=125))
         FadeOutStartTime=0.500000
         FadeInEndTime=0.350000
         MaxParticles=50
         StartLocationShape=PTLS_Polar
         StartLocationPolarRange=(X=(Min=16384.000000,Max=16384.000000),Y=(Max=65536.000000),Z=(Min=20.000000,Max=20.000000))
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=50.000000,Max=90.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
         ParticlesPerSecond=50.000000
         InitialParticlesPerSecond=50.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'AW-2004Particles.Weapons.SmokePanels2'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.500000,Max=0.800000)
         StartVelocityRange=(X=(Min=70.000000,Max=70.000000))
         StartVelocityRadialRange=(Min=-600.000000,Max=-800.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
         VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
         VelocityScale(1)=(RelativeTime=0.200000,RelativeVelocity=(X=0.350000,Y=0.350000,Z=0.350000))
         VelocityScale(2)=(RelativeTime=0.500000,RelativeVelocity=(X=0.100000,Y=0.100000,Z=0.100000))
         VelocityScale(3)=(RelativeTime=1.000000)
     End Object
     Emitters(0)=SpriteEmitter'Onslaught.ONSHoverBikeHoverDust.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseDirectionAs=PTDU_Normal
         ProjectionNormal=(X=1.000000,Z=0.000000)
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ColorScale(1)=(RelativeTime=0.450000,Color=(B=64,G=100,R=128))
         ColorScale(2)=(RelativeTime=0.550000,Color=(B=64,G=100,R=128))
         ColorScale(3)=(RelativeTime=1.000000)
         Opacity=0.750000
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartLocationOffset=(Z=6.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.500000)
         StartSizeRange=(X=(Min=50.000000,Max=65.000000))
         Texture=Texture'AW-2004Particles.Energy.AirBlast'
         LifetimeRange=(Min=0.300000,Max=0.300000)
     End Object
     Emitters(1)=SpriteEmitter'Onslaught.ONSHoverBikeHoverDust.SpriteEmitter1'

     CullDistance=8000.000000
     bNoDelete=False
     bHardAttach=True
}
