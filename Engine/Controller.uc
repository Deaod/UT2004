//=============================================================================
// Controller, the base class of players or AI.
//
// Controllers are non-physical actors that can be attached to a pawn to control
// its actions.  PlayerControllers are used by human players to control pawns, while
// AIControFllers implement the artificial intelligence for the pawns they control.
// Controllers take control of a pawn using their Possess() method, and relinquish
// control of the pawn by calling UnPossess().
//
// Controllers receive notifications for many of the events occuring for the Pawn they
// are controlling.  This gives the controller the opportunity to implement the behavior
// in response to this event, intercepting the event and superceding the Pawn's default
// behavior.
//
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Controller extends Actor
	config(user)
	native
	nativereplication
	abstract;

var Pawn Pawn;

var const int		PlayerNum;			// The player number - per-match player number.
var		float		SightCounter;		// Used to keep track of when to check player visibility
var		float		FovAngle;			// X field of view angle in degrees, usually 90.
var globalconfig float	Handedness;
var		bool        bIsPlayer;			// Pawn is a player or a player-bot.
var		bool		bGodMode;			// cheat - when true, can't be killed or hurt

//AI flags
var const bool		bLOSflag;			// used for alternating LineOfSight traces
var		bool		bAdvancedTactics;	// serpentine movement between pathnodes
var		bool		bCanOpenDoors;
var		bool		bCanDoSpecial;
var		bool		bAdjusting;			// adjusting around obstacle
var		bool		bPreparingMove;		// set true while pawn sets up for a latent move
var		bool		bControlAnimations;	// take control of animations from pawn (don't let pawn play animations based on notifications)
var		bool		bEnemyInfoValid;	// false when change enemy, true when LastSeenPos etc updated
var		bool		bNotifyApex;		// event NotifyJumpApex() when at apex of jump
var		bool		bUsePlayerHearing;
var		bool		bJumpOverWall;		// true when jumping to clear obstacle
var		bool		bEnemyAcquired;
var		bool		bSoaking;			// pause and focus on this bot if it encounters a problem
var		bool		bHuntPlayer;		// hunting player
var		bool		bAllowedToTranslocate;
var		bool		bAllowedToImpactJump;
var		bool        bAdrenalineEnabled;
var		bool		bNotifyFallingHitWall;
var		bool		bSlowerZAcquire;	// acquire targets above or below more slowly than at same height
var		bool		bInDodgeMove;
var		bool		bVehicleTransition;
var		bool		bForceStrafe;
var		bool		bNotifyPostLanded;

// Input buttons.
var input byte
	bRun, bDuck, bFire, bAltFire, bVoiceTalk;

var		vector		AdjustLoc;			// location to move to while adjusting around obstacle

var const	Controller		nextController; // chained Controller list

var		float 		Stimulus;			// Strength of stimulus - Set when stimulus happens

// Navigation AI
var 	float		MoveTimer;
var 	Actor		MoveTarget;		// actor being moved toward
var		vector	 	Destination;	// location being moved toward
var	 	vector		FocalPoint;		// location being looked at
var		Actor		Focus;			// actor being looked at
var		float		FocusLead;		// how much to lead view of focus
var		Mover		PendingMover;	// mover pawn is waiting for to complete its move
var		Actor		GoalList[4];	// used by navigation AI - list of intermediate goals
var NavigationPoint home;			// set when begin play, used for retreating and attitude checks
var	 	float		MinHitWall;		// Minimum HitNormal dot Velocity.Normal to get a HitWall event from the physics
var		float		RespawnPredictionTime;	// how far ahead to predict respawns when looking for inventory
var		float		DodgeToGoalPct;	// Frequency bot tries to dodge to reachable goal
var		int			AcquisitionYawRate;
var		float		DodgeLandZ;		// expected min landing height of dodge
var		Vehicle		LastBlockingVehicle;

// Enemy information
var	 	Pawn    	Enemy;
var		Actor		Target;
var		vector		LastSeenPos; 	// enemy position when I last saw enemy (auto updated if EnemyNotVisible() enabled)
var		vector		LastSeeingPos;	// position where I last saw enemy (auto updated if EnemyNotVisible enabled)
var		float		LastSeenTime;

var string VoiceType; // OBSOLETE
var float OldMessageTime; //to limit frequency of voice messages

// Route Cache for Navigation
var Actor		RouteCache[16];
var ReachSpec	CurrentPath;
var ReachSpec	NextRoutePath;
var vector		CurrentPathDir;
var Actor		RouteGoal; //final destination for current route
var float		RouteDist;	// total distance for current route
var	float		LastRouteFind;	// time at which last route finding occured
var		vector		DirectionHint;		// used to pick which side of vehicle to get out on

// Replication Info
var() class<PlayerReplicationInfo> PlayerReplicationInfoClass;
var PlayerReplicationInfo PlayerReplicationInfo;

var class<Pawn> PawnClass;	// class of pawn to spawn (for players)
var class<Pawn> PreviousPawnClass;	// Holds the player's previous class

var float GroundPitchTime;
var vector ViewX, ViewY, ViewZ;	// Viewrotation encoding for PHYS_Spider

var NavigationPoint StartSpot;  // where player started the match

// for monitoring the position of a pawn
var		vector		MonitorStartLoc;	// used by latent function MonitorPawn()
var		Pawn		MonitoredPawn;		// used by latent function MonitorPawn()
var		float		MonitorMaxDistSq;

var		AvoidMarker	FearSpots[2];	// avoid these spots when moving

var float WarningDelay;		// delay before act on firing warning
var Projectile WarningProjectile;
var Pawn ShotTarget;
var const Actor LastFailedReach;	// cache to avoid trying failed actorreachable more than once per frame
var const float FailedReachTime;
var const vector FailedReachLocation;

var float Adrenaline;
var float           AdrenalineMax;       // maximum Adrenaline (combo energy)
var class<Weapon> LastPawnWeapon;				// used by game stats

const LATENT_MOVETOWARD = 503; // LatentAction number for Movetoward() latent function

replication
{
	reliable if( bNetDirty && (Role==ROLE_Authority) )
		PlayerReplicationInfo, Pawn;
	reliable if( bNetDirty && (Role== ROLE_Authority) && bNetOwner )
		PawnClass, Adrenaline,bAdrenalineEnabled;

	// Functions the server calls on the client side.
	reliable if( RemoteRole==ROLE_AutonomousProxy )
		ClientGameEnded, ClientRoundEnded, ClientDying, ClientSetRotation, ClientSetLocation,
		ClientSwitchToBestWeapon, ClientSetWeapon;
	reliable if ( (!bDemoRecording || (bClientDemoRecording && bClientDemoNetFunc)) && Role == ROLE_Authority )
		ClientVoiceMessage;

	// Functions the client calls on the server.
	unreliable if( Role<ROLE_Authority )
		SendVoiceMessage, SetPawnClass;
	reliable if ( Role < ROLE_Authority )
		ServerRestartPlayer;
}

// Latent Movement.
//Note that MoveTo sets the actor's Destination, and MoveToward sets the
//actor's MoveTarget.  Actor will rotate towards destination unless the optional ViewFocus is specified.

native(500) final latent function MoveTo( vector NewDestination, optional Actor ViewFocus, optional bool bShouldWalk);
native(502) final latent function MoveToward(actor NewTarget, optional Actor ViewFocus, optional float DestinationOffset, optional bool bUseStrafing, optional bool bShouldWalk);
native(508) final latent function FinishRotation();

// native AI functions
/* LineOfSightTo() returns true if any of several points of Other is visible
  (origin, top, bottom)
*/
native(514) final function bool LineOfSightTo(actor Other);

/* CanSee() similar to line of sight, but also takes into account Pawn's peripheral vision
*/
native(533) final function bool CanSee(Pawn Other);

//Navigation functions - return the next path toward the goal
native(518) final function Actor FindPathTo(vector aPoint);
native(517) final function Actor FindPathToward(actor anActor, optional bool bWeightDetours);
native final function Actor FindPathToIntercept(Pawn P, Actor RouteGoal, optional bool bWeightDetours);
native final function Actor FindPathTowardNearest(class<NavigationPoint> GoalClass, optional bool bWeightDetours);
native(525) final function NavigationPoint FindRandomDest();

native(523) final function vector EAdjustJump(float BaseZ, float XYSpeed);

//Reachable returns whether direct path from Actor to aPoint is traversable
//using the current locomotion method
native(521) final function bool pointReachable(vector aPoint);
native(520) final function bool actorReachable(actor anActor);

/* PickWallAdjust()
Check if could jump up over obstruction (only if there is a knee height obstruction)
If so, start jump, and return current destination
Else, try to step around - return a destination 90 degrees right or left depending on traces
out and floor checks
*/
native(526) final function bool PickWallAdjust(vector HitNormal);

/* WaitForLanding()
latent function returns when pawn is on ground (no longer falling)
*/
native(527) final latent function WaitForLanding();

native(540) final function actor FindBestInventoryPath(out float MinWeight);
native final function actor FindBestSuperPickup(float MaxDist); // find nearest super pickup (base has bDelayedSpawn=true)

native(529) final function AddController();
native(530) final function RemoveController();

// Pick best pawn target
native(531) final function pawn PickTarget(out float bestAim, out float bestDist, vector FireDir, vector projStart, float MaxRange);
native(534) final function actor PickAnyTarget(out float bestAim, out float bestDist, vector FireDir, vector projStart);

native final function bool InLatentExecution(int LatentActionNumber); //returns true if controller currently performing latent action specified by LatentActionNumber
// Force end to sleep
native function StopWaiting();
native function EndClimbLadder();

native final function bool CanMakePathTo(Actor A); // assumes valid CurrentPath, tries to see if CurrentPath can be combine with path to N

event MayFall(); //return true if allowed to fall - called by engine when pawn is about to fall

event MayDodgeToMoveTarget();

event MissedDodge();

function PendingStasis()
{
	bStasis = true;
	Pawn = None;
}

// ----- combos ----- //

function AwardAdrenaline(float Amount)
{
    if ( bAdrenalineEnabled )
    {
		Adrenaline += Amount;
		Adrenaline = Clamp( Adrenaline, 0, AdrenalineMax );
	}
}

function bool NeedsAdrenaline()
{
	return ( (Pawn != None) && !Pawn.InCurrentCombo() && (Adrenaline < AdrenalineMax) );
}

/* DisplayDebug()
list important controller attributes on canvas
*/
function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local string DebugString;

	if ( Pawn == None )
	{
		Super.DisplayDebug(Canvas,YL,YPos);
		return;
	}

	Canvas.SetDrawColor(255,0,0);
	Canvas.DrawText("CONTROLLER "$GetItemName(string(self))$" Pawn "$GetItemName(string(Pawn))$" viewpitch "$Rotation.Pitch);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	if ( Enemy != None )
		Canvas.DrawText("     STATE: "$GetStateName()$" Timer: "$TimerCounter$" Enemy "$Enemy.GetHumanReadableName(), false);
	else
		Canvas.DrawText("     STATE: "$GetStateName()$" Timer: "$TimerCounter$" NO Enemy ", false);
	YPos += YL;
	Canvas.SetPos(4,YPos);


	if ( MonitoredPawn != None )
		DebugString $= "     MonitoredPawn: "@MonitoredPawn.GetHumanReadableName();
	else
		DebugString $= "     MonitoredPawn: None";
	if ( Target != None )
		DebugString $= "     Target: "@Target.GetHumanReadableName();
	else
		DebugString $= "     Target: None";
	Canvas.DrawText(DebugString);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	if ( PlayerReplicationInfo == None )
		Canvas.DrawText("     NO PLAYERREPLICATIONINFO", false);
	else
		PlayerReplicationInfo.DisplayDebug(Canvas,YL,YPos);

	YPos += YL;
	Canvas.SetPos(4,YPos);
}

simulated function String GetHumanReadableName()
{
	if ( PlayerReplicationInfo != None )
		return PlayerReplicationInfo.PlayerName;
	return GetItemName(String(self));
}

simulated function rotator GetViewRotation()
{
	return Rotation;
}

/* Reset()
reset actor to initial state
*/
function Reset()
{
	super.Reset();

	Enemy = None;
	LastSeenTime = 0;
	StartSpot = None;
	Adrenaline = 0;
	bAdjusting = false;
	bPreparingMove = false;
	bJumpOverWall = false;
	bEnemyAcquired = false;
	bHuntPlayer = false;
	bInDodgeMove = false;
	MoveTimer = -1;
	MoveTarget = None;
	PendingMover = None;
	CurrentPath = None;
	RouteGoal = None;
	MonitoredPawn = None;
	WarningProjectile = None;
}

function bool AvoidCertainDeath()
{
	return false;
}

/* ClientSetLocation()
replicated function to set location and rotation.  Allows server to force new location for
teleports, etc.
*/
function ClientSetLocation( vector NewLocation, rotator NewRotation )
{
	SetRotation(NewRotation);
	If ( (Rotation.Pitch > RotationRate.Pitch)
		&& (Rotation.Pitch < 65536 - RotationRate.Pitch) )
	{
		If (Rotation.Pitch < 32768)
			NewRotation.Pitch = RotationRate.Pitch;
		else
			NewRotation.Pitch = 65536 - RotationRate.Pitch;
	}
	if ( Pawn != None )
	{
		NewRotation.Roll  = 0;
		Pawn.SetRotation( NewRotation );
		Pawn.SetLocation( NewLocation );
	}
}

/* ClientSetRotation()
replicated function to set rotation.  Allows server to force new rotation.
*/
function ClientSetRotation( rotator NewRotation )
{
	SetRotation(NewRotation);
	if ( Pawn != None )
	{
		NewRotation.Pitch = 0;
		NewRotation.Roll  = 0;
		Pawn.SetRotation( NewRotation );
	}
}

function ClientDying(class<DamageType> DamageType, vector HitLocation)
{
	if ( Pawn != None )
	{
		Pawn.PlayDying(DamageType, HitLocation);
		Pawn.GotoState('Dying');
	}
}

/* AIHearSound()
Called when AI controlled pawn would hear a sound.  Default AI implementation uses MakeNoise()
interface for hearing appropriate sounds instead
*/
event AIHearSound (
	actor Actor,
	int Id,
	sound S,
	vector SoundLocation,
	vector Parameters,
	bool Attenuate
);

event SoakStop(string problem);

function Possess(Pawn aPawn)
{
	aPawn.PossessedBy(self);
	Pawn = aPawn;
	if ( PlayerReplicationInfo != None )
	{
		if ( Vehicle(Pawn) != None && Vehicle(Pawn).Driver != None )
			PlayerReplicationInfo.bIsFemale = Vehicle(Pawn).Driver.bIsFemale;
		else
			PlayerReplicationInfo.bIsFemale = Pawn.bIsFemale;
	}

	// preserve Pawn's rotation initially for placed Pawns
	FocalPoint = Pawn.Location + 512*vector(Pawn.Rotation);
	Restart();
}

// unpossessed a pawn (not because pawn was killed)
function UnPossess()
{
    if ( Pawn != None )
        Pawn.UnPossessed();
    Pawn = None;
}

function WasKilledBy(Controller Other);

function class<Weapon> GetLastWeapon()
{
	if ( (Pawn == None) || (Pawn.Weapon == None) )
		return LastPawnWeapon;
	return Pawn.Weapon.Class;
}

/* PawnDied()
 unpossess a pawn (because pawn was killed)
 */
function PawnDied(Pawn P)
{
	if ( Pawn != P )
		return;
	if ( Pawn != None )
	{
		if ( Pawn.InCurrentCombo() )
			Adrenaline = 0;
		SetLocation(Pawn.Location);
		Pawn.UnPossessed();
	}
	Pawn = None;
	PendingMover = None;
	if ( bIsPlayer )
    {
        if ( !IsInState('GameEnded') && !IsInState('RoundEnded') )
			GotoState('Dead'); // can respawn
    }
	else
		Destroy();
}

function Restart()
{
	Enemy = None;
}

event LongFall(); // called when latent function WaitForLanding() doesn't return after 4 seconds

// notifications of pawn events (from C++)
// if return true, then pawn won't get notified
event bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume);
event bool NotifyHeadVolumeChange(PhysicsVolume NewVolume);
event bool NotifyLanded(vector HitNormal);
event NotifyPostLanded();
event bool NotifyHitWall(vector HitNormal, actor Wall);
event NotifyFallingHitWall(vector HitNormal, actor Wall); // only if bNotifyFallingHitWall is set
event bool NotifyBump(Actor Other);
event NotifyHitMover(vector HitNormal, mover Wall);
event NotifyJumpApex();
event NotifyMissedJump();

function SetDoubleJump();

// notifications called by pawn in script
function NotifyAddInventory(inventory NewItem);
function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	if ( (instigatedBy != None) && (instigatedBy != pawn) )
		damageAttitudeTo(instigatedBy, Damage);
}

function SetFall();	//about to fall
function PawnIsInPain(PhysicsVolume PainVolume);	// called when pawn is taking pain volume damage

event PreBeginPlay()
{
	AddController();
	Super.PreBeginPlay();
	if ( bDeleteMe )
		return;

	SightCounter = 0.2 * FRand();  //offset randomly
}

event PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( !bDeleteMe && bIsPlayer && (Level.NetMode != NM_Client) )
	{
		PlayerReplicationInfo = Spawn(PlayerReplicationInfoClass, Self,,vect(0,0,0),rot(0,0,0));
		InitPlayerReplicationInfo();
	}
}

function InitPlayerReplicationInfo()
{
	if (PlayerReplicationInfo.PlayerName == "")
		PlayerReplicationInfo.SetPlayerName(class'GameInfo'.Default.DefaultPlayerName);

	PlayerReplicationInfo.bNoTeam = !Level.Game.bTeamGame;
}

simulated function int GetTeamNum()
{
	if ( (PlayerReplicationInfo == None) || (PlayerReplicationInfo.Team == None) )
		return 255;

	return PlayerReplicationInfo.Team.TeamIndex;
}

function bool SameTeamAs(Controller C)
{
	if ( C == None )
		return false;
	return Level.Game.IsOnTeam(C,GetTeamNum());
}

function HandlePickup(Pickup pick)
{
	if ( MoveTarget == pick )
	{
		if ( pick.MyMarker != None )
		{
			MoveTarget = pick.MyMarker;
			Pawn.Anchor = pick.MyMarker;
			MoveTimer = 0.5;
		}
		else
			MoveTimer = -1.0;
	}
}

simulated event Destroyed()
{
	if ( Role < ROLE_Authority )
    {
    	Super.Destroyed();
		return;
    }

	RemoveController();

	if ( bIsPlayer && (Level.Game != None) )
		Level.Game.logout(self);
	if ( PlayerReplicationInfo != None )
	{
		if ( !PlayerReplicationInfo.bOnlySpectator && (PlayerReplicationInfo.Team != None) )
			PlayerReplicationInfo.Team.RemoveFromTeam(self);
		PlayerReplicationInfo.Destroy();
	}
	Super.Destroyed();
}

event bool AllowDetourTo(NavigationPoint N)
{
	return true;
}

/* AdjustView()
by default, check and see if pawn still needs to update eye height
(only if some playercontroller still has pawn as its viewtarget)
Overridden in playercontroller
*/
function AdjustView( float DeltaTime )
{
	local Controller C;

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
		if ( C.IsA('PlayerController') && (PlayerController(C).ViewTarget == Pawn) )
			return;

	Pawn.bUpdateEyeHeight =false;
	Pawn.Eyeheight = Pawn.BaseEyeheight;
}

function bool WantsSmoothedView()
{
	return ( (Pawn != None) && ((Pawn.Physics==PHYS_Walking) || (Pawn.Physics==PHYS_Spider)) && !Pawn.bJustLanded );
}

function GameHasEnded()
{
	if ( Pawn != None )
		Pawn.bNoWeaponFiring = true;
	GotoState('GameEnded');
}

function ClientGameEnded()
{
	GotoState('GameEnded');
}

function RoundHasEnded()
{
	if ( Pawn != None )
		Pawn.bNoWeaponFiring = true;
	GotoState('RoundEnded');
}

function ClientRoundEnded()
{
	GotoState('RoundEnded');
}

simulated event RenderOverlays( canvas Canvas );

/* GetFacingDirection()
returns direction faced relative to movement dir

0 = forward
16384 = right
32768 = back
49152 = left
*/
function int GetFacingDirection()
{
	return 0;
}

//------------------------------------------------------------------------------
// Speech related

function byte GetMessageIndex(name PhraseName)
{
	return 0;
}

function SendMessage(PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait, name BroadcastType)
{
	SendVoiceMessage(PlayerReplicationInfo, Recipient, MessageType, MessageID, BroadcastType);
}

function bool AllowVoiceMessage(name MessageType)
{
	if ( Level.TimeSeconds - OldMessageTime < 10 )
		return false;
	else
		OldMessageTime = Level.TimeSeconds;

	return true;
}

function SendVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID, name broadcasttype)
{
	local Controller P;

	if ( ((Recipient == None) || (AIController(self) == None))
		&& !AllowVoiceMessage(MessageType) )
		return;

	for ( P=Level.ControllerList; P!=None; P=P.NextController )
	{
		if ( PlayerController(P) != None )
		{
			if ((P.PlayerReplicationInfo == Sender) ||
				(P.PlayerReplicationInfo == Recipient &&
				 (Level.Game.BroadcastHandler == None ||
				  Level.Game.BroadcastHandler.AcceptBroadcastSpeech(PlayerController(P), Sender)))
				)
				P.ClientVoiceMessage(Sender, Recipient, messagetype, messageID);
			else if ( (Recipient == None) || (Level.NetMode == NM_Standalone) )
			{
				if ( (broadcasttype == 'GLOBAL') || !Level.Game.bTeamGame || (Sender.Team == P.PlayerReplicationInfo.Team) )
					if ( Level.Game.BroadcastHandler == None || Level.Game.BroadcastHandler.AcceptBroadcastSpeech(PlayerController(P), Sender) )
						P.ClientVoiceMessage(Sender, Recipient, messagetype, messageID);
			}
		}
		else if ( (messagetype == 'ORDER') && ((Recipient == None) || (Recipient == P.PlayerReplicationInfo)) )
			P.BotVoiceMessage(messagetype, messageID, self);
	}
}

function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID);
function BotVoiceMessage(name messagetype, byte MessageID, Controller Sender);

//***************************************************************
// interface used by ScriptedControllers to query pending controllers

function bool WouldReactToNoise( float Loudness, Actor NoiseMaker)
{
	return false;
}

function bool WouldReactToSeeing(Pawn Seen)
{
	return false;
}

//***************************************************************
// AI related

/* AdjustToss()
return adjustment to Z component of aiming vector to compensate for arc given the target
distance
*/
function vector AdjustToss(float TSpeed, vector Start, vector End, bool bNormalize)
{
	local vector Dest2D, Result, Vel2D;
	local float Dist2D;

	if ( Start.Z > End.Z + 64 )
	{
		Dest2D = End;
		Dest2D.Z = Start.Z;
		Dist2D = VSize(Dest2D - Start);
		TSpeed *= Dist2D/VSize(End - Start);
		Result = SuggestFallVelocity(Dest2D,Start,TSpeed,TSpeed);
		Vel2D = result;
		Vel2D.Z = 0;
		Result.Z = Result.Z + (End.Z - Start.Z) * VSize(Vel2D)/Dist2D;
	}
	else
	{
		Result = SuggestFallVelocity(End,Start,TSpeed,TSpeed);
	}
	if ( bNormalize )
		return TSpeed * Normal(Result);
	else
		return Result;
}

event PrepareForMove(NavigationPoint Goal, ReachSpec Path);
function WaitForMover(Mover M);
function MoverFinished();
function UnderLift(Mover M);

function FearThisSpot(AvoidMarker aSpot)
{
	local int i;

	if ( Pawn == None )
		return;
	if ( !LineOfSightTo(aSpot) )
		return;
	for ( i=0; i<2; i++ )
		if ( FearSpots[i] == None )
		{
			FearSpots[i] = aSpot;
			return;
		}
	for ( i=0; i<2; i++ )
		if ( VSize(Pawn.Location - FearSpots[i].Location) > VSize(Pawn.Location - aSpot.Location) )
		{
			FearSpots[i] = aSpot;
			return;
		}
}

event float Desireability(Pickup P)
{
	return P.BotDesireability(Pawn);
}

event float SuperDesireability(Pickup P)
{
	return P.BotDesireability(Pawn);
}

/* called before start of navigation network traversal to allow setup of transient navigation flags
*/
event SetupSpecialPathAbilities();

event HearNoise( float Loudness, Actor NoiseMaker);
event SeePlayer( Pawn Seen );	// called when a player (bIsPlayer==true) pawn is seen
event SeeMonster( Pawn Seen );	// called when a non-player (bIsPlayer==false) pawn is seen
event EnemyNotVisible();

function DamageShake(int damage);
function ShakeView(vector shRotMag,    vector shRotRate,    float shRotTime,
                   vector shOffsetMag, vector shOffsetRate, float shOffsetTime);

function NotifyKilled(Controller Killer, Controller Killed, pawn Other)
{
	if ( Enemy == Other )
		Enemy = None;
}

function damageAttitudeTo(pawn Other, float Damage);
function float AdjustDesireFor(Pickup P);
function bool FireWeaponAt(Actor A);

function StopFiring()
{
	if ( Pawn != None )
		Pawn.StopWeaponFiring();
	bFire = 0;
	bAltFire = 0;
}

simulated function float RateWeapon(Weapon w)
{
    return w.Default.Priority;
}

function float WeaponPreference(Weapon W)
{
	return 0.0;
}

/* AdjustAim()
AIController version does adjustment for non-controlled pawns.
PlayerController version does the adjustment for player aiming help.
Only adjusts aiming at pawns
allows more error in Z direction (full as defined by AutoAim - only half that difference for XY)
*/
function rotator AdjustAim(FireProperties FiredAmmunition, vector projStart, int aimerror)
{
    return Rotation;
}

function InstantWarnTarget(Actor Target, FireProperties FiredAmmunition, vector FireDir)
{
	local float Dist;

	if ( FiredAmmunition.bInstantHit && (Pawn(Target) != None) && (Pawn(Target).Controller != None)  )
	{
		Dist = VSize(Pawn.Location - Target.Location);
		if ( VSize(FireDir * Dist - Target.Location) < Target.CollisionRadius )
			return;
		if ( FRand() < FiredAmmunition.WarnTargetPct )
			Pawn(Target).Controller.ReceiveWarning(Pawn, -1, FireDir);
		return;
	}
}
/* ReceiveWarning()
 AI controlled creatures may duck
 if not falling, and projectile time is long enough
 often pick opposite to current direction (relative to shooter axis)
*/
event ReceiveWarning(Pawn shooter, float projSpeed, vector FireDir);

function ReceiveProjectileWarning(Projectile proj)
{
	if ( WarningProjectile == None )
		ReceiveWarning(Proj.Instigator, Proj.speed, Normal(Proj.Velocity));
}

/* If ReceiveWarning caused WarningDelay to be set, this will be called when it times out
*/
event DelayedWarning();

exec function SwitchToBestWeapon()
{
	local float rating;

	if ( Pawn == None || Pawn.Inventory == None )
		return;

    if ( (Pawn.PendingWeapon == None) || (AIController(self) != None) )
    {
	    Pawn.PendingWeapon = Pawn.Inventory.RecommendWeapon(rating);
	    if ( Pawn.PendingWeapon == Pawn.Weapon )
		    Pawn.PendingWeapon = None;
	    if ( Pawn.PendingWeapon == None )
    		return;
    }

	StopFiring();

	if ( Pawn.Weapon == None )
		Pawn.ChangedWeapon();
	else if ( Pawn.Weapon != Pawn.PendingWeapon )
    {
		Pawn.Weapon.PutDown();
    }
}

// server calls this to force client to switch
function ClientSwitchToBestWeapon()
{
    SwitchToBestWeapon();
}

function ClientSetWeapon( class<Weapon> WeaponClass )
{
    local Inventory Inv;
	local int Count;

    for( Inv = Pawn.Inventory; Inv != None; Inv = Inv.Inventory )
    {
		Count++;
		if ( Count > 1000 )
			return;
        if( !ClassIsChildOf( Inv.Class, WeaponClass ) )
            continue;

	    if( Pawn.Weapon == None )
        {
            Pawn.PendingWeapon = Weapon(Inv);
    		Pawn.ChangedWeapon();
        }
	    else if ( Pawn.Weapon != Weapon(Inv) )
        {
    		Pawn.PendingWeapon = Weapon(Inv);
	    	Pawn.Weapon.PutDown();
        }

        return;
    }
}

function SetPawnClass(string inClass, string inCharacter)
{
    local class<Pawn> pClass;

    if ( inClass == "" )
		return;
    pClass = class<Pawn>(DynamicLoadObject(inClass, class'Class'));
    if ( pClass != None )
        PawnClass = pClass;
}

function SetPawnFemale();

function bool CheckFutureSight(float DeltaTime)
{
	return true;
}

function ChangedWeapon()
{
	if ( Pawn.Weapon != None )
		LastPawnWeapon = Pawn.Weapon.Class;
}

function ServerReStartPlayer()
{
	if ( Level.NetMode == NM_Client )
		return;
	if ( Pawn != None )
		ServerGivePawn();
}

function ServerGivePawn();

event MonitoredPawnAlert();

function StartMonitoring(Pawn P, float MaxDist)
{
	MonitoredPawn = P;
	MonitorStartLoc = P.Location;
	MonitorMaxDistSq = MaxDist * MaxDist;
}

function bool AutoTaunt()
{
	return false;
}

function bool DontReuseTaunt(int T)
{
	return false;
}

// - ParseChatPercVar should be subclassed if a controller needs more of them
function string ParseChatPercVar(string Cmd)
{
	if (cmd~="%A")	// Adrenaline
		return int(Adrenaline)@"Adrenaline";

	if ( (Pawn != None) && (cmd~="%S") ) // Shield
		return int(Pawn.ShieldStrength)@"Shield";

	return Cmd;
}

// **********************************************
// Controller States

State Dead
{
ignores SeePlayer, HearNoise, KilledBy;

	function PawnDied(Pawn P)
	{
		if ( Level.NetMode != NM_Client )
			warn(self$" Pawndied while dead");
	}

	function ServerReStartPlayer()
	{
		if ( Level.NetMode == NM_Client )
			return;
		Level.Game.RestartPlayer(self);
	}
}

state GameEnded
{
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange, Falling, TakeDamage, ReceiveWarning;

	function BeginState()
	{
		if ( Pawn != None )
		{
			if ( Pawn.Weapon != None )
				Pawn.Weapon.HolderDied();
			Pawn.SimAnim.AnimRate = 0;
			Pawn.TurnOff();
			Pawn.UnPossessed();
			Pawn = None;
		}
		if ( !bIsPlayer )
			Destroy();
	}
}

state RoundEnded
{
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange, Falling, TakeDamage, ReceiveWarning;

	function BeginState()
	{
		if ( Pawn != None )
		{
			if ( Pawn.Weapon != None )
				Pawn.Weapon.HolderDied();
			Pawn.SimAnim.AnimRate = 0;
			Pawn.TurnOff();
			Pawn.UnPossessed();
			Pawn = None;
		}
		if ( !bIsPlayer )
			Destroy();
	}
}

defaultproperties
{
     FovAngle=90.000000
     Handedness=2.000000
     bAdrenalineEnabled=True
     bSlowerZAcquire=True
     MinHitWall=-1.000000
     AcquisitionYawRate=20000
     PlayerReplicationInfoClass=Class'Engine.PlayerReplicationInfo'
     AdrenalineMax=100.000000
     bHidden=True
     bOnlyRelevantToOwner=True
     RemoteRole=ROLE_None
     RotationRate=(Pitch=3072,Yaw=30000,Roll=2048)
     bHiddenEd=True
}
