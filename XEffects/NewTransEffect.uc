class NewTransEffect extends Emitter;

#exec OBJ LOAD FILE="..\Staticmeshes\ParticleMeshes.usx"

function PostBeginPlay()
{
	If ( Role == ROLE_Authority )
		Instigator = Pawn(Owner);
	if ( Level.NetMode == NM_DedicatedServer )
		LifeSpan = 0.15;
	Super.PostBeginPlay();
}

simulated function PostNetBeginPlay()
{
	local PlayerController PC;
	local float Dist;
	
	if ( Instigator != None )
	{
		SetLocation(Instigator.Location);
		SetBase(Instigator);
		if ( (PlayerController(Instigator.Controller) != None) && !PlayerController(Instigator.Controller).bBehindView )
		{
			Emitters[0].InitialParticlesPerSecond *= 0.5;
			Emitters[0].SphereRadiusRange.Min *= 2.4;
			Emitters[0].SphereRadiusRange.Max *= 2.4;
			Emitters[1].Disabled = true;
		}
		else if ( (Level.NetMode == NM_Standalone) || (Level.NetMode == NM_Client) )
		{
			PC = Level.GetLocalPlayerController();
			if ( (PC != None) && (PC.ViewTarget != None) )
			{
				Dist = VSize(PC.ViewTarget.Location - Location);
				if ( Dist > PC.Region.Zone.DistanceFogEnd )
					LifeSpan = 0.01;
				else if ( Dist > 8000 )
					Emitters[1].Disabled = true;
			}
		}
	}
    PlaySound(Sound'WeaponSounds.P1WeaponSpawn1',SLOT_None);
	Super.PostNetBeginPlay();
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseColorScale=True
         RespawnDeadParticles=False
         UniformMeshScale=False
         UseRevolution=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.200000,Color=(G=12,R=255))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=128,G=128,R=255))
         ColorScale(3)=(RelativeTime=1.000000)
         MaxParticles=100
         SphereRadiusRange=(Min=24.000000,Max=24.000000)
         StartLocationPolarRange=(X=(Max=65536.000000),Y=(Min=16384.000000,Max=16384.000000),Z=(Min=48.000000,Max=64.000000))
         MeshSpawningStaticMesh=StaticMesh'ParticleMeshes.Simple.ParticleCylinder'
         MeshSpawning=PTMS_Random
         MeshScaleRange=(X=(Min=1.500000,Max=1.500000),Y=(Min=1.500000,Max=1.500000),Z=(Min=0.750000,Max=0.750000))
         RevolutionsPerSecondRange=(Z=(Max=1.000000))
         SpinsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartSizeRange=(X=(Min=10.000000,Max=20.000000))
         ScaleSizeByVelocityMultiplier=(X=0.020000,Y=0.020000)
         InitialParticlesPerSecond=150.000000
         Texture=Texture'EpicParticles.Flares.FlickerFlare2'
         LifetimeRange=(Min=0.300000,Max=0.300000)
         StartVelocityRadialRange=(Min=-100.000000,Max=-300.000000)
         VelocityLossRange=(Z=(Max=50.000000))
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(0)=SpriteEmitter'XEffects.NewTransEffect.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=128,G=128,R=255))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=64,G=64,R=255))
         ColorScale(3)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         StartLocationRange=(Z=(Min=-48.000000,Max=48.000000))
         SpinsPerSecondRange=(X=(Max=0.500000))
         StartSpinRange=(X=(Max=1.000000))
         Texture=Texture'EpicParticles.Flares.FlickerFlare2'
         LifetimeRange=(Min=0.500000,Max=0.500000)
         InitialDelayRange=(Min=0.400000,Max=0.400000)
     End Object
     Emitters(1)=SpriteEmitter'XEffects.NewTransEffect.SpriteEmitter1'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     bReplicateInstigator=True
     RemoteRole=ROLE_SimulatedProxy
}
