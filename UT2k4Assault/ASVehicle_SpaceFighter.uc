//=============================================================================
// ASVehicle_SpaceFighter
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class ASVehicle_SpaceFighter extends ASVehicle
	abstract
	config(User);

// Movement
var				Quat	SpaceFighterRotation;	// Space Fighter actual rotation (using quaternions instead of rotators)
var				float	YawAccel, PitchAccel, RollAccel;
var				float	DesiredVelocity;		// Range: EngineMinVelocity -> 1000
var()	const	float	EngineMinVelocity;		// minimum forward velocity
var()	const	float	VehicleRotationSpeed;
var()	const	float	RotationInertia;
var()			float   StrafeAccel, StrafeAccelRate, MaxStrafe;
var()			float   RollAutoCorrectSpeed;


var				bool	bInitialized;			// this to catch first tick when match is started and velocity reset (so ship would always have a rotation==(0,0,0))
var				bool	bPostNetCalled;
var				bool	bGearUp;				// Once flying animation is played
var				bool	bSpeedFilterWarmup;
var				bool	bAutoTarget;			// automatically target closest Vehicle
var				bool	bTargetClosestToCrosshair;
var				bool	bRocketLoaded;
var				bool	bHumanShip;

var				Rotator ShotDownRotation;
var				int		TopGunCount;

var	name FlyingAnim;

// Camera
var Rotator		LastCamRot;
var	float		myDeltaTime;
var	float		LastTimeSeconds;
var	float		CamRotationInertia;

// HUD
var				string		DelayedDebugString;
var localized	string		Text_Speed;

// FX
var	Emitter		TrailEmitter;
var	float		TrailOffset;

var	Emitter		SmokeTrail;
var class<Emitter> ShotDownFXClass;

// Engine Speed smooth filter (for velocity jerkyness on low and jerky FPS)
const			SpeedFilterFrames = 20;
var		float	SpeedFilter[SpeedFilterFrames];
var		int		NextSpeedFilterSlot;
var		float	SmoothedSpeedRatio;

// Rockets
var		Vector	RocketOffset;

// Shield effect actors
var	class<Actor>	GenericShieldEffect[2];
var	float			NextShieldTime;

// Target locking
var	Vehicle		CurrentTarget;
var	float		MaxTargetingRange;
var	float		LastAutoTargetTime;
var	Vector		CrosshairPos;
var Sound		TargetAcquiredSound;

var Texture		WeaponInfoTexture, SpeedInfoTexture;

var Sound	RocketLoadedSound;

replication
{
	reliable if ( bNetDirty && bNetOwner && Role==ROLE_Authority )
		CurrentTarget;

	reliable if ( Role < ROLE_Authority )
		ServerPrevTarget, ServerNextTarget, ServerSetTarget;
}


function BlowUp( vector HitNormal );		// Blow up space ship

simulated function PostNetBeginPlay()
{
	super.PostNetBeginPlay();

	bPostNetCalled = true;
	PlayTakeOff();

	if ( ASGameInfo(Level.Game) != None )
		bThumped = ASGameInfo(Level.Game).DivertSpaceFighter();
}

simulated function PlayTakeOff();


simulated event TeamChanged()
{
	// Add Trail FX
	if ( Level.NetMode != NM_DedicatedServer )
	{
		SetTrailFX();
		AdjustFX();
	}
}

simulated function SetTrailFX();

simulated function Destroyed()
{
	if ( TrailEmitter != None )
		TrailEmitter.Destroy();

	if ( SmokeTrail != None )
		SmokeTrail.Destroy();

	super.Destroyed();
}


function PossessedBy(Controller C)
{
	super.PossessedBy(C);

	// Don't start at full speed
	Velocity = EngineMinVelocity * Vector(Rotation);
    Acceleration = Velocity;
}

function vector GetBotError(vector StartLocation)
{
	local vector ErrorDir, VelDir;

	Controller.ShotTarget = Pawn(Controller.Target);
	ErrorDir = Normal((Controller.Target.Location - Location) Cross vect(0,0,1));
	if ( Controller.Target != OldTarget )
	{
		BotError = (1500 - 100 * Level.Game.GameDifficulty) * ErrorDir;
		OldTarget = Controller.Target;
	}
	VelDir = Normal(Controller.Target.Velocity);
	BotError += (100 - 200 *FRand()) * (ErrorDir + VelDir);
	if ( (Level.Game.GameDifficulty < 6) && (VSize(BotError) < 120) )
	{
		if ( (BotError Dot VelDir) < 0 )
			BotError += 10 * VelDir;
		else
			BotError -= 10 * VelDir;
	}
	if ( (Pawn(OldTarget) != None) && Pawn(OldTarget).bStationary )
		BotError *= 0.6;
	BotError = Normal(BotError) * FMin(VSize(BotError), FMin(1500 - 100*Level.Game.GameDifficulty,0.2 * VSize(Controller.Target.Location - StartLocation)));

	return BotError;
}

simulated function ClientKDriverEnter(PlayerController PC)
{
	super.ClientKDriverEnter( PC );

	// Don't start at full speed
	Velocity = EngineMinVelocity * Vector(Rotation);
    Acceleration = Velocity;
}

// Called from the PlayerController when player wants to get out.
function bool KDriverLeave( bool bForceLeave )
{
	if ( bForceLeave )	// Hack so you can't exit SpaceFighters with the "Use" Key.
	{
		if ( super.KDriverLeave( bForceLeave ) )
		{
			if ( !bDeleteMe && !IsInState('Dying') )
				Destroy();
		}
		else return false;
	}
	else
	{
		TargetUnSet();
		return false;
	}
}

function DriverDied()
{
	TakeDamage(default.Health*2, Self, Location, vect(0,0,0), None);
}

// return false if out of range, can't see target, etc.
function bool CanAttack(Actor Other)
{
    // check that can see target
    if ( Controller != None )
		return Controller.LineOfSightTo(Other);
    return false;
}

//=============================================================================
// Movement
//=============================================================================

simulated function UpdateRocketAcceleration(float DeltaTime, float YawChange, float PitchChange)
{
	local vector	X,Y,Z;
	local float		CurrentSpeed;
	local float		EngineAccel;
	local float		RotationSmoothFactor;
	local float		RollChange;
	local Rotator	NewRotation;

	if ( !bPostNetCalled || Controller == None )
		return;

	if ( !bInitialized  )
	{
		// Laurent -- Velocity Override
		// When Player Spawns with the spaceship as Pawn, velocity is reset at start match
		// since Rotation is overwritten later by Rotator(Velocity), it gets reset to Rotation(0,0,0)
		// And therefore not using the one set in PlayerStart.Rotation
		Acceleration = EngineMinVelocity * Vector(Rotation);
		SpaceFighterRotation = QuatFromRotator( Rotation );
		bInitialized = true;
	}

	// Only allow space fighter to change gear once landing gear is up.
	// (small hack for fins animations)
	if ( bGearUp )
		DesiredVelocity	= FClamp( DesiredVelocity+PlayerController(Controller).aForward*DeltaTime/15.f,
								EngineMinVelocity, 1000.f);
	else
		DesiredVelocity	= EngineMinVelocity;

	CurrentSpeed	= FClamp( (Velocity Dot Vector(Rotation)) * 1000.f / AirSpeed, 0.f, 1000.f);
	EngineAccel		= (DesiredVelocity - CurrentSpeed) * 100.f;

	RotationSmoothFactor = FClamp(1.f - RotationInertia * DeltaTime, 0.f, 1.f);

	if ( PlayerController(Controller).bDuck > 0 && Abs(Rotation.Roll) > 500 )
	{
		// Auto Correct Roll
		if ( Rotation.Roll < 0 )
			RollChange = RollAutoCorrectSpeed;
		else
			RollChange = -RollAutoCorrectSpeed;
	}
  	else if ( PlayerController(Controller).aUp > 0 ) // Rolling
  		RollChange = PlayerController(Controller).aStrafe * 0.66;

	// Rotation Acceleration
	YawAccel	= RotationSmoothFactor*YawAccel   + DeltaTime*VehicleRotationSpeed*YawChange;
	PitchAccel	= RotationSmoothFactor*PitchAccel + DeltaTime*VehicleRotationSpeed*PitchChange;
	RollAccel	= RotationSmoothFactor*RollAccel  + DeltaTime*VehicleRotationSpeed*RollChange;

	YawAccel	= FClamp( YawAccel, -AirSpeed, AirSpeed );
	PitchAccel	= FClamp( PitchAccel, -AirSpeed, AirSpeed );
	RollAccel	= FClamp( RollAccel, -AirSpeed, AirSpeed );

	// Perform new rotation
	GetAxes( QuatToRotator(SpaceFighterRotation), X, Y, Z );
	SpaceFighterRotation = QuatProduct(SpaceFighterRotation,
								QuatProduct(QuatFromAxisAndAngle(Y, DeltaTime*PitchAccel),
								QuatProduct(QuatFromAxisAndAngle(Z, -1.0 * DeltaTime * YawAccel),
								QuatFromAxisAndAngle(X, DeltaTime * RollAccel))));

	NewRotation = QuatToRotator( SpaceFighterRotation );

	// If autoadjusting roll, clamp to 0
	if ( PlayerController(Controller).bDuck > 0 && ((NewRotation.Roll < 0 && Rotation.Roll > 0) || (NewRotation.Roll > 0 && Rotation.Roll < 0)) )
	{
		NewRotation.Roll = 0;
		RollAccel = 0;
	}

	Acceleration = Vector(NewRotation) * DesiredVelocity;

	// strafing
	StrafeAccel	= RotationSmoothFactor*StrafeAccel;
	if ( PlayerController(Controller).aUp == 0 )
		StrafeAccel	+= DeltaTime*StrafeAccelRate*PlayerController(Controller).aStrafe;
	StrafeAccel = FClamp( StrafeAccel, -MaxStrafe, MaxStrafe);
	GetAxes( NewRotation, X, Y, Z );
	Acceleration += StrafeAccel * Y;

	// Adjust Rolling based on Stafing
	NewRotation.Roll += StrafeAccel * 15;
	DelayedDebugString = "NewRotation.Roll:" @ NewRotation.Roll @ "StrafeAccel:" @ StrafeAccel;

	// Take complete control on Rotation
	bRotateToDesired	= true;
	bRollToDesired		= true;
	DesiredRotation		= NewRotation;
	SetRotation( NewRotation );
}

function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
{
	if ( Role == Role_Authority )
	{
		if ( !bPostNetCalled )
			return;

		UpdateAutoTargetting();

		// Hack when spacefighter gets stuck... kill!!
		if ( VSize(Velocity) < 100 )
			TakeDamage(default.Health*2, Self, Location, vect(0,0,0), None);
	}
}

function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local vector		X,Y,Z;
	local float			ForwardVelocity;
	local Controller	C;

	super.DisplayDebug(Canvas, YL, YPos);

	if ( Controller == None )
	{
		Canvas.SetDrawColor(255,0,0);
		Canvas.DrawText("LOCAL CONTROLLER");
		YPos += YL;
		Canvas.SetPos(4,YPos);

		C = Level.GetLocalPlayerController();
		C.DisplayDebug(Canvas,YL,YPos);
	}

	Canvas.DrawText("-- SPACEFIGHTER");
	YPos += YL;
	Canvas.SetPos(4,YPos);

	GetAxes(Rotation, X, Y, Z);
	Canvas.DrawText("-- GetAxes, X:"@String(X)$", Y:"@String(Y)$", Z:"@String(Z));
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("-- Acceleration:"@String(Acceleration));
	YPos += YL;
	Canvas.SetPos(4,YPos);

	// Debug stuffs
	ForwardVelocity = Velocity Dot Vector(Rotation);
	Canvas.DrawText("-- Gear:"@DesiredVelocity/10.0$"% Forward Velocity:"@String(ForwardVelocity));
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("-- DDS"@DelayedDebugString);
	YPos += YL;
	Canvas.SetPos(4,YPos);
}

simulated function rotator GetViewRotation()
{
	if ( IsLocallyControlled() && Health > 0 )
		return QuatToRotator(SpaceFighterRotation);	// true rotation
	else
		return Rotation;
}

simulated function SpecialCalcFirstPersonView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
    local vector	x, y, z;
	local rotator	R;

	CameraLocation = Location;
	ViewActor	= Self;
	R			= GetViewRotation();
    GetAxes(R, x, y, z);

    // First-person view.
    CameraRotation = Normalize(R + PC.ShakeRot); // amb
    CameraLocation = CameraLocation +
                     PC.ShakeOffset.X * x +
                     PC.ShakeOffset.Y * y +
                     PC.ShakeOffset.Z * z;

	// Camera position is locked to vehicle
	CameraLocation = CameraLocation + (FPCamPos >> GetViewRotation());
}

// Special calc-view for vehicles
simulated function bool SpecialCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local vector			CamLookAt, HitLocation, HitNormal;
	local PlayerController	PC;
	local float				CamDistFactor;
	local vector			CamDistance;
	local Rotator			CamRotationRate;
	local Rotator			TargetRotation;

	PC = PlayerController(Controller);

	// Only do this mode if we have a playercontroller viewing this vehicle
	if ( PC == None || PC.ViewTarget == None )
		return false;

	ViewActor = Self;

	if ( !PC.bBehindView )	// First Person View
	{
		SpecialCalcFirstPersonView( PC, ViewActor, CameraLocation, CameraRotation);
		return true;
	}

	// 3rd person view
	myDeltaTime			= Level.TimeSeconds - LastTimeSeconds;
	LastTimeSeconds		= Level.TimeSeconds;
	CamLookAt			= ViewActor.Location + (Vect(60, 0, 0) >> ViewActor.Rotation);

	// Camera Rotation
	if ( ViewActor == Self ) // Client Hack to camera roll is not affected by strafing
		TargetRotation = GetViewRotation();
	else
		TargetRotation = ViewActor.Rotation;

	if ( IsInState('ShotDown') )		// shotdown
	{
		TargetRotation.Yaw += 32768;
		Normalize( TargetRotation );
		CamRotationInertia = default.CamRotationInertia * 10.f;
		CamDistFactor	= 2.0;

	}
	else if ( IsInState('Dying') )	// dead
	{
		CamRotationInertia = default.CamRotationInertia * 50.f;
		CamDistFactor	= 3.0;
	}
	else
	{
		CamDistFactor	= 1 - (DesiredVelocity / AirSpeed);
	}

	CamRotationRate			= Normalize(TargetRotation - LastCamRot);
	CameraRotation.Yaw		= CalcInertia(myDeltaTime, CamRotationInertia, CamRotationRate.Yaw, LastCamRot.Yaw);
	CameraRotation.Pitch	= CalcInertia(myDeltaTime, CamRotationInertia, CamRotationRate.Pitch, LastCamRot.Pitch);
	CameraRotation.Roll		= CalcInertia(myDeltaTime, CamRotationInertia, CamRotationRate.Roll, LastCamRot.Roll);
	LastCamRot				= CameraRotation;

	// Camera Location
	CamDistance		= Vect(-180, 0, 80);
	CamDistance.X	-= CamDistFactor * 200.0;	// Adjust Camera location based on ship's velocity
	CameraLocation	= CamLookAt + (CamDistance >> CameraRotation);

	if ( Trace( HitLocation, HitNormal, CameraLocation, ViewActor.Location, false, vect(10, 10, 10) ) != None )
		CameraLocation = HitLocation + HitNormal * 10;

	return true;
}


//
// Targeting
//

simulated function bool IsTargetRelevant( Vehicle Target )
{
	if ( Target == None )
		return false;

	if ( Target.Team == Team || Target.Health < 1 || Target.bDeleteMe
		|| VSize(Location - Target.Location) > MaxTargetingRange )
		return false;

	// Target is located behind spacefighter
	if ( (Target.Location - Location) Dot vector(Rotation) < 0 )
		return false;

	return true;
}

simulated function PrevWeapon()
{
	ServerPrevTarget( false );
}

simulated function NextWeapon()
{
	ServerNextTarget( false );
}

exec function TargetClosestToCrosshair()
{
	bTargetClosestToCrosshair = true;	//Flag it to be done next time we have a Canvas
}

function ServerNextTarget( bool bTryOnce )
{
	local float			CurrentTargetDist, BestDist, Dist;
	local Controller	C;
	local Vehicle		V, BestV;
	local int			numtargets;

	BestDist = MaxTargetingRange;

	if ( !IsTargetRelevant( CurrentTarget ) )
		CurrentTarget = None;

	if ( CurrentTarget != None )
		CurrentTargetDist = VSize(Location - CurrentTarget.Location);
	else
		CurrentTargetDist = 0;

	for (C = Level.ControllerList; C != None; C = C.NextController)
	{
		V = Vehicle(C.Pawn);

		if ( V != None && V != CurrentTarget && IsTargetRelevant( V ) )
		{
			Dist = VSize(Location - V.Location);

			numtargets++;
			if ( Dist > CurrentTargetDist && Dist < BestDist && LineOfSightTo( V ) )
			{
				BestV		= V;
				BestDist	= Dist;
			}
		}
	}

	if ( BestV != None )
		ServerSetTarget( BestV );
	else if ( !bTryOnce && CurrentTarget != None && numtargets>0 )
	{
		CurrentTarget = None;
		ServerNextTarget( true );
	}
}

function ServerPrevTarget( bool bTryOnce )
{
	local float			CurrentTargetDist, BestDist, Dist;
	local Controller	C;
	local Vehicle		V, BestV;
	local int			numtargets;

	if ( !IsTargetRelevant( CurrentTarget ) )
		CurrentTarget = None;

	if ( CurrentTarget != None )
		CurrentTargetDist = VSize(Location - CurrentTarget.Location);
	else
		CurrentTargetDist = MaxTargetingRange;

	for (C = Level.ControllerList; C != None; C = C.NextController)
	{
		V = Vehicle(C.Pawn);

		if ( V != None && V != CurrentTarget && IsTargetRelevant( V ) )
		{
			numtargets++;
			Dist = VSize(Location - V.Location);
			if ( Dist < CurrentTargetDist && Dist > BestDist && LineOfSightTo( V ) )
			{
				BestV		= V;
				BestDist	= Dist;
			}
		}
	}

	if ( BestV != None )
		ServerSetTarget( BestV );
	else if ( !bTryOnce && CurrentTarget != None && numtargets>0 )
	{
		CurrentTarget = None;
		ServerPrevTarget( true );
	}
}

/* Acquired a new Target */
function ServerSetTarget(Vehicle NewTarget)
{
	if ( PlayerController(Controller) != None )
		PlayerController(Controller).ClientPlaySound( TargetAcquiredSound );

	CurrentTarget = NewTarget;
	bAutoTarget = false;
}

/* Erase current target, and turns on auto targetting */
function TargetUnSet()
{
	CurrentTarget	= None;
	bAutoTarget		= true;
}

/* Lock closest visible enemy */
function UpdateAutoTargetting()
{
	local float			BestDist, Dist;
	local Controller	C;
	local Vehicle		V, BestV;

	if ( Role != ROLE_Authority )
		return;

	// If player chosen target destroyed, begin autotargeting again
	if ( CurrentTarget == None || CurrentTarget.Health < 1 || CurrentTarget.bDeleteMe
		|| VSize(CurrentTarget.Location - Location) > MaxTargetingRange )
	{
		if ( CurrentTarget != None )
		{
			PlayerController(Controller).ClientPlaySound( LockedOnSound );
			CurrentTarget	= None;
		}
		bAutoTarget		= true;
	}

	// Only check target once per second to save CPU
	if ( !bAutoTarget || LastAutoTargetTime + 1 > Level.TimeSeconds )
		return;

	LastAutoTargetTime = Level.TimeSeconds;

	if ( CurrentTarget == None )
		BestDist = MaxTargetingRange;
	else
		BestDist = VSize(Location - CurrentTarget.Location);

	// Automatically target closest visible enemy vehicle
	for (C = Level.ControllerList; C != None; C = C.NextController)
	{
		V = Vehicle(C.Pawn);
		if ( V != None && V != CurrentTarget && IsTargetRelevant( V ) )
		{
			Dist = VSize(Location - V.Location);
			if ( V.IsA('ASVehicle_SpaceFighter') ) // Target SpaceFighters first over turrets.
				Dist = Dist * 0.67;

			if ( (BestV == None || Dist < BestDist) && LineOfSightTo( V ) )
			{
				BestV		= V;
				BestDist	= Dist;
			}
		}
	}

	if ( BestV != None )
		ServerSetTarget( BestV );
}


//=============================================================================
// Collision
//=============================================================================

// dealing damage based on impact normal and vehicle velocity
simulated function VehicleCollision(Vector HitNormal, Actor Other)
{
	local float		Damage;
	local float		NormalSpeed;
	local Pawn		Inst;

	if ( Role < Role_Authority )
		return;

	NormalSpeed = Abs( Velocity Dot HitNormal );
	Damage		= (NormalSpeed-200) / 100.0;

	if ( Damage > 1.f )
	{
		Damage	    *= Damage;
		Inst		= Pawn(Other);

		// Force death with other Pawn's collision
		if ( Instigator != None )
			Damage += HealthMax;

		TakeDamage(Damage, Inst, Location-HitNormal*CollisionRadius, HitNormal*Damage*100.f, None);
	}
	else if ( VSize(Velocity) < 100 )
		TakeDamage(default.Health*2, Self, Location, vect(0,0,0), None);
}

simulated function Landed( vector HitNormal )
{
	VehicleCollision(HitNormal, None);
}

simulated function HitWall(vector HitNormal, actor Wall)
{
	VehicleCollision(HitNormal, Wall);
}

simulated singular function Touch(Actor Other)
{
	local Vector HitNormal;

	if ( Other!=None && !Other.IsA('Projectile') && Other.bBlockActors )
	{
		HitNormal = Normal(Location - Other.Location);
		VehicleCollision(HitNormal, Other);
	}
}

simulated function Bump( Actor Other )
{
	local Vector HitNormal;

	if ( Other != None && !Other.IsA('Projectile') && Other.bBlockActors )
	{
		HitNormal = Normal(Location - Other.Location);
		VehicleCollision(HitNormal, Other);
	}
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
	if ( bHumanShip && (Level.NetMode != NM_Client) )
	{
		if ( Level.NetMode == NM_Standalone )
		{
			if ( (InstigatedBy != None) && (InstigatedBy != self) && (!bThumped || InstigatedBy.bStationary)
				&& (PlayerController(Instigator.Controller) == None)
				&& (PlayerReplicationInfo != None) && (Level.GetLocalPlayerController().PlayerReplicationInfo.Team != PlayerReplicationInfo.Team) )
				Damage *= 0.3;
		}
		else if ( Deathmatch(Level.Game).bPlayersVsBots )
		{
			if ( (InstigatedBy != None) && (InstigatedBy != self)
				&& (PlayerController(Instigator.Controller) == None) )
				Damage *= 0.7;
		}
	}

	// Using HitFxTicker to play various client side deaths...
	if ( instigatedBy == None )
		HitFxTicker = 0; //TearOffDeath = Death_Geometry;	// geometry collision
	else if ( instigatedBy == Self )
		HitFxTicker = 1; //TearOffDeath = Death_Self;		// suicide
	else
		HitFxTicker = 2; //TearOffDeath = Death_Pawn;		// killed by player

	if ( Role == Role_Authority )
		DoShieldEffect(HitLocation, Normal(Location - HitLocation) );

	super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
}


//=============================================================================
// FX
//=============================================================================

function DoShieldEffect(vector HitLocation, vector HitNormal)
{
	local Actor ShieldEffect;

	if ( Team > 1 )
		return;

	if ( EffectIsRelevant(HitLocation, true) && NextShieldTime < Level.TimeSeconds )
	{
		NextShieldTime = Level.TimeSeconds + 0.1;
		ShieldEffect = Spawn(GenericShieldEffect[Team], Self,, HitLocation, rotator(-HitNormal));

		if ( ShieldEffect != None )
			ShieldEffect.SetBase( Self );
	}
}

event AnimEnd( int Channel )
{
	Disable('AnimEnd');
	bGearUp = true;

	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( HasAnim(FlyingAnim) )
			PlayAnim( FlyingAnim, 0.0001 );
		StopAnimating();
		Timer();	// Call Timer to adjust FX
	}
}

simulated function AdjustFX();

simulated function Timer()
{
	local float			NewTimerRate;

	// Adjust FX
	AdjustFX();

	// Update Frequency (for Super High details)
	if ( IsLocallyControlled() )
		NewTimerRate = 0.02;
	else if ( EffectIsRelevant(Location, false) ) // if this pawn is relevant to local player
		NewTimerRate = 0.04;
	else
		NewTimerRate = 0.08;		// Not relevant

	if ( Level.DetailMode == DM_High ) // High details
		NewTimerRate += 0.02;
	else if ( Level.DetailMode == DM_Low ) // Low details
		NewTimerRate += 0.04;

	SetTimer(NewTimerRate, false);
}


simulated function Vector GetRocketSpawnLocation()
{
	return RocketOffset;
}


simulated final function MyRandSpin(float spinRate)
{
	DesiredRotation		= RotRand(true);

	RotationRate.Yaw	= 0;
	RotationRate.Pitch	= Max( FRand()*SpinRate/8, SpinRate / 30 );
	RotationRate.Roll	= Max( FRand()*SpinRate, SpinRate / 8 );

	if ( FRand() > 0.5 )
		RotationRate.Pitch = -RotationRate.Pitch;

	if ( FRand() > 0.5 )
		RotationRate.Roll = -RotationRate.Roll;
}


// Spawn Explosion FX
simulated function Explode( vector HitLocation, vector HitNormal )
{
	if ( SmokeTrail != None )
	{
		SmokeTrail.Kill();
		SmokeTrail = None;
	}

	if ( TrailEmitter != None )
	{
		TrailEmitter.Kill();
		TrailEmitter = None;
	}

	bDynamicLight = false;
	LightType = LT_None;

	//if ( HitNormal != vect(0,0,0) )
	//	SetRotation( Rotator(-HitNormal) ); // Hack to position camera well..

	if ( Level.NetMode != NM_DedicatedServer )
		ExplosionEffect = Spawn(class'FX_SpaceFighter_Explosion', Self,, HitLocation, Rotation);
}


simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	local vector	HitNormal;

	if ( Level.Game != None )
		Level.Game.DiscardInventory( Self );

	// Make sure player controller is actually possessing the vehicle.. (since we forced it in ClientKDriverEnter)
	if ( PlayerController(Controller) != None && PlayerController(Controller).Pawn != Self )
		Controller = None;

	if ( PlayerController(Controller) != None )
	{
		PlayerController(Controller).SetViewTarget( Self );
		DestroyPrevController = Controller;
	}

	bCanTeleport = false;
	bReplicateMovement = false;
	bTearOff = true;
	bPlayedDeath = true;

	if ( HitFxTicker == 2 )
	{
		ShotDownRotation = Rotation;
		if ( Level.NetMode != NM_DedicatedServer )
		{
			SmokeTrail = Spawn(ShotDownFXClass, Self,, Location);
			if ( SmokeTrail != None )
				SmokeTrail.SetBase( Self );
		}
		GotoState('ShotDown');
	}
	else
	{
		if ( HitFxTicker == 0 )
			HitNormal = Normal( TearOffMomentum );	// Set Directional explosion based on HitNormal

		Explode( Location, HitNormal );

		GotoState('Dying');
	}
}


//
// Shot down in flames
//
state ShotDown
{
	ignores Trigger, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

	event ChangeAnimation() {}
	event StopPlayFiring() {}
	function PlayFiring(float Rate, name FiringMode) {}
	function PlayWeaponSwitch(Weapon NewWeapon) {}
	function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType) {}
	simulated function PlayNextAnimation() {}
	event FellOutOfWorld(eKillZType KillType) {	}
	function ReduceCylinder() { }
	function LandThump() {	}
	event AnimEnd(int Channel) {	}
	function LieStill() {}
	singular function BaseChange() {	}
	function Died(Controller Killer, class<DamageType> damageType, vector HitLocation) {}
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, class<DamageType> damageType) {}

	function VehicleSwitchView(bool bUpdating) {}
	function DriverDied();
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot);

	function UpdateRocketAcceleration(float DeltaTime, float YawChange, float PitchChange);

	simulated function Timer()
	{
		BlowUp( vect(0,0,0) );
	}

	simulated function VehicleCollision(Vector HitNormal, Actor Other)
	{
		BlowUp( HitNormal );
	}

	// Blow up Space Fighter
	simulated function BlowUp( vector HitNormal )
	{
		Explode( Location, HitNormal );
		GotoState('Dying');
	}

    simulated function BeginState()
	{
		local PlayerController	PC;

		// Set random spin rate...
		bRotateToDesired	= true;
		bRollToDesired		= true;
		MyRandSpin( 200000 );
		Acceleration.Z -= VSize(Velocity)*0.67;
		//SetPhysics( PHYS_Falling );

		PC = PlayerController(Controller);
		if ( PC != None && !PC.bBehindView )
			PC.bBehindView = true;// Force Behindview

		if ( Driver != None && bDrawDriverInTP )
			Destroyed_HandleDriver();

		if ( Controller != None )
			Controller.PawnDied( Self );
	}

	simulated function EndState()
	{
		AmbientSound	= None;
		bDynamicLight	= false;
		LightType		= LT_None;
	}

Begin:

	SetTimer(4.0, false);
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     EngineMinVelocity=600.000000
     VehicleRotationSpeed=0.009000
     RotationInertia=10.000000
     StrafeAccelRate=0.500000
     MaxStrafe=300.000000
     RollAutoCorrectSpeed=3000.000000
     bSpeedFilterWarmup=True
     bAutoTarget=True
     bHumanShip=True
     CamRotationInertia=0.330000
     Text_Speed="Speed:"
     TrailOffset=80.000000
     MaxTargetingRange=20000.000000
     TargetAcquiredSound=Sound'AssaultSounds.HumanShip.TargetCycle01'
     RocketLoadedSound=Sound'AssaultSounds.HumanShip.HnShipFireReadyl01'
     DefaultCrosshair=Texture'Crosshairs.HUD.Crosshair_Circle1'
     CrosshairScale=0.500000
     bCHZeroYOffset=True
     bHasRadar=True
     CenterSpringForce="SpringSpaceFighter"
     CenterSpringRangePitch=0
     CenterSpringRangeRoll=0
     DriverDamageMult=0.000000
     bCanFly=True
     bCanStrafe=True
     bSimulateGravity=False
     bDirectHitWall=True
     bServerMoveSetPawnRot=False
     bSpecialHUD=True
     bSpecialCalcView=True
     SightRadius=25000.000000
     AirSpeed=2000.000000
     AccelRate=2000.000000
     HealthMax=250.000000
     Health=250
     LandMovementState="PlayerSpaceFlying"
     MinFlySpeed=1100.000000
     MaxRotation=0.850000
     Physics=PHYS_Flying
     CollisionRadius=60.000000
     CollisionHeight=30.000000
     RotationRate=(Pitch=32768,Yaw=32768,Roll=32768)
     ForceType=FT_DragAlong
     ForceRadius=100.000000
     ForceScale=5.000000
}
