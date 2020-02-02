//=============================================================================
// WA_Turret_Minigun
// Inpired from the original UT2003 minigun weapon...
//=============================================================================

class WA_Turret_Minigun extends xWeaponAttachment;


#exec OBJ LOAD FILE=..\StaticMeshes\AS_Weapons_SM.usx
#exec OBJ LOAD FILE=..\Textures\VMParticleTextures.utx


var	int		CurrentCannonRoll;
var int		CannonRollSpeed, CurrentRollSpeed, RollSpeedAcc;
var bool	bFiring;

// Shell case
var class<xEmitter>     mShellCaseEmitterClass;
var xEmitter            mShellCaseEmitter;
var() vector            mShellEmitterOffset;

// Muzzle flash
var class<MinigunMuzFlash3rd>		mMuzFlashClass;
var xEmitter						mMuzFlash3rd;

// Tracer FX
var class<Emitter>      mTracerClass;
var() editinline Emitter mTracer;
var() float				mTracerInterval;
var() float				mTracerPullback;
var() float				mTracerMinDistance;
var() float				mTracerSpeed;
var float               mLastTracerTime;

var float				Spread;

// Smoke
var() class<xEmitter>	SmokeEmitterClass;
var() xEmitter			SmokeEmitter;

var Sound		FiringSound, WindingSound;

var byte	OldSpawnHitCount;
var vector	mOldHitLocation;
var float	LastFireTime;


simulated function PostBeginPlay()
{
	local Rotator	R;

	super.PostBeginPlay();

	 R					= GetBoneRotation( 'CannonBone' );
	 CurrentCannonRoll	= R.Yaw;
}

simulated function Destroyed()
{
	StopFiring();

    if ( mMuzFlash3rd != None )
        mMuzFlash3rd.Destroy();

    if ( mShellCaseEmitter != None )
        mShellCaseEmitter.Destroy();

	if ( SmokeEmitter != None )
        SmokeEmitter.Destroy();

	super.Destroyed();
}

simulated event ThirdPersonEffects()
{
	local rotator	R;
	local PlayerController PC;

    if ( (Level.NetMode == NM_DedicatedServer) || (Instigator == None) )
        return;

    if ( FlashCount > 0 )
	{
		LastFireTime = Level.TimeSeconds;

		if ( !bFiring || (GetStateName() != 'Firing') )
			StartFiring();

		// Muzzle Flash spawning
		if ( mMuzFlash3rd == None )
        {
            mMuzFlash3rd = Spawn( mMuzFlashClass,,, ASVehicle(Instigator).GetFireStart(), Instigator.Rotation );
			if ( mMuzFlash3rd != None )
			{
				mMuzFlash3rd.bHardAttach = true;
				mMuzFlash3rd.SetBase( Instigator );

				mMuzFlash3rd.mMeshNodes[0]	= StaticMesh'AS_Weapons_SM.MuzzleFlash.ASMinigun_Muzzle';
				mMuzFlash3rd.Skins[0]		= Shader'VMParticleTextures.TankFiringP.tankMuzzleSHAD';
				mMuzFlash3rd.mSizeRange[0]	= 0.3;
				mMuzFlash3rd.mSizeRange[1]	= 0.4;

				// Setting dynamic light effect on muzzle flash...
				mMuzFlash3rd.bDynamicLight		= false;
				mMuzFlash3rd.LightType			= LT_Pulse;
				mMuzFlash3rd.LightEffect		= LE_NonIncidence;
				mMuzFlash3rd.LightPeriod		= 3;
				mMuzFlash3rd.LightBrightness	= 150;
				mMuzFlash3rd.LightHue			= 30;
				mMuzFlash3rd.LightSaturation	= 150;
				mMuzFlash3rd.LightRadius		= 8.0;
			}
        }
		else
		{	// Update location/rotation
			mMuzFlash3rd.SetBase( None );
			mMuzFlash3rd.SetLocation( ASVehicle(Instigator).GetFireStart() );
			mMuzFlash3rd.SetRotation( Instigator.Rotation );
			mMuzFlash3rd.SetBase( Instigator );
		}

		// Muzzle flash update
        if ( mMuzFlash3rd != None )
        {
            mMuzFlash3rd.Trigger(Self, None);
            R.Roll = Rand(16384);
			mMuzFlash3rd.SetRelativeRotation( R );
			
			// Dynamic Light
			mMuzFlash3rd.bDynamicLight = true;
			SetTimer(0.14, false);
        }

		// Shell Case spawning
		if ( Level.DetailMode != DM_Low )
		{
			if ( mShellCaseEmitter == None )
			{
				mShellCaseEmitter = Spawn( mShellCaseEmitterClass,,, GetFireStart( mShellEmitterOffset ), Instigator.Rotation );
				if ( mShellCaseEmitter != None )
				{
					mShellCaseEmitter.bHardAttach	= true;
					mShellCaseEmitter.SetBase( Instigator );
					mShellCaseEmitter.SetRelativeRotation( Rot(0,-16384,0) );
				}
			}
			else
			{	// Update location/rotation
				mShellCaseEmitter.SetBase( None );
				mShellCaseEmitter.SetLocation( GetFireStart( mShellEmitterOffset ) );
				mShellCaseEmitter.SetRotation( Instigator.Rotation );
				mShellCaseEmitter.SetBase( Instigator );
				mShellCaseEmitter.SetRelativeRotation( Rot(0,-16384,0) );
			}

			// Shellcase update
			if ( mShellCaseEmitter != None )
				mShellCaseEmitter.mStartParticles++;
		}

		// Impact effect
		if ( OldSpawnHitCount != SpawnHitCount )
		{
			OldSpawnHitCount = SpawnHitCount;
			GetHitInfo();
		
			PC = Level.GetLocalPlayerController();
			if ( (Instigator.Controller == PC) || (VSize(PC.ViewTarget.Location - mHitLocation) < 5000) )
				Spawn(class'HitEffect'.static.GetHitEffect(mHitActor, mHitLocation, mHitNormal),,, mHitLocation, Rotator(mHitNormal));
		}

		// Tracer FX
		UpdateTracer();
	}
	else 
		StopFiring();

	super.ThirdPersonEffects();
}

/*
Firing state:
Updates cannon rotation
*/
state Firing
{
    simulated function Tick(float deltaTime)
    {
		local rotator	R;

		if ( Instigator == None )
			return;

		if ( bFiring && (Level.TimeSeconds - LastFireTime > 0.5) )
			StopFiring();

		if ( bFiring )
		{ 
			// Increase rotation rate...
			if ( CurrentRollSpeed < CannonRollSpeed )
				CurrentRollSpeed += RollSpeedAcc * 4.f * deltaTime;	// faster acceleration when shooting
			else if ( CurrentRollSpeed > CannonRollSpeed )
				CurrentRollSpeed = CannonRollSpeed;
		}
		else
		{	
			// decrease rotation rate...
			if ( CurrentRollSpeed > 0 )
				CurrentRollSpeed -= RollSpeedAcc * deltaTime;
			
			// If rotation rate is null, exit state..
			if ( CurrentRollSpeed < 0 )
			{
				CurrentRollSpeed = 0;
				GotoState('');
			}
		}

		// Rotating cannon
		CurrentCannonRoll = (CurrentCannonRoll + CurrentRollSpeed * deltatime) % 65536;
		R.Roll = CurrentCannonRoll;
		Instigator.SetBoneRotation('CannonBone', R, 0, 1.f);
    }

}

simulated function Timer()
{
	// Shut down dynamic light
	if ( mMuzFlash3rd != None )
		mMuzFlash3rd.bDynamicLight = false;
}

simulated Event StartFiring()
{
	bFiring	= true;
	
	if ( Instigator != None )
		Instigator.AmbientSound	= FiringSound;

	GotoState('Firing');
}

simulated Event StopFiring()
{
	if ( !bFiring )
		return;

	bFiring	= false;

	if ( Instigator != None )
	{
		Instigator.AmbientSound	= None;
		Instigator.PlaySound( WindingSound,, 4.f,, Instigator.SoundRadius, 0.75 );

		if ( !Level.bDropDetail && Level.DetailMode != DM_Low )
		{
			if ( SmokeEmitter == None )
			{
				SmokeEmitter = Spawn( SmokeEmitterClass,,, ASVehicle(Instigator).GetFireStart(), Instigator.Rotation );

				if ( SmokeEmitter != None )
				{
					SmokeEmitter.bOnlyOwnerSee = false;
					SmokeEmitter.bHidden = false;
					SmokeEmitter.bHardAttach = true;
					SmokeEmitter.SetBase( Instigator );
				}
			}
			else
			{	// Update location/rotation
				SmokeEmitter.SetBase( None );
				SmokeEmitter.SetLocation( ASVehicle(Instigator).GetFireStart() );
				SmokeEmitter.SetRotation( Instigator.Rotation );
				SmokeEmitter.SetBase( Instigator );
			}

			if ( SmokeEmitter != None )
				SmokeEmitter.Trigger( Self, Instigator );
		}
	}
}

/* UpdateHit
- used to update properties so hit effect can be spawn client side
*/
function UpdateHit(Actor HitActor, vector HitLocation, vector HitNormal)
{
	SpawnHitCount++;
	mHitLocation	= HitLocation;
	mHitActor		= HitActor;
	mHitNormal		= HitNormal;
}

simulated function UpdateTracer()
{
    local float		hitDist;
	//local rotator	RelRot;
	local vector	SpawnLoc, SpawnDir, SpawnVel;

    if ( Level.NetMode == NM_DedicatedServer )
        return;

	// Spawn Tracer effect
    if ( mTracer == None )
    {
        mTracer = Spawn( mTracerClass,,, ASVehicle(Instigator).GetFireStart(), Instigator.Rotation );
    }

	if ( Level.bDropDetail || Level.DetailMode == DM_Low )
		mTracerInterval = 2 * default.mTracerInterval;
	else
		mTracerInterval = default.mTracerInterval;

    if ( mTracer != None && Level.TimeSeconds >= mLastTracerTime + mTracerInterval)
    {
		SpawnLoc = ASVehicle(Instigator).GetFireStart();
		mTracer.SetLocation( SpawnLoc );

		hitDist = VSize( mHitLocation - SpawnLoc ) - mTracerPullback;
				
		// If the hit location is exactly the same as last time, we assume it isn't correct so we just use the gun rotation instead.
		if ( mHitLocation == mOldHitLocation )
			SpawnDir = vector( Instigator.Rotation ) + VRand()*FRand()*class'FM_Turret_Minigun_Fire'.default.Spread ;
		else
			SpawnDir = Normal( mHitLocation - SpawnLoc );

		mOldHitLocation = mHitLocation;

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

simulated function vector GetFireStart( vector RelOffset )
{
	local vector	X, Y, Z;

	GetViewAxes(X, Y, Z);
    return Instigator.Location + X*RelOffset.X + Y*RelOffset.Y + Z*RelOffset.Z;
}

simulated function GetViewAxes( out vector xaxis, out vector yaxis, out vector zaxis )
{
	GetAxes( Instigator.Rotation, xaxis, yaxis, zaxis );
}


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     CannonRollSpeed=196608
     RollSpeedAcc=98304
     mShellCaseEmitterClass=Class'UT2k4Assault.FX_Minigun_ShellSpewer'
     mShellEmitterOffset=(X=28.000000,Y=-40.000000,Z=62.000000)
     mMuzFlashClass=Class'XEffects.MinigunMuzFlash3rd'
     mTracerClass=Class'XEffects.NewTracer'
     mTracerInterval=0.060000
     mTracerPullback=150.000000
     mTracerSpeed=10000.000000
     Spread=1024.000000
     SmokeEmitterClass=Class'XEffects.MinigunMuzzleSmoke'
     FiringSound=Sound'NewWeaponSounds.MiniGunTurretFire'
     WindingSound=Sound'NewWeaponSounds.MiniGunTurretWindDown'
     bHeavy=True
     bRapidFire=True
     bAltRapidFire=True
     bHidden=True
}
