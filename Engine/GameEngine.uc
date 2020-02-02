//=============================================================================
// GameEngine: The game subsystem.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class GameEngine extends Engine
	native
	noexport
	transient;

// URL structure.
struct URL
{
	var string			Protocol,	// Protocol, i.e. "unreal" or "http".
						Host;		// Optional hostname, i.e. "204.157.115.40" or "unreal.epicgames.com", blank if local.
	var int				Port;		// Optional host port.
	var string			Map;		// Map name, i.e. "SkyCity", default is "Index".
	var array<string>	Op;			// Options.
	var string			Portal;		// Portal to enter through, default is "".
	var int				Valid;
};

var Level			GLevel,
					GEntry;
var PendingLevel	GPendingLevel;
var URL				LastURL;
var config array<string>  ServerActors,
					      ServerPackages;

var array<object>         DummyArray;	// Do not modify
var object                DummyObject;  // Do not modify
var string				  DummyString;	// Do not modify

var globalconfig String MainMenuClass;			// Menu that appears when you first start
var globalconfig string SinglePlayerMenuClass;	// Menu that appears when you return from a single player match after a cinematic game
var globalconfig String ConnectingMenuClass;	// Menu that appears when you are connecting
var globalconfig String DisconnectMenuClass;	// Menu that appears when you are disconnected
var globalconfig String LoadingClass;			// Loading screen that appears

var                  bool bCheatProtection;
var(Settings) config bool ColorHighDetailMeshes;
var(Settings) config bool ColorSlowCollisionMeshes;
var(Settings) config bool ColorNoCollisionMeshes;
var(Settings) config bool ColorWorldTextures;
var(Settings) config bool ColorPlayerAndWeaponTextures;
var(Settings) config bool ColorInterfaceTextures;

var(VoiceChat) globalconfig bool VoIPAllowVAD;

defaultproperties
{
     ServerActors(0)="IpDrv.MasterServerUplink"
     ServerActors(1)="UWeb.WebServer"
     ServerPackages(0)="Core"
     ServerPackages(1)="Engine"
     ServerPackages(2)="Fire"
     ServerPackages(3)="Editor"
     ServerPackages(4)="IpDrv"
     ServerPackages(5)="UWeb"
     ServerPackages(6)="GamePlay"
     ServerPackages(7)="UnrealGame"
     ServerPackages(8)="XEffects"
     ServerPackages(9)="XPickups"
     ServerPackages(10)="XGame"
     ServerPackages(11)="XWeapons"
     ServerPackages(12)="XInterface"
     ServerPackages(13)="Vehicles"
     ServerPackages(14)="TeamSymbols_UT2003"
     ServerPackages(15)="TeamSymbols_UT2004"
     ServerPackages(16)="BonusPack"
     ServerPackages(17)="SkaarjPack_rc"
     ServerPackages(18)="SkaarjPack"
     ServerPackages(19)="UTClassic"
     ServerPackages(20)="UT2k4Assault"
     ServerPackages(21)="Onslaught"
     ServerPackages(22)="GUI2K4"
     ServerPackages(23)="UT2k4AssaultFull"
     ServerPackages(24)="OnslaughtFull"
     ServerPackages(25)="xVoting"
     MainMenuClass="GUI2K4.UT2K4MainMenu"
     SinglePlayerMenuClass="GUI2K4.UT2K4SP_Main"
     ConnectingMenuClass="GUI2K4.UT2K4ServerLoading"
     DisconnectMenuClass="GUI2K4.UT2K4DisconnectOptionPage"
     LoadingClass="GUI2K4.UT2K4SP_LadderLoading"
     CacheSizeMegs=32
}
