//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSVehicleBuildEffect extends Emitter;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Level.NetMode == NM_DedicatedServer)
		LifeSpan = 0.5;
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         UseDirectionAs=PTDU_Up
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255))
         FadeOutStartTime=0.120000
         FadeInEndTime=0.050000
         MaxParticles=32
         StartLocationRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-80.000000,Max=80.000000))
         StartSizeRange=(X=(Min=150.000000,Max=200.000000),Y=(Min=150.000000,Max=200.000000))
         ScaleSizeByVelocityMultiplier=(X=0.100000,Y=0.005000)
         ScaleSizeByVelocityMax=5000.000000
         InitialParticlesPerSecond=60.000000
         Texture=Texture'VMParticleTextures.buildEffects.PC_buildStreaks'
         LifetimeRange=(Min=0.150000,Max=0.150000)
         InitialDelayRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(Z=(Min=2000.000000,Max=2500.000000))
     End Object
     Emitters(0)=SpriteEmitter'Onslaught.ONSVehicleBuildEffect.SpriteEmitter3'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter4
         UseDirectionAs=PTDU_Normal
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255))
         FadeOutStartTime=0.250000
         FadeInEndTime=0.100000
         CoordinateSystem=PTCS_Relative
         MaxParticles=35
         StartLocationOffset=(Z=-50.000000)
         StartLocationRange=(X=(Min=-10.000000,Max=-10.000000),Z=(Min=-50.000000,Max=-50.000000))
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=0.750000)
         StartSizeRange=(X=(Min=200.000000,Max=200.000000),Y=(Min=180.000000,Max=180.000000))
         InitialParticlesPerSecond=15.000000
         Texture=Texture'VMParticleTextures.buildEffects.PC_buildBorderNew'
         LifetimeRange=(Min=0.300000,Max=0.300000)
         StartVelocityRange=(Z=(Min=500.000000,Max=500.000000))
     End Object
     Emitters(1)=SpriteEmitter'Onslaught.ONSVehicleBuildEffect.SpriteEmitter4'

     Begin Object Class=MeshEmitter Name=MeshEmitter0
         StaticMesh=StaticMesh'VMStructures.CoreGroup.CoreShieldSM'
         RenderTwoSided=True
         UseParticleColor=True
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255))
         FadeOutStartTime=0.500000
         FadeInEndTime=0.100000
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartLocationOffset=(Z=-40.000000)
         StartLocationRange=(Z=(Min=-20.000000,Max=-20.000000))
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Min=0.357000,Max=0.783000))
         StartSizeRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000))
         InitialParticlesPerSecond=60.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         InitialDelayRange=(Min=2.000000,Max=2.000000)
     End Object
     Emitters(2)=MeshEmitter'Onslaught.ONSVehicleBuildEffect.MeshEmitter0'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     RemoteRole=ROLE_DumbProxy
}
