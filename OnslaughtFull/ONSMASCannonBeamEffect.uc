//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSMASCannonBeamEffect extends Emitter;

var bool bCancel;

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority)
		bCancel;
}

simulated function Cancel()
{
	bCancel = True;
	bTearOff = True;
	SpriteEmitter(Emitters[2]).FadeOut = True;
	SpriteEmitter(Emitters[2]).LifeTimeRange.Min = 0.5;
	SpriteEmitter(Emitters[2]).LifeTimeRange.Max = 0.5;
	SpriteEmitter(Emitters[2]).SizeScale[0].RelativeTime = 3.0;
	SpriteEmitter(Emitters[2]).SizeScale[0].RelativeSize = 0.0;
	Kill();
}

function PostNetRecieve()
{
    if (bCancel)
        Cancel();
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=0.070000
         FadeInEndTime=0.025000
         MaxParticles=80
         StartSpinRange=(X=(Min=0.750000,Max=5.000000))
         StartSizeRange=(X=(Min=650.000000,Max=650.000000))
         InitialParticlesPerSecond=40.000000
         Texture=Texture'AW-2004Particles.Weapons.PlasmaStar2'
         LifetimeRange=(Min=0.020000,Max=0.020000)
         InitialDelayRange=(Min=1.300000,Max=1.300000)
     End Object
     Emitters(0)=SpriteEmitter'OnslaughtFull.ONSMASCannonBeamEffect.SpriteEmitter3'

     Begin Object Class=BeamEmitter Name=BeamEmitter2
         BeamDistanceRange=(Min=10000.000000,Max=10000.000000)
         DetermineEndPointBy=PTEP_Distance
         FadeOut=True
         RespawnDeadParticles=False
         AlphaTest=False
         UseSizeScale=True
         UseRegularSizeScale=False
         FadeOutStartTime=0.500000
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         StartLocationOffset=(X=100.000000)
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=6.000000)
         StartSizeRange=(X=(Min=50.000000,Max=20.000000))
         InitialParticlesPerSecond=50.000000
         Texture=Texture'VMParticleTextures.LeviathanParticleEffects.LEVmainPartBeam'
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(X=(Min=-100.000000,Max=-100.000000))
     End Object
     Emitters(1)=BeamEmitter'OnslaughtFull.ONSMASCannonBeamEffect.BeamEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter4
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=3.100000
         MaxParticles=1
         SizeScale(0)=(RelativeTime=3.000000,RelativeSize=40.000000)
         InitialParticlesPerSecond=2.000000
         Texture=Texture'VMParticleTextures.LeviathanParticleEffects.LeviathanMGUNFlare'
         LifetimeRange=(Min=3.300000,Max=3.300000)
     End Object
     Emitters(2)=SpriteEmitter'OnslaughtFull.ONSMASCannonBeamEffect.SpriteEmitter4'

     AutoDestroy=True
     LightHue=180
     LightSaturation=255
     LightBrightness=255.000000
     bNoDelete=False
     bNetNotify=True
}
