class PlayerSpawnEffect extends Emitter;

/* misnamed, as this is actually the pickup respawn effect
*/
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( Level.NetMode == NM_DedicatedServer )
		LifeSpan = 0.15;
	else if ( Level.GetLocalPlayerController().BeyondViewDistance(Location, CullDistance)  )
		LifeSpan = 0.01;
	else
		PlaySound(sound'WeaponSounds.item_respawn');
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
         ResetOnTrigger=True
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=64,G=255,R=255))
         ColorMultiplierRange=(Y=(Min=0.700000))
         MaxParticles=40
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=80.000000,Max=80.000000)
         SpinsPerSecondRange=(X=(Min=0.250000,Max=0.250000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=8.000000)
         StartSizeRange=(X=(Min=2.000000,Max=2.000000))
         Texture=Texture'AW-2004Particles.Weapons.PlasmaStar'
         LifetimeRange=(Min=0.700000,Max=0.700000)
         StartVelocityRadialRange=(Min=120.000000,Max=120.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(0)=SpriteEmitter'XEffects.PlayerSpawnEffect.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ResetOnTrigger=True
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=64,G=255,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=3
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=6.000000)
         StartSizeRange=(X=(Min=7.000000,Max=7.000000))
         InitialParticlesPerSecond=12.000000
         Texture=Texture'AW-2004Particles.Fire.BlastMark'
         LifetimeRange=(Min=0.500000,Max=0.500000)
         InitialDelayRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(1)=SpriteEmitter'XEffects.PlayerSpawnEffect.SpriteEmitter1'

     AutoDestroy=True
     CullDistance=6500.000000
     bNoDelete=False
     bNetTemporary=True
     RemoteRole=ROLE_DumbProxy
}
