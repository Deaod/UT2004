class ONSChargeBeamEffect extends Emitter;

#exec OBJ LOAD FILE="..\Textures\AW-2004Particles.utx"

var vector HitLocation;

replication
{
	reliable if (bNetInitial && Role == ROLE_Authority)
		HitLocation;
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Level.NetMode == NM_DedicatedServer)
		LifeSpan = 1.0;
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	if (Role < ROLE_Authority)
		SetupBeam();
}

simulated function SetupBeam()
{
	local BeamEmitter.ParticleBeamEndPoint End;
	local int x;
	local float Dist;
	local PlayerController PC;

	PC = Level.GetLocalPlayerController();
	if ( (PC != None) && !PC.BeyondViewDistance(HitLocation, 0) )
		SpawnEffects(HitLocation, Normal(HitLocation - Location));

	End.Offset.X.Min = HitLocation.X;
	End.Offset.X.Max = HitLocation.X;
	End.Offset.Y.Min = HitLocation.Y;
	End.Offset.Y.Max = HitLocation.Y;
	End.Offset.Z.Min = HitLocation.Z;
	End.Offset.Z.Max = HitLocation.Z;

	Dist = VSize(HitLocation - Location);
	for (x = 0; x < 4; x++)
	{
		BeamEmitter(Emitters[x]).BeamDistanceRange.Min = Dist;
		BeamEmitter(Emitters[x]).BeamDistanceRange.Max = Dist;
		Emitters[x].StartSizeRange.X.Min *= DrawScale;
		Emitters[x].StartSizeRange.Y.Min *= DrawScale;
		Emitters[x].StartSizeRange.X.Max *= DrawScale;
		Emitters[x].StartSizeRange.Y.Max *= DrawScale;
		Emitters[x].LifetimeRange.Min *= DrawScale;
		Emitters[x].LifetimeRange.Max *= DrawScale;
		BeamEmitter(Emitters[x]).BeamEndPoints[0] = End;
	}
}

simulated function SpawnEffects(vector HitLocation, vector HitNormal)
{
	local rotator HitRotation;

	HitRotation = rotator(HitNormal);

	Spawn(class'ShockImpactFlareB',,, HitLocation, HitRotation);
	Spawn(class'ShockImpactRingB',,, HitLocation, HitRotation);
	Spawn(class'ShockImpactScorch',,, HitLocation, rotator(-HitNormal));
	Spawn(class'ShockExplosionCoreB',,, HitLocation+HitNormal*8, HitRotation);
}

defaultproperties
{
     Begin Object Class=BeamEmitter Name=BeamEmitter0
         BeamDistanceRange=(Min=512.000000,Max=512.000000)
         DetermineEndPointBy=PTEP_OffsetAsAbsolute
         RotatingSheets=3
         LowFrequencyPoints=2
         HighFrequencyPoints=2
         BranchProbability=(Max=1.000000)
         BranchSpawnAmountRange=(Max=2.000000)
         UseColorScale=True
         RespawnDeadParticles=False
         AlphaTest=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=192,G=192,R=192))
         ColorScale(1)=(RelativeTime=0.800000,Color=(B=128,G=255,R=128))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=1
         StartLocationOffset=(Y=-12.000000)
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeSize=0.750000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.250000)
         StartSizeRange=(X=(Min=60.000000,Max=60.000000),Y=(Min=60.000000,Max=60.000000))
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'AW-2004Particles.Energy.BeamBolt1a'
         LifetimeRange=(Min=0.450000,Max=0.450000)
     End Object
     Emitters(0)=BeamEmitter'Onslaught.ONSChargeBeamEffect.BeamEmitter0'

     Begin Object Class=BeamEmitter Name=BeamEmitter1
         BeamDistanceRange=(Min=512.000000,Max=512.000000)
         DetermineEndPointBy=PTEP_OffsetAsAbsolute
         RotatingSheets=3
         LowFrequencyPoints=2
         HighFrequencyPoints=2
         BranchProbability=(Max=1.000000)
         BranchSpawnAmountRange=(Max=2.000000)
         UseColorScale=True
         RespawnDeadParticles=False
         AlphaTest=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=64,G=64,R=64))
         ColorScale(1)=(RelativeTime=0.800000,Color=(B=192,G=192,R=128))
         ColorScale(2)=(RelativeTime=1.000000)
         Opacity=0.400000
         MaxParticles=1
         StartLocationOffset=(Y=-12.000000)
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=200.000000,Max=200.000000),Y=(Min=60.000000,Max=60.000000))
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'EpicParticles.Flares.SoftFlare'
         LifetimeRange=(Min=0.600000,Max=0.600000)
     End Object
     Emitters(1)=BeamEmitter'Onslaught.ONSChargeBeamEffect.BeamEmitter1'

     Begin Object Class=BeamEmitter Name=BeamEmitter2
         BeamDistanceRange=(Min=512.000000,Max=512.000000)
         DetermineEndPointBy=PTEP_OffsetAsAbsolute
         RotatingSheets=3
         LowFrequencyPoints=2
         HighFrequencyPoints=2
         BranchProbability=(Max=1.000000)
         BranchSpawnAmountRange=(Max=2.000000)
         UseColorScale=True
         RespawnDeadParticles=False
         AlphaTest=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=192,G=192,R=192))
         ColorScale(1)=(RelativeTime=0.800000,Color=(B=128,G=255,R=128))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=1
         StartLocationOffset=(Y=12.000000)
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeSize=0.750000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.250000)
         StartSizeRange=(X=(Min=60.000000,Max=60.000000),Y=(Min=60.000000,Max=60.000000))
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'AW-2004Particles.Energy.BeamBolt1a'
         LifetimeRange=(Min=0.450000,Max=0.450000)
     End Object
     Emitters(2)=BeamEmitter'Onslaught.ONSChargeBeamEffect.BeamEmitter2'

     Begin Object Class=BeamEmitter Name=BeamEmitter3
         BeamDistanceRange=(Min=512.000000,Max=512.000000)
         DetermineEndPointBy=PTEP_OffsetAsAbsolute
         RotatingSheets=3
         LowFrequencyPoints=2
         HighFrequencyPoints=2
         BranchProbability=(Max=1.000000)
         BranchSpawnAmountRange=(Max=2.000000)
         UseColorScale=True
         RespawnDeadParticles=False
         AlphaTest=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=64,G=64,R=64))
         ColorScale(1)=(RelativeTime=0.800000,Color=(B=192,G=192,R=128))
         ColorScale(2)=(RelativeTime=1.000000)
         Opacity=0.400000
         MaxParticles=1
         StartLocationOffset=(Y=12.000000)
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=200.000000,Max=200.000000),Y=(Min=60.000000,Max=60.000000))
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'EpicParticles.Flares.SoftFlare'
         LifetimeRange=(Min=0.600000,Max=0.600000)
     End Object
     Emitters(3)=BeamEmitter'Onslaught.ONSChargeBeamEffect.BeamEmitter3'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     bNetInitialRotation=True
     RemoteRole=ROLE_SimulatedProxy
}
