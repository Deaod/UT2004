class FX_SpaceFighter_Trail_Red extends Emitter
	notplaceable;

#exec OBJ LOAD FILE=AS_FX_TX.utx

simulated function PreBeginPlay()
{
	if ( Level.DetailMode == DM_Low )
	{
		TrailEmitter(Emitters[0]).MaxPointsPerTrail = 100;
	}

	super.PreBeginPlay();
}

simulated function SetBlueColor()
{
	Emitters[0].Texture = Texture'AS_FX_TX.Trails.Trail_blue';
	Emitters[1].ColorScale[0].Color = class'Canvas'.static.MakeColor(96, 160, 255);
	Emitters[1].ColorScale[1].Color = class'Canvas'.static.MakeColor(48, 128, 255);
	Emitters[1].ColorScale[2].Color = class'Canvas'.static.MakeColor(48, 128, 255);
	Emitters[2].ColorScale[1].Color = class'Canvas'.static.MakeColor(64, 112, 220);
	Emitters[2].ColorScale[2].Color = class'Canvas'.static.MakeColor(64, 112, 220);
}

defaultproperties
{
     Begin Object Class=TrailEmitter Name=TrailEmitter0
         TrailShadeType=PTTST_Linear
         TrailLocation=PTTL_FollowEmitter
         MaxPointsPerTrail=200
         DistanceThreshold=50.000000
         UseCrossedSheets=True
         PointLifeTime=0.750000
         AutomaticInitialSpawning=False
         MaxParticles=1
         StartSizeRange=(X=(Min=4.000000,Max=4.000000))
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'AS_FX_TX.Trails.Trail_red'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=999999.000000,Max=999999.000000)
     End Object
     Emitters(0)=TrailEmitter'UT2k4Assault.FX_SpaceFighter_Trail_Red.TrailEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter15
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ColorScale(0)=(Color=(B=96,G=160,R=255))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=48,G=128,R=255))
         ColorScale(2)=(RelativeTime=0.900000,Color=(B=48,G=128,R=255))
         ColorScale(3)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=20
         StartLocationOffset=(X=30.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.150000,RelativeSize=2.000000)
         SizeScale(2)=(RelativeTime=0.750000,RelativeSize=2.000000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=3.000000,Max=6.000000))
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'EpicParticles.Flares.FlashFlare1'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRange=(X=(Min=-75.000000,Max=-75.000000))
     End Object
     Emitters(1)=SpriteEmitter'UT2k4Assault.FX_SpaceFighter_Trail_Red.SpriteEmitter15'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter26
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.330000,Color=(B=64,G=112,R=220,A=255))
         ColorScale(2)=(RelativeTime=0.660000,Color=(B=64,G=112,R=220,A=255))
         ColorScale(3)=(RelativeTime=1.000000)
         Opacity=0.660000
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         StartLocationOffset=(X=23.000000)
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=0.050000,Max=0.050000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=30.000000,Max=50.000000))
         InitialParticlesPerSecond=10.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'AS_FX_TX.Flares.Laser_Flare'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=2.000000)
     End Object
     Emitters(2)=SpriteEmitter'UT2k4Assault.FX_SpaceFighter_Trail_Red.SpriteEmitter26'

     bNoDelete=False
     bHardAttach=True
     bDirectional=True
}
