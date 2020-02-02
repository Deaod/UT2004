class ONSTankSecondaryTurret extends ONSWeapon;

var class<Emitter>      mTracerClass;
var() editinline Emitter mTracer;
var() float				mTracerInterval;
var() float				mTracerPullback;
var() float				mTracerMinDistance;
var() float				mTracerSpeed;
var float               mLastTracerTime;

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Material'VMparticleTextures.TankFiringP.CloudParticleOrangeBMPtex');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TracerShot');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'VMparticleTextures.TankFiringP.CloudParticleOrangeBMPtex');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TracerShot');

    Super.UpdatePrecacheMaterials();
}

function byte BestMode()
{
	return 0;
}

simulated function Destroyed()
{
	if (mTracer != None)
		mTracer.Destroy();

	Super.Destroyed();
}

simulated function UpdateTracer()
{
	local vector SpawnDir, SpawnVel;
	local float hitDist;

	if (Level.NetMode == NM_DedicatedServer)
		return;

	if (mTracer == None)
	{
		mTracer = Spawn(mTracerClass);
	}

	if (Level.bDropDetail || Level.DetailMode == DM_Low)
		mTracerInterval = 2 * Default.mTracerInterval;
	else
		mTracerInterval = Default.mTracerInterval;

	if (mTracer != None && Level.TimeSeconds > mLastTracerTime + mTracerInterval)
	{
	        mTracer.SetLocation(WeaponFireLocation);

		hitDist = VSize(LastHitLocation - WeaponFireLocation) - mTracerPullback;

		if (Instigator != None && Instigator.IsLocallyControlled())
			SpawnDir = vector(WeaponFireRotation);
		else
			SpawnDir = Normal(LastHitLocation - WeaponFireLocation);

		if(hitDist > mTracerMinDistance)
		{
			SpawnVel = SpawnDir * mTracerSpeed;

			mTracer.Emitters[0].StartVelocityRange.X.Min = SpawnVel.X;
			mTracer.Emitters[0].StartVelocityRange.X.Max = SpawnVel.X;
			mTracer.Emitters[0].StartVelocityRange.Y.Min = SpawnVel.Y;
			mTracer.Emitters[0].StartVelocityRange.Y.Max = SpawnVel.Y;
			mTracer.Emitters[0].StartVelocityRange.Z.Min = SpawnVel.Z;
			mTracer.Emitters[0].StartVelocityRange.Z.Max = SpawnVel.Z;

			mTracer.Emitters[0].LifetimeRange.Min = hitDist / mTracerSpeed;
			mTracer.Emitters[0].LifetimeRange.Max = mTracer.Emitters[0].LifetimeRange.Min;

			mTracer.SpawnParticle(1);
		}

		mLastTracerTime = Level.TimeSeconds;
	}
}

simulated function FlashMuzzleFlash()
{
	Super.FlashMuzzleFlash();

	if (Role < ROLE_Authority)
		DualFireOffset *= -1;

	UpdateTracer();
}

defaultproperties
{
     mTracerClass=Class'XEffects.NewTracer'
     mTracerInterval=0.060000
     mTracerPullback=150.000000
     mTracerSpeed=15000.000000
     YawBone="Object01"
     PitchBone="Object02"
     PitchUpLimit=12500
     PitchDownLimit=59500
     WeaponFireAttachmentBone="Object02"
     WeaponFireOffset=85.000000
     DualFireOffset=5.000000
     RotationsPerSecond=2.000000
     bInstantRotation=True
     bInstantFire=True
     bDoOffsetTrace=True
     bAmbientFireSound=True
     bIsRepeatingFF=True
     Spread=0.010000
     RedSkin=Shader'VMVehicles-TX.HoverTankGroup.HoverTankChassisFinalRED'
     BlueSkin=Shader'VMVehicles-TX.HoverTankGroup.HoverTankChassisFinalBLUE'
     FireInterval=0.100000
     AmbientEffectEmitterClass=Class'Onslaught.ONSRVChainGunFireEffect'
     FireSoundClass=Sound'ONSVehicleSounds-S.Tank.TankMachineGun01'
     AmbientSoundScaling=1.300000
     FireForce="minifireb"
     DamageType=Class'Onslaught.DamTypeONSChainGun'
     DamageMin=17
     DamageMax=17
     TraceRange=15000.000000
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=50.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=1.000000,Y=1.000000,Z=1.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=2.000000
     AIInfo(0)=(bInstantHit=True,aimerror=750.000000)
     CullDistance=8000.000000
     Mesh=SkeletalMesh'ONSWeapons-A.TankMachineGun'
}
