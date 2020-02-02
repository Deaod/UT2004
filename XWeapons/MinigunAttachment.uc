class MinigunAttachment extends xWeaponAttachment;

var class<Emitter>      mMuzFlashClass;
var Emitter             mMuzFlash3rd;

var class<Emitter>      mTracerClass;
var() editinline Emitter mTracer;
var float				mTracerInterval;
var() float             mTracerIntervalPrimary;
var() float             mTracerIntervalSecondary;
var() float				mTracerPullback;
var() float				mTracerMinDistance;
var() float				mTracerSpeed;
var float               mLastTracerTime;
var byte				OldSpawnHitCount;

var float               mCurrentRoll;
var float               mRollInc;
var float               mRollUpdateTime;

var class<xEmitter>     mShellCaseEmitterClass;
var xEmitter            mShellCaseEmitter;
var() vector            mShellEmitterOffset;

var vector	mOldHitLocation;

function Destroyed()
{
    if (mTracer != None)
        mTracer.Destroy();

    if (mMuzFlash3rd != None)
        mMuzFlash3rd.Destroy();

    if (mShellCaseEmitter != None)
        mShellCaseEmitter.Destroy();

	Super.Destroyed();
}

simulated function UpdateRoll(float dt)
{
    local rotator r;

    UpdateRollTime(false);

    if (mRollInc <= 0.f)
        return;

    mCurrentRoll += dt*mRollInc;
    mCurrentRoll = mCurrentRoll % 65536.f;
    r.Roll = int(mCurrentRoll);

    SetBoneRotation('Bone Barrels', r, 0, 1.f);
}

simulated function UpdateRollTime(bool bUpdate)
{
    local float diff;

    diff = Level.TimeSeconds - mRollUpdateTime;

    if (bUpdate)
        mRollUpdateTime = Level.TimeSeconds;

    // TODO: clean up!
    if (diff > 0.2)
    {
        mRollInc = 0.f;
    }
}

simulated function vector GetTracerStart()
{
    local Pawn p;

    p = Pawn(Owner);

    if ( (p != None) && p.IsFirstPerson() && p.Weapon != None )
    {
        // 1st person
        return p.Weapon.GetEffectStart();
    }

    // 3rd person
	if ( mMuzFlash3rd != None )
		return mMuzFlash3rd.Location;
	else
		return Location;
}

simulated function UpdateTracer()
{
    local vector SpawnLoc, SpawnDir, SpawnVel;
	local float hitDist;

    if (Level.NetMode == NM_DedicatedServer)
        return;

    if (mTracer == None)
    {
        mTracer = Spawn(mTracerClass);
        //AttachToBone(mTracer, 'tip');
    }

    if (mTracer != None && Level.TimeSeconds > mLastTracerTime + mTracerInterval)
    {
		SpawnLoc = GetTracerStart();
		mTracer.SetLocation(SpawnLoc);

		hitDist = VSize(mHitLocation - SpawnLoc) - mTracerPullback;

		// If we have a hit but the hit location has not changed
		if(mHitLocation == mOldHitLocation)
			SpawnDir = vector( Instigator.GetViewRotation() );
		else
			SpawnDir = Normal(mHitLocation - SpawnLoc);

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

        GotoState('TickTracer');
    }

	mOldHitLocation = mHitLocation;
}

/* UpdateHit
- used to update properties so hit effect can be spawn client side
*/
function UpdateHit(Actor HitActor, vector HitLocation, vector HitNormal)
{
    NetUpdateTime = Level.TimeSeconds - 1;
	SpawnHitCount++;
	mHitLocation = HitLocation;
	mHitActor = HitActor;
	mHitNormal = HitNormal;
}

simulated event ThirdPersonEffects()
{
	local PlayerController PC;
	
    if ( (Level.NetMode == NM_DedicatedServer) || (Instigator == None) )
		return; 

    if ( FlashCount > 0 )
	{
 		PC = Level.GetLocalPlayerController();
		if ( OldSpawnHitCount != SpawnHitCount )
		{
			OldSpawnHitCount = SpawnHitCount;
			GetHitInfo();
			PC = Level.GetLocalPlayerController();
			if ( (Instigator.Controller == PC) || (VSize(PC.ViewTarget.Location - mHitLocation) < 2000) )
			{
				if ( FiringMode == 0 )
					Spawn(class'HitEffect'.static.GetHitEffect(mHitActor, mHitLocation, mHitNormal),,, mHitLocation, Rotator(mHitNormal));
				else
					Spawn(class'XEffects.ExploWallHit',,, mHitLocation, Rotator(mHitNormal));
				CheckForSplash();
			}
		}
		if ( (Level.TimeSeconds - LastRenderTime > 0.2) && (Instigator.Controller != PC) )
			return;

	 	WeaponLight();

		if (FiringMode == 0)
        {
            mTracerInterval = mTracerIntervalPrimary;
            mRollInc = 65536.f*3.f;
        }
        else
        {
            mTracerInterval = mTracerIntervalSecondary;
            mRollInc = 65536.f;
        } 

		if ( Level.bDropDetail || Level.DetailMode == DM_Low )
			mTracerInterval *= 2.0;

        UpdateRollTime(true);
		
        UpdateTracer();

        if (mMuzFlash3rd == None)
        {
            mMuzFlash3rd = Spawn(mMuzFlashClass);
            AttachToBone(mMuzFlash3rd, 'tip');
        }
        if (mMuzFlash3rd != None)
        {
            mMuzFlash3rd.SpawnParticle(1);
        }

        if ( (mShellCaseEmitter == None) && (Level.DetailMode != DM_Low) && !Level.bDropDetail )
        {
            mShellCaseEmitter = Spawn(mShellCaseEmitterClass);
            if ( mShellCaseEmitter != None )
				AttachToBone(mShellCaseEmitter, 'shell');
        }
        if (mShellCaseEmitter != None)
            mShellCaseEmitter.mStartParticles++;
    }
    else
    {
        GotoState('');
    }

    Super.ThirdPersonEffects();
}

state TickTracer
{
    simulated function Tick(float deltaTime)
    {
        UpdateRoll(deltaTime);
    }
}

defaultproperties
{
     mMuzFlashClass=Class'XEffects.NewMinigunMFlash'
     mTracerClass=Class'XEffects.NewTracer'
     mTracerIntervalPrimary=0.120000
     mTracerIntervalSecondary=0.180000
     mTracerPullback=50.000000
     mTracerSpeed=10000.000000
     mShellCaseEmitterClass=Class'XEffects.ShellSpewer'
     bHeavy=True
     bRapidFire=True
     bAltRapidFire=True
     SplashEffect=Class'XGame.BulletSplash'
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=255.000000
     LightRadius=5.000000
     LightPeriod=3
     CullDistance=5000.000000
     Mesh=SkeletalMesh'Weapons.Minigun_3rd'
}
