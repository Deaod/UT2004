//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSWeapon extends Actor
    native
    nativereplication
    abstract;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

// Weapon Bone Rotation System
var()   name                                YawBone;
var()   float                               YawStartConstraint;
var()   float                               YawEndConstraint;
var     float                               YawConstraintDelta;
var()   name                                PitchBone;
var()   int                                 PitchUpLimit;
var()   int                                 PitchDownLimit;
var     rotator                             CurrentAim;
var     vector                              WeaponFireLocation;
var     rotator                             WeaponFireRotation;

var()   name                                WeaponFireAttachmentBone;
var()   name                                GunnerAttachmentBone;
var()   float                               WeaponFireOffset;
var()   float                               DualFireOffset;
var     vector                              WeaponOffset;

var     rotator         LastRotation;
var     float           RotationsPerSecond;

// Bools
var	    bool	bInstantRotation; //NOTE: Gradual rotation via RotationsPerSecond still used for non-owning net clients to smooth rotation changes
var     bool    bActive;
var()   bool    bInstantFire;
var()   bool    bDualIndependantTargeting;  // When using a DualFireOffset each shot will be independantly targeted at the crosshair
var     bool    bShowChargingBar;
var     bool    bCallInstigatorPostRender; //if Instigator exists, during this actor's native PostRender(), call Instigator->PostRender() (used when weapon is visible but owner is bHidden)
var     bool    bForceCenterAim;
var()   bool    bAimable;
var	    bool    bDoOffsetTrace; //trace from outside vehicle's collision back towards weapon to determine firing offset
var()   bool    bAmbientFireSound;
var()   bool    bAmbientAltFireSound;
var()   bool    bInheritVelocity;
var		bool	bIsAltFire;
var		bool	bIsRepeatingFF;
var()   bool    bReflective;
var()   bool    bShowAimCrosshair; // Show the crosshair that indicates whether aim is good or not
var	const bool	bCorrectAim;	// output variable - set natively - means gun can hit what controller is aiming at

// Aiming
var()	float	FireIntervalAimLock; //fraction of FireInterval/AltFireInterval during which you can't move the gun
var	float		AimLockReleaseTime; //when this time is reached gun can move again
var vector      CurrentHitLocation;
var float		Spread;
var float       AimTraceRange;

// Impact/Damage
var     vector                              LastHitLocation; // Location of the last hit effect
var     byte                                FlashCount;      // Incremented each frame of firing
var     byte                                OldFlashCount;   // Stores the last FlashCount received
var     byte                                HitCount;        // Incremented each time a hit effect occurs
var     byte                                OldHitCount;     // Stores the last HitCount received

// Team Skins //
var	byte Team;
var()   Material    RedSkin;
var()   Material    BlueSkin;

// Timing
var()   float           FireInterval, AltFireInterval;
var     float           FireCountdown;

// Effects
var()   class<Emitter>					FlashEmitterClass;
var     Emitter							FlashEmitter;
var()   class<Emitter>					EffectEmitterClass;
var     Emitter							EffectEmitter;
var()   class<ONSWeaponAmbientEmitter>  AmbientEffectEmitterClass;
var     ONSWeaponAmbientEmitter			AmbientEffectEmitter;

// Sound
var()   sound           FireSoundClass;
var()   float           FireSoundVolume;
var()   float           FireSoundRadius;
var()	float           FireSoundPitch;
var()   sound           AltFireSoundClass;
var()   float           AltFireSoundVolume;
var()   float           AltFireSoundRadius;
var()   sound           RotateSound;
var		float			RotateSoundThreshold;		// threshold in rotator units for RotateSound to play
var()   float           AmbientSoundScaling;

// Force Feedback //
var()	string			FireForce;
var()	string			AltFireForce;

// Instant Fire Stuff
var class<DamageType>   DamageType;
var int                 DamageMin, DamageMax;
var float               TraceRange;
var float               Momentum;

// Projectile Fire Stuff
var()   class<Projectile>   ProjectileClass;
var()   class<Projectile>   AltFireProjectileClass;
var	array<Projectile> Projectiles; //ignore these when doing third person aiming trace (only necessary if projectiles fired have bProjTarget==true)

// camera shakes //
var() vector            ShakeRotMag;           // how far to rot view
var() vector            ShakeRotRate;          // how fast to rot view
var() float             ShakeRotTime;          // how much time to rot the instigator's view
var() vector            ShakeOffsetMag;        // max view offset vertically
var() vector            ShakeOffsetRate;       // how fast to offset view vertically
var() float             ShakeOffsetTime;       // how much time to offset view

// AI
struct native ONSWeaponAIInfo
{
	var bool bTossed, bTrySplash, bLeadTarget, bInstantHit, bFireOnRelease;
	var float AimError, WarnTargetPct, RefireRate;
};
var ONSWeaponAIInfo AIInfo[2];
var FireProperties SavedFireProperties[2];

//// DEBUGGING ////
var string  DebugInfo;

replication
{
    reliable if (bNetDirty && !bNetOwner && Role == ROLE_Authority)
        CurrentHitLocation, FlashCount;
    reliable if (bNetDirty && Role == ROLE_Authority)
        HitCount, LastHitLocation, bActive, bForceCenterAim, bCallInstigatorPostRender, Team;
}

native function int LimitPitch(int Pitch, rotator ForwardRotation, optional int WeaponYaw);

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
//	Super.DisplayDebug(Canvas, YL, YPos);

	Canvas.SetDrawColor(255,255,255);
	Canvas.DrawText("bActive: "$bActive@"bCorrectAim: "$bCorrectAim);
	YPos += YL;
	Canvas.SetPos(4, YPos);
	Canvas.DrawText("DebugInfo: "$DebugInfo);
}

simulated function PostBeginPlay()
{
    YawConstraintDelta = (YawEndConstraint - YawStartConstraint) & 65535;
    if (AltFireInterval ~= 0.0) //doesn't have an altfire
    {
    	AltFireInterval = FireInterval;
    	AIInfo[1] = AIInfo[0];
    }

    if (bShowChargingBar && Owner != None)
    	Vehicle(Owner).bShowChargingBar = true; //for listen/standalone clients

    if (Level.GRI != None && Level.GRI.WeaponBerserk > 1.0)
    	SetFireRateModifier(Level.GRI.WeaponBerserk);
}

simulated function PostNetBeginPlay()
{
    if (bInstantFire)
        GotoState('InstantFireMode');
    else
        GotoState('ProjectileFireMode');

    InitEffects();

    MaxRange();

    Super.PostNetBeginPlay();
}

simulated function InitEffects()
{
    // don't even spawn on server
    if (Level.NetMode == NM_DedicatedServer)
		return;

    if ( (FlashEmitterClass != None) && (FlashEmitter == None) )
    {
        FlashEmitter = Spawn(FlashEmitterClass);
        FlashEmitter.SetDrawScale(DrawScale);
        if (WeaponFireAttachmentBone == '')
            FlashEmitter.SetBase(self);
        else
            AttachToBone(FlashEmitter, WeaponFireAttachmentBone);

        FlashEmitter.SetRelativeLocation(WeaponFireOffset * vect(1,0,0));
    }

    if (AmbientEffectEmitterClass != none && AmbientEffectEmitter == None)
    {
        AmbientEffectEmitter = spawn(AmbientEffectEmitterClass, self,, WeaponFireLocation, WeaponFireRotation);
        if (WeaponFireAttachmentBone == '')
            AmbientEffectEmitter.SetBase(self);
        else
            AttachToBone(AmbientEffectEmitter, WeaponFireAttachmentBone);

        AmbientEffectEmitter.SetRelativeLocation(WeaponFireOffset * vect(1,0,0));
    }
}

simulated function SetGRI(GameReplicationInfo GRI)
{
	if (GRI.WeaponBerserk > 1.0)
		SetFireRateModifier(GRI.WeaponBerserk);
}

simulated function SetFireRateModifier(float Modifier)
{
	if (FireInterval == AltFireInterval)
	{
		FireInterval = default.FireInterval / Modifier;
		AltFireInterval = FireInterval;
	}
	else
	{
		FireInterval = default.FireInterval / Modifier;
		AltFireInterval = default.AltFireInterval / Modifier;
	}
}

function SpawnHitEffects(actor HitActor, vector HitLocation, vector HitNormal);
simulated event ClientSpawnHitEffects();

simulated function ShakeView()
{
    local PlayerController P;

    if (Instigator == None)
    	return;

    P = PlayerController(Instigator.Controller);
    if (P != None )
        P.WeaponShakeView(ShakeRotMag, ShakeRotRate, ShakeRotTime, ShakeOffsetMag, ShakeOffsetRate, ShakeOffsetTime);
}

//ClientStartFire() and ClientStopFire() are only called for the client that owns the weapon (and not at all for bots)
simulated function ClientStartFire(Controller C, bool bAltFire)
{
    bIsAltFire = bAltFire;

	if (FireCountdown <= 0)
	{
		if (bIsRepeatingFF)
		{
			if (bIsAltFire)
				ClientPlayForceFeedback( AltFireForce );
			else
				ClientPlayForceFeedback( FireForce );
		}
		OwnerEffects();
	}
}

simulated function ClientStopFire(Controller C, bool bWasAltFire)
{
	if (bIsRepeatingFF)
	{
		if (bIsAltFire)
			StopForceFeedback( AltFireForce );
		else
			StopForceFeedback( FireForce );
	}

	if (Role < ROLE_Authority && AmbientEffectEmitter != None)
		AmbientEffectEmitter.SetEmitterStatus(false);
}

simulated function ClientPlayForceFeedback( String EffectName )
{
    local PlayerController PC;

    if (Instigator == None)
    	return;

    PC = PlayerController(Instigator.Controller);
    if ( PC != None && PC.bEnableGUIForceFeedback )
    {
        PC.ClientPlayForceFeedback( EffectName );
    }
}

simulated function StopForceFeedback( String EffectName )
{
    local PlayerController PC;

    if (Instigator == None)
    	return;

    PC = PlayerController(Instigator.Controller);
    if ( PC != None && PC.bEnableGUIForceFeedback )
    {
        PC.StopForceFeedback( EffectName );
    }
}

//do effects (muzzle flash, force feedback, etc) immediately for the weapon's owner (don't wait for replication)
simulated event OwnerEffects()
{
	if (!bIsRepeatingFF)
	{
		if (bIsAltFire)
			ClientPlayForceFeedback( AltFireForce );
		else
			ClientPlayForceFeedback( FireForce );
	}
    ShakeView();

	if (Role < ROLE_Authority)
	{
		if (bIsAltFire)
			FireCountdown = AltFireInterval;
		else
			FireCountdown = FireInterval;

		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

        FlashMuzzleFlash();

		if (AmbientEffectEmitter != None)
			AmbientEffectEmitter.SetEmitterStatus(true);

        // Play firing noise
        if (!bAmbientFireSound)
        {
            if (bIsAltFire)
                PlaySound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
            else
                PlaySound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
        }
	}
}

event bool AttemptFire(Controller C, bool bAltFire)
{
  	if(Role != ROLE_Authority || bForceCenterAim)
		return False;

	if (FireCountdown <= 0)
	{
		CalcWeaponFire();
		if (bCorrectAim)
			WeaponFireRotation = AdjustAim(bAltFire);
		if (Spread > 0)
			WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand()*FRand()*Spread);

        	DualFireOffset *= -1;

		Instigator.MakeNoise(1.0);
		if (bAltFire)
		{
			FireCountdown = AltFireInterval;
			AltFire(C);
		}
		else
		{
		    FireCountdown = FireInterval;
		    Fire(C);
		}
		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

	    return True;
	}

	return False;
}

function rotator AdjustAim(bool bAltFire)
{
	local rotator AdjustedAim, ControllerAim;
	local int n;

	if ( (Instigator == None) || (Instigator.Controller == None) )
		return WeaponFireRotation;

	if ( bAltFire )
		n = 1;

	if ( !SavedFireProperties[n].bInitialized )
	{
		SavedFireProperties[n].AmmoClass = class'Ammo_Dummy';
		if ( bAltFire )
			SavedFireProperties[n].ProjectileClass = AltFireProjectileClass;
		else
			SavedFireProperties[n].ProjectileClass = ProjectileClass;
		SavedFireProperties[n].WarnTargetPct = AIInfo[n].WarnTargetPct;
		SavedFireProperties[n].MaxRange = MaxRange();
		SavedFireProperties[n].bTossed = AIInfo[n].bTossed;
		SavedFireProperties[n].bTrySplash = AIInfo[n].bTrySplash;
		SavedFireProperties[n].bLeadTarget = AIInfo[n].bLeadTarget;
		SavedFireProperties[n].bInstantHit = AIInfo[n].bInstantHit;
		SavedFireProperties[n].bInitialized = true;
	}

	ControllerAim = Instigator.Controller.Rotation;

	AdjustedAim = Instigator.AdjustAim(SavedFireProperties[n], WeaponFireLocation, AIInfo[n].AimError);
	if (AdjustedAim == Instigator.Rotation || AdjustedAim == ControllerAim)
		return WeaponFireRotation; //No adjustment
	else
	{
		AdjustedAim.Pitch = Instigator.LimitPitch(AdjustedAim.Pitch);
		return AdjustedAim;
}
}

//AI: return the best fire mode for the situation
function byte BestMode()
{
	return Rand(2);
}

function Fire(Controller C)
{
    log(self$": Fire has been called outside of a state!");
}

function AltFire(Controller C)
{
    log(self$": AltFire has been called outside of a state!");
}

// return false if out of range, can't see target, etc.
function bool CanAttack(Actor Other)
{
    local float Dist, CheckDist;
    local vector HitLocation, HitNormal, projStart;
    local actor HitActor;

    if ( (Instigator == None) || (Instigator.Controller == None) )
        return false;

    // check that target is within range
    Dist = VSize(Instigator.Location - Other.Location);
    if (Dist > MaxRange())
        return false;

    // check that can see target
    if (!Instigator.Controller.LineOfSightTo(Other))
        return false;

	if (ProjectileClass != None)
	{
		CheckDist = FMax(CheckDist, 0.5 * ProjectileClass.Default.Speed);
		CheckDist = FMax(CheckDist, 300);
		CheckDist = FMin(CheckDist, VSize(Other.Location - Location));
	}
	if (AltFireProjectileClass != None)
	{
		CheckDist = FMax(CheckDist, 0.5 * AltFireProjectileClass.Default.Speed);
		CheckDist = FMax(CheckDist, 300);
		CheckDist = FMin(CheckDist, VSize(Other.Location - Location));
	}

    // check that would hit target, and not a friendly
	CalcWeaponFire();
    projStart = WeaponFireLocation;
    if (bInstantFire)
        HitActor = Trace(HitLocation, HitNormal, Other.Location + Other.CollisionHeight * vect(0,0,0.8), projStart, true);
    else
    {
        // for non-instant hit, only check partial path (since others may move out of the way)
        HitActor = Trace(HitLocation, HitNormal,
                projStart + CheckDist * Normal(Other.Location + Other.CollisionHeight * vect(0,0,0.8) - Location),
                projStart, true);
    }

    if ( (HitActor == None) || (HitActor == Other) || (Pawn(HitActor) == None)
		|| (Pawn(HitActor).Controller == None) || !Instigator.Controller.SameTeamAs(Pawn(HitActor).Controller) )
        return true;

    return false;
}

simulated function float MaxRange()
{
	if (bInstantFire)
	{
        if (Instigator != None && Instigator.Region.Zone != None && Instigator.Region.Zone.bDistanceFog)
			TraceRange = FClamp(Instigator.Region.Zone.DistanceFogEnd, 8000, default.TraceRange);
		else
			TraceRange = default.TraceRange;

		AimTraceRange = TraceRange;
	}
	else if ( ProjectileClass != None )
		AimTraceRange = ProjectileClass.static.GetRange();
	else
		AimTraceRange = 10000;

	return AimTraceRange;
}

state InstantFireMode
{
    function Fire(Controller C)
    {
        FlashMuzzleFlash();

        if (AmbientEffectEmitter != None)
        {
            AmbientEffectEmitter.SetEmitterStatus(true);
        }

        // Play firing noise
        if (bAmbientFireSound)
            AmbientSound = FireSoundClass;
        else
            PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius, FireSoundPitch, False);

        TraceFire(WeaponFireLocation, WeaponFireRotation);
    }

    function AltFire(Controller C)
    {
    }

    simulated event ClientSpawnHitEffects()
    {
    	local vector HitLocation, HitNormal, Offset;
    	local actor HitActor;

    	// if standalone, already have valid HitActor and HitNormal
    	if ( Level.NetMode == NM_Standalone )
    		return;
    	Offset = 20 * Normal(WeaponFireLocation - LastHitLocation);
    	HitActor = Trace(HitLocation, HitNormal, LastHitLocation - Offset, LastHitLocation + Offset, False);
    	SpawnHitEffects(HitActor, LastHitLocation, HitNormal);
    }

    simulated function SpawnHitEffects(actor HitActor, vector HitLocation, vector HitNormal)
    {
		local PlayerController PC;

		PC = Level.GetLocalPlayerController();
		if (PC != None && ((Instigator != None && Instigator.Controller == PC) || VSize(PC.ViewTarget.Location - HitLocation) < 5000))
		{
			Spawn(class'HitEffect'.static.GetHitEffect(HitActor, HitLocation, HitNormal),,, HitLocation, Rotator(HitNormal));
			if ( !Level.bDropDetail && (Level.DetailMode != DM_Low) )
			{
				// check for splash
				if ( Base != None )
				{
					Base.bTraceWater = true;
					HitActor = Base.Trace(HitLocation,HitNormal,HitLocation,Location + 200 * Normal(HitLocation - Location),true);
					Base.bTraceWater = false;
				}
				else
				{
					bTraceWater = true;
					HitActor = Trace(HitLocation,HitNormal,HitLocation,Location + 200 * Normal(HitLocation - Location),true);
					bTraceWater = false;
				}

				if ( (FluidSurfaceInfo(HitActor) != None) || ((PhysicsVolume(HitActor) != None) && PhysicsVolume(HitActor).bWaterVolume) )
					Spawn(class'BulletSplash',,,HitLocation,rot(16384,0,0));
			}
		}
    }
}

state ProjectileFireMode
{
    function Fire(Controller C)
    {
    	SpawnProjectile(ProjectileClass, False);
    }

    function AltFire(Controller C)
    {
        if (AltFireProjectileClass == None)
            Fire(C);
        else
            SpawnProjectile(AltFireProjectileClass, True);
    }
}

function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{
    local Projectile P;
    local ONSWeaponPawn WeaponPawn;
    local vector StartLocation, HitLocation, HitNormal, Extent;

    if (bDoOffsetTrace)
    {
       	Extent = ProjClass.default.CollisionRadius * vect(1,1,0);
        Extent.Z = ProjClass.default.CollisionHeight;
       	WeaponPawn = ONSWeaponPawn(Owner);
    	if (WeaponPawn != None && WeaponPawn.VehicleBase != None)
    	{
    		if (!WeaponPawn.VehicleBase.TraceThisActor(HitLocation, HitNormal, WeaponFireLocation, WeaponFireLocation + vector(WeaponFireRotation) * (WeaponPawn.VehicleBase.CollisionRadius * 1.5), Extent))
			StartLocation = HitLocation;
		else
			StartLocation = WeaponFireLocation + vector(WeaponFireRotation) * (ProjClass.default.CollisionRadius * 1.1);
	}
	else
	{
		if (!Owner.TraceThisActor(HitLocation, HitNormal, WeaponFireLocation, WeaponFireLocation + vector(WeaponFireRotation) * (Owner.CollisionRadius * 1.5), Extent))
			StartLocation = HitLocation;
		else
			StartLocation = WeaponFireLocation + vector(WeaponFireRotation) * (ProjClass.default.CollisionRadius * 1.1);
	}
    }
    else
    	StartLocation = WeaponFireLocation;

    P = spawn(ProjClass, self, , StartLocation, WeaponFireRotation);

    if (P != None)
    {
        if (bInheritVelocity)
            P.Velocity = Instigator.Velocity;

        FlashMuzzleFlash();

        // Play firing noise
        if (bAltFire)
        {
            if (bAmbientAltFireSound)
                AmbientSound = AltFireSoundClass;
            else
                PlayOwnedSound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
        }
        else
        {
            if (bAmbientFireSound)
                AmbientSound = FireSoundClass;
            else
                PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
        }
    }

    return P;
}

function CeaseFire(Controller C)
{
    FlashCount = 0;
    HitCount = 0;

    if (AmbientEffectEmitter != None)
    {
        AmbientEffectEmitter.SetEmitterStatus(false);
    }

    if (bAmbientFireSound || bAmbientAltFireSound)
    {
        AmbientSound = None;
    }
}

function WeaponCeaseFire(Controller C, bool bWasAltFire);

simulated event FlashMuzzleFlash()
{
    if (Role == ROLE_Authority)
    {
    	FlashCount++;
    	NetUpdateTime = Level.TimeSeconds - 1;
    }
    else
        CalcWeaponFire();

    if (FlashEmitter != None)
        FlashEmitter.Trigger(Self, Instigator);

    if ( (EffectEmitterClass != None) && EffectIsRelevant(Location,false) )
        EffectEmitter = spawn(EffectEmitterClass, self,, WeaponFireLocation, WeaponFireRotation);
}

simulated function Destroyed()
{
    DestroyEffects();

    Super.Destroyed();
}

simulated function DestroyEffects()
{
    if (FlashEmitter != None)
        FlashEmitter.Destroy();
    if (EffectEmitter != None)
    	EffectEmitter.Destroy();
    if (AmbientEffectEmitter != None)
    	AmbientEffectEmitter.Destroy();
}

simulated function SetTeam(byte T)
{
    Team = T;
    if (T == 0 && RedSkin != None)
    {
        Skins[0] = RedSkin;
        RepSkin = RedSkin;
    }
    else if (T == 1 && BlueSkin != None)
    {
        Skins[0] = BlueSkin;
        RepSkin = BlueSkin;
    }
}

/* simulated TraceFire to get precise start/end of hit */
simulated function SimulateTraceFire( out vector Start, out Rotator Dir, out vector HitLocation, out vector HitNormal )
{
    local Vector		X, End;
    local Actor			Other;
    local ONSWeaponPawn WeaponPawn;
    local Vehicle		VehicleInstigator;

    if ( bDoOffsetTrace )
    {
    	WeaponPawn = ONSWeaponPawn(Owner);
	    if ( WeaponPawn != None && WeaponPawn.VehicleBase != None )
    	{
    		if ( !WeaponPawn.VehicleBase.TraceThisActor(HitLocation, HitNormal, Start, Start + vector(Dir) * (WeaponPawn.VehicleBase.CollisionRadius * 1.5)))
				Start = HitLocation;
		}
		else
			if ( !Owner.TraceThisActor(HitLocation, HitNormal, Start, Start + vector(Dir) * (Owner.CollisionRadius * 1.5)))
				Start = HitLocation;
    }

	X = Vector(Dir);
    End = Start + TraceRange * X;

    // skip past vehicle driver
    VehicleInstigator = Vehicle(Instigator);
    if ( VehicleInstigator != None && VehicleInstigator.Driver != None )
    {
        VehicleInstigator.Driver.bBlockZeroExtentTraces = false;
        Other = Trace(HitLocation, HitNormal, End, Start, true);
        VehicleInstigator.Driver.bBlockZeroExtentTraces = true;
    }
    else
        Other = Trace(HitLocation, HitNormal, End, Start, True);

    if ( Other != None && Other != Instigator )
    {
		if ( !Other.bWorldGeometry )
        {
 			if ( Vehicle(Other) != None || Pawn(Other) == None )
 			{
 				LastHitLocation = HitLocation;
			}
			HitNormal = vect(0,0,0);
        }
        else
        {
            LastHitLocation = HitLocation;
		}
    }
    else
    {
        HitLocation = End;
        HitNormal = Vect(0,0,0);
    }
}

function TraceFire(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal, RefNormal;
    local Actor Other;
    local ONSWeaponPawn WeaponPawn;
    local Vehicle VehicleInstigator;
    local int Damage;
    local bool bDoReflect;
    local int ReflectNum;

    MaxRange();

    if ( bDoOffsetTrace )
    {
    	WeaponPawn = ONSWeaponPawn(Owner);
	    if ( WeaponPawn != None && WeaponPawn.VehicleBase != None )
    	{
    		if ( !WeaponPawn.VehicleBase.TraceThisActor(HitLocation, HitNormal, Start, Start + vector(Dir) * (WeaponPawn.VehicleBase.CollisionRadius * 1.5)))
				Start = HitLocation;
		}
		else
			if ( !Owner.TraceThisActor(HitLocation, HitNormal, Start, Start + vector(Dir) * (Owner.CollisionRadius * 1.5)))
				Start = HitLocation;
    }

    ReflectNum = 0;
    while ( true )
    {
        bDoReflect = false;
        X = Vector(Dir);
        End = Start + TraceRange * X;

        //skip past vehicle driver
        VehicleInstigator = Vehicle(Instigator);
        if ( ReflectNum == 0 && VehicleInstigator != None && VehicleInstigator.Driver != None )
        {
        	VehicleInstigator.Driver.bBlockZeroExtentTraces = false;
        	Other = Trace(HitLocation, HitNormal, End, Start, true);
        	VehicleInstigator.Driver.bBlockZeroExtentTraces = true;
        }
        else
        	Other = Trace(HitLocation, HitNormal, End, Start, True);

        if ( Other != None && (Other != Instigator || ReflectNum > 0) )
        {
            if (bReflective && Other.IsA('xPawn') && xPawn(Other).CheckReflect(HitLocation, RefNormal, DamageMin*0.25))
            {
                bDoReflect = True;
                HitNormal = vect(0,0,0);
            }
            else if (!Other.bWorldGeometry)
            {
                Damage = (DamageMin + Rand(DamageMax - DamageMin));
 				if ( Vehicle(Other) != None || Pawn(Other) == None )
 				{
 					HitCount++;
 					LastHitLocation = HitLocation;
					SpawnHitEffects(Other, HitLocation, HitNormal);
				}
               	Other.TakeDamage(Damage, Instigator, HitLocation, Momentum*X, DamageType);
				HitNormal = vect(0,0,0);
            }
            else
            {
                HitCount++;
                LastHitLocation = HitLocation;
                SpawnHitEffects(Other, HitLocation, HitNormal);
	    }
        }
        else
        {
            HitLocation = End;
            HitNormal = Vect(0,0,0);
            HitCount++;
            LastHitLocation = HitLocation;
        }

        SpawnBeamEffect(Start, Dir, HitLocation, HitNormal, ReflectNum);

        if ( bDoReflect && ++ReflectNum < 4 )
        {
            //Log("reflecting off"@Other@Start@HitLocation);
            Start	= HitLocation;
            Dir		= Rotator(RefNormal); //Rotator( X - 2.0*RefNormal*(X dot RefNormal) );
        }
        else
        {
            break;
        }
    }

    NetUpdateTime = Level.TimeSeconds - 1;
}

function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum);

simulated function CalcWeaponFire()
{
    local coords WeaponBoneCoords;
    local vector CurrentFireOffset;

    // Calculate fire offset in world space
    WeaponBoneCoords = GetBoneCoords(WeaponFireAttachmentBone);
    CurrentFireOffset = (WeaponFireOffset * vect(1,0,0)) + (DualFireOffset * vect(0,1,0));

    // Calculate rotation of the gun
    WeaponFireRotation = rotator(vector(CurrentAim) >> Rotation);

    // Calculate exact fire location
    WeaponFireLocation = WeaponBoneCoords.Origin + (CurrentFireOffset >> WeaponFireRotation);

    // Adjust fire rotation taking dual offset into account
    if (bDualIndependantTargeting)
        WeaponFireRotation = rotator(CurrentHitLocation - WeaponFireLocation);
}

function DoCombo();

simulated function float ChargeBar();

static function StaticPrecache(LevelInfo L);

defaultproperties
{
     YawEndConstraint=65535.000000
     PitchUpLimit=5000
     PitchDownLimit=60000
     RotationsPerSecond=0.750000
     bAimable=True
     bShowAimCrosshair=True
     bCorrectAim=True
     FireInterval=0.500000
     FireSoundVolume=160.000000
     FireSoundRadius=300.000000
     FireSoundPitch=1.000000
     AltFireSoundVolume=160.000000
     AltFireSoundRadius=300.000000
     RotateSoundThreshold=50.000000
     AmbientSoundScaling=1.000000
     DamageType=Class'XWeapons.DamTypeMinigunBullet'
     DamageMin=6
     DamageMax=6
     TraceRange=10000.000000
     Momentum=1.000000
     AIInfo(0)=(aimerror=600.000000,RefireRate=0.900000)
     AIInfo(1)=(aimerror=600.000000,RefireRate=0.900000)
     DrawType=DT_Mesh
     bIgnoreEncroachers=True
     bReplicateInstigator=True
     RemoteRole=ROLE_SimulatedProxy
     NetUpdateFrequency=5.000000
     SoundVolume=255
     SoundRadius=100.000000
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
     bNoRepMesh=True
}
