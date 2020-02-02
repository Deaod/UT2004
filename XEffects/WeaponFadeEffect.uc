class WeaponFadeEffect extends Emitter;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	if ( Owner != None )
	{
		SetLocation(Owner.Location);
		SetRotation(Owner.Rotation);
		if ( Owner.StaticMesh != None )
		{
			MeshEmitter(Emitters[0]).StaticMesh = Owner.StaticMesh;
			MeshEmitter(Emitters[1]).StaticMesh = Owner.StaticMesh;
			MeshEmitter(Emitters[0]).SizeScale[0].RelativeSize = Owner.DrawScale;
			MeshEmitter(Emitters[0]).SizeScale[1].RelativeSize = Owner.DrawScale;
			MeshEmitter(Emitters[1]).SizeScale[0].RelativeSize = 1.02 * Owner.DrawScale;
			MeshEmitter(Emitters[1]).SizeScale[1].RelativeSize = 1.2 * Owner.DrawScale;
			if ( Owner.IsA('LinkGunPickup') || Owner.IsA('ONSAVRiLPickup') ) //this is indeed a beautiful hack
				Emitters[1].Disabled = true;
		}
	}
}

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter17
         StaticMesh=StaticMesh'WeaponStaticMesh.RocketLauncherPickup'
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ResetOnTrigger=True
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         SpinCCWorCW=(X=0.000000)
         SizeScale(0)=(RelativeSize=0.550000)
         SizeScale(1)=(RelativeTime=0.300000,RelativeSize=0.550000)
         SizeScale(2)=(RelativeTime=1.000000)
         InitialParticlesPerSecond=9999999.000000
         LifetimeRange=(Min=1.500000,Max=1.500000)
     End Object
     Emitters(0)=MeshEmitter'XEffects.WeaponFadeEffect.MeshEmitter17'

     Begin Object Class=MeshEmitter Name=MeshEmitter18
         StaticMesh=StaticMesh'WeaponStaticMesh.RocketLauncherPickup'
         UseMeshBlendMode=False
         UseParticleColor=True
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ResetOnTrigger=True
         ColorScale(1)=(RelativeTime=0.300000,Color=(B=64,G=255,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         Opacity=0.500000
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         DetailMode=DM_High
         SpinCCWorCW=(X=0.000000)
         SizeScale(0)=(RelativeSize=0.550000)
         SizeScale(1)=(RelativeTime=0.300000,RelativeSize=0.650000)
         SizeScale(2)=(RelativeTime=1.000000)
         InitialParticlesPerSecond=9999999.000000
         LifetimeRange=(Min=1.750000,Max=1.750000)
     End Object
     Emitters(1)=MeshEmitter'XEffects.WeaponFadeEffect.MeshEmitter18'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter44
         UseColorScale=True
         RespawnDeadParticles=False
         UseRevolution=True
         UseRevolutionScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ResetOnTrigger=True
         ColorScale(0)=(Color=(B=64,G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000)
         ColorMultiplierRange=(Y=(Min=0.700000))
         MaxParticles=40
         StartLocationShape=PTLS_Sphere
         RevolutionsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         RevolutionScale(1)=(RelativeTime=0.500000,RelativeRevolution=(X=0.200000,Y=0.200000,Z=0.200000))
         RevolutionScale(2)=(RelativeTime=1.000000,RelativeRevolution=(X=0.700000,Y=0.700000,Z=0.700000))
         SpinsPerSecondRange=(X=(Min=1.000000,Max=1.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=4.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=2.000000,Max=2.000000))
         Texture=Texture'AW-2004Particles.Weapons.PlasmaStar'
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Max=40.000000))
         VelocityLossRange=(X=(Min=-1.000000,Max=-1.000000),Y=(Min=-1.000000,Max=-1.000000),Z=(Min=-1.000000,Max=-1.000000))
     End Object
     Emitters(2)=SpriteEmitter'XEffects.WeaponFadeEffect.SpriteEmitter44'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter54
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ResetOnTrigger=True
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=64,G=255,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=3
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=4.000000)
         StartSizeRange=(X=(Min=7.000000,Max=7.000000))
         InitialParticlesPerSecond=5.000000
         Texture=Texture'AW-2004Particles.Fire.BlastMark'
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(3)=SpriteEmitter'XEffects.WeaponFadeEffect.SpriteEmitter54'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter55
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=64,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.187500,Color=(B=64,G=255,R=255))
         ColorScale(2)=(RelativeTime=0.375000,Color=(B=255,G=255,R=255))
         ColorScale(3)=(RelativeTime=0.687500,Color=(B=64,G=255,R=255))
         ColorScale(4)=(RelativeTime=1.000000)
         Opacity=0.750000
         MaxParticles=1
         SizeScale(1)=(RelativeTime=0.375000,RelativeSize=0.250000)
         SizeScale(2)=(RelativeTime=1.000000)
         InitialParticlesPerSecond=99999.000000
         Texture=Texture'EpicParticles.Flares.BurnFlare1'
         LifetimeRange=(Min=0.750000,Max=0.750000)
         InitialDelayRange=(Min=1.000000,Max=1.000000)
         WarmupTicksPerSecond=1.000000
         RelativeWarmupTime=1.000000
     End Object
     Emitters(4)=SpriteEmitter'XEffects.WeaponFadeEffect.SpriteEmitter55'

     AutoDestroy=True
     bNoDelete=False
}
