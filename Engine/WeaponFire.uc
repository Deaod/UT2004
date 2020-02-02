class WeaponFire extends Object
    native;

var() bool bSplashDamage;
var() bool bSplashJump;
var() bool bRecommendSplashDamage;
var() bool bTossed;
var() bool bLeadTarget;
var() bool bInstantHit;

// other useful stuff //
var() bool  bPawnRapidFireAnim; // for determining what anim the firer should play
var() bool  bReflective;
var bool bTimerLoop;
var() bool  bFireOnRelease;    // if true, shot will be fired when button is released, HoldTime will be the time the button was held for
var() bool  bWaitForRelease;   // if true, fire button must be released between each shot
var() bool  bModeExclusive;    // if true, no other fire modes can be active at the same time as this one

var   bool  bIsFiring;
var   bool  bNowWaiting;
var   bool  bServerDelayStopFire;
var   bool  bServerDelayStartFire;
var	  bool	bInstantStop;

// muzzle flash & smoke //
var() bool bAttachSmokeEmitter;
var() bool bAttachFlashEmitter;

// timer
var float TimerInterval;
var float NextTimerPop;

var() Weapon Weapon;
var pawn Instigator;
var LevelInfo Level;
var Actor Owner;

var   float NextFireTime;
var() float PreFireTime;       // seconds before first shot
var() float MaxHoldTime;
var() float HoldTime;

var() int ThisModeNum;
var float TransientSoundVolume;
var float TransientSoundRadius;

// animation //
var() Name PreFireAnim;
var() Name FireAnim;
var() Name FireLoopAnim;
var() Name FireEndAnim;
var() Name ReloadAnim;

var() float PreFireAnimRate;
var() float FireAnimRate;
var() float FireLoopAnimRate;
var() float FireEndAnimRate;
var() float ReloadAnimRate;
var() float TweenTime;

// sound //
var() Sound FireSound;
var() Sound ReloadSound;
var() Sound NoAmmoSound;

// jdf ---
// Force Feedback //
var() String FireForce;
var() String ReloadForce;
var() String NoAmmoForce;
// --- jdf

// timing //
var() float FireRate;          // seconds between shots
var   float ServerStartFireTime;

// ammo //
var() class<Ammunition> AmmoClass;
var() int AmmoPerFire;
var() int AmmoClipSize;
var() float Load;

// camera shakes //
var() vector ShakeRotMag;           // how far to rot view
var() vector ShakeRotRate;          // how fast to rot view
var() float  ShakeRotTime;          // how much time to rot the instigator's view
var() vector ShakeOffsetMag;        // max view offset vertically
var() vector ShakeOffsetRate;       // how fast to offset view vertically
var() float  ShakeOffsetTime;       // how much time to offset view

// AI //
var() class<Projectile> ProjectileClass;
var() float BotRefireRate;
var() float WarnTargetPct;

var() class<xEmitter> FlashEmitterClass;
var() xEmitter FlashEmitter;
var() class<xEmitter> SmokeEmitterClass;
var() xEmitter SmokeEmitter;


var() float AimError; // 0=none 1000=quite a bit
var() float Spread; // rotator units. no relation to AimError
var() enum ESpreadStyle
{
    SS_None,
    SS_Random, // spread is max random angle deviation
    SS_Line,   // spread is angle between each projectile
    SS_Ring
} SpreadStyle;

var int FireCount;
var() float DamageAtten; // attenuate instant-hit/projectile damage by this multiplier

var Actor.FireProperties SavedFireProperties;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

simulated function SetTimer( float NewTimerRate, bool bLoop )
{
	bTimerLoop = bLoop;
	TimerInterval = NewTimerRate;
	NextTimerPop = Level.TimeSeconds + TimerInterval;
}

event Timer();

simulated function PreBeginPlay();
simulated function BeginPlay();
simulated function PostNetBeginPlay();

simulated event SetInitialState()
{
	GotoState( 'Auto' );
}

simulated function PostBeginPlay()
{
    Load = AmmoPerFire;

    if (bFireOnRelease)
        bWaitForRelease = true;

    if (bWaitForRelease)
        bNowWaiting = true;
}

simulated function DestroyEffects()
{
    if (FlashEmitter != None)
        FlashEmitter.Destroy();

    if (SmokeEmitter != None)
        SmokeEmitter.Destroy();
}

simulated function InitEffects()
{
    // don't even spawn on server
    if ( (Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
		return;
    if ( (FlashEmitterClass != None) && ((FlashEmitter == None) || FlashEmitter.bDeleteMe) )
    {
        FlashEmitter = Weapon.Spawn(FlashEmitterClass);
    }
    if ( (SmokeEmitterClass != None) && ((SmokeEmitter == None) || SmokeEmitter.bDeleteMe) )
    {
        SmokeEmitter = Weapon.Spawn(SmokeEmitterClass);
    }
}

function DoFireEffect()
{
}

function DrawMuzzleFlash(Canvas Canvas)
{
    // Draw smoke first
    if (SmokeEmitter != None && SmokeEmitter.Base != Weapon)
    {
        SmokeEmitter.SetLocation( Weapon.GetEffectStart() );
        Canvas.DrawActor( SmokeEmitter, false, false, Weapon.DisplayFOV );
    }

    if (FlashEmitter != None && FlashEmitter.Base != Weapon)
    {
        FlashEmitter.SetLocation( Weapon.GetEffectStart() );
        Canvas.DrawActor( FlashEmitter, false, false, Weapon.DisplayFOV );
    }
}

function FlashMuzzleFlash()
{
    if (FlashEmitter != None)
        FlashEmitter.Trigger(Weapon, Instigator);
}

function StartMuzzleSmoke()
{
    if ( !Level.bDropDetail && (SmokeEmitter != None) )
        SmokeEmitter.Trigger(Weapon, Instigator);
}

function ShakeView()
{
    local PlayerController P;

    P = PlayerController(Instigator.Controller);
    if ( P != None )
        P.WeaponShakeView(ShakeRotMag, ShakeRotRate, ShakeRotTime,
                    ShakeOffsetMag, ShakeOffsetRate, ShakeOffsetTime);
}

// jdf ---
function ClientPlayForceFeedback( String EffectName )
{
    local PlayerController PC;

    PC = PlayerController(Instigator.Controller);
    if (PC != None && PC.bEnableWeaponForceFeedback )
    {
        PC.ClientPlayForceFeedback(EffectName);
    }
}

function StopForceFeedback( String EffectName )
{
    local PlayerController PC;

    PC = PlayerController(Instigator.Controller);
    if (PC != None && PC.bEnableWeaponForceFeedback )
		PC.StopForceFeedback(EffectName);
}
// --- jdf

function Update(float dt)
{
}

function StartFiring()
{
}

function StopFiring()
{
}

function StartBerserk()
{
    FireRate = default.FireRate * 0.75;
    FireAnimRate = default.FireAnimRate/0.75;
    ReloadAnimRate = default.ReloadAnimRate/0.75;
}

function StopBerserk()
{
    FireRate = default.FireRate;
    FireAnimRate = default.FireAnimRate;
    ReloadAnimRate = default.ReloadAnimRate;
}

function StartSuperBerserk()
{
    FireRate = default.FireRate/Level.GRI.WeaponBerserk;
    FireAnimRate = default.FireAnimRate * Level.GRI.WeaponBerserk;
    ReloadAnimRate = default.ReloadAnimRate * Level.GRI.WeaponBerserk;
}

function bool IsFiring()
{
	return bIsFiring;
}

event ModeTick(float dt);

event ModeDoFire()
{
    if (!AllowFire())
        return;

    if (MaxHoldTime > 0.0)
        HoldTime = FMin(HoldTime, MaxHoldTime);

    // server
    if (Weapon.Role == ROLE_Authority)
    {
        Weapon.ConsumeAmmo(ThisModeNum, Load);
        DoFireEffect();
		HoldTime = 0;	// if bot decides to stop firing, HoldTime must be reset first
        if ( (Instigator == None) || (Instigator.Controller == None) )
			return;

        if ( AIController(Instigator.Controller) != None )
            AIController(Instigator.Controller).WeaponFireAgain(BotRefireRate, true);

        Instigator.DeactivateSpawnProtection();
    }

    // client
    if (Instigator.IsLocallyControlled())
    {
        ShakeView();
        PlayFiring();
        FlashMuzzleFlash();
        StartMuzzleSmoke();
    }
    else // server
    {
        ServerPlayFiring();
    }

    Weapon.IncrementFlashCount(ThisModeNum);

    // set the next firing time. must be careful here so client and server do not get out of sync
    if (bFireOnRelease)
    {
        if (bIsFiring)
            NextFireTime += MaxHoldTime + FireRate;
        else
            NextFireTime = Level.TimeSeconds + FireRate;
    }
    else
    {
        NextFireTime += FireRate;
        NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
    }

    Load = AmmoPerFire;
    HoldTime = 0;

    if (Instigator.PendingWeapon != Weapon && Instigator.PendingWeapon != None)
    {
        bIsFiring = false;
        Weapon.PutDown();
    }
}

event ModeHoldFire()
{
    if (Instigator.IsLocallyControlled())
        PlayStartHold();
}


simulated function bool AllowFire()
{
    return ( Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire);
}

//// server propagation of firing ////
function ServerPlayFiring()
{
    Weapon.PlayOwnedSound(FireSound,SLOT_Interact,TransientSoundVolume,,TransientSoundRadius,,false);
}


//// client animation ////

function PlayPreFire()
{
    if ( Weapon.Mesh != None && Weapon.HasAnim(PreFireAnim) )
    {
        Weapon.PlayAnim(PreFireAnim, PreFireAnimRate, TweenTime);
    }
}

function PlayStartHold()
{
}

function PlayFiring()
{
	if ( Weapon.Mesh != None )
	{
		if ( FireCount > 0 )
		{
			if ( Weapon.HasAnim(FireLoopAnim) )
			{
				Weapon.PlayAnim(FireLoopAnim, FireLoopAnimRate, 0.0);
			}
			else
			{
				Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
			}
		}
		else
		{
			Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
		}
	}
    Weapon.PlayOwnedSound(FireSound,SLOT_Interact,TransientSoundVolume,,TransientSoundRadius,Default.FireAnimRate/FireAnimRate,false);
    ClientPlayForceFeedback(FireForce);  // jdf

    FireCount++;
}

function PlayFireEnd()
{
    if ( Weapon.Mesh != None && Weapon.HasAnim(FireEndAnim) )
    {
        Weapon.PlayAnim(FireEndAnim, FireEndAnimRate, TweenTime);
    }
}

function Rotator AdjustAim(Vector Start, float InAimError)
{
	if ( !SavedFireProperties.bInitialized )
	{
		SavedFireProperties.AmmoClass = AmmoClass;
		SavedFireProperties.ProjectileClass = ProjectileClass;
		SavedFireProperties.WarnTargetPct = WarnTargetPct;
		SavedFireProperties.MaxRange = MaxRange();
		SavedFireProperties.bTossed = bTossed;
		SavedFireProperties.bTrySplash = bRecommendSplashDamage;
		SavedFireProperties.bLeadTarget = bLeadTarget;
		SavedFireProperties.bInstantHit = bInstantHit;
		SavedFireProperties.bInitialized = true;
	}
    return Instigator.AdjustAim(SavedFireProperties, Start, InAimError);
}

simulated function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Instigator.Location + Instigator.EyePosition();
}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
    Canvas.SetDrawColor(0,255,0);
    Canvas.DrawText("  FIREMODE "$self$" IsFiring "$bIsFiring);
    YPos += YL;
    Canvas.SetPos(4,YPos);
/*
    Canvas.DrawText("  FireOnRelease "$bFireOnRelease$" HoldTime "$HoldTime$" MaxHoldTime "$MaxHoldTime);
    YPos += YL;
    Canvas.SetPos(4,YPos);

    Canvas.DrawText("  NextFireTime "$NextFireTime$" NowWaiting "$bNowWaiting);
    YPos += YL;
    Canvas.SetPos(4,YPos);
*/
}

function float MaxRange()
{
	return 5000;
}

// for convenience/ backwards compatibility
function actor Spawn
(
	class<actor>      SpawnClass,
	optional actor	  SpawnOwner,
	optional name     SpawnTag,
	optional vector   SpawnLocation,
	optional rotator  SpawnRotation
)
{
	return Weapon.Spawn(SpawnClass,SpawnOwner,SpawnTag,SpawnLocation,SpawnRotation);
}

function Actor Trace
(
	out vector      HitLocation,
	out vector      HitNormal,
	vector          TraceEnd,
	optional vector TraceStart,
	optional bool   bTraceActors,
	optional vector Extent,
	optional out material Material
)
{
	return Weapon.Trace(HitLocation,HitNormal,TraceEnd,TraceStart,bTraceActors,Extent,Material);
}

defaultproperties
{
     bInstantHit=True
     bModeExclusive=True
     TransientSoundVolume=0.500000
     TransientSoundRadius=400.000000
     PreFireAnim="PreFire"
     FireAnim="Fire"
     FireLoopAnim="FireLoop"
     FireEndAnim="FireEnd"
     ReloadAnim="Reload"
     PreFireAnimRate=1.000000
     FireAnimRate=1.000000
     FireLoopAnimRate=1.000000
     FireEndAnimRate=1.000000
     ReloadAnimRate=1.000000
     TweenTime=0.100000
     FireRate=0.500000
     BotRefireRate=0.950000
     aimerror=600.000000
     DamageAtten=1.000000
}
