class NewLinkTrail extends Emitter;

#exec OBJ LOAD FILE=AW-2004Particles.utx

function MakeYellow()
{
	if ( Emitters[1] != None )
	{
		Emitters[1].ColorScale[1].Color.R = 255;
		Emitters[1].ColorScale[2].Color.R = 255;
	}
}

function Delay(float DelayTime)
{
	if ( Emitters[0] != None )
	{
		Emitters[0].InitialDelayRange.Min = DelayTime;
		Emitters[0].InitialDelayRange.Max = DelayTime;
	}
	if ( Emitters[1] != None )
	{
		Emitters[1].InitialDelayRange.Min = DelayTime;
		Emitters[1].InitialDelayRange.Max = DelayTime;
	}
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter21
         UseDirectionAs=PTDU_Right
         AutomaticInitialSpawning=False
         ColorMultiplierRange=(X=(Min=0.250000,Max=0.250000),Z=(Min=0.000000,Max=0.000000))
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartLocationOffset=(X=30.000000)
         StartSizeRange=(X=(Min=-80.000000,Max=-80.000000),Y=(Min=30.000000,Max=30.000000))
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'AW-2004Particles.Weapons.PlasmaShaft'
         LifetimeRange=(Min=0.010000,Max=0.010000)
         StartVelocityRange=(X=(Min=-10.000000,Max=-10.000000))
         WarmupTicksPerSecond=1.000000
         RelativeWarmupTime=1.000000
     End Object
     Emitters(0)=SpriteEmitter'XEffects.NewLinkTrail.SpriteEmitter21'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter18
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         UseRandomSubdivision=True
         ColorScale(1)=(RelativeTime=0.100000,Color=(G=255,R=96))
         ColorScale(2)=(RelativeTime=0.800000,Color=(G=255))
         ColorScale(3)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=6
         DetailMode=DM_SuperHigh
         StartLocationOffset=(X=-35.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=0.300000,RelativeSize=0.900000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.250000)
         StartSizeRange=(X=(Min=20.000000,Max=20.000000))
         Texture=Texture'AW-2004Particles.Weapons.SmokePanels1'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.350000,Max=0.350000)
         StartVelocityRange=(X=(Min=400.000000,Max=400.000000))
         WarmupTicksPerSecond=1.000000
         RelativeWarmupTime=3.000000
     End Object
     Emitters(1)=SpriteEmitter'XEffects.NewLinkTrail.SpriteEmitter18'

     bNoDelete=False
     Physics=PHYS_Trailer
     DrawScale=0.500000
}
