class ONSDamagedEffect extends Emitter
	native;

#exec OBJ LOAD FILE=..\Textures\AW-2004Particles.utx
#exec OBJ LOAD FILE=..\Textures\EpicParticles.utx

simulated function PostBeginPlay()
{
	local ONSVehicle V;

	Super.PostBeginPlay();

	V = ONSVehicle(Owner);
	if (V != None)
	{
		SetEffectScale(V.DamagedEffectScale);
		UpdateDamagedEffect(false, 0);
	}
}

simulated function SetEffectScale(float Scaling)
{
	Emitters[0].SizeScale[0].RelativeSize = Scaling * default.Emitters[0].SizeScale[0].RelativeSize;
	Emitters[0].SizeScale[1].RelativeSize = Scaling * default.Emitters[0].SizeScale[1].RelativeSize;


	Emitters[1].SizeScale[0].RelativeSize = Scaling * default.Emitters[1].SizeScale[0].RelativeSize;
	Emitters[1].SizeScale[1].RelativeSize = Scaling * default.Emitters[1].SizeScale[1].RelativeSize;
	Emitters[1].SizeScale[2].RelativeSize = Scaling * default.Emitters[1].SizeScale[2].RelativeSize;

	Emitters[1].StartLocationRange.X.Min = Scaling * default.Emitters[1].StartLocationRange.X.Min;
	Emitters[1].StartLocationRange.X.Max = Scaling * default.Emitters[1].StartLocationRange.X.Max;
	Emitters[1].StartLocationRange.Y.Min = Scaling * default.Emitters[1].StartLocationRange.Y.Min;
	Emitters[1].StartLocationRange.Y.Max = Scaling * default.Emitters[1].StartLocationRange.Y.Max;


	Emitters[2].StartSizeRange.X.Min = Scaling * default.Emitters[2].StartSizeRange.X.Min;
	Emitters[2].StartSizeRange.X.Max = Scaling * default.Emitters[2].StartSizeRange.X.Max;
	Emitters[2].StartSizeRange.Y.Min = Scaling * default.Emitters[2].StartSizeRange.Y.Min;
	Emitters[2].StartSizeRange.Y.Max = Scaling * default.Emitters[2].StartSizeRange.Y.Max;

	Emitters[2].StartLocationRange.X.Min = Scaling * default.Emitters[2].StartLocationRange.X.Min;
	Emitters[2].StartLocationRange.X.Max = Scaling * default.Emitters[2].StartLocationRange.X.Max;
	Emitters[2].StartLocationRange.Y.Min = Scaling * default.Emitters[2].StartLocationRange.Y.Min;
	Emitters[2].StartLocationRange.Y.Max = Scaling * default.Emitters[2].StartLocationRange.Y.Max;
}

//Called from ONSVehicle native code when significant changes in vehicle's health or velocity occur
simulated event UpdateDamagedEffect(bool bFlame, float VelMag)
{
	local float SmokeLifeScale;

	if(bFlame)
	{
		Emitters[1].ParticlesPerSecond = default.Emitters[1].ParticlesPerSecond;
		Emitters[1].InitialParticlesPerSecond = default.Emitters[1].InitialParticlesPerSecond;
		Emitters[1].AllParticlesDead = false;

		Emitters[2].ParticlesPerSecond = default.Emitters[2].ParticlesPerSecond;
		Emitters[2].InitialParticlesPerSecond = default.Emitters[2].InitialParticlesPerSecond;
		Emitters[2].AllParticlesDead = false;
	} 
	else
	{
		Emitters[1].ParticlesPerSecond = 0;
		Emitters[1].InitialParticlesPerSecond = 0;

		Emitters[2].ParticlesPerSecond = 0;
		Emitters[2].InitialParticlesPerSecond = 0;
	}

	SmokeLifeScale = 1.0 - ( 0.55 * ((VelMag-500)/2000) );
	SmokeLifeScale = FClamp(SmokeLifeScale, 0.45, 1.0);

	Emitters[0].InitialParticlesPerSecond = 7.5/SmokeLifeScale;
	Emitters[0].ParticlesPerSecond = 7.5/SmokeLifeScale;
	Emitters[0].LifetimeRange.Min = 2.0 * SmokeLifeScale;
	Emitters[0].LifetimeRange.Max = 2.0 * SmokeLifeScale;
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         UseVelocityScale=True
         Acceleration=(Z=175.000000)
         ColorScale(0)=(Color=(B=192,G=192,R=192))
         ColorScale(1)=(RelativeTime=0.100000,Color=(B=160,G=160,R=160,A=255))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=128,G=128,R=128,A=192))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
         MaxParticles=50
         StartLocationRange=(Z=(Max=20.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartSizeRange=(X=(Min=50.000000,Max=50.000000))
         ParticlesPerSecond=25.000000
         InitialParticlesPerSecond=25.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'AW-2004Particles.Weapons.DustSmoke'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=2.500000,Max=1.500000)
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=200.000000,Max=200.000000))
         VelocityScale(0)=(RelativeVelocity=(Z=0.500000))
         VelocityScale(1)=(RelativeTime=0.500000,RelativeVelocity=(X=0.200000,Y=0.200000,Z=0.200000))
         VelocityScale(2)=(RelativeTime=1.000000,RelativeVelocity=(X=1.000000,Y=1.000000,Z=0.200000))
     End Object
     Emitters(0)=SpriteEmitter'Onslaught.ONSDamagedEffect.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=50.000000)
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=34,G=135,R=210,A=255))
         ColorScale(2)=(RelativeTime=0.600000,Color=(B=255,G=255,R=255,A=64))
         ColorScale(3)=(RelativeTime=1.000000)
         Opacity=0.500000
         CoordinateSystem=PTCS_Relative
         MaxParticles=4
         StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000))
         StartLocationShape=PTLS_All
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.200000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartSizeRange=(X=(Min=10.000000,Max=20.000000))
         ParticlesPerSecond=8.000000
         InitialParticlesPerSecond=8.000000
         Texture=Texture'AW-2004Particles.Fire.NapalmSpot'
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRange=(Z=(Min=4.000000,Max=4.000000))
     End Object
     Emitters(1)=SpriteEmitter'Onslaught.ONSDamagedEffect.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=9,G=175,R=255))
         ColorScale(2)=(RelativeTime=0.400000,Color=(B=13,G=122,R=242))
         ColorScale(3)=(RelativeTime=1.000000)
         StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000))
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.750000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=20.000000,Max=30.000000))
         ParticlesPerSecond=25.000000
         InitialParticlesPerSecond=25.000000
         Texture=Texture'AW-2004Particles.Fire.SmokeFragment'
         LifetimeRange=(Min=0.150000,Max=0.150000)
         StartVelocityRange=(Z=(Min=140.000000,Max=180.000000))
     End Object
     Emitters(2)=SpriteEmitter'Onslaught.ONSDamagedEffect.SpriteEmitter2'

     AutoDestroy=True
     bNoDelete=False
     bHardAttach=True
}
