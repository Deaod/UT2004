//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSVehicle extends SVehicle
    native
    nativereplication
    abstract;

#exec OBJ LOAD FILE=HUDContent.utx

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

//// WEAPONS ////
struct native export DriverWeaponStruct
{
    var()           class<ONSWeapon>                WeaponClass;
    var()           name                            WeaponBone;
};
var(SVehicle)       array<DriverWeaponStruct>       DriverWeapons;
var                 array<ONSWeapon>                Weapons;

struct native export PassengerWeaponStruct
{
    var()           class<ONSWeaponPawn>            WeaponPawnClass;
    var()           name                            WeaponBone;
};
var(SVehicle)       array<PassengerWeaponStruct>    PassengerWeapons;
var                 array<ONSWeaponPawn>            WeaponPawns;

var                 byte                            ActiveWeapon;
var                 Rotator                         CustomAim;

var bool bHasAltFire;

//// TEAM STATUS ////
var()               Material        RedSkin;
var()               Material        BlueSkin;

//// SOUNDS ////
var()               sound           IdleSound;
var()               sound           StartUpSound;
var()               sound           ShutDownSound;

//// FORCEFEEDBACK ////
var()				string			StartUpForce;
var()				string			ShutDownForce;

//// PROXIMITY VIEWSHAKE ////
var()				float			ViewShakeRadius; // Distance from vehicle origin that view starts to shake.
var()				rotator			ViewShakeRotMag;
var()				float			ViewShakeRotFreq;
var()				vector			ViewShakeOffsetMag;
var()				float			ViewShakeOffsetFreq;
var					float			ViewShakeLastCheck; // Internal

//// DAMAGE AND DESTRUCTION ////
var()   StaticMesh                  DestroyedVehicleMesh;
var()   class<Emitter>              DestructionEffectClass;
var()   class<Emitter>				DisintegrationEffectClass;
var()   float                       DisintegrationHealth;
var()   range                       DestructionLinearMomentum;
var()   range                       DestructionAngularMomentum;
var()   float                       TimeBetweenImpactExplosions;
var()   array<sound>                ExplosionSounds;
var()	float						ExplosionSoundVolume;
var()	float						ExplosionSoundRadius;
var     byte                        ExplosionCount;
var     byte                        OldExplosionCount;
var     float			            LastVelocitySize; //internal
var     float                       LastImpactExplosionTime;
var     float			            LastCheckUpsideDownTime;
var     float                       UpsideDownDamage;
var     float			            ExplosionDamage;
var     float			            ExplosionRadius;
var     float			            ExplosionMomentum;
var     class<DamageType>	        ExplosionDamageType;
var     class<DamageType>           DestroyedRoadKillDamageType; //damagetype for when vehicle runs over/crushes someone after being destroyed

var()	class<ONSDamagedEffect>     DamagedEffectClass;
var()	float				        DamagedEffectScale;
var()	vector                      DamagedEffectOffset;
var()	float				        DamagedEffectHealthSmokeFactor; // Proportion of default health before thing starts smoking.
var()	float				        DamagedEffectHealthFireFactor; // Proportion of default health before thing starts burning.
var()	float				        DamagedEffectAccScale;
var()   float                       DamagedEffectFireDamagePerSec;
var     float                       DamagedEffectAccruedDamage;
var	ONSDamagedEffect		        DamagedEffect;

// BOOLS //
var     bool                        bDestroyAppearance;
var     bool                        bDisintegrateVehicle;
var     bool                        bHadFire; //internal
var()	bool                        bEnableProximityViewShake;
var()   bool                        bOnlyViewShakeIfDriven;
var     bool                        bSoundsPrecached;
var     bool                        bNeverReset;
var     bool                        bEjectPassengersWhenFlipped;
var     bool                        bDriverCannotLeaveVehicle;
var     bool                        bCannotBeBased;
var()   vector                      FireImpulse;
var()   vector                      AltFireImpulse;
var     bool                        bHasFireImpulse;
var     bool                        bHasAltFireImpulse;
var     bool                        bCustomAiming;     // If true, the weapon aiming will be controlled by setting CustomAim.
var		const bool					bIsAwake;					// used for replication
var		const bool					bHasBeenAwake;
var		bool						bAltFocalPoint;		// used by AI - override AI focalpoint

var vector AltFocalPoint;

// EXPLOSION CAMERA SHAKES //
var() vector ShakeRotMag;           // how far to rot view
var() vector ShakeRotRate;          // how fast to rot view
var() float  ShakeRotTime;          // how much time to rot the instigator's view
var() vector ShakeOffsetMag;        // max view offset vertically
var() vector ShakeOffsetRate;       // how fast to offset view vertically
var() float  ShakeOffsetTime;       // how much time to offset view

//// IMPACT ////
struct native export ImpactInfoStruct
{
    var             actor           Other;
    var             vector          Pos;
    var             vector          ImpactVel;
    var             vector          ImpactNorm;
    var             vector          ImpactAccel;
};

var                 ImpactInfoStruct                ImpactInfo;
var                 int             ImpactTicksLeft;

var()               float           ImpactDamageTicks;
var()               float           ImpactDamageThreshold;
var()               float           ImpactDamageMult;

var()               array<Sound>    ImpactDamageSounds;

//// SPARKS ////
var()				class<ONSImpactSparks>		SparkEffectClass;
var()				editinline ONSImpactSparks	SparkEffect;
var()				float						SparkAdvanceFactor;

//// HEADLIGHTS ////
var		array<ONSHeadlightCorona>	HeadlightCorona;
var()	array<vector>				HeadlightCoronaOffset;
var()	Material					HeadlightCoronaMaterial;
var()	float						HeadlightCoronaMaxSize;

var		ONSHeadlightProjector		HeadlightProjector;
var()	Material					HeadlightProjectorMaterial; // If null, do not create projector.
var()	vector						HeadlightProjectorOffset;
var()	rotator						HeadlightProjectorRotation;
var()	float						HeadlightProjectorScale;

//// DEBUGGING ////
var     string                      DebugInfo;

var	Sound	LockedOnSound;
var	float	ResetTime;	//if vehicle has no driver, CheckReset() will be called at this time
var	float	LastRunOverWarningTime; //last time checked for pawns in front of vehicle and warned them of their impending doom
var	float	MinRunOverWarningAim;
var bot		Reservation;		// bot that's about to get in this vehicle
var int     OldYaw;		// used by AI

// CORRECT AIM INDICATOR
var config Color CrosshairColor;
var config float CrosshairX, CrosshairY;
var config Texture CrosshairTexture;

replication
{
    reliable if (bNetOwner && bNetDirty && Role == ROLE_Authority)
    	ActiveWeapon;

    reliable if (bNetDirty && Role == ROLE_Authority)
        ExplosionCount, bDestroyAppearance, bDisintegrateVehicle;

	reliable if (Role == ROLE_Authority)
		ClientRegisterVehicleWeapon;

    reliable if (Role < ROLE_Authority)
    	ServerChangeDriverPosition, ServerVerifyVehicleWeapon;
}

//Notify vehicle that an enemy has locked on to it
event NotifyEnemyLockedOn()
{
	local int i;

	Super.NotifyEnemyLockedOn();

	if (LockedOnSound != None)
		PlaySound(LockedOnSound);

	for (i = 0; i < WeaponPawns.length; i++)
		WeaponPawns[i].NotifyEnemyLockedOn();
}

event NotifyEnemyLostLock()
{
	local int i;

	Super.NotifyEnemyLostLock();

	for (i = 0; i < WeaponPawns.length; i++)
		WeaponPawns[i].NotifyEnemyLostLock();
}

function bool HasWeapon()
{
	return (ActiveWeapon < Weapons.length);
}

function bool CanAttack(Actor Other)
{
	if (ActiveWeapon < Weapons.Length)
		return Weapons[ActiveWeapon].CanAttack(Other);

	return false;
}

function Deploy();
function MayUndeploy();

function bool TooCloseToAttack(Actor Other)
{
	local int NeededPitch, i;
	local bool bControlledWeaponPawn;

	if (VSize(Location - Other.Location) > 2500)
		return false;
	if (!HasWeapon())
	{
		if (WeaponPawns.length == 0)
			return false;
		for (i = 0; i < WeaponPawns.length; i++)
			if (WeaponPawns[i].Controller != None)
			{
				bControlledWeaponPawn = true;
				if (!WeaponPawns[i].TooCloseToAttack(Other))
					return false;
			}

		if (!bControlledWeaponPawn)
			return false;

		return true;
	}

	Weapons[ActiveWeapon].CalcWeaponFire();
	NeededPitch = rotator(Other.Location - Weapons[ActiveWeapon].WeaponFireLocation).Pitch;
	NeededPitch = NeededPitch & 65535;
	return (LimitPitch(NeededPitch) != NeededPitch);
}

function ChooseFireAt(Actor A)
{
	if (!bHasAltFire)
		Fire(0);
	else if (ActiveWeapon < Weapons.length)
	{
		if (Weapons[ActiveWeapon].BestMode() == 0)
			Fire(0);
		else
			AltFire(0);
	}
}

function float RefireRate()
{
	if (ActiveWeapon < Weapons.length)
	{
		if (bWeaponisAltFiring && bHasAltFire)
			return Weapons[ActiveWeapon].AIInfo[1].RefireRate;
		else
			return Weapons[ActiveWeapon].AIInfo[0].RefireRate;
	}

	return 0;
}

function bool IsFiring()
{
	return (ActiveWeapon < Weapons.length && (bWeaponisFiring || (bWeaponisAltFiring && bHasAltFire)));
}

function bool NeedToTurn(vector targ)
{
	return !(ActiveWeapon < Weapons.length && Weapons[ActiveWeapon].bCorrectAim);
}

function bool FireOnRelease()
{
	if (ActiveWeapon < Weapons.length)
	{
		if (bWeaponisAltFiring && bHasAltFire)
			return Weapons[ActiveWeapon].AIInfo[1].bFireOnRelease;
		else
			return Weapons[ActiveWeapon].AIInfo[0].bFireOnRelease;
	}

	return false;
}

function float ModifyThreat(float current, Pawn Threat)
{
	if (Threat.bCanFly && ActiveWeapon < Weapons.length && !Weapons[ActiveWeapon].AIInfo[0].bInstantHit)
		return current - 3;

	return current;
}

function bool ChangedReservation(Pawn P)
{
	if ( Level.Game.JustStarted(20) && (Reservation != None) && (Reservation != P.Controller) )
	{
		if ( (Reservation.RouteGoal == Self) && (Reservation.Pawn != None) && (VSize(Reservation.Pawn.Location - Location) <= VSize(P.Location - Location)) )
		{
			return true;
		}
		Reservation = Bot(P.Controller);
		return false;
	}
	return false;
}

function float ReservationCostMultiplier()
{
	if ( (Reservation == None) || (Reservation.Pawn == None) )
		return 1.0;
	if ( (Reservation.MoveTarget == self) && Reservation.InLatentExecution(Reservation.LATENT_MOVETOWARD) )
		return 0;
	return 0.25;
}


function float NewReservationCostMultiplier(Pawn P)
{
	if ( Reservation == P.Controller )
		return 1.0;
	if ( Level.Game.JustStarted(20) && (Reservation != None) && (Reservation.Pawn != None)
		&& (VSize(Reservation.Pawn.Location - Location) <= VSize(P.Location - Location)) )
	{
		return 0;
	}
	return ReservationCostMultiplier();
}

function bool SpokenFor(Controller C)
{
	local Bot B;

	if ( Reservation == None )
		return false;
	if ( (Reservation.Pawn == None) || (Vehicle(Reservation.Pawn) != None) )
	{
		Reservation = None;
		return false;
	}
	if ( ((Reservation.RouteGoal != self) && (Reservation.MoveTarget != self))
		|| !Reservation.InLatentExecution(Reservation.LATENT_MOVETOWARD) )
	{
		Reservation = None;
		return false;
	}

	if ( !Reservation.SameTeamAs(C) )
		return false;

	B = Bot(C);
	if ( B == None )
		return true;
	if ( WeaponPawns.Length > 0 )
		return ( B.Squad != Reservation.Squad );
	if( Level.Game.JustStarted(20) )
	{
		if ( VSize(Reservation.Pawn.Location - Location) > VSize(C.Pawn.Location - Location) )
			return false;
	}

	return true;
}

function SetReservation(controller C)
{
	if ( !SpokenFor(C) )
		Reservation = Bot(C);
}

function Vehicle OpenPositionFor(Pawn P)
{
	local int i;

	if ( Level.Game.JustStarted(20) )
	{

		if ( (Reservation != None) && (Reservation != P.Controller) && (Reservation.RouteGoal == Self) && (Reservation.Pawn != None) && (VSize(Reservation.Pawn.Location - Location) <= VSize(P.Location - Location)) )
		{
			for ( i=0; i<WeaponPawns.Length; i++ )
				if ( WeaponPawns[i].Controller == None )
					return WeaponPawns[i];
			return None;
		}
	}

	if ( Controller == None )
		return self;

	if ( !Controller.SameTeamAs(P.Controller) )
		return None;
	for ( i=0; i<WeaponPawns.Length; i++ )
		if ( WeaponPawns[i].Controller == None )
			return WeaponPawns[i];

	return None;
}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local int i;

	Super.DisplayDebug(Canvas, YL, YPos);

//    if (Weapons[0] != None && Weapons[0].DebugInfo != "")
//        DebugInfo = Weapons[0].DebugInfo;

	Canvas.SetDrawColor(255,0,0);
	Canvas.DrawText(DebugInfo);
	YPos += YL;

  	for (i=0; i<Weapons.length; i++)
  	{
		YPos += YL;
		Canvas.SetPos(0, YPos);
		Canvas.SetDrawColor(0,0,255);        Canvas.DrawText("-- Weapon: "$i$" - "$Weapons[i]);
		YPos += YL;
		Canvas.SetPos(4, YPos);
		Weapons[i].DisplayDebug( Canvas, YL, YPos );
	}

  	YPos += YL;
	DebugInfo = "";
}

simulated function PostNetBeginPlay()
{
    local int i;

    Super.PostNetBeginPlay();

    if (Role == ROLE_Authority)
    {
        // Spawn the Driver Weapons
        for(i=0;i<DriverWeapons.Length;i++)
        {
            // Spawn Weapon
            Weapons[i] = spawn(DriverWeapons[i].WeaponClass, self,, Location, rot(0,0,0));
            AttachToBone(Weapons[i], DriverWeapons[i].WeaponBone);
            if (!Weapons[i].bAimable)
                Weapons[i].CurrentAim = rot(0,32768,0);
        }

    	if (ActiveWeapon < Weapons.length)
    	{
            PitchUpLimit = Weapons[ActiveWeapon].PitchUpLimit;
            PitchDownLimit = Weapons[ActiveWeapon].PitchDownLimit;
    	}

        // Spawn the Passenger Weapons
        for(i=0;i<PassengerWeapons.Length;i++)
        {
            // Spawn WeaponPawn
            WeaponPawns[i] = spawn(PassengerWeapons[i].WeaponPawnClass, self,, Location);
            WeaponPawns[i].AttachToVehicle(self, PassengerWeapons[i].WeaponBone);
            if (!WeaponPawns[i].bHasOwnHealth)
            	WeaponPawns[i].HealthMax = HealthMax;
            WeaponPawns[i].ObjectiveGetOutDist = ObjectiveGetOutDist;
        }
    }

	if(Level.NetMode != NM_DedicatedServer && Level.DetailMode > DM_Low && SparkEffectClass != None)
	{
		SparkEffect = spawn( SparkEffectClass, self,, Location);
	}

	if(Level.NetMode != NM_DedicatedServer && Level.bUseHeadlights && !(Level.bDropDetail || (Level.DetailMode == DM_Low)))
	{
		HeadlightCorona.Length = HeadlightCoronaOffset.Length;

		for(i=0; i<HeadlightCoronaOffset.Length; i++)
		{
			HeadlightCorona[i] = spawn( class'ONSHeadlightCorona', self,, Location + (HeadlightCoronaOffset[i] >> Rotation) );
			HeadlightCorona[i].SetBase(self);
			HeadlightCorona[i].SetRelativeRotation(rot(0,0,0));
			HeadlightCorona[i].Skins[0] = HeadlightCoronaMaterial;
			HeadlightCorona[i].ChangeTeamTint(Team);
			HeadlightCorona[i].MaxCoronaSize = HeadlightCoronaMaxSize * Level.HeadlightScaling;
		}

		if(HeadlightProjectorMaterial != None && Level.DetailMode == DM_SuperHigh)
		{
			HeadlightProjector = spawn( class'ONSHeadlightProjector', self,, Location + (HeadlightProjectorOffset >> Rotation) );
			HeadlightProjector.SetBase(self);
			HeadlightProjector.SetRelativeRotation( HeadlightProjectorRotation );
			HeadlightProjector.ProjTexture = HeadlightProjectorMaterial;
			HeadlightProjector.SetDrawScale(HeadlightProjectorScale);
			HeadlightProjector.CullDistance	= ShadowCullDistance;
		}
	}

    SetTeamNum(Team);
	TeamChanged();
}


simulated function ClientRegisterVehicleWeapon(ONSWeapon W, int Index)
{
	if (W == None)
		ServerVerifyVehicleWeapon(Index);
	else
		Weapons[Index] = W;
}

function ServerVerifyVehicleWeapon(int Index)
{
	if (Index < Weapons.length && Weapons[Index] != None)
		ClientRegisterVehicleWeapon(Weapons[Index], Index);
}

function Vehicle FindEntryVehicle(Pawn P)
{
	local int x;
	local float Dist, ClosestDist;
	local ONSWeaponPawn ClosestWeaponPawn;
	local Bot B;
	local Vehicle VehicleGoal;

	//bots know what they want
	B = Bot(P.Controller);
	if (B != None)
	{
		VehicleGoal = Vehicle(B.RouteGoal);
		if (VehicleGoal == None)
			return None;
		if (VehicleGoal == self)
		{
			if (Driver == None)
				return self;

			return None;
		}
		for (x = 0; x < WeaponPawns.length; x++)
			if (VehicleGoal == WeaponPawns[x])
			{
				if (WeaponPawns[x].Driver == None)
					return WeaponPawns[x];
				if (Driver == None)
					return self;

				return None;
			}

		return None;
	}

    // Always go with driver's seat if no driver
    if (Driver == None)
    {
	Dist = VSize(P.Location - (Location + (EntryPosition >> Rotation)));
	if (Dist < EntryRadius)
		return self;
	for (x = 0; x < WeaponPawns.length; x++)
	{
        	Dist = VSize(P.Location - (WeaponPawns[x].Location + (WeaponPawns[x].EntryPosition >> Rotation)));
		if (Dist < WeaponPawns[x].EntryRadius)
			return self;
	}

	return None;
    }

    // Check WeaponPawns to see if we are in radius
    ClosestDist = 100000.0;
    for (x = 0; x < WeaponPawns.length; x++)
    {
        Dist = VSize(P.Location - (WeaponPawns[x].Location + (WeaponPawns[x].EntryPosition >> Rotation)));
        if (Dist < WeaponPawns[x].EntryRadius && Dist < ClosestDist)
        {
            // WeaponPawn is within radius
            ClosestDist = Dist;
            ClosestWeaponPawn = WeaponPawns[x];
        }
    }

    if (ClosestWeaponPawn != None || VSize(P.Location - (Location + (EntryPosition >> Rotation))) < EntryRadius)
    {
        // WeaponPawn slot is closest
        if (ClosestWeaponPawn != None && ClosestWeaponPawn.Driver == None)
            return ClosestWeaponPawn;          // If closest WeaponPawn slot is open we try it
        else                                   // Otherwise we try to find another open WeaponPawn slot
        {
            for (x = 0; x < WeaponPawns.length; x++)
            {
                if (WeaponPawns[x].Driver == None)
                    return WeaponPawns[x];
            }
        }
    }

	// No slots in range
	return None;
}

function bool TryToDrive(Pawn P)
{
	local int x;

	if (FlipTimeLeft > 0)
		return false;

	if (NeedsFlip())
	{
		Flip(vector(P.Rotation), 1);
		return false;
	}

	//don't allow vehicle to be stolen when somebody is in a turret
	if (!bTeamLocked && P.GetTeamNum() != Team)
		for (x = 0; x < WeaponPawns.length; x++)
			if (WeaponPawns[x].Driver != None)
			{
				VehicleLocked(P);
				return false;
			}

	return Super.TryToDrive(P);
}

function KDriverEnter(Pawn p)
{
    local int x;

    ResetTime = Level.TimeSeconds - 1;
    Instigator = self;

    super.KDriverEnter( P );

    if ( Weapons.Length > 0 )
        Weapons[ActiveWeapon].bActive = True;

    if ( IdleSound != None )
        AmbientSound = IdleSound;

    if ( StartUpSound != None )
        PlaySound(StartUpSound, SLOT_None, 1.0);

    if (xPawn(Driver) != None && Driver.HasUDamage())
    	for (x = 0; x < Weapons.length; x++)
		Weapons[x].SetOverlayMaterial(xPawn(Driver).UDamageWeaponMaterial, xPawn(Driver).UDamageTime - Level.TimeSeconds, false);

    Driver.bSetPCRotOnPossess = false; //so when driver gets out he'll be facing the same direction as he was inside the vehicle

	for (x = 0; x < Weapons.length; x++)
	{
		if (Weapons[x] == None)
		{
			Weapons.Remove(x, 1);
			x--;
		}
		else
		{
			Weapons[x].NetUpdateFrequency = 20;
			ClientRegisterVehicleWeapon(Weapons[x], x);
		}
	}
}

function bool KDriverLeave(bool bForceLeave)
{
    local Controller C;
    local int x;

    if (bDriverCannotLeaveVehicle)
    {
        if (FlipTimeLeft > 0)
    		return False;

    	if (NeedsFlip())
    	{
    		Flip(vector(Rotation + rot(0,16384,0)), 1);
    		return False;
    	}

    	return False;
    }

    // We need to get the controller here since Super.KDriverLeave() messes with it.
    C = Controller;
    if ( Super.KDriverLeave(bForceLeave) || bForceLeave )
    {
    	if (C != None)
    	{
	        if (xPawn(C.Pawn) != None && C.Pawn.HasUDamage())
        		for (x = 0; x < Weapons.length; x++)
	    			Weapons[x].SetOverlayMaterial(xPawn(C.Pawn).UDamageWeaponMaterial, 0, false);
    		C.Pawn.bSetPCRotOnPossess = C.Pawn.default.bSetPCRotOnPossess;
            Instigator = C.Pawn; //so if vehicle continues on and runs someone over, the appropriate credit is given
        }
    	for (x = 0; x < Weapons.length; x++)
    	{
    		Weapons[x].FlashCount = 0;
    		Weapons[x].NetUpdateFrequency = Weapons[x].default.NetUpdateFrequency;
    	}

        return True;
    }
    else
        return False;
}

function DriverDied()
{
	local int x;

    if (xPawn(Driver) != None && Driver.HasUDamage())
   		for (x = 0; x < Weapons.length; x++)
			Weapons[x].SetOverlayMaterial(xPawn(Driver).UDamageWeaponMaterial, 0, false);

    Super.DriverDied();
    
    if ( Health > 0 )
		DriverLeft();
}

function SetActiveWeapon(int i)
{
    Weapons[ActiveWeapon].bActive = False;
    ActiveWeapon = i;
    Weapons[ActiveWeapon].bActive = True;

    PitchUpLimit = Weapons[ActiveWeapon].PitchUpLimit;
    PitchDownLimit = Weapons[ActiveWeapon].PitchDownLimit;
}

event VehicleLocked( Pawn P )
{
	P.ReceiveLocalizedMessage(class'ONSOnslaughtMessage', 4);
}


// DriverLeft() called by KDriverLeave()
function DriverLeft()
{
    if (ActiveWeapon < Weapons.Length)
    {
        Weapons[ActiveWeapon].bActive = False;
        Weapons[ActiveWeapon].AmbientSound = None;
    }

    if (AmbientSound != None)
        AmbientSound = None;

    if (ShutDownSound != None)
        PlaySound(ShutDownSound, SLOT_None, 1.0);

    if (!bNeverReset && ParentFactory != None && (VSize(Location - ParentFactory.Location) > 5000.0 || !FastTrace(ParentFactory.Location, Location)))
    {
    	if (bKeyVehicle)
    		ResetTime = Level.TimeSeconds + 15;
    	else
		ResetTime = Level.TimeSeconds + 30;
    }

    Super.DriverLeft();
}

//Vehicle has been in the middle of nowhere with no driver for a while, so consider resetting it
event CheckReset()
{
	local Pawn P;

	if ( bKeyVehicle && IsVehicleEmpty() )
	{
		Died(None, class'DamageType', Location);
		return;
	}

	if ( !IsVehicleEmpty() )
	{
    	ResetTime = Level.TimeSeconds + 10;
    	return;
	}

	foreach CollidingActors(class 'Pawn', P, 2500.0)
	{
		if (P.Controller != none && P != self && P.GetTeamNum() == GetTeamNum() && FastTrace(P.Location + P.CollisionHeight * vect(0,0,1), Location + CollisionHeight * vect(0,0,1)))
		{
			ResetTime = Level.TimeSeconds + 10;
			return;
		}
	}

	//if factory is active, we want it to spawn new vehicle NOW
	if ( ParentFactory != None )
	{
		ParentFactory.VehicleDestroyed(self);
		ParentFactory.Timer();
		ParentFactory = None; //so doesn't call ParentFactory.VehicleDestroyed() again in Destroyed()
	}

	Destroy();
}

simulated function int NumPassengers()
{
	local int i, num;

	if ( Driver != None )
		num = 1;

	for (i=0; i<WeaponPawns.length; i++)
		if ( WeaponPawns[i].Driver != None )
			num++;
	return num;
}

function AIController GetBotPassenger()
{
	local int i;

	for (i=0; i<WeaponPawns.length; i++)
		if ( AIController(WeaponPawns[i].Controller) != None )
			return AIController(WeaponPawns[i].Controller);
	return None;
}

function Pawn GetInstigator()
{
	local int i;

	if ( Controller != None )
		return Self;

	for (i=0; i<WeaponPawns.length; i++)
		if ( WeaponPawns[i].Controller != None )
			return WeaponPawns[i];

	return Self;
}

event bool IsVehicleEmpty()
{
	local int i;

	if ( Driver != None )
		return false;

	for (i=0; i<WeaponPawns.length; i++)
		if ( WeaponPawns[i].Driver != None )
			return false;

	return true;
}

function bool HasOccupiedTurret()
{
	local int i;

	for (i = 0; i < WeaponPawns.length; i++)
		if (WeaponPawns[i].Driver != None)
			return true;

	return false;
}

simulated function ClientKDriverEnter(PlayerController PC)
{
	Super.ClientKDriverEnter(PC);

	if (PC.bEnableGUIForceFeedback)
		PC.ClientPlayForceFeedback(StartUpForce);

	if (!bDesiredBehindView)
		PC.SetRotation(Rotation);
}

simulated function ClientKDriverLeave(PlayerController PC)
{
	if (ActiveWeapon < Weapons.length)
	{
		if (bWeaponisFiring)
			Weapons[ActiveWeapon].ClientStopFire(PC, false);
		if (bWeaponisAltFiring)
			Weapons[ActiveWeapon].ClientStopFire(PC, true);
	}

	if (PC.bEnableGUIForceFeedback)
		PC.StopForceFeedback(StartUpForce); // quick jump in and out

	Super.ClientKDriverLeave(PC);
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local int x;
	local PlayerController PC;
	local Controller C;

	if ( bDeleteMe || Level.bLevelChange || bVehicleDestroyed)
		return; // already destroyed, or level is being cleaned up

	bVehicleDestroyed = True;

	if ( Physics != PHYS_Karma )
	{
		super.Died(Killer, damageType, HitLocation);
		return;
	}

	if ( Level.Game.PreventDeath(self, Killer, damageType, HitLocation) )
	{
		Health = max(Health, 1); //mutator should set this higher
		return;
	}
	Health = Min(0, Health);

	if ( Controller != None )
	{
		C = Controller;
		C.WasKilledBy(Killer);
		Level.Game.Killed(Killer, C, self, damageType);
		if( C.bIsPlayer )
		{
			PC = PlayerController(C);
			if ( PC != None )
				ClientKDriverLeave(PC); // Just to reset HUD etc.
			else
                ClientClearController();
			if ( (bRemoteControlled || bEjectDriver) && (Driver != None) && (Driver.Health > 0) )
			{
				C.Unpossess();
				C.Possess(Driver);
				if ( bEjectDriver )
					EjectDriver();

				Driver = None;
			}
			else
				C.PawnDied(self);
		}
		else
			C.Destroy();

    		if ( Driver != None )
	    	{
        	    if ( !bRemoteControlled && !bEjectDriver )
	            {
		            if (!bDrawDriverInTP && PlaceExitingDriver())
	        	    {
	                	Driver.StopDriving(self);
		                Driver.DrivenVehicle = self;
		            }
					Driver.TearOffMomentum = Velocity * 0.25;
					Driver.Died(Controller, class'DamRanOver', Driver.Location);
	            }
        	    else
				{
					if ( bEjectDriver )
						EjectDriver();
					else
						KDriverLeave( false );
				}
	    	}

		bDriving = False;
	}
	else
		Level.Game.Killed(Killer, Controller(Owner), self, damageType);

	if ( Killer != None )
	{
		TriggerEvent(Event, self, Killer.Pawn);
		Instigator = Killer.Pawn; //so if the dead vehicle crushes somebody the vehicle's killer gets the credit
	}
	else
		TriggerEvent(Event, self, None);

	RanOverDamageType = DestroyedRoadKillDamageType;
	CrushedDamageType = DestroyedRoadKillDamageType;

	if ( IsHumanControlled() )
		PlayerController(Controller).ForceDeathUpdate();

	for (x = 0; x < WeaponPawns.length; x++)
	{
		if ( bRemoteControlled || bEjectDriver )
		{
			if ( bEjectDriver )
				WeaponPawns[x].EjectDriver();
			else
				WeaponPawns[x].KDriverLeave( false );
		}
		WeaponPawns[x].Died(Killer, damageType, HitLocation);
	}
	WeaponPawns.length = 0;

	if (ParentFactory != None)
	{
		ParentFactory.VehicleDestroyed(self);
		ParentFactory = None;
	}

	GotoState('VehicleDestroyed');
}

simulated function Destroyed()
{
    local int i;

	Super.Destroyed();

    // Destroy the weapons
    if (Role == ROLE_Authority)
    {
	    for(i=0;i<Weapons.Length;i++)
	    	if (Weapons[i]!=None)
	        	Weapons[i].Destroy();

	    for(i=0;i<WeaponPawns.Length;i++)
	    	if (WeaponPawns[i]!=None)
	        	WeaponPawns[i].Destroy();
    }
    Weapons.Length = 0;
    WeaponPawns.Length = 0;

    // Destroy the effects
	if(Level.NetMode != NM_DedicatedServer)
	{
		for(i=0;i<HeadlightCorona.Length;i++)
			HeadlightCorona[i].Destroy();
		HeadlightCorona.Length = 0;

		if(HeadlightProjector != None)
			HeadlightProjector.Destroy();

		if(DamagedEffect != None)
		{
			DamagedEffect.Destroy();
			DamagedEffect = None;
		}

		if(SparkEffect != None)
			SparkEffect.Destroy();
	}

	TriggerEvent(Event, self, None);
}

function VehicleCeaseFire(bool bWasAltFire)
{
    Super.VehicleCeaseFire(bWasAltFire);

    if (ActiveWeapon < Weapons.length)
    {
		Weapons[ActiveWeapon].CeaseFire(Controller);
		Weapons[ActiveWeapon].WeaponCeaseFire(Controller,bWasAltFire);
	}
}

simulated event TeamChanged()
{
    local int i;

    Super.TeamChanged();

    if (Team == 0 && RedSkin != None)
        Skins[0] = RedSkin;
    else if (Team == 1 && BlueSkin != None)
        Skins[0] = BlueSkin;

    if (Level.NetMode != NM_DedicatedServer && Team <= 2 && SpawnOverlay[0] != None && SpawnOverlay[1] != None)
        SetOverlayMaterial(SpawnOverlay[Team], 1.5, True);

    for (i = 0; i < Weapons.Length; i++)
        Weapons[i].SetTeam(Team);

	if (Level.NetMode != NM_DedicatedServer)
	{
		for(i = 0; i < HeadlightCorona.Length; i++)
			HeadlightCorona[i].ChangeTeamTint(Team);
	}
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{
	if (UpsideDownDamage == 0 && DamageType != class'DamTypeONSVehicle' && NeedsFlip())
		Damage = Health;

	Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
}

function DriverRadiusDamage(float DamageAmount, float DamageRadius, Controller EventInstigator, class<DamageType> DamageType, float Momentum, vector HitLocation)
{
	local int i;

	Super.DriverRadiusDamage(DamageAmount, DamageRadius, EventInstigator, DamageType, Momentum, HitLocation);

	for (i = 0; i < WeaponPawns.length; i++)
		if (!WeaponPawns[i].bCollideActors)
			WeaponPawns[i].DriverRadiusDamage(DamageAmount, DamageRadius, EventInstigator, DamageType, Momentum, HitLocation);
}

function Fire(optional float F)
{
	Super.Fire(F);

	if (ActiveWeapon < Weapons.length && PlayerController(Controller) != None)
		Weapons[ActiveWeapon].ClientStartFire(Controller, false);
}

function AltFire(optional float F)
{
	Super.AltFire(F);

	if (!bWeaponIsFiring && ActiveWeapon < Weapons.length && PlayerController(Controller) != None)
		Weapons[ActiveWeapon].ClientStartFire(Controller, true);
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
	Super.ClientVehicleCeaseFire(bWasAltFire);

	if (ActiveWeapon < Weapons.length)
	{
		Weapons[ActiveWeapon].ClientStopFire(Controller, bWasAltFire);
		if (!bWasAltFire && bWeaponIsAltFiring)
            Weapons[ActiveWeapon].ClientStartFire(Controller, true);
    }
}

event TakeImpactDamage(float AccelMag)
{
	local int Damage;

	Damage = int(AccelMag * ImpactDamageModifier());
	TakeDamage(Damage, Self, ImpactInfo.Pos, vect(0,0,0), class'DamTypeONSVehicle');
	//FIXME - Scale sound volume to damage amount
	if (ImpactDamageSounds.Length > 0)
		PlaySound(ImpactDamageSounds[Rand(ImpactDamageSounds.Length-1)],,TransientSoundVolume*2.5);

    if (Health < 0 && (Level.TimeSeconds - LastImpactExplosionTime) > TimeBetweenImpactExplosions)
    {
        VehicleExplosion(Normal(ImpactInfo.ImpactNorm), 0.5);
        LastImpactExplosionTime = Level.TimeSeconds;
    }

	if ( (Controller != None) && (KarmaBoostDest(Controller.MoveTarget) != None) && Controller.InLatentExecution(Controller.LATENT_MOVETOWARD) )
		Controller.MoveTimer = -1;
}

function float ImpactDamageModifier()
{
    return ImpactDamageMult;
}

event KImpact(actor Other, vector Pos, vector ImpactVel, vector ImpactNorm)
{
    if (Role == ROLE_Authority)
    {
        ImpactInfo.Other = Other;
        ImpactInfo.Pos = Pos;
        ImpactInfo.ImpactVel = ImpactVel;
        ImpactInfo.ImpactNorm = ImpactNorm;
        ImpactInfo.ImpactAccel = KParams.KAcceleration;
        ImpactTicksLeft = ImpactDamageTicks;
    }
}

simulated function float ChargeBar()
{
	if (ActiveWeapon < Weapons.length)
		return Weapons[ActiveWeapon].ChargeBar();

	return 0;
}

// AI hint
function bool FastVehicle()
{
	return false;
}

function bool IsDeployed()
{
	return false;
}

function SetTeamNum(byte T)
{
    local byte	Temp;
	local int	x;

    Temp = Team;
	PrevTeam = T;
    Team	= T;

	if ( Temp != T )
		TeamChanged();

	for (x = 0; x < WeaponPawns.length; x++)
      	WeaponPawns[x].SetTeamNum(T);
}

simulated function SwitchWeapon(byte F)
{
	ServerChangeDriverPosition(F);
}

function ServerChangeDriverPosition(byte F)
{
	local Pawn OldDriver, Bot;

	if (Driver == None)
		return;

	F -= 2;

	if (F < WeaponPawns.length && (WeaponPawns[F].Driver == None || AIController(WeaponPawns[F].Controller) != None))
	{
		OldDriver = Driver;
		//if human player wants a bot's seat, bot swaps with him
		if (AIController(WeaponPawns[F].Controller) != None)
		{
			Bot = WeaponPawns[F].Driver;
			WeaponPawns[F].KDriverLeave(true);
		}
		KDriverLeave(true);
		if (!WeaponPawns[F].TryToDrive(OldDriver))
		{
			KDriverEnter(OldDriver);
			if (Bot != None)
				WeaponPawns[F].KDriverEnter(Bot);
		}
		else if (Bot != None)
			TryToDrive(Bot);
	}
}

function bool HasUDamage()
{
	return (Driver != None && Driver.HasUDamage());
}

event ApplyFireImpulse(bool bAlt)
{
    if (!bAlt)
        KAddImpulse(FireImpulse >> Weapons[ActiveWeapon].WeaponFireRotation, Weapons[ActiveWeapon].WeaponFireLocation);
    else
        KAddImpulse(AltFireImpulse >> Weapons[ActiveWeapon].WeaponFireRotation, Weapons[ActiveWeapon].WeaponFireLocation);
}

simulated event DestroyAppearance()
{
	local int i;
	local KarmaParams KP;

	// For replication
	bDestroyAppearance = True;

	// Put brakes on
    Throttle	= 0;
    Steering	= 0;
	Rise		= 0;

    // Destroy the weapons
    if (Role == ROLE_Authority)
    {
    	for(i=0;i<Weapons.Length;i++)
		{
			if ( Weapons[i] != None )
				Weapons[i].Destroy();
		}
		for(i=0;i<WeaponPawns.Length;i++)
			WeaponPawns[i].Destroy();
    }
    Weapons.Length = 0;
    WeaponPawns.Length = 0;

    // Destroy the effects
	if(Level.NetMode != NM_DedicatedServer)
	{
		bNoTeamBeacon = true;

		for(i=0;i<HeadlightCorona.Length;i++)
			HeadlightCorona[i].Destroy();
		HeadlightCorona.Length = 0;

		if(HeadlightProjector != None)
			HeadlightProjector.Destroy();
	}

    // Copy linear velocity from actor so it doesn't just stop.
    KP = KarmaParams(KParams);
    if(KP != None)
        KP.KStartLinVel = Velocity;

    // Become the dead vehicle mesh
    SetPhysics(PHYS_None);
    KSetBlockKarma(False);
    SetDrawType(DT_StaticMesh);
    SetStaticMesh(DestroyedVehicleMesh);
    KSetBlockKarma(True);
    SetPhysics(PHYS_Karma);
    Skins.length = 0;
	NetPriority = 2;
}

function VehicleExplosion(vector MomentumNormal, float PercentMomentum)
{
    local vector LinearImpulse, AngularImpulse;

    HurtRadius(ExplosionDamage, ExplosionRadius, ExplosionDamageType, ExplosionMomentum, Location);

    if (!bDisintegrateVehicle)
    {
        ExplosionCount++;

        if (Level.NetMode != NM_DedicatedServer)
            ClientVehicleExplosion(False);

        LinearImpulse = PercentMomentum * RandRange(DestructionLinearMomentum.Min, DestructionLinearMomentum.Max) * MomentumNormal;
        AngularImpulse = PercentMomentum * RandRange(DestructionAngularMomentum.Min, DestructionAngularMomentum.Max) * VRand();

//        log(" ");
//        log(self$" Explosion");
//        log("LinearImpulse: "$LinearImpulse$"("$VSize(LinearImpulse)$")");
//        log("AngularImpulse: "$AngularImpulse$"("$VSize(AngularImpulse)$")");
//        log(" ");

		NetUpdateTime = Level.TimeSeconds - 1;
        KAddImpulse(LinearImpulse, vect(0,0,0));
        KAddAngularImpulse(AngularImpulse);
    }
}

simulated event ClientVehicleExplosion(bool bFinal)
{
    local Actor DestructionEffect;
	local int SoundNum;
	local PlayerController PC;
	local float Dist, Scale;

	//viewshake
	if (Level.NetMode != NM_DedicatedServer)
	{
		PC = Level.GetLocalPlayerController();
		if (PC != None && PC.ViewTarget != None)
		{
			Dist = VSize(Location - PC.ViewTarget.Location);
			if (Dist < ExplosionRadius * 2.5)
			{
				if (Dist < ExplosionRadius)
					Scale = 1.0;
				else
					Scale = (ExplosionRadius*2.5 - Dist) / (ExplosionRadius);
				PC.ShakeView(ShakeRotMag*Scale, ShakeRotRate, ShakeRotTime, ShakeOffsetMag*Scale, ShakeOffsetRate, ShakeOffsetTime);
			}
		}
	}

    // Explosion effect
	if(ExplosionSounds.Length > 0)
	{
		SoundNum = Rand(ExplosionSounds.Length);
		PlaySound(ExplosionSounds[SoundNum], SLOT_None, ExplosionSoundVolume*TransientSoundVolume,, ExplosionSoundRadius);
	}

	if (bFinal)
    {
        if (Level.NetMode != NM_DedicatedServer)
            DestructionEffect = spawn(DisintegrationEffectClass,,, Location, Rotation);

        bHidden = True;
        GotoState('VehicleDisintegrated');
    }
	else
	{
        if (Level.NetMode != NM_DedicatedServer)
        {
    		DestructionEffect = spawn(DestructionEffectClass, self);
    		DestructionEffect.SetBase(self);
    	}
    }
}

state VehicleDestroyed
{
ignores Tick;

	function CallDestroy()
	{
		Destroy();
	}

    function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
    {
    }

Begin:
    DestroyAppearance();
    VehicleExplosion(vect(0,0,1), 1.0);
    sleep(9.0);
    CallDestroy();
}

state VehicleDisintegrated
{
ignores Tick;

	function CallDestroy()
	{
		Destroy();
	}

    function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
    {
    }

Begin:
    sleep(0.25);
    CallDestroy();
}


simulated event SVehicleUpdateParams()
{
	local int i;

	Super.SVehicleUpdateParams();

	// This code just for making it easy to position coronas etc.
	if(Level.NetMode != NM_DedicatedServer)
	{
		for(i=0; i<HeadlightCorona.Length; i++)
		{
			HeadlightCorona[i].SetBase(None);
			HeadlightCorona[i].SetLocation( Location + (HeadlightCoronaOffset[i] >> Rotation) );
			HeadlightCorona[i].SetBase(self);
			HeadlightCorona[i].Skins[0] = HeadlightCoronaMaterial;
			HeadlightCorona[i].MaxCoronaSize = HeadlightCoronaMaxSize * Level.HeadlightScaling;
		}

		if(HeadlightProjector != None)
		{
			HeadlightProjector.SetBase(None);
			HeadlightProjector.SetLocation( Location + (HeadlightProjectorOffset >> Rotation) );
			HeadlightProjector.SetBase(self);
			HeadlightProjector.SetRelativeRotation( HeadlightProjectorRotation );
			HeadlightProjector.ProjTexture = HeadlightProjectorMaterial;
			HeadlightProjector.SetDrawScale(HeadlightProjectorScale);
		}

		if(DamagedEffect != None)
		{
			DamagedEffect.SetBase(None);
			DamagedEffect.SetLocation( Location + (DamagedEffectOffset >> Rotation) );
			DamagedEffect.SetBase(self);
			DamagedEffect.SetEffectScale(DamagedEffectScale);
		}
	}
}

function int LimitPitch(int pitch)
{
	if (ActiveWeapon >= Weapons.length)
		return Super.LimitPitch(pitch);

	return Weapons[ActiveWeapon].LimitPitch(pitch, Rotation);
}

function ServerPlayHorn(int HornIndex)
{
	local int i, NumPositions;
	local Pawn P;

	Super.ServerPlayHorn(HornIndex);

	if (HornIndex > 0 || PlayerController(Controller) == None)
		return;

	for (i = 0; i < WeaponPawns.length; i++)
		if (WeaponPawns[i].Driver == None)
		{
			NumPositions++;
			break;
		}

	if (NumPositions > 0)
		foreach VisibleCollidingActors(class'Pawn', P, TransientSoundRadius)
			if (Bot(P.Controller) != None && Vehicle(P) == None)
			{
				Bot(P.Controller).SetTemporaryOrders('Follow', Controller);
				NumPositions--;
				if (NumPositions == 0)
					break;
			}
}

simulated function DrawHUD(Canvas Canvas)
{
    local PlayerController PC;
    local vector CameraLocation;
    local rotator CameraRotation;
    local Actor ViewActor;

	if (IsLocallyControlled() && ActiveWeapon < Weapons.length && Weapons[ActiveWeapon] != None && Weapons[ActiveWeapon].bShowAimCrosshair && Weapons[ActiveWeapon].bCorrectAim)
	{
		Canvas.DrawColor = CrosshairColor;
		Canvas.DrawColor.A = 255;
		Canvas.Style = ERenderStyle.STY_Alpha;

		Canvas.SetPos(Canvas.SizeX*0.5-CrosshairX, Canvas.SizeY*0.5-CrosshairY);
		Canvas.DrawTile(CrosshairTexture, CrosshairX*2.0+1, CrosshairY*2.0+1, 0.0, 0.0, CrosshairTexture.USize, CrosshairTexture.VSize);
	}

    PC = PlayerController(Controller);
	if (PC != None && !PC.bBehindView && HUDOverlay != None)
	{
        if (!Level.IsSoftwareRendering())
        {
    		CameraRotation = PC.Rotation;
    		SpecialCalcFirstPersonView(PC, ViewActor, CameraLocation, CameraRotation);
    		HUDOverlay.SetLocation(CameraLocation + (HUDOverlayOffset >> CameraRotation));
    		HUDOverlay.SetRotation(CameraRotation);
    		Canvas.DrawActor(HUDOverlay, false, false, FClamp(HUDOverlayFOV * (PC.DesiredFOV / PC.DefaultFOV), 1, 170));
    	}
	}
	else
        ActivateOverlay(False);
}

function PlayHit(float Damage, Pawn InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum)
{
	local int i;

	Super.PlayHit(Damage, InstigatedBy, HitLocation, damageType, Momentum);

	for (i = 0; i < WeaponPawns.length; i++)
		if (!WeaponPawns[i].bHasOwnHealth && WeaponPawns[i].Controller != None)
			WeaponPawns[i].Controller.NotifyTakeHit(InstigatedBy, HitLocation, Damage, damageType, Momentum);
}

function array<Vehicle> GetTurrets()
{
	return WeaponPawns;
}

simulated function PrecacheAnnouncer(AnnouncerVoice V, bool bRewardSounds)
{
	if (bRewardSounds && !bSoundsPrecached)
	{
		V.PrecacheSound('Pancake');
		V.PrecacheSound('Road_Kill');
		V.PrecacheSound('Vehicular_manslaughter');
		V.PrecacheSound('Hit_and_run');
		V.PrecacheSound('Car_jacked');
		V.PrecacheSound('Hijacked');
		V.PrecacheSound('RoadRampage');
		V.PrecacheSound('EagleEye');
		V.PrecacheSound('top_gun');
		V.PrecacheSound('DareDevil');
		bSoundsPrecached = true;
	}
}

static function StaticPrecache(LevelInfo L)
{
    local int i;

    for(i=0;i<Default.DriverWeapons.Length;i++)
        Default.DriverWeapons[i].WeaponClass.static.StaticPrecache(L);

    for(i=0;i<Default.PassengerWeapons.Length;i++)
        Default.PassengerWeapons[i].WeaponPawnClass.static.StaticPrecache(L);

	if (Default.DestroyedVehicleMesh != None)
		L.AddPrecacheStaticMesh(Default.DestroyedVehicleMesh);

	if (Default.HeadlightCoronaMaterial != None)
		L.AddPrecacheMaterial(Default.HeadLightCoronaMaterial);

	if (Default.HeadlightProjectorMaterial != None)
		L.AddPrecacheMaterial(Default.HeadLightProjectorMaterial);

	L.AddPrecacheMaterial( default.VehicleIcon.Material );

	L.AddPrecacheMaterial(Material'EmitterTextures.MultiFrame.LargeFlames');
	L.AddPrecacheMaterial(Material'EmitterTextures.MultiFrame.fire3');
	L.AddPrecacheMaterial(Texture'AW-2004Particles.Weapons.DustSmoke');
}

simulated function UpdatePrecacheStaticMeshes()
{
	super.UpdatePrecacheStaticMeshes();

	if ( DestroyedVehicleMesh != None )
		Level.AddPrecacheStaticMesh(DestroyedVehicleMesh);
}

simulated function UpdatePrecacheMaterials()
{
	if (HeadlightCoronaMaterial != None)
		Level.AddPrecacheMaterial(HeadLightCoronaMaterial);

	if (HeadlightProjectorMaterial != None)
		Level.AddPrecacheMaterial(HeadLightProjectorMaterial);

	Level.AddPrecacheMaterial(Material'EmitterTextures.MultiFrame.LargeFlames');
	Level.AddPrecacheMaterial(Material'EmitterTextures.MultiFrame.fire3');
	Level.AddPrecacheMaterial(Texture'AW-2004Particles.Weapons.DustSmoke');

	Level.AddPrecacheMaterial( VehicleIcon.Material );

	Super.UpdatePrecacheMaterials();
}

//  Add time to the reset timer if you are healing it.

function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
	if (ResetTime-Level.TimeSeconds<10.0)
		ResetTime = Level.TimeSeconds+10.0;

    return super.HealDamage(Amount, Healer, DamageType);
}

defaultproperties
{
     bHasAltFire=True
     ViewShakeRadius=100.000000
     DisintegrationHealth=-50.000000
     DestructionAngularMomentum=(Min=50.000000,Max=50.000000)
     TimeBetweenImpactExplosions=0.100000
     ExplosionSounds(0)=Sound'ONSVehicleSounds-S.Explosions.VehicleExplosion01'
     ExplosionSounds(1)=Sound'ONSVehicleSounds-S.Explosions.VehicleExplosion02'
     ExplosionSounds(2)=Sound'ONSVehicleSounds-S.Explosions.VehicleExplosion03'
     ExplosionSounds(3)=Sound'ONSVehicleSounds-S.Explosions.VehicleExplosion04'
     ExplosionSounds(4)=Sound'ONSVehicleSounds-S.Explosions.VehicleExplosion05'
     ExplosionSoundVolume=5.000000
     ExplosionSoundRadius=200.000000
     ExplosionDamage=100.000000
     ExplosionRadius=300.000000
     ExplosionMomentum=60000.000000
     ExplosionDamageType=Class'Onslaught.DamTypeONSVehicleExplosion'
     DestroyedRoadKillDamageType=Class'Onslaught.DamTypeDestroyedVehicleRoadKill'
     DamagedEffectClass=Class'Onslaught.ONSDamagedEffect'
     DamagedEffectScale=1.000000
     DamagedEffectHealthSmokeFactor=0.500000
     DamagedEffectHealthFireFactor=0.250000
     DamagedEffectAccScale=0.250000
     DamagedEffectFireDamagePerSec=0.750000
     bOnlyViewShakeIfDriven=True
     bEjectPassengersWhenFlipped=True
     ShakeRotMag=(Z=250.000000)
     ShakeRotRate=(Z=2500.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(Z=10.000000)
     ShakeOffsetRate=(Z=200.000000)
     ShakeOffsetTime=10.000000
     ImpactDamageTicks=10.000000
     ImpactDamageThreshold=5000.000000
     ImpactDamageMult=0.000300
     ImpactDamageSounds(0)=Sound'ONSVehicleSounds-S.CollisionSounds.VehicleCollision01'
     ImpactDamageSounds(1)=Sound'ONSVehicleSounds-S.CollisionSounds.VehicleCollision02'
     ImpactDamageSounds(2)=Sound'ONSVehicleSounds-S.CollisionSounds.VehicleCollision03'
     ImpactDamageSounds(3)=Sound'ONSVehicleSounds-S.CollisionSounds.VehicleCollision04'
     ImpactDamageSounds(4)=Sound'ONSVehicleSounds-S.CollisionSounds.VehicleCollision05'
     ImpactDamageSounds(5)=Sound'ONSVehicleSounds-S.CollisionSounds.VehicleCollision06'
     ImpactDamageSounds(6)=Sound'ONSVehicleSounds-S.CollisionSounds.VehicleCollision07'
     SparkEffectClass=Class'Onslaught.ONSImpactSparks'
     SparkAdvanceFactor=1.500000
     LockedOnSound=Sound'WeaponSounds.BaseGunTech.BSeekLost1'
     MinRunOverWarningAim=0.880000
     CrossHairColor=(G=255,A=255)
     CrosshairX=32.000000
     CrosshairY=32.000000
     CrosshairTexture=Texture'ONSInterface-TX.tankBarrelAligned'
     bZeroPCRotOnEntry=False
     bTeamLocked=True
     bEnterringUnlocks=True
     Team=0
     TeamBeaconTexture=Texture'ONSInterface-TX.HealthBar'
     NoEntryTexture=Texture'HUDContent.Generic.NoEntry'
     TeamBeaconBorderMaterial=Texture'InterfaceContent.Menu.BorderBoxD'
     RanOverDamageType=Class'Onslaught.DamTypeRoadkill'
     CrushedDamageType=Class'Onslaught.DamTypePancake'
     RanOverSound=Sound'ONSVehicleSounds-S.CollisionSounds.BodyHitbyVeh01'
     StolenAnnouncement="Hijacked"
     StolenSound=Sound'ONSVehicleSounds-S.CarAlarm.CarAlarm01'
     BulletSounds(0)=Sound'WeaponSounds.BaseShieldReflections.BBulletReflect1'
     BulletSounds(1)=Sound'WeaponSounds.BaseShieldReflections.BBulletReflect2'
     BulletSounds(2)=Sound'WeaponSounds.BaseShieldReflections.BBulletReflect3'
     BulletSounds(3)=Sound'WeaponSounds.BaseShieldReflections.BBulletReflect4'
     BulletSounds(4)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact1'
     BulletSounds(5)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact2'
     BulletSounds(6)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact3'
     BulletSounds(7)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact4'
     BulletSounds(8)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact5'
     BulletSounds(9)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact6'
     BulletSounds(10)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact7'
     BulletSounds(11)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact8'
     BulletSounds(12)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact9'
     BulletSounds(13)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact11'
     BulletSounds(14)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact12'
     BulletSounds(15)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact13'
     BulletSounds(16)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact14'
     WaterDamage=150.000000
     VehicleDrowningDamType=Class'Gameplay.Drowned'
     SpawnOverlay(0)=Shader'XGameShaders.PlayerShaders.VehicleSpawnShaderRed'
     SpawnOverlay(1)=Shader'XGameShaders.PlayerShaders.VehicleSpawnShaderBlue'
     VehicleIcon=(Material=Texture'AS_FX_TX.HUD.TrackedVehicleIcon',SizeX=64.000000,SizeY=64.000000)
     bSpecialHUD=True
     bSetPCRotOnPossess=False
     bCanTeleport=False
     SoundRadius=200.000000
     TransientSoundRadius=600.000000
}
