// GameInfo.
//
// The GameInfo defines the game being played: the game rules, scoring, what actors
// are allowed to exist in this game type, and who may enter the game.  While the
// GameInfo class is the public interface, much of this functionality is delegated
// to several classes to allow easy modification of specific game components.  These
// classes include GameInfo, AccessControl, Mutator, BroadcastHandler, and GameRules.
// A GameInfo actor is instantiated when the level is initialized for gameplay (in
// C++ UGameEngine::LoadMap() ).  The class of this GameInfo actor is determined by
// (in order) either the DefaultGameType if specified in the LevelInfo, or the
// DefaultGame entry in the game's .ini file (in the Engine.Engine section), unless
// its a network game in which case the DefaultServerGame entry is used.
//
//=============================================================================
class GameInfo extends Info
	HideDropDown
	CacheExempt
    native;

//------------------------------------------------------------------------------
// Structs for reporting server state data

struct native export KeyValuePair
{
	var() string Key;
	var() string Value;
};

struct native export PlayerResponseLine
{
	var() int PlayerNum;
	var() string PlayerName;
	var() int Ping;
	var() int Score;
	var() int StatsID;
};

struct native export ServerResponseLine
{
	var() int ServerID;
	var() string IP;
	var() int Port;
	var() int QueryPort;
	var() string ServerName;
	var() string MapName;
	var() string GameType;
	var() int CurrentPlayers;
	var() int MaxPlayers;
	var() int Ping;
    var() int Flags;
    var() string SkillLevel;
	var() array<KeyValuePair> ServerInfo;
	var() array<PlayerResponseLine> PlayerInfo;
};

//-----------------------------------------------------------------------------
// Variables.

var bool						bRestartLevel;            // Level should be restarted when player dies
var bool						bPauseable;               // Whether the game is pauseable.
var config bool					bWeaponStay;              // Whether or not weapons stay when picked up.
var bool						bCanChangeSkin;           // Allow player to change skins in game.
var cache bool					bTeamGame;                // This is a team game.
var bool						bGameEnded;               // set when game ends
var bool						bOverTime;
var localized bool				bAlternateMode;
var bool						bCanViewOthers;
var bool						bDelayedStart;
var bool						bWaitingToStartMatch;
var globalconfig bool			bChangeLevels;
var bool					    bAlreadyChanged;
var bool						bLoggingGame;           // Does this gametype log?
var globalconfig bool			bEnableStatLogging;		// If True, games will log
var config bool					bAllowWeaponThrowing;
var globalconfig bool			bAllowBehindView;
var globalconfig bool			bAdminCanPause;
var bool						bGameRestarted;
var globalconfig bool			bWeaponShouldViewShake;
var bool						bModViewShake;			// for mutators to turn off weaponviewshake
var bool						bForceClassicView;		// OBSOLETE
var globalconfig bool			bLowGore;				// OBSOLETE - use GoreLevel instead;
var bool bWelcomePending;
var bool bAttractCam;
var bool    bMustJoinBeforeStart;   // players can only spectate if they join after the game starts
var bool bTestMode;
var bool bAllowVehicles;	//are vehicles allowed in this gametype?
var bool bAllowMPGameSpeed;
var bool bIsSaveGame;			// stays true during entire game (unlike LevelInfo property)
var bool bLiberalVehiclePaths;
var globalconfig bool bLargeGameVOIP;

var globalconfig	int			GoreLevel;
var globalconfig	float		GameDifficulty;
var float		AutoAim;                  // OBSOLETE How much autoaiming to do (1 = none, 0 = always).
                                                        // (cosine of max error to correct)
var globalconfig	float		GameSpeed;                // Scale applied to game rate.
var   float						StartTime;

var   string					DefaultPlayerClassName;

// user interface
var   string                  ScoreBoardType;           // Type of class<Menu> to use for scoreboards. (gam)
var   string                  BotMenuType;              // Type of bot menu to display. -NOT USED-
var   cache string            RulesMenuType;            // Type of rules menu to display.
var   string                  SettingsMenuType;         // Type of settings menu to display. -NOT USED-
var   string                  GameUMenuType;            // Type of Game dropdown to display. (Used as map menu in Onslaught)
var   string                  MultiplayerUMenuType;     // Type of Multiplayer dropdown to display. -NOT USED-
var   string                  GameOptionsMenuType;      // Type of options dropdown to display. -NOT USED-

var   cache string            HUDSettingsMenu;          // Optional GUI page for configuring HUD options specific to this gametype
var   string				  HUDType;                  // HUD class this game uses.
var   cache string            MapListType;              // Maplist this game uses.
var   cache string            MapPrefix;                // Prefix characters for names of maps for this game type.
var   string                  BeaconName;               // Identifying string used for finding LAN servers.
var localized string          GoreLevelText[3];
var() int                     ResetCountDown;
var() config int              ResetTimeDelay;           // time (seconds) before restarting teams

var   globalconfig int        MaxSpectators;            // Maximum number of spectators.
var   int                     NumSpectators;            // Current number of spectators.
var   globalconfig int        MaxPlayers;
var   int                     NumPlayers;               // number of human players
var   int                     NumBots;                  // number of non-human players (AI controlled but participating as a player)
var   int                     CurrentID;
var localized string          DefaultPlayerName;
var float					  FearCostFallOff;			// how fast the FearCost in NavigationPoints falls off

var config int                GoalScore;                // what score is needed to end the match
var config int                MaxLives;	                // max number of lives for match, unless overruled by level's GameDetails
var config int                TimeLimit;                // time limit in minutes

// Message classes.
var class<LocalMessage>       DeathMessageClass;
var class<GameMessage>        GameMessageClass;
var	name					  OtherMesgGroup;

//-------------------------------------
// GameInfo components
var   string                  MutatorClass;
var   Mutator                 BaseMutator;            // linked list of Mutators (for modifying actors as they enter the game)
var() globalconfig string     AccessControlClass;
var   AccessControl           AccessControl;          // AccessControl controls whether players can enter and/or become admins
var   GameRules               GameRulesModifiers;     // linked list of modifier classes which affect game rules
var() string                  BroadcastHandlerClass;
var() class<BroadcastHandler> BroadcastClass;
var   BroadcastHandler        BroadcastHandler;       // handles message (text and localized) broadcasts

var class<PlayerController>   PlayerControllerClass;  // type of player controller to spawn for players logging in
var string                    PlayerControllerClassName;

// ReplicationInfo
var() class<GameReplicationInfo> GameReplicationInfoClass;
var GameReplicationInfo 		 GameReplicationInfo;

// Voice chat
var() class<VoiceChatReplicationInfo>	VoiceReplicationInfoClass;
var VoiceChatReplicationInfo			VoiceReplicationInfo;

// Maplist management
var   globalconfig string         MaplistHandlerType;
var   class<MaplistManagerBase>   MaplistHandlerClass;
var   transient MaplistManagerBase          MaplistHandler;

// Stats - jmw
var GameStats                   GameStats;				// Holds the GameStats actor
var globalconfig string			GameStatsClass;			// Type of GameStats actor to spawn

// Server demo recording - rjp
var transient string            DemoCommand;	// set in InitGame to value of ?DemoRec=
                                                // only checked in GameInfo.PostBeginPlay()


// Cheat Protection
var globalconfig string			SecurityClass;

// Cache-related information
var() cache localized string    GameName;
var() cache localized string    Description;
var() cache string              ScreenShotName;
var() cache String              DecoTextName;	// deprecated ?
var() cache String              Acronym;

// voting handler
var globalconfig string VotingHandlerType;
var class<VotingHandler> VotingHandlerClass;
var transient VotingHandler VotingHandler;

// persistant game data management
var() transient GameProfile     CurrentGameProfile;
var() private const transient Manifest    SaveGameManifest;

// localized PlayInfo descriptions & extra info
const GIPROPNUM = 15;
var localized string GIPropsDisplayText[GIPROPNUM];
var localized string GIPropDescText[GIPROPNUM];
var localized string GIPropsExtras[2];

var Vehicle VehicleList;
var string CallSigns[15];

var globalconfig string ServerSkillLevel;	// The Server Skill Level ( 0 - 2, Beginner - Advanced )

var globalconfig float MaxIdleTime;		// maximum time players are allowed to idle before being kicked

//Loading screen hints
var localized string NoBindString;
var color BindColor;

native final function Manifest  GetSavedGames();
native final function Object    CreateDataObject ( class objClass, string objName, string packageName );
native final function bool      DeleteDataObject ( class objClass, string objName, string packageName );
native final function Object    LoadDataObject   ( class objClass, string objName, string packageName );
native final iterator function  AllDataObjects   ( class objClass, out Object obj, string packageName );
native final function bool      SavePackage      ( string packageName );
native final function bool      DeletePackage    ( string packageName );

native final static function	LoadMapList(string MapPrefix, out array<string> Maps);

//------------------------------------------------------------------------------
// Engine notifications.

function PreBeginPlay()
{
    StartTime = 0;
    GameReplicationInfo = Spawn(GameReplicationInfoClass);
	Level.GRI = GameReplicationInfo;

    InitGameReplicationInfo();
    InitVoiceReplicationInfo();

	// Create stat logging actor.
    InitLogging();
}

function Destroyed()
{
    CurrentGameProfile = None;
    Super.Destroyed();
}

function UpdatePrecacheMaterials()
{
	PrecacheGameTextures(Level);
}

function UpdatePrecacheStaticMeshes()
{
	PrecacheGameStaticMeshes(Level);
}

static function PrecacheGameTextures(LevelInfo myLevel);
static function PrecacheGameStaticMeshes(LevelInfo myLevel);
static function PrecacheGameAnnouncements(AnnouncerVoice V, bool bRewardSounds);

function string FindPlayerByID( int PlayerID )
{
    local PlayerReplicationInfo PRI;

	PRI = GameReplicationInfo.FindPlayerByID(PlayerID);
	if ( PRI != None )
		return PRI.PlayerName;
    return "";
}

function ChangeMap(int ContextID) // sjs
{
    local MapList MyList;
    local class<MapList> ML;
    local string MapString;

    ML = class<MapList>(DynamicLoadObject(MapListType, class'Class'));
    MyList = spawn(ML);
    MapString = MyList.GetMap(ContextID);
    MyList.Destroy();

    if( MapString == "" )
        return;

    Level.ServerTravel(MapString, false);
}
static function bool UseLowGore()
{
	return ( Default.bAlternateMode || Default.bLowGore || (Default.GoreLevel < 2) );
}

static function bool NoBlood()
{
	return ( Default.GoreLevel == 0 );
}

function PostBeginPlay()
{
	if ( MaxIdleTime > 0 )
		MaxIdleTime = FMax(MaxIdleTime, 30);

	if (GameStats!=None)
	{
		GameStats.NewGame();
		GameStats.ServerInfo();
	}

	// Do not start any demo recordings until everything has been initialized
	if ( DemoCommand != "" )
		ConsoleCommand("demorec"@DemoCommand, True);
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
    Super.Reset();
    bGameEnded = false;
    bOverTime = false;
    bWaitingToStartMatch = true;
    InitGameReplicationInfo();
    InitVoiceReplicationInfo();
}

/* InitLogging()
Set up statistics logging
*/
function InitLogging()
{
	local class <GameStats> MyGameStatsClass;

    if ( !bEnableStatLogging || !bLoggingGame || (Level.NetMode == NM_Standalone) || (Level.NetMode == NM_ListenServer) )
        return;

	MyGameStatsClass=class<GameStats>(DynamicLoadObject(GameStatsClass,class'class'));
    if (MyGameStatsClass!=None)
    {
		GameStats = spawn(MyGameStatsClass);
        if (GameStats==None)
        	log("Could to create Stats Object");
    }
    else
    	log("Error loading GameStats ["$GameStatsClass$"]");
}

function Timer()
{
	local NavigationPoint N;
	local int i;

    // If we are a server, broadcast a welcome message.
    if( bWelcomePending )
    {
		bWelcomePending = false;
		if ( Level.NetMode != NM_Standalone )
		{
			for ( i=0; i<GameReplicationInfo.PRIArray.Length; i++ )
				if ( (GameReplicationInfo.PRIArray[i] != None)
					&& !GameReplicationInfo.PRIArray[i].bWelcomed )
				{
					GameReplicationInfo.PRIArray[i].bWelcomed = true;
					if ( !GameReplicationInfo.PRIArray[i].bOnlySpectator )
						BroadcastLocalizedMessage(GameMessageClass, 1, GameReplicationInfo.PRIArray[i]);
					else
						BroadcastLocalizedMessage(GameMessageClass, 16, GameReplicationInfo.PRIArray[i]);
				}
		}
	}

    BroadcastHandler.UpdateSentText();
    for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		N.FearCost *= FearCostFallOff;
}

// Called when game shutsdown.
event GameEnding()
{
    EndLogging("serverquit");
}

/* KickIdler() called if
		if ( (Pawn != None) || (PlayerReplicationInfo.bOnlySpectator && (ViewTarget != self))
			|| (Level.Pauser != None) || Level.Game.bWaitingToStartMatch || Level.Game.bGameEnded )
		{
			LastActiveTime = Level.TimeSeconds;
		}
		else if ( (Level.Game.MaxIdleTime > 0) && (Level.TimeSeconds - LastActiveTime > Level.Game.MaxIdleTime) )
			KickIdler(self);
*/
event KickIdler(PlayerController PC)
{
	log("Kicking idle player "$PC.PlayerReplicationInfo.PlayerName);
	AccessControl.DefaultKickReason = AccessControl.IdleKickReason;
	AccessControl.KickPlayer(PC);
	AccessControl.DefaultKickReason = AccessControl.Default.DefaultKickReason;
}

//------------------------------------------------------------------------------
// Replication

function InitGameReplicationInfo()
{
    GameReplicationInfo.bTeamGame = bTeamGame;
    GameReplicationInfo.GameName = GameName;
    GameReplicationInfo.GameClass = string(Class);
    GameReplicationInfo.MaxLives = MaxLives;
}

function InitVoiceReplicationInfo()
{
	log(Name@"VoiceReplicationInfo created:"@VoiceReplicationInfo,'VoiceChat');
}

function InitMaplistHandler();

native function string GetNetworkNumber();

//------------------------------------------------------------------------------
// Server/Game Querying.

function GetServerInfo( out ServerResponseLine ServerState )
{
	local int RealSkillLevel;

	ServerState.ServerName		= StripColor(GameReplicationInfo.ServerName);
	ServerState.MapName			= Left(string(Level), InStr(string(Level), "."));
	ServerState.GameType		= Mid( string(Class), InStr(string(Class), ".")+1);
	ServerState.CurrentPlayers	= GetNumPlayers();
	ServerState.MaxPlayers		= MaxPlayers;
	ServerState.IP				= ""; // filled in at the other end.
	ServerState.Port			= GetServerPort();

	// rjp --
	// Valid values are 0, 1, 2
	// empty string will NOT be considered as 0 in the database, so we need to do some fiddling here
	// to make sure that servers that do not set a default value for ServerSkillLevel still report a skill level
	RealSkillLevel = Clamp( int(ServerSkillLevel), 0, 2 );
    ServerState.SkillLevel		= string(RealSkillLevel);

	ServerState.ServerInfo.Length = 0;
	ServerState.PlayerInfo.Length = 0;
}

function int GetNumPlayers()
{
	return NumPlayers;
}

function GetServerDetails( out ServerResponseLine ServerState )
{
	local Mutator M;
	local GameRules G;
	local int i, Len, NumMutators;
	local string MutatorName;
	local bool bFound;

	AddServerDetail( ServerState, "ServerMode", Eval(Level.NetMode == NM_ListenServer, "non-dedicated", "dedicated") );
	AddServerDetail( ServerState, "AdminName", GameReplicationInfo.AdminName );
	AddServerDetail( ServerState, "AdminEmail", GameReplicationInfo.AdminEmail );
	AddServerDetail( ServerState, "ServerVersion", Level.EngineVersion );

	if ( AccessControl != None && AccessControl.RequiresPassword() )
		AddServerDetail( ServerState, "GamePassword", "True" );

	AddServerDetail( ServerState, "GameStats", GameStats != None );

	if ( AllowGameSpeedChange() && (GameSpeed != 1.0) )
		AddServerDetail( ServerState, "GameSpeed", int(GameSpeed*100)/100.0 );

	AddServerDetail( ServerState, "MaxSpectators", MaxSpectators );

	// voting
	if( VotingHandler != None )
		VotingHandler.GetServerDetails(ServerState);

	// Ask the mutators if they have anything to add.
	for (M = BaseMutator; M != None; M = M.NextMutator)
	{
		M.GetServerDetails(ServerState);
		NumMutators++;
	}

	// Ask the gamerules if they have anything to add.
	for ( G=GameRulesModifiers; G!=None; G=G.NextGameRules )
		G.GetServerDetails(ServerState);

	// make sure all the mutators were really added
	for ( i=0; i<ServerState.ServerInfo.Length; i++ )
		if ( ServerState.ServerInfo[i].Key ~= "Mutator" )
			NumMutators--;

	if ( NumMutators > 1 )
	{
		// something is missing
		for (M = BaseMutator.NextMutator; M != None; M = M.NextMutator)
		{
			MutatorName = M.GetHumanReadableName();
			for ( i=0; i<ServerState.ServerInfo.Length; i++ )
				if ( (ServerState.ServerInfo[i].Value ~= MutatorName) && (ServerState.ServerInfo[i].Key ~= "Mutator") )
				{
					bFound = true;
					break;
				}
			if ( !bFound )
			{
				Len = ServerState.ServerInfo.Length;
				ServerState.ServerInfo.Length = Len+1;
				ServerState.ServerInfo[i].Key = "Mutator";
				ServerState.ServerInfo[i].Value = MutatorName;
			}
		}
	}
}

function GetServerPlayers( out ServerResponseLine ServerState )
{
    local Mutator M;
	local Controller C;
	local PlayerReplicationInfo PRI;
	local int i, TeamFlag[2];

	i = ServerState.PlayerInfo.Length;
	TeamFlag[0] = 1 << 29;
	TeamFlag[1] = TeamFlag[0] << 1;

	for( C=Level.ControllerList;C!=None;C=C.NextController )
        {
			PRI = C.PlayerReplicationInfo;
			if( (PRI != None) && !PRI.bBot && MessagingSpectator(C) == None )
            {
			ServerState.PlayerInfo.Length = i+1;
			ServerState.PlayerInfo[i].PlayerNum  = C.PlayerNum;
			ServerState.PlayerInfo[i].PlayerName = PRI.PlayerName;
			ServerState.PlayerInfo[i].Score		 = PRI.Score;
			ServerState.PlayerInfo[i].Ping		 = 4 * PRI.Ping;
			if (bTeamGame && PRI.Team != None)
				ServerState.PlayerInfo[i].StatsID = ServerState.PlayerInfo[i].StatsID | TeamFlag[PRI.Team.TeamIndex];
			i++;
            }
    }

	// Ask the mutators if they have anything to add.
	for (M = BaseMutator.NextMutator; M != None; M = M.NextMutator)
		M.GetServerPlayers(ServerState);
}

//------------------------------------------------------------------------------
// Misc.

// Return the server's port number.
function int GetServerPort()
{
    local string S;
    local int i;

    // Figure out the server's port.
    S = Level.GetAddressURL();
    i = InStr( S, ":" );
    assert(i>=0);
    return int(Mid(S,i+1));
}

function bool SetPause( BOOL bPause, PlayerController P )
{
    if( bPauseable || (bAdminCanPause && (P.IsA('Admin') || P.PlayerReplicationInfo.bAdmin)) || Level.Netmode==NM_Standalone )
    {
        if( bPause )
            Level.Pauser=P.PlayerReplicationInfo;
        else
            Level.Pauser=None;
        return True;
    }
    else return False;
}

//------------------------------------------------------------------------------
// Game parameters.

function bool AllowGameSpeedChange()
{
	if ( Level.NetMode == NM_Standalone )
		return true;
	else
		return bAllowMPGameSpeed;
}

//
// Set gameplay speed.
//
function SetGameSpeed( Float T )
{
    local float OldSpeed;

	if ( !AllowGameSpeedChange() )
	{
		Level.TimeDilation = 1.1;
		GameSpeed = 1.0;
		Default.GameSpeed = GameSpeed;
	}
	else
	{
		OldSpeed = GameSpeed;
		GameSpeed = FMax(T, 0.1);
		Level.TimeDilation = 1.1 * GameSpeed;
		if ( GameSpeed != OldSpeed )
		{
			Default.GameSpeed = GameSpeed;
			class'GameInfo'.static.StaticSaveConfig();
		}
	}
    SetTimer(Level.TimeDilation, true);
}

//
// Called after setting low or high detail mode.
//
event DetailChange()
{
    local actor A;
    local zoneinfo Z;

    if( Level.DetailMode == DM_Low )
    {
        foreach DynamicActors(class'Actor', A)
        {
            if( (A.bHighDetail || A.bSuperHighDetail) && !A.bGameRelevant )
                A.Destroy();
        }
    }
    else if( Level.DetailMode == DM_High )
    {
        foreach DynamicActors(class'Actor', A)
        {
            if( A.bSuperHighDetail && !A.bGameRelevant )
                A.Destroy();
        }
    }
    foreach AllActors(class'ZoneInfo', Z)
        Z.LinkToSkybox();
}

//------------------------------------------------------------------------------
// Player start functions

//
// Grab the next option from a string.
//
static function bool GrabOption( out string Options, out string Result )
{
    if( Left(Options,1)=="?" )
    {
        // Get result.
        Result = Mid(Options,1);
        if( InStr(Result,"?")>=0 )
            Result = Left( Result, InStr(Result,"?") );

        // Update options.
        Options = Mid(Options,1);
        if( InStr(Options,"?")>=0 )
            Options = Mid( Options, InStr(Options,"?") );
        else
            Options = "";

        return true;
    }
    else return false;
}

//
// Break up a key=value pair into its key and value.
//
static function GetKeyValue( string Pair, out string Key, out string Value )
{
    if( InStr(Pair,"=")>=0 )
    {
        Key   = Left(Pair,InStr(Pair,"="));
        Value = Mid(Pair,InStr(Pair,"=")+1);
    }
    else
    {
        Key   = Pair;
        Value = "";
    }
}

/* ParseOption()
 Find an option in the options string and return it.
*/
static function string ParseOption( string Options, string InKey )
{
    local string Pair, Key, Value;
    while( GrabOption( Options, Pair ) )
    {
        GetKeyValue( Pair, Key, Value );
        if( Key ~= InKey )
            return Value;
    }
    return "";
}

//
// HasOption - return true if the option is specified on the command line.
//
static function bool HasOption( string Options, string InKey )
{
    local string Pair, Key, Value;
    while( GrabOption( Options, Pair ) )
    {
        GetKeyValue( Pair, Key, Value );
        if( Key ~= InKey )
            return true;
    }
    return false;
}

/* Initialize the game.
 The GameInfo's InitGame() function is called before any other scripts (including
 PreBeginPlay() ), and is used by the GameInfo to initialize parameters and spawn
 its helper classes.
 Warning: this is called before actors' PreBeginPlay.
*/
event InitGame( string Options, out string Error )
{
    local string InOpt, LeftOpt;
    local int pos;
    local class<AccessControl> ACClass;
    local class<GameRules> GRClass;
	local bool bIsTutorial;

    InOpt = ParseOption( Options, "SaveGame");
    if (InOpt != "" && CurrentGameProfile == none)
    {
        CurrentGameProfile = LoadDataObject(class'GameProfile', "GameProfile", InOpt);
		if ( CurrentGameProfile != none )
	        CurrentGameProfile.Initialize(self, InOpt);
		else
		{
			Log("SINGLEPLAYER GameInfo::InitGame failed to find GameProfile"@InOpt);
		}
		if ( !CurrentGameProfile.bInLadderGame )
		{
			CurrentGameProfile = None;
		}
    }

	if ( (CurrentGameProfile == None) && (Left(string(level),3) ~= "TUT") )
		bIsTutorial = true;

    MaxPlayers = Clamp(GetIntOption( Options, "MaxPlayers", MaxPlayers ),0,32);
    MaxSpectators = Clamp(GetIntOption( Options, "MaxSpectators", MaxSpectators ),0,32);
    GameDifficulty = FMax(0,GetIntOption(Options, "Difficulty", GameDifficulty));
    if ( (CurrentGameProfile != None) || bIsTutorial )
    {
    	if (CurrentGameProfile != None)
	        GameDifficulty = CurrentGameProfile.Difficulty;
        SetGameSpeed(1.0);
    }
    AddMutator(MutatorClass);

    BroadcastClass = class<BroadcastHandler>(DynamicLoadObject(BroadcastHandlerClass,Class'Class'));
	default.BroadcastClass = BroadcastClass;	// rjp -- for PlayInfo
    BroadcastHandler = spawn(BroadcastClass);

    InOpt = ParseOption( Options, "AccessControl");
    if( InOpt != "" )
        ACClass = class<AccessControl>(DynamicLoadObject(InOpt, class'Class'));
    if ( ACClass == None )
    {
        ACClass = class<AccessControl>(DynamicLoadObject(AccessControlClass, class'Class'));
		if (ACClass == None)
			ACClass = class'Engine.AccessControl';
	}

	LeftOpt = ParseOption( Options, "AdminName" );
	InOpt = ParseOption( Options, "AdminPassword");
	if( LeftOpt!="" && InOpt!="" )
			ACClass.default.bDontAddDefaultAdmin = true;

	// Only spawn access control if we are a server
	if (Level.NetMode == NM_ListenServer || Level.NetMode == NM_DedicatedServer )
	{
		AccessControl = Spawn(ACClass);
		if (AccessControl != None && LeftOpt!="" && InOpt!="" )
	        AccessControl.SetAdminFromURL(LeftOpt, InOpt);
	}

    SetGameSpeed(1.0);
    InOpt = ParseOption( Options, "GameRules");
    if ( InOpt != "" )
    {
        log("Game Rules"@InOpt);
        while ( InOpt != "" )
        {
            pos = InStr(InOpt,",");
            if ( pos > 0 )
            {
                LeftOpt = Left(InOpt, pos);
                InOpt = Right(InOpt, Len(InOpt) - pos - 1);
            }
            else
            {
                LeftOpt = InOpt;
                InOpt = "";
            }
            log("Add game rules "$LeftOpt);
            GRClass = class<GameRules>(DynamicLoadObject(LeftOpt, class'Class'));
            if ( GRClass != None )
            {
                if ( GameRulesModifiers == None )
                    GameRulesModifiers = Spawn(GRClass);
                else
                    GameRulesModifiers.AddGameRules(Spawn(GRClass));
            }
        }
    }

    InOpt = ParseOption( Options, "Mutator");
    if ( InOpt != "" )
    {
        log("Mutators"@InOpt);
        while ( InOpt != "" )
        {
            pos = InStr(InOpt,",");
            if ( pos > 0 )
            {
                LeftOpt = Left(InOpt, pos);
                InOpt = Right(InOpt, Len(InOpt) - pos - 1);
            }
            else
            {
                LeftOpt = InOpt;
                InOpt = "";
            }
            AddMutator(LeftOpt, true);
        }
    }
    if ( (CurrentGameProfile == None) && !bIsTutorial )
	{
		InOpt = ParseOption( Options, "GameSpeed");
		if( InOpt != "" )
		{
			log("GameSpeed"@InOpt);
			SetGameSpeed(float(InOpt));
		}
	}

    InOpt = ParseOption( Options, "GamePassword");
    if( InOpt != "" && AccessControl != None)
    {
        AccessControl.SetGamePassWord(InOpt);
        log( "GamePassword" @ InOpt );
    }

    InOpt = ParseOption( Options,"AllowThrowing");
    if ( InOpt != "" )
    	bAllowWeaponThrowing = bool(InOpt);

	InOpt = ParseOption( Options,"AllowBehindview");
    if ( InOpt != "" )
    	bAllowBehindview = bool(InOpt);

	InOpt = ParseOption(Options, "GameStats");
	if ( InOpt != "")
		bEnableStatLogging = bool(InOpt);

	log("GameInfo::InitGame : bEnableStatLogging"@bEnableStatLogging);

	if( HasOption(Options, "DemoRec") )
		DemoCommand = ParseOption(Options, "DemoRec");

    if ( HasOption(Options, "AttractCam") )
	    bAttractCam = true;

	// Voting handler requires maplist manager to be configured
    InitMaplistHandler();
	InOpt = ParseOption( Options, "VotingHandler");
    if( InOpt != "" )
        VotingHandlerClass = class<VotingHandler>(DynamicLoadObject(InOpt, class'Class'));

	if( VotingHandlerClass == None )
	{
   		if( VotingHandlerType != "" )
   			VotingHandlerClass = class<VotingHandler>(DynamicLoadObject(VotingHandlerType, class'Class'));
   		else
			VotingHandlerClass = class<VotingHandler>(DynamicLoadObject("Engine.VotingHandler", class'Class'));
    }
	class'Engine.GameInfo'.default.VotingHandlerClass = VotingHandlerClass;
	if( (Level.NetMode != NM_StandAlone) && (VotingHandlerClass != None) && VotingHandlerClass.Static.IsEnabled() )
	{
		VotingHandler = Spawn(VotingHandlerClass);
		if(VotingHandler == none)
			log("WARNING: Failed to spawn VotingHandler");
	}
	bTestMode = HasOption(Options, "CheckErrors");
}

function AddMutator(string mutname, optional bool bUserAdded)
{
    local class<Mutator> mutClass;
    local Mutator mut;

	if ( !Static.AllowMutator(MutName) )
		return;

    mutClass = class<Mutator>(DynamicLoadObject(mutname, class'Class'));
    if (mutClass == None)
        return;

	if ( (mutClass.Default.GroupName != "") && (BaseMutator != None) )
	{
		// make sure no mutators with same groupname
		for ( mut=BaseMutator; mut!=None; mut=mut.NextMutator )
			if ( mut.GroupName == mutClass.Default.GroupName )
			{
				log("Not adding "$mutClass$" because already have a mutator in the same group - "$mut);
				return;
			}
	}

	// make sure this mutator is not added already
	for ( mut=BaseMutator; mut!=None; mut=mut.NextMutator )
		if ( mut.Class == mutClass )
		{
			log("Not adding "$mutClass$" because this mutator is already added - "$mut);
			return;
		}

    mut = Spawn(mutClass);
	// mc, beware of mut being none
	if (mut == None)
		return;

	// Meant to verify if this mutator was from Command Line parameters or added from other Actors
	mut.bUserAdded = bUserAdded;

    if (BaseMutator == None)
        BaseMutator = mut;
    else
        BaseMutator.AddMutator(mut);
}

function AddGameModifier( GameRules NewRule )
{
	if ( NewRule == None )
		return;

	if ( GameRulesModifiers != None )
		GameRulesModifiers.AddGameRules(NewRule);
	else GameRulesModifiers = NewRule;
}

//
// Return beacon text for serverbeacon.
//
event string GetBeaconText()
{
    return
        Level.ComputerName
    $   " "
    $   Left(Level.Title,24)
    $   "\\t"
    $   BeaconName
    $   "\\t"
    $   GetNumPlayers()
    $   "/"
    $   MaxPlayers;
}

/* ProcessServerTravel()
 Optional handling of ServerTravel for network games.
*/
function ProcessServerTravel( string URL, bool bItems )
{
    local playercontroller P, LocalPlayer;

    // Pass it along
    BaseMutator.ServerTraveling(URL,bItems);

    EndLogging("mapchange");

    // Notify clients we're switching level and give them time to receive.
    // We call PreClientTravel directly on any local PlayerPawns (ie listen server)
    log("ProcessServerTravel:"@URL);
    foreach DynamicActors( class'PlayerController', P )
        if( NetConnection( P.Player)!=None )
            P.ClientTravel( Eval( Instr(URL,"?") > 0, Left(URL,Instr(URL,"?")), URL), TRAVEL_Relative, bItems );
        else
        {
            LocalPlayer = P;
            P.PreClientTravel();
        }

    if ( (Level.NetMode == NM_ListenServer) && (LocalPlayer != None) )
        Level.NextURL = Level.NextURL
                     $"?Team="$LocalPlayer.GetDefaultURL("Team")
                     $"?Name="$LocalPlayer.GetDefaultURL("Name")
                     $"?Class="$LocalPlayer.GetDefaultURL("Class")
                     $"?Character="$LocalPlayer.GetDefaultURL("Character");

    // Switch immediately if not networking.
    if( Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
        Level.NextSwitchCountdown = 0.0;
}

//
// Accept or reject a player on the server.
// Fails login if you set the Error to a non-empty string.
//
event PreLogin
(
    string Options,
    string Address,
    string PlayerID,
    out string Error,
    out string FailCode
)
{
    local bool bSpectator;

    bSpectator = ( ParseOption( Options, "SpectatorOnly" ) ~= "1" );
    if (AccessControl != None)
	    AccessControl.PreLogin(Options, Address, PlayerID,Error, FailCode, bSpectator);
}

function int GetIntOption( string Options, string ParseString, int CurrentValue)
{
    local string InOpt;

    InOpt = ParseOption( Options, ParseString );
    if ( InOpt != "" )
        return int(InOpt);
    return CurrentValue;
}

function bool BecomeSpectator(PlayerController P)
{
	if ( (P.PlayerReplicationInfo == None) || !GameReplicationInfo.bMatchHasBegun
	     || (NumSpectators >= MaxSpectators) || P.IsInState('GameEnded') || P.IsInState('RoundEnded') )
	{
		P.ReceiveLocalizedMessage(GameMessageClass, 12);
		return false;
	}

	if (GameStats != None)
	{
		GameStats.DisconnectEvent(P.PlayerReplicationInfo);
	}
	P.PlayerReplicationInfo.bOnlySpectator = true;
	NumSpectators++;
	NumPlayers--;

	return true;
}

function bool AllowBecomeActivePlayer(PlayerController P)
{
	if ( (P.PlayerReplicationInfo == None) || !GameReplicationInfo.bMatchHasBegun || bMustJoinBeforeStart
	     || (NumPlayers >= MaxPlayers) || (MaxLives > 0) || P.IsInState('GameEnded') || P.IsInState('RoundEnded') )
	{
		P.ReceiveLocalizedMessage(GameMessageClass, 13);
		return false;
	}
	return true;
}

function bool AtCapacity(bool bSpectator)
{
    if ( Level.NetMode == NM_Standalone )
        return false;

    if ( bSpectator )
        return ( (NumSpectators >= MaxSpectators)
            && ((Level.NetMode != NM_ListenServer) || (NumPlayers > 0)) );
    else
        return ( (MaxPlayers>0) && (NumPlayers>=MaxPlayers) );
}

function InitSavedLevel()
{
	if ( Level.GRI == None )
		Level.GRI = GameReplicationInfo;

	if ( Level.ObjectPool == None )
		Level.ObjectPool = new(xLevel) class'ObjectPool';
}

//
// Log a player in.
// Fails login if you set the Error string.
// PreLogin is called before Login, but significant game time may pass before
// Login is called, especially if content is downloaded.
//
event PlayerController Login
(
    string Portal,
    string Options,
    out string Error
)
{
    local NavigationPoint StartSpot;
    local PlayerController NewPlayer, TestPlayer;
    local string          InName, InAdminName, InPassword, InChecksum, InCharacter,InSex;
    local byte            InTeam;
    local bool bSpectator, bAdmin;
    local class<Security> MySecurityClass;
    local pawn TestPawn;

	Options = StripColor(Options);	// Strip out color Codes

    BaseMutator.ModifyLogin(Portal, Options);

    // Get URL options.
    InName     = Left(ParseOption ( Options, "Name"), 20);
    InTeam     = GetIntOption( Options, "Team", 255 ); // default to "no team"
    InAdminName= ParseOption ( Options, "AdminName");
    InPassword = ParseOption ( Options, "Password" );
    InChecksum = ParseOption ( Options, "Checksum" );

	if ( HasOption(Options, "Load") )
	{
		log("Loading Savegame");

		InitSavedLevel();
		bIsSaveGame = true;

		// Try to match up to existing unoccupied player in level,
		// for savegames - also needed coop level switching.
		ForEach DynamicActors(class'PlayerController', TestPlayer )
		{
			if ( (TestPlayer.Player==None) && (TestPlayer.PlayerOwnerName~=InName) )
			{
				TestPawn = TestPlayer.Pawn;
				if ( TestPawn != None )
					TestPawn.SetRotation(TestPawn.Controller.Rotation);
				log("FOUND "$TestPlayer@TestPlayer.PlayerReplicationInfo.PlayerName);
				return TestPlayer;
			}
		}
	}

    bSpectator = ( ParseOption( Options, "SpectatorOnly" ) ~= "1" );
    if (AccessControl != None)
		bAdmin = AccessControl.CheckOptionsAdmin(Options);

    // Make sure there is capacity except for admins. (This might have changed since the PreLogin call).
    if ( !bAdmin && AtCapacity(bSpectator) )
    {
        Error = GameMessageClass.Default.MaxedOutMessage;
        return None;
    }

	// If admin, force spectate mode if the server already full of reg. players
	if ( bAdmin && AtCapacity(false))
		bSpectator = true;

    // Pick a team (if need teams)
    InTeam = PickTeam(InTeam,None);

    // Find a start spot.
    StartSpot = FindPlayerStart( None, InTeam, Portal );

    if( StartSpot == None )
    {
        Error = GameMessageClass.Default.FailedPlaceMessage;
        return None;
    }

    if ( PlayerControllerClass == None )
        PlayerControllerClass = class<PlayerController>(DynamicLoadObject(PlayerControllerClassName, class'Class'));

    NewPlayer = spawn(PlayerControllerClass,,,StartSpot.Location,StartSpot.Rotation);

    // Handle spawn failure.
    if( NewPlayer == None )
    {
        log("Couldn't spawn player controller of class "$PlayerControllerClass);
        Error = GameMessageClass.Default.FailedSpawnMessage;
        return None;
    }

    NewPlayer.StartSpot = StartSpot;

    // Init player's replication info
    NewPlayer.GameReplicationInfo = GameReplicationInfo;

	// Apply security to this controller
	MySecurityClass=class<Security>(DynamicLoadObject(SecurityClass,class'class'));
    if (MySecurityClass!=None)
    {
		NewPlayer.PlayerSecurity = spawn(MySecurityClass,NewPlayer);
		if (NewPlayer.PlayerSecurity==None)
			log("Could not spawn security for player "$NewPlayer,'Security');
    }
    else if (SecurityClass == "")
    	log("No value for Engine.GameInfo.SecurityClass -- System is not secure.",'Security');
    else
	    log("Unknown security class ["$SecurityClass$"] -- System is not secure.",'Security');

	if ( bAttractCam )
		NewPlayer.GotoState('AttractMode');
	else
		NewPlayer.GotoState('Spectating');

    // Init player's name
    if( InName=="" )
        InName=DefaultPlayerName;
    if( Level.NetMode!=NM_Standalone || NewPlayer.PlayerReplicationInfo.PlayerName==DefaultPlayerName )
        ChangeName( NewPlayer, InName, false );

	// custom voicepack
    NewPlayer.PlayerReplicationInfo.VoiceTypeName = ParseOption ( Options, "Voice");

    InCharacter = ParseOption(Options, "Character");
    NewPlayer.SetPawnClass(DefaultPlayerClassName, InCharacter);
    InSex = ParseOption(Options, "Sex");
    if ( Left(InSex,3) ~= "F" )
		NewPlayer.SetPawnFemale();	// only effective if character not valid

    // Set the player's ID.
    NewPlayer.PlayerReplicationInfo.PlayerID = CurrentID++;

    if ( bSpectator || NewPlayer.PlayerReplicationInfo.bOnlySpectator || !ChangeTeam(newPlayer, InTeam, false) )
    {
        NewPlayer.PlayerReplicationInfo.bOnlySpectator = true;
        NewPlayer.PlayerReplicationInfo.bIsSpectator = true;
        NewPlayer.PlayerReplicationInfo.bOutOfLives = true;
        NumSpectators++;

        return NewPlayer;
    }

	newPlayer.StartSpot = StartSpot;

    // Init player's administrative privileges and log it
    if (AccessControl != None && AccessControl.AdminLogin(NewPlayer, InAdminName, InPassword))
    {
		AccessControl.AdminEntered(NewPlayer, InAdminName);
    }

    NumPlayers++;
	if ( NumPlayers > 20 )
		bLargeGameVOIP = true;
    bWelcomePending = true;

	if ( bTestMode )
		TestLevel();

    // if delayed start, don't give a pawn to the player yet
    // Normal for multiplayer games
    if ( bDelayedStart )
    {
        NewPlayer.GotoState('PlayerWaiting');
        return NewPlayer;
    }
    return newPlayer;
}

function TestLevel()
{
	local Actor A, Found;
	local bool bFoundErrors;

	ForEach AllActors(class'Actor', A)
	{
		bFoundErrors = bFoundErrors || A.CheckForErrors();
		if ( bFoundErrors && (Found == None) )
			Found = A;
	}

	if ( bFoundErrors )
		Found.Crash();
}

/* StartMatch()
Start the game - inform all actors that the match is starting, and spawn player pawns
*/
function StartMatch()
{
    local Controller P;
    local Actor A;

	if (GameStats!=None)
		GameStats.StartGame();

    // tell all actors the game is starting
    ForEach AllActors(class'Actor', A)
        A.MatchStarting();

    // start human players first
    for ( P = Level.ControllerList; P!=None; P=P.nextController )
        if ( P.IsA('PlayerController') && (P.Pawn == None) )
        {
            if ( bGameEnded )
                return; // telefrag ended the game with ridiculous frag limit
            else if ( PlayerController(P).CanRestartPlayer()  )
                RestartPlayer(P);
        }

    // start AI players
    for ( P = Level.ControllerList; P!=None; P=P.nextController )
        if ( P.bIsPlayer && !P.IsA('PlayerController') )
        {
			if ( Level.NetMode == NM_Standalone )
				RestartPlayer(P);
        	else
				P.GotoState('Dead','MPStart');
		}

    bWaitingToStartMatch = false;
	GameReplicationInfo.bMatchHasBegun = true;
}

// Player Can be restarted ?
function bool PlayerCanRestart( PlayerController aPlayer )
{
	return true;
}

function bool PlayerCanRestartGame( PlayerController aPlayer )
{
	return true;
}

//
// Restart a player.
//
function RestartPlayer( Controller aPlayer )
{
    local NavigationPoint startSpot;
    local int TeamNum;
    local class<Pawn> DefaultPlayerClass;
	local Vehicle V, Best;
	local vector ViewDir;
	local float BestDist, Dist;

    if( bRestartLevel && Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
        return;

    if ( (aPlayer.PlayerReplicationInfo == None) || (aPlayer.PlayerReplicationInfo.Team == None) )
        TeamNum = 255;
    else
        TeamNum = aPlayer.PlayerReplicationInfo.Team.TeamIndex;

    startSpot = FindPlayerStart(aPlayer, TeamNum);
    if( startSpot == None )
    {
        log(" Player start not found!!!");
        return;
    }

    if (aPlayer.PreviousPawnClass!=None && aPlayer.PawnClass != aPlayer.PreviousPawnClass)
        BaseMutator.PlayerChangedClass(aPlayer);

    if ( aPlayer.PawnClass != None )
        aPlayer.Pawn = Spawn(aPlayer.PawnClass,,,StartSpot.Location,StartSpot.Rotation);

    if( aPlayer.Pawn==None )
    {
        DefaultPlayerClass = GetDefaultPlayerClass(aPlayer);
        aPlayer.Pawn = Spawn(DefaultPlayerClass,,,StartSpot.Location,StartSpot.Rotation);
    }
    if ( aPlayer.Pawn == None )
    {
        log("Couldn't spawn player of type "$aPlayer.PawnClass$" at "$StartSpot);
        aPlayer.GotoState('Dead');
        if ( PlayerController(aPlayer) != None )
			PlayerController(aPlayer).ClientGotoState('Dead','Begin');
        return;
    }
    if ( PlayerController(aPlayer) != None )
		PlayerController(aPlayer).TimeMargin = -0.1;
    aPlayer.Pawn.Anchor = startSpot;
	aPlayer.Pawn.LastStartSpot = PlayerStart(startSpot);
	aPlayer.Pawn.LastStartTime = Level.TimeSeconds;
    aPlayer.PreviousPawnClass = aPlayer.Pawn.Class;

    aPlayer.Possess(aPlayer.Pawn);
    aPlayer.PawnClass = aPlayer.Pawn.Class;

    aPlayer.Pawn.PlayTeleportEffect(true, true);
    aPlayer.ClientSetRotation(aPlayer.Pawn.Rotation);
    AddDefaultInventory(aPlayer.Pawn);
    TriggerEvent( StartSpot.Event, StartSpot, aPlayer.Pawn);

    if ( bAllowVehicles && (Level.NetMode == NM_Standalone) && (PlayerController(aPlayer) != None) )
    {
		// tell bots not to get into nearby vehicles for a little while
		BestDist = 2000;
		ViewDir = vector(aPlayer.Pawn.Rotation);
		for ( V=VehicleList; V!=None; V=V.NextVehicle )
			if ( V.bTeamLocked && (aPlayer.GetTeamNum() == V.Team) )
			{
				Dist = VSize(V.Location - aPlayer.Pawn.Location);
				if ( (ViewDir Dot (V.Location - aPlayer.Pawn.Location)) < 0 )
					Dist *= 2;
				if ( Dist < BestDist )
				{
					Best = V;
					BestDist = Dist;
				}
			}

		if ( Best != None )
			Best.PlayerStartTime = Level.TimeSeconds + 8;
	}
}

function class<Pawn> GetDefaultPlayerClass(Controller C)
{
    local PlayerController PC;
    local String PawnClassName;
    local class<Pawn> PawnClass;

    PC = PlayerController( C );

    if( PC != None )
    {
        PawnClassName = PC.GetDefaultURL( "Class" );
        PawnClass = class<Pawn>( DynamicLoadObject( PawnClassName, class'Class') );

        if( PawnClass != None )
            return( PawnClass );
    }

    return( class<Pawn>( DynamicLoadObject( DefaultPlayerClassName, class'Class' ) ) );
}

//
// Called after a successful login. This is the first place
// it is safe to call replicated functions on the PlayerController.
//
event PostLogin( PlayerController NewPlayer )
{
    local class<HUD> HudClass;
    local class<Scoreboard> ScoreboardClass;

	if ( !bIsSaveGame )
	{
		// Log player's login.
		if (GameStats!=None)
		{
			GameStats.ConnectEvent(NewPlayer.PlayerReplicationInfo);
			GameStats.GameEvent("NameChange",NewPlayer.PlayerReplicationInfo.playername,NewPlayer.PlayerReplicationInfo);
		}

		if ( !bDelayedStart )
		{
			// start match, or let player enter, immediately
			bRestartLevel = false;  // let player spawn once in levels that must be restarted after every death
			if ( bWaitingToStartMatch )
				StartMatch();
			else
				RestartPlayer(newPlayer);
			bRestartLevel = Default.bRestartLevel;
		}
	}

    // tell client what hud and scoreboard to use
    if( HUDType == "" )
        log( "No HUDType specified in GameInfo", 'Log' );
    else
    {
        HudClass = class<HUD>(DynamicLoadObject(HUDType, class'Class'));

        if( HudClass == None )
            log( "Can't find HUD class "$HUDType, 'Error' );
    }

    if( ScoreBoardType != "" )
    {
        ScoreboardClass = class<Scoreboard>(DynamicLoadObject(ScoreBoardType, class'Class'));

        if( ScoreboardClass == None )
            log( "Can't find ScoreBoard class "$ScoreBoardType, 'Error' );
    }
    NewPlayer.ClientSetHUD( HudClass, ScoreboardClass );
    SetWeaponViewShake(NewPlayer);

    if ( bIsSaveGame )
		return;

    if ( NewPlayer.Pawn != None )
        NewPlayer.Pawn.ClientSetRotation(NewPlayer.Pawn.Rotation);

	if( VotingHandler != None )
		VotingHandler.PlayerJoin(NewPlayer);

	if ( AccessControl != None )
		NewPlayer.LoginDelay = AccessControl.LoginDelaySeconds;

	NewPlayer.ClientCapBandwidth(NewPlayer.Player.CurrentNetSpeed);
	NotifyLogin(NewPlayer.PlayerReplicationInfo.PlayerID);

    log("New Player"@NewPlayer.PlayerReplicationInfo.PlayerName@"id="$NewPlayer.GetPlayerIDHash());
}

function SetWeaponViewShake(PlayerController P)
{
	P.ClientSetWeaponViewShake(bWeaponShouldViewShake && bModViewShake);
}

//
// Player exits.
//
function Logout( Controller Exiting )
{
    local bool bMessage;

    bMessage = true;
    if ( PlayerController(Exiting) != None )
    {
		if ( AccessControl != None && AccessControl.AdminLogout( PlayerController(Exiting) ) )
			AccessControl.AdminExited( PlayerController(Exiting) );

        if ( PlayerController(Exiting).PlayerReplicationInfo.bOnlySpectator )
        {
            bMessage = false;
                 NumSpectators--;
        }
        else
        {
            NumPlayers--;
        }

    }
    if( bMessage && (Level.NetMode==NM_DedicatedServer || Level.NetMode==NM_ListenServer) )
        BroadcastLocalizedMessage(GameMessageClass, 4, Exiting.PlayerReplicationInfo);

	if( VotingHandler != None )
		VotingHandler.PlayerExit(Exiting);

	if ( GameStats!=None)
		GameStats.DisconnectEvent(Exiting.PlayerReplicationInfo);

    //notify mutators that a player exited
    NotifyLogout(Exiting);
}

// Called at the end of GameInfo.PostLogin()
// Notify all existing PlayerControllers that this player has joined.  Each player's ChatManager replicates
// this information to the client for matching against the client's "Restricted" list of players.  If a match is made,
// the client's copy of ChatManager notifies the server's copy so that the corresponding type of communication is not
// sent to the player.
function NotifyLogin(int NewPlayerID)
{
	local int i;
	local array<PlayerController> PCArray;

	GetPlayerControllerList(PCArray);
	for ( i = 0; i < PCArray.Length; i++ )
		PCArray[i].ServerRequestBanInfo(NewPlayerID);
}

function NotifyLogout(Controller Exiting)
{
	local Controller C;
	local PlayerController PC;

    BaseMutator.NotifyLogout(Exiting);

	if ( PlayerController(Exiting) != None && Exiting.PlayerReplicationInfo != None )
	{
		for ( C = Level.ControllerList; C != None; C = C.NextController )
		{
			PC = PlayerController(C);
			if ( PC != None && PC.ChatManager != None )
				PC.ChatManager.UnTrackPlayer(Exiting.PlayerReplicationInfo.PlayerID);
		}
	}
}

//
// Examine the passed player's inventory, and accept or discard each item.
// AcceptInventory needs to gracefully handle the case of some inventory
// being accepted but other inventory not being accepted (such as the default
// weapon).  There are several things that can go wrong: A weapon's
// AmmoType not being accepted but the weapon being accepted -- the weapon
// should be killed off. Or the player's selected inventory item, active
// weapon, etc. not being accepted, leaving the player weaponless or leaving
// the HUD inventory rendering messed up (AcceptInventory should pick another
// applicable weapon/item as current).
//
event AcceptInventory(pawn PlayerPawn)
{
    //default accept all inventory except default weapon (spawned explicitly)
}

function AddGameSpecificInventory(Pawn p)
{
    local Weapon newWeapon;
    local class<Weapon> WeapClass;

    // Spawn default weapon.
    WeapClass = BaseMutator.GetDefaultWeapon();
    if( (WeapClass!=None) && (p.FindInventoryType(WeapClass)==None) )
    {
        newWeapon = Spawn(WeapClass,,,p.Location);
        if( newWeapon != None )
        {
            newWeapon.GiveTo(p);
            newWeapon.bCanThrow = false; // don't allow default weapon to be thrown out
        }
    }
}

//
// Spawn any default inventory for the player.
//
function AddDefaultInventory( pawn PlayerPawn )
{
    local Weapon newWeapon;
    local class<Weapon> WeapClass;

    // Spawn default weapon.
    WeapClass = BaseMutator.GetDefaultWeapon();
    if( (WeapClass!=None) && (PlayerPawn.FindInventoryType(WeapClass)==None) )
    {
        newWeapon = Spawn(WeapClass,,,PlayerPawn.Location);
        if( newWeapon != None )
        {
            newWeapon.GiveTo(PlayerPawn);
            //newWeapon.BringUp();
            newWeapon.bCanThrow = false; // don't allow default weapon to be thrown out
        }
    }
    SetPlayerDefaults(PlayerPawn);
}

/* SetPlayerDefaults()
 first make sure pawn properties are back to default, then give mutators an opportunity
 to modify them
*/
function SetPlayerDefaults(Pawn PlayerPawn)
{
    PlayerPawn.AirControl = PlayerPawn.Default.AirControl;
    PlayerPawn.GroundSpeed = PlayerPawn.Default.GroundSpeed;
    PlayerPawn.WaterSpeed = PlayerPawn.Default.WaterSpeed;
    PlayerPawn.AirSpeed = PlayerPawn.Default.AirSpeed;
    PlayerPawn.Acceleration = PlayerPawn.Default.Acceleration;
    PlayerPawn.JumpZ = PlayerPawn.Default.JumpZ;
    BaseMutator.ModifyPlayer(PlayerPawn);
}

function NotifyKilled(Controller Killer, Controller Killed, Pawn KilledPawn )
{
    local Controller C;

    for ( C=Level.ControllerList; C!=None; C=C.nextController )
        C.NotifyKilled(Killer, Killed, KilledPawn);
}

function KillEvent(string Killtype, PlayerReplicationInfo Killer, PlayerReplicationInfo Victim, class<DamageType> Damage)
{
	if ( GameStats != None )
		GameStats.KillEvent(KillType, Killer, Victim, Damage);
}

function Killed( Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType )
{
	local vehicle V;

    if ( (Killed != None) && Killed.bIsPlayer )
    {
        Killed.PlayerReplicationInfo.Deaths += 1;
        Killed.PlayerReplicationInfo.NetUpdateTime = FMin(Killed.PlayerReplicationInfo.NetUpdateTime, Level.TimeSeconds + 0.3 * FRand());
        BroadcastDeathMessage(Killer, Killed, damageType);

		if ( (Killer == Killed) || (Killer == None) )
		{
			if ( Killer == None )
				KillEvent("K", None, Killed.PlayerReplicationInfo, DamageType);	//"Kill"
			else
				KillEvent("K", Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, DamageType);	//"Kill"
		}
		else
		{
			if ( bTeamGame && (Killer.PlayerReplicationInfo != None)
				&& (Killer.PlayerReplicationInfo.Team == Killed.PlayerReplicationInfo.Team) )
				KillEvent("TK", Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, DamageType);	//"Teamkill"
			else
				KillEvent("K", Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, DamageType);	//"Kill"
		}
    }
    if ( Killed != None )
	    ScoreKill(Killer, Killed);
    DiscardInventory(KilledPawn);
    NotifyKilled(Killer,Killed,KilledPawn);

    if ( bAllowVehicles && (Level.NetMode == NM_Standalone) && (PlayerController(Killed) != None) )
    {
		// tell bots not to get into nearby vehicles
		for ( V=VehicleList; V!=None; V=V.NextVehicle )
			if ( Killed.GetTeamNum() == V.Team )
				V.PlayerStartTime = 0;
	}

}

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    if ( GameRulesModifiers == None )
        return false;
    return GameRulesModifiers.PreventDeath(Killed,Killer, damageType,HitLocation);
}

function bool PreventSever(Pawn Killed,  Name boneName, int Damage, class<DamageType> DamageType)
{
    if ( GameRulesModifiers == None )
        return false;
    return GameRulesModifiers.PreventSever(Killed, boneName, Damage, DamageType);
}

function BroadcastDeathMessage(Controller Killer, Controller Other, class<DamageType> damageType)
{
    if ( (Killer == Other) || (Killer == None) )
        BroadcastLocalized(self,DeathMessageClass, 1, None, Other.PlayerReplicationInfo, damageType);
    else
        BroadcastLocalized(self,DeathMessageClass, 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, damageType);
}


// %k = Owner's PlayerName (Killer)
// %o = Other's PlayerName (Victim)
// %w = Owner's Weapon ItemName
static native function string ParseKillMessage( string KillerName, string VictimName, string DeathMessage );

function Kick( string S )
{
	if (AccessControl != None)
	    AccessControl.Kick(S);
}

function SessionKickBan( string S ) // sjs
{
	if (AccessControl != None)
	    AccessControl.SessionKickBan( S );
}

function KickBan( string S )
{
	if (AccessControl != None)
	    AccessControl.KickBan(S);
}

function bool IsOnTeam(Controller Other, int TeamNum)
{
	local int OtherTeam;

    if ( bTeamGame && (Other != None) )
    {
		OtherTeam = Other.GetTeamNum();
		if ( OtherTeam == 255 )
			return false;
		return (OtherTeam == TeamNum);
	}
    return false;
}

//-------------------------------------------------------------------------------------
// Level gameplay modification.

//
// Return whether Viewer is allowed to spectate from the
// point of view of ViewTarget.
//
function bool CanSpectate( PlayerController Viewer, bool bOnlySpectator, actor ViewTarget )
{
    return true;
}

/* Use reduce damage for teamplay modifications, etc.
*/
function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
    local int OriginalDamage;
    local armor FirstArmor, NextArmor;

    OriginalDamage = Damage;

    if( injured.PhysicsVolume.bNeutralZone )
        Damage = 0;
    else if ( injured.InGodMode() ) // God mode
        return 0;
    else if ( (injured.Inventory != None) && (damage > 0) ) //then check if carrying armor
    {
        FirstArmor = injured.inventory.PrioritizeArmor(Damage, DamageType, HitLocation);
        while( (FirstArmor != None) && (Damage > 0) )
        {
			NextArmor = FirstArmor.nextArmor;
            Damage = FirstArmor.ArmorAbsorbDamage(Damage, DamageType, HitLocation);
            FirstArmor = NextArmor;
        }
    }

    if ( GameRulesModifiers != None )
        return GameRulesModifiers.NetDamage( OriginalDamage, Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );

    return Damage;
}

//
// Return whether an item should respawn.
//
function bool ShouldRespawn( Pickup Other )
{
    if( Level.NetMode == NM_StandAlone )
        return false;

    return Other.ReSpawnTime!=0.0;
}

/* Called when pawn has a chance to pick Item up (i.e. when
   the pawn touches a weapon pickup). Should return true if
   he wants to pick it up, false if he does not want it.
*/
function bool PickupQuery( Pawn Other, Pickup item )
{
    local byte bAllowPickup;

    if ( (GameRulesModifiers != None) && GameRulesModifiers.OverridePickupQuery(Other, item, bAllowPickup) )
        return (bAllowPickup == 1);

    if ( Other.Inventory == None )
        return true;
    else
        return !Other.Inventory.HandlePickupQuery(Item);
}

/* Discard a player's inventory after he dies.
*/
function DiscardInventory( Pawn Other )
{
    Other.Weapon = None;
    Other.SelectedItem = None;
    while ( Other.Inventory != None )
        Other.Inventory.Destroy();
}

/* Try to change a player's name.
*/
function ChangeName( Controller Other, coerce string S, bool bNameChange )
{
	local Controller C;

    if( S == "" )
        return;

	S = StripColor(s);	// Stip out color codes

    Other.PlayerReplicationInfo.SetPlayerName(S);
    // notify local players
    if ( bNameChange )
		for ( C=Level.ControllerList; C!=None; C=C.NextController )
			if ( (PlayerController(C) != None) && (Viewport(PlayerController(C).Player) != None) )
				PlayerController(C).ReceiveLocalizedMessage( class'GameMessage', 2, Other.PlayerReplicationInfo );
}

/* Return whether a team change is allowed.
*/
function bool ChangeTeam(Controller Other, int N, bool bNewTeam)
{
    return true;
}

/* Return a picked team number if none was specified
*/
function byte PickTeam(byte Current, Controller C)
{
    return Current;
}

/* Send a player to a URL.
*/
function SendPlayer( PlayerController aPlayer, string URL )
{
    aPlayer.ClientTravel( URL, TRAVEL_Relative, true );
}

/* Restart the game.
*/
function RestartGame()
{
    local string NextMap;
    local MapList MyList;

    if ( (GameRulesModifiers != None) && GameRulesModifiers.HandleRestartGame() )
        return;

	if ( bGameRestarted )
		return;
    bGameRestarted = true;

	// allow voting handler to stop travel to next map
    if ( VotingHandler != None && !VotingHandler.HandleRestartGame() )
        return;

    // these server travels should all be relative to the current URL
    if ( bChangeLevels && !bAlreadyChanged && (MapListType != "") )
    {
        // open a the nextmap actor for this game type and get the next map
        bAlreadyChanged = true;
        MyList = GetMapList(MapListType);
		if (MyList != None)
		{
			NextMap = MyList.GetNextMap();
			MyList.Destroy();
		}
        if ( NextMap == "" )
            NextMap = GetMapName(MapPrefix, NextMap,1);

        if ( NextMap != "" )
        {
            Level.ServerTravel(NextMap, false);
            return;
        }
    }

    Level.ServerTravel( "?Restart", false );
}

function array<string> GetMapRotation()
{
	if ( MaplistHandler != None )
		return MaplistHandler.GetCurrentMapRotation();
}

function MapList GetMapList(string MapListClassType)
{
local class<MapList> MapListClass;

	if (MapListClassType != "")
	{
        MapListClass = class<MapList>(DynamicLoadObject(MapListClassType, class'Class'));
		if (MapListClass != None)
			return Spawn(MapListClass);
	}
	return None;
}

function ChangeVoiceChannel( PlayerReplicationInfo PRI, int NewChannelIndex, int OldChannelIndex );

//==========================================================================
// Message broadcasting functions (handled by the BroadCastHandler)

event Broadcast( Actor Sender, coerce string Msg, optional name Type )
{
    BroadcastHandler.Broadcast(Sender,Msg,Type);
}

function BroadcastTeam( Controller Sender, coerce string Msg, optional name Type )
{
    BroadcastHandler.BroadcastTeam(Sender,Msg,Type);
}

/*
 Broadcast a localized message to all players.
 Most message deal with 0 to 2 related PRIs.
 The LocalMessage class defines how the PRI's and optional actor are used.
*/
event BroadcastLocalized( actor Sender, class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
    BroadcastHandler.AllowBroadcastLocalized(Sender,Message,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);
}

//==========================================================================

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
    local Controller P;

    if ( (GameRulesModifiers != None) && !GameRulesModifiers.CheckEndGame(Winner, Reason) )
        return false;

    // all player cameras focus on winner or final scene (picked by gamerules)
    for ( P=Level.ControllerList; P!=None; P=P.NextController )
    {
        P.ClientGameEnded();
        P.GameHasEnded();
    }
    return true;
}

/* End of game.
*/
function EndGame( PlayerReplicationInfo Winner, string Reason )
{
    // don't end game if not really ready
    if ( !CheckEndGame(Winner, Reason) )
    {
        bOverTime = true;
        return;
    }

    bGameEnded = true;
    TriggerEvent('EndGame', self, None);
    EndLogging(Reason);
}

function EndLogging(string Reason)
{

	if (GameStats == None)
		return;

	GameStats.EndGame(Reason);
	GameStats.Destroy();
	GameStats = None;
}

/* Return the 'best' player start for this player to start from.
 */
function NavigationPoint FindPlayerStart( Controller Player, optional byte InTeam, optional string incomingName )
{
    local NavigationPoint N, BestStart;
    local Teleporter Tel;
    local float BestRating, NewRating;
    local byte Team;

    // always pick StartSpot at start of match
    if ( (Player != None) && (Player.StartSpot != None) && (Level.NetMode == NM_Standalone)
        && (bWaitingToStartMatch || ((Player.PlayerReplicationInfo != None) && Player.PlayerReplicationInfo.bWaitingPlayer))  )
    {
        return Player.StartSpot;
    }

    if ( GameRulesModifiers != None )
    {
        N = GameRulesModifiers.FindPlayerStart(Player,InTeam,incomingName);
        if ( N != None )
            return N;
    }

    // if incoming start is specified, then just use it
    if( incomingName!="" )
        foreach AllActors( class 'Teleporter', Tel )
            if( string(Tel.Tag)~=incomingName )
                return Tel;

    // use InTeam if player doesn't have a team yet
    if ( (Player != None) && (Player.PlayerReplicationInfo != None) )
    {
        if ( Player.PlayerReplicationInfo.Team != None )
            Team = Player.PlayerReplicationInfo.Team.TeamIndex;
        else
            Team = InTeam;
    }
    else
        Team = InTeam;

    for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
    {
        NewRating = RatePlayerStart(N,Team,Player);
        if ( NewRating > BestRating )
        {
            BestRating = NewRating;
            BestStart = N;
        }
    }

    if ( (BestStart == None) || ((PlayerStart(BestStart) == None) && (Player != None) && Player.bIsPlayer) )
    {
        log("Warning - PATHS NOT DEFINED or NO PLAYERSTART with positive rating");
		BestRating = -100000000;
        ForEach AllActors( class 'NavigationPoint', N )
        {
            NewRating = RatePlayerStart(N,0,Player);
            if ( InventorySpot(N) != None )
				NewRating -= 50;
			NewRating += 20 * FRand();
            if ( NewRating > BestRating )
            {
                BestRating = NewRating;
                BestStart = N;
            }
        }
    }

    return BestStart;
}

/* Rate whether player should choose this NavigationPoint as its start
default implementation is for single player game
*/
function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
    local PlayerStart P;

    P = PlayerStart(N);
    if ( P != None )
    {
        if ( P.bSinglePlayerStart )
        {
            if ( P.bEnabled )
                return 1000;
            return 20;
        }
        return 10;
    }
    return 0;
}

function ScoreObjective(PlayerReplicationInfo Scorer, float Score)
{
    if ( Scorer != None )
        Scorer.Score += Score;

    if ( GameRulesModifiers != None )
        GameRulesModifiers.ScoreObjective(Scorer, Score);

    CheckScore(Scorer);
}

/* CheckScore()
see if this score means the game ends
*/
function CheckScore(PlayerReplicationInfo Scorer)
{
    if ( (GameRulesModifiers != None) && GameRulesModifiers.CheckScore(Scorer) )
        return;
}

function ScoreEvent(PlayerReplicationInfo Who, float Points, string Desc)
{
	if (GameStats!=None)
		GameStats.ScoreEvent(Who,Points,Desc);
}

function TeamScoreEvent(int Team, float Points, string Desc)
{
	if ( GameStats != None )
		GameStats.TeamScoreEvent(Team, Points, Desc);
}

function ScoreKill(Controller Killer, Controller Other)
{
    if( (killer == Other) || (killer == None) )
	{
    	if ( (Other!=None) && (Other.PlayerReplicationInfo != None) )
        {
			Other.PlayerReplicationInfo.Score -= 1;
			Other.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
			ScoreEvent(Other.PlayerReplicationInfo,-1,"self_frag");
        }
	}
    else if ( killer.PlayerReplicationInfo != None )
	{
		Killer.PlayerReplicationInfo.Score += 1;
		Killer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
		Killer.PlayerReplicationInfo.Kills++;
		ScoreEvent(Killer.PlayerReplicationInfo,1,"frag");
	}

    if ( GameRulesModifiers != None )
        GameRulesModifiers.ScoreKill(Killer, Other);

    if ( (Killer != None) || (MaxLives > 0) )
        CheckScore(Killer.PlayerReplicationInfo);
}

function bool TooManyBots(Controller botToRemove)
{
    return false;
}

// Stub
static function Texture GetRandomTeamSymbol(int base) { return None; }

static function string FindTeamDesignation(GameReplicationInfo GRI, actor A)	// Should be subclassed in various team games
{
	return "";
}

// - Given a %X var return the value.

static function string ParseChatPercVar(Mutator BaseMutator, Controller Who, string Cmd)
{
	// Pass along to Mutators
	if (BaseMutator!=None)
		Cmd = BaseMutator.ParseChatPercVar(Who,Cmd);

	if (Who!=None)
		Cmd = Who.ParseChatPercVar(Cmd);

	return Cmd;
}

// - Parse out % vars for various messages

static function string ParseMessageString(Mutator BaseMutator, Controller Who, String Message)
{
	return Message;
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);  // Always begin with calling parent

	PlayInfo.AddSetting(default.BotsGroup,   "GameDifficulty",			GetDisplayText("GameDifficulty"), 		0, 2, "Select", default.GIPropsExtras[0], "Xb");

	PlayInfo.AddSetting(default.GameGroup,   "GoalScore",				GetDisplayText("GoalScore"), 			0, 0, "Text",     "3;0:999");
	PlayInfo.AddSetting(default.GameGroup,   "TimeLimit",				GetDisplayText("TimeLimit"), 			0, 0, "Text",     "3;0:999");
	PlayInfo.AddSetting(default.GameGroup,   "MaxLives",				GetDisplayText("MaxLives"), 			0, 0, "Text",     "3;0:999");
	PlayInfo.AddSetting(default.GameGroup,   "bWeaponStay",			GetDisplayText("bWeaponStay"), 			1, 0, "Check",             ,            ,    ,True);

	PlayInfo.AddSetting(default.RulesGroup,  "bAllowWeaponThrowing",	GetDisplayText("bAllowWeaponThrowing"), 1, 0, "Check",             ,            ,    ,True);
	PlayInfo.AddSetting(default.RulesGroup,  "bAllowBehindView",		GetDisplayText("bAllowBehindview"), 	1, 0, "Check",             ,            ,True,True);
	PlayInfo.AddSetting(default.RulesGroup,  "bWeaponShouldViewShake",	GetDisplayText("bWeaponShouldViewShake"),1, 0, "Check",            ,            ,    ,True);

	PlayInfo.AddSetting(default.ServerGroup, "bEnableStatLogging",		GetDisplayText("bEnableStatLogging"), 	0, 1, "Check",             ,            ,True);
	PlayInfo.AddSetting(default.ServerGroup, "bAdminCanPause",			GetDisplayText("bAdminCanPause"), 		1, 1, "Check",             ,            ,True,True);
	PlayInfo.AddSetting(default.ServerGroup, "MaxSpectators",			GetDisplayText("MaxSpectators"), 		1, 1, "Text",      "3;0:32",            ,True,True);
	PlayInfo.AddSetting(default.ServerGroup, "MaxPlayers",				GetDisplayText("MaxPlayers"), 			0, 1, "Text",      "3;0:32",            ,True);
	PlayInfo.AddSetting(default.ServerGroup, "MaxIdleTime",			GetDisplayText("MaxIdleTime"), 			0, 1, "Text",      "3;0:300",            ,True,True);

	// Add GRI's PIData
	if (default.GameReplicationInfoClass != None)
	{
		default.GameReplicationInfoClass.static.FillPlayInfo(PlayInfo);
		PlayInfo.PopClass();
	}

	if (default.VoiceReplicationInfoClass != None)
	{
		default.VoiceReplicationInfoClass.static.FillPlayInfo(PlayInfo);
		PlayInfo.PopClass();
	}

	if (default.BroadcastClass != None)
		default.BroadcastClass.static.FillPlayInfo(PlayInfo);

	else class'BroadcastHandler'.static.FillPlayInfo(PlayInfo);

	PlayInfo.PopClass();

	if (class'Engine.GameInfo'.default.VotingHandlerClass != None)
 	{
	 	class'Engine.GameInfo'.default.VotingHandlerClass.static.FillPlayInfo(PlayInfo);
	 	PlayInfo.PopClass();
	}
	else
		log("GameInfo::FillPlayInfo class'Engine.GameInfo'.default.VotingHandlerClass = None");
}

static function string GetDisplayText(string PropName)
{
	switch (PropName)
	{
		case "GameDifficulty":			return default.GIPropsDisplayText[0];
		case "bWeaponStay":				return default.GIPropsDisplayText[1];
		case "MaxSpectators":			return default.GIPropsDisplayText[4];
		case "MaxPlayers":				return default.GIPropsDisplayText[5];
		case "GoalScore":				return default.GIPropsDisplayText[6];
		case "MaxLives":				return default.GIPropsDisplayText[7];
		case "TimeLimit":				return default.GIPropsDisplayText[8];
		case "bEnableStatLogging":		return default.GIPropsDisplayText[9];
		case "bAllowWeaponThrowing":	return default.GIPropsDisplayText[10];
		case "bAllowBehindview":		return default.GIPropsDisplayText[11];
		case "bAdminCanPause":			return default.GIPropsDisplayText[12];
		case "MaxIdleTime":				return default.GIPropsDisplayText[13];
		case "bWeaponShouldViewShake":	return default.GIPropsDisplayText[14];
	}

	return "";
}

static function string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "GameDifficulty":			return default.GIPropDescText[0];
		case "bWeaponStay":				return default.GIPropDescText[1];
		case "MaxSpectators":			return default.GIPropDescText[4];
		case "MaxPlayers":				return default.GIPropDescText[5];
		case "GoalScore":				return default.GIPropDescText[6];
		case "MaxLives":				return default.GIPropDescText[7];
		case "TimeLimit":				return default.GIPropDescText[8];
		case "bEnableStatLogging":		return default.GIPropDescText[9];
		case "bAllowWeaponThrowing":	return default.GIPropDescText[10];
		case "bAllowBehindview":		return default.GIPropDescText[11];
		case "bAdminCanPause":			return default.GIPropDescText[12];
		case "MaxIdleTime":				return default.GIPropDescText[13];
		case "bWeaponShouldViewShake":	return default.GIPropDescText[14];
	}

	return Super.GetDescriptionText(PropName);
}

static event bool AcceptPlayInfoProperty(string PropName)
{
	if ( PropName == "MaxLives" )
		return false;

	return Super.AcceptPlayInfoProperty(PropName);
}

static function int OrderToIndex(int Order)
{
	return Order;
}

function ReviewJumpSpots(name TestLabel);

function string RecommendCombo(string ComboName)
{
	return ComboName;
}

function string NewRecommendCombo(string ComboName, AIController C)
{
	local string NewComboName;

	NewComboName = RecommendCombo(ComboName);
	if (NewComboName != ComboName)
		return NewComboName;

	return BaseMutator.NewRecommendCombo(ComboName, C);
}

function bool CanEnterVehicle(Vehicle V, Pawn P)
{
	return BaseMutator.CanEnterVehicle(V, P);
}

function DriverEnteredVehicle(Vehicle V, Pawn P)
{
	BaseMutator.DriverEnteredVehicle(V, P);
}

function bool CanLeaveVehicle(Vehicle V, Pawn P)
{
	return BaseMutator.CanLeaveVehicle(V, P);
}

function DriverLeftVehicle(Vehicle V, Pawn P)
{
	BaseMutator.DriverLeftVehicle(V, P);
}



function TeamInfo OtherTeam(TeamInfo Requester)
{
	return None;
}

exec function KillBots(int num);

exec function AdminSay(string Msg)
{
	local controller C;

	for( C=Level.ControllerList; C!=None; C=C.nextController )
		if( C.IsA('PlayerController') )
		{
			PlayerController(C).ClearProgressMessages();
			PlayerController(C).SetProgressTime(6);
			PlayerController(C).SetProgressMessage(0, Msg, class'Canvas'.Static.MakeColor(255,255,255));
		}
}

function RegisterVehicle(Vehicle V)
{
	// add to AI vehicle list
	V.NextVehicle = VehicleList;
	VehicleList = V;
}


function actor FindSpecGoalFor(PlayerReplicationInfo PRI, int TeamIndex)
{
	return none;
}

function int GetDefenderNum()
{
	return 255;
}

event SetGrammar()
{
	if( BeaconName!="" )
		LoadSRGrammar(BeaconName);
}

native function LoadSRGrammar( string Grammar );

// Server-only convenience function to retrieve a list of non-AI playercontrollers
function GetPlayerControllerList(out array<PlayerController> ControllerArray)
{
	local Controller C;
	local PlayerController PC;

	if ( ControllerArray.Length > 0 )
		ControllerArray.Remove(0, ControllerArray.Length);


	for (C = Level.ControllerList; C != None; C = C.NextController)
	{
		PC = PlayerController(C);
		if ( PC != None && PC.bIsPlayer && PC.PlayerReplicationInfo != None &&
		!PC.PlayerReplicationInfo.bOnlySpectator && !PC.PlayerReplicationInfo.bBot && PC.Player != None )
			ControllerArray[ControllerArray.Length] = PC;
	}
}

/* Parse voice command and give order to bot
*/
function ParseVoiceCommand( PlayerController Sender, string RecognizedString );

// Stub for UnrealMPGameInfo
static function AdjustBotInterface(bool bSinglePlayer);

// matinee Scene events
event SceneStarted( SceneManager SM, Actor Other );
event SceneEnded( SceneManager SM, Actor Other );
event SceneAbort();						// Called from PlayerController when pressing fire.

event NoTranslocatorKeyPressed( PlayerController PC );

static function array<string> GetAllLoadHints(optional bool bThisClassOnly);
static function string GetLoadingHint( PlayerController Ref, string MapName, color HintColor )
{
	local string Hint;
	local int Attempt;

	if ( Ref == None )
		return "";

	while ( Hint == "" && ++Attempt < 10 )
		Hint = ParseLoadingHint(GetNextLoadHint(MapName), Ref, HintColor);

	return Hint;
}

static function string ParseLoadingHint(string Hint, PlayerController Ref, color HintColor)
{
	local string CurrentHint, Cmd, Result;
	local int pos;

	pos = InStr(Hint, "%");
	if ( pos == -1 )
		return Hint;

	do
	{
		Cmd = "";
		Result = "";

		CurrentHint $= Left(Hint,pos);
		Hint = Mid(Hint, pos+1);

		pos = InStr(Hint, "%");
		if ( pos == -1 )
			break;

		Cmd = Left(Hint,pos);
		Hint = Mid(Hint,pos+1);
		Result = GetKeyBindName(Cmd,Ref);
		if ( Result == Cmd || Result == "" )
			break;

		CurrentHint $= MakeColorCode(default.BindColor) $ Result $ MakeColorCode(HintColor);
		pos = InStr(Hint, "%");
	} until ( Hint == "" || pos == -1 );

	if ( Result != "" && Result != Cmd )
		return CurrentHint $ Hint;

	return "";
}

static function string GetKeyBindName( string Cmd, PlayerController Ref )
{
	local string BindStr;
	local array<string> Bindings;
	local int i, idx, BestIdx, Weight, BestWeight;

	if ( Ref == None || Cmd == "" )
		return Cmd;

	BestIdx = -1;
	BindStr = Ref.ConsoleCommand("BINDINGTOKEY" @ "\"" $ Cmd $ "\"");
	if ( BindStr != "" )
	{
		Split(BindStr, ",", Bindings);
		if ( Bindings.Length > 0 )
		{
			for ( i = 0; i < Bindings.Length; i++ )
			{
				idx = int(Ref.ConsoleCommand("KEYNUMBER"@Bindings[i]));
				if ( idx != -1 )
				{
					Weight = GetBindWeight(idx);
					if ( Weight > BestWeight )
					{
						BestWeight = Weight;
						BestIdx = idx;
					}
				}
			}

			if ( BestIdx != -1 )
				return Ref.ConsoleCommand("LOCALIZEDKEYNAME"@BestIdx);
		}
	}

	return Cmd;
}

static function string GetNextLoadHint(string MapName)
{
	return "";
}

static function string MakeColorCode(color NewColor)
{
    // Text colours use 1 as 0.
    if(NewColor.R == 0)
        NewColor.R = 1;

    if(NewColor.G == 0)
        NewColor.G = 1;

    if(NewColor.B == 0)
        NewColor.B = 1;

    return Chr(0x1B)$Chr(NewColor.R)$Chr(NewColor.G)$Chr(NewColor.B);
}

static function int GetBindWeight( byte KeyNumber )
{
	// Left/Right mouse
    if ( KeyNumber == 0x01 || KeyNumber == 0x02 )
        return 100;

	// Main number & letter keys
    if ( KeyNumber >= 0x30 && KeyNumber <= 0x5A )
        return 75;

	// Space or Ctrl/Alt/Shift
    if ( KeyNumber==0x20 || (KeyNumber >= 0x10 && KeyNumber <= 0x12) )
        return 50;

	// Arrow keys
    if ( KeyNumber >= 0x25 && KeyNumber <= 0x28 )
    	return 45;

	// Middle mouse
    if ( KeyNumber==0x04 )
        return 40;

	// Mouse scroll wheel
    if ( KeyNumber == 0xEC || KeyNumber == 0xED )
        return 35;

	// Home, PgDn, etc.
    if ( KeyNumber == 0x08 || (KeyNumber >= 0x21 && KeyNumber <= 0x28) )
        return 30;

	// Number pad
    if ( KeyNumber >= 0x60 && KeyNumber <= 0x6F )
        return 25;

    return 20;
}

static function bool IsVehicleMutator( string MutatorClassName )
{
	if ( MutatorClassName ~= "Onslaught.MutBigWheels" )
		return true;
	if ( MutatorClassName ~= "Onslaught.MutWheeledVehicleStunts" )
		return true;
	if ( MutatorClassName ~= "Onslaught.MutLightweightVehicles" )
		return true;
	if ( MutatorClassName ~= "OnslaughtFull.MutVehicleArena" )
		return true;
	return false;
}

// Returns whether a mutator should be allowed with this gametype
static function bool AllowMutator( string MutatorClassName )
{
	if ( MutatorClassName == Default.MutatorClass )
		return true;

	if ( !Default.bAllowVehicles && static.IsVehicleMutator(MutatorClassName) )
		return false;

	return !class'LevelInfo'.static.IsDemoBuild();
}

static function AddServerDetail( out ServerResponseLine ServerState, string RuleName, coerce string RuleValue )
{
	local int i;

	i = ServerState.ServerInfo.Length;
	ServerState.ServerInfo.Length = i + 1;

	ServerState.ServerInfo[i].Key = RuleName;
	ServerState.ServerInfo[i].Value = RuleValue;
}


function string StripColor(string s)
{
	local int p;

    p = InStr(s,chr(27));
	while ( p>=0 )
	{
		s = left(s,p)$mid(S,p+4);
		p = InStr(s,Chr(27));
	}

	return s;
}

function bool JustStarted(float T)
{
	return ( Level.TimeSeconds < T );
}


function int MultiMinPlayers()
{
	return 0;
}

// cheat
function WeakObjectives();
function DisableNextObjective();

// hacky.  If you press use while dead, this function will get called.

function DeadUse(PlayerController PC);

defaultproperties
{
     bRestartLevel=True
     bPauseable=True
     bCanChangeSkin=True
     bCanViewOthers=True
     bDelayedStart=True
     bChangeLevels=True
     bAllowWeaponThrowing=True
     bWeaponShouldViewShake=True
     bModViewShake=True
     GoreLevel=2
     GameDifficulty=1.000000
     AutoAim=0.930000
     GameSpeed=1.000000
     HUDType="Engine.HUD"
     GoreLevelText(0)="No Gore"
     GoreLevelText(1)="Reduced Gore"
     GoreLevelText(2)="Full Gore"
     MaxSpectators=2
     MaxPlayers=16
     CurrentID=1
     DefaultPlayerName="Player"
     FearCostFallOff=0.950000
     DeathMessageClass=Class'Engine.LocalMessage'
     GameMessageClass=Class'Engine.GameMessage'
     MutatorClass="Engine.Mutator"
     AccessControlClass="Engine.AccessControl"
     BroadcastHandlerClass="Engine.BroadcastHandler"
     PlayerControllerClassName="Engine.PlayerController"
     GameReplicationInfoClass=Class'Engine.GameReplicationInfo'
     VoiceReplicationInfoClass=Class'Engine.VoiceChatReplicationInfo'
     MaplistHandlerClass=Class'Engine.MaplistManager'
     GameStatsClass="IpDrv.MasterServerGameStats"
     SecurityClass="UnrealGame.UnrealSecurity"
     GameName="Game"
     Acronym="???"
     VotingHandlerType="xVoting.xVotingHandler"
     GIPropsDisplayText(0)="Bot Skill"
     GIPropsDisplayText(1)="Weapons Stay"
     GIPropsDisplayText(2)="Reduce Gore Level"
     GIPropsDisplayText(3)="Game Speed"
     GIPropsDisplayText(4)="Max Spectators"
     GIPropsDisplayText(5)="Max Players"
     GIPropsDisplayText(6)="Goal Score"
     GIPropsDisplayText(7)="Max Lives"
     GIPropsDisplayText(8)="Time Limit"
     GIPropsDisplayText(9)="World Stats Logging"
     GIPropsDisplayText(10)="Allow Weapon Throwing"
     GIPropsDisplayText(11)="Allow Behind View"
     GIPropsDisplayText(12)="Allow Admin Pausing"
     GIPropsDisplayText(13)="Kick Idlers Time"
     GIPropsDisplayText(14)="Weapons shake view"
     GIPropDescText(0)="Set the skill of your bot opponents."
     GIPropDescText(1)="When enabled, weapons will always be available for pickup."
     GIPropDescText(2)="Enable this option to reduce the amount of blood and guts you see."
     GIPropDescText(3)="Controls how fast time passes in the game."
     GIPropDescText(4)="Sets the maximum number of spectators that can watch the game."
     GIPropDescText(5)="Sets the maximum number of players that can join this server."
     GIPropDescText(6)="The game ends when someone reaches this score."
     GIPropDescText(7)="Limits how many times players can respawn after dying."
     GIPropDescText(8)="The game ends after this many minutes of play."
     GIPropDescText(9)="Enable this option to send game statistics to the UT2004 global stats server"
     GIPropDescText(10)="When enabled, players can throw their current weapon out."
     GIPropDescText(11)="Controls whether players can switch to a third person view."
     GIPropDescText(12)="Controls whether administrators can pause the game."
     GIPropDescText(13)="Specifies how long to wait before kicking idle player from server."
     GIPropDescText(14)="When enabled, some weapons cause view shaking while firing."
     GIPropsExtras(0)="0.000000;Novice;1.000000;Average;2.000000;Experienced;3.000000;Skilled;4.000000;Adept;5.000000;Masterful;6.000000;Inhuman;7.000000;Godlike"
     CallSigns(0)="ALPHA"
     CallSigns(1)="BRAVO"
     CallSigns(2)="CHARLIE"
     CallSigns(3)="DELTA"
     CallSigns(4)="ECHO"
     CallSigns(5)="FOXTROT"
     CallSigns(6)="GOLF"
     CallSigns(7)="HOTEL"
     CallSigns(8)="INDIA"
     CallSigns(9)="JULIET"
     CallSigns(10)="KILO"
     CallSigns(11)="LIMA"
     CallSigns(12)="MIKE"
     CallSigns(13)="NOVEMBER"
     CallSigns(14)="OSCAR"
     NoBindString="[None]"
     BindColor=(G=128,R=128,A=255)
}
