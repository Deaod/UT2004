//=============================================================================
// LevelInfo contains information about the current level. There should
// be one per level and it should be actor 0. UnrealEd creates each level's
// LevelInfo automatically so you should never have to place one
// manually.
//
// The ZoneInfo properties in the LevelInfo are used to define
// the properties of all zones which don't themselves have ZoneInfo.
//=============================================================================
class LevelInfo extends ZoneInfo
	native
	nativereplication
	notplaceable;

// Textures.
//#exec Texture Import File=Textures\WireframeTexture.tga // use white square instead
#exec Texture Import File=Textures\WhiteSquareTexture.pcx
#exec Texture Import File=Textures\S_Vertex.tga Name=LargeVertex

//-----------------------------------------------------------------------------
// Level time.

// Time passage.
var float TimeDilation;          // Normally 1 - scales real time passage.

// Current time.
var           float	TimeSeconds;   // Time in seconds since level began play.
var transient int   Year;          // Year.
var transient int   Month;         // Month.
var transient int   Day;           // Day of month.
var transient int   DayOfWeek;     // Day of week.
var transient int   Hour;          // Hour.
var transient int   Minute;        // Minute.
var transient int   Second;        // Second.
var transient int   Millisecond;   // Millisecond.
var			  float	PauseDelay;		// time at which to start pause

//-----------------------------------------------------------------------------
// Level Summary Info

var(LevelSummary) localized String Title;
var(LevelSummary) String Author;
var(LevelSummary) String Description;

var(LevelSummary) Material Screenshot;
var(LevelSummary) String DecoTextName;

var(LevelSummary) int IdealPlayerCountMin;
var(LevelSummary) int IdealPlayerCountMax;

var(LevelSummary) string ExtraInfo;

var(SinglePlayer) int   SinglePlayerTeamSize;

var(RadarMap) Material RadarMapImage;
var(RadarMap) float CustomRadarRange;

var() config enum EPhysicsDetailLevel
{
	PDL_Low,
	PDL_Medium,
	PDL_High
} PhysicsDetailLevel;

var() config enum EMeshLODDetailLevel
{
	MDL_Low,
	MDL_Medium,
	MDL_High,
	MDL_Ultra
} MeshLODDetailLevel;


// Karma - jag
var(Karma) float KarmaTimeScale;		// Karma physics timestep scaling.
var(Karma) float RagdollTimeScale;		// Ragdoll physics timestep scaling. This is applied on top of KarmaTimeScale.
var(Karma) int   MaxRagdolls;			// Maximum number of simultaneous rag-dolls.
var(Karma) float KarmaGravScale;		// Allows you to make ragdolls use lower friction than normal.
var(Karma) bool  bKStaticFriction;		// Better rag-doll/ground friction model, but more CPU.

var()	   bool bKNoInit;				// Start _NO_ Karma for this level. Only really for the Entry level.
// jag

var			int	LastTaunt[2];				// 'Global' last taunts used.

var config float	DecalStayScale;		// affects decal stay time

var() localized string LevelEnterText;  // Message to tell players when they enter.
var()           string LocalizedPkg;    // Package to look in for localizations.
var             PlayerReplicationInfo Pauser;          // If paused, name of person pausing the game.
var		LevelSummary Summary;
var           string VisibleGroups;		    // List of the group names which were checked when the level was last saved
//-----------------------------------------------------------------------------
// Flags affecting the level.

var(LevelSummary) bool HideFromMenus;
var() bool           bLonePlayer;     // No multiplayer coordination, i.e. for entranceways.
var bool             bBegunPlay;      // Whether gameplay has begun.
var bool             bPlayersOnly;    // Only update players.
var bool			 bFreezeKarma;    // Stop all Karma physics from being evolved.
var const EDetailMode	DetailMode;   // Client detail mode.
var bool			 bDropDetail;	  // frame rate is below DesiredFrameRate, so drop high detail actors
var bool			 bAggressiveLOD;  // frame rate is well below DesiredFrameRate, so make LOD more aggressive
var bool             bStartup;        // Starting gameplay.
var config bool		 bLowSoundDetail;
var	bool			 bPathsRebuilt;	  // True if path network is valid
var bool			 bHasPathNodes;
var	bool			bLevelChange;
var globalconfig bool bShouldPreload;	// if true, preload all skins (initially set true if > 512 MB of system memory)
var globalconfig bool bDesireSkinPreload; // user set property
var globalconfig bool bKickLiveIdlers;	// if true, even playercontrollers with pawns can be kicked for idling
var bool			bSkinsPreloaded;	// set after skins are preloaded
var bool bClassicView;					// FOV at least 90, eyeheight up, small weapons OBSOLETE
var(RadarMap) bool bShowRadarMap;
var(RadarMap) bool bUseTerrainForRadarRange;
var bool bIsSaveGame;					// true while save game is being loaded (GameInfo bIsSaveGame stays true through entire game)
var(SaveGames) bool bSupportSaveGames;		// needs to be true to support savegames

//-----------------------------------------------------------------------------
// Renderer Management.
var config bool bNeverPrecache;

var() int			LevelTextureLODBias;
var float AnimMeshGlobalLOD;   //State of the dDynamic LOD reduction for animating meshes.

//-----------------------------------------------------------------------------
// Legend - used for saving the viewport camera positions
var() vector  CameraLocationDynamic;
var() vector  CameraLocationTop;
var() vector  CameraLocationFront;
var() vector  CameraLocationSide;
var() rotator CameraRotationDynamic;

//-----------------------------------------------------------------------------
// Audio properties.

var(Audio) string	Song;			// Filename of the streaming song.
var(Audio) float	PlayerDoppler;	// Player doppler shift, 0=none, 1=full.
var(Audio) float	MusicVolumeOverride;

//-----------------------------------------------------------------------------
// Miscellaneous information.

var() float Brightness;

var texture DefaultTexture;
var texture WireframeTexture;
var texture WhiteSquareTexture;
var texture LargeVertex;
var int HubStackLevel;
var transient enum ELevelAction
{
	LEVACT_None,
	LEVACT_Loading,
	LEVACT_Saving,
	LEVACT_Connecting,
	LEVACT_Precaching
} LevelAction;

var transient GameReplicationInfo GRI;

//-----------------------------------------------------------------------------
// Networking.

var enum ENetMode
{
	NM_Standalone,        // Standalone game.
	NM_DedicatedServer,   // Dedicated server, no local client.
	NM_ListenServer,      // Listen server.
	NM_Client             // Client only, no local server.
} NetMode;
var string ComputerName;  // Machine's name according to the OS.
var string EngineVersion; // Engine version.
var string MinNetVersion; // Min engine version that is net compatible.

//-----------------------------------------------------------------------------
// Gameplay rules

var() string DefaultGameType;
var() string PreCacheGame;
var GameInfo Game;
var float DefaultGravity;
var float LastVehicleCheck;
var() float StallZ;	//vehicles stall if they reach this

//-----------------------------------------------------------------------------
// Navigation point and Pawn lists (chained using nextNavigationPoint and nextPawn).

var const NavigationPoint NavigationPointList;
var const Controller ControllerList;
var private PlayerController LocalPlayerController;		// player who is client here

//-----------------------------------------------------------------------------
// Headlights
var(Headlights) bool	bUseHeadlights;
var(Headlights)	float	HeadlightScaling;

//-----------------------------------------------------------------------------
// Server related.

var string NextURL;
var bool bNextItems;
var float NextSwitchCountdown;

//-----------------------------------------------------------------------------
// Global object recycling pool.

var transient ObjectPool	ObjectPool;

//-----------------------------------------------------------------------------
// Additional resources to precache (e.g. Playerskins).

var transient array<material>	PrecacheMaterials;
var transient array<staticmesh> PrecacheStaticMeshes;

// common static mesh (for camouflage combo)

var(Camouflage) StaticMesh IndoorCamouflageMesh;
var(Camouflage) float IndoorMeshDrawscale;
var(Camouflage) StaticMesh OutdoorCamouflageMesh;
var(Camouflage) float OutdoorMeshDrawscale;

// When kicking up dust in this level - what colour to use?
var(DustColor) color DustColor;
var(DustColor) color WaterDustColor;


//-----------------------------------------------------------------------------
// Replication/Networking
var float MoveRepSize;
var globalconfig float MaxClientFrameRate;

// speed hack detection
var globalconfig float MaxTimeMargin;
var globalconfig float TimeMarginSlack;
var globalconfig float MinTimeMargin;


// these two properties are valid only during replication
var const PlayerController ReplicationViewer;	// during replication, set to the playercontroller to
												// which actors are currently being replicated
var const Actor  ReplicationViewTarget;				// during replication, set to the viewtarget to
												// which actors are currently being replicated

//-----------------------------------------------------------------------------
// Functions.

native simulated function DetailChange(EDetailMode NewDetailMode);
native simulated function bool IsEntry();
native simulated function UpdateDistanceFogLOD(float LOD);
native simulated function ForceLoadTexture(Texture Texture);
native simulated function PhysicsVolume GetPhysicsVolume(vector Loc);		// returns PhysicsVolume which encompasses Loc

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	DecalStayScale = Max(DecalStayScale,0);
}

simulated function class<GameInfo> GetGameClass()
{
	local class<GameInfo> G;

	if(Level.Game != None)
		return Level.Game.Class;

	if (GRI != None && GRI.GameClass != "")
		G = class<GameInfo>(DynamicLoadObject(GRI.GameClass,class'Class'));
	if(G != None)
		return G;

	if ( DefaultGameType != "" )
		G = class<GameInfo>(DynamicLoadObject(DefaultGameType,class'Class'));

	return G;
}

simulated event FillPrecacheMaterialsArray( bool FullPrecache )
{
	local Actor A;
	local class<GameInfo> G;
	local bool bRealDesire;

	if ( NetMode == NM_DedicatedServer )
		return;
	if ( !bSkinsPreloaded || FullPrecache )
	{
		if ( Game != None )
			G = Game.Class;
		else if ( (GRI != None) && (GRI.GameClass != "") )
			G = class<GameInfo>(DynamicLoadObject(GRI.GameClass,class'Class'));
		if ( G != None )
		{
			G.Static.PreCacheGameTextures(self);
			bSkinsPreloaded = true;
		}
		if ( (G == None) && (DefaultGameType != "") )
			G = class<GameInfo>(DynamicLoadObject(DefaultGameType,class'Class'));
		if ( G == None )
			G = class<GameInfo>(DynamicLoadObject(PreCacheGame,class'Class'));
		if ( G != None )
		{
			bRealDesire = bDesireSkinPreload;
			bDesireSkinPreload = false;
			G.Static.PreCacheGameTextures(self);
			bDesireSkinPreload = bRealDesire;
		}
	}
	ForEach AllActors(class'Actor',A)
	{
		if ( !A.bAlreadyPrecachedMaterials || FullPrecache )
		{
			A.UpdatePrecacheMaterials();
			A.bAlreadyPrecachedMaterials = true;
		}
	}
}

// OBSOLETE
simulated function PrecacheAnnouncements();

simulated event FillPrecacheStaticMeshesArray( bool FullPrecache )
{
	local Actor A;
	local class<GameInfo> G;

	if ( NetMode == NM_DedicatedServer )
		return;
	if ( Game == None )
	{
		if ( (GRI != None) && (GRI.GameClass != "") )
			G = class<GameInfo>(DynamicLoadObject(GRI.GameClass,class'Class'));
		if ( (G == None) && (DefaultGameType != "") )
			G = class<GameInfo>(DynamicLoadObject(DefaultGameType,class'Class'));
		if ( G == None )
			G = class<GameInfo>(DynamicLoadObject(PreCacheGame,class'Class'));
		if ( G != None )
			G.Static.PreCacheGameStaticMeshes(self);
	}

	ForEach AllActors(class'Actor',A)
		if ( !A.bAlreadyPrecachedMeshes || FullPrecache )
		{
			A.UpdatePrecacheStaticMeshes();
			A.bAlreadyPrecachedMeshes = true;
		}
}

simulated function AddPrecacheMaterial(Material mat)
{
    local int Index;

	if ( NetMode == NM_DedicatedServer )
		return;
    if (mat == None)
        return;

    Index = Level.PrecacheMaterials.Length;
    PrecacheMaterials.Insert(Index, 1);
	PrecacheMaterials[Index] = mat;
}

simulated function AddPrecacheStaticMesh(StaticMesh stat)
{
    local int Index;

	if ( NetMode == NM_DedicatedServer )
		return;
    if (stat == None)
        return;

    Index = Level.PrecacheStaticMeshes.Length;
    PrecacheStaticMeshes.Insert(Index, 1);
	PrecacheStaticMeshes[Index] = stat;
}

//
// Return the URL of this level on the local machine.
//
native simulated function string GetLocalURL();

//
// Demo build flag
//
native simulated static final function bool IsDemoBuild();  // True if this is a demo build.

// software rendering flag
native simulated static final function bool IsSoftwareRendering();

//
// Return the URL of this level, which may possibly
// exist on a remote machine.
//
native simulated function string GetAddressURL();

//
// Returns whether we are currently in the process of connecting to a URL
//
native simulated function bool IsPendingConnection();

//
// Jump the server to a new level.
//
event ServerTravel( string URL, bool bItems )
{
	if ( InStr(url,"%")>=0 )
	{
		log("URL Contains illegal character '%'.");
		return;
	}

	if (InStr(url,":")>=0 || InStr(url,"/")>=0 || InStr(url,"\\")>=0)
	{
		log("URL blocked");
		return;
	}

	if( NextURL=="" )
	{
		bLevelChange = true;
		bNextItems          = bItems;
		NextURL             = URL;
		if( Game!=None )
			Game.ProcessServerTravel( URL, bItems );
		else
			NextSwitchCountdown = 0;
	}
}

//
// ensure the DefaultPhysicsVolume class is loaded.
//
function ThisIsNeverExecuted()
{
	local DefaultPhysicsVolume P;
	P = None;
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	DefaultGravity =  Default.DefaultGravity;

	// perform garbage collection of objects (not done during gameplay)
	ConsoleCommand("OBJ GARBAGE");
	Super.Reset();
}

//-----------------------------------------------------------------------------
// Network replication.

replication
{
	reliable if( bNetDirty && Role==ROLE_Authority )
		Pauser, TimeDilation, DefaultGravity;

	reliable if( bNetInitial && Role==ROLE_Authority )
		RagdollTimeScale, KarmaTimeScale, KarmaGravScale;
}

//
//	PreBeginPlay
//

simulated event PreBeginPlay()
{
	// Create the object pool.
	Super.PreBeginPlay();

	ObjectPool = new(xLevel) class'ObjectPool';
}

simulated function PlayerController GetLocalPlayerController()
{
	local PlayerController PC;

	if ( Level.NetMode == NM_DedicatedServer )
		return None;
	if ( LocalPlayerController != None )
		return LocalPlayerController;

	ForEach DynamicActors(class'PlayerController', PC)
	{
		if ( Viewport(PC.Player) != None )
		{
			LocalPlayerController = PC;
			break;
		}
	}
	return LocalPlayerController;
}

defaultproperties
{
     TimeDilation=1.100000
     Title="Untitled"
     Author="Anonymous"
     IdealPlayerCountMin=6
     IdealPlayerCountMax=10
     CustomRadarRange=10000.000000
     PhysicsDetailLevel=PDL_Medium
     MeshLODDetailLevel=MDL_Medium
     KarmaTimeScale=0.900000
     RagdollTimeScale=1.000000
     MaxRagdolls=4
     KarmaGravScale=1.000000
     bKStaticFriction=True
     DecalStayScale=1.000000
     VisibleGroups="None"
     DetailMode=DM_SuperHigh
     bShowRadarMap=True
     bUseTerrainForRadarRange=True
     AnimMeshGlobalLOD=1.000000
     MusicVolumeOverride=-1.000000
     Brightness=1.000000
     DefaultTexture=Texture'Engine.DefaultTexture'
     WireframeTexture=Texture'Engine.WhiteSquareTexture'
     WhiteSquareTexture=Texture'Engine.WhiteSquareTexture'
     LargeVertex=Texture'Engine.LargeVertex'
     PreCacheGame="xGame.xDeathMatch"
     DefaultGravity=-950.000000
     StallZ=10000.000000
     bUseHeadlights=True
     HeadlightScaling=1.000000
     IndoorMeshDrawscale=1.000000
     OutdoorMeshDrawscale=1.000000
     WaterDustColor=(B=255,G=255,R=255)
     MoveRepSize=42.000000
     MaxClientFrameRate=90.000000
     MaxTimeMargin=1.000000
     TimeMarginSlack=1.350000
     MinTimeMargin=-1.000000
     bWorldGeometry=True
     bAlwaysRelevant=True
     RemoteRole=ROLE_DumbProxy
     bHiddenEd=True
}
