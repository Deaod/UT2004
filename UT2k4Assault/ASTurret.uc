//=============================================================================
// ASTurret
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class ASTurret extends ASVehicle
		abstract;

// Static base
var		class<ASTurret_Base>	TurretBaseClass;
var		ASTurret_Base			TurretBase;
var		Rotator					OriginalRotation;

// Swivel (follows Turret's rotation Yaw only)
var		class<ASTurret_Base>	TurretSwivelClass;
var		ASTurret_Base			TurretSwivel;

// Movement
var float		YawAccel, PitchAccel;

var()	const	float	RotationInertia;
var()	const	Range	RotPitchConstraint;		// Min=0d,-90d  Max=0d,+90d  16384=0d 0=90d
var()	const	float	RotationSpeed;
var()			vector  CamAbsLocation, CamRelLocation, CamDistance;

// Camera
var		Rotator		LastCamRot;
var		float		LastTimeSeconds;
var()	float		CamRotationInertia;

// Zooming
var		bool 		bZooming;
var()	float		DesiredPlayerFOV, MinPlayerFOV, OldFOV, ZoomSpeed, ZoomWeaponOffsetAdjust;
var		material	ZoomTick, ZoomTickTex;

var Texture		WeaponInfoTexture;

var() name ObjectiveTag[6];

var		array<SVehicleTrigger>	EntryTriggers;

replication
{
	reliable if ( bNetInitial && Role==ROLE_Authority)
		OriginalRotation;

	reliable if ( Role<ROLE_Authority)
		ServerSwitchTurret;
}


function bool RecommendLongRangedAttack()
{
	return true;
}

function bool StronglyRecommended(Actor S, int TeamIndex, Actor Objective)
{
	local int i;

	if ( Objective != None )
	{
		if ( ObjectiveTag[0] != '' )
		{
			for ( i=0; i<6; i++ )
			{
				if ( ObjectiveTag[i] == '' )
					return false;
				else if ( ObjectiveTag[i] == Objective.Tag )
					return true;
			}
		}
		else if ( (VSize(Objective.Location - Location) > 8000) || !FastTrace(Objective.Location, Location) )
				return false;
	}
	return true;
}

function float BotDesireability(Actor S, int TeamIndex, Actor Objective)
{
	if ( !StronglyRecommended(S, TeamIndex, Objective) )
		return 0;
	else if (Health <= 0 || Occupied() || (bTeamLocked && GetTeamNum() != TeamIndex))
		return 0;

	return ((MaxDesireability * 0.5) + (MaxDesireability * 0.5 * (float(Health) / HealthMax)));
}

simulated function PrevWeapon()
{
	ServerSwitchTurret( false );
}

simulated function NextWeapon()
{
	ServerSwitchTurret( true );
}

function ServerSwitchTurret( bool bNextTurret )
{
	if ( ASVehicleFactory_Turret(ParentFactory) == None )
		return;

	if ( bNextTurret )
		ASVehicleFactory_Turret(ParentFactory).NextVehicle( Self );
	else
		ASVehicleFactory_Turret(ParentFactory).PrevVehicle( Self );
}

simulated event PostBeginPlay()
{
	if ( Role == Role_Authority )
		OriginalRotation = Rotation;	// Save original Rotation to place client versions well...

	super.PostBeginPlay();
}

function PossessedBy(Controller C)
{
	local PlayerController PC;

	super.PossessedBy(C);

	PC = PlayerController(C);
	if ( PC != None )
		PC.SetFOV( PC.DefaultFOV );
}

simulated event PostNetBeginPlay()
{
	// Static (non rotating) base
	if ( TurretBaseClass != None )
		TurretBase = Spawn(TurretBaseClass, Self,, Location, OriginalRotation);

	// Swivel, rotates left/right (Yaw)
	if ( TurretSwivelClass != None )
		TurretSwivel = Spawn(TurretSwivelClass, Self,, Location, OriginalRotation);

	super.PostNetBeginPlay();
}

simulated function bool HasAmmo()
{
	return true;
}

simulated event Destroyed()
{
	if ( TurretBase != None )
		TurretBase.Destroy();

	if ( TurretSwivel != None )
		TurretSwivel.Destroy();

	super.Destroyed();
}


simulated function UpdateRocketAcceleration(float DeltaTime, float YawChange, float PitchChange)
{
	local int		Pitch;
	local rotator	NewRotation;

	if ( PlayerController(Controller) != None && PlayerController(Controller).bFreeCamera )
	{
		PlayerController(Controller).UpdateRotation( DeltaTime, 0);
		return;
	}

	// Make sure Delta is not too big...
	if ( DeltaTime > 0.3 )
		DeltaTime = 0.3;

	YawAccel	= RotationInertia*YawAccel + DeltaTime*RotationSpeed*YawChange;
	PitchAccel	= RotationInertia*PitchAccel + DeltaTime*RotationSpeed*PitchChange;

	Pitch		= Rotation.Pitch & 65535;

	// Pitch constraint
	if ( (Pitch > 16384 - RotPitchConstraint.Max) && (Pitch < 49152 + RotPitchConstraint.Min) )
	{
		if ( Pitch > 49152 - RotPitchConstraint.Min )
			PitchAccel = Max(PitchAccel,0);
		else if ( Pitch < 16384 + RotPitchConstraint.Max )
			PitchAccel = Min(PitchAccel,0);
	}

	NewRotation			= Rotation;
	NewRotation.Yaw	   += YawAccel;
	NewRotation.Pitch  += PitchAccel;

	SetRotation( NewRotation );

	if ( IsLocallyControlled() )
	{
		if ( TurretBase != None && TurretBase.DrawType == DT_Mesh  )
			TurretBase.UpdateOverlay();

		if ( TurretSwivel != None )
		{
			if ( TurretSwivel.DrawType == DT_Mesh )
				TurretSwivel.UpdateOverlay();
			TurretSwivel.UpdateSwivelRotation( NewRotation );
		}
	}
}


// Special calc-view for vehicles
simulated function bool SpecialCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local vector			CamLookAt, HitLocation, HitNormal;
	local PlayerController	PC;
	local float				DeltaTime;
	local Rotator			CamRotationRate;

	PC = PlayerController(Controller);

	// Only do this mode if we have a playercontroller viewing this vehicle
	if ( PC == None || PC.ViewTarget != self || PC.bFreeCamera )
		return false;

	ViewActor = Self;

	if ( !PC.bBehindView )	// First Person View
	{
		SpecialCalcFirstPersonView( PC, ViewActor, CameraLocation, CameraRotation);
		return true;
	}

	// 3rd person view
	DeltaTime			= Level.TimeSeconds - LastTimeSeconds;
	LastTimeSeconds		= Level.TimeSeconds;

	CamLookAt			= Location + CamAbsLocation + (CamRelLocation >> ViewActor.Rotation);

	// Camera Rotation
	CamRotationRate			= Normalize(ViewActor.Rotation - LastCamRot);
	CameraRotation.Yaw		= CalcInertia(DeltaTime, CamRotationInertia, CamRotationRate.Yaw, LastCamRot.Yaw);
	CameraRotation.Pitch	= CalcInertia(DeltaTime, CamRotationInertia, CamRotationRate.Pitch, LastCamRot.Pitch);
	CameraRotation.Roll		= 0;
	LastCamRot				= CameraRotation;

	CameraLocation	= CamLookAt + (CamDistance >> CameraRotation);

	if ( Trace( HitLocation, HitNormal, CameraLocation, CamLookAt, false, vect(10, 10, 10) ) != None )
		CameraLocation = HitLocation + HitNormal * 10;

	return true;
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

simulated function rotator GetViewRotation()
{
	return Rotation;
}

simulated function PlayFiring(optional float Rate, optional name FiringMode )
{
	if ( FiringMode == '0' )
		PlayAnim('FireR', 0.45);
	else
		PlayAnim('FireL', 0.45);
}


// Spawn Explosion FX
simulated function Explode( vector HitLocation, vector HitNormal )
{
	super.Explode( HitLocation, Vect(0,0,1) ); // Overriding Explosion direction

	if ( TurretBase != None )
		TurretBase.Destroy();

	if ( TurretSwivel != None )
		TurretSwivel.Destroy();
}


simulated function DrawHealthInfo( Canvas C, PlayerController PC )
{
	class'HUD_Assault'.static.DrawCustomHealthInfo( C, PC, true );
}

simulated function Actor PerformTrace( out vector HitLocation, out Vector HitNormal, vector End, vector Start )
{
	local Actor	HitActor;

	// Disable base and swivel collision
	if ( TurretBase != None )
		TurretBase.bBlockZeroExtentTraces = false;

	if ( TurretSwivel != None )
		TurretSwivel.bBlockZeroExtentTraces = false;

	HitActor = super.PerformTrace(HitLocation, HitNormal, End, Start );

	if ( TurretBase != None )
		TurretBase.bBlockZeroExtentTraces = true;

	if ( TurretSwivel != None )
		TurretSwivel.bBlockZeroExtentTraces = true;

	return HitActor;
}

simulated function bool DrawCrosshair( Canvas C, out vector ScreenPos )
{
	local float		RatioX, RatioY;
	local float		tileX, tileY;
	local float		SizeX, SizeY;

	local float		ZoomPct;
    local playercontroller pc;

	super.DrawCrosshair( C, ScreenPos );

	PC = PlayerController(Controller);

	SizeX = ZoomTickTex.MaterialUSize();
	SizeY = ZoomTickTex.MaterialVSize();

	RatioX = C.SizeX / 640.0;
	RatioY = C.SizeY / 480.0;

	tileX = CrosshairScale * SizeX * RatioX;
	tileY = CrosshairScale * SizeY * RatioX;

	C.Style = ERenderStyle.STY_Additive;
	C.DrawColor = class'Canvas'.static.MakeColor(255, 255, 255);

	C.SetPos( ScreenPos.X - tileX, ScreenPos.Y - tileY );
	C.DrawTile( ZoomTickTex, tileX*2,tileY*2, 0.0, 0.0, SizeX, SizeY);
	ZoomPct = 1-(PC.FOVAngle-MinPlayerFOV) / (PC.DefaultFOV - MinPlayerFOV);

	C.SetPos( ScreenPos.X - tileX, ScreenPos.Y - tileY );
    TexRotator(ZoomTick).Rotation.Yaw = 32767 * ZoomPct;
	C.DrawTile( ZoomTick, tileX*2,tileY*2, 0.0, 0.0, SizeX, SizeY);

	PostZoomAdjust( ZoomPct );

	return true;
}

simulated function PostZoomAdjust( float ZoomPct )
{
	// Fudge the weapon effects so they look right
    if ( !bDrawMeshInFP && Weapon != None )
		Weapon.SmallViewOffset.X = Weapon.default.SmallViewOffset.X - (ZoomWeaponOffsetAdjust * ZoomPct);
}


simulated function RawInput(float DeltaTime,
							float aBaseX, float aBaseY, float aBaseZ, float aMouseX, float aMouseY,
							float aForward, float aTurn, float aStrafe, float aUp, float aLookUp)
{
	local playerController	PC;
    local float				NewFOV;

	if ( PlayerController(Controller) != None )
    {
		PC = PlayerController(Controller);
	    if ( aForward!=0 )
	    {
        	bZooming = true;

	        if ( aForward>0 )
            {
            	if ( PC.FOVAngle > MinPlayerFOV )
                	NewFOV = PC.FOVAngle - ((PC.DefaultFOV - MinPlayerFOV)*DeltaTime*ZoomSpeed);
				else
                	NewFOV = MinPlayerFOV;
            }
            else
            {
            	if ( PC.FOVAngle < PC.DefaultFOV )
                	NewFOV = PC.FOVAngle + ((PC.DefaultFOV - MinPlayerFOV)*DeltaTime*ZoomSpeed);
                else
                	NewFOV = PC.DefaultFOV;
            }
	    }
        else
        	bZooming = false;

        if ( bZooming )
            PC.SetFOV( FClamp(NewFOV, MinPlayerFOV, PC.DefaultFOV)  );

		if ( OldFOV == 0 )
			OldFOV = PC.FOVAngle;

		if ( OldFOV != PC.FOVAngle )
			PlaySound(Sound'WeaponSounds.LightningGun.LightningZoomIn', SLOT_Misc,,,,,false);

		OldFOV = PC.FOVAngle;
    }

    super.RawInput(DeltaTime, aBaseX, aBaseY, aBaseZ, aMouseX, aMouseY, aForward, aTurn, aStrafe, aUp, aLookUp);
}

simulated function ClientKDriverEnter( PlayerController PC )
{
	OldFOV = PC.FOVAngle;
	super.ClientKDriverEnter( PC );
}

static function StaticPrecache(LevelInfo L)
{
    super.StaticPrecache( L );

	L.AddPrecacheMaterial( default.ZoomTick );
	L.AddPrecacheMaterial( default.ZoomTickTex );
}

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial( default.ZoomTick );
	Level.AddPrecacheMaterial( default.ZoomTickTex );

	super.UpdatePrecacheMaterials();
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     RotationInertia=0.200000
     RotPitchConstraint=(Min=12288.000000,Max=4096.000000)
     RotationSpeed=16.000000
     CamAbsLocation=(Z=100.000000)
     CamRelLocation=(X=200.000000,Z=100.000000)
     CamDistance=(X=-800.000000,Z=100.000000)
     CamRotationInertia=0.000010
     MinPlayerFOV=20.000000
     ZoomSpeed=1.500000
     ZoomWeaponOffsetAdjust=80.000000
     ZoomTick=TexRotator'Turrets.Huds.LinkZoomTickRot'
     ZoomTickTex=Texture'Turrets.Huds.LinkZoomTickBar'
     VehicleProjSpawnOffset=(X=138.000000,Y=-65.000000,Z=16.000000)
     DefaultCrosshair=Texture'Crosshairs.HUD.Crosshair_Circle1'
     CrosshairScale=0.500000
     bCHZeroYOffset=True
     bDefensive=True
     bAutoTurret=True
     bRemoteControlled=True
     AutoTurretControllerClass=Class'UnrealGame.TurretController'
     FPCamPos=(Z=40.000000)
     VehiclePositionString="manning a turret"
     VehicleNameString="Energy Turret"
     bSimulateGravity=False
     bIgnoreForces=True
     bStationary=True
     bSpecialHUD=True
     bSpecialCalcView=True
     SightRadius=25000.000000
     WaterSpeed=0.000000
     AirSpeed=0.000000
     AccelRate=0.000000
     JumpZ=0.000000
     MaxFallSpeed=0.000000
     HealthMax=650.000000
     Health=650
     LandMovementState="PlayerTurreting"
     bIgnoreEncroachers=True
     Physics=PHYS_Rotating
     DrawScale=5.000000
     AmbientGlow=64
     bShouldBaseAtStartup=False
     CollisionRadius=80.000000
     CollisionHeight=80.000000
     bCollideWorld=False
     bPathColliding=True
}
