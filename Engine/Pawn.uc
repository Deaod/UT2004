//=============================================================================
// Pawn, the base class of all actors that can be controlled by players or AI.
//
// Pawns are the physical representations of players and creatures in a level.
// Pawns have a mesh, collision, and physics.  Pawns can take damage, make sounds,
// and hold weapons and other inventory.  In short, they are responsible for all
// physical interaction between the player or AI and the world.
//
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Pawn extends Actor
	abstract
	native
	placeable
	config(user)
	nativereplication
	exportstructs;

#exec Texture Import File=Textures\Pawn.pcx Name=S_Pawn Mips=Off MASKED=1

//-----------------------------------------------------------------------------
// Pawn variables.

var Controller Controller;

// cache net relevancy test
var float NetRelevancyTime;
var playerController LastRealViewer;
var actor LastViewer;

var const float LastLocTime;		// used to force periodic location replication, even when pawn isn't moving

// Physics related flags.
var bool		bJustLanded;		// used by eyeheight adjustment
var bool		bLandRecovery;		// used by eyeheight adjustment
var bool		bUpAndOut;			// used by swimming
var bool		bIsWalking;			// currently walking (can't jump, affects animations)
var bool		bWarping;			// Set when travelling through warpzone (so shouldn't telefrag)
var bool		bWantsToCrouch;		// if true crouched (physics will automatically reduce collision height to CrouchHeight)
var const bool	bIsCrouched;		// set by physics to specify that pawn is currently crouched
var const bool	bTryToUncrouch;		// when auto-crouch during movement, continually try to uncrouch
var() bool		bCanCrouch;			// if true, this pawn is capable of crouching
var bool		bCrawler;			// crawling - pitch and roll based on surface pawn is on
var const bool	bReducedSpeed;		// used by movement natives
var bool		bJumpCapable;
var	bool		bCanJump;			// movement capabilities - used by AI
var	bool 		bCanWalk;
var	bool		bCanSwim;
var	bool		bCanFly;
var	bool		bCanClimbLadders;
var	bool		bCanStrafe;
var	bool		bCanDoubleJump;
var bool		bCanWallDodge;
var	bool		bAvoidLedges;		// don't get too close to ledges
var	bool		bStopAtLedges;		// if bAvoidLedges and bStopAtLedges, Pawn doesn't try to walk along the edge at all
var	bool		bNoJumpAdjust;		// set to tell controller not to modify velocity of a jump/fall
var	bool		bCountJumps;		// if true, inventory wants message whenever this pawn jumps
var const bool	bSimulateGravity;	// simulate gravity for this pawn on network clients when predicting position (true if pawn is walking or falling)
var	bool		bUpdateEyeheight;	// if true, UpdateEyeheight will get called every tick
var	bool		bIgnoreForces;		// if true, not affected by external forces
var const bool	bNoVelocityUpdate;	// used by C++ physics
var	bool		bCanWalkOffLedges;	// Can still fall off ledges, even when walking (for Player Controlled pawns)
var bool		bSteadyFiring;		// used for third person weapon anims/effects
var bool		bCanBeBaseForPawns;	// all your 'base', are belong to us
var bool		bClientCollision;	// used on clients when temporarily turning off collision
var const bool	bSimGravityDisabled;	// used on network clients
var bool		bDirectHitWall;		// always call pawn hitwall directly (no controller notifyhitwall)
var bool		bServerMoveSetPawnRot;
var bool        bFlyingKarma;       // Tells AI that this vehicle can be flown like PHYS_Flying even though it has karma physics
var bool		bDrawCorona;
var globalconfig bool bNoCoronas;

// used by dead pawns (for bodies landing and changing collision box)
var		bool	bThumped;
var		bool	bInvulnerableBody;

// AI related flags
var		bool	bIsFemale;
var		bool	bAutoActivate;			// if true, automatically activate Powerups which have their bAutoActivate==true
var		bool	bCanPickupInventory;	// if true, will pickup inventory when touching pickup actors
var		bool	bUpdatingDisplay;		// to avoid infinite recursion through inventory setdisplay
var		bool	bAmbientCreature;		// AIs will ignore me
var(AI) bool	bLOSHearing;			// can hear sounds from line-of-sight sources (which are close enough to hear)
										// bLOSHearing=true is like UT/Unreal hearing
var(AI) bool	bSameZoneHearing;		// can hear any sound in same zone (if close enough to hear)
var(AI) bool	bAdjacentZoneHearing;	// can hear any sound in adjacent zone (if close enough to hear)
var(AI) bool	bMuffledHearing;		// can hear sounds through walls (but muffled - sound distance increased to double plus 4x the distance through walls
var(AI) bool	bAroundCornerHearing;	// Hear sounds around one corner (slightly more expensive, and bLOSHearing must also be true)
var(AI) bool	bDontPossess;			// if true, Pawn won't be possessed at game start
var		bool	bAutoFire;				// used for third person weapon anims/effects
var		bool	bRollToDesired;			// Update roll when turning to desired rotation (normally false)
var		bool	bIgnorePlayFiring;		// if true, ignore the next PlayFiring() call (used by AnimNotify_FireWeapon)
var		bool	bStationary;			// pawn can't move

var		bool	bCachedRelevant;		// network relevancy caching flag
var		bool	bUseCompressedPosition;	// use compressed position in networking - true unless want to replicate roll, or very high velocities
var		globalconfig bool bWeaponBob;
var     bool    bHideRegularHUD;
var		bool	bSpecialHUD;
var		bool	bSpecialCrosshair;
var		bool    bSpecialCalcView;		// If true, the Controller controlling this pawn will call 'SpecialCalcView' to find camera pos.
var		bool	bNoTeamBeacon;			// never display team beacon for this pawn
var		bool	bNoWeaponFiring;
var		bool	bIsTyping;				// play typing anim if idle
var		bool	bScriptPostRender;		// if true, PostRender2D() gets called instead of native team beacon drawing code
var		bool	bCanUse;			// can this pawn Use things?
var		bool	bSuperSize;				// hack for Leviathan
var		bool	bWaterStepup;			// used by get out of water physics code

var		byte	FlashCount;				// used for third person weapon anims/effects
// AI basics.
var 	byte	Visibility;			//How visible is the pawn? 0=invisible, 128=normal, 255=highly visible

var		float	DesiredSpeed;
var		float	MaxDesiredSpeed;
var(AI) name	AIScriptTag;		// tag of AIScript which should be associated with this pawn
var(AI) float	HearingThreshold;	// max distance at which a makenoise(1.0) loudness sound can be heard
var(AI)	float	Alertness;			// -1 to 1 ->Used within specific states for varying reaction to stimuli
var(AI)	float	SightRadius;		// Maximum seeing distance.
var(AI)	float	PeripheralVision;	// Cosine of limits of peripheral vision.
var()	float	SkillModifier;			// skill modifier (same scale as game difficulty)
var const float	AvgPhysicsTime;		// Physics updating time monitoring (for AI monitoring reaching destinations)
var		float	MeleeRange;			// Max range for melee attack (not including collision radii)
var		float	NavigationPointRange;	// extra slack to have "reached" a NavigationPoint
var NavigationPoint Anchor;			// current nearest path;
var const NavigationPoint LastAnchor;		// recent nearest path
var		float	FindAnchorFailedTime;	// last time a FindPath() attempt failed to find an anchor.
var		float	LastValidAnchorTime;	// last time a valid anchor was found
var		float	DestinationOffset;	// used to vary destination over NavigationPoints
var		float	NextPathRadius;		// radius of next path in route
var		vector	SerpentineDir;		// serpentine direction
var		float	SerpentineDist;
var		float	SerpentineTime;		// how long to stay straight before strafing again
var const float	UncrouchTime;		// when auto-crouch during movement, continually try to uncrouch once this decrements to zero
var		float	SpawnTime;

// Movement.
var float   GroundSpeed;    // The maximum ground speed.
var float   WaterSpeed;     // The maximum swimming speed.
var float   AirSpeed;		// The maximum flying speed.
var float	LadderSpeed;	// Ladder climbing speed
var float	AccelRate;		// max acceleration rate
var float	JumpZ;      	// vertical acceleration w/ jump
var float   AirControl;		// amount of AirControl available to the pawn
var float	WalkingPct;		// pct. of running speed that walking speed is
var float	CrouchedPct;	// pct. of running speed that crouched walking speed is
var float	MaxFallSpeed;	// max speed pawn can land without taking damage (also limits what paths AI can use)
var vector	ConstantAcceleration;	// acceleration added to pawn when falling
var Vehicle DrivenVehicle;
var vector	ImpactVelocity;	// velocity added while falling (bot tries to correct for it)
var() int PitchUpLimit;
var() int PitchDownLimit;

// Player info.
var	string			OwnerName;		// Name of owning player (for save games, coop)
var travel Weapon	Weapon;			// The pawn's current weapon.
var Weapon			PendingWeapon;	// Will become weapon once current weapon is put down
var travel Powerups	SelectedItem;	// currently selected inventory item
var float      		BaseEyeHeight; 	// Base eye height above collision center.
var float        	EyeHeight;     	// Current eye height, adjusted for bobbing and stairs.
var	vector			Floor;			// Normal of floor pawn is standing on (only used by PHYS_Spider and PHYS_Walking)
var float			SplashTime;		// time of last splash
var float			CrouchHeight;	// CollisionHeight when crouching
var float			CrouchRadius;	// CollisionRadius when crouching
var() float			DrivingHeight;  // CollisionHeight when driving a vehicle
var() float			DrivingRadius;  // CollisionRadius when driving a vehicle
var float			OldZ;			// Old Z Location - used for eyeheight smoothing
var PhysicsVolume	HeadVolume;		// physics volume of head
var float           HealthMax;
var float           SuperHealthMax;
var travel int      Health;         // Health: 100 = normal maximum
var	float			BreathTime;		// used for getting BreathTimer() messages (for no air, etc.)
var float			UnderWaterTime; // how much time pawn can go without air (in seconds)
var	float			LastPainTime;	// last time pawn played a takehit animation (updated in PlayHit())
var class<DamageType> ReducedDamageType; // which damagetype this creature is protected from (used by AI)
var float           HeadRadius;     // Squared radius of the head of the pawn that is vulnerable to headshots
var float           HeadHeight;     // Distance from base of neck to center of head - used for headshot calculation
var float			HeadScale;
var bool			bSetPCRotOnPossess;

// Sound and noise management
// remember location and position of last noises propagated
var const 	vector 		noise1spot;
var const 	float 		noise1time;
var const	pawn		noise1other;
var const	float		noise1loudness;
var const 	vector 		noise2spot;
var const 	float 		noise2time;
var const	pawn		noise2other;
var const	float		noise2loudness;
var			float		LastPainSound;

// view bob
var				globalconfig float Bob;
var				float				LandBob, AppliedBob;
var				float bobtime;
var				vector			WalkBob;

var float SoundDampening;
var float DamageScaling;
var globalconfig float AmbientSoundScaling;

var localized  string MenuName; // Name used for this pawn type in menus (e.g. player selection)

// shadow decal
var Projector Shadow;

// blood effect
var class<Effects> BloodEffect;
var class<Effects> LowGoreBlood;

var class<AIController> ControllerClass;	// default class to use when pawn is controlled by AI (can be modified by an AIScript)

var PlayerReplicationInfo PlayerReplicationInfo;

var LadderVolume OnLadder;		// ladder currently being climbed

var name LandMovementState;		// PlayerControllerState to use when moving on land or air
var name WaterMovementState;	// PlayerControllerState to use when moving in water

var PlayerStart LastStartSpot;	// used to avoid spawn camping
var float LastStartTime;

// Animation status
var name AnimAction;			// use for replicating anims

// Animation updating by physics
// Note that animation channels 2 through 11 are used for animation updating
var vector TakeHitLocation;		// location of last hit (for playing hit/death anims)
var class<DamageType> HitDamageType;	// damage type of last hit (for playing hit/death anims)
var vector TearOffMomentum;		// momentum to apply when torn off (bTearOff == true)
var EPhysics OldPhysics;
var bool bPhysicsAnimUpdate;
var bool bWasCrouched;
var bool bWasWalking;
var bool bWasOnGround;
var bool bInitializeAnimation;
var bool bPlayedDeath;

// jjs - physics based animation stuff
var bool bIsIdle;           // true when standing still on the ground, Physics can be used for determining other states
var bool bWaitForAnim;      // true if the pawn is playing an important non-looping animation (eg. landing/dodge) and doesn't feel like being interrupted
var const bool bReverseRun;
var bool bDoTorsoTwist;
var const bool FootTurning;
var const bool FootStill;

var const byte		ViewPitch;      // jjs - something to replicate so we can see which way remote clients are looking
var int		SmoothViewPitch;
var int		SmoothViewYaw;

var float OldRotYaw;			// used for determining if pawn is turning
var vector OldAcceleration;
var name MovementAnims[4];		// Forward, Back, Left, Right
var name TurnLeftAnim;
var name TurnRightAnim;			// turning anims when standing in place (scaled by turn speed)
var(AnimTweaks) float BlendChangeTime;	// time to blend between movement animations
var float MovementBlendStartTime;	// used for delaying the start of run blending
var float ForwardStrafeBias;	// bias of strafe blending in forward direction
var float BackwardStrafeBias;	// bias of strafe blending in backward direction

var float DodgeSpeedFactor; // dodge speed moved here so animation knows the diff between a jump and a dodge
var float DodgeSpeedZ;

var const int OldAnimDir;
var const Vector OldVelocity;
var float IdleTime;

var name SwimAnims[4];      // 0=forward, 1=backwards, 2=left, 3=right
var name CrouchAnims[4];
var name WalkAnims[4];
var name AirAnims[4];
var name TakeoffAnims[4];
var name LandAnims[4];
var name DoubleJumpAnims[4];
var name DodgeAnims[4];
var name AirStillAnim;
var name TakeoffStillAnim;
var name CrouchTurnRightAnim;
var name CrouchTurnLeftAnim;
var name IdleCrouchAnim;
var name IdleSwimAnim;
var name IdleWeaponAnim;    // WeaponAttachment code will set this one
var name IdleRestAnim;
var name IdleChatAnim;

var array<name> TauntAnims; // Array of names of taunt anim that can be played by this character. First 4 assumed to be orders.
var localized string TauntAnimNames[16]; // Text description

var const int  FootRot;     // torso twisting/looking stuff
var const int  TurnDir;
var name RootBone;
var name HeadBone;
var name SpineBone1;
var name SpineBone2;

// xPawn replicated properties - moved here to take advantage of native replication
var(Shield) transient float ShieldStrength;          // current shielding (having been activated)

struct HitFXData
{
    var() Name    Bone;
    var() class<DamageType> damtype;
    var() bool bSever;
    var() Rotator rotDir;
};

var() HitFXData HitFx[8];
var transient int   HitFxTicker;

var transient CompressedPosition PawnPosition;
var Controller DelayedDamageInstigatorController;
var Controller LastHitBy; //give kill credit to this guy if hit momentum causes pawn to fall to his death
var float MinFlySpeed;
var float MaxRotation;				// minimum dot product of movement direction and rotation vector, ignored if 0

replication
{
	// Variables the server should send to the client.
	reliable if( bNetDirty && (Role==ROLE_Authority) )
        bSimulateGravity, bIsCrouched, bIsWalking, PlayerReplicationInfo, AnimAction, HitDamageType, TakeHitLocation,HeadScale, bIsTyping, DrivenVehicle, bSpecialHUD;
	reliable if( bTearOff && bNetDirty && (Role==ROLE_Authority) )
		TearOffMomentum;
	reliable if ( bNetDirty && !bNetOwner && (Role==ROLE_Authority) )
        bSteadyFiring, ViewPitch; // - jjs
	reliable if( bNetDirty && bNetOwner && Role==ROLE_Authority )
         Controller,SelectedItem, GroundSpeed, WaterSpeed, AirSpeed, AccelRate, JumpZ, AirControl, bCanWallDodge, PitchUpLimit, PitchDownLimit;
	reliable if( bNetDirty && Role==ROLE_Authority )
         Health;
	reliable if ( bNetDirty && bNetInitial && Role==ROLE_Authority )
	 HealthMax;
    unreliable if ( !bNetOwner && Role==ROLE_Authority )
		PawnPosition;

    // xPawn replicated properties - moved here to take advantage of native replication
    reliable if (Role==ROLE_Authority)
        ShieldStrength, HitFx, HitFxTicker;

	// replicated functions sent to server by owning client
	reliable if( Role<ROLE_Authority )
		ServerChangedWeapon, NextItem, ServerNoTranslocator;

}

static function StaticPrecache(LevelInfo L);
simulated native function SetViewPitch( int NewPitch );
simulated native function SetTwistLook( int twist, int look );
simulated native function int Get4WayDirection( );
simulated event SetHeadScale(float NewScale);

simulated event PostRender2D(Canvas C, float ScreenLocX, float ScreenLocY)  // called if bScriptPostRender is true, overrides native team beacon drawing code
{
	local PlayerController PC;

	PC = Level.GetLocalPlayerController();

	if ( (PC != None) && (PC.myHUD != None) )
		PC.myHUD.DrawCustomBeacon(C,self, ScreenLocX, ScreenLocY);
}

native function bool ReachedDestination(Actor Goal);
native function ForceCrouch();

simulated function Weapon GetDemoRecordingWeapon()
{
	local inventory Inv;
	local int i;

	for ( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if ( (Weapon(Inv) != None) && (Inv.ThirdPersonActor != None) )
		{
			Weapon = Weapon(Inv);
			PendingWeapon = Weapon;
			Weapon.bSpectated = true;
			break;
		}
		i++;
		if ( i > 500 )
			return None;
	}
	return Weapon;
}

simulated function SetBaseEyeheight()
{
	if ( !bIsCrouched )
		BaseEyeheight = Default.BaseEyeheight;
	else
		BaseEyeheight = FMin(0.8 * CrouchHeight, CrouchHeight - 10);

	Eyeheight = BaseEyeheight;
}

function Pawn GetAimTarget()
{
	return self;
}

function DeactivateSpawnProtection()
{
	SpawnTime = -100000;
}

function Actor GetPathTo(Actor Dest)
{
	if ( PlayerController(Controller) == None )
		return Dest;

	return PlayerController(Controller).GetPathTo(Dest);
}

function PlayerChangedTeam()
{
	Died( None, class'DamageType', Location );
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	if ( (Controller == None) || Controller.bIsPlayer )
	{
		if ( Controller != None )
			Controller.PawnDied(self);
		Destroy();
	}
	else
		Super.Reset();
}

function bool HasWeapon()
{
	return (Weapon != None);
}

function ChooseFireAt( Actor A )
{
    Fire(0);
}

function bool StopWeaponFiring()
{
	if (Weapon != None && Weapon.IsFiring())
	{
		Weapon.ServerStopFire(0);
		Weapon.ServerStopFire(1);
		return true;
	}
	return false;
}

simulated function Fire( optional float F )
{
	if (Weapon != None)
	{
	    Weapon.Fire(F);
	}
}

simulated function AltFire( optional float F )
{
	if( Weapon!=None )
        Weapon.AltFire(F);
}

function bool RecommendLongRangedAttack()
{
	if ( Weapon != None )
		return Weapon.RecommendLongRangedAttack();
	return false;
}

function bool CanAttack(Actor Other)
{
	if ( Weapon == None )
		return false;
	return Weapon.CanAttack(Other);
}

function bool TooCloseToAttack(Actor Other)
{
	return false;
}

function float RefireRate()
{
	if (Weapon != None)
		return Weapon.RefireRate();

	return 0;
}

function bool IsFiring()
{
	if (Weapon != None)
		return Weapon.IsFiring();

	return false;
}

function bool FireOnRelease()
{
	if (Weapon != None)
		return Weapon.FireOnRelease();

	return false;
}

function bool NeedToTurn(vector targ)
{
	local vector LookDir, AimDir;

	LookDir = Vector(Rotation);
	LookDir.Z = 0;
	LookDir = Normal(LookDir);
	AimDir = targ - Location;
	AimDir.Z = 0;
	AimDir = Normal(AimDir);

	return ((LookDir Dot AimDir) < 0.93);
}

function float ModifyThreat(float current, Pawn Threat)
{
	return current;
}

function DrawHUD(Canvas Canvas);
simulated function SpecialDrawCrosshair( Canvas C );

// If returns false, do normal calcview anyway
function bool SpecialCalcView(out Actor ViewActor, out vector CameraLocation, out rotator CameraRotation);
function bool SpectatorSpecialCalcView(PlayerController Viewer, out Actor ViewActor, out vector CameraLocation, out rotator CameraRotation);

simulated function String GetHumanReadableName()
{
	if ( PlayerReplicationInfo != None )
		return PlayerReplicationInfo.PlayerName;
	return MenuName;
}

function PlayTeleportEffect(bool bOut, bool bSound)
{
	MakeNoise(1.0);
}

function HoldFlag(Actor FlagActor);
function DropFlag();

function bool PerformDodge(eDoubleClickDir DoubleClickMove, vector Dir, vector Cross);

function NotifyTeamChanged();

/* PossessedBy()
 Pawn is possessed by Controller
*/
function PossessedBy(Controller C)
{
	Controller = C;
	NetPriority = 3;
	NetUpdateFrequency = 100;
	NetUpdateTime = Level.TimeSeconds - 1;
	if ( C.PlayerReplicationInfo != None )
	{
		PlayerReplicationInfo = C.PlayerReplicationInfo;
		OwnerName = PlayerReplicationInfo.PlayerName;
	}
	if ( C.IsA('PlayerController') )
	{
		if ( bSetPCRotOnPossess )
			C.SetRotation(Rotation);
		if ( Level.NetMode != NM_Standalone )
			RemoteRole = ROLE_AutonomousProxy;
		BecomeViewTarget();
	}
	else
		RemoteRole = Default.RemoteRole;

	SetOwner(Controller);	// for network replication
	Eyeheight = BaseEyeHeight;
	ChangeAnimation();
}

function UnPossessed()
{
	NetUpdateTime = Level.TimeSeconds - 1;
	if ( DrivenVehicle != None )
		NetUpdateFrequency = 5;

	PlayerReplicationInfo = None;
	SetOwner(None);
	Controller = None;
}

/* PointOfView()
called by controller when possessing this pawn
false = 1st person, true = 3rd person
*/
simulated function bool PointOfView()
{
	return false;
}

function BecomeViewTarget()
{
	bUpdateEyeHeight = true;
}

function DropToGround()
{
	bCollideWorld = True;
	bInterpolating = false;
	if ( Health > 0 )
	{
		SetCollision(true,true);
		SetPhysics(PHYS_Falling);
		AmbientSound = None;
		if ( IsHumanControlled() )
			Controller.GotoState(LandMovementState);
	}
}

function bool CanGrabLadder()
{
	return ( bCanClimbLadders
			&& (Controller != None)
			&& (Physics != PHYS_Ladder)
			&& ((Physics != Phys_Falling) || (abs(Velocity.Z) <= JumpZ)) );
}

event SetWalking(bool bNewIsWalking)
{
	if ( bNewIsWalking != bIsWalking )
	{
		bIsWalking = bNewIsWalking;
		ChangeAnimation();
	}
}

simulated function bool CanSplash()
{
	if ( (Level.TimeSeconds - SplashTime > 0.15)
		&& ((Physics == PHYS_Falling) || (Physics == PHYS_Flying))
		&& (Abs(Velocity.Z) > 100) )
	{
		SplashTime = Level.TimeSeconds;
		return true;
	}
	return false;
}

function EndClimbLadder(LadderVolume OldLadder)
{
	if ( Controller != None )
		Controller.EndClimbLadder();
	if ( Physics == PHYS_Ladder )
		SetPhysics(PHYS_Falling);
}

function ClimbLadder(LadderVolume L)
{
	OnLadder = L;
	SetRotation(OnLadder.WallDir);
	SetPhysics(PHYS_Ladder);
	if ( IsHumanControlled() )
		Controller.GotoState('PlayerClimbing');
}

/* DisplayDebug()
list important actor variable on canvas.  Also show the pawn's controller and weapon info
*/
simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local string T;
	Super.DisplayDebug(Canvas, YL, YPos);

	Canvas.SetDrawColor(255,255,255);

	Canvas.DrawText("Animation Action "$AnimAction$" Health "$Health);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("Anchor "$Anchor$" Serpentine Dist "$SerpentineDist$" Time "$SerpentineTime);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	T = "Floor "$Floor$" DesiredSpeed "$DesiredSpeed$" Crouched "$bIsCrouched$" Try to uncrouch "$UncrouchTime;
	if ( (OnLadder != None) || (Physics == PHYS_Ladder) )
		T=T$" on ladder "$OnLadder;
	Canvas.DrawText(T);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("EyeHeight "$Eyeheight$" BaseEyeHeight "$BaseEyeHeight$" Physics Anim "$bPhysicsAnimUpdate);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	if ( Controller == None )
	{
		Canvas.SetDrawColor(255,0,0);
		Canvas.DrawText("NO CONTROLLER");
		YPos += YL;
		Canvas.SetPos(4,YPos);
	}
	else
	{
		if ( Controller.PlayerReplicationInfo != None )
		{
			Canvas.SetDrawColor(255,0,0);
			Canvas.DrawText("Owned by "$Controller.PlayerReplicationInfo.PlayerName);
			YPos += YL;
			Canvas.SetPos(4,YPos);
		}
		Controller.DisplayDebug(Canvas,YL,YPos);
	}
	if ( Weapon == None )
	{
		Canvas.SetDrawColor(0,255,0);
		Canvas.DrawText("NO WEAPON");
		YPos += YL;
		Canvas.SetPos(4,YPos);
	}
	else
		Weapon.DisplayDebug(Canvas,YL,YPos);
}

//
// Compute offset for drawing an inventory item.
//
simulated function vector CalcDrawOffset(inventory Inv)
{
	local vector DrawOffset;

	if ( Controller == None )
		return (Inv.PlayerViewOffset >> Rotation) + BaseEyeHeight * vect(0,0,1);

	DrawOffset = ((0.9/Weapon.DisplayFOV * 100 * ModifiedPlayerViewOffset(Inv)) >> GetViewRotation() );
	if ( !IsLocallyControlled() )
		DrawOffset.Z += BaseEyeHeight;
	else
	{
		DrawOffset.Z += EyeHeight;
        if( bWeaponBob )
		    DrawOffset += WeaponBob(Inv.BobDamping);
         DrawOffset += CameraShake();
	}
	return DrawOffset;
}

simulated function vector CameraShake()
{
    local vector x, y, z, shakevect;
    local PlayerController pc;

    pc = PlayerController(Controller);

    if (pc == None)
        return shakevect;

    GetAxes(pc.Rotation, x, y, z);

    shakevect = pc.ShakeOffset.X * x +
                pc.ShakeOffset.Y * y +
                pc.ShakeOffset.Z * z;

    return shakevect;
}

simulated function vector ModifiedPlayerViewOffset(inventory Inv)
{
	return Inv.PlayerViewOffset;
}

simulated function vector WeaponBob(float BobDamping)
{
	Local Vector WBob;

	WBob = BobDamping * WalkBob;
	WBob.Z = (0.45 + 0.55 * BobDamping) * WalkBob.Z;
	WBob.Z += LandBob;
	return WBob;
}

function CheckBob(float DeltaTime, vector Y)
{
	local float Speed2D;

    if( !bWeaponBob || bJustLanded )
    {
		BobTime = 0;
		WalkBob = Vect(0,0,0);
        return;
    }
	Bob = FClamp(Bob, -0.01, 0.01);
	if (Physics == PHYS_Walking )
	{
		Speed2D = VSize(Velocity);
		if ( Speed2D < 10 )
			BobTime += 0.2 * DeltaTime;
		else
			BobTime += DeltaTime * (0.3 + 0.7 * Speed2D/GroundSpeed);
		WalkBob = Y * Bob * Speed2D * sin(8 * BobTime);
		AppliedBob = AppliedBob * (1 - FMin(1, 16 * deltatime));
		WalkBob.Z = AppliedBob;
		if ( Speed2D > 10 )
			WalkBob.Z = WalkBob.Z + 0.75 * Bob * Speed2D * sin(16 * BobTime);
	}
	else if ( Physics == PHYS_Swimming )
	{
		BobTime += DeltaTime;
		Speed2D = Sqrt(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y);
		WalkBob = Y * Bob *  0.5 * Speed2D * sin(4.0 * BobTime);
		WalkBob.Z = Bob * 1.5 * Speed2D * sin(8.0 * BobTime);
	}
	else
	{
		BobTime = 0;
		WalkBob = WalkBob * (1 - FMin(1, 8 * deltatime));
	}
}

//***************************************
// Vehicle driving
// StartDriving() and StopDriving() also called on client
// on transitions of bIsDriving setting

simulated event StartDriving(Vehicle V)
{
	DrivenVehicle = V;
	NetUpdateTime = Level.TimeSeconds - 1;
    AmbientSound = None;
    StopWeaponFiring();
	DeactivateSpawnProtection();

	// Move the driver into position, and attach to car.
	ShouldCrouch(false);
	bIgnoreForces = true;
	Velocity = vect(0,0,0);
	Acceleration = vect(0,0,0);
	bCanTeleport = false;

	if ( !V.bRemoteControlled || V.bHideRemoteDriver )
    {
		SetCollision( False, False, False);
		bCollideWorld = false;
		V.AttachDriver( Self );
		if ( V.bDrawDriverinTP )
			CullDistance = 5000;
		else
		   	bHidden = true;
    }

	// set animation
	bPhysicsAnimUpdate = false;
	bWaitForAnim = false;
	if ( !V.bHideRemoteDriver && V.bDrawDriverinTP )
	{
		if ( HasAnim(DrivenVehicle.DriveAnim) )
			LoopAnim(DrivenVehicle.DriveAnim);
		else
			LoopAnim('Vehicle_Driving');
		SetAnimFrame(0.5);
		SmoothViewYaw = Rotation.Yaw;
		SetTwistLook(0,0);
	}
	else if ( !V.bRemoteControlled )
	{
		LoopAnim('Vehicle_Driving');
	}
}

simulated event StopDriving(Vehicle V)
{
	if ( (Role == ROLE_Authority) && (PlayerController(Controller) != None) )
		V.PlayerStartTime = Level.TimeSeconds + 12;
	CullDistance = Default.CullDistance;
	NetUpdateTime = Level.TimeSeconds - 1;

	if (V != None && V.Weapon != None )
    	V.Weapon.ImmediateStopFire();

	if ( Physics == PHYS_Karma )
		return;

	DrivenVehicle	= None;
	bIgnoreForces	= false;
	bHardAttach	= false;
	bWaitForAnim	= false;
	bCanTeleport	= true;
	bCollideWorld	= true;
	PlayWaiting();
	//PrePivot = vect(0,0,0);

	if ( V != None )
		V.DetachDriver( Self );

	bPhysicsAnimUpdate = Default.bPhysicsAnimUpdate;
	SetCollision(True, True);

	if ( (Role == ROLE_Authority) && (Health > 0) )
	{
    	if ( !V.bRemoteControlled || V.bHideRemoteDriver )
        {
			Acceleration = vect(0, 0, 24000);
			if ( PhysicsVolume.bWaterVolume )
				SetPhysics(PHYS_Swimming);
			else
				SetPhysics(PHYS_Falling);
			SetBase(None);
			bHidden = false;
        }
	}

    bOwnerNoSee = default.bOwnerNoSee;

	if ( Weapon != None )
	{
		PendingWeapon = None;
		Weapon.BringUp();
	}
}

simulated function bool FindValidTaunt( out name Sequence )
{
	return true;
}

// CheckTauntValid() is obsolete, use FindValidTaunt()
simulated function bool CheckTauntValid( name Sequence )
{
	return FindValidTaunt(sequence);
}

//***************************************
// Interface to Pawn's Controller

// return true if controlled by a Player (AI or human)
simulated function bool IsPlayerPawn()
{
	return ( (Controller != None) && Controller.bIsPlayer );
}

// return true if was controlled by a Player (AI or human)
simulated function bool WasPlayerPawn()
{
	return false;
}

// return true if controlled by a real live human
simulated function bool IsHumanControlled()
{
	return ( PlayerController(Controller) != None );
}

// return true if controlled by local (not network) player
simulated function bool IsLocallyControlled()
{
	if ( Level.NetMode == NM_Standalone )
		return true;
	if ( Controller == None )
		return false;
	if ( PlayerController(Controller) == None )
		return true;

	return ( Viewport(PlayerController(Controller).Player) != None );
}

// return true if viewing this pawn in first person pov. useful for determining what and where to spawn effects
simulated function bool IsFirstPerson()
{
    local PlayerController PC;

    PC = PlayerController(Controller);
    return ( PC != None && !PC.bBehindView && Viewport(PC.Player) != None );
}

simulated function rotator GetViewRotation()
{
	if ( Controller == None )
		return Rotation;
	return Controller.GetViewRotation();
}

simulated function SetViewRotation(rotator NewRotation )
{
	if ( Controller != None )
		Controller.SetRotation(NewRotation);
}

final function bool InGodMode()
{
	return ( (Controller != None) && Controller.bGodMode );
}

function bool NearMoveTarget()
{
	if ( (Controller == None) || (Controller.MoveTarget == None) )
		return false;

	return ReachedDestination(Controller.MoveTarget);
}

simulated final function bool PressingFire()
{
	return ( (Controller != None) && (Controller.bFire != 0) );
}

simulated final function bool PressingAltFire()
{
	return ( (Controller != None) && (Controller.bAltFire != 0) );
}

function Actor GetMoveTarget()
{
	if ( Controller == None )
		return None;

	return Controller.MoveTarget;
}

function SetMoveTarget(Actor NewTarget )
{
	if ( Controller != None )
		Controller.MoveTarget = NewTarget;
}

function bool LineOfSightTo(actor Other)
{
	return ( (Controller != None) && Controller.LineOfSightTo(Other) );
}

simulated final function rotator AdjustAim(FireProperties FiredAmmunition, vector projStart, int aimerror)
{
	if ( Controller == None )
		return Rotation;

	return Controller.AdjustAim(FiredAmmunition, projStart, aimerror);
}

function Actor ShootSpecial(Actor A)
{
	if ( !Controller.bCanDoSpecial || (Weapon == None) )
		return None;

	SetRotation(rotator(A.Location - Location));
	Controller.Focus = A;
	Controller.FireWeaponAt(A);
	return A;
}

/* return a value (typically 0 to 1) adjusting pawn's perceived strength if under some special influence (like berserk)
*/
function float AdjustedStrength()
{
	return 0;
}

function HandlePickup(Pickup pick)
{
	MakeNoise(0.2);
	if ( Controller != None )
		Controller.HandlePickup(pick);
}

function ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	if ( PlayerController(Controller) != None )
		PlayerController(Controller).ReceiveLocalizedMessage( Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
}

event ClientMessage( coerce string S, optional Name Type )
{
	if ( PlayerController(Controller) != None )
		PlayerController(Controller).ClientMessage( S, Type );
}

function Trigger( actor Other, pawn EventInstigator )
{
	if ( Controller != None )
		Controller.Trigger(Other, EventInstigator);
}

//***************************************

function bool CanTrigger(Trigger T)
{
	return true;
}

function CreateInventory(string InventoryClassName)
{
}

function GiveWeapon(string aClassName )
{
	local class<Weapon> WeaponClass;
	local Weapon NewWeapon;

	WeaponClass = class<Weapon>(DynamicLoadObject(aClassName, class'Class'));

	if( FindInventoryType(WeaponClass) != None )
		return;
	newWeapon = Spawn(WeaponClass);
	if( newWeapon != None )
		newWeapon.GiveTo(self);
}

function SetDisplayProperties(ERenderStyle NewStyle, Material NewTexture, bool bLighting )
{
	Style = NewStyle;
	Texture = NewTexture;
	bUnlit = bLighting;
	if ( Weapon != None )
		Weapon.SetDisplayProperties(Style, Texture, bUnlit);

	if ( !bUpdatingDisplay && (Inventory != None) )
	{
		bUpdatingDisplay = true;
		Inventory.SetOwnerDisplay();
	}
	bUpdatingDisplay = false;
}

function SetDefaultDisplayProperties()
{
	Style = Default.Style;
	texture = Default.Texture;
	bUnlit = Default.bUnlit;
	if ( Weapon != None )
		Weapon.SetDefaultDisplayProperties();

	if ( !bUpdatingDisplay && (Inventory != None) )
	{
		bUpdatingDisplay = true;
		Inventory.SetOwnerDisplay();
	}
	bUpdatingDisplay = false;
}

function FinishedInterpolation()
{
	DropToGround();
}

function JumpOutOfWater(vector jumpDir)
{
	Falling();
	Velocity = jumpDir * WaterSpeed;
	Acceleration = jumpDir * AccelRate;
	velocity.Z = FMax(380,JumpZ); //set here so physics uses this for remainder of tick
	bUpAndOut = true;
}

/*
Modify velocity called by physics before applying new velocity
for this tick.

Velocity,Acceleration, etc. have been updated by the physics, but location hasn't
*/
simulated event ModifyVelocity(float DeltaTime, vector OldVelocity);

event FellOutOfWorld(eKillZType KillType)
{
	if ( Level.NetMode == NM_Client )
		return;
	if ( (Controller != None) && Controller.AvoidCertainDeath() )
		return;

	Health = -1;

	if( KillType == KILLZ_Lava)
		Died( None, class'FellLava', Location );
	else if(KillType == KILLZ_Suicide)
		Died( None, class'Fell', Location );
	else
	{
		if ( Physics != PHYS_Karma )
			SetPhysics(PHYS_None);
		Died( None, class'Fell', Location );
	}
}

/* ShouldCrouch()
Controller is requesting that pawn crouch
*/
function ShouldCrouch(bool Crouch)
{
	if ( bWantsToCrouch != Crouch )
		bWantsToCrouch = Crouch;
}

// Stub events called when physics actually allows crouch to begin or end
// use these for changing the animation (if script controlled)
event EndCrouch(float HeightAdjust)
{
	EyeHeight -= HeightAdjust;
	OldZ += HeightAdjust;
	BaseEyeHeight = Default.BaseEyeHeight;
}

event StartCrouch(float HeightAdjust)
{
	EyeHeight += HeightAdjust;
	OldZ -= HeightAdjust;
	BaseEyeHeight = FMin(0.8 * CrouchHeight, CrouchHeight - 10);
}

function RestartPlayer();
function AddVelocity( vector NewVelocity)
{
	if ( bIgnoreForces || (NewVelocity == vect(0,0,0)) )
		return;
	if ( (Physics == PHYS_Falling) && (AIController(Controller) != None) )
		ImpactVelocity += NewVelocity;
	if ( (Physics == PHYS_Walking)
		|| (((Physics == PHYS_Ladder) || (Physics == PHYS_Spider)) && (NewVelocity.Z > Default.JumpZ)) )
		SetPhysics(PHYS_Falling);
	if ( (Velocity.Z > 380) && (NewVelocity.Z > 0) )
		NewVelocity.Z *= 0.5;
	Velocity += NewVelocity;
}

function KilledBy( pawn EventInstigator )
{
	local Controller Killer;

	Health = 0;
	if ( EventInstigator != None )
		Killer = EventInstigator.Controller;
	Died( Killer, class'Suicided', Location );
}

function TakeFallingDamage()
{
	local float Shake, EffectiveSpeed;

	if (Velocity.Z < -0.5 * MaxFallSpeed)
	{
		if ( Role == ROLE_Authority )
		{
		    MakeNoise(1.0);
		    if (Velocity.Z < -1 * MaxFallSpeed)
		    {
				EffectiveSpeed = Velocity.Z;
				if ( TouchingWaterVolume() )
					EffectiveSpeed = FMin(0, EffectiveSpeed + 100);
				if ( EffectiveSpeed < -1 * MaxFallSpeed )
					TakeDamage(-100 * (EffectiveSpeed + MaxFallSpeed)/MaxFallSpeed, None, Location, vect(0,0,0), class'Fell');
		    }
		}
		if ( Controller != None )
		{
			Shake = FMin(1, -1 * Velocity.Z/MaxFallSpeed);
            Controller.DamageShake(Shake);
		}
	}
	else if (Velocity.Z < -1.4 * JumpZ)
		MakeNoise(0.5);
}

function ClientReStart()
{
	Velocity = vect(0,0,0);
	Acceleration = vect(0,0,0);
	BaseEyeHeight = Default.BaseEyeHeight;
	EyeHeight = BaseEyeHeight;
	PlayWaiting();
}

function ClientSetLocation( vector NewLocation, rotator NewRotation )
{
	if ( Controller != None )
		Controller.ClientSetLocation(NewLocation, NewRotation);
}

function ClientSetRotation( rotator NewRotation )
{
	if ( Controller != None )
		Controller.ClientSetRotation(NewRotation);
}

simulated function FaceRotation( rotator NewRotation, float DeltaTime )
{
	if ( Physics == PHYS_Ladder )
		SetRotation(OnLadder.Walldir);
	else
	{
		if ( (Physics == PHYS_Walking) || (Physics == PHYS_Falling) )
			NewRotation.Pitch = 0;
		SetRotation(NewRotation);
	}
}

function int LimitPitch(int pitch)
{
    pitch = pitch & 65535;

    if (pitch > PitchUpLimit && pitch < PitchDownLimit)
    {
        if (pitch - PitchUpLimit < PitchDownLimit - pitch)
            pitch = PitchUpLimit;
        else
            pitch = PitchDownLimit;
    }

    return pitch;
}

function ClientDying(class<DamageType> DamageType, vector HitLocation)
{
	if ( Controller != None )
		Controller.ClientDying(DamageType, HitLocation);
}

function DoComboName( string ComboClassName );
function bool InCurrentCombo()
{
	return false;
}
//=============================================================================
// UDamage stub.
function EnableUDamage(float Amount);
function DisableUDamage();

//=============================================================================
// Shield stubs.
function float GetShieldStrengthMax();
function float GetShieldStrength();
function bool AddShieldStrength(int Amount);
function int CanUseShield(int Amount);

//=============================================================================
// Inventory related functions.

// check before throwing
simulated function bool CanThrowWeapon()
{
    return ( (Weapon != None) && Weapon.CanThrow() && Level.Game.bAllowWeaponThrowing );
}

// toss out a weapon
function TossWeapon(Vector TossVel)
{
	local Vector X,Y,Z;

	Weapon.Velocity = TossVel;
	GetAxes(Rotation,X,Y,Z);
	Weapon.DropFrom(Location + 0.8 * CollisionRadius * X - 0.5 * CollisionRadius * Y);
}

exec function SwitchToLastWeapon()
{
	if ( (Weapon != None) && (Weapon.OldWeapon != None) && Weapon.OldWeapon.HasAmmo() )
	{
		PendingWeapon = Weapon.OldWeapon;
		Weapon.PutDown();
	}
}

/* PrevWeapon()
- switch to previous inventory group weapon
*/
simulated function PrevWeapon()
{
    if ( Level.Pauser != None )
        return;

    if ( Weapon == None && Controller != None )
    {
        Controller.SwitchToBestWeapon();
        return;
    }
    if ( PendingWeapon != None )
    {
        if ( PendingWeapon.bForceSwitch )
            return;
        PendingWeapon = Inventory.PrevWeapon(None, PendingWeapon);
    }
    else
        PendingWeapon = Inventory.PrevWeapon(None, Weapon);

    if ( PendingWeapon != None )
        Weapon.PutDown();
}

/* NextWeapon()
- switch to next inventory group weapon
*/
simulated function NextWeapon()
{
    if ( Level.Pauser != None )
        return;

    if ( Weapon == None && Controller != None )
    {
        Controller.SwitchToBestWeapon();
        return;
    }
    if ( PendingWeapon != None )
    {
        if ( PendingWeapon.bForceSwitch )
            return;
        PendingWeapon = Inventory.NextWeapon(None, PendingWeapon);
    }
    else
        PendingWeapon = Inventory.NextWeapon(None, Weapon);

    if ( PendingWeapon != None )
        Weapon.PutDown();
}


// The player wants to switch to weapon group number F.
simulated function SwitchWeapon(byte F)
{
    local weapon newWeapon;

    if ( (Level.Pauser!=None) || (Inventory == None) )
        return;
    if ( (Weapon != None) && (Weapon.Inventory != None) )
        newWeapon = Weapon.Inventory.WeaponChange(F, false);
    else
        newWeapon = None;
    if ( newWeapon == None )
        newWeapon = Inventory.WeaponChange(F, true);

    if ( newWeapon == None )
	{
		if ( F == 10 )
			ServerNoTranslocator();

		return;
	}

    if ( PendingWeapon != None && PendingWeapon.bForceSwitch )
        return;

    if ( Weapon == None )
    {
        PendingWeapon = newWeapon;
        ChangedWeapon();
    }
    else if ( Weapon != newWeapon || PendingWeapon != None )
    {
        PendingWeapon = newWeapon;
        Weapon.PutDown();
    }
    else if ( Weapon == newWeapon )
        Weapon.Reselect(); // sjs
}

function ServerNoTranslocator()
{
	if ( Level.Game != None )
		Level.Game.NoTranslocatorKeyPressed( PlayerController(Controller) );
}

// The player/bot wants to select next item
exec function NextItem()
{
	if (SelectedItem==None) {
		SelectedItem = Inventory.SelectNext();
		Return;
	}
	if (SelectedItem.Inventory!=None)
		SelectedItem = SelectedItem.Inventory.SelectNext();
	else
		SelectedItem = Inventory.SelectNext();

	if ( SelectedItem == None )
		SelectedItem = Inventory.SelectNext();
}

// FindInventoryType()
// returns the inventory item of the requested class
// if it exists in this pawn's inventory

function Inventory FindInventoryType( class DesiredClass )
{
	local Inventory Inv;
	local int Count;

	for( Inv=Inventory; Inv!=None && Count < 1000; Inv=Inv.Inventory )
	{
		if ( Inv.class == DesiredClass )
			return Inv;
		Count++;
	}

	// Search for subclasses if exact class wasn't found
	Count = 0;
	for ( Inv = Inventory; Inv != None && Count < 1000; Inv = Inv.Inventory )
	{
		if ( ClassIsChildOf(Inv.Class, DesiredClass) )
			return Inv;
		Count++;
	}

	return None;
}

// Add Item to this pawn's inventory.
// Returns true if successfully added, false if not.
function bool AddInventory( inventory NewItem )
{
	// Skip if already in the inventory.
	local inventory Inv;
	local actor Last, Prev;
	local bool bAddedInOrder;

	Last = self;

	// The item should not have been destroyed if we get here.
	if (NewItem ==None )
		log("tried to add none inventory to "$self);

	NewItem.SetOwner(Self);
	NewItem.NetUpdateTime = Level.TimeSeconds - 1;

	// order weapons based on priority
	if ( Weapon(NewItem) != None )
	{
		Prev = self;
		for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
		{
			if ( (Inv.InventoryGroup == NewItem.InventoryGroup) && (Weapon(Inv) != None) )
			{
				if( (Weapon(Inv).Priority < Weapon(NewItem).Priority) )
				{
					bAddedInOrder = true;
					break;
				}
			}
			else if ( (Weapon(Prev) != None) && (Weapon(Prev).InventoryGroup == NewItem.InventoryGroup) )
			{
				bAddedInOrder = true;
				break;
			}
			if ( !bAddedInOrder )
				Prev = Inv;
		}
		if ( bAddedInOrder )
		{
			NewItem.Inventory = Prev.Inventory;
			Prev.Inventory = NewItem;
			Prev.NetUpdateTime = Level.TimeSeconds - 1;
		}
	}

	if ( !bAddedInOrder )
	{
		for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
		{
			if( Inv == NewItem )
				return false;
			Last = Inv;
		}

		// Add to back of inventory chain (so minimizes net replication effect).
		NewItem.Inventory = None;
		Last.Inventory = NewItem;
		Last.NetUpdateTime = Level.TimeSeconds - 1;
	}
	if ( Controller != None )
		Controller.NotifyAddInventory(NewItem);
	return true;
}

// Remove Item from this pawn's inventory, if it exists.
function DeleteInventory( inventory Item )
{
	// If this item is in our inventory chain, unlink it.
	local actor Link;
	local int Count;

	if ( Item == Weapon )
		Weapon = None;
	if ( Item == SelectedItem )
		SelectedItem = None;
	for( Link = Self; Link!=None; Link=Link.Inventory )
	{
		if( Link.Inventory == Item )
		{
			Link.Inventory = Item.Inventory;
			Item.Inventory = None;
			Link.NetUpdateTime = Level.TimeSeconds - 1;
			Item.NetUpdateTime = Level.TimeSeconds - 1;
			break;
		}
		if ( Level.NetMode == NM_Client )
		{
		Count++;
		if ( Count > 1000 )
			break;
	}
	}
	Item.SetOwner(None);
}

// Just changed to pendingWeapon
simulated function ChangedWeapon()
{
    local Weapon OldWeapon;

    ServerChangedWeapon(Weapon, PendingWeapon);
    if (Role < ROLE_Authority)
	{
        OldWeapon = Weapon;
        Weapon = PendingWeapon;
		PendingWeapon = None;
		if ( Controller != None )
			Controller.ChangedWeapon();

        if (Weapon != None)
		    Weapon.BringUp(OldWeapon);
    }
}

function name GetOffhandBoneFor(Inventory I)
{
	return '';
}

function name GetWeaponBoneFor(Inventory I)
{
	return 'righthand';
}

function ServerChangedWeapon(Weapon OldWeapon, Weapon NewWeapon)
{
    Weapon = NewWeapon;

    if ( Controller != None )
		Controller.ChangedWeapon();

    PendingWeapon = None;

	if ( OldWeapon != None )
	{
		OldWeapon.SetDefaultDisplayProperties();
		OldWeapon.DetachFromPawn(self);
        OldWeapon.GotoState('Hidden');
        OldWeapon.NetUpdateFrequency = 2;
	}

	if ( Weapon != None )
	{
	    Weapon.NetUpdateFrequency = 100;
		Weapon.AttachToPawn(self);
		Weapon.BringUp(OldWeapon);
        PlayWeaponSwitch(NewWeapon);
	}

	if ( Inventory != None )
		Inventory.OwnerEvent('ChangedWeapon'); // tell inventory that weapon changed (in case any effect was being applied)
}

function bool IsHeadShot(vector loc, vector ray, float AdditionalScale)
{
    local coords C;
    local vector HeadLoc, B, M, diff;
    local float t, DotMM, Distance;
    local int look;

    if (HeadBone == '')
        return False;

    // If we are a dedicated server estimate what animation is most likely playing on the client
    if (Level.NetMode == NM_DedicatedServer)
    {
        if (Physics == PHYS_Falling)
            PlayAnim(AirAnims[0], 1.0, 0.0);
        else if (Physics == PHYS_Walking)
        {
            if (bIsCrouched)
                PlayAnim(IdleCrouchAnim, 1.0, 0.0);
            else
                PlayAnim(IdleWeaponAnim, 1.0, 0.0);

			if ( bDoTorsoTwist )
			{
                SmoothViewYaw = Rotation.Yaw;
                SmoothViewPitch = ViewPitch;

                look = (256 * ViewPitch) & 65535;
                if (look > 32768)
                    look -= 65536;

                SetTwistLook(0, look);
            }
        }
        else if (Physics == PHYS_Swimming)
            PlayAnim(SwimAnims[0], 1.0, 0.0);

        SetAnimFrame(0.5);
    }

    C = GetBoneCoords(HeadBone);

    HeadLoc = C.Origin + (HeadHeight * HeadScale * AdditionalScale * C.XAxis);

    // Express snipe trace line in terms of B + tM
    B = loc;
    M = ray * (2.0 * CollisionHeight + 2.0 * CollisionRadius);

    // Find Point-Line Squared Distance
    diff = HeadLoc - B;
    t = M Dot diff;
    if (t > 0)
    {
        DotMM = M dot M;
        if (t < DotMM)
        {
            t = t / DotMM;
            diff = diff - (t * M);
        }
        else
        {
            t = 1;
            diff -= M;
        }
    }
    else
        t = 0;

    Distance = Sqrt(diff Dot diff);

    return (Distance < (HeadRadius * HeadScale * AdditionalScale));
}

//==============
// Encroachment
event bool EncroachingOn( actor Other )
{
	if ( Other.bWorldGeometry || Other.bBlocksTeleport )
		return true;

	if ( (Vehicle(Other) != None) && (Weapon != None) && Weapon.IsA('Translauncher') )
		return true;

	if ( ((Controller == None) || !Controller.bIsPlayer || bWarping) && (Pawn(Other) != None) )
		return true;

	return false;
}

event EncroachedBy( actor Other )
{
	// Allow encroachment by Vehicles so they can push the pawn out of the way
	if ( Pawn(Other) != None && Vehicle(Other) == None )
		gibbedBy(Other);
}

function gibbedBy(actor Other)
{
	if ( Role < ROLE_Authority )
		return;
	if ( Pawn(Other) != None )
		Died(Pawn(Other).Controller, class'DamTypeTelefragged', Location);
	else
		Died(None, class'Gibbed', Location);
}

//Base change - if new base is pawn or decoration, damage based on relative mass and old velocity
// Also, non-players will jump off pawns immediately
function JumpOffPawn()
{
	Velocity += (100 + CollisionRadius) * VRand();
	Velocity.Z = 200 + CollisionHeight;
	SetPhysics(PHYS_Falling);
	bNoJumpAdjust = true;
	if ( Controller != None )
		Controller.SetFall();
}

singular event BaseChange()
{
	local float decorMass;

	if ( bInterpolating )
		return;
	if ( (base == None) && (Physics == PHYS_None) )
		SetPhysics(PHYS_Falling);
	// Pawns can only set base to non-pawns, or pawns which specifically allow it.
	// Otherwise we do some damage and jump off.
	else if ( Pawn(Base) != None && Base != DrivenVehicle )
	{
		if ( !Pawn(Base).bCanBeBaseForPawns )
		{
			Base.TakeDamage( (1-Velocity.Z/400)* Mass/Base.Mass, Self,Location,0.5 * Velocity , class'Crushed');
			JumpOffPawn();
		}
	}
	else if ( (Decoration(Base) != None) && (Velocity.Z < -400) )
	{
		decorMass = FMax(Decoration(Base).Mass, 1);
		Base.TakeDamage((-2* Mass/decorMass * Velocity.Z/400), Self, Location, 0.5 * Velocity, class'Crushed');
	}
}

event UpdateEyeHeight( float DeltaTime )
{
	local float smooth, MaxEyeHeight;
	local float OldEyeHeight;
	local Actor HitActor;
	local vector HitLocation,HitNormal;

	if ( Controller == None )
	{
		EyeHeight = 0;
		return;
	}
	if ( Level.NetMode == NM_DedicatedServer )
	{
		Eyeheight = BaseEyeheight;
		return;
	}
	if ( bTearOff )
	{
		EyeHeight = Default.BaseEyeheight;
		bUpdateEyeHeight = false;
		return;
	}
	HitActor = trace(HitLocation,HitNormal,Location + (CollisionHeight + MAXSTEPHEIGHT + 14) * vect(0,0,1),
					Location + CollisionHeight * vect(0,0,1),true);
	if ( HitActor == None )
		MaxEyeHeight = CollisionHeight + MAXSTEPHEIGHT;
	else
		MaxEyeHeight = HitLocation.Z - Location.Z - 14;

	if ( abs(Location.Z - OldZ) > 15 )
	{
		bJustLanded = false;
		bLandRecovery = false;
	}

	// smooth up/down stairs
	if ( !bJustLanded )
	{
		smooth = FMin(0.9, 10.0 * DeltaTime/Level.TimeDilation);
		LandBob *= (1 - smooth);
		if( Controller.WantsSmoothedView() )
		{
			OldEyeHeight = EyeHeight;
			EyeHeight = FClamp((EyeHeight - Location.Z + OldZ) * (1 - smooth) + BaseEyeHeight * smooth,
								-0.5 * CollisionHeight, MaxEyeheight);
		}
	    else
		    EyeHeight = FMin(EyeHeight * ( 1 - smooth) + BaseEyeHeight * smooth, MaxEyeHeight);
	}
	else if ( bLandRecovery )
	{
		smooth = FMin(0.9, 10.0 * DeltaTime);
		OldEyeHeight = EyeHeight;
	    EyeHeight = FMin(EyeHeight * ( 1 - 0.6*smooth) + BaseEyeHeight * 0.6*smooth, BaseEyeHeight);
		LandBob *= (1 - smooth);
		if ( Eyeheight >= BaseEyeheight - 1)
		{
			bJustLanded = false;
			bLandRecovery = false;
			Eyeheight = BaseEyeheight;
		}
	}
	else
	{
		smooth = FMin(0.65, 10.0 * DeltaTime);
		OldEyeHeight = EyeHeight;
		EyeHeight = FMin(EyeHeight * (1 - 1.5*smooth), MaxEyeHeight);
		LandBob += 0.03 * (OldEyeHeight - Eyeheight);
		if ( (Eyeheight < 0.25 * BaseEyeheight + 1) || (LandBob > 3)  )
		{
			bLandRecovery = true;
			Eyeheight = 0.25 * BaseEyeheight + 1;
		}
	}

	Controller.AdjustView(DeltaTime);
}

/* EyePosition()
Called by PlayerController to determine camera position in first person view.  Returns
the offset from the Pawn's location at which to place the camera
*/
simulated function vector EyePosition()
{
	return EyeHeight * vect(0,0,1) + WalkBob;
}

//=============================================================================

simulated event Destroyed()
{
	if ( Shadow != None )
		Shadow.Destroy();
	if ( Controller != None )
		Controller.PawnDied(self);
	if ( Level.NetMode == NM_Client )
		return;

	while ( Inventory != None )
		Inventory.Destroy();

	Weapon = None;
	Super.Destroyed();
}

//=============================================================================
//
// Called immediately before gameplay begins.
//
event PreBeginPlay()
{
	Super.PreBeginPlay();
	Instigator = self;
	DesiredRotation = Rotation;
	if ( bDeleteMe )
		return;

	if ( BaseEyeHeight == 0 )
		BaseEyeHeight = 0.8 * CollisionHeight;
	EyeHeight = BaseEyeHeight;

	if ( menuname == "" )
		menuname = GetItemName(string(class));
}

event PostBeginPlay()
{
	local AIScript A;

	Super.PostBeginPlay();
	SplashTime = 0;
	SpawnTime = Level.TimeSeconds;
	EyeHeight = BaseEyeHeight;
	OldRotYaw = Rotation.Yaw;

	// automatically add controller to pawns which were placed in level
	// NOTE: pawns spawned during gameplay are not automatically possessed by a controller
	if ( Level.bStartup && (Health > 0) && !bDontPossess )
	{
		// check if I have an AI Script
		if ( AIScriptTag != '' )
		{
			ForEach AllActors(class'AIScript',A,AIScriptTag)
				break;
			// let the AIScript spawn and init my controller
			if ( A != None )
			{
				A.SpawnControllerFor(self);
				if ( Controller != None )
					return;
			}
		}
		if ( (ControllerClass != None) && (Controller == None) )
			Controller = spawn(ControllerClass);
		if ( Controller != None )
		{
			Controller.Possess(self);
			AIController(Controller).Skill += SkillModifier;
		}
	}
}

// called after PostBeginPlay on net client
simulated event PostNetBeginPlay()
{
	local playercontroller P;

	if ( Level.bDropDetail || (Level.DetailMode == DM_Low) )
		MaxLights = Min(4,MaxLights);
	if ( Role == ROLE_Authority )
		return;
	if ( (Controller != None) && (Controller.Pawn == None) )
	{
		Controller.Pawn = self;
		if ( (PlayerController(Controller) != None)
			&& (PlayerController(Controller).ViewTarget == Controller) )
			PlayerController(Controller).SetViewTarget(self);
	}

	if ( Role == ROLE_AutonomousProxy )
		bUpdateEyeHeight = true;

	if ( (PlayerReplicationInfo != None)
		&& (PlayerReplicationInfo.Owner == None) )
	{
		PlayerReplicationInfo.SetOwner(Controller);
		if ( left(PlayerReplicationInfo.PlayerName, 5) ~= "PRESS" )
		{
			P = Level.GetLocalPlayerController();
			if ( (P.PlayerReplicationInfo != None) && !(left(PlayerReplicationInfo.PlayerName, 5) ~= "PRESS") )
				bScriptPostRender = true;
		}
	}
	PlayWaiting();
}

simulated function SetMesh()
{
    if (Mesh != None)
        return;

	LinkMesh( default.mesh );
}

function Gasp();
function SetMovementPhysics();

function bool GiveHealth(int HealAmount, int HealMax)
{
	if (Health < HealMax)
	{
		Health = Min(HealMax, Health + HealAmount);
        return true;
	}
    return false;
}

function bool HasUDamage()
{
	return false;
}

function int ShieldAbsorb( int damage )
{
    return damage;
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
	local int actualDamage;
	local Controller Killer;

	if ( damagetype == None )
	{
		if ( InstigatedBy != None )
			warn("No damagetype for damage by "$instigatedby$" with weapon "$InstigatedBy.Weapon);
		DamageType = class'DamageType';
	}

	if ( Role < ROLE_Authority )
	{
		log(self$" client damage type "$damageType$" by "$instigatedBy);
		return;
	}

	if ( Health <= 0 )
		return;

	if ((instigatedBy == None || instigatedBy.Controller == None) && DamageType.default.bDelayedDamage && DelayedDamageInstigatorController != None)
		instigatedBy = DelayedDamageInstigatorController.Pawn;

	if ( (Physics == PHYS_None) && (DrivenVehicle == None) )
		SetMovementPhysics();
	if (Physics == PHYS_Walking && damageType.default.bExtraMomentumZ)
		momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));
	if ( instigatedBy == self )
		momentum *= 0.6;
	momentum = momentum/Mass;

	if (Weapon != None)
		Weapon.AdjustPlayerDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType );
	if (DrivenVehicle != None)
        	DrivenVehicle.AdjustDriverDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType );
	if ( (InstigatedBy != None) && InstigatedBy.HasUDamage() )
		Damage *= 2;
	actualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);
	if( DamageType.default.bArmorStops && (actualDamage > 0) )
		actualDamage = ShieldAbsorb(actualDamage);

	Health -= actualDamage;
	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;

	PlayHit(actualDamage,InstigatedBy, hitLocation, damageType, Momentum);
	if ( Health <= 0 )
	{
		// pawn died
		if ( DamageType.default.bCausedByWorld && (instigatedBy == None || instigatedBy == self) && LastHitBy != None )
			Killer = LastHitBy;
		else if ( instigatedBy != None )
			Killer = instigatedBy.GetKillerController();
		if ( Killer == None && DamageType.Default.bDelayedDamage )
			Killer = DelayedDamageInstigatorController;
		if ( bPhysicsAnimUpdate )
			TearOffMomentum = momentum;
		Died(Killer, damageType, HitLocation);
	}
	else
	{
		AddVelocity( momentum );
		if ( Controller != None )
			Controller.NotifyTakeHit(instigatedBy, HitLocation, actualDamage, DamageType, Momentum);
		if ( instigatedBy != None && instigatedBy != self )
			LastHitBy = instigatedBy.Controller;
	}
	MakeNoise(1.0);
}

function SetDelayedDamageInstigatorController(Controller C)
{
	DelayedDamageInstigatorController = C;
}

simulated function int GetTeamNum()
{
	if ( Controller != None )
		return Controller.GetTeamNum();
	if ( (DrivenVehicle != None) && (DrivenVehicle.Controller != None) )
		return DrivenVehicle.Controller.GetTeamNum();
	if ( (PlayerReplicationInfo == None) || (PlayerReplicationInfo.Team == None) )
		return 255;
	return PlayerReplicationInfo.Team.TeamIndex;
}

function TeamInfo GetTeam()
{
	if ( PlayerReplicationInfo != None )
		return PlayerReplicationInfo.Team;
	if ( (DrivenVehicle != None) && (DrivenVehicle.PlayerReplicationInfo != None) )
		return DrivenVehicle.PlayerReplicationInfo.Team;
	return None;
}

function Controller GetKillerController()
{
	return Controller;
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    local Vector			TossVel;
	local Trigger			T;
	local NavigationPoint	N;

	if ( bDeleteMe || Level.bLevelChange || Level.Game == None )
		return; // already destroyed, or level is being cleaned up

	if ( DamageType.default.bCausedByWorld && (Killer == None || Killer == Controller) && LastHitBy != None )
		Killer = LastHitBy;

	// mutator hook to prevent deaths
	// WARNING - don't prevent bot suicides - they suicide when really needed
	if ( Level.Game.PreventDeath(self, Killer, damageType, HitLocation) )
	{
		Health = max(Health, 1); //mutator should set this higher
		return;
	}
	Health = Min(0, Health);

    if ( Weapon != None && (DrivenVehicle == None || DrivenVehicle.bAllowWeaponToss) )
    {
		if ( Controller != None )
			Controller.LastPawnWeapon = Weapon.Class;
        Weapon.HolderDied();
        TossVel = Vector(GetViewRotation());
        TossVel = TossVel * ((Velocity Dot TossVel) + 500) + Vect(0,0,200);
        TossWeapon(TossVel);
    }

	if ( DrivenVehicle != None )
	{
		Velocity = DrivenVehicle.Velocity;
		DrivenVehicle.DriverDied();
	}

	if ( Controller != None )
	{
		Controller.WasKilledBy(Killer);
		Level.Game.Killed(Killer, Controller, self, damageType);
	}
	else
		Level.Game.Killed(Killer, Controller(Owner), self, damageType);

	DrivenVehicle = None;

	if ( Killer != None )
		TriggerEvent(Event, self, Killer.Pawn);
	else
		TriggerEvent(Event, self, None);

	// make sure to untrigger any triggers requiring player touch
	if ( IsPlayerPawn() || WasPlayerPawn() )
	{
		PhysicsVolume.PlayerPawnDiedInVolume(self);
		ForEach TouchingActors(class'Trigger',T)
			T.PlayerToucherDied(self);

		// event for HoldObjectives
		//for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		//	if ( N.bStatic && N.bReceivePlayerToucherDiedNotify )
		ForEach TouchingActors(class'NavigationPoint', N)
			if ( N.bReceivePlayerToucherDiedNotify )
				N.PlayerToucherDied( Self );
	}

	// remove powerup effects, etc.
	RemovePowerups();

	Velocity.Z *= 1.3;
	if ( IsHumanControlled() )
		PlayerController(Controller).ForceDeathUpdate();
    if ( (DamageType != None) && DamageType.default.bAlwaysGibs )
		ChunkUp( Rotation, DamageType.default.GibPerterbation );
	else
	{
		NetUpdateFrequency = Default.NetUpdateFrequency;
		PlayDying(DamageType, HitLocation);
		if ( Level.Game.bGameEnded )
			return;
		if ( !bPhysicsAnimUpdate && !IsLocallyControlled() )
			ClientDying(DamageType, HitLocation);
	}

}

function RemovePowerups();

event Falling()
{
	//SetPhysics(PHYS_Falling); //Note - physics changes type to PHYS_Falling by default
	if ( Controller != None )
		Controller.SetFall();
}

event HitWall(vector HitNormal, actor Wall);

event Landed(vector HitNormal)
{
	ImpactVelocity = vect(0,0,0);
	TakeFallingDamage();
	if ( Health > 0 )
		PlayLanded(Velocity.Z);
	if ( (Velocity.Z < -200) && (PlayerController(Controller) != None) )
	{
		bJustLanded = PlayerController(Controller).bLandingShake;
		OldZ = Location.Z;
	}
	LastHitBy = None;
}

event HeadVolumeChange(PhysicsVolume newHeadVolume)
{
	if ( (Level.NetMode == NM_Client) || (Controller == None) )
		return;
	if ( HeadVolume.bWaterVolume )
	{
		if (!newHeadVolume.bWaterVolume)
		{
			if ( Controller.bIsPlayer && (BreathTime > 0) && (BreathTime < 8) )
				Gasp();
			BreathTime = -1.0;
		}
	}
	else if ( newHeadVolume.bWaterVolume )
		BreathTime = UnderWaterTime;
}

function bool TouchingWaterVolume()
{
	local PhysicsVolume V;

	ForEach TouchingActors(class'PhysicsVolume',V)
		if ( V.bWaterVolume )
			return true;

	return false;
}

//Pain timer just expired.
//Check what zone I'm in (and which parts are)
//based on that cause damage, and reset BreathTime

function bool IsInPain()
{
	local PhysicsVolume V;

	ForEach TouchingActors(class'PhysicsVolume',V)
		if ( V.bPainCausing && (V.DamageType != ReducedDamageType)
			&& (V.DamagePerSec > 0) )
			return true;
	return false;
}

event BreathTimer()
{
	if ( (Health < 0) || (Level.NetMode == NM_Client) || (DrivenVehicle != None) )
		return;
	TakeDrowningDamage();
	if ( Health > 0 )
		BreathTime = 2.0;
}

function TakeDrowningDamage();

function bool CheckWaterJump(out vector WallNormal)
{
	local actor HitActor;
	local vector HitLocation, HitNormal, checkpoint, start, checkNorm;

	if ( AIController(Controller) != None )
	{
		checkpoint = Acceleration;
		checkpoint.Z = 0.0;
	}
	if ( checkpoint == vect(0,0,0))
		checkpoint = vector(Rotation);
	checkpoint.Z = 0.0;
	checkNorm = Normal(checkpoint);
	checkPoint = Location + 1.2 * CollisionRadius * checkNorm;
	HitActor = Trace(HitLocation, HitNormal, checkpoint, Location, true, GetCollisionExtent());
	if ( (HitActor != None) && (Pawn(HitActor) == None) )
	{
		WallNormal = -1 * HitNormal;
		start = Location;
		start.Z += 1.1 * MAXSTEPHEIGHT;
		checkPoint = start + 2 * CollisionRadius * checkNorm;
		HitActor = Trace(HitLocation, HitNormal, checkpoint, start, true);
		if ( (HitActor == None) || (HitNormal.Z > 0.7) )
			return true;
	}

	return false;
}

function DoDoubleJump( bool bUpdating );
function bool CanDoubleJump();
function bool CanMultiJump();

function UpdateRocketAcceleration(float DeltaTime, float YawChange, float PitchChange);
function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot);

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
	return false;
}

//Player Jumped
function bool DoJump( bool bUpdating )
{
	if ( !bIsCrouched && !bWantsToCrouch && ((Physics == PHYS_Walking) || (Physics == PHYS_Ladder) || (Physics == PHYS_Spider)) )
	{
		if ( Role == ROLE_Authority )
		{
			if ( (Level.Game != None) && (Level.Game.GameDifficulty > 2) )
				MakeNoise(0.1 * Level.Game.GameDifficulty);
			if ( bCountJumps && (Inventory != None) )
				Inventory.OwnerEvent('Jumped');
		}
		if ( Physics == PHYS_Spider )
			Velocity = JumpZ * Floor;
		else if ( Physics == PHYS_Ladder )
			Velocity.Z = 0;
		else if ( bIsWalking )
			Velocity.Z = Default.JumpZ;
		else
			Velocity.Z = JumpZ;
		if ( (Base != None) && !Base.bWorldGeometry )
			Velocity.Z += Base.Velocity.Z;
		SetPhysics(PHYS_Falling);
        return true;
	}
    return false;
}

/* PlayMoverHitSound()
Mover Hit me, play appropriate sound if any
*/
function PlayMoverHitSound();

function PlayDyingSound();

function PlayHit(float Damage, Pawn InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum)
{
	local vector BloodOffset, Mo, HitNormal;
	local class<Effects> DesiredEffect;
	local class<Emitter> DesiredEmitter;
	local PlayerController Hearer;

	if ( DamageType == None )
		return;
	if ( (Damage <= 0) && ((Controller == None) || !Controller.bGodMode) )
		return;

	if (Damage > DamageType.Default.DamageThreshold) //spawn some blood
	{

		HitNormal = Normal(HitLocation - Location);

		// Play any set effect
		if ( EffectIsRelevant(Location,true) )
		{
			DesiredEffect = DamageType.static.GetPawnDamageEffect(HitLocation, Damage, Momentum, self, (Level.bDropDetail || Level.DetailMode == DM_Low));

			if ( DesiredEffect != None )
			{
				BloodOffset = 0.2 * CollisionRadius * HitNormal;
				BloodOffset.Z = BloodOffset.Z * 0.5;

				Mo = Momentum;
				if ( Mo.Z > 0 )
					Mo.Z *= 0.5;
				spawn(DesiredEffect,self,,HitLocation + BloodOffset, rotator(Mo));
			}

			// Spawn any preset emitter

			DesiredEmitter = DamageType.Static.GetPawnDamageEmitter(HitLocation, Damage, Momentum, self, (Level.bDropDetail || Level.DetailMode == DM_Low));
			if (DesiredEmitter != None)
				spawn(DesiredEmitter,,,HitLocation+HitNormal, Rotator(HitNormal));
		}
	}
	if ( Health <= 0 )
	{
		if ( PhysicsVolume.bDestructive && (PhysicsVolume.ExitActor != None) )
			Spawn(PhysicsVolume.ExitActor);
		return;
	}

	if ( Level.TimeSeconds - LastPainTime > 0.1 )
	{
		if ( InstigatedBy != None && (DamageType != None) && DamageType.default.bDirectDamage )
			Hearer = PlayerController(InstigatedBy.Controller);
		if ( Hearer != None )
			Hearer.bAcuteHearing = true;
		PlayTakeHit(HitLocation,Damage,damageType);
		if ( Hearer != None )
			Hearer.bAcuteHearing = false;
		LastPainTime = Level.TimeSeconds;
	}
}

/*
Pawn was killed - detach any controller, and die
*/

// blow up into little pieces (implemented in subclass)

simulated function ChunkUp( Rotator HitRotation, float ChunkPerterbation )
{
	if ( (Level.NetMode != NM_Client) && (Controller != None) )
	{
		if ( Controller.bIsPlayer )
			Controller.PawnDied(self);
		else
			Controller.Destroy();
	}
	destroy();
}

simulated function TurnOff()
{
	SetCollision(true,false);
	AmbientSound = None;
 	bNoWeaponFiring = true;
    Velocity = vect(0,0,0);
    SetPhysics(PHYS_None);
    bPhysicsAnimUpdate = false;
    bIsIdle = true;
    bWaitForAnim = false;
    StopAnimating();
    bIgnoreForces = true;
}

/* IsInLoadout()
return true if InventoryClass is part of required or optional equipment
*/
function bool IsInLoadout(class<Inventory> InventoryClass)
{
	return true;
}


State Dying
{
ignores Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

	event ChangeAnimation() {}
	event StopPlayFiring() {}
	function PlayFiring(float Rate, name FiringMode) {}
	function PlayWeaponSwitch(Weapon NewWeapon) {}
	function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType) {}
	simulated function PlayNextAnimation() {}

	function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
	{
	}

	event FellOutOfWorld(eKillZType KillType)
	{
		if(KillType == KILLZ_Lava || KillType == KILLZ_Suicide )
			return;

		Destroy();
	}

	function Timer()
	{
		if ( !PlayerCanSeeMe() )
			Destroy();
		else
			SetTimer(2.0, false);
	}

	function Landed(vector HitNormal)
	{
		local rotator finalRot;

		if( Velocity.Z < -500 )
			TakeDamage( (1-Velocity.Z/30),Instigator,Location,vect(0,0,0) , class'Crushed');

		finalRot = Rotation;
		finalRot.Roll = 0;
		finalRot.Pitch = 0;
		setRotation(finalRot);
		SetPhysics(PHYS_None);
		SetCollision(true, false);

		if ( !IsAnimating(0) )
			LieStill();
	}

	/* ReduceCylinder() made obsolete by ragdoll deaths */
	function ReduceCylinder()
	{
		SetCollision(false,false);
	}

	function LandThump()
	{
		// animation notify - play sound if actually landed, and animation also shows it
		if ( Physics == PHYS_None)
			bThumped = true;
	}

	event AnimEnd(int Channel)
	{
		if ( Channel != 0 )
			return;
		if ( Physics == PHYS_None )
			LieStill();
		else if ( PhysicsVolume.bWaterVolume )
		{
			bThumped = true;
			LieStill();
		}
	}

	function LieStill()
	{
		if ( !bThumped )
			LandThump();
		ReduceCylinder();
	}

	singular function BaseChange()
	{
		if( base == None )
			SetPhysics(PHYS_Falling);
		else if ( Pawn(base) != None ) // don't let corpse ride around on someone's head
        	ChunkUp( Rotation, 1.0 );
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, class<DamageType> damageType)
	{
		SetPhysics(PHYS_Falling);
		if ( (Physics == PHYS_None) && (Momentum.Z < 0) )
			Momentum.Z *= -1;
		Velocity += 3 * momentum/(Mass + 200);
		if ( bInvulnerableBody )
			return;
		Damage *= DamageType.Default.GibModifier;
		Health -=Damage;
		if ( ((Damage > 30) || !IsAnimating()) && (Health < -80) )
        	ChunkUp( Rotation, DamageType.default.GibPerterbation );
	}

	function BeginState()
	{
		local int i;

		//log(self$" dying");
		if ( bTearOff && (Level.NetMode == NM_DedicatedServer) )
			LifeSpan = 1.0;
		else
			SetTimer(12.0, false);
		SetPhysics(PHYS_Falling);
		bInvulnerableBody = true;
		if ( Controller != None )
		{
			if ( Controller.bIsPlayer )
				Controller.PawnDied(self);
			else
				Controller.Destroy();
		}

		for (i = 0; i < Attached.length; i++)
			if (Attached[i] != None)
				Attached[i].PawnBaseDied();
	}

Begin:
	Sleep(0.2);
	bInvulnerableBody = false;
	PlayDyingSound();
}

//=============================================================================
// Animation interface for controllers

simulated event SetAnimAction(name NewAction);

/* PlayXXX() function called by controller to play transient animation actions
*/
simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	AmbientSound = None;
	GotoState('Dying');
	if ( bPhysicsAnimUpdate )
	{
		bReplicateMovement = false;
		bTearOff = true;
		Velocity += TearOffMomentum;
		SetPhysics(PHYS_Falling);
	}
	bPlayedDeath = true;
}

simulated function PlayFiring(optional float Rate, optional name FiringMode);
function PlayWeaponSwitch(Weapon NewWeapon);
simulated event StopPlayFiring()
{
	bSteadyFiring = false;
}

function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType)
{
	local Sound DesiredSound;

	if (Damage==0)
		return;
	//
	// Play a hit sound according to the DamageType

 	DesiredSound = DamageType.Static.GetPawnDamageSound();
	if (DesiredSound != None)
		PlayOwnedSound(DesiredSound,SLOT_Misc);
}

//=============================================================================
// Pawn internal animation functions

simulated event ChangeAnimation()
{
	if ( (Controller != None) && Controller.bControlAnimations )
		return;
	// player animation - set up new idle and moving animations
	PlayWaiting();
	PlayMoving();
}

simulated event AnimEnd(int Channel)
{
	if ( Channel == 0 )
		PlayWaiting();
}

// Animation group checks (usually implemented in subclass)

function bool CannotJumpNow()
{
	return false;
}

simulated event PlayJump();
simulated event PlayFalling();
simulated function PlayMoving();
simulated function PlayWaiting();

function PlayLanded(float impactVel)
{
	if ( !bPhysicsAnimUpdate )
		PlayLandingAnimation(impactvel);
}

simulated event PlayLandingAnimation(float ImpactVel);

function PlayVictoryAnimation();


function Vehicle GetVehicleBase()
{
	return Vehicle(Base);
}

function int GetSpree()
{
	return 0;
}

function IncrementSpree();

// Allows a pawn to process the raw input from the controller

simulated function RawInput(float DeltaTime,
							float aBaseX, float aBaseY, float aBaseZ, float aMouseX, float aMouseY,
							float aForward, float aTurn, float aStrafe, float aUp, float aLookUp)
{
}

function Suicide()
{
	KilledBy(self);
}

// Cheats - invoked by CheatManager
function bool CheatWalk()
{
	UnderWaterTime = Default.UnderWaterTime;
	SetCollision(true, true , true);
	SetPhysics(PHYS_Walking);
	bCollideWorld = true;
	return true;
}

function bool CheatGhost()
{
	UnderWaterTime = -1.0;
	SetCollision(false, false, false);
	bCollideWorld = false;
	return true;
}

function bool CheatFly()
{
	UnderWaterTime = Default.UnderWaterTime;
	SetCollision(true, true , true);
	bCollideWorld = true;
	return true;
}

function float RangedAttackTime()
{
	if ( Weapon != None )
		return Weapon.RangedAttackTime();

	return 0;
}

simulated function vector GetTargetLocation()
{
	return Location;
}

defaultproperties
{
     bJumpCapable=True
     bCanJump=True
     bCanWalk=True
     bCanDoubleJump=True
     bSimulateGravity=True
     bServerMoveSetPawnRot=True
     bNoCoronas=True
     bAutoActivate=True
     bLOSHearing=True
     bUseCompressedPosition=True
     bCanUse=True
     Visibility=128
     DesiredSpeed=1.000000
     MaxDesiredSpeed=1.000000
     HearingThreshold=2800.000000
     SightRadius=5000.000000
     AvgPhysicsTime=0.100000
     GroundSpeed=440.000000
     WaterSpeed=300.000000
     AirSpeed=440.000000
     LadderSpeed=200.000000
     AccelRate=2048.000000
     JumpZ=420.000000
     AirControl=0.050000
     WalkingPct=0.500000
     CrouchedPct=0.500000
     MaxFallSpeed=1200.000000
     PitchUpLimit=18000
     PitchDownLimit=49153
     BaseEyeHeight=64.000000
     EyeHeight=54.000000
     CrouchHeight=40.000000
     CrouchRadius=34.000000
     DrivingHeight=20.000000
     DrivingRadius=22.000000
     HealthMax=100.000000
     SuperHealthMax=199.000000
     Health=100
     HeadRadius=9.000000
     HeadHeight=6.000000
     HeadScale=1.000000
     bSetPCRotOnPossess=True
     noise1time=-10.000000
     noise2time=-10.000000
     Bob=0.006000
     SoundDampening=1.000000
     DamageScaling=1.000000
     ControllerClass=Class'Engine.AIController'
     LandMovementState="PlayerWalking"
     WaterMovementState="PlayerSwimming"
     BlendChangeTime=0.250000
     DrawType=DT_Mesh
     bUseDynamicLights=True
     bStasis=True
     bUpdateSimulatedPosition=True
     RemoteRole=ROLE_SimulatedProxy
     NetPriority=2.000000
     Texture=Texture'Engine.S_Pawn'
     bTravel=True
     bCanBeDamaged=True
     bShouldBaseAtStartup=True
     bOwnerNoSee=True
     bCanTeleport=True
     bDisturbFluidSurface=True
     SoundVolume=255
     SoundRadius=160.000000
     CollisionRadius=34.000000
     CollisionHeight=78.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bProjTarget=True
     bRotateToDesired=True
     RotationRate=(Pitch=4096,Yaw=20000,Roll=3072)
     bNoRepMesh=True
     bDirectional=True
}
