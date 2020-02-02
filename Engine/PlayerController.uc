//=============================================================================
// PlayerController
//
// PlayerControllers are used by human players to control pawns.
//
// This is a built-in Unreal class and it shouldn't be modified.
// for the change in Possess().
//=============================================================================
class PlayerController extends Controller
    config(user)
    native
    nativereplication
    exportstructs
	DependsOn(Interactions);

// Player info.
var const player Player;

// player input control
var globalconfig    bool    bLookUpStairs;  // look up/down stairs (player)
var globalconfig    bool    bSnapToLevel;   // Snap to level eyeheight when not mouselooking
var globalconfig    bool    bAlwaysMouseLook;
var globalconfig    bool    bKeyboardLook;  // no snapping when true
var bool                    bCenterView;

// Player control flags
var bool        bBehindView;    // Outside-the-player view.
var bool        bFrozen;        // set when game ends or player dies to temporarily prevent player from restarting (until cleared by timer)
var bool        bPressedJump;
var	bool		bDoubleJump;
var bool        bUpdatePosition;
var bool        bIsTyping;
var bool        bFixedCamera;   // used to fix camera in position (to view animations)
var bool        bJumpStatus;    // used in net games
var bool        bUpdating;
var globalconfig bool   bNeverSwitchOnPickup;   // if true, don't automatically switch to picked up weapon
var bool		bHideSpectatorBeacons;
var bool        bZooming;
var	bool		bHideVehicleNoEntryIndicator;

var globalconfig bool bAlwaysLevel;
var bool        bSetTurnRot;
var bool        bCheatFlying;   // instantly stop in flying mode
var bool        bFreeCamera;    // free camera when in behindview mode (for checking out player models and animations)
var bool        bZeroRoll;
var bool        bCameraPositionLocked;
var	bool		bViewBot;
var bool		UseFixedVisibility;

var bool    bFreeCam;               // In FreeCam mode to adjust the cam rotator
var bool    bFreeCamZoom;           // In zoom mode
var bool    bFreeCamSwivel;         // In swivel mode
var bool	bBlockCloseCamera;
var bool	bValidBehindCamera;
var bool	bForcePrecache;
var bool	bClientDemo;
var const bool bAllActorsRelevant;	// used by UTTV.  DO NOT SET THIS TRUE - it has a huge impact on network performance
var bool	bShortConnectTimeOut;	// when true, reduces connect timeout to 15 seconds
var bool	bPendingDestroy;		// when true, playercontroller is being destroyed
var	bool	bEnableAmbientShake;

var globalconfig bool bNoVoiceMessages;
var globalconfig bool bNoTextToSpeechVoiceMessages;
var globalconfig bool bNoVoiceTaunts;
var globalconfig bool bNoAutoTaunts;
var globalconfig bool bAutoTaunt;
var globalconfig bool bNoMatureLanguage;
var globalconfig bool bDynamicNetSpeed;
var globalconfig bool bSmallWeapons;
var bool bWeaponViewShake;
var globalconfig bool bLandingShake;
var globalconfig bool bAimingHelp;

var(ForceFeedback) globalconfig bool bEnablePickupForceFeedback;
var(ForceFeedback) globalconfig bool bEnableWeaponForceFeedback;
var(ForceFeedback) globalconfig bool bEnableDamageForceFeedback;
var(ForceFeedback) globalconfig bool bEnableGUIForceFeedback;
var(ForceFeedback) bool bForceFeedbackSupported;  // true if a device is detected

var(VoiceChat)               bool           bVoiceChatEnabled;	    // Whether voice chat is enabled on this client
var(VoiceChat)  globalconfig bool           bEnableInitialChatRoom; // Enables speaking on DefaultActiveChannel upon joining server
var	bool									bViewingMatineeCinematic;
var bool									bCustomListener;
var bool									bAcuteHearing;			// makes playercontroller hear much better (used to magnify hit sounds caused by player)

var bool bMenuBeforeRespawn; //forces the midgame menu to pop up before player can click to respawn

var bool  bSkippedLastUpdate, bLastPressedJump;

var globalconfig bool bEnableStatsTracking;
var globalconfig bool bOnlySpeakTeamText;

var bool bWasSpeedHack;
var bool bIsSpaceFighter;	// hack for spacefighter joystick controls
var const bool bWasSaturated;		// used by servers to identify saturated client connections

var float FOVBias;

// Voice Chat
struct StoredChatPassword
{
	var string ChatRoomName;
	var string ChatRoomPassword;
};
// Contains a bit-mask of which channels to auto-join
// 1 - Public, 2 - Local, 4 - Team
var(VoiceChat)  globalconfig byte			AutoJoinMask;

var input byte
    bStrafe, bSnapLevel, bLook, bFreeLook, bTurn180, bTurnToNearest, bXAxis, bYAxis;

var EDoubleClickDir DoubleClickDir;     // direction of movement key double click (for special moves)

var globalconfig byte AnnouncerLevel;        // 0=none, 1=no possession announcements, 2=all
var globalconfig byte AnnouncerVolume;       // 1 to 4

var globalconfig float	TextToSpeechVoiceVolume;

var float MaxResponseTime;		 // how long server will wait for client move update before setting position
var float WaitDelay;                         // Delay time until can restart
var pawn AcknowledgedPawn;				     // used in net games so client can acknowledge it possessed a pawn

var input float
    aBaseX, aBaseY, aBaseZ, aMouseX, aMouseY,
    aForward, aTurn, aStrafe, aUp, aLookUp;

// Vehicle Move Replication
var float aLastForward, aLastStrafe, aLastUp, NumServerDrives, NumSkips;

// Vehicle Check Radius
var float   VehicleCheckRadius;         // Radius that is checked for nearby vehicles when pressing use
var bool	bSuccessfulUse;				// gives PC a hint that UsedBy was successful

// Camera info.
var int ShowFlags;
var int Misc1,Misc2;
var int RendMap;
var float        OrthoZoom;     // Orthogonal/map view zoom factor.
var const actor ViewTarget;
var const Controller RealViewTarget;
var PlayerController DemoViewer;
var float CameraDist;       // multiplier for behindview camera dist
var range CameraDistRange;
var vector OldCameraLoc;		// used in behindview calculations
var rotator OldCameraRot;
var transient array<CameraEffect> CameraEffects;    // A stack of camera effects.

var globalconfig float DesiredFOV;
var globalconfig float DefaultFOV;
var float       ZoomLevel, DesiredZoomLevel;

// Audio.
var vector ListenerLocation;
var rotator ListenerRotation;

// Fixed visibility.
var vector	FixedLocation;
var rotator	FixedRotation;
var matrix	RenderWorldToCamera;

// Screen flashes
var vector FlashScale, FlashFog;
var float ConstantGlowScale;
var vector ConstantGlowFog;
var globalconfig float ScreenFlashScaling;

// Distance fog fading.
var color	LastDistanceFogColor;
var float	LastDistanceFogStart;
var float	LastDistanceFogEnd;
var float	CurrentDistanceFogEnd;
var float	TimeSinceLastFogChange;
var int		LastZone;

// Remote Pawn ViewTargets
var rotator     TargetViewRotation;
var rotator     BlendedTargetViewRotation;
var float       TargetEyeHeight;
var vector      TargetWeaponViewOffset;

var HUD myHUD;  // heads up display info

var float LastPlaySound;
var float LastPlaySpeech;

// Music info.
var string              Song;
var EMusicTransition    Transition;

// Move buffering for network games.  Clients save their un-acknowledged moves in order to replay them
// when they get position updates from the server.
var SavedMove SavedMoves;   // buffered moves pending position updates
var SavedMove FreeMoves;    // freed moves, available for buffering
var SavedMove PendingMove;
var float CurrentTimeStamp,LastUpdateTime,ServerTimeStamp,TimeMargin, ClientUpdateTime;
var float MaxTimeMargin;
var globalconfig float TimeMarginSlack; // OBSOLETE
var Weapon OldClientWeapon;
var int WeaponUpdate;

// Progess Indicator - used by the engine to provide status messages (HUD is responsible for displaying these).
var string  ProgressMessage[4];
var color   ProgressColor[4];
var float   ProgressTimeOut;

// Localized strings
var localized string QuickSaveString;
var localized string NoPauseMessage;
var localized string ViewingFrom;
var localized string OwnCamera;

// ReplicationInfo
var GameReplicationInfo			GameReplicationInfo;
var VoiceChatReplicationInfo	VoiceReplicationInfo;
var VotingReplicationInfoBase   VoteReplicationInfo;

// Stats Logging
var globalconfig string StatsUsername;
var globalconfig string StatsPassword;

var class<LocalMessage> LocalMessageClass;
var(VoiceChat) class<ChatRoomMessage> ChatRoomMessageClass;

// view shaking (affects roll, and offsets camera position)
var vector  ShakeOffsetRate;
var vector  ShakeOffset; //current magnitude to offset camera from shake
var vector  ShakeOffsetTime;
var vector  ShakeOffsetMax;
var vector  ShakeRotRate;
var vector  ShakeRotMax;
var rotator ShakeRot;
var vector  ShakeRotTime;

var	float		AmbientShakeFalloffStartTime;
var float		AmbientShakeFalloffTime; // Time taken for shaking to stop after AmbientShakeFalloffStartTime has passed.
var vector		AmbientShakeOffsetMag;
var float		AmbientShakeOffsetFreq;
var rotator		AmbientShakeRotMag;
var float		AmbientShakeRotFreq;

var Pawn        TurnTarget;
var config int  EnemyTurnSpeed;
var int         GroundPitch;
var rotator     TurnRot180;

var vector OldFloor;        // used by PlayerSpider mode - floor for which old rotation was based;

// Components ( inner classes )
var private transient CheatManager    CheatManager;   // Object within playercontroller that manages "cheat" commands
var class<CheatManager>               CheatClass;     // class of my CheatManager
var private transient PlayerInput     PlayerInput;    // Object within playercontroller that manages player input.
var config class<PlayerInput>         InputClass;     // class of my PlayerInput
var private transient AdminBase		  AdminManager;
var transient MaplistManagerBase      MapHandler;     // Used by AdminBase
var string                            PlayerChatType;
var PlayerChatManager				  ChatManager;    // Manages all chat, speech, and voice messages sent to player
var const vector FailedPathStart;

// Camera control for debugging/tweaking

// BehindView Camera Adjustments
var rotator CameraDeltaRotation;    // The rotator delta adjustment
var float   CameraDeltaRad;         // The zoom delta adjustment
var rotator CameraSwivel;           // The swivel adjustment

// For drawing player names
struct PlayerNameInfo
{
    var string mInfo;
    var color  mColor;
    var float  mXPos;
    var float  mYPos;
};

var(TeamBeacon) float      TeamBeaconMaxDist;
var(TeamBeacon) float      TeamBeaconPlayerInfoMaxDist;
var(TeamBeacon) Texture    TeamBeaconTexture;
var(TeamBeacon) Texture    LinkBeaconTexture;
var(TeamBeacon) Texture    SpeakingBeaconTexture;
var(TeamBeacon) Color      TeamBeaconTeamColors[2];
var(TeamBeacon) Color      TeamBeaconCustomColor;

var private const array<PlayerNameInfo> PlayerNameArray;

// Demo recording view rotation
var int DemoViewPitch;
var int DemoViewYaw;

var Security PlayerSecurity;	// Used for Cheat Protection

var float LoginDelay;
var float NextLoginTime;
var float ForcePrecacheTime;

var float LastPingUpdate;
var float ExactPing;
var float OldPing;
var float SpectateSpeed;
var globalconfig float DynamicPingThreshold;
var float NextSpeedChange;
var float VoiceChangeLimit;
var int ClientCap;

var(Menu)	config string	MidGameMenuClass;	// Menu that is shown when Escape is pressed
var(Menu)	config string   DemoMenuClass;		// Menu used for demos
var(Menu)   config string	AdminMenuClass;	    // Menu that is shown when adminmenu command is used
var(Menu)   config string   ChatPasswordMenuClass;	// Menu that appears when attempting to join a chatroom that has a password


var(VoiceChat) globalconfig array<StoredChatPassword> 	StoredChatPasswords;
var				VoiceChatRoom				ActiveRoom;			// The chatroom we're currently speaking to
var(VoiceChat)  globalconfig string         LastActiveChannel;	// Stores the currently active channel when switching maps
var(VoiceChat)  globalconfig string         VoiceChatCodec;     // Which voice chat codec to request in internet games (will only be used if it exists on server)
var(VoiceChat)  globalconfig string         VoiceChatLANCodec;  // Which voice chat codec to request in LAN games

var(VoiceChat)	globalconfig string 		ChatPassword;		// Password for our personal chat room
var(VoiceChat)  globalconfig string         DefaultActiveChannel;	// Channel we initially want to make active

// ClientAdjustPosition replication (event called at end of frame)
struct ClientAdjustment
{
    var float TimeStamp;
    var name newState;
    var EPhysics newPhysics;
    var vector NewLoc;
    var vector NewVel;
    var actor NewBase;
    var vector NewFloor;
};
var ClientAdjustment PendingAdjustment;

var	AnnouncerQueueManager		AnnouncerQueueManager;	// Handling Announcer Queueing
var AnnouncerVoice StatusAnnouncer;
var AnnouncerVoice RewardAnnouncer;

var float LastActiveTime;		// used to kick idlers

var Actor	CalcViewActor;		// optimize PlayerCalcView
var vector	CalcViewActorLocation;
var vector	CalcViewLocation;
var rotator	CalcViewRotation;
var float	LastPlayerCalcView;

var float LastBroadcastTime;
var string LastBroadcastString[4];
var float LastSpeedHackLog;

var string PlayerOwnerName;	// for savegames

replication
{
    // Things the server should send to the client.
    reliable if( bNetDirty && bNetOwner && Role==ROLE_Authority )
        GameReplicationInfo, VoiceReplicationInfo, ChatManager, LoginDelay;
    unreliable if ( bNetOwner && Role==ROLE_Authority && (ViewTarget != Pawn) && (Pawn(ViewTarget) != None) )
        TargetViewRotation, TargetEyeHeight;
    reliable if( bDemoRecording && Role==ROLE_Authority )
        DemoViewPitch, DemoViewYaw;

    // Functions server can call.
    reliable if( Role==ROLE_Authority )
        ClientSetHUD,ClientReliablePlaySound, FOV, StartZoom,
        ToggleZoom, StopZoom, EndZoom, ClientSetMusic, ClientRestart, ClientReset,
        ClientAdjustGlow,
        ClientSetBehindView, ClientSetFixedCamera, ClearProgressMessages,
        ProgressCommand, SetProgressMessage, SetProgressTime,
        GivePawn, ClientGotoState,
		ClientSetActiveRoom, ChatRoomMessage,
		ClientValidate, ClientSetWeaponViewShake,
        ClientSetViewTarget, ClientCapBandwidth,
		ClientOpenMenu, ClientCloseMenu, ClientReplaceMenu, ClientNetworkMessage,
		AdminReply;
    reliable if ( (Role == ROLE_Authority) )
        ClientMessage, TeamMessage, ReceiveLocalizedMessage, QueueAnnouncement;
    unreliable if( Role==ROLE_Authority && !bDemoRecording )
        ClientPlaySound, PlayAnnouncement, PlayRewardAnnouncement, PlayStatusAnnouncement;
    reliable if( Role==ROLE_Authority && !bDemoRecording )
        ClientStopForceFeedback, ClientTravel, ClientSetClassicView;
    unreliable if( Role==ROLE_Authority )
        SetFOVAngle, ClientDamageShake, ClientFlash,ClientUpdateFlagHolder,
        ClientAdjustPosition, ShortClientAdjustPosition, VeryShortClientAdjustPosition, LongClientAdjustPosition;
    unreliable if( (!bDemoRecording || bClientDemoRecording && bClientDemoNetFunc) && Role==ROLE_Authority )
        ClientHearSound;
    reliable if( bClientDemoRecording && ROLE==ROLE_Authority )
		DemoClientSetHUD;

    // Functions client can call.
    unreliable if( Role<ROLE_Authority )
        ServerUpdatePing, ShortServerMove, ServerMove, RocketServerMove;

    reliable if( Role<ROLE_Authority )
		ServerShortTimeout;

    unreliable if( Role<ROLE_Authority )
		ServerVoiceCommand,
        DualServerMove, DualRocketServerMove, TurretServerMove, DualTurretServerMove, DualSpaceFighterServerMove, SpaceFighterServerMove,
        ServerSay, ServerTeamSay, ServerSetHandedness, ServerSetAutotaunt, ServerViewNextPlayer, ServerViewSelf,ServerUse, ServerDrive, ServerToggleBehindView;
    reliable if( Role<ROLE_Authority )
        ServerSpeech, ServerPause, SetPause, ServerMutate, ServerAcknowledgePossession,
        PrevItem, ActivateItem, ServerReStartGame, AskForPawn,
        ChangeName, ChangeVoiceType, ServerChangeTeam, Suicide,
        ServerThrowWeapon, BehindView, Typing,
		ServerValidationResponse, ServerVerifyViewTarget, ServerSpectateSpeed, ServerSetClientDemo,
		ServerSpectate, BecomeSpectator, BecomeActivePlayer;

	// Server Admin replicated functions
	reliable if( Role<ROLE_Authority )
		Admin, AdminCommand, ServerAdminLogin, AdminLogout, AdminDebug;

	// Voice-chat replicated function
	reliable if (Role < ROLE_Authority)
		ServerSetChatPassword, ServerJoinVoiceChannel, ServerLeaveVoiceChannel, ServerSpeak,
		ServerChangeVoiceChatMode, ServerChatRestriction, ServerRequestBanInfo, ServerGetWeaponStats;

	reliable if ( Role < ROLE_Authority )
		ServerChatDebug;

	reliable if (ROLE==ROLE_Authority)
    	ResetFOV, ClientBecameSpectator, ClientBecameActivePlayer;

}

native final function SetNetSpeed(int NewSpeed);
native final function string GetPlayerIDHash();
native final function string GetPlayerNetworkAddress();
native final function string GetServerNetworkAddress();
native function string ConsoleCommand( string Command, optional bool bWriteToLog );
native final function LevelInfo GetEntryLevel();
native(544) final function ResetKeyboard();
native final private function ResetInput();

native final function SetViewTarget(Actor NewViewTarget);
native event ClientTravel( string URL, ETravelType TravelType, bool bItems );
native final function string GetURLProtocol();
native final function string GetDefaultURL(string Option);
// Execute a console command in the context of this player, then forward to Actor.ConsoleCommand.
native function CopyToClipboard( string Text );
native function string PasteFromClipboard();

// Validation.
private native event ClientValidate(string C);
private native event ServerValidationResponse(string R);

native final function bool CheckSpeedHack(float DeltaTime);

/* FindStairRotation()
returns an integer to use as a pitch to orient player view along current ground (flat, up, or down)
*/
native(524) final function int FindStairRotation(float DeltaTime);

native event ClientHearSound (
    actor Actor,
    int Id,
    sound S,
    vector SoundLocation,
    vector Parameters,
    bool Attenuate
);

exec function GetWeaponStats()
{
}

function ServerGetWeaponStats(Weapon W)
{
	if ( (Pawn == None) || (Pawn.Weapon == None) )
	{
		log("Weapon stats requested by "$PlayerReplicationInfo.PlayerName$" with pawn "$Pawn$" and no weapon");
		return;
	}
	log("Weapon stats requested by "$PlayerReplicationInfo.PlayerName$" for "$Pawn.Weapon);
	if ( W != None )
		W.StartDebugging();
	Pawn.Weapon.StartDebugging();
}

simulated event PostBeginPlay()
{
	local class<PlayerChatManager> PlayerChatClass;

    super.PostBeginPlay();
	MaxTimeMargin = Level.MaxTimeMargin;
	MaxResponseTime = Default.MaxResponseTime * Level.TimeDilation;

	if ( Level.NetMode == NM_Client )
		SpawnDefaultHUD();

	if (Level.LevelEnterText != "" )
        ClientMessage(Level.LevelEnterText);

    FixFOV();
    SetViewTarget(self);  // MUST have a view target!
	LastActiveTime = Level.TimeSeconds;

	if ( Level.NetMode == NM_Standalone )
        AddCheats();

    bForcePrecache = (Role < ROLE_Authority);
    ForcePrecacheTime = Level.TimeSeconds + 1.2;

    if ( Level.Game != None )
    	MapHandler = Level.Game.MaplistHandler;

    if ( (PlayerChatType != "") && (Role == ROLE_Authority) )
    {
    	PlayerChatClass = class<PlayerChatManager>(DynamicLoadObject(PlayerChatType, class'Class'));
    	if ( PlayerChatClass != None )
    		ChatManager = Spawn(PlayerChatClass, Self);
    }
}

simulated function bool BeyondViewDistance(vector OtherLocation, float CullDistance)
{
	local float Dist;

	if ( ViewTarget == None )
		return true;

	Dist = VSize(OtherLocation - ViewTarget.Location);

	if ( (CullDistance > 0) && (CullDistance < Dist * FOVBias) )
		return true;

	return ( Region.Zone.bDistanceFog && (Dist > Region.Zone.DistanceFogEnd) );
}

event KickWarning()
{
	ReceiveLocalizedMessage( class'GameMessage', 15 );
}

function ResetTimeMargin()
{
    TimeMargin = -0.1;
	MaxTimeMargin = Level.MaxTimeMargin;
}

function ServerShortTimeout()
{
	local Actor A;

	bShortConnectTimeOut = true;
	ResetTimeMargin();

	// quick update of pickups and gameobjectives since this player is now relevant
	if ( Level.Game.NumPlayers < 8 )
	{
		ForEach AllActors(class'Actor', A)
			if ( (A.NetUpdateFrequency < 1) && !A.bOnlyRelevantToOwner )
				A.NetUpdateTime = FMin(A.NetUpdateTime, Level.TimeSeconds + 0.2 * FRand());
}
	else
	{
		ForEach AllActors(class'Actor', A)
			if ( (A.NetUpdateFrequency < 1) && !A.bOnlyRelevantToOwner )
				A.NetUpdateTime = FMin(A.NetUpdateTime, Level.TimeSeconds + 0.5 * FRand());
	}
}


function Actor GetPathTo(Actor Dest)
{
	local int i;
	local Actor Best;
	local vector Dir;

	if ( Dest == None )
		return Dest;

	if ( (Pawn.Physics != PHYS_Falling) && ((RouteGoal != Dest) || (Level.TimeSeconds - LastRouteFind > 1+FRand())) )
	{
		MoveTarget = FindPathToward(Dest, false);
		if ( MoveTarget == None )
			return Dest;
	}

	if ( RouteCache[0] == None )
		return Dest;

	if ( RouteCache[1] == None )
		return RouteCache[0];

	Best = RouteCache[0];
	Dir = Normal(RouteCache[1].Location - RouteCache[0].Location);

	// return furthest visible path in a relatively straight line from first
	for ( i=0; i<5; i++ )
	{
		if ( (RouteCache[i] == None) || (VSize(Pawn.Location - RouteCache[i].Location) > 2000) )
			break;
		if ( ((Normal(RouteCache[i].Location - RouteCache[0].Location) Dot Dir) > 0.7)
			&& LineOfSightTo(RouteCache[i]) )
			Best = RouteCache[i];
	}

	return Best;
}

// This is called by the low level audio code whenever a stream is finished
//!! Only for music started with PlayStream()
simulated event StreamFinished(int StreamHandle, Interactions.EStreamFinishReason Reason)
{
	local int i;

	if ( Player != None )
	{
		for ( i = 0; i < Player.LocalInteractions.Length; i++ )
			if ( Player.LocalInteractions[i] != None )
				Player.LocalInteractions[i].StreamFinished( StreamHandle, Reason );
	}
}

exec function KillAll(class<actor> aClass)
{
	local Actor A;
	local Controller C;

	if (Role != ROLE_Authority)
		return;

	//notification
	if (CheatManager != None)
		CheatManager.ReportCheat("KillAll");
	for (C = Level.ControllerList; C != None; C = C.NextController)
		if (PlayerController(C) != None)
			PlayerController(C).ClientMessage("Killed all "$string(aClass));

	if ( ClassIsChildOf(aClass, class'AIController') )
	{
		Level.Game.KillBots(Level.Game.NumBots);
		return;
	}
	if ( ClassIsChildOf(aClass, class'Pawn') )
	{
		KillAllPawns(class<Pawn>(aClass));
		return;
	}
	ForEach DynamicActors(class 'Actor', A)
		if ( ClassIsChildOf(A.class, aClass) )
			A.Destroy();
}

// Kill non-player pawns and their controllers
function KillAllPawns(class<Pawn> aClass)
{
	local Pawn P;

	Level.Game.KillBots(Level.Game.NumBots);
	ForEach DynamicActors(class'Pawn', P)
		if ( ClassIsChildOf(P.Class, aClass)
			&& !P.IsPlayerPawn() )
		{
			if ( P.Controller != None )
				P.Controller.Destroy();
			P.Destroy();
		}
}

exec function ToggleScreenShotMode()
{
	if ( myHUD.bCrosshairShow )
	{
		myHUD.bCrosshairShow = false;
		SetWeaponHand("Hidden");
		myHUD.bHideHUD = true;
		TeamBeaconMaxDist = 0;
		bHideVehicleNoEntryIndicator = true;
	}
	else
	{
		// return to normal
		myHUD.bCrosshairShow = true;
		SetWeaponHand("Right");
		myHUD.bHideHUD = false;
		TeamBeaconMaxDist = default.TeamBeaconMaxDist;
		bHideVehicleNoEntryIndicator = false;
	}
}

exec function SetSpectateSpeed(Float F)
{
	SpectateSpeed = F;
	ServerSpectateSpeed(F);
}

function ClientSetWeaponViewShake(Bool B)
{
	bWeaponViewShake = B;
}

function ClientSetClassicView()
{
	Level.bClassicView = true;
}

function ServerSpectateSpeed(Float F)
{
	SpectateSpeed = F;
}

function ServerGivePawn()
{
	GivePawn(Pawn);
}

function ClientCapBandwidth(int Cap)
{
	ClientCap = Cap;
	if ( (Player != None) && (Player.CurrentNetSpeed > Cap) )
		SetNetSpeed(Cap);
}

function PendingStasis()
{
    bStasis = true;
    Pawn = None;
    GotoState('Scripting');
}

function AddCheats()
{
	// Assuming that this never gets called for NM_Client
	if ( CheatManager == None && (Level.NetMode == NM_Standalone) )
		CheatManager = new(self) CheatClass;
}

function MakeAdmin()
{
	if ( AdminManager == None && Level != None && Level.Game != None && Level.Game.AccessControl != None)
	{
		if (Level.Game.AccessControl.AdminClass == None)
			Log("AdminClass is None");
		else
			AdminManager = new(self) Level.Game.AccessControl.AdminClass;
	}
}

function HandlePickup(Pickup pick)
{
	ReceiveLocalizedMessage(pick.MessageClass,,,,pick.class);
}

event ClientSetViewTarget( Actor a )
{
	local bool bNewViewTarget;

	if ( A == None )
	{
		if ( ViewTarget != self )
			SetLocation(CalcViewLocation);
		ServerVerifyViewTarget();
	}
	else
	{
		bNewViewTarget = (ViewTarget != a);
		SetViewTarget( a );
		if (bNewViewTarget)
			a.POVChanged(self, false);
	}
}

function ServerVerifyViewTarget()
{
	if ( ViewTarget == self )
		return;
	if ( ViewTarget == None )
		return;
	ClientSetViewTarget(ViewTarget);
}

/* SpawnDefaultHUD()
Spawn a HUD (make sure that PlayerController always has valid HUD, even if \
ClientSetHUD() hasn't been called\
*/
function SpawnDefaultHUD()
{
    myHUD = spawn(class'HUD',self);
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	local vehicle DrivenVehicle;

    DrivenVehicle = Vehicle(Pawn);
	if( DrivenVehicle != None )
		DrivenVehicle.KDriverLeave(true); // Force the driver out of the car

	if ( Pawn != None )
		PawnDied( Pawn );
    super.Reset();
    SetViewTarget( Self );
    ClientSetViewTarget( self );
	ClientSetFixedCamera( false );
    bBehindView = false;
    WaitDelay	= Level.TimeSeconds + 2;
    FixFOV();
    if ( PlayerReplicationInfo.bOnlySpectator )
    	GotoState('Spectating');
    else
	GotoState('PlayerWaiting');
}

event ClientReset()
{
	bBehindView		= false;
	bFixedCamera	= false;
	SetViewTarget( Self );

    if ( PlayerReplicationInfo.bOnlySpectator )
    	GotoState('Spectating');
    else
	GotoState('PlayerWaiting');
}

function CleanOutSavedMoves()
{
    local SavedMove Next;

	// clean out saved moves
	while ( SavedMoves != None )
	{
		Next = SavedMoves.NextMove;
		SavedMoves.Destroy();
		SavedMoves = Next;
	}
	if ( PendingMove != None )
	{
		PendingMove.Destroy();
		PendingMove = None;
	}
}

/* InitInputSystem()
Spawn the appropriate class of PlayerInput
Only called for playercontrollers that belong to local players
*/
event InitInputSystem()
{
	PlayerInput = new(self) InputClass;
}

/* ClientGotoState()
server uses this to force client into NewState
*/
function ClientGotoState(name NewState, name NewLabel)
{
    GotoState(NewState,NewLabel);
}

function AskForPawn()
{
	if ( IsInState('GameEnded') )
		ClientGotoState('GameEnded', 'Begin');
	else if ( IsInState('RoundEnded') )
		ClientGotoState('RoundEnded', 'Begin');
	else if (IsInState('Spectating'))
		ClientGotoState('Spectating', 'Begin');
	else if ( Pawn != None )
		GivePawn(Pawn);
	else
	{
		bFrozen = false;
		ServerRestartPlayer();
	}
}

function GivePawn(Pawn NewPawn)
{
    if ( NewPawn == None )
        return;
    Pawn = NewPawn;
    NewPawn.Controller = self;
    ClientRestart(Pawn);
}

/* GetFacingDirection()
returns direction faced relative to movement dir
0 = forward
16384 = right
32768 = back
49152 = left
*/
function int GetFacingDirection()
{
    local vector X,Y,Z, Dir;

    GetAxes(Pawn.Rotation, X,Y,Z);
    Dir = Normal(Pawn.Acceleration);
    if ( Y Dot Dir > 0 )
        return ( 49152 + 16384 * (X Dot Dir) );
    else
        return ( 16384 - 16384 * (X Dot Dir) );
}

// Possess a pawn
function Possess(Pawn aPawn)
{
    if ( PlayerReplicationInfo.bOnlySpectator )
        return;

	TargetEyeHeight = aPawn.BaseEyeheight;
	ResetFOV();
    aPawn.PossessedBy(self);
    Pawn = aPawn;
    Pawn.bStasis = false;
	ResetTimeMargin();
    CleanOutSavedMoves();  // don't replay moves previous to possession
	if ( Vehicle(Pawn) != None && Vehicle(Pawn).Driver != None )
		PlayerReplicationInfo.bIsFemale = Vehicle(Pawn).Driver.bIsFemale;
	else
    PlayerReplicationInfo.bIsFemale = Pawn.bIsFemale;
    ServerSetHandedness(Handedness);
    ServerSetAutoTaunt(bAutoTaunt);
    Restart();
}

function AcknowledgePossession(Pawn P)
{
	if ( Viewport(Player) != None )
	{
		AcknowledgedPawn = P;
		if ( P != None )
			P.SetBaseEyeHeight();
		ServerAcknowledgePossession(P, Handedness, bAutoTaunt);
	}
}


function ServerAcknowledgePossession(Pawn P, float NewHand, bool bNewAutoTaunt)
{
	ResetTimeMargin();
    AcknowledgedPawn = P;
    ServerSetHandedness(NewHand);
    ServerSetAutoTaunt(bNewAutoTaunt);
}

// unpossessed a pawn (not because pawn was killed)
function UnPossess()
{
    if ( Pawn != None )
    {
        SetLocation(Pawn.Location);
        Pawn.RemoteRole = ROLE_SimulatedProxy;
        Pawn.UnPossessed();
		CleanOutSavedMoves();  // don't replay moves previous to unpossession
        if ( Viewtarget == Pawn )
            SetViewTarget(self);
    }
    Pawn = None;
    GotoState('Spectating');
}

function ViewNextBot()
{
	if ( CheatManager != None )
		CheatManager.ViewBot();
}

// unpossessed a pawn (because pawn was killed)
function PawnDied(Pawn P)
{
	if ( P != Pawn )
		return;
    EndZoom();
    if ( Pawn != None )
        Pawn.RemoteRole = ROLE_SimulatedProxy;
    if ( ViewTarget == Pawn )
        bBehindView = true;

    Super.PawnDied(P);
}

simulated function ClientUpdateFlagHolder(PlayerReplicationInfo PRI, int i)
{
	if ( (Role == ROLE_Authority) || (GameReplicationInfo == None) )
		return;
	GameReplicationInfo.FlagHolder[i] = PRI;
}

simulated function ClientSetHUD(class<HUD> newHUDClass, class<Scoreboard> newScoringClass )
{
    if ( myHUD != None )
        myHUD.Destroy();

    if (newHUDClass == None)
        myHUD = None;
    else
    {
        myHUD = spawn (newHUDClass, self);

        if (myHUD == None)
            log ("PlayerController::ClientSetHUD(): Could not spawn a HUD of class "$newHUDClass, 'Error');
        else
            myHUD.SetScoreBoardClass( newScoringClass );
    }

    if( Level.Song != "" && Level.Song != "None" )
		ClientSetInitialMusic( Level.Song, MTRAN_Fade );
}

// jdf ---
// Server ignores this call, client plays effect
simulated function ClientPlayForceFeedback( String EffectName )
{
    if (bForceFeedbackSupported && Viewport(Player) != None)
        PlayFeedbackEffect( EffectName );
}

simulated function StopForceFeedback( optional String EffectName )
{
    if (bForceFeedbackSupported && Viewport(Player) != None)
		StopFeedbackEffect( EffectName );
}

function ClientStopForceFeedback( optional String EffectName )
{
    if (bForceFeedbackSupported && Viewport(Player) != None)
		StopFeedbackEffect( EffectName );
}
// --- jdf

final function float UpdateFlashComponent(float current, float Step, float goal)
{
	if ( goal > current )
		return FMin(current + Step, goal);
	else
		return FMax(current - Step, goal);
}

function ViewFlash(float DeltaTime)
{
    local vector goalFog;
    local float goalscale, delta, Step;
    local PhysicsVolume ViewVolume;

    delta = FMin(0.1, DeltaTime);
    goalScale = 1; // + ConstantGlowScale;
    goalFog = vect(0,0,0); // ConstantGlowFog;

    if ( Pawn != None )
    {
		if ( bBehindView )
			ViewVolume = Level.GetPhysicsVolume(CalcViewLocation);
		else
			ViewVolume = Pawn.HeadVolume;

		goalScale += ViewVolume.ViewFlash.X;
		goalFog += ViewVolume.ViewFog;
    }
	Step = 0.6 * delta * ScreenFlashScaling;
	FlashScale.X = UpdateFlashComponent(FlashScale.X,step,goalScale);
    FlashScale = FlashScale.X * vect(1,1,1);

	FlashFog.X = UpdateFlashComponent(FlashFog.X,step,goalFog.X);
	FlashFog.Y = UpdateFlashComponent(FlashFog.Y,step,goalFog.Y);
	FlashFog.Z = UpdateFlashComponent(FlashFog.Z,step,goalFog.Z);
}

simulated event ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	// Wait for player to be up to date with replication when joining a server, before stacking up messages
	if ( Level.NetMode == NM_DedicatedServer || GameReplicationInfo == None )
		return;

    Message.Static.ClientReceive( Self, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
	if ( Message.static.IsConsoleMessage(Switch) && (Player != None) && (Player.Console != None) )
		Player.Console.Message(Message.Static.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject),0 );
}

simulated event ChatRoomMessage( byte Result, int ChannelIndex, optional PlayerReplicationInfo RelatedPRI )
{
	local VoiceChatRoom VCR;
	local string str;

	if ( VoiceReplicationInfo != None && ChatRoomMessageClass != None )
	{
		VCR = VoiceReplicationInfo.GetChannelAt(ChannelIndex);
		if ( VCR != None )
			str = VCR.GetTitle();

		if ( (str ~= "Team") || (str ~= "Public") || (str ~= "Local") )
			return;
		ClientMessage( ChatRoomMessageClass.static.AssembleMessage(Result, str, RelatedPRI) );
	}
}

event ClientMessage( coerce string S, optional Name Type )
{
	// Wait for player to be up to date with replication when joining a server, before stacking up messages
	if ( Level.NetMode == NM_DedicatedServer || GameReplicationInfo == None )
		return;

    if (Type == '')
        Type = 'Event';

	TeamMessage(PlayerReplicationInfo, S, Type);
}

function bool AllowTextToSpeech(PlayerReplicationInfo PRI, name Type)
{
	if ( bNoTextToSpeechVoiceMessages || (PRI == None) )
		return false;

    if ( Type == 'Say' )
	{
		if ( PRI.bAdmin || ((GameReplicationInfo != None) && !GameReplicationInfo.bTeamGame) || (PRI == PlayerReplicationInfo) )
			return true;
		if ( IsInState('GameEnded') || IsInState('RoundEnded') )
			return true;
		return !bOnlySpeakTeamText;
	}
    else if ( Type == 'TeamSay' )
		return true;
	return false;
}

event TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type  )
{
	local string c;

	// Wait for player to be up to date with replication when joining a server, before stacking up messages
	if ( Level.NetMode == NM_DedicatedServer || GameReplicationInfo == None )
		return;

	if( AllowTextToSpeech(PRI, Type) )
		TextToSpeech( S, TextToSpeechVoiceVolume );
	if ( Type == 'TeamSayQuiet' )
		Type = 'TeamSay';

	if ( myHUD != None )
		myHUD.Message( PRI, c$S, Type );

	if ( (Player != None) && (Player.Console != None) )
	{
		if ( PRI!=None )
		{
			if ( PRI.Team!=None && GameReplicationInfo.bTeamGame)
			{
    			if (PRI.Team.TeamIndex==0)
					c = chr(27)$chr(200)$chr(1)$chr(1);
    			else if (PRI.Team.TeamIndex==1)
        			c = chr(27)$chr(125)$chr(200)$chr(253);
			}
			S = PRI.PlayerName$": "$S;
		}
		Player.Console.Chat( c$s, 6.0, PRI );
	}
}

simulated function PlayBeepSound();

simulated function PrecacheAnnouncements()
{
	if ( RewardAnnouncer != None )
		RewardAnnouncer.PrecacheAnnouncements(true);
	if ( StatusAnnouncer != None )
		StatusAnnouncer.PrecacheAnnouncements(false);
}

simulated function PlayStatusAnnouncement(name AName, byte AnnouncementLevel, optional bool bForce)
{
	local float Atten;
	local sound ASound;

	// Wait for player to be up to date with replication when joining a server, before stacking up messages
	if ( Level.NetMode == NM_DedicatedServer || GameReplicationInfo == None )
		return;

	if ( (AnnouncementLevel > AnnouncerLevel) || (StatusAnnouncer == None) )
		return;
	if ( !bForce && (Level.TimeSeconds - LastPlaySound < 1) )
		return;
    LastPlaySound = Level.TimeSeconds;  // so voice messages won't overlap
	LastPlaySpeech = Level.TimeSeconds;	// don't want chatter to overlap announcements

	Atten = 2.0 * FClamp(0.1 + float(AnnouncerVolume)*0.225,0.2,1.0);
	ASound = StatusAnnouncer.GetSound(AName);
	if ( ASound != None )
		ClientPlaySound(ASound,true,Atten,SLOT_Talk);
}

simulated function PlayRewardAnnouncement(name AName, byte AnnouncementLevel, optional bool bForce)
{
	local float Atten;
	local sound ASound;

	// Wait for player to be up to date with replication when joining a server, before stacking up messages
	if ( Level.NetMode == NM_DedicatedServer || GameReplicationInfo == None )
		return;

	if ( (AnnouncementLevel > AnnouncerLevel) || (RewardAnnouncer == None) )
		return;
	if ( !bForce && (Level.TimeSeconds - LastPlaySound < 1) )
		return;
    LastPlaySound = Level.TimeSeconds;  // so voice messages won't overlap
	LastPlaySpeech = Level.TimeSeconds;	// don't want chatter to overlap announcements

	Atten = 2.0 * FClamp(0.1 + float(AnnouncerVolume)*0.225,0.2,1.0);
	ASound = RewardAnnouncer.GetSound(AName);
	if ( ASound != None )
		ClientPlaySound(ASound,true,Atten,SLOT_Talk);
}

// PlayAnnouncement is OBSOLETE
simulated function PlayAnnouncement(sound ASound, byte AnnouncementLevel, optional bool bForce)
{
	local float Atten;

	if ( AnnouncementLevel > AnnouncerLevel )
		return;
	if ( !bForce && (Level.TimeSeconds - LastPlaySound < 1) )
		return;
    LastPlaySound = Level.TimeSeconds;  // so voice messages won't overlap
	LastPlaySpeech = Level.TimeSeconds;	// don't want chatter to overlap announcements

	Atten = 2.0 * FClamp(0.1 + float(AnnouncerVolume)*0.225,0.2,1.0);
	ClientPlaySound(ASound,true,Atten,SLOT_Talk);
}

// CustomizeAnnouncer is obsolete
function Sound CustomizeAnnouncer(Sound AnnouncementSound)
{
	return AnnouncementSound;
}

simulated function QueueAnnouncement( name ASoundName, byte AnnouncementLevel,
									 optional AnnouncerQueueManager.EAPriority Priority, optional byte Switch )
{
	if ( AnnouncementLevel > AnnouncerLevel || Level.NetMode == NM_DedicatedServer || GameReplicationInfo == None )
		return;

	if ( AnnouncerQueueManager == None )
	{
		AnnouncerQueueManager = Spawn(class'AnnouncerQueueManager');
		AnnouncerQueueManager.InitFor( Self );
	}

	if ( AnnouncerQueueManager != None )
		AnnouncerQueueManager.AddItemToQueue( ASoundName, Priority, Switch );
}

function bool AllowVoiceMessage(name MessageType)
{
	if ( Level.NetMode == NM_Standalone )
		return true;

	if ( Level.TimeSeconds - OldMessageTime < 3 )
	{
		if ( (MessageType == 'TAUNT') || (MessageType == 'AUTOTAUNT') )
			return false;
		if ( Level.TimeSeconds - OldMessageTime < 1 )
			return false;
	}
	if ( Level.TimeSeconds - OldMessageTime < 6 )
		OldMessageTime = Level.TimeSeconds + 3;
	else
		OldMessageTime = Level.TimeSeconds;
	return true;
}

//Play a sound client side (so only client will hear it
simulated function ClientPlaySound(sound ASound, optional bool bVolumeControl, optional float inAtten, optional ESoundSlot slot )
{
    local float atten;

    atten = 1.0;
    if( bVolumeControl )
        atten = FClamp(inAtten,0,2);

	if ( ViewTarget != None )
		ViewTarget.PlaySound(ASound, slot, atten,,,,false);
}

simulated function ClientReliablePlaySound(sound ASound, optional bool bVolumeControl )
{
    ClientPlaySound(ASound, bVolumeControl);
}

simulated event Destroyed()
{
    local SavedMove Next;
    local Vehicle DrivenVehicle;
	local Pawn Driver;

	// cheatmanager, adminmanager, and playerinput cleaned up in C++ PostScriptDestroyed()

	if ( AdminManager != None )
		AdminManager.DoLogout();

    StopFeedbackEffect();

    if ( Pawn != None )
    {
		// If its a vehicle, just destroy the driver, otherwise do the normal.
        DrivenVehicle = Vehicle(Pawn);
		if( DrivenVehicle != None )
		{
			Driver = DrivenVehicle.Driver;
			DrivenVehicle.KDriverLeave(true); // Force the driver out of the car
			if ( Driver != None )
			{
				Driver.Health = 0;
				Driver.Died( self, class'Suicided', Driver.Location );
			}
		}
		else
		{
			Pawn.Health = 0;
			Pawn.Died( self, class'Suicided', Pawn.Location );
        }
    }
    if ( myHUD != None )
		myHud.Destroy();
	if ( AnnouncerQueueManager != None )
		AnnouncerQueueManager.Destroy();

    while ( FreeMoves != None )
    {
        Next = FreeMoves.NextMove;
        FreeMoves.Destroy();
        FreeMoves = Next;
    }
    while ( SavedMoves != None )
    {
        Next = SavedMoves.NextMove;
        SavedMoves.Destroy();
        SavedMoves = Next;
    }

    if( PlayerSecurity != None )
    {
        PlayerSecurity.Destroy();
        PlayerSecurity = None;
    }

	if ( ChatManager != None )
		ChatManager.Destroy();

    super.Destroyed();
}

function ClientSetMusic( string NewSong, EMusicTransition NewTransition )
{
	local float FadeIn, FadeOut;

	switch (NewTransition)
	{
	case MTRAN_Segue:
		FadeIn = 7.0;
		FadeOut = 3.0;
		break;

	case MTRAN_Fade:
		FadeIn = 3.0;
		FadeOut = 3.0;
		break;

	case MTRAN_FastFade:
		FadeIn = 1.0;
		FadeOut = 1.0;
		break;

	case MTRAN_SlowFade:
		FadeIn = 5.0;
		FadeOut = 5.0;
		break;
	}

    StopAllMusic( FadeOut );

    if ( NewSong != "" )
	    PlayMusic( NewSong, FadeIn );

    Song        = NewSong;
    Transition  = NewTransition;
    if (Player!=None && Player.Console!=None)
    	Player.Console.SetMusic(NewSong);
}

function ClientSetInitialMusic( string NewSong, EMusicTransition NewTransition )
{
	local string SongName;

	if ( Song != "" )
		return;

    SongName = NewSong;
    if (Player!=None && Player.Console!=None)
    	SongName = Player.Console.SetInitialMusic(NewSong);

    ClientSetMusic(SongName,NewTransition);
}

// ------------------------------------------------------------------------
// Zooming/FOV change functions

function ToggleZoomWithMax(float MaxZoomLevel)
{
    if ( DefaultFOV != DesiredFOV )
        EndZoom();
    else
		StartZoomWithMax(MaxZoomLevel);
}

function StartZoomWithMax(float MaxZoomLevel)
{
	DesiredZoomLevel = MaxZoomLevel;
	myHUD.FadeZoom();
    ZoomLevel = 0.0;
    bZooming = true;
}

function ToggleZoom()
{
	ToggleZoomWithMax(0.9);
}

function StartZoom()
{
	StartZoomWithMax(0.9);
}

function StopZoom()
{
    bZooming = false;
}

function EndZoom()
{
	if ( DesiredFOV != DefaultFOV )
		myHUD.FadeZoom();
    bZooming = false;
    DesiredFOV = DefaultFOV;
}

simulated function FixFOV()
{
	FOVAngle = Default.DefaultFOV;
    DesiredFOV = Default.DefaultFOV;
    DefaultFOV = Default.DefaultFOV;
}

function SetFOV(float NewFOV)
{
    DesiredFOV = NewFOV;
    FOVAngle = NewFOV;
}

function ResetFOV()
{
    DesiredFOV = DefaultFOV;
	FOVAngle = DefaultFOV;
}

exec function FOV(float F)
{
    if( (F >= 80.0) || (Level.Netmode==NM_Standalone) || PlayerReplicationInfo.bOnlySpectator )
    {
        DefaultFOV = FClamp(F, 1, 170);
        DesiredFOV = DefaultFOV;
        SaveConfig();
    }
}

exec function Mutate(string MutateString)
{
	ServerMutate(MutateString);
}

function ServerMutate(string MutateString)
{
	if( Level.NetMode == NM_Client )
		return;
	Level.Game.BaseMutator.Mutate(MutateString, Self);
}

exec function SetSensitivity(float F)
{
    PlayerInput.UpdateSensitivity(F);
}

exec function SetMouseSmoothing( int Mode )
{
    PlayerInput.UpdateSmoothing( Mode );
}

exec function SetMouseAccel(float F)
{
	PlayerInput.UpdateAccel(F);
}

exec function ForceReload()
{
    if ( (Pawn != None) && (Pawn.Weapon != None) )
    {
        //Pawn.Weapon.ForceReload(); //merge_hack
    }
}

// ------------------------------------------------------------------------
// Messaging functions

function bool AllowTextMessage(string Msg)
{
	local int i;

	if ( (Level.NetMode == NM_Standalone) || PlayerReplicationInfo.bAdmin )
		return true;
	if ( ( Level.Pauser == none) && (Level.TimeSeconds - LastBroadcastTime < 2 ) )
		return false;

	// lower frequency if same text
	if ( Level.TimeSeconds - LastBroadcastTime < 5 )
	{
		Msg = Left(Msg,Clamp(len(Msg) - 4, 8, 64));
		for ( i=0; i<4; i++ )
			if ( LastBroadcastString[i] ~= Msg )
				return false;
	}
	for ( i=3; i>0; i-- )
		LastBroadcastString[i] = LastBroadcastString[i-1];

	LastBroadcastTime = Level.TimeSeconds;
	return true;
}

// Send a message to all players.
exec function Say( string Msg )
{
	Msg = Left(Msg,128);

	if ( AllowTextMessage(Msg) )
		ServerSay(Msg);
}

function ServerSay( string Msg )
{
	local controller C;

	Msg = Level.Game.StripColor(Msg);

	// center print admin messages which start with #
	if (PlayerReplicationInfo.bAdmin && left(Msg,1) == "#" )
	{
		Msg = right(Msg,len(Msg)-1);
		for( C=Level.ControllerList; C!=None; C=C.nextController )
			if( C.IsA('PlayerController') )
			{
				PlayerController(C).ClearProgressMessages();
				PlayerController(C).SetProgressTime(6);
				PlayerController(C).SetProgressMessage(0, Msg, class'Canvas'.Static.MakeColor(255,255,255));
			}
		return;
	}

	Level.Game.Broadcast(self, Msg, 'Say');
}

exec function TeamSay( string Msg )
{
	Msg = Left(Msg,128);
	if ( AllowTextMessage(Msg) )
		ServerTeamSay(Msg);
}

function ServerTeamSay( string Msg )
{
	LastActiveTime = Level.TimeSeconds;

	Msg = Level.Game.StripColor(Msg);

	if( !GameReplicationInfo.bTeamGame )
	{
		Say( Msg );
		return;
	}

    Level.Game.BroadcastTeam( self, Level.Game.ParseMessageString( Level.Game.BaseMutator , self, Msg ) , 'TeamSay');
}

// ------------------------------------------------------------------------

function ServerSetAutoTaunt(bool Value)
{
	bAutoTaunt = Value;
}

exec function SetAutoTaunt(bool Value)
{
	class'PlayerController'.default.bAutoTaunt = Value;
	class'PlayerController'.static.StaticSaveConfig();
	bAutoTaunt = Value;

	ServerSetAutoTaunt(Value);
}

// ------------------------------------------------------------------------

function ServerSetHandedness( float hand)
{
    Handedness = hand;
    if ( (Pawn != None) && (Pawn.Weapon != None) )
        Pawn.Weapon.SetHand(Handedness);
}

function SetHand(int IntValue)
{
    Handedness = IntValue;
    SaveConfig();
    if( (Pawn != None) && (Pawn.Weapon != None) )
        Pawn.Weapon.SetHand(Handedness);

    ServerSetHandedness(Handedness);
}

exec function SetWeaponHand ( string S )
{
    if ( S ~= "Left" )
        Handedness = -1;
    else if ( S~= "Right" )
        Handedness = 1;
    else if ( S ~= "Center" )
        Handedness = 0;
    else if ( S ~= "Hidden" )
        Handedness = 2;
    SetHand(Handedness);
}

function bool IsDead()
{
	return false;
}

exec function ShowGun ()
{
    if( Handedness == 2 )
        Handedness = 1;
    else
        Handedness = 2;

    SetHand(Handedness);
}

event PreClientTravel()
{
    log("PreClientTravel");
    ClientStopForceFeedback();  // jdf
}

function ClientSetFixedCamera(bool B)
{
    bFixedCamera = B;
}

function ClientSetBehindView(bool B)
{
    local bool bWasBehindView;

    bWasBehindView = bBehindView;
    bBehindView = B;
    CameraDist = Default.CameraDist;
    if (bBehindView != bWasBehindView)
	    ViewTarget.POVChanged(self, true);

    if (Vehicle(Pawn) != None)
    {
    	Vehicle(Pawn).bDesiredBehindView = B;
    	Pawn.SaveConfig();
    }
}

function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID)
{
    local VoicePack V;

    if ( (Sender == None) || (Sender.voicetype == None) || (Player.Console == None) )
        return;

    V = Spawn(Sender.voicetype, self);
    if ( V != None )
        V.ClientInitialize(Sender, Recipient, messagetype, messageID);
}

/* ForceDeathUpdate()
Make sure ClientAdjustPosition immediately informs client of pawn's death
*/
function ForceDeathUpdate()
{
    LastUpdateTime = Level.TimeSeconds - 10;
}

/* RocketServerMove()
compressed version of server move for PlayerRocketing state
*/
function RocketServerMove
(
	float	TimeStamp,
	vector	InAccel,
	vector	ClientLoc,
	bool	NewbDuck,
	byte	ClientRoll,
	int		View
)
{
	ServerMove(TimeStamp,InAccel,ClientLoc,false,NewbDuck,false,false, DCLICK_NONE,ClientRoll,View);
}

/* DualRocketServerMove()
compressed version of server move for PlayerRocketing state
*/
function DualRocketServerMove
(
	float	TimeStamp0,
	vector	InAccel0,
	bool	NewbDuck0,
	byte	ClientRoll0,
	int		View0,
	float	TimeStamp,
	vector	InAccel,
	vector	ClientLoc,
	bool	NewbDuck,
	byte	ClientRoll,
	int		View
)
{
	ServerMove(TimeStamp0,InAccel0,vect(0,0,0),false,NewbDuck0,false,false, DCLICK_NONE,ClientRoll0,View0);
	ServerMove(TimeStamp,InAccel,ClientLoc,false,NewbDuck,false,false, DCLICK_NONE,ClientRoll,View);
}

function SpaceFighterServerMove
(
	float	TimeStamp,
	vector	InAccel,
	vector	ClientLoc,
	bool	NewbDuck,
	int     ViewPitch,
	int		ViewYaw,
	int		ViewRoll
)
{
	local	Rotator		BackupView;

	BackupView.Pitch	= ViewPitch;
	BackupView.Yaw		= ViewYaw;
	BackupView.Roll		= ViewRoll;
	SetRotation( BackupView );
	if ( Pawn != None )
		Pawn.SetRotation( BackupView );

	Global.ServerMove(TimeStamp,InAccel,ClientLoc,false,NewbDuck,false,false, DCLICK_NONE,0,0);
}

function DualSpaceFighterServerMove
(
	float	TimeStamp0,
	vector	InAccel0,
	bool	NewbDuck0,
	int     ViewPitch0,
	int		ViewYaw0,
	int		ViewRoll0,
	float	TimeStamp,
	vector	InAccel,
	vector	ClientLoc,
	bool	NewbDuck,
	int     ViewPitch,
	int		ViewYaw,
	int		ViewRoll
)
{
	local	Rotator		BackupView;

	BackupView.Pitch	= ViewPitch0;
	BackupView.Yaw		= ViewYaw0;
	BackupView.Roll		= ViewRoll0;
	SetRotation( BackupView );
	if ( Pawn != None )
		Pawn.SetRotation( BackupView );

	Global.ServerMove(TimeStamp0,InAccel0,vect(0,0,0),false,NewbDuck0,false,false, DCLICK_NONE,0,0);

	BackupView.Pitch	= ViewPitch;
	BackupView.Yaw		= ViewYaw;
	BackupView.Roll		= ViewRoll;
	SetRotation( BackupView );
	if ( Pawn != None )
		Pawn.SetRotation( BackupView );

	Global.ServerMove(TimeStamp,InAccel,ClientLoc,false,NewbDuck,false,false, DCLICK_NONE,0,0);
}

/* TurretServerMove()
compressed version of server move for PlayerTurreting state
*/
function TurretServerMove
(
	float	TimeStamp,
	vector	ClientLoc,
	bool	NewbDuck,
	byte	ClientRoll,
	int		View
)
{
	ServerMove(TimeStamp,Vect(0,0,0),ClientLoc,false,NewbDuck,false,false, DCLICK_NONE,ClientRoll,View);
}

/* DualTurretServerMove()
compressed version of server move for PlayerTurreting state
*/
function DualTurretServerMove
(
	float	TimeStamp0,
	bool	NewbDuck0,
	byte	ClientRoll0,
	int		View0,
	float	TimeStamp,
	vector	ClientLoc,
	bool	NewbDuck,
	byte	ClientRoll,
	int		View
)
{
	ServerMove(TimeStamp0,Vect(0,0,0),vect(0,0,0),false,NewbDuck0,false,false, DCLICK_NONE,ClientRoll0,View0);
	ServerMove(TimeStamp,Vect(0,0,0),ClientLoc,false,NewbDuck,false,false, DCLICK_NONE,ClientRoll,View);
}

/* ShortServerMove()
compressed version of server move for bandwidth saving
*/
function ShortServerMove
(
    float TimeStamp,
    vector ClientLoc,
    bool NewbRun,
    bool NewbDuck,
    bool NewbJumpStatus,
    byte ClientRoll,
    int View
)
{
    ServerMove(TimeStamp,vect(0,0,0),ClientLoc,NewbRun,NewbDuck,NewbJumpStatus,false,DCLICK_None,ClientRoll,View);
}

/* DualServerMove()
- replicated function sent by client to server - contains client movement and firing info for two moves
*/
function DualServerMove
(
	float TimeStamp0,
	vector InAccel0,
	byte PendingCompress,
	eDoubleClickDir DoubleClickMove0,
	int View0,
    float TimeStamp,
    vector InAccel,
    vector ClientLoc,
    eDoubleClickDir DoubleClickMove,
    byte ClientRoll,
    int View,
    optional byte OldTimeDelta,
    optional int OldAccel
)
{
	local bool NewbRun0,NewbDuck0,NewbJumpStatus0,NewbDoubleJump0,
				NewbRun,NewbDuck,NewbJumpStatus,NewbDoubleJump;

	NewbRun0 = (PendingCompress & 1) != 0;
	NewbDuck0 = (PendingCompress & 2) != 0;
	NewbJumpStatus0 = (PendingCompress & 4) != 0;
	NewbDoubleJump0 = (PendingCompress & 8) != 0;
	NewbRun = (PendingCompress & 16) != 0;
	NewbDuck = (PendingCompress & 32) != 0;
	NewbJumpStatus = (PendingCompress & 64) != 0;
	NewbDoubleJump = (PendingCompress & 128) != 0;

    ServerMove(TimeStamp0,InAccel0,vect(0,0,0),NewbRun0,NewbDuck0,NewbJumpStatus0,NewbDoubleJump0,DoubleClickMove0,
			ClientRoll,View0);
	if ( ClientLoc == vect(0,0,0) )
		ClientLoc = vect(0.1,0,0);
    ServerMove(TimeStamp,InAccel,ClientLoc,NewbRun,NewbDuck,NewbJumpStatus,NewbDoubleJump,DoubleClickMove,ClientRoll,View,OldTimeDelta,OldAccel);
}

/* ServerMove()
- replicated function sent by client to server - contains client movement and firing info.
*/
function ServerMove
(
    float TimeStamp,
    vector InAccel,
    vector ClientLoc,
    bool NewbRun,
    bool NewbDuck,
    bool NewbJumpStatus,
    bool NewbDoubleJump,
    eDoubleClickDir DoubleClickMove,
    byte ClientRoll,
    int View,
    optional byte OldTimeDelta,
    optional int OldAccel
)
{
    local float DeltaTime, clientErr, OldTimeStamp;
    local rotator DeltaRot, Rot, ViewRot;
    local vector Accel, LocDiff;
    local int maxPitch, ViewPitch, ViewYaw;
    local bool NewbPressedJump, OldbRun, OldbDoubleJump;
    local eDoubleClickDir OldDoubleClickMove;

    // If this move is outdated, discard it.
    if ( CurrentTimeStamp >= TimeStamp )
        return;

	if ( AcknowledgedPawn != Pawn )
	{
		OldTimeDelta = 0;
		InAccel = vect(0,0,0);
		GivePawn(Pawn);
	}

    // if OldTimeDelta corresponds to a lost packet, process it first
    if (  OldTimeDelta != 0 )
    {
        OldTimeStamp = TimeStamp - float(OldTimeDelta)/500 - 0.001;
        if ( CurrentTimeStamp < OldTimeStamp - 0.001 )
        {
            // split out components of lost move (approx)
            Accel.X = OldAccel >>> 23;
            if ( Accel.X > 127 )
                Accel.X = -1 * (Accel.X - 128);
            Accel.Y = (OldAccel >>> 15) & 255;
            if ( Accel.Y > 127 )
                Accel.Y = -1 * (Accel.Y - 128);
            Accel.Z = (OldAccel >>> 7) & 255;
            if ( Accel.Z > 127 )
                Accel.Z = -1 * (Accel.Z - 128);
            Accel *= 20;

            OldbRun = ( (OldAccel & 64) != 0 );
            OldbDoubleJump = ( (OldAccel & 32) != 0 );
            NewbPressedJump = ( (OldAccel & 16) != 0 );
            if ( NewbPressedJump )
                bJumpStatus = NewbJumpStatus;
            switch (OldAccel & 7)
            {
                case 0:
                    OldDoubleClickMove = DCLICK_None;
                    break;
                case 1:
                    OldDoubleClickMove = DCLICK_Left;
                    break;
                case 2:
                    OldDoubleClickMove = DCLICK_Right;
                    break;
                case 3:
                    OldDoubleClickMove = DCLICK_Forward;
                    break;
                case 4:
                    OldDoubleClickMove = DCLICK_Back;
                    break;
            }
            //log("Recovered move from "$OldTimeStamp$" acceleration "$Accel$" from "$OldAccel);
            OldTimeStamp = FMin(OldTimeStamp, CurrentTimeStamp + MaxResponseTime);
            MoveAutonomous(OldTimeStamp - CurrentTimeStamp, OldbRun, (bDuck == 1), NewbPressedJump, OldbDoubleJump, OldDoubleClickMove, Accel, rot(0,0,0));
			CurrentTimeStamp = OldTimeStamp;
        }
    }

    // View components
    ViewPitch = View/32768;
    ViewYaw = 2 * (View - 32768 * ViewPitch);
    ViewPitch *= 2;
    // Make acceleration.
    Accel = InAccel * 0.1;

    NewbPressedJump = (bJumpStatus != NewbJumpStatus);
    bJumpStatus = NewbJumpStatus;

    // Save move parameters.
    DeltaTime = FMin(MaxResponseTime,TimeStamp - CurrentTimeStamp);

	if ( Pawn == None )
	{
		ResetTimeMargin();
	}
	else if ( !CheckSpeedHack(DeltaTime) )
	{
		bWasSpeedHack = true;
		DeltaTime = 0;
		Pawn.Velocity = vect(0,0,0);
	}
	else if ( bWasSpeedHack )
	{
		// if have had a speedhack detection, then modify deltatime if getting too far ahead again
		if ( (TimeMargin > 0.5 * Level.MaxTimeMargin) && (Level.MaxTimeMargin > 0) )
			DeltaTime *= 0.8;
	}

    CurrentTimeStamp = TimeStamp;
    ServerTimeStamp = Level.TimeSeconds;
    ViewRot.Pitch = ViewPitch;
    ViewRot.Yaw = ViewYaw;
    ViewRot.Roll = 0;

    if ( NewbPressedJump || (InAccel != vect(0,0,0)) )
		LastActiveTime = Level.TimeSeconds;

	if ( Pawn == None || Pawn.bServerMoveSetPawnRot )
		SetRotation(ViewRot);

	if ( AcknowledgedPawn != Pawn )
		return;

    if ( (Pawn != None) && Pawn.bServerMoveSetPawnRot )
    {
        Rot.Roll = 256 * ClientRoll;
        Rot.Yaw = ViewYaw;
        if ( (Pawn.Physics == PHYS_Swimming) || (Pawn.Physics == PHYS_Flying) )
            maxPitch = 2;
        else
            maxPitch = 0;
        if ( (ViewPitch > maxPitch * RotationRate.Pitch) && (ViewPitch < 65536 - maxPitch * RotationRate.Pitch) )
        {
            If (ViewPitch < 32768)
                Rot.Pitch = maxPitch * RotationRate.Pitch;
            else
                Rot.Pitch = 65536 - maxPitch * RotationRate.Pitch;
        }
        else
            Rot.Pitch = ViewPitch;
        DeltaRot = (Rotation - Rot);
        Pawn.SetRotation(Rot);
    }

    // Perform actual movement
    if ( (Level.Pauser == None) && (DeltaTime > 0) )
        MoveAutonomous(DeltaTime, NewbRun, NewbDuck, NewbPressedJump, NewbDoubleJump, DoubleClickMove, Accel, DeltaRot);

    // Accumulate movement error.
    if ( ClientLoc == vect(0,0,0) )
		return;		// first part of double servermove
    else if ( Level.TimeSeconds - LastUpdateTime > 0.3 )
        ClientErr = 10000;
    else if ( Level.TimeSeconds - LastUpdateTime > 180.0/Player.CurrentNetSpeed )
    {
        if ( Pawn == None )
            LocDiff = Location - ClientLoc;
        else
            LocDiff = Pawn.Location - ClientLoc;
        ClientErr = LocDiff Dot LocDiff;
    }

    // If client has accumulated a noticeable positional error, correct him.
    if ( ClientErr > 3 )
    {
        if ( Pawn == None )
        {
            PendingAdjustment.newPhysics = Physics;
            PendingAdjustment.NewLoc = Location;
            PendingAdjustment.NewVel = Velocity;
        }
        else
        {
            PendingAdjustment.newPhysics = Pawn.Physics;
            PendingAdjustment.NewVel = Pawn.Velocity;
            PendingAdjustment.NewBase = Pawn.Base;
            if ( (Mover(Pawn.Base) != None) || (Vehicle(Pawn.Base) != None) )
                PendingAdjustment.NewLoc = Pawn.Location - Pawn.Base.Location;
            else
                PendingAdjustment.NewLoc = Pawn.Location;
            PendingAdjustment.NewFloor = Pawn.Floor;
        }
    //if ( (ClientErr != 10000) && (Pawn != None) )
//		log(" Client Error at "$TimeStamp$" is "$ClientErr$" with acceleration "$Accel$" LocDiff "$LocDiff$" Physics "$Pawn.Physics);
        LastUpdateTime = Level.TimeSeconds;

		PendingAdjustment.TimeStamp = TimeStamp;
		PendingAdjustment.newState = GetStateName();
    }
	//log("Server moved stamp "$TimeStamp$" location "$Pawn.Location$" Acceleration "$Pawn.Acceleration$" Velocity "$Pawn.Velocity);
}

/* Called on server at end of tick when PendingAdjustment has been set.
Done this way to avoid ever sending more than one ClientAdjustment per server tick.
*/
event SendClientAdjustment()
{
	if ( AcknowledgedPawn != Pawn )
	{
		PendingAdjustment.TimeStamp = 0;
		return;
	}

    if ( (Pawn == None) || (Pawn.Physics != PHYS_Spider) )
    {
        if ( PendingAdjustment.NewVel == vect(0,0,0) )
        {
            ShortClientAdjustPosition
            (
                PendingAdjustment.TimeStamp,
                PendingAdjustment.newState,
                PendingAdjustment.newPhysics,
                PendingAdjustment.NewLoc.X,
                PendingAdjustment.NewLoc.Y,
                PendingAdjustment.NewLoc.Z,
                PendingAdjustment.NewBase
            );
        }
        else
            ClientAdjustPosition
            (
                PendingAdjustment.TimeStamp,
                PendingAdjustment.newState,
                PendingAdjustment.newPhysics,
                PendingAdjustment.NewLoc.X,
                PendingAdjustment.NewLoc.Y,
                PendingAdjustment.NewLoc.Z,
                PendingAdjustment.NewVel.X,
                PendingAdjustment.NewVel.Y,
                PendingAdjustment.NewVel.Z,
                PendingAdjustment.NewBase
            );
    }
    else
        LongClientAdjustPosition
        (
            PendingAdjustment.TimeStamp,
            PendingAdjustment.newState,
            PendingAdjustment.newPhysics,
            PendingAdjustment.NewLoc.X,
            PendingAdjustment.NewLoc.Y,
            PendingAdjustment.NewLoc.Z,
            PendingAdjustment.NewVel.X,
            PendingAdjustment.NewVel.Y,
            PendingAdjustment.NewVel.Z,
            PendingAdjustment.NewBase,
            PendingAdjustment.NewFloor.X,
            PendingAdjustment.NewFloor.Y,
            PendingAdjustment.NewFloor.Z
        );

	PendingAdjustment.TimeStamp = 0;
}

// Only executed on server
function ServerDrive(float InForward, float InStrafe, float aUp, bool InJump, int View)
{
    local rotator ViewRotation;

    // Added to handle setting of the correct ViewRotation on the server in network games --Dave@Psyonix
    ViewRotation.Pitch = View/32768;
    ViewRotation.Yaw = 2 * (View - 32768 * ViewRotation.Pitch);
    ViewRotation.Pitch *= 2;
    ViewRotation.Roll = 0;
    SetRotation(ViewRotation);

    ProcessDrive(InForward, InStrafe, aUp, InJump);
}

function ProcessDrive(float InForward, float InStrafe, float InUp, bool InJump)
{
	ClientGotoState(GetStateName(), 'Begin');
}

function ProcessMove ( float DeltaTime, vector newAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
{
    if ( (Pawn != None) && (Pawn.Acceleration != newAccel) )
        Pawn.Acceleration = newAccel;
}

final function MoveAutonomous
(
    float DeltaTime,
    bool NewbRun,
    bool NewbDuck,
    bool NewbPressedJump,
    bool NewbDoubleJump,
    eDoubleClickDir DoubleClickMove,
    vector newAccel,
    rotator DeltaRot
)
{
	if ( (Pawn != None) && Pawn.bHardAttach )
		return;

    if ( NewbRun )
        bRun = 1;
    else
        bRun = 0;

    if ( NewbDuck )
        bDuck = 1;
    else
        bDuck = 0;
    bPressedJump = NewbPressedJump;
    bDoubleJump = NewbDoubleJump;
    HandleWalking();
    ProcessMove(DeltaTime, newAccel, DoubleClickMove, DeltaRot);
    if ( Pawn != None )
        Pawn.AutonomousPhysics(DeltaTime);
    else
        AutonomousPhysics(DeltaTime);
    bDoubleJump = false;
    //log("Role "$Role$" moveauto time "$100 * DeltaTime$" ("$Level.TimeDilation$")");
}

/* VeryShortClientAdjustPosition
bandwidth saving version, when velocity is zeroed, and pawn is walking
*/
function VeryShortClientAdjustPosition
(
    float TimeStamp,
    float NewLocX,
    float NewLocY,
    float NewLocZ,
    Actor NewBase
)
{
    local vector Floor;

    if ( Pawn != None )
        Floor = Pawn.Floor;
    LongClientAdjustPosition(TimeStamp,'PlayerWalking',PHYS_Walking,NewLocX,NewLocY,NewLocZ,0,0,0,NewBase,Floor.X,Floor.Y,Floor.Z);
}

/* ShortClientAdjustPosition
bandwidth saving version, when velocity is zeroed
*/
function ShortClientAdjustPosition
(
    float TimeStamp,
    name newState,
    EPhysics newPhysics,
    float NewLocX,
    float NewLocY,
    float NewLocZ,
    Actor NewBase
)
{
    local vector Floor;

    if ( Pawn != None )
        Floor = Pawn.Floor;
    LongClientAdjustPosition(TimeStamp,newState,newPhysics,NewLocX,NewLocY,NewLocZ,0,0,0,NewBase,Floor.X,Floor.Y,Floor.Z);
}

/* ClientAdjustPosition
- pass newloc and newvel in components so they don't get rounded
*/
function ClientAdjustPosition
(
    float TimeStamp,
    name newState,
    EPhysics newPhysics,
    float NewLocX,
    float NewLocY,
    float NewLocZ,
    float NewVelX,
    float NewVelY,
    float NewVelZ,
    Actor NewBase
)
{
    local vector Floor;

    if ( Pawn != None )
        Floor = Pawn.Floor;
    LongClientAdjustPosition(TimeStamp,newState,newPhysics,NewLocX,NewLocY,NewLocZ,NewVelX,NewVelY,NewVelZ,NewBase,Floor.X,Floor.Y,Floor.Z);
}

/* LongClientAdjustPosition
long version, when care about pawn's floor normal
*/
function LongClientAdjustPosition
(
    float TimeStamp,
    name newState,
    EPhysics newPhysics,
    float NewLocX,
    float NewLocY,
    float NewLocZ,
    float NewVelX,
    float NewVelY,
    float NewVelZ,
    Actor NewBase,
    float NewFloorX,
    float NewFloorY,
    float NewFloorZ
)
{
    local vector NewLocation, NewVelocity, NewFloor;
    local Actor MoveActor;
    local SavedMove CurrentMove;
    local float NewPing;

	// update ping
	if ( (PlayerReplicationInfo != None) && !bDemoOwner )
	{
		NewPing = FMin(1.5, Level.TimeSeconds - TimeStamp);

		if ( ExactPing < 0.004 )
			ExactPing = FMin(0.3,NewPing);
		else
		{
			if ( NewPing > 2 * ExactPing )
				NewPing = FMin(NewPing, 3*ExactPing);
			ExactPing = FMin(0.99, 0.99 * ExactPing + 0.008 * NewPing); // placebo effect
		}
		PlayerReplicationInfo.Ping = Min(250.0 * ExactPing, 255);
		PlayerReplicationInfo.bReceivedPing = true;
		if ( Level.TimeSeconds - LastPingUpdate > 4 )
		{
			if ( bDynamicNetSpeed && (OldPing > DynamicPingThreshold * 0.001) && (ExactPing > DynamicPingThreshold * 0.001) )
			{
				if ( Level.MoveRepSize < 64 )
					Level.MoveRepSize += 8;
				else if ( Player.CurrentNetSpeed >= 6000 )
					SetNetSpeed(Player.CurrentNetSpeed - 1000);
				OldPing = 0;
			}
			else
				OldPing = ExactPing;
			LastPingUpdate = Level.TimeSeconds;
			ServerUpdatePing(1000 * ExactPing);
		}
	}
    if ( Pawn != None )
    {
        if ( Pawn.bTearOff )
        {
            Pawn = None;
			if ( !IsInState('GameEnded') && !IsInState('RoundEnded') && !IsInState('Dead') )
			{
            	GotoState('Dead');
            }
            return;
        }
        MoveActor = Pawn;
        if ( (ViewTarget != Pawn)
			&& ((ViewTarget == self) || ((Pawn(ViewTarget) != None) && (Pawn(ViewTarget).Health <= 0))) )
		{
			bBehindView = false;
			SetViewTarget(Pawn);
		}
    }
    else
    {
        MoveActor = self;
 	   	if( GetStateName() != newstate )
		{
		    if ( NewState == 'GameEnded' || NewState == 'RoundEnded' )
			    GotoState(NewState);
			else if ( IsInState('Dead') )
			{
		    	if ( (NewState != 'PlayerWalking') && (NewState != 'PlayerSwimming') )
		        {
				    GotoState(NewState);
		        }
		        return;
			}
			else if ( NewState == 'Dead' )
				GotoState(NewState);
		}
	}
    if ( CurrentTimeStamp >= TimeStamp )
        return;
    CurrentTimeStamp = TimeStamp;

    NewLocation.X = NewLocX;
    NewLocation.Y = NewLocY;
    NewLocation.Z = NewLocZ;
    NewVelocity.X = NewVelX;
    NewVelocity.Y = NewVelY;
    NewVelocity.Z = NewVelZ;

	// skip update if no error
    CurrentMove = SavedMoves;
    while ( CurrentMove != None )
    {
        if ( CurrentMove.TimeStamp <= CurrentTimeStamp )
        {
            SavedMoves = CurrentMove.NextMove;
            CurrentMove.NextMove = FreeMoves;
            FreeMoves = CurrentMove;
			if ( CurrentMove.TimeStamp == CurrentTimeStamp )
			{
				FreeMoves.Clear();
				if ( ((Mover(NewBase) != None) || (Vehicle(NewBase) != None))
					&& (NewBase == CurrentMove.EndBase) )
				{
					if ( (GetStateName() == NewState)
						&& IsInState('PlayerWalking')
						&& ((MoveActor.Physics == PHYS_Walking) || (MoveActor.Physics == PHYS_Falling)) )
					{
						if ( VSize(CurrentMove.SavedRelativeLocation - NewLocation) < 3 )
						{
							CurrentMove = None;
							return;
						}
						else if ( (Vehicle(NewBase) != None)
								&& (VSize(Velocity) < 3) && (VSize(NewVelocity) < 3)
								&& (VSize(CurrentMove.SavedRelativeLocation - NewLocation) < 30) )
						{
							CurrentMove = None;
							return;
						}
					}
				}
				else if ( (VSize(CurrentMove.SavedLocation - NewLocation) < 3)
					&& (VSize(CurrentMove.SavedVelocity - NewVelocity) < 3)
					&& (GetStateName() == NewState)
					&& IsInState('PlayerWalking')
					&& ((MoveActor.Physics == PHYS_Walking) || (MoveActor.Physics == PHYS_Falling)) )
				{
					CurrentMove = None;
					return;
				}
				CurrentMove = None;
			}
			else
			{
				FreeMoves.Clear();
				CurrentMove = SavedMoves;
			}
        }
        else
			CurrentMove = None;
    }
	if ( MoveActor.bHardAttach )
	{
		if ( MoveActor.Base == None )
		{
			if ( NewBase != None )
				MoveActor.SetBase(NewBase);
			if ( MoveActor.Base == None )
				MoveActor.bHardAttach = false;
			else
				return;
		}
		else
			return;
	}

	NewFloor.X = NewFloorX;
	NewFloor.Y = NewFloorY;
	NewFloor.Z = NewFloorZ;
	if ( (Mover(NewBase) != None) || (Vehicle(NewBase) != None) )
		NewLocation += NewBase.Location;

	if ( !bDemoOwner )
	{
		//if ( Pawn != None )
		//	log("Client "$Role$" adjust "$self$" stamp "$TimeStamp$" time "$Level.TimeSeconds$" location "$MoveActor.Location);
		MoveActor.bCanTeleport = false;
		if ( !MoveActor.SetLocation(NewLocation) && (Pawn(MoveActor) != None)
			&& (MoveActor.CollisionHeight > Pawn(MoveActor).CrouchHeight)
			&& !Pawn(MoveActor).bIsCrouched
			&& (newPhysics == PHYS_Walking)
			&& (MoveActor.Physics != PHYS_Karma) && (MoveActor.Physics != PHYS_KarmaRagDoll) )
		{
			MoveActor.SetPhysics(newPhysics);

			if ( !MoveActor.SetLocation(NewLocation + vect(0,0,1)*MAXSTEPHEIGHT) )
			{
				Pawn(MoveActor).ForceCrouch();
				MoveActor.SetLocation(NewLocation);
			}
			else
			{
				MoveActor.MoveSmooth(vect(0,0,-1)*MAXSTEPHEIGHT);
			}
		}
		MoveActor.bCanTeleport = true;
	}
	// Hack. Don't let network change physics mode of karma stuff on the client.
	if( (MoveActor.Physics != newPhysics) && (MoveActor.Physics != PHYS_Karma) && (MoveActor.Physics != PHYS_KarmaRagDoll)
		&& (newPhysics != PHYS_Karma) && (newPhysics != PHYS_KarmaRagDoll) )
	{
	    MoveActor.SetPhysics(newPhysics);
	}
	if ( MoveActor != self )
		MoveActor.SetBase(NewBase, NewFloor);

    MoveActor.Velocity = NewVelocity;

    if( GetStateName() != newstate )
        GotoState(newstate);

	bUpdatePosition = true;
}

function ServerUpdatePing(int NewPing)
{
	PlayerReplicationInfo.Ping = Min(0.25 * NewPing, 250);
	PlayerReplicationInfo.bReceivedPing = true;
}

function ClientUpdatePosition()
{
    local SavedMove CurrentMove;
    local int realbRun, realbDuck;
    local bool bRealJump;

	// Dont do any network position updates on things running PHYS_Karma
	if( Pawn != None && (Pawn.Physics == PHYS_Karma || Pawn.Physics == PHYS_KarmaRagDoll) )
		return;

    bUpdatePosition = false;
    realbRun= bRun;
    realbDuck = bDuck;
    bRealJump = bPressedJump;
    CurrentMove = SavedMoves;
    bUpdating = true;

    while ( CurrentMove != None )
    {
		if ( (PendingMove == CurrentMove) && (Pawn != None) )
			PendingMove.SetInitialPosition(Pawn);
        if ( CurrentMove.TimeStamp <= CurrentTimeStamp )
        {
            SavedMoves = CurrentMove.NextMove;
            CurrentMove.NextMove = FreeMoves;
            FreeMoves = CurrentMove;
            FreeMoves.Clear();
            CurrentMove = SavedMoves;
        }
        else
        {
            MoveAutonomous(CurrentMove.Delta, CurrentMove.bRun, CurrentMove.bDuck, CurrentMove.bPressedJump, CurrentMove.bDoubleJump, CurrentMove.DoubleClickMove, CurrentMove.Acceleration, rot(0,0,0));
			if ( Pawn != None )
			{
				CurrentMove.SavedLocation = Pawn.Location;
				CurrentMove.SavedVelocity = Pawn.Velocity;
				CurrentMove.EndBase = Pawn.Base;
				if ( (CurrentMove.EndBase != None) && !CurrentMove.EndBase.bWorldGeometry )
					CurrentMove.SavedRelativeLocation = Pawn.Location - CurrentMove.EndBase.Location;
			}
            CurrentMove = CurrentMove.NextMove;
        }
    }

    bUpdating = false;
    bDuck = realbDuck;
    bRun = realbRun;
    bPressedJump = bRealJump;
}

final function SavedMove GetFreeMove()
{
    local SavedMove s, first;
    local int i;

    if ( FreeMoves == None )
    {
        // don't allow more than 100 saved moves
        For ( s=SavedMoves; s!=None; s=s.NextMove )
        {
            i++;
            if ( i > 100 )
            {
                first = SavedMoves;
                SavedMoves = SavedMoves.NextMove;
                first.Clear();
                first.NextMove = None;
                // clear out all the moves
                While ( SavedMoves != None )
                {
                    s = SavedMoves;
                    SavedMoves = SavedMoves.NextMove;
                    s.Clear();
                    s.NextMove = FreeMoves;
                    FreeMoves = s;
                }
                return first;
            }
        }
        return Spawn(class'SavedMove');
    }
    else
    {
        s = FreeMoves;
        FreeMoves = FreeMoves.NextMove;
        s.NextMove = None;
        return s;
    }
}

function int CompressAccel(int C)
{
    if ( C >= 0 )
        C = Min(C, 127);
    else
        C = Min(abs(C), 127) + 128;
    return C;
}

/*
========================================================================
Here's how player movement prediction, replication and correction works in network games:

Every tick, the PlayerTick() function is called.  It calls the PlayerMove() function (which is implemented
in various states).  PlayerMove() figures out the acceleration and rotation, and then calls ProcessMove()
(for single player or listen servers), or ReplicateMove() (if its a network client).

ReplicateMove() saves the move (in the PendingMove list), calls ProcessMove(), and then replicates the move
to the server by calling the replicated function ServerMove() - passing the movement parameters, the client's
resultant position, and a timestamp.

ServerMove() is executed on the server.  It decodes the movement parameters and causes the appropriate movement
to occur.  It then looks at the resulting position and if enough time has passed since the last response, or the
position error is significant enough, the server calls ClientAdjustPosition(), a replicated function.

ClientAdjustPosition() is executed on the client.  The client sets its position to the servers version of position,
and sets the bUpdatePosition flag to true.

When PlayerTick() is called on the client again, if bUpdatePosition is true, the client will call
ClientUpdatePosition() before calling PlayerMove().  ClientUpdatePosition() replays all the moves in the pending
move list which occured after the timestamp of the move the server was adjusting.
*/

//
// Replicate this client's desired movement to the server.
//
function ReplicateMove
(
    float DeltaTime,
    vector NewAccel,
    eDoubleClickDir DoubleClickMove,
    rotator DeltaRot
)
{
    local SavedMove NewMove, OldMove, AlmostLastMove, LastMove;
    local byte ClientRoll;
    local float OldTimeDelta, NetMoveDelta;
    local int OldAccel;
    local vector BuildAccel, AccelNorm, MoveLoc, CompareAccel;
	local bool bPendingJumpStatus;

	MaxResponseTime = Default.MaxResponseTime * Level.TimeDilation;
	DeltaTime = FMin(DeltaTime, MaxResponseTime);

	// find the most recent move, and the most recent interesting move
    if ( SavedMoves != None )
    {
        LastMove = SavedMoves;
        AlmostLastMove = LastMove;
        AccelNorm = Normal(NewAccel);
        while ( LastMove.NextMove != None )
        {
            // find most recent interesting move to send redundantly
            if ( LastMove.IsJumpMove() )
			{
                OldMove = LastMove;
            }
            else if ( (Pawn != None) && ((OldMove == None) || !OldMove.IsJumpMove()) )
            {
				// see if acceleration direction changed
				if ( OldMove != None )
					CompareAccel = Normal(OldMove.Acceleration);
				else
					CompareAccel = AccelNorm;

				if ( (LastMove.Acceleration != CompareAccel) && ((normal(LastMove.Acceleration) Dot CompareAccel) < 0.95) )
					OldMove = LastMove;
			}

            AlmostLastMove = LastMove;
            LastMove = LastMove.NextMove;
        }
        if ( LastMove.IsJumpMove() )
		{
            OldMove = LastMove;
        }
        else if ( (Pawn != None) && ((OldMove == None) || !OldMove.IsJumpMove()) )
        {
			// see if acceleration direction changed
			if ( OldMove != None )
				CompareAccel = Normal(OldMove.Acceleration);
			else
				CompareAccel = AccelNorm;

			if ( (LastMove.Acceleration != CompareAccel) && ((normal(LastMove.Acceleration) Dot CompareAccel) < 0.95) )
				OldMove = LastMove;
		}
    }

    // Get a SavedMove actor to store the movement in.
	NewMove = GetFreeMove();
	if ( NewMove == None )
		return;
	NewMove.SetMoveFor(self, DeltaTime, NewAccel, DoubleClickMove);

    // Simulate the movement locally.
    bDoubleJump = false;
    ProcessMove(NewMove.Delta, NewMove.Acceleration, NewMove.DoubleClickMove, DeltaRot);

	// see if the two moves could be combined
	if ( (PendingMove != None) && (Pawn != None) && (Pawn.Physics == PHYS_Walking)
		&& (NewMove.Delta + PendingMove.Delta < MaxResponseTime)
		&& (NewAccel != vect(0,0,0))
		&& (PendingMove.SavedPhysics == PHYS_Walking)
		&& !PendingMove.bPressedJump && !NewMove.bPressedJump
		&& (PendingMove.bRun == NewMove.bRun)
		&& (PendingMove.bDuck == NewMove.bDuck)
		&& (PendingMove.bDoubleJump == NewMove.bDoubleJump)
		&& (PendingMove.DoubleClickMove == DCLICK_None)
		&& (NewMove.DoubleClickMove == DCLICK_None)
		&& ((Normal(PendingMove.Acceleration) Dot Normal(NewAccel)) > 0.99)
		&& (Level.TimeDilation >= 0.9) )
	{
		Pawn.SetLocation(PendingMove.GetStartLocation());
		Pawn.Velocity = PendingMove.StartVelocity;
		if ( PendingMove.StartBase != Pawn.Base);
			Pawn.SetBase(PendingMove.StartBase);
		Pawn.Floor = PendingMove.StartFloor;
		NewMove.Delta += PendingMove.Delta;
		NewMove.SetInitialPosition(Pawn);

		// remove pending move from move list
		if ( LastMove == PendingMove )
		{
			if ( SavedMoves == PendingMove )
			{
				SavedMoves.NextMove = FreeMoves;
				FreeMoves = SavedMoves;
				SavedMoves = None;
			}
			else
			{
				PendingMove.NextMove = FreeMoves;
				FreeMoves = PendingMove;
				if ( AlmostLastMove != None )
				{
					AlmostLastMove.NextMove = None;
					LastMove = AlmostLastMove;
				}
			}
			FreeMoves.Clear();
		}
		PendingMove = None;
	}

    if ( Pawn != None )
        Pawn.AutonomousPhysics(NewMove.Delta);
    else
        AutonomousPhysics(DeltaTime);
    NewMove.PostUpdate(self);

	if ( SavedMoves == None )
		SavedMoves = NewMove;
	else
		LastMove.NextMove = NewMove;

	if ( PendingMove == None )
	{
		// Decide whether to hold off on move
		if ( (Player.CurrentNetSpeed > 10000) && (GameReplicationInfo != None) && (GameReplicationInfo.PRIArray.Length <= 10) )
			NetMoveDelta = 0.011;
		else
			NetMoveDelta = FMax(0.0222,2 * Level.MoveRepSize/Player.CurrentNetSpeed);

		if ( (Level.TimeSeconds - ClientUpdateTime) * Level.TimeDilation * 0.91 < NetMoveDelta )
		{
			PendingMove = NewMove;
			return;
		}
	}

    ClientUpdateTime = Level.TimeSeconds;

    // check if need to redundantly send previous move
    if ( OldMove != None )
    {
        // old move important to replicate redundantly
        OldTimeDelta = FMin(255, (Level.TimeSeconds - OldMove.TimeStamp) * 500);
        BuildAccel = 0.05 * OldMove.Acceleration + vect(0.5, 0.5, 0.5);
        OldAccel = (CompressAccel(BuildAccel.X) << 23)
                    + (CompressAccel(BuildAccel.Y) << 15)
                    + (CompressAccel(BuildAccel.Z) << 7);
        if ( OldMove.bRun )
            OldAccel += 64;
        if ( OldMove.bDoubleJump )
            OldAccel += 32;
        if ( OldMove.bPressedJump )
            OldAccel += 16;
        OldAccel += OldMove.DoubleClickMove;
    }

    // Send to the server
	ClientRoll = (Rotation.Roll >> 8) & 255;
    if ( PendingMove != None )
    {
		if ( PendingMove.bPressedJump )
			bJumpStatus = !bJumpStatus;
		bPendingJumpStatus = bJumpStatus;
	}
    if ( NewMove.bPressedJump )
         bJumpStatus = !bJumpStatus;

    if ( Pawn == None )
        MoveLoc = Location;
    else
        MoveLoc = Pawn.Location;

    CallServerMove
    (
        NewMove.TimeStamp,
        NewMove.Acceleration * 10,
        MoveLoc,
        NewMove.bRun,
        NewMove.bDuck,
        bPendingJumpStatus,
        bJumpStatus,
        NewMove.bDoubleJump,
        NewMove.DoubleClickMove,
        ClientRoll,
        (32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2)),
        OldTimeDelta,
        OldAccel
    );
	PendingMove = None;
}

function CallServerMove
(
    float TimeStamp,
    vector InAccel,
    vector ClientLoc,
    bool NewbRun,
    bool NewbDuck,
    bool NewbPendingJumpStatus,
    bool NewbJumpStatus,
    bool NewbDoubleJump,
    eDoubleClickDir DoubleClickMove,
    byte ClientRoll,
    int View,
    optional byte OldTimeDelta,
    optional int OldAccel
)
{
	local byte PendingCompress;
	local bool bCombine;

	if ( PendingMove != None )
	{
		if ( PendingMove.bRun )
			PendingCompress = 1;
		if ( PendingMove.bDuck )
			PendingCompress += 2;
		if ( NewbPendingJumpStatus )
			PendingCompress += 4;
		if ( PendingMove.bDoubleJump )
			PendingCompress += 8;
		if ( NewbRun )
			PendingCompress += 16;
		if ( NewbDuck )
			PendingCompress += 32;
		if ( NewbJumpStatus )
			PendingCompress += 64;
		if ( NewbDoubleJump )
			PendingCompress += 128;

		// send two moves simultaneously
		if ( (InAccel == vect(0,0,0))
			&& (PendingMove.StartVelocity == vect(0,0,0))
			&& (DoubleClickMove == DCLICK_None)
			&& (PendingMove.Acceleration == vect(0,0,0)) && (PendingMove.DoubleClickMove == DCLICK_None) && !PendingMove.bDoubleJump )
		{
			if ( Pawn == None )
				bCombine = (Velocity == vect(0,0,0));
			else
				bCombine = (Pawn.Velocity == vect(0,0,0));

			if ( bCombine )
			{
				if ( OldTimeDelta == 0 )
				{
					ShortServerMove
					(
						TimeStamp,
						ClientLoc,
						NewbRun,
						NewbDuck,
						NewbJumpStatus,
						ClientRoll,
						View
					);
				}
				else
				{
					ServerMove
					(
						TimeStamp,
						InAccel,
						ClientLoc,
						NewbRun,
						NewbDuck,
						NewbJumpStatus,
						NewbDoubleJump,
						DoubleClickMove,
						ClientRoll,
						View,
						OldTimeDelta,
						OldAccel
					);
				}
				return;
			}
		}

		if ( OldTimeDelta == 0 )
			DualServerMove
			(
				PendingMove.TimeStamp,
				PendingMove.Acceleration * 10,
				PendingCompress,
				PendingMove.DoubleClickMove,
				(32767 & (PendingMove.Rotation.Pitch/2)) * 32768 + (32767 & (PendingMove.Rotation.Yaw/2)),
				TimeStamp,
				InAccel,
				ClientLoc,
				DoubleClickMove,
				ClientRoll,
				View
			);
		else
			DualServerMove
			(
				PendingMove.TimeStamp,
				PendingMove.Acceleration * 10,
				PendingCompress,
				PendingMove.DoubleClickMove,
				(32767 & (PendingMove.Rotation.Pitch/2)) * 32768 + (32767 & (PendingMove.Rotation.Yaw/2)),
				TimeStamp,
				InAccel,
				ClientLoc,
				DoubleClickMove,
				ClientRoll,
				View,
				OldTimeDelta,
				OldAccel
			);
	}
	else if ( OldTimeDelta != 0 )
	{
        ServerMove
        (
            TimeStamp,
            InAccel,
            ClientLoc,
            NewbRun,
            NewbDuck,
            NewbJumpStatus,
            NewbDoubleJump,
            DoubleClickMove,
            ClientRoll,
            View,
            OldTimeDelta,
            OldAccel
        );
	}
    else if ( (InAccel == vect(0,0,0)) && (DoubleClickMove == DCLICK_None) && !NewbDoubleJump )
    {
		ShortServerMove
		(
			TimeStamp,
			ClientLoc,
			NewbRun,
			NewbDuck,
			NewbJumpStatus,
			ClientRoll,
			View
		);
    }
    else
		ServerMove
        (
            TimeStamp,
            InAccel,
            ClientLoc,
            NewbRun,
            NewbDuck,
            NewbJumpStatus,
            NewbDoubleJump,
            DoubleClickMove,
            ClientRoll,
            View
        );
}

function HandleWalking()
{
    if ( Pawn != None )
        Pawn.SetWalking( (bRun != 0) && !Region.Zone.IsA('WarpZoneInfo') );
}

function ServerRestartGame()
{
}

function SetFOVAngle(float newFOV)
{
    FOVAngle = newFOV;
}

exec function SetFlashScaling(float F)
{
	ScreenFlashScaling = FClamp(F,0,1);
}

function ClientFlash( float scale, vector fog )
{
    FlashScale = (scale + (1 - ScreenFlashScaling) * (1 - Scale)) * vect(1,1,1);
    flashfog = ScreenFlashScaling * 0.001 * fog;
}

function ClientAdjustGlow( float scale, vector fog )
{
    ConstantGlowScale += scale;
    ConstantGlowFog += 0.001 * fog;
}

function DamageShake(int damage) //send type of damage too!
{
    ClientDamageShake(damage);
}

// function ShakeView( float shaketime, float RollMag, vector OffsetMag, float RollRate, vector OffsetRate, float OffsetTime)

private function ClientDamageShake(int damage)
{
    // todo: add properties!
    ShakeView( Damage * vect(30,0,0),
               120000 * vect(1,0,0),
               0.15 + 0.005 * damage,
               damage * vect(0,0,0.03),
               vect(1,1,1),
               0.2);
}

function WeaponShakeView(vector shRotMag,    vector shRotRate,    float shRotTime,
                   vector shOffsetMag, vector shOffsetRate, float shOffsetTime)
{
	if ( bWeaponViewShake )
		ShakeView(shRotMag * (1.0 - ZoomLevel), shRotRate, shRotTime, shOffsetMag * (1.0 - ZoomLevel), shOffsetRate, shOffsetTime);
}

/* ShakeView()
Call this function to shake the player's view
shaketime = how long to roll view
RollMag = how far to roll view as it shakes
OffsetMag = max view offset
RollRate = how fast to roll view
OffsetRate = how fast to offset view
OffsetTime = how long to offset view (number of shakes)
*/
function ShakeView(vector shRotMag,    vector shRotRate,    float shRotTime,
                   vector shOffsetMag, vector shOffsetRate, float shOffsetTime)
{
    if ( VSize(shRotMag) > VSize(ShakeRotMax) )
    {
        ShakeRotMax  = shRotMag;
        ShakeRotRate = shRotRate;
        ShakeRotTime = shRotTime * vect(1,1,1);
    }

    if ( VSize(shOffsetMag) > VSize(ShakeOffsetMax) )
    {
        ShakeOffsetMax  = shOffsetMag;
        ShakeOffsetRate = shOffsetRate;
        ShakeOffsetTime = shOffsetTime * vect(1,1,1);
    }
}

function StopViewShaking()
{
        ShakeRotMax  = vect(0,0,0);
        ShakeRotRate = vect(0,0,0);
        ShakeRotTime = vect(0,0,0);
	ShakeOffsetMax  = vect(0,0,0);
        ShakeOffsetRate = vect(0,0,0);
        ShakeOffsetTime = vect(0,0,0);
}

//pass in FalloffStartTime = 0 for constant shaking
event SetAmbientShake(float FalloffStartTime, float	FalloffTime, vector	OffsetMag, float OffsetFreq, rotator RotMag, float RotFreq)
{
	bEnableAmbientShake = true;
	AmbientShakeFalloffStartTime = FalloffStartTime;
	AmbientShakeFalloffTime = FalloffTime;
	AmbientShakeOffsetMag = OffsetMag;
	AmbientShakeOffsetFreq = OffsetFreq;
	AmbientShakeRotMag = RotMag;
	AmbientShakeRotFreq = RotFreq;
}

event ShakeViewEvent(vector shRotMag,    vector shRotRate,    float shRotTime, vector shOffsetMag, vector shOffsetRate, float shOffsetTime)
{
	ShakeView(shRotMag, shRotRate, shRotTime, shOffsetMag, shOffsetRate, shOffsetTime);
}

function damageAttitudeTo(pawn Other, float Damage)
{
    if ( (Other != None) && (Other != Pawn) && (Damage > 0) )
        Enemy = Other;
}

function Typing( bool bTyping )
{
    bIsTyping = bTyping;
    if ( (Pawn != None) && !Pawn.bTearOff )
        Pawn.bIsTyping = bIsTyping;

}

//*************************************************************************************
// Normal gameplay execs
// Type the name of the exec function at the console to execute it

exec function Jump( optional float F )
{
    if ( Level.Pauser == PlayerReplicationInfo )
        SetPause(False);
    else
        bPressedJump = true;
}

// Send a voice message of a certain type to a certain player.
exec function Speech( name Type, int Index, string Callsign )
{
	ServerSpeech(Type,Index,Callsign);
}

function ServerSpeech( name Type, int Index, string Callsign )
{
	// log("Type:"$Type@"Index:"$Index@"Callsign:"$Callsign);
	if(PlayerReplicationInfo.VoiceType != None)
		PlayerReplicationInfo.VoiceType.static.PlayerSpeech( Type, Index, Callsign, Self );
}

exec function RestartLevel()
{
    if( Level.Netmode==NM_Standalone )
        ClientTravel( "?restart", TRAVEL_Relative, false );
}

exec function LocalTravel( string URL )
{
    if( Level.Netmode==NM_Standalone )
        ClientTravel( URL, TRAVEL_Relative, true );
}

// ------------------------------------------------------------------------
// Loading and saving

/* QuickSave()
Save game to slot 9
*/
exec function QuickSave()
{
    if ( (Pawn != None) && (Pawn.Health > 0)
        && (Level.NetMode == NM_Standalone) )
    {
        ClientMessage(QuickSaveString);
        ConsoleCommand("SaveGame 9");
    }
}

/* QuickLoad()
Load game from slot 9
*/
exec function QuickLoad()
{
    if ( Level.NetMode == NM_Standalone )
        ClientTravel( "?load=9", TRAVEL_Absolute, false);
}

/* SetPause()
 Try to pause game; returns success indicator.
 Replicated to server in network games.
 */
function bool SetPause( BOOL bPause )
{
    bFire = 0;
    bAltFire = 0;
    return Level.Game.SetPause(bPause, self);
}

/* Pause()
Command to try to pause the game.
*/
exec function Pause()
{
	if ( bDemoOwner )
	{
		if ( Level.Pauser == None )
			Level.Pauser = PlayerReplicationInfo;
		else
			Level.Pauser = None;
	}
	else
		ServerPause();
}

function ServerPause()
{
	// Pause if not already
	if(Level.Pauser == None)
		SetPause(true);
	else
		SetPause(false);
}

exec function ShowMenu()
{
	local bool bCloseHUDScreen;

	if ( MyHUD != None )
	{
		bCloseHUDScreen = MyHUD.bShowScoreboard || MyHUD.bShowLocalStats;
		if ( MyHUD.bShowScoreboard )
			MyHUD.bShowScoreboard = false;
		if ( MyHUD.bShowLocalStats )
			MyHUD.bShowLocalStats = false;
		if ( bCloseHUDScreen )
			return;
	}

	ShowMidGameMenu(true);
}

function ShowMidGameMenu(bool bPause)
{
	// Pause if not already
	if(bPause && Level.Pauser == None)
		SetPause(true);

	StopForceFeedback();  // jdf - no way to pause feedback

	// Open menu

	if (bDemoOwner)
		ClientopenMenu(DemoMenuClass);
	else
		ClientOpenMenu(MidGameMenuClass);
}

// Activate specific inventory item
exec function ActivateInventoryItem( class InvItem )
{
    local Powerups Inv;

    Inv = Powerups(Pawn.FindInventoryType(InvItem));
    if ( Inv != None )
        Inv.Activate();
}

// ------------------------------------------------------------------------
// Weapon changing functions

/* ThrowWeapon()
Throw out current weapon, and switch to a new weapon
*/
exec function ThrowWeapon()
{
    if ( (Pawn == None) || (Pawn.Weapon == None) )
        return;

    ServerThrowWeapon();
}

function ServerThrowWeapon()
{
    local Vector TossVel;

    if (Pawn.CanThrowWeapon())
    {
        TossVel = Vector(GetViewRotation());
        TossVel = TossVel * ((Pawn.Velocity Dot TossVel) + 500) + Vect(0,0,250);
        Pawn.TossWeapon(TossVel);
        ClientSwitchToBestWeapon();
    }
}

/* PrevWeapon()
- switch to previous inventory group weapon
*/
exec function PrevWeapon()
{
    if ( Level.Pauser != None )
        return;

	if ( Pawn != None )
		Pawn.PrevWeapon();
	else if ( bBehindView )
		CameraDist = FMax(CameraDistRange.Min, CameraDist - 1.0);
}

/* NextWeapon()
- switch to next inventory group weapon
*/
exec function NextWeapon()
{
    if ( Level.Pauser != None )
        return;

	if ( Pawn != None )
		Pawn.NextWeapon();
	else if ( bBehindView )
		CameraDist = FMin(CameraDistRange.Max, CameraDist + 1.0);
}

exec function PipedSwitchWeapon(byte F)
{
	if ( (Pawn == None) || (Pawn.PendingWeapon != None) )
		return;

	SwitchWeapon(F);
}

// The player wants to switch to weapon group number F.
exec function SwitchWeapon(byte F)
{
	if ( Pawn != None )
		Pawn.SwitchWeapon(F);
}

exec function GetWeapon(class<Weapon> NewWeaponClass )
{
    local Inventory Inv;
    local int Count;

    if ( (Pawn == None) || (Pawn.Inventory == None) || (NewWeaponClass == None) )
        return;

    if ( (Pawn.Weapon != None) && (Pawn.Weapon.Class == NewWeaponClass) && (Pawn.PendingWeapon == None) )
    {
        Pawn.Weapon.Reselect();
        return;
    }

    if ( Pawn.PendingWeapon != None && Pawn.PendingWeapon.bForceSwitch )
        return;

    for ( Inv=Pawn.Inventory; Inv!=None; Inv=Inv.Inventory )
    {
        if ( Inv.Class == NewWeaponClass )
        {
            Pawn.PendingWeapon = Weapon(Inv);
            if ( !Pawn.PendingWeapon.HasAmmo() )
            {
                ClientMessage( Pawn.PendingWeapon.ItemName$Pawn.PendingWeapon.MessageNoAmmo );
                Pawn.PendingWeapon = None;
                return;
            }
            Pawn.Weapon.PutDown();
            return;
        }
		Count++;
		if ( Count > 1000 )
			return;
    }
}

// The player wants to select previous item
exec function PrevItem()
{
    local Inventory Inv;
    local Powerups LastItem;

    if ( (Level.Pauser!=None) || (Pawn == None) )
        return;
    if (Pawn.SelectedItem==None)
    {
        Pawn.SelectedItem = Pawn.Inventory.SelectNext();
        Return;
    }
    if (Pawn.SelectedItem.Inventory!=None)
        for( Inv=Pawn.SelectedItem.Inventory; Inv!=None; Inv=Inv.Inventory )
        {
            if (Inv==None) Break;
            if ( Inv.IsA('Powerups') && Powerups(Inv).bActivatable) LastItem=Powerups(Inv);
        }
    for( Inv=Pawn.Inventory; Inv!=Pawn.SelectedItem; Inv=Inv.Inventory )
    {
        if (Inv==None) Break;
        if ( Inv.IsA('Powerups') && Powerups(Inv).bActivatable) LastItem=Powerups(Inv);
    }
    if (LastItem!=None)
        Pawn.SelectedItem = LastItem;
}

// The player wants to active selected item
exec function ActivateItem()
{
    if( Level.Pauser!=None )
        return;
    if ( (Pawn != None) && (Pawn.SelectedItem!=None) )
        Pawn.SelectedItem.Activate();
}

// The player wants to fire.
exec function Fire( optional float F )
{
	if ( Level.NetMode == NM_StandAlone && bViewingMatineeCinematic )
	{
		Level.Game.SceneAbort();
	}

    if ( Level.Pauser == PlayerReplicationInfo )
    {
        SetPause(false);
        return;
    }
	if( bDemoOwner || (Pawn == None) )
		return;

    Pawn.Fire(F);
}

// The player wants to alternate-fire.
exec function AltFire( optional float F )
{
    if ( Level.Pauser == PlayerReplicationInfo )
    {
        SetPause(false);
        return;
    }
	if( bDemoOwner || (Pawn == None) )
		return;
    Pawn.AltFire(F);
}

// The player wants to use something in the level.
exec function Use()
{
    ServerUse();
}

function ServerUse()
{
    local Actor A;
	local Vehicle DrivenVehicle, EntryVehicle, V;

	if ( Role < ROLE_Authority )
		return;

    if ( Level.Pauser == PlayerReplicationInfo )
    {
        SetPause(false);
        return;
    }

    if (Pawn == None || !Pawn.bCanUse)
        return;

	DrivenVehicle = Vehicle(Pawn);
	if( DrivenVehicle != None )
	{
		DrivenVehicle.KDriverLeave(false);
		return;
	}

    // Check for nearby vehicles
    ForEach Pawn.VisibleCollidingActors(class'Vehicle', V, VehicleCheckRadius)
    {
        // Found a vehicle within radius
        EntryVehicle = V.FindEntryVehicle(Pawn);
        if (EntryVehicle != None && EntryVehicle.TryToDrive(Pawn))
            return;
    }

    // Send the 'DoUse' event to each actor player is touching.
    ForEach Pawn.TouchingActors(class'Actor', A)
        A.UsedBy(Pawn);

	if ( Pawn.Base != None )
		Pawn.Base.UsedBy( Pawn );
}

exec function Suicide()
{
	local float MinSuicideInterval;

	if ( Level.NetMode == NM_Standalone )
		MinSuicideInterval = 1;
	else
		MinSuicideInterval = 10;

	if ( (Pawn != None) && (Level.TimeSeconds - Pawn.LastStartTime > MinSuicideInterval) )
		Pawn.Suicide();
}

exec function SetName( coerce string S)
{
    ChangeName(S);
    UpdateURL("Name", S, true);
    SaveConfig();
}

exec function SetVoice( coerce string S )
{
	if ( Level.NetMode == NM_StandAlone )
	{
		if ( PlayerReplicationInfo != None )
			PlayerReplicationInfo.SetCharacterVoice(S);
	}

	else ChangeVoiceType(S);
	UpdateURL("Voice", S, True);
}

function ChangeVoiceType(string NewVoiceType)
{
	if ( VoiceChangeLimit > Level.TimeSeconds )
		return;

	VoiceChangeLimit = Level.TimeSeconds + 10.0;	// TODO - probably better to hook this up to the same limit system that playernames use
	if ( NewVoiceType != "" && PlayerReplicationInfo != None )
		PlayerReplicationInfo.SetCharacterVoice(NewVoiceType);
}

function ChangeName( coerce string S )
{
    if ( Len(S) > 20 )
        S = left(S,20);
    ReplaceText(S, " ", "_");
    ReplaceText(S, "\"", "");
    Level.Game.ChangeName( self, S, true );
}

exec function SwitchTeam()
{
    if ( (PlayerReplicationInfo.Team == None) || (PlayerReplicationInfo.Team.TeamIndex == 1) )
        ServerChangeTeam(0);
    else
        ServerChangeTeam(1);
}

exec function ChangeTeam( int N )
{
	ServerChangeTeam(N);
}

function ServerChangeTeam( int N )
{
    local TeamInfo OldTeam;

    OldTeam = PlayerReplicationInfo.Team;
    Level.Game.ChangeTeam(self, N, true);
    if ( Level.Game.bTeamGame && (PlayerReplicationInfo.Team != OldTeam) )
    {
		if ( (OldTeam != None) && (PlayerReplicationInfo.Team != None)
			&& (PlayerReplicationInfo.Team.Size > OldTeam.Size) )
			Adrenaline = 0;
		if ( Pawn != None )
			Pawn.PlayerChangedTeam();
    }
}


exec function SwitchLevel( string URL )
{
    if( Level.NetMode==NM_Standalone || Level.netMode==NM_ListenServer )
        Level.ServerTravel( URL, false );
}

event ProgressCommand(string Cmd, string Msg1, string Msg2)
{
	local string c,v;

	log(Name$".ProgressCommand Cmd '"$Cmd$"'  Msg1 '"$Msg1$"'   Msg2 '"$Msg2$"'");

	Divide(Cmd, ":", C, V);

	// Checking for bActive prevents multiple status message menus from being opened. However, this also
	// prevents status messages from appearing if another menu is open.
	// Instead, place checks for bActive in places where ProgressCommand is called, but we don't want to override other menus.
	if ( C~="menu" /*&& (!Player.GUIController.bActive)*/ )
		ClientOpenMenu(v, false, Msg1, Msg2);
}


exec function ClearProgressMessages()
{
    local int i;

    for (i=0; i<ArrayCount(ProgressMessage); i++)
    {
        ProgressMessage[i] = "";
        ProgressColor[i] = class'Canvas'.Static.MakeColor(255,255,255);
    }
}

exec event SetProgressMessage( int Index, string S, color C )
{
    if ( Index < ArrayCount(ProgressMessage) )
    {
        ProgressMessage[Index] = S;
        ProgressColor[Index] = C;
    }
}

exec event SetProgressTime( float T )
{
    ProgressTimeOut = T + Level.TimeSeconds;
}

function Restart()
{
    Super.Restart();
    ServerTimeStamp = 0;
	ResetTimeMargin();
    EnterStartState();
    bBehindView = Pawn.PointOfView();
    ClientRestart(Pawn);
    SetViewTarget(Pawn);
}

function EnterStartState()
{
    local name NewState;

    if ( Pawn.PhysicsVolume.bWaterVolume )
    {
        if ( Pawn.HeadVolume.bWaterVolume )
            Pawn.BreathTime = Pawn.UnderWaterTime;
        NewState = Pawn.WaterMovementState;
    }
    else
        NewState = Pawn.LandMovementState;

    if ( IsInState(NewState) )
        BeginState();
    else
        GotoState(NewState);
}

function ClientRestart(Pawn NewPawn)
{
	local bool bNewViewTarget;

	Pawn = NewPawn;
	if ( (Pawn != None) && Pawn.bTearOff )
	{
		Pawn.Controller = None;
		Pawn = None;
	}
	AcknowledgePossession(Pawn);
    if ( Pawn == None )
    {
        GotoState('WaitingForPawn');
        return;
    }
    Pawn.ClientRestart();
    bNewViewTarget = (ViewTarget != Pawn);
    SetViewTarget(Pawn);
    bBehindView = Pawn.PointOfView();
    BehindView(bBehindView);
    if (bNewViewTarget)
	    Pawn.POVChanged(self, false);
    CleanOutSavedMoves();
    EnterStartState();
}

exec function BehindView( Bool B )
{
	if ( Level.NetMode == NM_Standalone || bDemoOwner || Level.Game.bAllowBehindView || Vehicle(Pawn) != None || PlayerReplicationInfo.bOnlySpectator || PlayerReplicationInfo.bAdmin || IsA('Admin') )
	{
		if ( (Vehicle(Pawn)==None) || (Vehicle(Pawn).bAllowViewChange) )	// Allow vehicles to limit view changes
		{
			ClientSetBehindView(B);
			bBehindView = B;
		}
	}
}

exec function ToggleBehindView()
{
	ServerToggleBehindview();
}

function ServerToggleBehindView()
{
	local bool B;

	if ( Level.NetMode == NM_Standalone || Level.Game.bAllowBehindView || Vehicle(Pawn) != None || PlayerReplicationInfo.bOnlySpectator || PlayerReplicationInfo.bAdmin || IsA('Admin') )
	{
		if ( (Vehicle(Pawn)==None) || (Vehicle(Pawn).bAllowViewChange) )	// Allow vehicles to limit view changes
		{
			B = !bBehindView;
			ClientSetBehindView(B);
			bBehindView = B;
		}
	}
}

//=============================================================================
// functions.

// Just changed to pendingWeapon
function ChangedWeapon()
{
    if ( Pawn != None && Pawn.Weapon != None )
    {
        Pawn.Weapon.SetHand(Handedness);
        LastPawnWeapon = Pawn.Weapon.Class;
    }
}

event TravelPostAccept()
{
    if ( Pawn.Health <= 0 )
        Pawn.Health = Pawn.Default.Health;
}

event PlayerTick( float DeltaTime )
{
	if ( bForcePrecache )
	{
		if ( Level.TimeSeconds > ForcePrecacheTime )
		{
			bForcePrecache = false;
			Level.FillPrecacheMaterialsArray( false );
			Level.FillPrecacheStaticMeshesArray( false );
		}
	}
	else if ( !bShortConnectTimeOut )
	{
		bShortConnectTimeOut = true;
		ServerShortTimeout();
	}

	if ( Pawn != AcknowledgedPawn )
	{
		if ( Role < ROLE_Authority )
		{
			// make sure old pawn controller is right
			if ( (AcknowledgedPawn != None) && (AcknowledgedPawn.Controller == self) )
				AcknowledgedPawn.Controller = None;
		}
		AcknowledgePossession(Pawn);
	}
    PlayerInput.PlayerInput(DeltaTime);
    if ( bUpdatePosition )
        ClientUpdatePosition();

	if ( !IsSpectating() && Pawn != None )
    	Pawn.RawInput(DeltaTime, aBaseX, aBaseY, aBaseZ, aMouseX, aMouseY, aForward, aTurn, aStrafe, aUp, aLookUp);

    PlayerMove(DeltaTime);
}

function PlayerMove(float DeltaTime);

//
/* AdjustAim()
Calls this version for player aiming help.
Aimerror not used in this version.
Only adjusts aiming at pawns
*/
function rotator AdjustAim(FireProperties FiredAmmunition, vector projStart, int aimerror)
{
    local vector FireDir, AimSpot, HitNormal, HitLocation, OldAim, AimOffset;
    local actor BestTarget;
    local float bestAim, bestDist, projspeed;
    local actor HitActor;
    local bool bNoZAdjust, bLeading;
    local rotator AimRot;

    FireDir = vector(Rotation);
    if ( FiredAmmunition.bInstantHit )
        HitActor = Trace(HitLocation, HitNormal, projStart + 10000 * FireDir, projStart, true);
    else
        HitActor = Trace(HitLocation, HitNormal, projStart + 4000 * FireDir, projStart, true);
    if ( (HitActor != None) && HitActor.bProjTarget )
    {
        BestTarget = HitActor;
        bNoZAdjust = true;
        OldAim = HitLocation;
        BestDist = VSize(BestTarget.Location - Pawn.Location);
    }
    else
    {
        // adjust aim based on FOV
        bestAim = 0.90;
        if ( (Level.NetMode == NM_Standalone) && bAimingHelp )
        {
            bestAim = 0.93;
            if ( FiredAmmunition.bInstantHit )
                bestAim = 0.97;
            if ( FOVAngle < DefaultFOV - 8 )
                bestAim = 0.99;
        }
        else if ( FiredAmmunition.bInstantHit )
                bestAim = 1.0;
        BestTarget = PickTarget(bestAim, bestDist, FireDir, projStart, FiredAmmunition.MaxRange);
        if ( BestTarget == None )
        {
            if (bBehindView)
                return Pawn.Rotation;
            else
				return Rotation;
        }
        OldAim = projStart + FireDir * bestDist;
    }
	InstantWarnTarget(BestTarget,FiredAmmunition,FireDir);
	ShotTarget = Pawn(BestTarget);
    if ( !bAimingHelp || (Level.NetMode != NM_Standalone) )
    {
        if (bBehindView)
            return Pawn.Rotation;
        else
            return Rotation;
    }

    // aim at target - help with leading also
    if ( !FiredAmmunition.bInstantHit )
    {
        projspeed = FiredAmmunition.ProjectileClass.default.speed;
        BestDist = vsize(BestTarget.Location + BestTarget.Velocity * FMin(1, 0.02 + BestDist/projSpeed) - projStart);
        bLeading = true;
        FireDir = BestTarget.Location + BestTarget.Velocity * FMin(1, 0.02 + BestDist/projSpeed) - projStart;
        AimSpot = projStart + bestDist * Normal(FireDir);
        // if splash damage weapon, try aiming at feet - trace down to find floor
        if ( FiredAmmunition.bTrySplash
            && ((BestTarget.Velocity != vect(0,0,0)) || (BestDist > 1500)) )
        {
            HitActor = Trace(HitLocation, HitNormal, AimSpot - BestTarget.CollisionHeight * vect(0,0,2), AimSpot, false);
            if ( (HitActor != None)
                && FastTrace(HitLocation + vect(0,0,4),projstart) )
                return rotator(HitLocation + vect(0,0,6) - projStart);
        }
    }
    else
    {
        FireDir = BestTarget.Location - projStart;
        AimSpot = projStart + bestDist * Normal(FireDir);
    }
    AimOffset = AimSpot - OldAim;

    // adjust Z of shooter if necessary
    if ( bNoZAdjust || (bLeading && (Abs(AimOffset.Z) < BestTarget.CollisionHeight)) )
        AimSpot.Z = OldAim.Z;
    else if ( AimOffset.Z < 0 )
        AimSpot.Z = BestTarget.Location.Z + 0.4 * BestTarget.CollisionHeight;
    else
        AimSpot.Z = BestTarget.Location.Z - 0.7 * BestTarget.CollisionHeight;

    if ( !bLeading )
    {
        // if not leading, add slight random error ( significant at long distances )
        if ( !bNoZAdjust )
        {
            AimRot = rotator(AimSpot - projStart);
            if ( FOVAngle < DefaultFOV - 8 )
                AimRot.Yaw = AimRot.Yaw + 200 - Rand(400);
            else
                AimRot.Yaw = AimRot.Yaw + 375 - Rand(750);
            return AimRot;
        }
    }
    else if ( !FastTrace(projStart + 0.9 * bestDist * Normal(FireDir), projStart) )
    {
        FireDir = BestTarget.Location - projStart;
        AimSpot = projStart + bestDist * Normal(FireDir);
    }

    return rotator(AimSpot - projStart);
}

function bool NotifyLanded(vector HitNormal)
{
    return bUpdating;
}

//=============================================================================
// Player Control

// Player view.
// Compute the rendering viewpoint for the player.
//

function AdjustView(float DeltaTime )
{
    // teleporters affect your FOV, so adjust it back down
    if ( FOVAngle != DesiredFOV )
    {
        if ( FOVAngle > DesiredFOV )
            FOVAngle = FOVAngle - FMax(7, 0.9 * DeltaTime * (FOVAngle - DesiredFOV));
        else
            FOVAngle = FOVAngle - FMin(-7, 0.9 * DeltaTime * (FOVAngle - DesiredFOV));
        if ( Abs(FOVAngle - DesiredFOV) <= 10 )
            FOVAngle = DesiredFOV;
    }

    // adjust FOV for weapon zooming
    if ( bZooming )
    {
        ZoomLevel = FMin(ZoomLevel + DeltaTime, DesiredZoomLevel);
        DesiredFOV = FClamp(90.0 - (ZoomLevel * 88.0), 1, 170);
    }
}

function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
    local vector View,HitLocation,HitNormal;
    local float ViewDist,RealDist;
    local vector globalX,globalY,globalZ;
    local vector localX,localY,localZ;

    CameraRotation = Rotation;
    CameraRotation.Roll = 0;
	CameraLocation.Z += 12;

    // add view rotation offset to cameraview (amb)
    CameraRotation += CameraDeltaRotation;

    View = vect(1,0,0) >> CameraRotation;

    // add view radius offset to camera location and move viewpoint up from origin (amb)
    RealDist = Dist;
    Dist += CameraDeltaRad;

    if( Trace( HitLocation, HitNormal, CameraLocation - Dist * vector(CameraRotation), CameraLocation,false,vect(10,10,10) ) != None )
        ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
    else
        ViewDist = Dist;

    if ( !bBlockCloseCamera || !bValidBehindCamera || (ViewDist > 10 + FMax(ViewTarget.CollisionRadius, ViewTarget.CollisionHeight)) )
	{
		//Log("Update Cam ");
		bValidBehindCamera = true;
		OldCameraLoc = CameraLocation - ViewDist * View;
		OldCameraRot = CameraRotation;
	}
	else
	{
		//Log("Dont Update Cam "$bBlockCloseCamera@bValidBehindCamera@ViewDist);
		SetRotation(OldCameraRot);
	}

    CameraLocation = OldCameraLoc;
    CameraRotation = OldCameraRot;

    // add view swivel rotation to cameraview (amb)
    GetAxes(CameraSwivel,globalX,globalY,globalZ);
    localX = globalX >> CameraRotation;
    localY = globalY >> CameraRotation;
    localZ = globalZ >> CameraRotation;
    CameraRotation = OrthoRotation(localX,localY,localZ);
}

function CalcFirstPersonView( out vector CameraLocation, out rotator CameraRotation )
{
    local vector x, y, z, AmbShakeOffset;
	local rotator AmbShakeRot;
	local float FalloffScaling;

    GetAxes(Rotation, x, y, z);

	if(bEnableAmbientShake)
	{
		if (AmbientShakeFalloffStartTime > 0 && Level.TimeSeconds - AmbientShakeFalloffStartTime > AmbientShakeFalloffTime)
			bEnableAmbientShake = false;
		else
		{
			if (AmbientShakeFalloffStartTime > 0)
			{
		FalloffScaling = 1.0 - ((Level.TimeSeconds - AmbientShakeFalloffStartTime) / AmbientShakeFalloffTime);
		FalloffScaling = FClamp(FalloffScaling, 0.0, 1.0);
			}
			else
				FalloffScaling = 1.0;

		AmbShakeOffset = AmbientShakeOffsetMag * FalloffScaling *
			sin(Level.TimeSeconds * AmbientShakeOffsetFreq * 2 * Pi);

		AmbShakeRot = AmbientShakeRotMag * FalloffScaling *
			sin(Level.TimeSeconds * AmbientShakeRotFreq * 2 * Pi);
	}
	}

    // First-person view.
    CameraRotation = Normalize(Rotation + ShakeRot + AmbShakeRot); // amb
    CameraLocation = CameraLocation + Pawn.EyePosition() + Pawn.WalkBob +
                     ShakeOffset.X * x +
                     ShakeOffset.Y * y +
                     ShakeOffset.Z * z +
					 AmbShakeOffset;
}

event AddCameraEffect(CameraEffect NewEffect,optional bool RemoveExisting)
{
    if(RemoveExisting)
        RemoveCameraEffect(NewEffect);

    CameraEffects.Length = CameraEffects.Length + 1;
    CameraEffects[CameraEffects.Length - 1] = NewEffect;
}

event RemoveCameraEffect(CameraEffect ExEffect)
{
    local int   EffectIndex;

    for(EffectIndex = 0;EffectIndex < CameraEffects.Length;EffectIndex++)
        if(CameraEffects[EffectIndex] == ExEffect)
        {
            CameraEffects.Remove(EffectIndex,1);
            return;
        }
}

exec function CreateCameraEffect(class<CameraEffect> EffectClass)
{
    AddCameraEffect(new EffectClass);
}

simulated function rotator GetViewRotation()
{
    if ( bBehindView && (Pawn != None) )
        return Pawn.Rotation;
    return Rotation;
}

function CacheCalcView(actor ViewActor, vector CameraLocation, rotator CameraRotation)
{
	CalcViewActor		= ViewActor;
	if (ViewActor != None)
		CalcViewActorLocation = ViewActor.Location;
	CalcViewLocation	= CameraLocation;
	CalcViewRotation	= CameraRotation;
	LastPlayerCalcView	= Level.TimeSeconds;
}

event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
    local Pawn PTarget;

	if ( LastPlayerCalcView == Level.TimeSeconds && CalcViewActor != None && CalcViewActor.Location == CalcViewActorLocation )
	{
		ViewActor	= CalcViewActor;
		CameraLocation	= CalcViewLocation;
		CameraRotation	= CalcViewRotation;
		return;
	}

	// If desired, call the pawn's own special callview
	if( Pawn != None && Pawn.bSpecialCalcView && (ViewTarget == Pawn) )
	{
		// try the 'special' calcview. This may return false if its not applicable, and we do the usual.
		if ( Pawn.SpecialCalcView(ViewActor, CameraLocation, CameraRotation) )
		{
			CacheCalcView(ViewActor,CameraLocation,CameraRotation);
			return;
		}
	}

    if ( (ViewTarget == None) || ViewTarget.bDeleteMe )
    {
        if ( bViewBot && (CheatManager != None) )
			CheatManager.ViewBot();
        else if ( (Pawn != None) && !Pawn.bDeleteMe )
            SetViewTarget(Pawn);
        else if ( RealViewTarget != None )
            SetViewTarget(RealViewTarget);
        else
            SetViewTarget(self);
    }

    ViewActor = ViewTarget;
    CameraLocation = ViewTarget.Location;

    if ( ViewTarget == Pawn )
    {
        if( bBehindView ) //up and behind
            CalcBehindView(CameraLocation, CameraRotation, CameraDist * Pawn.Default.CollisionRadius);
        else
            CalcFirstPersonView( CameraLocation, CameraRotation );

		CacheCalcView(ViewActor,CameraLocation,CameraRotation);
        return;
    }
    if ( ViewTarget == self )
    {
        if ( bCameraPositionLocked )
            CameraRotation = CheatManager.LockedRotation;
        else
            CameraRotation = Rotation;

		CacheCalcView(ViewActor,CameraLocation,CameraRotation);
        return;
    }

    if ( ViewTarget.IsA('Projectile') )
    {
        if ( Projectile(ViewTarget).bSpecialCalcView && Projectile(ViewTarget).SpecialCalcView(ViewActor, CameraLocation, CameraRotation, bBehindView) )
        {
            CacheCalcView(ViewActor,CameraLocation,CameraRotation);
            return;
        }

        if ( !bBehindView )
        {
            CameraLocation += (ViewTarget.CollisionHeight) * vect(0,0,1);
            CameraRotation = Rotation;

    		CacheCalcView(ViewActor,CameraLocation,CameraRotation);
            return;
        }
    }

    CameraRotation = ViewTarget.Rotation;
    PTarget = Pawn(ViewTarget);
    if ( PTarget != None )
    {
        if ( (Level.NetMode == NM_Client) || (bDemoOwner && (Level.NetMode != NM_Standalone)) )
        {
            PTarget.SetViewRotation(TargetViewRotation);
            CameraRotation = BlendedTargetViewRotation;

            PTarget.EyeHeight = TargetEyeHeight;
        }
        else if ( PTarget.IsPlayerPawn() )
            CameraRotation = PTarget.GetViewRotation();

		if (PTarget.bSpecialCalcView && PTarget.SpectatorSpecialCalcView(self, ViewActor, CameraLocation, CameraRotation))
		{
			CacheCalcView(ViewActor, CameraLocation, CameraRotation);
			return;
		}

        if ( !bBehindView )
            CameraLocation += PTarget.EyePosition();
    }
    if ( bBehindView )
    {
        CameraLocation = CameraLocation + (ViewTarget.Default.CollisionHeight - ViewTarget.CollisionHeight) * vect(0,0,1);
        CalcBehindView(CameraLocation, CameraRotation, CameraDist * ViewTarget.Default.CollisionRadius);
    }

	CacheCalcView(ViewActor,CameraLocation,CameraRotation);
}

function int BlendRot(float DeltaTime, int BlendC, int NewC)
{
	if ( Abs(BlendC - NewC) > 32767 )
	{
		if ( BlendC > NewC )
			NewC += 65536;
		else
			BlendC += 65536;
	}
	if ( Abs(BlendC - NewC) > 4096 )
		BlendC = NewC;
	else
		BlendC = BlendC + (NewC - BlendC) * FMin(1,24 * DeltaTime);

	return (BlendC & 65535);
}

function CheckShake(out float MaxOffset, out float Offset, out float Rate, out float Time, float dt)
{
    if ( abs(Offset) < abs(MaxOffset) )
        return;

    Offset = MaxOffset;
    if ( Time > 1 )
    {
        if ( Time * abs(MaxOffset/Rate) <= 1 )
            MaxOffset = MaxOffset * (1/Time - 1);
        else
            MaxOffset *= -1;
        Time -= dt;
        Rate *= -1;
    }
    else
    {
        MaxOffset = 0;
        Offset = 0;
        Rate = 0;
    }
}

function UpdateShakeRotComponent(out float max, out int current, out float rate, out float time, float dt)
{
    local float fCurrent;

    current = ((current & 65535) + rate * dt) & 65535;
    if ( current > 32768 )
    current -= 65536;

    fCurrent = current;
    CheckShake(max, fCurrent, rate, time, dt);
    current = fCurrent;
}

function ViewShake(float DeltaTime)
{
    if ( ShakeOffsetRate != vect(0,0,0) )
    {
        // modify shake offset
        ShakeOffset.X += DeltaTime * ShakeOffsetRate.X;
        CheckShake(ShakeOffsetMax.X, ShakeOffset.X, ShakeOffsetRate.X, ShakeOffsetTime.X, DeltaTime);

        ShakeOffset.Y += DeltaTime * ShakeOffsetRate.Y;
        CheckShake(ShakeOffsetMax.Y, ShakeOffset.Y, ShakeOffsetRate.Y, ShakeOffsetTime.Y, DeltaTime);

        ShakeOffset.Z += DeltaTime * ShakeOffsetRate.Z;
        CheckShake(ShakeOffsetMax.Z, ShakeOffset.Z, ShakeOffsetRate.Z, ShakeOffsetTime.Z, DeltaTime);
    }

    if ( ShakeRotRate != vect(0,0,0) )
    {
        UpdateShakeRotComponent(ShakeRotMax.X, ShakeRot.Pitch, ShakeRotRate.X, ShakeRotTime.X, DeltaTime);
        UpdateShakeRotComponent(ShakeRotMax.Y, ShakeRot.Yaw,   ShakeRotRate.Y, ShakeRotTime.Y, DeltaTime);
        UpdateShakeRotComponent(ShakeRotMax.Z, ShakeRot.Roll,  ShakeRotRate.Z, ShakeRotTime.Z, DeltaTime);
    }
}

function bool TurnTowardNearestEnemy();

function TurnAround()
{
    if ( !bSetTurnRot )
    {
        TurnRot180 = Rotation;
        TurnRot180.Yaw += 32768;
        bSetTurnRot = true;
    }

    DesiredRotation = TurnRot180;
    bRotateToDesired = ( DesiredRotation.Yaw != Rotation.Yaw );
}

function UpdateRotation(float DeltaTime, float maxPitch)
{
    local rotator newRotation, ViewRotation;

    if ( bInterpolating || ((Pawn != None) && Pawn.bInterpolating) )
    {
        ViewShake(deltaTime);
        return;
    }

    // Added FreeCam control for better view control
    if (bFreeCam == True)
    {
        if (bFreeCamZoom == True)
        {
            CameraDeltaRad += DeltaTime * 0.25 * aLookUp;
        }
        else if (bFreeCamSwivel == True)
        {
            CameraSwivel.Yaw += 16.0 * DeltaTime * aTurn;
            CameraSwivel.Pitch += 16.0 * DeltaTime * aLookUp;
        }
        else
        {
            CameraDeltaRotation.Yaw += 32.0 * DeltaTime * aTurn;
            CameraDeltaRotation.Pitch += 32.0 * DeltaTime * aLookUp;
        }
    }
    else
    {
        ViewRotation = Rotation;

		if(Pawn != None && Pawn.Physics != PHYS_Flying) // mmmmm
		{
			// Ensure we are not setting the pawn to a rotation beyond its desired
			if(	Pawn.DesiredRotation.Roll < 65535 &&
				(ViewRotation.Roll < Pawn.DesiredRotation.Roll || ViewRotation.Roll > 0))
				ViewRotation.Roll = 0;
			else if( Pawn.DesiredRotation.Roll > 0 &&
				(ViewRotation.Roll > Pawn.DesiredRotation.Roll || ViewRotation.Roll < 65535))
				ViewRotation.Roll = 0;
		}

        DesiredRotation = ViewRotation; //save old rotation

        if ( bTurnToNearest != 0 )
            TurnTowardNearestEnemy();
        else if ( bTurn180 != 0 )
            TurnAround();
        else
        {
            TurnTarget = None;
            bRotateToDesired = false;
            bSetTurnRot = false;
            ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
            ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
        }
        if (Pawn != None)
	        ViewRotation.Pitch = Pawn.LimitPitch(ViewRotation.Pitch);

        SetRotation(ViewRotation);

        ViewShake(deltaTime);
        ViewFlash(deltaTime);

        NewRotation = ViewRotation;
        //NewRotation.Roll = Rotation.Roll;

        if ( !bRotateToDesired && (Pawn != None) && (!bFreeCamera || !bBehindView) )
            Pawn.FaceRotation(NewRotation, deltatime);
    }
}

function ClearDoubleClick()
{
    if (PlayerInput != None)
        PlayerInput.DoubleClickTimer = 0.0;
}

simulated function bool DodgingIsEnabled()
{
	if ( PlayerInput != None )
		return PlayerInput.bEnableDodging;
	else if ( InputClass != None )
		return InputClass.default.bEnableDodging;
	else return class'Engine.PlayerInput'.default.bEnableDodging;
}

simulated function SetDodging( bool Enabled )
{
    if( PlayerInput != None)
        PlayerInput.bEnableDodging = Enabled;

    InputClass.default.bEnableDodging = Enabled;
    InputClass.static.StaticSaveConfig();
}

// Player movement.
// Player Standing, walking, running, falling.
state PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;

    function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
    {
        if ( NewVolume.bWaterVolume )
            GotoState(Pawn.WaterMovementState);
        return false;
    }

    function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
    {
        local vector OldAccel;
        local bool OldCrouch;

		if ( Pawn == None )
			return;
        OldAccel = Pawn.Acceleration;
        if ( Pawn.Acceleration != NewAccel )
			Pawn.Acceleration = NewAccel;
		if ( bDoubleJump && (bUpdating || Pawn.CanDoubleJump()) )
			Pawn.DoDoubleJump(bUpdating);
        else if ( bPressedJump )
			Pawn.DoJump(bUpdating);

        Pawn.SetViewPitch(Rotation.Pitch);

        if ( Pawn.Physics != PHYS_Falling )
        {
            OldCrouch = Pawn.bWantsToCrouch;
            if (bDuck == 0)
                Pawn.ShouldCrouch(false);
            else if ( Pawn.bCanCrouch )
                Pawn.ShouldCrouch(true);
        }
    }

    function PlayerMove( float DeltaTime )
    {
        local vector X,Y,Z, NewAccel;
        local eDoubleClickDir DoubleClickMove;
        local rotator OldRotation, ViewRotation;
        local bool  bSaveJump;

        if( Pawn == None )
        {
            GotoState('Dead'); // this was causing instant respawns in mp games
            return;
        }

        GetAxes(Pawn.Rotation,X,Y,Z);

        // Update acceleration.
        NewAccel = aForward*X + aStrafe*Y;
        NewAccel.Z = 0;
        if ( VSize(NewAccel) < 1.0 )
            NewAccel = vect(0,0,0);
        DoubleClickMove = PlayerInput.CheckForDoubleClickMove(1.1*DeltaTime/Level.TimeDilation);

        GroundPitch = 0;
        ViewRotation = Rotation;
        if ( Pawn.Physics == PHYS_Walking )
        {
            // tell pawn about any direction changes to give it a chance to play appropriate animation
            //if walking, look up/down stairs - unless player is rotating view
             if ( (bLook == 0)
                && (((Pawn.Acceleration != Vect(0,0,0)) && bSnapToLevel) || !bKeyboardLook) )
            {
                if ( bLookUpStairs || bSnapToLevel )
                {
                    GroundPitch = FindStairRotation(deltaTime);
                    ViewRotation.Pitch = GroundPitch;
                }
                else if ( bCenterView )
                {
                    ViewRotation.Pitch = ViewRotation.Pitch & 65535;
                    if (ViewRotation.Pitch > 32768)
                        ViewRotation.Pitch -= 65536;
                    ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
                    if ( (Abs(ViewRotation.Pitch) < 250) && (ViewRotation.Pitch < 100) )
                        ViewRotation.Pitch = -249;
                }
            }
        }
        else
        {
            if ( !bKeyboardLook && (bLook == 0) && bCenterView )
            {
                ViewRotation.Pitch = ViewRotation.Pitch & 65535;
                if (ViewRotation.Pitch > 32768)
                    ViewRotation.Pitch -= 65536;
                ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
                if ( (Abs(ViewRotation.Pitch) < 250) && (ViewRotation.Pitch < 100) )
                    ViewRotation.Pitch = -249;
            }
        }
        Pawn.CheckBob(DeltaTime, Y);

        // Update rotation.
        SetRotation(ViewRotation);
        OldRotation = Rotation;
        UpdateRotation(DeltaTime, 1);
		bDoubleJump = false;

        if ( bPressedJump && Pawn.CannotJumpNow() )
        {
            bSaveJump = true;
            bPressedJump = false;
        }
        else
            bSaveJump = false;

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
        else
            ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
        bPressedJump = bSaveJump;
    }

    function BeginState()
    {
       	DoubleClickDir = DCLICK_None;
       	bPressedJump = false;
       	GroundPitch = 0;
		if ( Pawn != None )
		{
            if ( Pawn.Mesh == None )
                Pawn.SetMesh();
            Pawn.ShouldCrouch(false);
            if (Pawn.Physics != PHYS_Falling && Pawn.Physics != PHYS_Karma) // FIXME HACK!!!
                Pawn.SetPhysics(PHYS_Walking);
		}
     }

    function EndState()
    {
        GroundPitch = 0;
        if ( Pawn != None && bDuck==0 )
            Pawn.ShouldCrouch(false);
    }

Begin:
}

// player is climbing ladder
state PlayerClimbing
{
ignores SeePlayer, HearNoise, Bump;

    function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
    {
        if ( NewVolume.bWaterVolume )
            GotoState(Pawn.WaterMovementState);
        else
            GotoState(Pawn.LandMovementState);
        return false;
    }

    function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
    {
        local vector OldAccel;

        OldAccel = Pawn.Acceleration;
        if ( Pawn.Acceleration != NewAccel )
			Pawn.Acceleration = NewAccel;

        if ( bPressedJump )
        {
            Pawn.DoJump(bUpdating);
            if ( Pawn.Physics == PHYS_Falling )
                GotoState('PlayerWalking');
        }
    }

    function PlayerMove( float DeltaTime )
    {
        local vector X,Y,Z, NewAccel;
        local eDoubleClickDir DoubleClickMove;
        local rotator OldRotation, ViewRotation;
        local bool  bSaveJump;

        GetAxes(Rotation,X,Y,Z);

        // Update acceleration.
        if ( Pawn.OnLadder != None )
        {
            NewAccel = aForward*Pawn.OnLadder.ClimbDir;
            if ( Pawn.OnLadder.bAllowLadderStrafing )
				NewAccel += aStrafe*Y;
		}
        else
            NewAccel = aForward*X + aStrafe*Y;
        if ( VSize(NewAccel) < 1.0 )
            NewAccel = vect(0,0,0);

        ViewRotation = Rotation;

        // Update rotation.
        SetRotation(ViewRotation);
        OldRotation = Rotation;
        UpdateRotation(DeltaTime, 1);

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
        else
            ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
        bPressedJump = bSaveJump;
    }

    function BeginState()
    {
        Pawn.ShouldCrouch(false);
        bPressedJump = false;
    }

    function EndState()
    {
        if ( Pawn != None )
            Pawn.ShouldCrouch(false);
    }
}

// Player movement.
// Player Driving a Karma vehicle.
state PlayerDriving
{
ignores SeePlayer, HearNoise, Bump;

    function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
    {

    }

	// Set the throttle, steering etc. for the vehicle based on the input provided
	function ProcessDrive(float InForward, float InStrafe, float InUp, bool InJump)
	{
		local Vehicle CurrentVehicle;

	    CurrentVehicle = Vehicle(Pawn);

        if(CurrentVehicle == None)
            return;

		//log("Forward:"@InForward@" Strafe:"@InStrafe@" Up:"@InUp);

		CurrentVehicle.Throttle = FClamp( InForward/5000.0, -1.0, 1.0 );
		CurrentVehicle.Steering = FClamp( -InStrafe/5000.0, -1.0, 1.0 );
		CurrentVehicle.Rise = FClamp( InUp/5000.0, -1.0, 1.0 );
	}

    function PlayerMove( float DeltaTime )
    {
		local Vehicle CurrentVehicle;
		local float NewPing;

		CurrentVehicle = Vehicle(Pawn);

		// update 'looking' rotation
        UpdateRotation(DeltaTime, 2);

        // TODO: Don't send things like aForward and aStrafe for gunners who don't need it
		// Only servers can actually do the driving logic.
        if (Role < ROLE_Authority )
        {
			if ( (Level.TimeSeconds - LastPingUpdate > 4) && (PlayerReplicationInfo != None) && !bDemoOwner )
			{
				LastPingUpdate = Level.TimeSeconds;
				NewPing = float(ConsoleCommand("GETPING"));
				if ( ExactPing < 0.006 )
					ExactPing = FMin(0.1,0.001 * NewPing);
				else
					ExactPing = 0.99 * ExactPing + 0.0001 * NewPing;
				PlayerReplicationInfo.Ping = Min(250.0 * ExactPing, 255);
				PlayerReplicationInfo.bReceivedPing = true;
				OldPing = ExactPing;
				ServerUpdatePing(1000 * ExactPing);
			}
            if (!bSkippedLastUpdate &&                              // in order to skip this update we must not have skipped the last one
                (Player.CurrentNetSpeed < 10000) &&                 // and netspeed must be low
                (Level.TimeSeconds - ClientUpdateTime < 0.0222) &&  // and time since last update must be short
                bPressedJump == bLastPressedJump &&                 // and update must not contain major changes
                aUp - aLastUp < 0.01 &&                             // "
                aForward - aLastForward < 0.01 &&                   // "
                aStrafe - aLastStrafe < 0.01                        // "
               )
            {
//                log("!bSkippedLastUpdate: "$!bSkippedLastUpdate);
//                log("(Player.CurrentNetSpeed < 10000): "$(Player.CurrentNetSpeed < 10000));
//                log("(Level.TimeSeconds - ClientUpdateTime < 0.0222): "$(Level.TimeSeconds - ClientUpdateTime < 0.0222)$"  - "$Level.TimeSeconds - ClientUpdateTime);
//                log("bPressedJump == bLastPressedJump: "$bPressedJump == bLastPressedJump);
//                log("aUp - aLastUp < 0.01: "$aUp - aLastUp < 0.01);
//                log("aForward - aLastForward < 0.01: "$aForward - aLastForward < 0.01);
//                log("aStrafe - aLastStrafe < 0.01: "$aStrafe - aLastStrafe < 0.01);

                bSkippedLastUpdate = True;
                return;
            }
            else
            {
                bSkippedLastUpdate = False;
                ClientUpdateTime = Level.TimeSeconds;

                // Save Move
                bLastPressedJump = bPressedJump;
                aLastUp = aUp;
                aLastForward = aForward;
                aLastStrafe = aStrafe;

                if (CurrentVehicle != None)
                {
                    CurrentVehicle.Throttle = FClamp( aForward/5000.0, -1.0, 1.0 );
                    CurrentVehicle.Steering = FClamp( -aStrafe/5000.0, -1.0, 1.0 );
                    CurrentVehicle.Rise = FClamp( aUp/5000.0, -1.0, 1.0 );
                }

                ServerDrive(aForward, aStrafe, aUp, bPressedJump, (32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2)));
            }
        }
		else
			ProcessDrive(aForward, aStrafe, aUp, bPressedJump);

		// If the vehicle is being controlled here - set replicated variables.
		if (CurrentVehicle != None)
		{
			if(bFire == 0 && CurrentVehicle.bWeaponIsFiring)
				CurrentVehicle.ClientVehicleCeaseFire(False);

			if(bAltFire == 0 && CurrentVehicle.bWeaponIsAltFiring)
				CurrentVehicle.ClientVehicleCeaseFire(True);
		}
    }

	function BeginState()
	{
		PlayerReplicationInfo.bReceivedPing = false;
		CleanOutSavedMoves();
	}

	function EndState()
	{
		CleanOutSavedMoves();
	}
}

// Player movement.
// Player walking on walls
state PlayerSpidering
{
ignores SeePlayer, HearNoise, Bump;

    event bool NotifyHitWall(vector HitNormal, actor HitActor)
    {
        Pawn.SetPhysics(PHYS_Spider);
        Pawn.SetBase(HitActor, HitNormal);
        return true;
    }

    // if spider mode, update rotation based on floor
    function UpdateRotation(float DeltaTime, float maxPitch)
    {
        local rotator ViewRotation;
        local vector MyFloor, CrossDir, FwdDir, OldFwdDir, OldX, RealFloor;

        if ( bInterpolating || Pawn.bInterpolating )
        {
            ViewShake(deltaTime);
            return;
        }

        TurnTarget = None;
        bRotateToDesired = false;
        bSetTurnRot = false;

        if ( (Pawn.Base == None) || (Pawn.Floor == vect(0,0,0)) )
            MyFloor = vect(0,0,1);
        else
            MyFloor = Pawn.Floor;

        if ( MyFloor != OldFloor )
        {
            // smoothly change floor
            RealFloor = MyFloor;
            MyFloor = Normal(6*DeltaTime * MyFloor + (1 - 6*DeltaTime) * OldFloor);
            if ( (RealFloor Dot MyFloor) > 0.999 )
                MyFloor = RealFloor;
			else
			{
				// translate view direction
				CrossDir = Normal(RealFloor Cross OldFloor);
				FwdDir = CrossDir Cross MyFloor;
				OldFwdDir = CrossDir Cross OldFloor;
				ViewX = MyFloor * (OldFloor Dot ViewX)
							+ CrossDir * (CrossDir Dot ViewX)
							+ FwdDir * (OldFwdDir Dot ViewX);
				ViewX = Normal(ViewX);

				ViewZ = MyFloor * (OldFloor Dot ViewZ)
							+ CrossDir * (CrossDir Dot ViewZ)
							+ FwdDir * (OldFwdDir Dot ViewZ);
				ViewZ = Normal(ViewZ);
				OldFloor = MyFloor;
				ViewY = Normal(MyFloor Cross ViewX);
			}
        }

        if ( (aTurn != 0) || (aLookUp != 0) )
        {
            // adjust Yaw based on aTurn
            if ( aTurn != 0 )
                ViewX = Normal(ViewX + 2 * ViewY * Sin(0.0005*DeltaTime*aTurn));

            // adjust Pitch based on aLookUp
            if ( aLookUp != 0 )
            {
                OldX = ViewX;
                ViewX = Normal(ViewX + 2 * ViewZ * Sin(0.0005*DeltaTime*aLookUp));
                ViewZ = Normal(ViewX Cross ViewY);

                // bound max pitch
                if ( (ViewZ Dot MyFloor) < 0.707   )
                {
                    OldX = Normal(OldX - MyFloor * (MyFloor Dot OldX));
                    if ( (ViewX Dot MyFloor) > 0)
                        ViewX = Normal(OldX + MyFloor);
                    else
                        ViewX = Normal(OldX - MyFloor);

                    ViewZ = Normal(ViewX Cross ViewY);
                }
            }

            // calculate new Y axis
            ViewY = Normal(MyFloor Cross ViewX);
        }
        ViewRotation =  OrthoRotation(ViewX,ViewY,ViewZ);
        SetRotation(ViewRotation);
        ViewShake(deltaTime);
        ViewFlash(deltaTime);
        Pawn.FaceRotation(ViewRotation, deltaTime );
    }

    function bool NotifyLanded(vector HitNormal)
    {
        Pawn.SetPhysics(PHYS_Spider);
        return bUpdating;
    }

    function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
    {
        if ( NewVolume.bWaterVolume )
            GotoState(Pawn.WaterMovementState);
        return false;
    }

    function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
    {
        local vector OldAccel;

        OldAccel = Pawn.Acceleration;
        if ( Pawn.Acceleration != NewAccel )
			Pawn.Acceleration = NewAccel;

        if ( bPressedJump )
            Pawn.DoJump(bUpdating);
    }

    function PlayerMove( float DeltaTime )
    {
        local vector NewAccel;
        local eDoubleClickDir DoubleClickMove;
        local rotator OldRotation, ViewRotation;
        local bool  bSaveJump;

        GroundPitch = 0;
        ViewRotation = Rotation;

        Pawn.CheckBob(DeltaTime,vect(0,0,0));

        // Update rotation.
        SetRotation(ViewRotation);
        OldRotation = Rotation;
        UpdateRotation(DeltaTime, 1);

        // Update acceleration.
        NewAccel = aForward*Normal(ViewX - OldFloor * (OldFloor Dot ViewX)) + aStrafe*ViewY;
        if ( VSize(NewAccel) < 1.0 )
            NewAccel = vect(0,0,0);

        if ( bPressedJump && Pawn.CannotJumpNow() )
        {
            bSaveJump = true;
            bPressedJump = false;
        }
        else
            bSaveJump = false;

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
        else
            ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
        bPressedJump = bSaveJump;
    }

    function BeginState()
    {
        if ( Pawn.Mesh == None )
            Pawn.SetMesh();
        OldFloor = vect(0,0,1);
        GetAxes(Rotation,ViewX,ViewY,ViewZ);
        DoubleClickDir = DCLICK_None;
        Pawn.ShouldCrouch(false);
        bPressedJump = false;
        if (Pawn.Physics != PHYS_Falling)
            Pawn.SetPhysics(PHYS_Spider);
        GroundPitch = 0;
        Pawn.bCrawler = true;
        Pawn.SetCollisionSize(Pawn.Default.CollisionHeight,Pawn.Default.CollisionHeight);
    }

    function EndState()
    {
        GroundPitch = 0;
        if ( Pawn != None )
        {
            Pawn.SetCollisionSize(Pawn.Default.CollisionRadius,Pawn.Default.CollisionHeight);
            Pawn.ShouldCrouch(false);
            Pawn.bCrawler = Pawn.Default.bCrawler;
        }
    }
}

// Player movement.
// Player Swimming
state PlayerSwimming
{
ignores SeePlayer, HearNoise, Bump;

    function bool WantsSmoothedView()
    {
        return ( !Pawn.bJustLanded );
    }

    function bool NotifyLanded(vector HitNormal)
    {
        if ( Pawn.PhysicsVolume.bWaterVolume )
            Pawn.SetPhysics(PHYS_Swimming);
        else
            GotoState(Pawn.LandMovementState);
        return bUpdating;
    }

    function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
    {
        local actor HitActor;
        local vector HitLocation, HitNormal, checkpoint;

        if ( !NewVolume.bWaterVolume )
        {
            Pawn.SetPhysics(PHYS_Falling);
            if ( (Pawn.Velocity.Z > 0) || Pawn.bWaterStepup )
            {
				if (Pawn.bUpAndOut && Pawn.CheckWaterJump(HitNormal)) //check for waterjump
				{
					Pawn.velocity.Z = FMax(Pawn.JumpZ,420) + 2 * Pawn.CollisionRadius; //set here so physics uses this for remainder of tick
					GotoState(Pawn.LandMovementState);
				}
				else if ( (Pawn.Velocity.Z > 160) || !Pawn.TouchingWaterVolume() )
					GotoState(Pawn.LandMovementState);
				else //check if in deep water
				{
					checkpoint = Pawn.Location;
					checkpoint.Z -= (Pawn.CollisionHeight + 6.0);
					HitActor = Trace(HitLocation, HitNormal, checkpoint, Pawn.Location, false);
					if (HitActor != None)
						GotoState(Pawn.LandMovementState);
					else
					{
						Enable('Timer');
						SetTimer(0.7,false);
					}
				}
			}
        }
        else
        {
            Disable('Timer');
            Pawn.SetPhysics(PHYS_Swimming);
        }
        return false;
    }

    function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
    {
        local vector X,Y,Z, OldAccel;
		local bool bUpAndOut;

        GetAxes(Rotation,X,Y,Z);
        OldAccel = Pawn.Acceleration;
        if ( Pawn.Acceleration != NewAccel )
			Pawn.Acceleration = NewAccel;
        bUpAndOut = ((X Dot Pawn.Acceleration) > 0) && ((Pawn.Acceleration.Z > 0) || (Rotation.Pitch > 2048));
		if ( Pawn.bUpAndOut != bUpAndOut )
			Pawn.bUpAndOut = bUpAndOut;
        if ( !Pawn.PhysicsVolume.bWaterVolume ) //check for waterjump
            NotifyPhysicsVolumeChange(Pawn.PhysicsVolume);
    }

    function PlayerMove(float DeltaTime)
    {
        local rotator oldRotation;
        local vector X,Y,Z, NewAccel;

        GetAxes(Rotation,X,Y,Z);

        NewAccel = aForward*X + aStrafe*Y + aUp*vect(0,0,1);
        if ( VSize(NewAccel) < 1.0 )
            NewAccel = vect(0,0,0);

        //add bobbing when swimming
        Pawn.CheckBob(DeltaTime, Y);

        // Update rotation.
        oldRotation = Rotation;
        UpdateRotation(DeltaTime, 2);

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
        else
            ProcessMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
        bPressedJump = false;
    }

    function Timer()
    {
        if ( !Pawn.PhysicsVolume.bWaterVolume && (Role == ROLE_Authority) )
            GotoState(Pawn.LandMovementState);

        Disable('Timer');
    }

    function BeginState()
    {
        Disable('Timer');
        Pawn.SetPhysics(PHYS_Swimming);
    }
}

state PlayerFlying
{
ignores SeePlayer, HearNoise, Bump;

    function PlayerMove(float DeltaTime)
    {
        local vector X,Y,Z;

        GetAxes(Rotation,X,Y,Z);

        Pawn.Acceleration = aForward*X + aStrafe*Y;
        if ( VSize(Pawn.Acceleration) < 1.0 )
            Pawn.Acceleration = vect(0,0,0);
        if ( bCheatFlying && (Pawn.Acceleration == vect(0,0,0)) )
            Pawn.Velocity = vect(0,0,0);
        // Update rotation.
        UpdateRotation(DeltaTime, 2);

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
        else
            ProcessMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
    }

    function BeginState()
    {
        Pawn.SetPhysics(PHYS_Flying);
    }
}

state PlayerSpaceFlying
{
ignores SeePlayer, HearNoise, Bump;

	function CallServerMove
	(
		float				TimeStamp,
		vector				InAccel,
		vector				ClientLoc,
		bool				NewbRun,
		bool				NewbDuck,
		bool				NewbJumpStatus,
		bool				NewbPendingJumpStatus,
		bool				NewbDoubleJump,
		eDoubleClickDir		DoubleClickMove,
		byte				ClientRoll,
		int					View,
		optional byte		OldTimeDelta,
		optional int		OldAccel
	)
	{
		local Rotator ViewRot;

		if ( Pawn == None )
			ViewRot = Rotation;
		else
			ViewRot = Pawn.Rotation;

		if ( PendingMove != None )
		{
			DualSpaceFighterServerMove
			(
				PendingMove.TimeStamp,
		        PendingMove.Acceleration * 10,
				PendingMove.bDuck,
				PendingMove.Rotation.Pitch,
				PendingMove.Rotation.Yaw,
				PendingMove.Rotation.Roll,
				TimeStamp,
				InAccel,
				ClientLoc,
				NewbDuck,
				ViewRot.Pitch,
				ViewRot.Yaw,
				ViewRot.Roll
			);
		}
		else
			SpaceFighterServerMove
			(
				TimeStamp,
				InAccel,
				ClientLoc,
				NewbDuck,
				ViewRot.Pitch,
				ViewRot.Yaw,
				ViewRot.Roll
			);
	}

	/* ServerMove()
	- replicated function sent by client to server - contains client movement and firing info
	Passes acceleration in components so it doesn't get rounded.
	IGNORE VANILLA SERVER MOVES
	*/
	function ServerMove
	(
		float				TimeStamp,
		vector				InAccel,
		vector				ClientLoc,
		bool				NewbRun,
		bool				NewbDuck,
		bool				NewbJumpStatus,
		bool				NewbDoubleJump,
		eDoubleClickDir		DoubleClickMove,
		byte				ClientRoll,
		int					View,
		optional byte		OldTimeDelta,
		optional int		OldAccel
	)
	{
		// If this move is outdated, discard it.
		if ( CurrentTimeStamp >= TimeStamp )
			return;

		if ( AcknowledgedPawn != Pawn )
		{
			OldTimeDelta = 0;
			InAccel = vect(0,0,0);
		}
		else
			Pawn.AutonomousPhysics(TimeStamp - CurrentTimeStamp);

		CurrentTimeStamp	= TimeStamp;
		ServerTimeStamp		= Level.TimeSeconds;
	}

    function PlayerMove(float DeltaTime)
    {
		if ( Pawn == None )
		{
			GotoState('dead');
			return;
		}

		Pawn.UpdateRocketAcceleration(DeltaTime, aTurn, aLookUp);
		SetRotation( Pawn.Rotation );

		ViewShake( DeltaTime );
        ViewFlash( DeltaTime );

        if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Pawn.Acceleration, DCLICK_None, Pawn.Rotation );
        else
            ProcessMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
    }

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
    {
		if ( Pawn == None )
			return;

        if ( Pawn.Acceleration != NewAccel )
			Pawn.Acceleration = NewAccel;

		if ( DeltaRot != rot(0,0,0) )
		{
			if ( Pawn.Rotation != DeltaRot )
				Pawn.SetRotation( DeltaRot );
			if ( Rotation != DeltaRot )
				SetRotation( DeltaRot );
		}

		Pawn.Velocity = Pawn.Acceleration * Pawn.AirSpeed * 0.001;
		Pawn.ProcessMove(DeltaTime, NewAccel, DoubleClickMove, DeltaRot);
	}

    function BeginState()
    {
		if ( Pawn != None )
			Pawn.SetPhysics( PHYS_Flying );

		RotationRate.Pitch	= 8192; // extending pitch limit

		bIsSpaceFighter = true;
    }

    function EndState()
    {
		RotationRate.Pitch = default.RotationRate.Pitch; // restoring pitch limit
		bIsSpaceFighter = false;
	}
}


state PlayerRocketing
{
ignores SeePlayer, HearNoise, Bump;

	function CallServerMove
	(
		float				TimeStamp,
		vector				InAccel,
		vector				ClientLoc,
		bool				NewbRun,
		bool				NewbDuck,
		bool				NewbJumpStatus,
		bool				NewbPendingJumpStatus,
		bool				NewbDoubleJump,
		eDoubleClickDir		DoubleClickMove,
		byte				ClientRoll,
		int					View,
		optional byte		OldTimeDelta,
		optional int		OldAccel
	)
	{
		if ( PendingMove != None )
		{
			DualRocketServerMove
			(
				PendingMove.TimeStamp,
		        PendingMove.Acceleration * 10,
				PendingMove.bDuck,
		        ((PendingMove.Rotation.Roll >> 8) & 255),
				(32767 & (PendingMove.Rotation.Pitch/2)) * 32768 + (32767 & (PendingMove.Rotation.Yaw/2)),
				TimeStamp,
				InAccel,
				ClientLoc,
				NewbDuck,
				ClientRoll,
				View
			);
		}
		else
			RocketServerMove
			(
				TimeStamp,
				InAccel,
				ClientLoc,
				NewbDuck,
				ClientRoll,
				View
			);
	}

	/* ServerMove()
	- replicated function sent by client to server - contains client movement and firing info
	Passes acceleration in components so it doesn't get rounded.
	IGNORE VANILLA SERVER MOVES
	*/
	function ServerMove
	(
		float				TimeStamp,
		vector				InAccel,
		vector				ClientLoc,
		bool				NewbRun,
		bool				NewbDuck,
		bool				NewbJumpStatus,
		bool				NewbDoubleJump,
		eDoubleClickDir		DoubleClickMove,
		byte				ClientRoll,
		int					View,
		optional byte		OldTimeDelta,
		optional int		OldAccel
	)
	{
		// If this move is outdated, discard it.
		if ( CurrentTimeStamp >= TimeStamp )
			return;

		if ( !CheckSpeedHack(TimeStamp - CurrentTimeStamp) )
		{
			if ( !bWasSpeedHack )
			{
				if ( Level.TimeSeconds - LastSpeedHackLog > 20 )
				{
					log("Possible speed hack by "$PlayerReplicationInfo.PlayerName);
					LastSpeedHackLog = Level.TimeSeconds;
				}
				ClientMessage( "Speed Hack Detected!",'CriticalEvent' );
			}
			else
				bWasSpeedHack = true;
		}
		else
		{
			if ( AcknowledgedPawn != Pawn )
			{
				OldTimeDelta = 0;
				InAccel = vect(0,0,0);
			}
			else
				Pawn.AutonomousPhysics(TimeStamp - CurrentTimeStamp);
		}
		CurrentTimeStamp	= TimeStamp;
		ServerTimeStamp		= Level.TimeSeconds;
	}

	function RocketServerMove
	(
		float	TimeStamp,
		vector	InAccel,
		vector	ClientLoc,
		bool	NewbDuck,
		byte	ClientRoll,
		int		View
	)
	{
		Global.ServerMove(TimeStamp,InAccel,ClientLoc,false,NewbDuck,false,false, DCLICK_NONE,ClientRoll,View);
	}

	function DualRocketServerMove
	(
		float	TimeStamp0,
		vector	InAccel0,
		bool	NewbDuck0,
		byte	ClientRoll0,
		int		View0,
		float	TimeStamp,
		vector	InAccel,
		vector	ClientLoc,
		bool	NewbDuck,
		byte	ClientRoll,
		int		View
	)
	{
		Global.ServerMove(TimeStamp0,InAccel0,vect(0,0,0),false,NewbDuck0,false,false, DCLICK_NONE,ClientRoll0,View0);
		Global.ServerMove(TimeStamp,InAccel,ClientLoc,false,NewbDuck,false,false, DCLICK_NONE,ClientRoll,View);
	}

    function PlayerMove(float DeltaTime)
    {
		Pawn.UpdateRocketAcceleration(DeltaTime,aTurn,aLookUp);
		SetRotation(Pawn.Rotation);

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
        else
            ProcessMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
    }

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
    {
		if ( Pawn == None )
			return;

        if ( Pawn.Acceleration != NewAccel )
			Pawn.Acceleration = NewAccel;
	}

    function BeginState()
    {
		if ( Pawn != None )
			Pawn.SetPhysics( PHYS_Flying );

		RotationRate.Pitch	= 8192; // extending pitch limit (limits network weapon aiming)
    }

    function EndState()
    {
		RotationRate.Pitch = default.RotationRate.Pitch; // restoring pitch limit
	}
}


state PlayerTurreting
{
ignores SeePlayer, HearNoise, Bump;

	function CallServerMove
	(
		float				TimeStamp,
		vector				InAccel,
		vector				ClientLoc,
		bool				NewbRun,
		bool				NewbDuck,
		bool				NewbJumpStatus,
		bool				NewbPendingJumpStatus,
		bool				NewbDoubleJump,
		eDoubleClickDir		DoubleClickMove,
		byte				ClientRoll,
		int					View,
		optional byte		OldTimeDelta,
		optional int		OldAccel
	)
	{

		if ( PendingMove != None )
		{
			DualTurretServerMove
			(
				PendingMove.TimeStamp,
				PendingMove.bDuck,
		        ((PendingMove.Rotation.Roll >> 8) & 255),
				(32767 & (PendingMove.Rotation.Pitch/2)) * 32768 + (32767 & (PendingMove.Rotation.Yaw/2)),
				TimeStamp,
				ClientLoc,
				NewbDuck,
				ClientRoll,
				View
			);
		}
		else
			TurretServerMove
			(
				TimeStamp,
				ClientLoc,
				NewbDuck,
				ClientRoll,
				View
			);
	}

	/* ServerMove()
	- replicated function sent by client to server - contains client movement and firing info
	Passes acceleration in components so it doesn't get rounded.
	IGNORE VANILLA SERVER MOVES
	*/
	function ServerMove
	(
		float				TimeStamp,
		vector				InAccel,
		vector				ClientLoc,
		bool				NewbRun,
		bool				NewbDuck,
		bool				NewbJumpStatus,
		bool				NewbDoubleJump,
		eDoubleClickDir		DoubleClickMove,
		byte				ClientRoll,
		int					View,
		optional byte		OldTimeDelta,
		optional int		OldAccel
	)
	{
		// If this move is outdated, discard it.
		if ( CurrentTimeStamp >= TimeStamp )
			return;

		if ( AcknowledgedPawn != Pawn )
		{
			OldTimeDelta = 0;
			InAccel = vect(0,0,0);
		}

		if ( AcknowledgedPawn == Pawn && CurrentTimeStamp < TimeStamp )
	       Pawn.AutonomousPhysics(TimeStamp - CurrentTimeStamp);
		CurrentTimeStamp = TimeStamp;
		ServerTimeStamp = Level.TimeSeconds;
	}

	function TurretServerMove
	(
		float	TimeStamp,
		vector	ClientLoc,
		bool	NewbDuck,
		byte	ClientRoll,
		int		View
	)
	{
		Global.ServerMove(TimeStamp,Vect(0,0,0),ClientLoc,false,NewbDuck,false,false, DCLICK_NONE,ClientRoll,View);
	}

	/* DualTurretServerMove()
	compressed version of server move for PlayerTurreting state
	*/
	function DualTurretServerMove
	(
		float	TimeStamp0,
		bool	NewbDuck0,
		byte	ClientRoll0,
		int		View0,
		float	TimeStamp,
		vector	ClientLoc,
		bool	NewbDuck,
		byte	ClientRoll,
		int		View
	)
	{
		Global.ServerMove(TimeStamp0,Vect(0,0,0),vect(0,0,0),false,NewbDuck0,false,false, DCLICK_NONE,ClientRoll0,View0);
		Global.ServerMove(TimeStamp,Vect(0,0,0),ClientLoc,false,NewbDuck,false,false, DCLICK_NONE,ClientRoll,View);
	}

    function PlayerMove(float DeltaTime)
    {
        local Vehicle CurrentVehicle;

		if ( Pawn == None )
		{
			GotoState('dead');
			return;
		}

		Pawn.UpdateRocketAcceleration(DeltaTime, aTurn, aLookUp);
		if ( !bFreeCamera )
			SetRotation( Pawn.Rotation );

		ViewShake( deltaTime );
        ViewFlash( deltaTime );

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
        else
            ProcessMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));

		CurrentVehicle = Vehicle(Pawn);
		if ( CurrentVehicle != None )
		{
			if ( bFire == 0 && CurrentVehicle.bWeaponIsFiring )
				CurrentVehicle.ClientVehicleCeaseFire( false );

			if ( bAltFire == 0 && CurrentVehicle.bWeaponIsAltFiring )
				CurrentVehicle.ClientVehicleCeaseFire( true );
		}
    }

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
    {
		if ( Pawn == None )
			return;

		Pawn.Acceleration = newAccel;
	}

    function BeginState()
    {
		if ( Pawn != None )
			Pawn.SetPhysics( PHYS_Flying );

		RotationRate.Pitch	= 16384; // extending pitch limit (limits network weapon aiming)
    }

    function EndState()
    {
		RotationRate.Pitch = default.RotationRate.Pitch; // restoring pitch limit
	}

Begin:
}

function bool IsSpectating()
{
	return false;
}

state BaseSpectating
{
	function bool IsSpectating()
	{
		return true;
	}

    function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
    {
        Acceleration = NewAccel;
        MoveSmooth(SpectateSpeed * Normal(Acceleration) * DeltaTime);
    }

    function PlayerMove(float DeltaTime)
    {
        local vector X,Y,Z;

		if ( (Pawn(ViewTarget) != None) && (Level.NetMode == NM_Client) )
		{
			if ( Pawn(ViewTarget).bSimulateGravity )
				TargetViewRotation.Roll = 0;
			BlendedTargetViewRotation.Pitch = BlendRot(DeltaTime, BlendedTargetViewRotation.Pitch, TargetViewRotation.Pitch & 65535);
			BlendedTargetViewRotation.Yaw = BlendRot(DeltaTime, BlendedTargetViewRotation.Yaw, TargetViewRotation.Yaw & 65535);
			BlendedTargetViewRotation.Roll = BlendRot(DeltaTime, BlendedTargetViewRotation.Roll, TargetViewRotation.Roll & 65535);
		}
        GetAxes(Rotation,X,Y,Z);

        Acceleration = 0.02 * (aForward*X + aStrafe*Y + aUp*vect(0,0,1));

        UpdateRotation(DeltaTime, 1);

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
        else
            ProcessMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
    }
}

state Scripting
{
    // FIXME - IF HIT FIRE, AND NOT bInterpolating, Leave script
    exec function Fire( optional float F )
    {
    }

    exec function AltFire( optional float F )
    {
        Fire(F);
    }
}

function ServerViewNextPlayer()
{
    local Controller C, Pick;
    local bool bFound, bRealSpec, bWasSpec;
	local TeamInfo RealTeam;

    bRealSpec = PlayerReplicationInfo.bOnlySpectator;
    bWasSpec = !bBehindView && (ViewTarget != Pawn) && (ViewTarget != self);
    PlayerReplicationInfo.bOnlySpectator = true;
    RealTeam = PlayerReplicationInfo.Team;

    // view next player
    for ( C=Level.ControllerList; C!=None; C=C.NextController )
    {
		if ( bRealSpec && (C.PlayerReplicationInfo != None) ) // hack fix for invasion spectating
			PlayerReplicationInfo.Team = C.PlayerReplicationInfo.Team;
        if ( Level.Game.CanSpectate(self,bRealSpec,C) )
        {
            if ( Pick == None )
                Pick = C;
            if ( bFound )
            {
                Pick = C;
                break;
            }
            else
                bFound = ( (RealViewTarget == C) || (ViewTarget == C) );
        }
    }
    PlayerReplicationInfo.Team = RealTeam;
    SetViewTarget(Pick);
    ClientSetViewTarget(Pick);
    if ( (ViewTarget == self) || bWasSpec )
        bBehindView = false;
    else
        bBehindView = true; //bChaseCam;
    ClientSetBehindView(bBehindView);
    PlayerReplicationInfo.bOnlySpectator = bRealSpec;
}

function ServerViewSelf()
{

	SetLocation(ViewTarget.Location);
	ClientSetLocation(ViewTarget.Location, Rotation);

    bBehindView = false;
    SetViewTarget(self);
    ClientSetViewTarget(self);
    ClientMessage(OwnCamera, 'Event');
}

function LoadPlayers()
{
	local int i;

	if ( GameReplicationInfo == None )
		return;

	for ( i=0; i<GameReplicationInfo.PRIArray.Length; i++ )
		GameReplicationInfo.PRIArray[i].UpdatePrecacheMaterials();
}

function ServerSpectate()
{
	// Proper fix for phantom pawns

	if (Pawn != none && !Pawn.bDeleteMe)
	{
		Pawn.Died(self, class'DamageType', Pawn.Location);
	}

	GotoState('Spectating');
	bBehindView = true;
	ServerViewNextPlayer();
}

//active player wants to become a spectator
function BecomeSpectator()
{
	if (Role < ROLE_Authority)
		return;

	if ( !Level.Game.BecomeSpectator(self) )
		return;

	if ( Pawn != None )
		Pawn.Died(self, class'DamageType', Pawn.Location);

	if ( PlayerReplicationInfo.Team != None )
		PlayerReplicationInfo.Team.RemoveFromTeam(self);
	PlayerReplicationInfo.Team = None;
	PlayerReplicationInfo.Score = 0;
	PlayerReplicationInfo.Deaths = 0;
	PlayerReplicationInfo.GoalsScored = 0;
	PlayerReplicationInfo.Kills = 0;
	ServerSpectate();
	BroadcastLocalizedMessage(Level.Game.GameMessageClass, 14, PlayerReplicationInfo);

	ClientBecameSpectator();
}

function ClientBecameSpectator()
{
	UpdateURL("SpectatorOnly", "1", true);
}

//spectating player wants to become active and join the game
function BecomeActivePlayer()
{
	if (Role < ROLE_Authority)
		return;

	if ( !Level.Game.AllowBecomeActivePlayer(self) )
		return;

	bBehindView = false;
	FixFOV();
	ServerViewSelf();
	PlayerReplicationInfo.bOnlySpectator = false;
	Level.Game.NumSpectators--;
	Level.Game.NumPlayers++;
	if (Level.Game.GameStats != None)
	{
		Level.Game.GameStats.ConnectEvent(PlayerReplicationInfo);
	}
	PlayerReplicationInfo.Reset();
	Adrenaline = 0;
	BroadcastLocalizedMessage(Level.Game.GameMessageClass, 1, PlayerReplicationInfo);
	if (Level.Game.bTeamGame)
		Level.Game.ChangeTeam(self, Level.Game.PickTeam(int(GetURLOption("Team")), None), false);
	if (!Level.Game.bDelayedStart)
    {
		// start match, or let player enter, immediately
		Level.Game.bRestartLevel = false;  // let player spawn once in levels that must be restarted after every death
		if (Level.Game.bWaitingToStartMatch)
			Level.Game.StartMatch();
		else
			Level.Game.RestartPlayer(PlayerController(Owner));
		Level.Game.bRestartLevel = Level.Game.Default.bRestartLevel;
    }
    else
        GotoState('PlayerWaiting');

    ClientBecameActivePlayer();
}

function ClientBecameActivePlayer()
{
	UpdateURL("SpectatorOnly","",true);
}

state Spectating extends BaseSpectating
{
    ignores SwitchWeapon, RestartLevel, ClientRestart, Suicide,
     ThrowWeapon, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange;

    exec function Fire( optional float F )
    {
    	if ( bFrozen )
	{
		if ( (TimerRate <= 0.0) || (TimerRate > 1.0) )
			bFrozen = false;
		return;
	}

        ServerViewNextPlayer();
    }

    // Return to spectator's own camera.
    exec function AltFire( optional float F )
    {
        bBehindView = false;
        ServerViewSelf();
    }

    function Timer()
    {
    	bFrozen = false;
    }

    function BeginState()
    {
        if ( Pawn != None )
        {
            SetLocation(Pawn.Location);
            UnPossess();
        }
        bCollideWorld = true;
		CameraDist = Default.CameraDist;
    }

    function EndState()
    {
        PlayerReplicationInfo.bIsSpectator = false;
        bCollideWorld = false;
    }
}

state AttractMode extends Spectating
{
}

auto state PlayerWaiting extends BaseSpectating
{
ignores SeePlayer, HearNoise, NotifyBump, TakeDamage, PhysicsVolumeChange, NextWeapon, PrevWeapon, SwitchToBestWeapon;

    exec function Jump( optional float F )
    {
    }

    exec function Suicide()
    {
    }

    function ServerRestartPlayer()
    {
        if ( Level.TimeSeconds < WaitDelay )
            return;
        if ( Level.NetMode == NM_Client )
            return;
        if ( Level.Game.bWaitingToStartMatch )
            PlayerReplicationInfo.bReadyToPlay = true;
        else
            Level.Game.RestartPlayer(self);
        }

    exec function Fire(optional float F)
    {
        LoadPlayers();
        if ( !bForcePrecache && (Level.TimeSeconds > 0.2) )
			ServerReStartPlayer();
    }

    exec function AltFire(optional float F)
    {
        Fire(F);
    }

    function EndState()
    {
        if ( Pawn != None )
            Pawn.SetMesh();
        if ( PlayerReplicationInfo != None )
			PlayerReplicationInfo.SetWaitingPlayer(false);
        bCollideWorld = false;
    }

    function BeginState()
    {
		CameraDist = Default.CameraDist;
        if ( PlayerReplicationInfo != None )
            PlayerReplicationInfo.SetWaitingPlayer(true);
        bCollideWorld = true;
    }
}

state WaitingForPawn extends BaseSpectating
{
ignores SeePlayer, HearNoise, KilledBy, SwitchWeapon;

    exec function Fire( optional float F )
    {
		AskForPawn();
    }

    exec function AltFire( optional float F )
    {
    }

    function LongClientAdjustPosition
    (
        float TimeStamp,
        name newState,
        EPhysics newPhysics,
        float NewLocX,
        float NewLocY,
        float NewLocZ,
        float NewVelX,
        float NewVelY,
        float NewVelZ,
        Actor NewBase,
        float NewFloorX,
        float NewFloorY,
        float NewFloorZ
    )
    {
		if ( newState == 'GameEnded' || newState == 'RoundEnded' )
			GotoState(newState);
    }

    function PlayerTick(float DeltaTime)
    {
        Global.PlayerTick(DeltaTime);

        if ( Pawn != None )
        {
            Pawn.Controller = self;
            Pawn.bUpdateEyeHeight = true;
            //log("Client restart in waitingforpawn");
            ClientRestart(Pawn);
        }
        else if ( (TimerRate <= 0.0) || (TimerRate > 1.0) )
		{
			SetTimer(0.2,true);
			AskForPawn();
		}
    }

    function Timer()
    {
        AskForPawn();
    }

    function BeginState()
    {
        SetTimer(0.2, true);
        AskForPawn();
    }

    function EndState()
    {
		bBehindView = false;
        SetTimer(0.0, false);
    }
}

state GameEnded
{
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyHeadVolumeChange, NotifyPhysicsVolumeChange, Falling, TakeDamage, Suicide;

	function ServerReStartPlayer()
	{
	}

	function bool IsSpectating()
	{
		return true;
	}

	exec function Use() {}
	exec function SwitchWeapon(byte T) {}
	exec function ThrowWeapon() {}

	function Possess(Pawn aPawn)
	{
		Global.Possess(aPawn);

		if (Pawn != None)
			Pawn.TurnOff();
	}

    function ServerReStartGame()
    {
		if ( Level.Game.PlayerCanRestartGame( Self ) )
			Level.Game.RestartGame();
    }

    exec function Fire( optional float F )
    {
        if ( Role < ROLE_Authority)
            return;
        if ( !bFrozen )
            ServerReStartGame();
        else if ( TimerRate <= 0 )
            SetTimer(1.5, false);
    }

    exec function AltFire( optional float F )
    {
        Fire(F);
    }

    function PlayerMove(float DeltaTime)
    {
        local vector X,Y,Z;
        local Rotator ViewRotation;

        GetAxes(Rotation,X,Y,Z);
        // Update view rotation.

        if ( !bFixedCamera )
        {
            ViewRotation = Rotation;
            ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
            ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
            if (Pawn != None)
	            ViewRotation.Pitch = Pawn.LimitPitch(ViewRotation.Pitch);
            SetRotation(ViewRotation);
        }
        else if ( ViewTarget != None )
            SetRotation(ViewTarget.Rotation);

        ViewShake(DeltaTime);
        ViewFlash(DeltaTime);

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
        else
            ProcessMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
        bPressedJump = false;
    }

    function ServerMove
    (
        float TimeStamp,
        vector InAccel,
        vector ClientLoc,
        bool NewbRun,
        bool NewbDuck,
        bool NewbJumpStatus,
        bool NewbDoubleJump,
        eDoubleClickDir DoubleClickMove,
        byte ClientRoll,
        int View,
        optional byte OldTimeDelta,
        optional int OldAccel
    )
    {
        Global.ServerMove(TimeStamp, InAccel, ClientLoc, NewbRun, NewbDuck, NewbJumpStatus,NewbDoubleJump,
                            DoubleClickMove, ClientRoll, (32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2)) );

    }

    function FindGoodView()
    {
        local vector cameraLoc;
        local rotator cameraRot, ViewRotation;
        local int tries, besttry;
        local float bestdist, newdist;
        local int startYaw;
        local actor ViewActor;

        ViewRotation = Rotation;
        ViewRotation.Pitch = 56000;
        tries = 0;
        besttry = 0;
        bestdist = 0.0;
        startYaw = ViewRotation.Yaw;

        for (tries=0; tries<16; tries++)
        {
            cameraLoc = ViewTarget.Location;
			SetRotation(ViewRotation);
            PlayerCalcView(ViewActor, cameraLoc, cameraRot);
            newdist = VSize(cameraLoc - ViewTarget.Location);
            if (newdist > bestdist)
            {
                bestdist = newdist;
                besttry = tries;
            }
            ViewRotation.Yaw += 4096;
        }

        ViewRotation.Yaw = startYaw + besttry * 4096;
        SetRotation(ViewRotation);
    }

    function Timer()
    {
        bFrozen = false;
    }

    function LongClientAdjustPosition
    (
        float TimeStamp,
        name newState,
        EPhysics newPhysics,
        float NewLocX,
        float NewLocY,
        float NewLocZ,
        float NewVelX,
        float NewVelY,
        float NewVelZ,
        Actor NewBase,
        float NewFloorX,
        float NewFloorY,
        float NewFloorZ
    )
    {
    }

    function BeginState()
    {
        local Pawn P;

        EndZoom();
		StopForceFeedback();
		CameraDist = Default.CameraDist;
        FOVAngle = DesiredFOV;
        bFire = 0;
        bAltFire = 0;
        if ( Pawn != None )
        {
       	    if ( Vehicle(Pawn) != None )
	    	Pawn.StopWeaponFiring();
			Pawn.TurnOff();
			Pawn.bSpecialHUD = false;
            Pawn.SimAnim.AnimRate = 0;
            if ( Pawn.Weapon != None )
            {
				Pawn.Weapon.StopFire(0);
				Pawn.Weapon.StopFire(1);
				Pawn.Weapon.bEndOfRound = true;
			}
        }
        bFrozen = true;
        if ( !bFixedCamera )
        {
            FindGoodView();
            bBehindView = true;
        }
        SetTimer(5, false);
        ForEach DynamicActors(class'Pawn', P)
        {
			if ( P.Role == ROLE_Authority )
				P.RemoteRole = ROLE_DumbProxy;
			P.TurnOff();
        }
    }

Begin:
}


state RoundEnded
{
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyHeadVolumeChange, NotifyPhysicsVolumeChange, Falling, TakeDamage, Suicide;

	function ServerReStartPlayer()
	{
	}

	function bool IsSpectating() {	return true; }

    exec function Use() {}
    exec function SwitchWeapon(byte T) {}
    exec function ThrowWeapon() {}
    exec function Fire(optional float F) {}
    exec function AltFire(optional float F) {}

    function Possess(Pawn aPawn)
    {
    	Global.Possess(aPawn);

    	if (Pawn != None)
    		Pawn.TurnOff();
    }

    function PlayerMove(float DeltaTime)
    {
        local vector X,Y,Z;
        local Rotator ViewRotation;

        GetAxes(Rotation,X,Y,Z);
        // Update view rotation.

        if ( !bFixedCamera )
        {
            ViewRotation = Rotation;
            ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
            ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
            if (Pawn != None)
	            ViewRotation.Pitch = Pawn.LimitPitch(ViewRotation.Pitch);
            SetRotation(ViewRotation);
        }
        else if ( ViewTarget != None )
            SetRotation( ViewTarget.Rotation );

        ViewShake( DeltaTime );
        ViewFlash( DeltaTime );

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
        else
            ProcessMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
        bPressedJump = false;
    }

    function ServerMove
    (
        float TimeStamp,
        vector InAccel,
        vector ClientLoc,
        bool NewbRun,
        bool NewbDuck,
        bool NewbJumpStatus,
        bool NewbDoubleJump,
        eDoubleClickDir DoubleClickMove,
        byte ClientRoll,
        int View,
        optional byte OldTimeDelta,
        optional int OldAccel
    )
    {
        Global.ServerMove(TimeStamp, InAccel, ClientLoc, NewbRun, NewbDuck, NewbJumpStatus,NewbDoubleJump,
                            DoubleClickMove, ClientRoll, (32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2)) );

    }

    function FindGoodView()
    {
        local vector	cameraLoc;
        local rotator	cameraRot, ViewRotation;
        local int		tries, besttry;
        local float		bestdist, newdist;
        local int		startYaw;
        local actor		ViewActor;

        ViewRotation = Rotation;
        ViewRotation.Pitch = 56000;
        tries = 0;
        besttry = 0;
        bestdist = 0.0;
        startYaw = ViewRotation.Yaw;

        for (tries=0; tries<16; tries++)
        {
            cameraLoc = ViewTarget.Location;
			SetRotation(ViewRotation);
            PlayerCalcView(ViewActor, cameraLoc, cameraRot);
            newdist = VSize(cameraLoc - ViewTarget.Location);
            if ( newdist > bestdist )
            {
                bestdist = newdist;
                besttry = tries;
            }
            ViewRotation.Yaw += 4096;
        }

        ViewRotation.Yaw = startYaw + besttry * 4096;
        SetRotation(ViewRotation);
    }

    function Timer()
    {
        bFrozen = false;
    }

    function LongClientAdjustPosition
    (
        float TimeStamp,
        name newState,
        EPhysics newPhysics,
        float NewLocX,
        float NewLocY,
        float NewLocZ,
        float NewVelX,
        float NewVelY,
        float NewVelZ,
        Actor NewBase,
        float NewFloorX,
        float NewFloorY,
        float NewFloorZ
    )
    {
		if ( newState == 'PlayerWaiting' )
			GotoState( newState );
    }

    function BeginState()
    {
        local Pawn P;

        EndZoom();
		CameraDist = Default.CameraDist;
        FOVAngle = DesiredFOV;
        bFire = 0;
        bAltFire = 0;

        if ( Pawn != None )
        {
       	    if ( Vehicle(Pawn) != None )
	    		Pawn.StopWeaponFiring();

			Pawn.TurnOff();
			Pawn.bSpecialHUD = false;
            Pawn.SimAnim.AnimRate = 0;
            if ( Pawn.Weapon != None )
			{
				Pawn.Weapon.StopFire(0);
				Pawn.Weapon.StopFire(1);
				Pawn.Weapon.bEndOfRound = true;
			}
        }

        bFrozen = true;
		bBehindView = true;
        if ( !bFixedCamera )
            FindGoodView();

        SetTimer(5, false);
        ForEach DynamicActors(class'Pawn', P)
        {
			if ( P.Role == ROLE_Authority )
				P.RemoteRole = ROLE_DumbProxy;
			P.TurnOff();
        }
		StopForceFeedback();
    }

	function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
	{
		local vector	View;
		local float		ViewDist,RealDist;
		local vector	globalX,globalY,globalZ;
		local vector	localX,localY,localZ;
		local vector	HitLocation,HitNormal;
		local Actor		HitActor;

		CameraRotation = Rotation;
		CameraRotation.Roll = 0;
		CameraLocation.Z += 12;

		// add view rotation offset to cameraview (amb)
		CameraRotation += CameraDeltaRotation;

		View = vect(1,0,0) >> CameraRotation;

		// add view radius offset to camera location and move viewpoint up from origin (amb)
		RealDist = Dist;
		Dist += CameraDeltaRad;

		HitActor = Trace( HitLocation, HitNormal, CameraLocation - Dist * vector(CameraRotation), CameraLocation,false,vect(10,10,10));
		if ( HitActor != None && !HitActor.IsA('BlockingVolume') )
			ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
		else
			ViewDist = Dist;

		if ( !bBlockCloseCamera || !bValidBehindCamera || (ViewDist > 10 + FMax(ViewTarget.CollisionRadius, ViewTarget.CollisionHeight)) )
		{
			//Log("Update Cam ");
			bValidBehindCamera = true;
			OldCameraLoc = CameraLocation - ViewDist * View;
			OldCameraRot = CameraRotation;
		}
		else
		{
			//Log("Dont Update Cam "$bBlockCloseCamera@bValidBehindCamera@ViewDist);
			SetRotation(OldCameraRot);
		}

		CameraLocation = OldCameraLoc;
		CameraRotation = OldCameraRot;

		// add view swivel rotation to cameraview (amb)
		GetAxes(CameraSwivel,globalX,globalY,globalZ);
		localX = globalX >> CameraRotation;
		localY = globalY >> CameraRotation;
		localZ = globalZ >> CameraRotation;
		CameraRotation = OrthoRotation(localX,localY,localZ);
	}

Begin:
}

state Dead
{
ignores SeePlayer, HearNoise, KilledBy, SwitchWeapon, NextWeapon, PrevWeapon;

	exec function ThrowWeapon()
	{
		//clientmessage("Throwweapon while dead, pawn "$Pawn$" health "$Pawn.health);
	}

	function bool IsDead()
	{
		return true;
	}

	function ServerReStartPlayer()
	{
		if ( !Level.Game.PlayerCanRestart( Self ) )
			return;

		super.ServerRestartPlayer();
	}

    exec function Fire( optional float F )
    {
		if ( bFrozen )
		{
			if ( (TimerRate <= 0.0) || (TimerRate > 1.0) )
				bFrozen = false;
			return;
		}

        LoadPlayers();

        if (bMenuBeforeRespawn)
        {
        	bMenuBeforeRespawn = false;
       		ShowMidGameMenu(false);
        }
        else
	        ServerReStartPlayer();
    }

    exec function AltFire( optional float F )
    {
    	Fire(F);
    }

    exec function Use()
    {
		if ( bFrozen )
		{
			if ( (TimerRate <= 0.0) || (TimerRate > 1.0) )
				bFrozen = false;
			return;
		}
		if ( Level.Game != None )
			Level.Game.DeadUse(self);
    }

    function ServerMove
    (
        float TimeStamp,
        vector Accel,
        vector ClientLoc,
        bool NewbRun,
        bool NewbDuck,
        bool NewbJumpStatus,
        bool NewbDoubleJump,
        eDoubleClickDir DoubleClickMove,
        byte ClientRoll,
        int View,
        optional byte OldTimeDelta,
        optional int OldAccel
    )
    {
        Global.ServerMove(
                    TimeStamp,
                    Accel,
                    ClientLoc,
                    false,
                    false,
                    false,
                    false,
                    DoubleClickMove,
                    ClientRoll,
                    View);
    }

    function PlayerMove(float DeltaTime)
    {
        local vector X,Y,Z;
        local rotator ViewRotation;

        if ( !bFrozen )
        {
            if ( bPressedJump )
            {
                Fire(0);
                bPressedJump = false;
            }
            GetAxes(Rotation,X,Y,Z);
            // Update view rotation.
            ViewRotation = Rotation;
            ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
            ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
            if (Pawn != None)
	            ViewRotation.Pitch = Pawn.LimitPitch(ViewRotation.Pitch);
            SetRotation(ViewRotation);
            if ( Role < ROLE_Authority ) // then save this move and replicate it
                ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
        }
        else if ( (TimerRate <= 0.0) || (TimerRate > 1.0) )
			bFrozen = false;

        ViewShake(DeltaTime);
        ViewFlash(DeltaTime);
    }

    function FindGoodView()
    {
        local vector cameraLoc;
        local rotator cameraRot, ViewRotation;
        local int tries, besttry;
        local float bestdist, newdist;
        local int startYaw;
        local actor ViewActor;

        ////log("Find good death scene view");
        ViewRotation = Rotation;
        ViewRotation.Pitch = 56000;
        tries = 0;
        besttry = 0;
        bestdist = 0.0;
        startYaw = ViewRotation.Yaw;

        for (tries=0; tries<16; tries++)
        {
            cameraLoc = ViewTarget.Location;
			SetRotation(ViewRotation);
            PlayerCalcView(ViewActor, cameraLoc, cameraRot);
            newdist = VSize(cameraLoc - ViewTarget.Location);
            if (newdist > bestdist)
            {
                bestdist = newdist;
                besttry = tries;
            }
            ViewRotation.Yaw += 4096;
        }

        ViewRotation.Yaw = startYaw + besttry * 4096;
        SetRotation(ViewRotation);
    }

    function Timer()
    {
        if (!bFrozen)
            return;

        bFrozen = false;
        bPressedJump = false;
    }

    function BeginState()
    {
		local Actor A;

		if ( (Pawn != None) && ((Pawn.Controller == self) || (Pawn.Controller == None)) )
			Pawn.Controller = None;
		EndZoom();
		CameraDist = Default.CameraDist;
		FOVAngle = DesiredFOV;
		Pawn = None;
        Enemy = None;
        bBehindView = true;
        bFrozen = true;
		bJumpStatus = false;
        bPressedJump = false;
        bBlockCloseCamera = true;
		bValidBehindCamera = false;
		bFreeCamera = False;
		if ( Viewport(Player) != None )
			ForEach DynamicActors(class'Actor',A)
				A.NotifyLocalPlayerDead(self);
        FindGoodView();
        SetTimer(1.0, false);
		StopForceFeedback();
		ClientPlayForceFeedback("Damage");  // jdf
		CleanOutSavedMoves();
    }

    function EndState()
    {
		StopForceFeedback();
		bBlockCloseCamera = false;
		CleanOutSavedMoves();
        Velocity = vect(0,0,0);
        Acceleration = vect(0,0,0);
        if ( !PlayerReplicationInfo.bOutOfLives )
			bBehindView = false;
        bPressedJump = false;
        if ( myHUD != None )
			myHUD.bShowScoreBoard = false;

		StopViewShaking();
    }

Begin:
    Sleep(3.0);
    if ( myHUD != None )
	    myHUD.bShowScoreBoard = true;
}

//------------------------------------------------------------------------------
// Control options
function ChangeStairLook( bool B )
{
    bLookUpStairs = B;
    if ( bLookUpStairs )
        bAlwaysMouseLook = false;
}

function ChangeAlwaysMouseLook(Bool B)
{
    bAlwaysMouseLook = B;
    if ( bAlwaysMouseLook )
        bLookUpStairs = false;
}

singular event UnPressButtons()
{
	bFire = 0;
	bAltFire = 0;
	bDuck = 0;
	bRun = 0;
	bVoiceTalk = 0;
	ResetInput();
}

// Replace with good code
event ClientOpenMenu (string Menu, optional bool bDisconnect,optional string Msg1, optional string Msg2)
{
	// GUIController calls UnpressButtons() after it's been activated...once active, it swallows
	// all input events, preventing GameEngine from parsing script execs commands -- rjp
	if ( !Player.GUIController.OpenMenu(Menu, Msg1, Msg2) )
		UnPressButtons();

	if (bDisconnect)
	{
		// Use delayed console command, in case the menu that was opened had bDisconnectOnOpen=True -- rjp
		if ( Player.Console != None )
			Player.Console.DelayedConsoleCommand("DISCONNECT");
		else ConsoleCommand("Disconnect");
	}
}

event ClientReplaceMenu(string Menu, optional bool bDisconnect,optional string Msg1, optional string Msg2)
{
	if ( !Player.GUIController.bActive )
	{
		if ( !Player.GUIController.ReplaceMenu(Menu,Msg1,Msg2) )
			UnpressButtons();
	}
	else Player.GUIController.ReplaceMenu(Menu,Msg1,Msg2);

	if (bDisconnect)
	{
		if ( Player.Console != None )
			Player.Console.DelayedConsoleCommand("Disconnect");
		else ConsoleCommand("Disconnect");
	}
}

event ClientCloseMenu(optional bool bCloseAll, optional bool bCancel)
{
	if (bCloseAll)
		Player.GUIController.CloseAll(bCancel,True);
	else
		Player.GUIController.CloseMenu(bCancel);
}

event ClientNetworkMessage(string ParamA, string ParamB)
{
	ClientOpenMenu(Player.GUIController.NetworkMsgMenu, true, ParamA, ParamB);
}

simulated function bool IsMouseInverted()
{
	return PlayerInput.bInvertMouse;
}

exec function InvertMouse(optional string Invert)
{
	PlayerInput.InvertMouse(Invert);
}

exec function InvertLook()
{
    local bool result;

    result = PlayerInput.InvertLook();

    if (IsOnConsole())
    {
        class'XBoxPlayerInput'.default.bInvertVLook = result;
        class'XBoxPlayerInput'.static.StaticSaveConfig();
    }
}

function bool CanRestartPlayer()
{
    return !PlayerReplicationInfo.bOnlySpectator;
}

/////////////////////////////////////////////////////////////////////////////
// Admin Handling : Was previously in Admin.uc
//
//
//

// Execute an administrative console command on the server.
exec function Admin( string CommandLine )
{
	local string Result;

	if (AdminManager != None)
	{
		if ( Level.Game.AccessControl == None || !Level.Game.AccessControl.CanPerform(Self, "Xc") )
        	return;

		Result = ConsoleCommand( CommandLine );
		if (Level.Game.AccessControl.bReplyToGUI)
			AdminReply(Result);
		else if( Result != "" )
			ClientMessage( Result );
	}
}

exec function AdminDebug( string CommandLine )
{
	if ( AdminManager != None )
	{
		if ( Level.Game.AccessControl == None || !Level.Game.AccessControl.CanPerform(Self, "Xc") )
			return;

		ConsoleCommand(CommandLine, True);
	}
}

exec function AdminLogin(string CmdLine)
{
	if ( Level.TimeSeconds < NextLoginTime )
		return;

	NextLoginTime = Level.TimeSeconds + LoginDelay;
	ServerAdminLogin(CmdLine);
}

function ServerAdminLogin( string CmdLine )
{
	local string uname, upass;

	if (AdminManager == None)
	{
		MakeAdmin();
		if ( AdminManager != None )
		{
			if ( !Divide(CmdLine, " ", uname, upass) )
				upass = CmdLine;

			AdminManager.DoLogin(uname, upass);
			if ( !AdminManager.bAdmin )
				AdminManager = None;
			else AddCheats();
		}
	}
}

function AdminCommand( string CommandLine )
{
	if (Left(CommandLine, 11) ~= "AdminLogin ")
	{
		AdminLogin(Mid(CommandLine, 11));
		ReportAdmin("adv="$Level.Game.AccessControl.IsA('AccessControlIni'));
	}
	else if (Left(CommandLine, 11) ~= "AdminLogout")
	{
		AdminLogout();
		ReportAdmin();
	}
	else if (Level.Game.AccessControl != None)
	{
		Level.Game.AccessControl.bReplyToGUI = true;
		Admin(CommandLine);
		Level.Game.AccessControl.bReplyToGUI = false;
	}
}

function ReportAdmin(optional string ReportText)
{
	local string str;

	if (AdminManager != None && AdminManager.bAdmin)
	{
		if (Level.Game.AccessControl != None)
		{
			str = "name=" $ Level.Game.AccessControl.GetAdminName(Self);
			if ( ReportText != "" )
				str $= ";" $ ReportText;
		}
		else
		{
			str = "name=Admin";
			if ( ReportText != "" )
				str $= ";" $ ReportText;
		}
	}
	else str = ReportText;
	AdminReply(str);
}

function AdminReply( string Reply )
{
	if (Player.GUIController != None)
		Player.GUIController.OnAdminReply(Reply);
}

exec function AdminLogout()
{
  if (AdminManager != None)
  {
	AdminManager.DoLogout();
	if (!AdminManager.bAdmin)
		AdminManager = None;
  }
}

exec function AdminGUI()
{
}

/////////////////////////////////////////////////////////////////////////////
//
// Demo Recording
//
//


// Called on the client during client-side demo recording
simulated event StartClientDemoRec()
{
	// Here we replicate functions which the demo never saw.
	DemoClientSetHUD( MyHud.Class, MyHud.ScoreBoard.Class );

	// tell server to replicate more stuff to me
	bClientDemo = true;
	ServerSetClientDemo();
}

function ServerSetClientDemo()
{
	bClientDemo = true;
}

// Called on the playback client during client-side demo playback
simulated function DemoClientSetHUD(class<HUD> newHUDClass, class<Scoreboard> newScoringClass )
{
	if( MyHUD == None )
		ClientSetHUD( newHUDClass, newScoringClass );
}

simulated function string GetCustomStatusAnnouncerClass() { return ""; }
simulated function string GetCustomRewardAnnouncerClass() { return ""; }
simulated function SetCustomStatusAnnouncerClass(string NewAnnouncerClass);
simulated function SetCustomRewardAnnouncerClass(string NewAnnouncerClass);

simulated function bool NeedNetNotify()
{
	return false;
}

/////////////////////////////////////////////////////////////////////////////
//
// Voice Recognition
//
//

event VoiceCommand( string RecognizedString, string RawString )
{
	log(RecognizedString);
	TeamMessage( PlayerReplicationInfo, RawString, 'TeamSayQuiet' );
	if ( RecognizedString != "" )
		ServerVoiceCommand(RecognizedString);
}

exec function command(string RecognizedString)
{
	Level.Game.ParseVoiceCommand( self, RecognizedString );
}

function ServerVoiceCommand(string RecognizedString)
{
	Level.Game.ParseVoiceCommand( self, RecognizedString );
}

// =====================================================================================================================
// =====================================================================================================================
//  Voice Chat
// =====================================================================================================================
// =====================================================================================================================

// Join a voice chatroom by name
exec function Join(string ChanName, string ChanPwd)
{
	local int i, idx;
	local VoiceChatRoom VCR;

	if (VoiceReplicationInfo == None || !VoiceReplicationInfo.bEnableVoiceChat )
		return;

	for (i = 0; i < StoredChatPasswords.Length; i++)
	{
		if (ChanName ~= StoredChatPasswords[i].ChatRoomName)
		{
			if ( ChanPwd == "" )
				ChanPwd = StoredChatPasswords[i].ChatRoomPassword;

			else
			{
				StoredChatPasswords[i].ChatRoomPassword = ChanPwd;
				SaveConfig();
			}

			break;
		}
	}

	if ( i == StoredChatPasswords.Length && ChanPwd != "" )
	{
		StoredChatPasswords.Length = i + 1;
		StoredChatPasswords[i].ChatRoomName = ChanName;
		StoredChatPasswords[i].ChatRoomPassword = ChanPwd;
		SaveConfig();
	}

	log("Join "$ChanName@"Password:"$ChanPwd@"PRI:"$PlayerReplicationInfo.PlayerName@"Team:"$PlayerReplicationInfo.Team,'VoiceChat');
	if (PlayerReplicationInfo != None && PlayerReplicationInfo.Team != None)
		idx = PlayerReplicationInfo.Team.TeamIndex;

	VCR = VoiceReplicationInfo.GetChannel(ChanName, idx);
	if (VCR != None)
	{
		if (!VCR.IsMember(PlayerReplicationInfo))
			ServerJoinVoiceChannel(VCR.ChannelIndex, ChanPwd);
	}
	else if ( ChatRoomMessageClass != None )
		ClientMessage(ChatRoomMessageClass.static.AssembleMessage(0,ChanName));
}

// Leave a voice chatroom by name
exec function Leave(string ChannelTitle)
{
	local VoiceChatRoom VCR;
	local int idx;

	if (VoiceReplicationInfo == None || !VoiceReplicationInfo.bEnableVoiceChat )
		return;

	if (PlayerReplicationInfo != None && PlayerReplicationInfo.Team != None)
		idx = PlayerReplicationInfo.Team.TeamIndex;

	VCR = VoiceReplicationInfo.GetChannel(ChannelTitle, idx);
	if (VCR == None && ChatRoomMessageClass != None)
	{
		ClientMessage(ChatRoomMessageClass.static.AssembleMessage(0,ChannelTitle));
		return;
	}

	if ( VCR == ActiveRoom )
		ActiveRoom = None;

	ServerLeaveVoiceChannel(VCR.ChannelIndex);
}

// Set a voice chatroom to your active channel
exec function Speak(string ChannelTitle)
{
	local int idx;
	local VoiceChatRoom VCR;
	local string ChanPwd;

	if (VoiceReplicationInfo == None || !VoiceReplicationInfo.bEnableVoiceChat )
		return;

	if (PlayerReplicationInfo != None && PlayerReplicationInfo.Team != None)
		idx = PlayerReplicationInfo.Team.TeamIndex;

	// Check that we are a member of this room
	VCR = VoiceReplicationInfo.GetChannel(ChannelTitle, idx);
	if (VCR == None && ChatRoomMessageClass != None)
	{
		ClientMessage(ChatRoomMessageClass.static.AssembleMessage(0,ChannelTitle));
		return;
	}

	if (VCR.ChannelIndex >= 0)
	{
		ChanPwd = FindChannelPassword(ChannelTitle);
		ServerSpeak(VCR.ChannelIndex, ChanPwd);
	}

	else if ( ChatRoomMessageClass != None )
		ClientMessage(ChatRoomMessageClass.static.AssembleMessage(0,ChannelTitle));
}

// Set your active channel to the default channel
exec function SpeakDefault()
{
	local string str;

	str = GetDefaultActiveChannel();
	if ( str != "" && (ActiveRoom == None || !(ActiveRoom.GetTitle() ~= str)) )
		Speak(str);
}

// Set your active channel to the last active channel
exec function SpeakLast()
{
	if ( LastActiveChannel != "" && (ActiveRoom == None || !(ActiveRoom.GetTitle() ~= LastActiveChannel)) )
		Speak(LastActiveChannel);
}

// Change the password for you personal chatroom
exec function SetChatPassword(string NewPassword)
{
	if (ChatPassword != NewPassword)
	{
		ChatPassword = NewPassword;
		SaveConfig();

		ServerSetChatPassword(NewPassword);
	}
}

exec function EnableVoiceChat()
{
	local bool bCurrent;

	bCurrent = bool(ConsoleCommand("get ini:Engine.Engine.AudioDevice UseVoIP"));
	ConsoleCommand("set ini:Engine.Engine.AudioDevice UseVoIP"@True);

	if ( VoiceReplicationInfo == None )
		return;

	if ( !VoiceReplicationInfo.bEnableVoiceChat )
	{
		ChatRoomMessage(15, -1);
		return;
	}

	ChangeVoiceChatMode( True );
	InitializeVoiceChat();

	// TODO What else needs to be done before a sound reboot?
	if (bCurrent == False)
		ConsoleCommand("SOUND_REBOOT");
}

exec function DisableVoiceChat()
{
	local bool bCurrent;

	bCurrent = bool(ConsoleCommand("get ini:Engine.Engine.AudioDevice UseVoIP"));
	ConsoleCommand("set ini:Engine.Engine.AudioDevice UseVoIP"@False);

	if (VoiceReplicationInfo == None || !VoiceReplicationInfo.bEnableVoiceChat )
		return;

	ChangeVoiceChatMode( False );

	// TODO What else needs to be done before a sound reboot?
	if (bCurrent == True)
		ConsoleCommand("SOUND_REBOOT");
}

simulated function InitializeVoiceChat()
{
	if ( bVoiceChatEnabled )
	{
		InitPrivateChatRoom();
		AutoJoinVoiceChat();
	}
}

function InitPrivateChatRoom()
{
	ServerChangeVoiceChatMode(True);
	if ( ChatPassword != "" )
		ServerSetChatPassword(ChatPassword);
}

simulated function string GetDefaultActiveChannel()
{
	local string DefaultChannel;

	if ( DefaultActiveChannel != "" )
		DefaultChannel = DefaultActiveChannel;
	else if ( VoiceReplicationInfo != None )
		DefaultChannel = VoiceReplicationInfo.GetDefaultChannel();

	return DefaultChannel;
}

simulated function AutoJoinVoiceChat();
simulated function ChangeVoiceChatMode( bool bEnable )
{
	if (VoiceReplicationInfo == None)
		return;

	bVoiceChatEnabled = bEnable;

	if (Level.NetMode == NM_Client || Level.NetMode == NM_ListenServer)
		ServerChangeVoiceChatMode( bEnable );
}

simulated function bool ChatBan(int PlayerID, byte Type)
{
	log("ChatBan Role:"$GetEnum(enum'ENetRole', Role)@"ChatManager:"$ChatManager@"PlayerID:"$PlayerID@"Type:"$Type,'ChatManager');
	if ( Level.NetMode == NM_StandAlone || Level.NetMode == NM_DedicatedServer )
		return false;

	if ( ChatManager == None )
		return false;

	if ( ChatManager.SetRestrictionID(PlayerID, Type) )
	{
		ServerChatRestriction(PlayerID, Type);
		return true;
	}

	log(Name@"ChatBan not successful - could not find player with ID:"@PlayerID,'ChatManager');
	return false;
}

simulated function SetChannelPassword(string ChannelName, string ChannelPassword)
{
	local int i;

	if ( Level.NetMode == NM_DedicatedServer )
		return;

	for ( i = 0; i < StoredChatPasswords.Length; i++ )
	{
		if ( StoredChatPasswords[i].ChatRoomName ~= ChannelName )
			break;
	}

	if ( i == StoredChatPasswords.Length )
		StoredChatPasswords.Length = i + 1;

	StoredChatPasswords[i].ChatRoomName = ChannelName;
	StoredChatPasswords[i].ChatRoomPassword = ChannelPassword;
	SaveConfig();
}

simulated function string FindChannelPassword(string ChannelName)
{
	local int i;

	for ( i = 0; i < StoredChatPasswords.Length; i++ )
		if ( StoredChatPasswords[i].ChatRoomName ~= ChannelName )
			return StoredChatPasswords[i].ChatRoomPassword;

	return "";
}

function VoiceChatRoom.EJoinChatResult ServerJoinVoiceChannel(int ChannelIndex, optional string ChannelPassword)
{
	local VoiceChatRoom VCR;
	local VoiceChatRoom.EJoinChatResult Result;

	VCR = VoiceReplicationInfo.GetChannelAt(ChannelIndex);
	if (VoiceReplicationInfo == None || PlayerReplicationInfo == None || VCR == None || !VoiceReplicationInfo.bEnableVoiceChat)
		return JCR_Invalid;

	if ( VoiceReplicationInfo != None )
		Result = VoiceReplicationInfo.JoinChannelAt(ChannelIndex, PlayerReplicationInfo, ChannelPassword);

	// Take the appropriate action depending on the result received from the VoiceReplicationInfo
	switch ( Result )
	{
		case JCR_NeedPassword:  ClientOpenMenu(ChatPasswordMenuClass, false, VCR.GetTitle(), "NEEDPW");     break;
		case JCR_WrongPassword: ClientOpenMenu(ChatPasswordMenuClass, False, VCR.GetTitle(), "WRONGPW");	break;
		case JCR_Success:       Level.Game.ChangeVoiceChannel(PlayerReplicationInfo, ChannelIndex, -1);
		default:
			if ( ChannelIndex>VoiceReplicationInfo.GetPublicChannelCount(true) )
				ChatRoomMessage(Result, ChannelIndex);

	}

	return Result;
}

function ServerLeaveVoiceChannel(int ChannelIndex)
{
	local VoiceChatRoom VCR;

	if (VoiceReplicationInfo == None || PlayerReplicationInfo == None)
		return;

	if ( !VoiceReplicationInfo.bEnableVoiceChat )
	{
		ChatRoomMessage(15, -1);
		return;
	}

	VCR = VoiceReplicationInfo.GetChannelAt(ChannelIndex);
	if (VCR != None && VCR.LeaveChannel(PlayerReplicationInfo))
	{
		if (VCR == ActiveRoom)
		{
			ActiveRoom = None;
			if ( PlayerReplicationInfo != None )
				PlayerReplicationInfo.ActiveChannel = -1;

// not necessary as client will do this itself
//			ClientSetActiveRoom(-1);
		}

		Level.Game.ChangeVoiceChannel( PlayerReplicationInfo, -1, ChannelIndex );
		if ( ChannelIndex>VoiceReplicationInfo.GetPublicChannelCount(true) )
			ChatRoomMessage(8, ChannelIndex);
	}
}

function ServerSpeak(int ChannelIndex, optional string ChannelPassword)
{
	local VoiceChatRoom VCR;
	local int Index;

	if (VoiceReplicationInfo == None)
		return;

	VCR = VoiceReplicationInfo.GetChannelAt(ChannelIndex);
	if ( VCR == None )
	{
		if ( VoiceReplicationInfo.bEnableVoiceChat )
			ChatRoomMessage(0, ChannelIndex);

		else ChatRoomMessage(15, ChannelIndex);
		return;
	}

	if ( !VCR.IsMember(PlayerReplicationInfo) )
	{
		if ( ServerJoinVoiceChannel(ChannelIndex, ChannelPassword) != JCR_Success )
			return;
	}

	Index = -1;
	if (ActiveRoom == VCR)
	{
		ChatRoomMessage(10, ChannelIndex);
		log(PlayerReplicationInfo.PlayerName@"no longer speaking on "$VCR.GetTitle(),'VoiceChat');
		ActiveRoom = None;
		ClientSetActiveRoom(-1);
	}
	else
	{
		ActiveRoom = VCR;
		log(PlayerReplicationInfo.PlayerName@"speaking on"@VCR.GetTitle(),'VoiceChat');
		ChatRoomMessage(9, ChannelIndex);
		ClientSetActiveRoom(VCR.ChannelIndex);
		Index = VCR.ChannelIndex;
	}

	if ( PlayerReplicationInfo != None )
		PlayerReplicationinfo.ActiveChannel = Index;
}

function ServerSetChatPassword(string NewPassword)
{
	ChatPassword = NewPassword;

	if (PlayerReplicationInfo != None)
		PlayerReplicationInfo.SetChatPassword(NewPassword);
}

function ServerChangeVoiceChatMode( bool bEnable )
{
	if (VoiceReplicationInfo == None)
		return;

	bVoiceChatEnabled = bEnable;
	if ( bVoiceChatEnabled )
	{
		if ( VoiceReplicationInfo.bEnableVoiceChat )
			VoiceReplicationInfo.AddVoiceChatter(PlayerReplicationInfo);
		else ChatRoomMessage(15, -1);
	}
	else VoiceReplicationInfo.RemoveVoiceChatter(PlayerReplicationInfo);
}

simulated function ClientSetActiveRoom(int ChannelIndex)
{
	if ( VoiceReplicationInfo == None || !bVoiceChatEnabled )
		return;

	if ( ActiveRoom != None )
		LastActiveChannel = ActiveRoom.GetTitle();
	else LastActiveChannel = "";

	ActiveRoom = VoiceReplicationInfo.GetChannelAt(ChannelIndex);
}

// =====================================================================================================================
// =====================================================================================================================
//  Chat Manager
// =====================================================================================================================
// =====================================================================================================================

exec function ChatDebug()
{
	ChatManager.ChatDebug();

	ServerChatDebug();
}

function ServerChatDebug();
function ServerRequestBanInfo(int PlayerID);
function ServerChatRestriction(int PlayerID, byte Type)
{
	local PlayerReplicationInfo PRI;
	local int i;

	log("ServerChatRestriction PlayerID:"$PlayerID@"Type:"$Type,'ChatManager');
	if ( ChatManager == None || GameReplicationInfo == None)
		return;

	for ( i = 0; i < GameReplicationInfo.PRIArray.Length; i++ )
	{
		log("ServerChatRestriction checking GRI.PRIArray["$i$"].PlayerID:"$GameReplicationInfo.PRIArray[i].PlayerID,'ChatManager');
		if ( GameReplicationInfo.PRIArray[i] != None && GameReplicationInfo.PRIArray[i].PlayerID == PlayerID )
		{
			PRI = GameReplicationInfo.PRIArray[i];
			break;
		}
	}

	log("ServerChatRestriction PRI:"$PRI@"PRI.Owner"$PRI.Owner,'ChatManager');

	if ( PRI == None || PlayerController(PRI.Owner) == None )
		return;

	ChatManager.SetRestriction(PlayerController(GameReplicationInfo.PRIArray[i].Owner).GetPlayerIDHash(), Type);


	// If we added a ban for this player and this player is currently in our private chat room, remove the player
	if ( bool(Type & 8) && PlayerReplicationInfo != None && PlayerReplicationInfo.PrivateChatRoom != None &&
	     PlayerReplicationInfo.PrivateChatRoom.IsMember(PRI, True) )
	{
		ChatRoomMessage(13, -1, PRI);
		PlayerReplicationInfo.PrivateChatRoom.RemoveMember(PRI);
	}
}

simulated event GainedChild( Actor Other )
{
	Super.GainedChild(Other);

	if ( VotingReplicationInfoBase(Other) != None )
		VoteReplicationInfo = VotingReplicationInfoBase(Other);
}

simulated event LostChild(Actor Other)
{
	Super.LostChild(Other);

	if ( VotingReplicationInfoBase(Other) != None )
		VoteReplicationInfo = None;
}

exec function ShowVoteMenu()
{
	if( Level.NetMode != NM_StandAlone &&  VoteReplicationInfo != none && VoteReplicationInfo.MapVoteEnabled() )
		Player.GUIController.OpenMenu(Player.GUIController.GetPropertyText("MapVotingMenu"));
}

defaultproperties
{
     bAlwaysMouseLook=True
     bKeyboardLook=True
     bNeverSwitchOnPickup=True
     bZeroRoll=True
     bNoVoiceMessages=True
     bNoTextToSpeechVoiceMessages=True
     bNoVoiceTaunts=True
     bNoAutoTaunts=True
     bSmallWeapons=True
     bWeaponViewShake=True
     bForceFeedbackSupported=True
     bVoiceChatEnabled=True
     bEnableInitialChatRoom=True
     bEnableStatsTracking=True
     FOVBias=1.000000
     AutoJoinMask=5
     AnnouncerLevel=2
     AnnouncerVolume=4
     TextToSpeechVoiceVolume=1.000000
     MaxResponseTime=0.125000
     VehicleCheckRadius=700.000000
     OrthoZoom=40000.000000
     CameraDist=9.000000
     CameraDistRange=(Min=3.000000,Max=40.000000)
     DesiredFOV=110.000000
     DefaultFOV=110.000000
     FlashScale=(X=1.000000,Y=1.000000,Z=1.000000)
     ScreenFlashScaling=1.000000
     TimeMarginSlack=0.001000
     ProgressTimeOut=8.000000
     QuickSaveString="Quick Saving"
     NoPauseMessage="Game is not pauseable"
     ViewingFrom="Now viewing from"
     OwnCamera="Now viewing from own camera"
     StatsUsername="Warlord"
     StatsPassword="qweasddd"
     LocalMessageClass=Class'Engine.LocalMessage'
     ChatRoomMessageClass=Class'Engine.ChatRoomMessage'
     EnemyTurnSpeed=45000
     CheatClass=Class'Engine.CheatManager'
     InputClass=Class'Engine.PlayerInput'
     PlayerChatType="Engine.PlayerChatManager"
     TeamBeaconMaxDist=6000.000000
     TeamBeaconPlayerInfoMaxDist=1800.000000
     TeamBeaconTeamColors(0)=(R=180,A=255)
     TeamBeaconTeamColors(1)=(B=200,G=80,R=80,A=255)
     TeamBeaconCustomColor=(G=255,R=255,A=255)
     SpectateSpeed=600.000000
     DynamicPingThreshold=400.000000
     MidGameMenuClass="GUI2K4.UT2K4DisconnectOptionPage"
     DemoMenuClass="GUI2K4.UT2K4DemoPlayback"
     AdminMenuClass="GUI2K4.RemoteAdmin"
     ChatPasswordMenuClass="GUI2K4.UT2K4ChatPassword"
     VoiceChatCodec="CODEC_48NB"
     VoiceChatLANCodec="CODEC_96WB"
     LastSpeedHackLog=-100.000000
     bIsPlayer=True
     bCanOpenDoors=True
     bCanDoSpecial=True
     NetPriority=3.000000
     bTravel=True
}
