class FX_SpaceFighter_3rdpMuzzle extends Emitter
	notplaceable;

#exec OBJ LOAD FILE=EpicParticles.utx

simulated function SetRedColor()
{
	Emitters[0].ColorScale[0].Color = class'Canvas'.static.MakeColor(200, 80, 48);
}

simulated function SetScale( float Scale )
{
	Emitters[0].StartSizeRange.X.Min = 75.f * Scale;
	Emitters[0].StartSizeRange.X.Max = Emitters[0].StartSizeRange.X.Min;
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=128,R=64))
         ColorScale(1)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         SpinsPerSecondRange=(X=(Max=0.040000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.330000,RelativeSize=0.250000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=75.000000,Max=75.000000))
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'AW-2004Particles.Weapons.PlasmaStar'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(0)=SpriteEmitter'UT2k4Assault.FX_SpaceFighter_3rdpMuzzle.SpriteEmitter1'

     bNoDelete=False
     bHardAttach=True
     bDirectional=True
}
