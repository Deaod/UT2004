//=============================================================================
// Vehicle
// this abstract base class contains gameplay and AI code for vehicles
//=============================================================================

class Vehicle extends Pawn
    native
    nativereplication
    abstract;

var globalconfig bool bVehicleShadows;	// Global config option for vehicle shadows

var             bool    bDriving;               // Vehicle is being driven
var             bool    bOldDriving;
var				bool	bDrawVehicleShadow;		// Vehicle Shadow
var (Vehicle)	bool	bDrawDriverInTP;		// Whether to draw the driver when in 3rd person mode.
var (Vehicle)	bool	bDriverCollideActors;	// if driver is drawn in vehicle, is Driver.bCollideActors true ?
var (Vehicle)	bool	bRelativeExitPos;		// relative vector to vehicle?

var		bool	bDefensive;				// should be used by defenders
var		bool	bAutoTurret;			// controlled by AI if no player controlling (FIXME Move to subclass)
var		bool	bRemoteControlled;		// destroying vehicle won't kill player
var		bool	bEjectDriver;			// If vehicle is destroyed, don't kill and eject driver(s)
var		bool	bTurnInPlace;			// whether vehicle can turn in place
var		bool	bFollowLookDir;			// used by AI to know that controller's rotation determines vehicle rotation
var		bool	bNonHumanControl;		// Cannot be controlled by humans
var		bool	bStalled;				// Vehicle is stalled (can't apply acceleration)
var     bool    bVehicleDestroyed;      // Vehicle has been destroyed (no more need to simulate special vehicle physics)
var     bool    bShowDamageOverlay;     // Vehicle should display the normal pawn damage overlay when hit by a weapon
var     bool    bDropDetail;            // Vehicle should reduce its detail level
var		bool	bNoFriendlyFire;		// FriendlyFire disabled for this vehicle
var     bool    bCanHover;              // Actor can hover above water
var		bool	bCanDoTrickJumps;		// AI hint

// Cameras
var (Vehicle) bool	bDrawMeshInFP;		// Whether to draw the vehicle mesh when in 1st person mode.
var (Vehicle) bool	bZeroPCRotOnEntry;	// If true, set camera rotation to zero on entering vehicle. If false, set it to the vehicle rotation.
var	bool	bPCRelativeFPRotation;		// In 1st person, PlayerController rotation is relative to vehicle rotation

var     bool    bWeaponisFiring;
var     bool    bWeaponisAltFiring;

var		bool	bTeamLocked;		// Team defines which players are allowed to enter the vehicle
var		bool	bEnterringUnlocks;	// Vehicle is unlocked when a player enterred it..
var	bool bCanFlip;
var	bool bAllowViewChange;
var	bool bAllowWeaponToss; //if the driver dies, will he toss his weapon?

var(Vehicle) bool	bHUDTrackVehicle;	// If true, Vehicle will tracked on HUD. (For Objectives in Assault)
var	bool bHasRadar;
var bool bHasHandbrake;					// hint for AI
var bool bScriptedRise;					// hint for AI
var bool bKeyVehicle;					// hint for AI
var bool bSeparateTurretFocus;			// hint for AI (for tank type turreted vehicles)

var() bool	bHighScoreKill;	// vehicle is considered important, and awards 5 points upon destruction.

var	bool	bAdjustDriversHead;	// rotate driver's head depending on view rotation
var bool	bEnemyLockedOn;
var config bool bDesiredBehindView;

var	bool bHideRemoteDriver; // If Set to true, the remote controlling driver will be hidden
var bool bShowChargingBar;
var bool bDriverHoldsFlag;
var bool bCanCarryFlag;

var bool bSpawnProtected;	// Cannot be destroyed by a player before its been possessed.

var() bool bFPNoZFromCameraPitch; // Ignore any vehicle-space Z due to FPCamViewOffset (so looking up and down doesn't change camera Z rel to vehicle)

var		byte	StuckCount;				// used by AI
var()	byte	Team;
var     byte    OldTeam, PrevTeam;  // OldTeam is used for replication purposes, PrevTeam is the team of the previous driver.

var				Rotator	PlayerEnterredRotation;	// Original rotation when player enterred vehicle
var		float	EjectMomentum;

var class<Controller> AutoTurretControllerClass;

// generic controls (set by controller, used by concrete derived classes)
var (Vehicle) float		Steering;		// between -1 and 1
var (Vehicle) float		Throttle;		// between -1 and 1
var (Vehicle) float		Rise;			// between -1 and 1
var           int       DriverViewPitch;      // The driver's view pitch
var           int       DriverViewYaw;        // The driver's view yaw

var float		ThrottleTime;	// last time at which throttle was 0 (used by AI)
var float		StuckTime;
var float		VehicleMovingTime; // used by AI C++

var (Vehicle) vector	DrivePos;		// Position (rel to vehicle) to put player while driving.
var (Vehicle) rotator	DriveRot;		// Rotation (rel to vehicle) to put driver while driving.
var (Vehicle) name		DriveAnim;		// Animation to play while driving.

//Info for EntryPositions
var (Vehicle) array<vector>	ExitPositions;		// Positions (rel to vehicle) to try putting the player when exiting.
var (Vehicle) vector	                EntryPosition;		// Offset for the entry trigger
var (Vehicle) float                     EntryRadius;        // Radius for the entry trigger

var (Vehicle) vector   FPCamPos;		// Position of camera when driving first person.
var (Vehicle) vector   FPCamViewOffset; // Offset in reference frame of camera.

//clientside settings
var config float TPCamDistance;
// force feedback
var string CenterSpringForce;
var int CenterSpringRangePitch;
var int CenterSpringRangeRoll;

var (Vehicle) vector   TPCamLookat; // Look at location in vehicle space
var (Vehicle) vector   TPCamWorldOffset; // Applied in world space after vehicle transform.
var float DesiredTPCamDistance, LastCameraCalcTime, CameraSpeed; //for smoothly interpolating TPCamDistance to new value
var (Vehicle) Range    TPCamDistRange;

var (Vehicle) int	MaxViewYaw;			// Maximum amount you can look left and right
var (Vehicle) int	MaxViewPitch;		// Maximum amount you can look up and down

var		Pawn			Driver;		// Can be None if Controller spawns right away with vehicle
var		SVehicleFactory	ParentFactory;

// FX
var String			TransEffects[2];		// Spawning effects
var	ShadowProjector	VehicleShadow;			// Shadow projector
var	float			ShadowMaxTraceDist;
var float			ShadowCullDistance;

var float MomentumMult;	//damage momentum multiplied by this value before being applied to vehicle
var float DriverDamageMult; //damage to the driver is multiplied by this value

// Missle warning
var String	LockOnClassString;
var float	LastLockWarningTime;
var float	LockWarningInterval;

var Vehicle NextVehicle;
var localized string VehiclePositionString;
var localized cache string VehicleNameString;
var localized cache string VehicleDescription;

var Texture TeamBeaconTexture, NoEntryTexture;
var Material TeamBeaconBorderMaterial;

var AIMarker myMarker;  // used for stationary turrets

//VEHICULAR MANSLAUGHTER
var float MinRunOverSpeed; //speed must be greater than this for running into someone to do damage
var class<DamageType> RanOverDamageType, CrushedDamageType;
var sound RanOverSound;
var name StolenAnnouncement;
var sound StolenSound;

var	float LinkHealMult;	// If > 0, Link Gun secondary heals an amount equal to its damage times this

var float OldSteering;
var float VehicleLostTime, TeamUseTime, PlayerStartTime;
var float MaxDesireability;
var const float AIMoveCheckTime;
var float ObjectiveGetOutDist; //if AI controlled and bot needs to trigger an objective not triggerable by vehicles, it will try to get out this far away

var name FlagBone;
var vector FlagOffset;
var rotator FlagRotation;

var	float	WheelsScale;

// HORN
var array<sound>	HornSounds;
var float			LastHornTime;

// BULLET HITS
var() array<sound>    BulletSounds;

// WATER DAMAGE
var()   float               WaterDamage;
var     class<DamageType>   VehicleDrowningDamType;

// HUD OVERLAY
var class<Actor>            HUDOverlayClass;
var Actor                   HUDOverlay;
var() vector                HUDOverlayOffset;
var() float                 HUDOverlayFOV;

// SPAWN OVERLAY MATERIAL
var()   Material            SpawnOverlay[2];


struct native SVehicleIcon
{
	var Material	Material;
	var float		X, Y, SizeX, SizeY;
	var bool		bIsGreyScale;
};

var SVehicleIcon VehicleIcon;

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
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

replication
{
	reliable if ( Role==ROLE_Authority )
		ClientKDriverEnter, ClientKDriverLeave, FixPCRotation, ClientClearController;

	unreliable if( bNetDirty && Role==ROLE_Authority )
        bDriving, bTeamLocked, Driver, Team, bVehicleDestroyed, WheelsScale;

	unreliable if( bNetInitial && Role==ROLE_Authority )
		bHUDTrackVehicle;

	reliable if ( Role < ROLE_Authority )
		VehicleFire, VehicleCeaseFire;
}

function PreBeginPlay()
{
	if ( !Level.Game.bAllowVehicles && !bDeleteMe )
	{
		Destroy();
		return;
	}

	Super.PreBeginPlay();
}

function PlayerChangedTeam()
{
	if ( Driver != None )
		Driver.KilledBy(Driver);
	else
		Super.PlayerChangedTeam();
}

simulated function SetBaseEyeheight()
{
	BaseEyeheight = Default.BaseEyeheight;
	Eyeheight = BaseEyeheight;
}

simulated function string GetVehiclePositionString()
{
	return VehiclePositionString;
}

function Suicide()
{
	if ( Driver != None )
		Driver.KilledBy(Driver);
	else
		KilledBy(self);
}

function bool CheatWalk()
{
	return false;
}

function bool CheatGhost()
{
	return false;
}

function bool CheatFly()
{
	return false;
}

simulated function PostBeginPlay()
{
	local controller NewController;

	super.PostBeginPlay();

	if ( bDeleteMe )
		return;

	// Glue a shadow projector on
	if ( bVehicleShadows && bDrawVehicleShadow && (Level.NetMode != NM_DedicatedServer) )
    {
        VehicleShadow = Spawn(class'ShadowProjector', self, '', Location);
        VehicleShadow.ShadowActor		= Self;
        VehicleShadow.bBlobShadow		= false;
        VehicleShadow.LightDirection	= Normal(vect(1,1,6));
        VehicleShadow.LightDistance		= 1200;
        VehicleShadow.MaxTraceDistance	= ShadowMaxTraceDist;
		VehicleShadow.CullDistance		= ShadowCullDistance;
        VehicleShadow.InitShadow();
    }

	if ( Role == Role_Authority )
	{
		if ( bAutoTurret && (Controller == None) && (AutoTurretControllerClass != None) )
		{
			NewController = spawn(AutoTurretControllerClass);
			if ( NewController != None )
				NewController.Possess(self);
		}
		if ( !bAutoTurret && !bNonHumanControl && IndependentVehicle() )
			Level.Game.RegisterVehicle(self);
	}

    OldTeam = Team;
    PrevTeam = Team;
}

simulated event SetInitialState()
{
    Super.SetInitialState();

    Disable('Tick');
}

function bool StronglyRecommended(Actor S, int TeamIndex, Actor Objective)
{
	return bKeyVehicle;
}

//return a value indicating how useful this vehicle is to bots
function float BotDesireability(Actor S, int TeamIndex, Actor Objective)
{
	local bool bSameTeam;
	local PlayerController P;

	bSameTeam = ( GetTeamNum() == TeamIndex );
	if ( bSameTeam )
	{
		if ( Level.TimeSeconds < TeamUseTime )
			return 0;
		if ( !bKeyVehicle && (Level.TimeSeconds < PlayerStartTime) )
		{
			P = Level.GetLocalPlayerController();
			if ( (P == None) || ((P.Pawn != None) && (Vehicle(P.Pawn) == None)) )
				return 0;
		}
	}
	if ( !bKeyVehicle && !bStationary && (Level.TimeSeconds < VehicleLostTime) )
		return 0;
	else if (Health <= 0 || Occupied() || (bTeamLocked && !bSameTeam))
		return 0;

	if (bKeyVehicle)
		return 100;

	return ((MaxDesireability * 0.5) + (MaxDesireability * 0.5 * (float(Health) / HealthMax)));
}

simulated function Destroyed()
{
	local Vehicle	V, Prev;

	if ( ParentFactory != None )
		ParentFactory.VehicleDestroyed( Self );		// Notify parent factory of death

    if ( VehicleShadow != None )
		VehicleShadow.Destroy();					// Destroy shadow projector

	if ( bAutoTurret && (Controller != None) && ClassIsChildOf(Controller.Class, AutoTurretControllerClass) && !Controller.bDeleteMe )
	{
		Controller.Destroy();
		Controller = None;
	}

	if ( Driver != None )
		Destroyed_HandleDriver();

	if ( Level.Game != None )
	{
		if ( Level.Game.VehicleList == Self )
			Level.Game.VehicleList = NextVehicle;
		else
		{
			Prev = Level.Game.VehicleList;
			if ( Prev != None )
				for ( V=Level.Game.VehicleList.NextVehicle; V!=None; V=V.NextVehicle )
				{
					if ( V == self )
					{
						Prev.NextVehicle = NextVehicle;
						break;
					}
					else
						Prev = V;
				}
		}
	}

	super.Destroyed();
}

simulated function Destroyed_HandleDriver()
{
	local Pawn		OldDriver;

	Driver.LastRenderTime = LastRenderTime;
	if ( Role == ROLE_Authority )
	{
		// if Driver wasn't visible in vehicle, destroy it
		if ( Driver != None && !bRemoteControlled && !bEjectDriver && !bDrawDriverInTP && Driver.Health > 0 )
		{
			OldDriver = Driver;
			Driver = None;
			OldDriver.DrivenVehicle = None;
			if ( !OldDriver.bDeleteMe )
				OldDriver.Destroy();
		}
		else if ( !bRemoteControlled && !bEjectDriver )
        {
			// otherwise spawn dead karma body
	        if (!bDrawDriverInTP && PlaceExitingDriver())
	        {
	            Driver.StopDriving(self);
	            Driver.DrivenVehicle = self;
	        }
			Driver.TearOffMomentum = Velocity * 0.25;
			Driver.Died(Controller, class'DamRanOver', Driver.Location);
        }
	}
	else if ( Driver.DrivenVehicle == self )
		Driver.StopDriving(self);
}

simulated function vector GetCameraLocationStart()
{
	return Location;
}

simulated function SpecialCalcBehindView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local vector CamLookAt, HitLocation, HitNormal, OffsetVector;
	local Actor HitActor;
    local vector x, y, z;

	if (DesiredTPCamDistance < TPCamDistance)
		TPCamDistance = FMax(DesiredTPCamDistance, TPCamDistance - CameraSpeed * (Level.TimeSeconds - LastCameraCalcTime));
	else if (DesiredTPCamDistance > TPCamDistance)
		TPCamDistance = FMin(DesiredTPCamDistance, TPCamDistance + CameraSpeed * (Level.TimeSeconds - LastCameraCalcTime));

    GetAxes(PC.Rotation, x, y, z);
	ViewActor = self;
	CamLookAt = GetCameraLocationStart() + (TPCamLookat >> Rotation) + TPCamWorldOffset;

	OffsetVector = vect(0, 0, 0);
	OffsetVector.X = -1.0 * TPCamDistance;

	CameraLocation = CamLookAt + (OffsetVector >> PC.Rotation);

	HitActor = Trace(HitLocation, HitNormal, CameraLocation, CamLookAt, true, vect(40, 40, 40));
	if ( HitActor != None
	     && (HitActor.bWorldGeometry || HitActor == GetVehicleBase() || Trace(HitLocation, HitNormal, CameraLocation, CamLookAt, false, vect(40, 40, 40)) != None) )
			CameraLocation = HitLocation;

    CameraRotation = Normalize(PC.Rotation + PC.ShakeRot);
    CameraLocation = CameraLocation + PC.ShakeOffset.X * x + PC.ShakeOffset.Y * y + PC.ShakeOffset.Z * z;
}

simulated function SpecialCalcFirstPersonView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local quat CarQuat, LookQuat, ResultQuat;
	local vector VehicleZ, CamViewOffsetWorld, x, y, z;
	local float CamViewOffsetZAmount;

	GetAxes(PC.Rotation, x, y, z);
	ViewActor = self;

	if (bPCRelativeFPRotation)
	{
		CarQuat = QuatFromRotator(Rotation);
		CameraRotation = Normalize(PC.Rotation);
		LookQuat = QuatFromRotator(CameraRotation);
		ResultQuat = QuatProduct(LookQuat, CarQuat);
		CameraRotation = QuatToRotator(ResultQuat);
	}
	else
		CameraRotation = PC.Rotation;

	// Camera position is locked to car
	CamViewOffsetWorld = FPCamViewOffset >> CameraRotation;
	CameraLocation = GetCameraLocationStart() + (FPCamPos >> Rotation) + CamViewOffsetWorld;

	if(bFPNoZFromCameraPitch)
	{
		VehicleZ = vect(0,0,1) >> Rotation;
		CamViewOffsetZAmount = CamViewOffsetWorld Dot VehicleZ;
		CameraLocation -= CamViewOffsetZAmount * VehicleZ;
	}

	CameraRotation = Normalize(CameraRotation + PC.ShakeRot);
	CameraLocation = CameraLocation + PC.ShakeOffset.X * x + PC.ShakeOffset.Y * y + PC.ShakeOffset.Z * z;
}

// Special calc-view for vehicles
simulated function bool SpecialCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local PlayerController pc;

	pc = PlayerController(Controller);

	// Only do this mode we have a playercontroller
	if( (pc == None) || (pc.Viewtarget != self) )
		return false;

	if( pc.bBehindView )
		SpecialCalcBehindView(PC,ViewActor,CameraLocation,CameraRotation);
	else
		SpecialCalcFirstPersonView(PC,ViewActor,CameraLocation,CameraRotation);

	LastCameraCalcTime = Level.TimeSeconds;

	return true;
}

simulated function bool SpectatorSpecialCalcView(PlayerController Viewer, out Actor ViewActor, out vector CameraLocation, out rotator CameraRotation)
{
	local rotator DummyRotation;

	if (Viewer.ViewTarget != self)
		return false;

	if (Viewer.bBehindView)
	{
		DesiredTPCamDistance = (TPCamDistRange.Max - TPCamDistRange.Min) * (Viewer.CameraDist / Viewer.CameraDistRange.Max) + TPCamDistRange.Min;
		SpecialCalcBehindView(Viewer, ViewActor, CameraLocation, CameraRotation);
	}
	else
		SpecialCalcFirstPersonView(Viewer, ViewActor, CameraLocation, DummyRotation); //use rotation set by playercontroller

	LastCameraCalcTime = Level.TimeSeconds;

	Viewer.SetLocation(CameraLocation);

	return true;
}

// Events called on driver entering/leaving vehicle

function Vehicle FindEntryVehicle(Pawn P)
{
	if ( AIController(P.Controller) != None )
		return self;
	if (VSize(P.Location - (Location + (EntryPosition >> Rotation))) < EntryRadius)
        return self;
    return None;
}

// The pawn Driver has tried to take control of this vehicle
function bool TryToDrive(Pawn P)
{
	if ( P.bIsCrouched ||  bNonHumanControl || (P.Controller == None) || (Driver != None) || (P.DrivenVehicle != None) || !P.Controller.bIsPlayer
	     || P.IsA('Vehicle') || Health <= 0 )
		return false;

	if( !Level.Game.CanEnterVehicle(self, P) )
		return false;

	// Check vehicle Locking....
	if ( !bTeamLocked || P.GetTeamNum() == Team )
	{
		if ( bEnterringUnlocks && bTeamLocked )
			bTeamLocked = false;

		KDriverEnter( P );
		return true;
	}
	else
	{
		VehicleLocked( P );
		return false;
	}
}

event VehicleLocked( Pawn P );	// Pawn tried to enter vehicle, but it's locked!!

function PossessedBy(Controller C)
{
	local PlayerController PC;

	if ( bAutoTurret && (Controller != None) && ClassIsChildOf(Controller.Class, AutoTurretControllerClass) && !Controller.bDeleteMe )
	{
		Controller.Destroy();
		Controller = None;
	}

	super.PossessedBy( C );

	// Stole another team's vehicle, so set Team to new owner's team
	if ( C.GetTeamNum() != Team )
	{
		//add stat tracking event/variable here?
		if ( Team != 255 && PlayerController(C) != None )
		{
			if( StolenAnnouncement != '' )
				PlayerController(C).PlayRewardAnnouncement(StolenAnnouncement, 1);

			if( StolenSound != None )
				PlaySound( StolenSound,, 2.5*TransientSoundVolume,, 400);
		}

		if ( C.GetTeamNum() != 255 )
			SetTeamNum( C.GetTeamNum() );
	}

	NetPriority = 3;
	NetUpdateFrequency = 100;
	ThrottleTime = Level.TimeSeconds;
	bSpawnProtected = false;

	PC = PlayerController(C);
	if ( PC != None )
		ClientKDriverEnter( PC );

	if ( ParentFactory != None && ( !bAutoTurret || !ClassIsChildOf(C.Class, AutoTurretControllerClass) ) )
		ParentFactory.VehiclePossessed( Self );		// Notify parent factory
}

function UnPossessed()
{
	local PlayerController	PC;
	local Controller		NewController;
	local bool				bWasPlayer;

	StopWeaponFiring();
	PC = PlayerController(Controller);



    if ( PC != None )
	{
		bWasPlayer = true;
        ClientKDriverLeave(PC);
		if (bPCRelativeFPRotation && !PC.bBehindView)
			FixPCRotation(PC);
	}
	else
        ClientClearController();

	NetPriority = Default.NetPriority;			// restore original netpriority changed when possessing
	NetUpdateTime = Level.TimeSeconds - 1;
	NetUpdateFrequency = 8;

	super.UnPossessed();

	if ( ParentFactory != None && ( !bAutoTurret || (Controller == None) || !ClassIsChildOf(Controller.Class, AutoTurretControllerClass) ) )
		ParentFactory.VehicleUnPossessed( Self );		// Notify parent of UnPossessed()

	if ( Health > 0 && !bDeleteMe )
	{
		if ( bWasPlayer && bAutoTurret && (AutoTurretControllerClass != None) )
		{
			Controller		= None;
			NewController	= spawn(AutoTurretControllerClass);
			if ( NewController != None )
				NewController.Possess( Self );
		}
	}
}

function KDriverEnter(Pawn P)
{
	local Controller C;

	bDriving = True;
	StuckCount = 0;

	// We don't have pre-defined exit positions here, so we use the original player location as an exit point
	if ( !bRelativeExitPos )
	{
		PlayerEnterredRotation = P.Rotation;
		ExitPositions[0] =  P.Location + Vect(0,0,16);
	}

	// Set pawns current controller to control the vehicle pawn instead
	C = P.Controller;
	if ( !bCanCarryFlag && (C.PlayerReplicationInfo.HasFlag != None)  )
		P.DropFlag();

	Driver = P;
	Driver.StartDriving( Self );

	// Disconnect PlayerController from Driver and connect to SVehicle.
	C.bVehicleTransition = true; // to keep Bots from doing Restart()
	C.Unpossess();
	Driver.SetOwner( Self ); // This keeps the driver relevant.
	C.Possess( Self );
	C.bVehicleTransition = false;

	DrivingStatusChanged();

	if ( PlayerController(C) != None )
		VehicleLostTime = 0;

	AttachFlag(PlayerReplicationInfo.HasFlag);

	Level.Game.DriverEnteredVehicle(self, P);
}

function AttachFlag(Actor FlagActor)
{
	if ( !bDriverHoldsFlag && (FlagActor != None) )
	{
		AttachToBone(FlagActor,FlagBone);
		FlagActor.SetRelativeRotation(FlagRotation);
		FlagActor.SetRelativeLocation(FlagOffset);
	}
}

simulated event SetWheelsScale(float NewScale)
{
	WheelsScale = NewScale;
}

// Called from the PlayerController when player wants to get out.
event bool KDriverLeave( bool bForceLeave )
{
	local Controller C;
	local PlayerController	PC;
	local bool havePlaced;

	if( !bForceLeave && !Level.Game.CanLeaveVehicle(self, Driver) )
		return false;

	if ( (PlayerReplicationInfo != None) && (PlayerReplicationInfo.HasFlag != None) )
		Driver.HoldFlag(PlayerReplicationInfo.HasFlag);

	// Do nothing if we're not being driven
	if (Controller == None )
		return false;

	// Before we can exit, we need to find a place to put the driver.
	// Iterate over array of possible exit locations.

	if ( (Driver != None) && (!bRemoteControlled || bHideRemoteDriver) )
    {
	    Driver.bHardAttach = false;
	    Driver.bCollideWorld = true;
	    Driver.SetCollision(true, true);
	    havePlaced = PlaceExitingDriver();

	    // If we could not find a place to put the driver, leave driver inside as before.
	    if (!havePlaced && !bForceLeave )
	    {
	        Driver.bHardAttach = true;
	        Driver.bCollideWorld = false;
	        Driver.SetCollision(false, false);
	        return false;
	    }
	}

	bDriving = False;

	// Reconnect Controller to Driver.
	C = Controller;
	if (C.RouteGoal == self)
		C.RouteGoal = None;
	if (C.MoveTarget == self)
		C.MoveTarget = None;
	C.bVehicleTransition = true;
	Controller.UnPossess();

	if ( (Driver != None) && (Driver.Health > 0) )
	{
		Driver.SetOwner( C );
		C.Possess( Driver );

		PC = PlayerController(C);
		if ( PC != None )
			PC.ClientSetViewTarget( Driver ); // Set playercontroller to view the person that got out

		Driver.StopDriving( Self );
	}
	C.bVehicleTransition = false;

	if ( C == Controller )	// If controller didn't change, clear it...
		Controller = None;

	Level.Game.DriverLeftVehicle(self, Driver);

	// Car now has no driver
	Driver = None;

	DriverLeft();

	// Put brakes on before you get out :)
    Throttle	= 0;
    Steering	= 0;
	Rise		= 0;

    return true;
}

// DriverLeft() called by KDriverLeave()
function DriverLeft()
{
    DrivingStatusChanged();
}

simulated event UpdateTiltForceFeedback()
{
	local rotator SpringCenter;
	local float pitch, roll;
	local PlayerController PC;

	PC = PlayerController(Controller);
	if ( PC != None )
	{
		SpringCenter = rotation;
		pitch = Clamp(SpringCenter.Pitch, -CenterSpringRangePitch, CenterSpringRangePitch);
		roll = Clamp(SpringCenter.Roll, -CenterSpringRangeRoll, CenterSpringRangeRoll);
		pitch /= CenterSpringRangePitch;
		roll /= CenterSpringRangeRoll;
		PC.ChangeSpringFeedbackEffect(CenterSpringForce, roll, pitch);
	}
}

simulated function ClientKDriverEnter(PlayerController PC)
{
//	PC.bFreeCamera = true;

	// Set rotation of camera when getting into vehicle based on bZeroPCRotOnEntry
	if ( bZeroPCRotOnEntry )
		PC.SetRotation( rot(0, 0, 0) );

	//set starting camera distance to local player's preferences
	TPCamDistance = default.TPCamDistance;
	DesiredTPCamDistance = TPCamDistance;

    if (!PC.bBehindView)
	   ActivateOverlay(True);

	if ( PC.bEnableGUIForceFeedback
		&&	PC.bForceFeedbackSupported
		&&	(Viewport(PC.Player) != None) )
	{
		if ( (CenterSpringRangePitch > 0) && (CenterSpringRangeRoll > 0) )
			UpdateTiltForceFeedback();
		PC.ClientPlayForceFeedback(CenterSpringForce);
	}

	if (Driver!=None)
	{
		Driver.AmbientSound=none;
		if (Driver.Weapon!=None)
			Driver.Weapon.AmbientSound=none;
	}


}

simulated function ClientClearController()
{
    ActivateOverlay(False);
}

simulated function ClientKDriverLeave(PlayerController PC)
{
//	PC.bFreeCamera = false;

	// Stop messing with bOwnerNoSee
	if ( Driver != None )
		Driver.bOwnerNoSee = Driver.default.bOwnerNoSee;

	if (PC.bEnableGUIForceFeedback)
		PC.StopForceFeedback(CenterSpringForce);

	bWeaponisFiring = False;
	bWeaponisAltFiring = False;

	ActivateOverlay(False);
}

simulated function ActivateOverlay(bool bActive)
{
    if (bActive)
    {
        if (HUDOverlayClass != None && HUDOverlay == None)
            HUDOverlay = spawn(HUDOverlayClass);
    }
    else if (HUDOverlay != None)
        HUDOverlay.Destroy();
}

//seperate replicated function called from UnPossessed() to make PC rotation no longer relative to vehicle
//needed because PC.bBehindView will get screwed around with as a result of unpossessing vehicle and repossessing Driver
simulated function FixPCRotation(PlayerController PC)
{
	PC.SetRotation(rotator(vector(PC.Rotation) >> Rotation));
}

simulated function AttachDriver(Pawn P)
{
	local vector AttachPos;

	P.bHardAttach = true;
	AttachPos = Location + (DrivePos >> Rotation);
	P.SetLocation( AttachPos );
	P.SetPhysics( PHYS_None );
	P.SetBase( Self );
	P.SetRelativeRotation( DriveRot );
}

simulated function DetachDriver(Pawn P) {}

function bool PlaceExitingDriver()
{
	local int		i, j;
	local vector	tryPlace, Extent, HitLocation, HitNormal, ZOffset, RandomSphereLoc;
	local float BestDir, NewDir;

	if ( Driver == None )
		return false;
	Extent = Driver.default.CollisionRadius * vect(1,1,0);
	Extent.Z = Driver.default.CollisionHeight;
	ZOffset = Driver.default.CollisionHeight * vect(0,0,1);

	//avoid running driver over by placing in direction perpendicular to velocity
	if ( VSize(Velocity) > 100 )
	{
		tryPlace = Normal(Velocity cross vect(0,0,1)) * (CollisionRadius + Driver.default.CollisionRadius ) * 1.25 ;
		if ( (Controller != None) && (Controller.DirectionHint != vect(0,0,0)) )
		{
			if ( (tryPlace dot Controller.DirectionHint) < 0 )
				tryPlace *= -1;
		}
		else if ( FRand() < 0.5 )
				tryPlace *= -1; //randomly prefer other side
		if ( (Trace(HitLocation, HitNormal, Location + tryPlace + ZOffset, Location + ZOffset, false, Extent) == None && Driver.SetLocation(Location + tryPlace + ZOffset))
		     || (Trace(HitLocation, HitNormal, Location - tryPlace + ZOffset, Location + ZOffset, false, Extent) == None && Driver.SetLocation(Location - tryPlace + ZOffset)) )
			return true;
	}

	if ( (Controller != None) && (Controller.DirectionHint != vect(0,0,0)) )
	{
		// first try best position
		tryPlace = Location;
		BestDir = 0;
		for( i=0; i<ExitPositions.Length; i++)
		{
			NewDir = Normal(ExitPositions[i] - Location) Dot Controller.DirectionHint;
			if ( NewDir > BestDir )
			{
				BestDir = NewDir;
				tryPlace = ExitPositions[i];
			}
		}
		Controller.DirectionHint = vect(0,0,0);
		if ( tryPlace != Location )
		{
			if ( bRelativeExitPos )
			{
				if ( ExitPositions[0].Z != 0 )
					ZOffset = Vect(0,0,1) * ExitPositions[0].Z;
				else
					ZOffset = Driver.default.CollisionHeight * vect(0,0,2);

				tryPlace = Location + ( (tryPlace-ZOffset) >> Rotation) + ZOffset;

				// First, do a line check (stops us passing through things on exit).
				if ( (Trace(HitLocation, HitNormal, tryPlace, Location + ZOffset, false, Extent) == None)
					&& Driver.SetLocation(tryPlace) )
					return true;
			}
			else if ( Driver.SetLocation(tryPlace) )
				return true;
		}
	}

	if ( !bRelativeExitPos )
	{
		for( i=0; i<ExitPositions.Length; i++)
		{
			tryPlace = ExitPositions[i];

			if ( Driver.SetLocation(tryPlace) )
				return true;
			else
			{
				for (j=0; j<10; j++) // try random positions in a sphere...
				{
					RandomSphereLoc = VRand()*200* FMax(FRand(),0.5);
					RandomSphereLoc.Z = Extent.Z * FRand();

					// First, do a line check (stops us passing through things on exit).
					if ( Trace(HitLocation, HitNormal, tryPlace+RandomSphereLoc, tryPlace, false, Extent) == None )
					{
						if ( Driver.SetLocation(tryPlace+RandomSphereLoc) )
							return true;
					}
					else if ( Driver.SetLocation(HitLocation) )
						return true;
				}
			}
		}
		return false;
	}

	for( i=0; i<ExitPositions.Length; i++)
	{
		if ( ExitPositions[0].Z != 0 )
			ZOffset = Vect(0,0,1) * ExitPositions[0].Z;
		else
			ZOffset = Driver.default.CollisionHeight * vect(0,0,2);

		tryPlace = Location + ( (ExitPositions[i]-ZOffset) >> Rotation) + ZOffset;

		// First, do a line check (stops us passing through things on exit).
		if ( Trace(HitLocation, HitNormal, tryPlace, Location + ZOffset, false, Extent) != None )
			continue;

		// Then see if we can place the player there.
		if ( !Driver.SetLocation(tryPlace) )
			continue;

		return true;
	}
	return false;
}

function Pawn CheckForHeadShot(Vector loc, Vector ray, float AdditionalScale)
{
    return None;
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, class<DamageType> damageType)
{
	local int ActualDamage;
	local Controller Killer;

	// Spawn Protection: Cannot be destroyed by a player until possessed
	if ( bSpawnProtected && instigatedBy != None && instigatedBy != Self )
		return;

	NetUpdateTime = Level.TimeSeconds - 1; // force quick net update

	if (DamageType != None)
	{
		if ((instigatedBy == None || instigatedBy.Controller == None) && DamageType.default.bDelayedDamage && DelayedDamageInstigatorController != None)
			instigatedBy = DelayedDamageInstigatorController.Pawn;

		Damage *= DamageType.default.VehicleDamageScaling;
		momentum *= DamageType.default.VehicleMomentumScaling * MomentumMult;

	        if (bShowDamageOverlay && DamageType.default.DamageOverlayMaterial != None && Damage > 0 )
        	    SetOverlayMaterial( DamageType.default.DamageOverlayMaterial, DamageType.default.DamageOverlayTime, false );
	}

	if (bRemoteControlled && Driver!=None)
	{
	    ActualDamage = Damage;
	    if (Weapon != None)
	        Weapon.AdjustPlayerDamage(ActualDamage, InstigatedBy, HitLocation, Momentum, DamageType );
	    if (InstigatedBy != None && InstigatedBy.HasUDamage())
	        ActualDamage *= 2;

	    ActualDamage = Level.Game.ReduceDamage(ActualDamage, self, instigatedBy, HitLocation, Momentum, DamageType);

	    if (Health - ActualDamage <= 0)
	       	KDriverLeave(false);
	}

    if ( Physics != PHYS_Karma )
	{
		super.TakeDamage(Damage,InstigatedBy,HitLocation,Momentum,DamageType);
		return;
	}

	if (Weapon != None)
	        Weapon.AdjustPlayerDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType );
	if (InstigatedBy != None && InstigatedBy.HasUDamage())
		Damage *= 2;
	ActualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);
	Health -= ActualDamage;

	PlayHit(actualDamage, InstigatedBy, hitLocation, damageType, Momentum);
	// The vehicle is dead!
	if ( Health <= 0 )
	{

		if ( Driver!=None && (bEjectDriver || bRemoteControlled) )
		{
			if ( bEjectDriver )
				EjectDriver();
			else
        		KDriverLeave( false );
		}

		// pawn died
		if ( instigatedBy != None )
			Killer = instigatedBy.GetKillerController();
		if ( Killer == None && (DamageType != None) && DamageType.Default.bDelayedDamage )
			Killer = DelayedDamageInstigatorController;
		Died(Killer, damageType, HitLocation);
	}
	else if ( Controller != None )
		Controller.NotifyTakeHit(instigatedBy, HitLocation, actualDamage, DamageType, Momentum);

	MakeNoise(1.0);

	if ( !bDeleteMe )
	{
		if ( Location.Z > Level.StallZ )
			Momentum.Z = FMin(Momentum.Z, 0);
		KAddImpulse(Momentum, hitlocation);
	}
}

function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
	if ( PlayerController(Healer) != None )
		PlayerStartTime = Level.TimeSeconds + 3;
	if (Health <= 0 || Health >= HealthMax || Amount <= 0 || Healer == None || !TeamLink(Healer.GetTeamNum()))
		return false;

	Health = Min(Health + (Amount * LinkHealMult), HealthMax);
	NetUpdateTime = Level.TimeSeconds - 1;
	return true;
}

//determine if radius damage that hit the vehicle should damage the driver
function DriverRadiusDamage(float DamageAmount, float DamageRadius, Controller EventInstigator, class<DamageType> DamageType, float Momentum, vector HitLocation)
{
	local float damageScale, dist;
	local vector dir;

	//if driver has collision, whatever is causing the radius damage will hit the driver by itself
	if (EventInstigator == None || Driver == None || Driver.bCollideActors || bRemoteControlled)
		return;

	dir = Driver.Location - HitLocation;
	dist = FMax(1, VSize(dir));
	dir = dir/dist;
	damageScale = 1 - FMax(0,(dist - Driver.CollisionRadius)/DamageRadius);
	if (damageScale <= 0)
		return;

	Driver.SetDelayedDamageInstigatorController(EventInstigator);
	Driver.TakeDamage( damageScale * DamageAmount, EventInstigator.Pawn, Driver.Location - 0.5 * (Driver.CollisionHeight + Driver.CollisionRadius) * dir,
			   damageScale * Momentum * dir, DamageType );
}


function DriverDied()
{
	local Controller C;

	Level.Game.DiscardInventory( Driver );
	if (PlayerReplicationInfo != None && PlayerReplicationInfo.HasFlag != None)
		PlayerReplicationInfo.HasFlag.Drop(0.5 * Velocity);

	if ( Driver == None )
		return;
	C = Controller;
	Driver.StopDriving( Self );
	Driver.Controller = C;
	Driver.DrivenVehicle = self; //for in game stats, so it knows pawn was killed inside a vehicle

	if ( Controller == None )
		return;

	if ( PlayerController(Controller) != None )
	{
		Controller.SetLocation(Location);
		PlayerController(Controller).SetViewTarget( Driver );
		PlayerController(Controller).ClientSetViewTarget( Driver );
	}

	Controller.Unpossess();
	if ( Controller == C )
		Controller = None;
	C.Pawn = Driver;

	Level.Game.DriverLeftVehicle(self, Driver);

	// Car now has no driver
	Driver = None;
	bDriving = false;

	// Put brakes on before you get out :)
    Throttle	= 0;
    Steering	= 0;
	Rise		= 0;
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local PlayerController PC;
	local Controller C;

	if ( bDeleteMe || Level.bLevelChange )
		return; // already destroyed, or level is being cleaned up

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

		if ( !C.bIsPlayer && !C.bDeleteMe )
			C.Destroy();
	}
	else
		Level.Game.Killed(Killer, Controller(Owner), self, damageType);

	if ( Killer != None )
		TriggerEvent(Event, self, Killer.Pawn);
	else
		TriggerEvent(Event, self, None);

	if ( IsHumanControlled() )
		PlayerController(Controller).ForceDeathUpdate();

	if ( !bDeleteMe )
		Destroy(); // Destroy the vehicle itself (see Destroyed)
}

function AdjustDriverDamage(out int Damage, Pawn InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	if ( InGodMode() )
 		Damage = 0;
	else
 		Damage *= DriverDamageMult;
}

function EjectDriver()
{
	local Pawn		OldPawn;
	local vector	EjectVel;

	OldPawn = Driver;

	KDriverLeave( true );

	if ( OldPawn == None )
		return;

	EjectVel	= VRand();
	EjectVel.Z	= 0;
	EjectVel	= (Normal(EjectVel)*0.2 + Vect(0,0,1)) * EjectMomentum;

	OldPawn.Velocity = EjectVel;

	// Spawn Protection
	OldPawn.SpawnTime = Level.TimeSeconds;
	OldPawn.PlayTeleportEffect( false, false);
}

// Input
function UsedBy( Pawn user )
{
	if ( Driver != None )
			return;

	// Enter vehicle code
	TryToDrive( User );
}

function Fire( optional float F )
{
	VehicleFire( false );
	bWeaponIsFiring = true;
}

function AltFire( optional float F )
{
	VehicleFire( true );
	bWeaponIsAltFiring = true;
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
	if (bWasAltFire)
		bWeaponIsAltFiring = false;
	else
		bWeaponIsFiring = false;

	VehicleCeaseFire(bWasAltFire);
}

// Do some server-side vehicle firing stuff
function VehicleFire(bool bWasAltFire)
{
	if ( bWasAltFire )
		bWeaponIsAltFiring = true;
	else
		bWeaponIsFiring = true;
}

function VehicleCeaseFire(bool bWasAltFire)
{
	if ( bWasAltFire )
		bWeaponIsAltFiring = false;
	else
		bWeaponIsFiring = false;
}

state UnDeployed
{
    function VehicleFire(bool bWasAltFire)
    {
        Global.VehicleFire(bWasAltFire);
    }

    function VehicleCeaseFire(bool bWasAltFire)
    {
        Global.VehicleCeaseFire(bWasAltFire);
    }
}

state Deployed
{
    function VehicleFire(bool bWasAltFire)
    {
        Global.VehicleFire(bWasAltFire);
    }

    function VehicleCeaseFire(bool bWasAltFire)
    {
        Global.VehicleCeaseFire(bWasAltFire);
    }
}

function bool StopWeaponFiring()
{
	local bool bResult;

	if ( bWeaponIsFiring )
	{
		ClientVehicleCeaseFire( false );
		bWeaponIsFiring = false;
		bResult = true;
	}
	if ( bWeaponIsAltFiring )
	{
		ClientVehicleCeaseFire( true );
		bWeaponIsAltFiring = false;
		bResult = true;
	}
	return bResult;
}


event UpdateEyeHeight( float DeltaTime )
{
	local Controller C;

	if ( Controller != None && Controller.IsA('PlayerController') )
		Controller.AdjustView( DeltaTime );

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
		if ( C.IsA('PlayerController') && (PlayerController(C).ViewTarget == self) )
			return;

	bUpdateEyeHeight =false;
	Eyeheight = BaseEyeheight;
}

// Vehicles ignore 'face rotation'.
simulated function FaceRotation( rotator NewRotation, float DeltaTime ) {}

simulated event SetAnimAction(name NewAction)
{
	if ( bDrawDriverInTP && (Driver != None) )
		Driver.SetAnimAction(NewAction);
}

// Vehicles dont get telefragged.
event EncroachedBy(Actor Other) {}

// RanInto() called for encroaching actors which successfully moved the other actor out of the way
event RanInto(Actor Other)
{
	local vector Momentum;
	local float Speed;

	if (Pawn(Other) == None || Vehicle(Other) != None || Other == Instigator || Other.Role != ROLE_Authority)
		return;

	Speed = VSize(Velocity);
	if (Speed > MinRunOverSpeed)
	{
		Momentum = Velocity * 0.25 * Other.Mass;

		if (Controller != None && Controller.SameTeamAs(Pawn(Other).Controller))
			Momentum += Speed * 0.25 * Other.Mass * Normal(Velocity cross vect(0,0,1));
		if (RanOverSound != None)
			PlaySound(RanOverSound,,TransientSoundVolume*2.5);

       		Other.TakeDamage(int(Speed * 0.075), Instigator, Other.Location, Momentum, RanOverDamageType);
	}
}

// This will get called if we couldn't move a pawn out of the way.
function bool EncroachingOn(Actor Other)
{
	if ( Other == None || Other == Instigator || Other.Role != ROLE_Authority || (!Other.bCollideActors && !Other.bBlockActors)
	     || VSize(Velocity) < 10 )
		return false;

	// If its a non-vehicle pawn, do lots of damage.
	if( (Pawn(Other) != None) && (Vehicle(Other) == None) )
	{
		Other.TakeDamage(10000, Instigator, Other.Location, Velocity * Other.Mass, CrushedDamageType);
		return false;
	}
}

simulated function bool FindValidTaunt( out name Sequence )
{
	if ( !bDrawDriverInTP || (Driver == None) )
		return false;
	return Driver.FindValidTaunt(Sequence);
}

simulated function bool CheckTauntValid( name Sequence )
{
	if ( !bDrawDriverInTP || (Driver == None) )
		return false;
	return Driver.CheckTauntValid(Sequence);
}


// AI code
function bool Occupied()
{
	return ( Controller != None );
}

function float ReservationCostMultiplier()
{
	return 1.0;
}

function float NewReservationCostMultiplier(Pawn P)
{
	return ReservationCostMultiplier();
}

function bool ChangedReservation(Pawn P)
{
	return false;
}

function bool SpokenFor(Controller C)
{
	return false;
}

function SetReservation(controller C);

function Vehicle OpenPositionFor(Pawn P)
{
	if ( Controller == None )
		return self;
	return None;
}

simulated function bool IndependentVehicle()
{
	return true;
}

function Actor GetBestEntry(Pawn P)
{
	return self;
}

function Vehicle GetMoveTargetFor(Pawn P)
{
	return self;
}

simulated event DrivingStatusChanged()
{
    local PlayerController PC;

	PC = Level.GetLocalPlayerController();

	if (bDriving && PC != None && (PC.ViewTarget == None || !(PC.ViewTarget.IsJoinedTo(self))))
        bDropDetail = (Level.bDropDetail || (Level.DetailMode == DM_Low));
    else
        bDropDetail = False;

    if (bDriving)
        Enable('Tick');
    else
        Disable('Tick');
}

// TakeWaterDamage() called every tick when WaterDamage>0 and PhysicsVolume.bWaterVolume=true
event TakeWaterDamage(float DeltaTime)
{
	local vector HitLocation,HitNormal;
	local actor EntryActor;

	TakeDamage(WaterDamage * DeltaTime, Self, vect(0,0,0), vect(0,0,0), VehicleDrowningDamType);

	if ( (Level.TimeSeconds - SplashTime > 0.3) && (PhysicsVolume.PawnEntryActor != None) && !Level.bDropDetail && (Level.DetailMode != DM_Low) && EffectIsRelevant(Location,false)
		&& (VSize(Velocity) > 300) )
	{
		SplashTime = Level.TimeSeconds;
		if ( !PhysicsVolume.TraceThisActor(HitLocation, HitNormal, Location - CollisionHeight*vect(0,0,1), Location + CollisionHeight*vect(0,0,1)) )	
		{
			EntryActor = Spawn(PhysicsVolume.PawnEntryActor,self,,HitLocation,rot(16384,0,0));
		}
	}
}

// LockOnWarning() called every LockWarningInterval when bEnemyLockedOn is true (on server/standalone)
event LockOnWarning()
{
	local	class<LocalMessage>	LockOnClass;

	LockOnClass = class<LocalMessage>(DynamicLoadObject(LockOnClassString, class'class'));
	PlayerController(Controller).ReceiveLocalizedMessage(LockOnClass, 12);
    LastLockWarningTime = Level.TimeSeconds;
}

/* PointOfView()
called by controller when possessing this pawn
false = 1st person, true = 3rd person
*/
simulated function bool PointOfView()
{
	if (!bAllowViewChange)
		return true;

	return default.bDesiredBehindView;
}

// Spawn FX
function PlayTeleportEffect( bool bOut, bool bSound)
{
	local Actor			A;
	local class<Actor>	TransEffect;

	if ( (GetTeam() == None) || (GetTeam().TeamIndex == 0) )
		TransEffect = class<Actor>(DynamicLoadObject(TransEffects[0], class'Class'));
	else
		TransEffect = class<Actor>(DynamicLoadObject(TransEffects[1], class'Class'));

	if ( TransEffect != None )
		A = Spawn(TransEffect,,,Location + CollisionHeight * vect(0,0,0.75));

	// for fast moving vehicles, make the effect sticky
	if ( A != None )
		A.SetBase( Self );

    super.PlayTeleportEffect( bOut, bSound );
}

simulated event PlayDying(class<DamageType> DamageType, vector HitLoc) {}

simulated function int GetTeamNum()
{
	if ( Role == Role_Authority && Team == 255 && (Controller != None) )
	   SetTeamNum( Controller.GetTeamNum() );

    return Team;
}

//Notify vehicle that an enemy has locked on to it
event NotifyEnemyLockedOn()
{
	bEnemyLockedOn = true;
}

function IncomingMissile(Projectile P);

//Notify vehicle that an enemy has lost the lock
event NotifyEnemyLostLock()
{
	bEnemyLockedOn = false;
}

/*
Team is changed when vehicle is possessed
and PrevTeam is restored when vehicle is unpossessed
*/
function SetTeamNum(byte T)
{
	PrevTeam	= Team;
    Team		= T;

	if ( PrevTeam != Team )
		TeamChanged();
}

simulated event TeamChanged() {}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	super.DisplayDebug(Canvas, YL, YPos);

	Canvas.SetDrawColor(255,255,255);
	Canvas.DrawText("Steering "$Steering$" throttle "$Throttle$" rise "$Rise);

	if ( Driver != None )
	{
        YPos += YL;
    	YPos += YL;
		Canvas.SetPos(0, YPos);
		Canvas.SetDrawColor(0,0,255);
		Canvas.DrawText("--- DRIVER");
		Canvas.SetPos(4, YPos);
		Driver.DisplayDebug( Canvas, YL, YPos );
	}
}

function Actor ShootSpecial(Actor A)
{
	local Controller OldController;

	if ( !Controller.bCanDoSpecial || (Weapon == None) )
		return None;

	Controller = OldController;
	if ( KDriverLeave(false) && (OldController.Pawn != None) )
	{
		OldController.Pawn.SetRotation(rotator(A.Location - OldController.Pawn.Location));
		OldController.Focus = A;
		OldController.FireWeaponAt(A);
	}
	return A;
}

//Vehicles stall when they go above the level's StallZ
simulated event Stalled();
simulated event UnStalled();

simulated function NextWeapon()
{
    local PlayerController PC;

    if ( Level.Pauser != None )
        return;

    PC = PlayerController(Controller);
    if (PC == None)
    	return;

    if (!PC.bBehindView)
    {
    	PC.BehindView(true);
	DesiredTPCamDistance = TPCamDistRange.Min;
	TPCamDistance = DesiredTPCamDistance;
    }
    else
	DesiredTPCamDistance = Min(DesiredTPCamDistance + 100, TPCamDistRange.Max);

    default.TPCamDistance = DesiredTPCamDistance;
    StaticSaveConfig();
}

simulated function PrevWeapon()
{
    local PlayerController PC;

    if ( Level.Pauser != None )
        return;

    PC = PlayerController(Controller);
    if (PC == None || !PC.bBehindView)
    	return;

    if (DesiredTPCamDistance ~= TPCamDistRange.Min)
    	PC.BehindView(false);
    else
    {
	DesiredTPCamDistance = Max(DesiredTPCamDistance - 100, TPCamDistRange.Min);
	default.TPCamDistance = DesiredTPCamDistance;
	StaticSaveConfig();
    }
}

function bool TeamLink(int TeamNum)
{
	return (LinkHealMult > 0 && Team == TeamNum && Health > 0);
}

event bool NeedsFlip()
{
	local vector worldUp, gravUp;
	local float GravMag;

	GravMag = VSize(PhysicsVolume.Gravity);
	if( GravMag < 0.1 )
		gravUp = vect(0,0,1);
	else
		gravUp = -1.0 * (PhysicsVolume.Gravity/GravMag);

	worldUp = vect(0,0,1) >> Rotation;
	if (worldUp Dot gravUp < -0.5)
		return true;

	return false;
}

function Flip(vector HitNormal, float ForceScale);

simulated function float ChargeBar();

simulated function ClientPlayForceFeedback( String EffectName )
{
    local PlayerController PC;

    PC = PlayerController(Controller);
    //if ( PC != None && PC.bEnableVehicleForceFeedback )
    if ( PC != None && PC.bEnableGUIForceFeedback )
    {
        PC.ClientPlayForceFeedback( EffectName );
    }
}

simulated function StopForceFeedback( String EffectName )
{
    local PlayerController PC;

    PC = PlayerController(Controller);
    //if ( PC != None && PC.bEnableVehicleForceFeedback )
    if ( PC != None && PC.bEnableGUIForceFeedback )
    {
        PC.StopForceFeedback( EffectName );
    }
}

function ServerPlayHorn(int HornIndex)
{
	if( (Level.TimeSeconds - LastHornTime > 3.0) && (HornIndex >= 0) && (HornIndex < HornSounds.Length) )
	{
		PlaySound( HornSounds[HornIndex],, 3.5*TransientSoundVolume,, 800);
		LastHornTime = Level.TimeSeconds;
	}
}

simulated function int NumPassengers()
{
	if ( Driver != None )
		return 1;
	return 0;
}

function Pawn GetInstigator()
{
	return Self;
}

function AIController GetBotPassenger()
{
	return AIController(Controller);
}

event bool IsVehicleEmpty()
{
	return (Driver == None);
}

function bool HasOccupiedTurret()
{
	return false;
}

function float AdjustedStrength()
{
	if (bStationary && bDefensive)
		return 1.0;

	return 0;
}

static function StaticPrecache(LevelInfo L);

function int GetSpree()
{
	if (Driver != None)
		return Driver.GetSpree();

	return 0;
}

function IncrementSpree()
{
	if (Driver != None)
		Driver.IncrementSpree();
}

simulated function POVChanged(PlayerController PC, bool bBehindViewChanged)
{
	if (PC.bBehindView)
	{
		if (bBehindViewChanged && bPCRelativeFPRotation)
			PC.SetRotation(rotator(vector(PC.Rotation) >> Rotation));

		bOwnerNoSee = false;

		if (Driver != None)
		{
			if (bDrawDriverInTP)
				Driver.bOwnerNoSee = false;
			else
				Driver.bOwnerNoSee = true;
		}

        if (PC == Controller)   // No overlays for spectators
            ActivateOverlay(False);
	}
	else
	{
		if (bPCRelativeFPRotation)
			PC.SetRotation(rotator(vector(PC.Rotation) << Rotation));

		if (bDrawMeshInFP)
			bOwnerNoSee = false;
		else
			bOwnerNoSee = true;

		if (Driver != None)
		{
			Driver.bOwnerNoSee = true;
		}

        if (bDriving && PC == Controller)   // No overlays for spectators
            ActivateOverlay(True);
	}
}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
    local int SoundNum;

    if (IndependentVehicle() && DamageType.Default.bBulletHit && BulletSounds.Length > 0)
    {
		SoundNum = Rand(BulletSounds.Length);

		if (Controller != None && Controller == Level.GetLocalPlayerController())
            PlayOwnedSound(BulletSounds[SoundNum], SLOT_None, 2.0, False, 400);
        else
            PlayOwnedSound(BulletSounds[SoundNum], SLOT_None, 2.0, False, 100);
	}
}

function array<Vehicle> GetTurrets();

function CheckSuperBerserk();

// Used to override locking actors.  Returns who the aggressor really should lock on to

event bool VerifyLock(actor Aggressor, out actor NewTarget)
{
	return true;
}

// Returns any alternate target actor for this vehicle if it has one

simulated function actor AlternateTarget()
{
    return None;
}

function ShouldTargetMissile(Projectile P)
{
	local AIController C;

	C = AIController(Controller);
	if (C != None && C.Skill >= 5.0 && (C.Enemy == None || !C.LineOfSightTo(C.Enemy)) )
		ShootMissile(P);
}

function ShootMissile(Projectile P)
{
	Controller.Focus = P;
	Controller.FireWeaponAt(P);
}

function bool ImportantVehicle()
{
	return false;
}

function bool IsArtillery()
{
	return false;
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     bDrawVehicleShadow=True
     bRelativeExitPos=True
     bZeroPCRotOnEntry=True
     bPCRelativeFPRotation=True
     bAllowViewChange=True
     bAdjustDriversHead=True
     bDesiredBehindView=True
     bDriverHoldsFlag=True
     bCanCarryFlag=True
     Team=255
     OldTeam=255
     PrevTeam=255
     EjectMomentum=1000.000000
     DriveAnim="Vehicle_Driving"
     EntryRadius=100.000000
     TPCamDistance=600.000000
     CenterSpringForce="SpringONSHoverBike"
     CenterSpringRangePitch=2000
     CenterSpringRangeRoll=2000
     TPCamLookat=(X=-100.000000,Z=100.000000)
     CameraSpeed=500.000000
     TPCamDistRange=(Min=50.000000,Max=1500.000000)
     MaxViewYaw=16000
     MaxViewPitch=16000
     TransEffects(0)="XEffects.TransEffectRed"
     TransEffects(1)="XEffects.TransEffectBlue"
     ShadowMaxTraceDist=350.000000
     ShadowCullDistance=1500.000000
     MomentumMult=4.000000
     DriverDamageMult=1.000000
     LockOnClassString="Onslaught.ONSOnslaughtMessage"
     LockWarningInterval=1.500000
     VehiclePositionString="in a vehicle"
     VehicleNameString="Vehicle"
     RanOverDamageType=Class'Engine.DamRanOver'
     CrushedDamageType=Class'Engine.Crushed'
     LinkHealMult=0.350000
     MaxDesireability=0.500000
     ObjectiveGetOutDist=1000.000000
     bCanBeBaseForPawns=True
     bDontPossess=True
     bUseCompressedPosition=False
     SightRadius=15000.000000
     WalkingPct=1.000000
     CrouchedPct=1.000000
     LandMovementState="PlayerDriving"
     NetUpdateFrequency=4.000000
     NetPriority=1.000000
     bForceSkelUpdate=True
     CollisionRadius=120.000000
     CollisionHeight=50.000000
}
