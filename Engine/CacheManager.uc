//==============================================================================
//	This class manages all cached record types for the game.
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class CacheManager extends Object
	native
	noexport
	transient;

struct native init GameRecord
{
	var() const     string      ClassName;
	var() const     string      GameName;
	var() const     string      Description;
	var() const     string      TextName;                    // deco reference
	var() const     string      GameAcronym;
	var() const     string      MapListClassName;
	var() const     string      MapPrefix;
	var() const     string      ScreenshotRef;               // Gametype screenshot
	var() const     string      HUDMenu;                     // Optional custom HUD settings menu for a gametype
	var() const     string      RulesMenu;                   // Optional custom rule menu for a gametype
	var() const     bool        bTeamGame;                   // Whether this is a team gametype
	var() const     byte        GameTypeGroup;               // 0 - UT2003, 1 - Bonus Pack, 2 - UT2004, 3 - Custom
	var   const     int         RecordIndex;
};

struct native init MutatorRecord
{
    var() const     string      ClassName;
    var() const     string      FriendlyName;
    var() const     string      Description;
    var() const     string      IconMaterialName;
    var() const     string      ConfigMenuClassName;
    var() const     string      GroupName;
    var   const     int         RecordIndex;
    var   const     byte        bActivated;
};

struct native init MapRecord
{
	var() const     string      Acronym;
	var() const     string      MapName;                    // Full map filename (no extension)
	var() const     string      TextName;                   // deco text reference
	var() const     string      FriendlyName;               // optional mapname
	var() const     string      Author;                     // Author's name
	var() const     string      Description;                // Filled by deco text, or levelsummary
	var() const     int         PlayerCountMin;             // Recommended minplayer count
	var() const     int         PlayerCountMax;             // Recommended maxplayer count
	var() const     string      ScreenshotRef;
	var() const		string		ExtraInfo;
	var   const     int         RecordIndex;
};

struct native init WeaponRecord
{
	var() const     string      ClassName;
	var() const     string      PickupClassName;
	var() const     string      AttachmentClassName;
	var() const     string      Description;
	var() const     string      TextName;
	var() const     string      FriendlyName;
	var   const     int         RecordIndex;
};

struct native init VehicleRecord
{
	var() const     string      ClassName;
	var() const     string      FriendlyName;
	var() const     string      Description;
	var   const     int         RecordIndex;
};

struct native init CrosshairRecord
{
	var() const     string      FriendlyName;
	var() const     texture     CrosshairTexture;
	var   const     int         RecordIndex;
};

struct native init AnnouncerRecord
{
	var() const     string      ClassName;
	var() const     string      FriendlyName;
	var() const     string      PackageName;
	var() const     string      FallbackPackage;
	var() const     bool        bEnglishOnly;
	var   const     int         RecordIndex;
};

struct native Standard
{
	var() const array<string> Classes, Maps;
};

var() private const array<Standard>        DefaultContent;
var() private const array<MutatorRecord>   CacheMutators;
var() private const array<MapRecord>       CacheMaps;
var() private const array<WeaponRecord>    CacheWeapons;
var() private const array<VehicleRecord>   CacheVehicles;
var() private const array<CrosshairRecord> CacheCrosshairs;
var() private const array<GameRecord>      CacheGameTypes;
var() private const array<AnnouncerRecord> CacheAnnouncers;

var protected const native pointer         FileManager;
var protected const native pointer         Tracker;

native(800)	final 			static function InitCache();

native(801) final simulated static function bool Is2003Content(    string Item );
native(802) final simulated static function bool Is2004Content(    string Item );
native(803) final simulated static function bool IsBPContent(      string Item );
native(830) final simulated static function bool IsDefaultContent( string Item );

// 0 - UT2003, 1 - Bonus Pack, 2 - UT2004, 3 - Custom
native(804) final simulated static function GetGameTypeList(  out array<GameRecord>      GameRecords, optional string FilterType );
native(805) final simulated static function GetMapList(       out array<MapRecord>       MapRecords,  optional string Acronym    );
native(806) final simulated static function GetWeaponList(    out array<WeaponRecord>    WeaponRecords                           );
native(807) final simulated static function GetVehicleList(   out array<VehicleRecord>   VehicleRecords                          );
native(808) final simulated static function GetCrosshairList( out array<CrosshairRecord> CrosshairRecords                        );
native(809) final simulated static function GetMutatorList(   out array<MutatorRecord>   MutatorRecords                          );
native(810) final simulated static function GetAnnouncerList( out array<AnnouncerRecord> AnnouncerRecords                        );

// Not actually hooked up to cache (.int search)
native(811) final simulated static function GetTeamSymbolList(out array<string> SymbolNames, optional bool bNoSinglePlayer);

native(818) final simulated static function GameRecord GetGameRecord ( coerce string ClassName);
native(819) final simulated static function MapRecord GetMapRecord ( string MapName );
native(880) final simulated static function MutatorRecord GetMutatorRecord( coerce string ClassName );
native(881) final simulated static function WeaponRecord GetWeaponRecord( coerce string ClassName );
native(882) final simulated static function VehicleRecord GetVehicleRecord( coerce string ClassName );
native(883) final simulated static function AnnouncerRecord GetAnnouncerRecord( coerce string ClassName );

defaultproperties
{
     DefaultContent(0)=(Classes=("UTClassic.MutUTClassic","UnrealGame.MutLowGrav","UnrealGame.MutBigHead","XGame.xTeamGame","XGame.xDeathMatch","XGame.xCTFGame","XGame.InstagibCTF","XGame.xVehicleCTFGame","XGame.xDoubleDom","XGame.xBombingRun","XGame.MutRegen","XGame.MutInstaGib","XGame.MutQuadJump","XGame.MutSpeciesStats","XGame.MutVampire","XGame.MutSlomoDeath","XGame.MutNoAdrenaline","XGame.MutZoomInstagib","XWeapons.Translauncher","XWeapons.ShockRifle","XWeapons.LinkGun","XWeapons.MutArena","XWeapons.Minigun","XWeapons.BioRifle","XWeapons.FlakCannon","XWeapons.RocketLauncher","XWeapons.ShieldGun","XWeapons.SniperRifle","XWeapons.Painter","XWeapons.MutNoSuperWeapon","XWeapons.AssaultRifle","XWeapons.Redeemer","Vehicles.Bulldog"),Maps=("BR-Anubis","BR-Bifrost","BR-Disclosure","BR-IceFields","BR-Skyline","BR-Slaughterhouse","BR-TwinTombs","CTF-Chrome","CTF-Citadel","CTF-December","CTF-Face3","CTF-Geothermal","CTF-Lostfaith","CTF-Magma","CTF-Maul","CTF-Orbital2","DM-Antalus","DM-Asbestos","DM-Compressed","DM-Flux2","DM-Gael","DM-Inferno","DM-Insidious","DM-Leviathan","DM-Oceanic","DM-Phobos2","DM-Plunge","DM-1on1-Serpentine","DM-TokaraForest","DM-TrainingDay","DOM-Core","DOM-OutRigger","DOM-Ruination","DOM-ScorchedEarth","DOM-SepukkuGorge","DOM-Suntemple","TUT-BR","TUT-CTF","TUT-DM","TUT-DOM2"))
     DefaultContent(1)=(Classes=("BonusPack.xLastManStandingGame","BonusPack.xMutantGame","BonusPack.MutCrateCombo","SkaarjPack.Invasion"),Maps=("BR-Canyon","CTF-Avaris","CTF-DoubleDammage","DM-1on1-Crash","DM-1on1-Mixer","DM-Icetomb","DM-Injector","DM-IronDeity","DM-Rustatorium","DOM-Junkyard","BR-DE-ElecFields","CTF-DE-ElecFields","CTF-DE-LavaGiant2","DM-DE-GrendelKeep","DM-DE-Ironic","DM-DE-Osiris2"))
     DefaultContent(2)=(Classes=("XInterface.DefaultCrosshairs","Onslaught.ONSCrosshairs","UTClassic.MutUseSniper","UTClassic.MutUseLightning","Onslaught.ONSOnslaughtGame","Onslaught.MutOnslaughtWeapons","Onslaught.ONSAVRiL","Onslaught.ONSGrenadeLauncher","Onslaught.ONSMineLayer","Onslaught.MutLightweightVehicles","UT2k4Assault.ASGameInfo","UTClassic.ClassicSniperRifle","UnrealGame.FemaleAnnouncer","UnrealGame.MaleAnnouncer","UnrealGame.SexyFemaleAnnouncer"),Maps=("AS-Convoy","AS-FallenCity","AS-Glacier","AS-MotherShip","AS-RobotFactory","AS-Junkyard","BR-BridgeOfFate","BR-Colossus","BR-Serenity","CTF-AbsoluteZero","CTF-Colossus","CTF-Grendelkeep","CTF-MoonDragon","DM-1on1-Albatross","DM-1on1-Idoma","DM-1on1-Irondust","DM-1on1-Roughinery","DM-1on1-Spirit","DM-1on1-Squader","DM-1on1-Trite","DM-1on1-Desolation","DM-Corrugation","DM-Gestalt","DM-Goliath","DM-Hyperblast2","DM-Junkyard","DM-Metallurgy","DM-Morpheus3","DM-Rankin","DM-Rrajigar","DM-Sulphur","DOM-Atlantis","DOM-Aswan","DOM-Conduit","DOM-Renascent","ONS-ArcticStronghold","ONS-Crossfire","ONS-Torlan","CTF-1on1-Joust","CTF-BridgeOfFate","CTF-Grassyknoll","CTF-Smote","DM-DesertIsle","DOM-Access","ONS-Dria","ONS-Severance","ONS-RedPlanet","ONS-Dawn","CTF-FaceClassic","CTF-January","DM-Curse4","DM-Deck17","ONS-Frostbite","TUT-ONS","CTF-TwinTombs","ONS-Primeval","ONS-Adara","ONS-Aridoom","ONS-Ascendancy","ONS-IslandHop","ONS-Tricky","ONS-Urban"))
     DefaultContent(3)=(Classes=("OnslaughtFull.MutVehicleArena","OnslaughtFull.ONSBomber","OnslaughtFull.ONSPainter","OnslaughtFull.ONSMobileAssaultStation","UT2k4AssaultFull.ASVehicle_SpaceFighter_Human","UT2k4AssaultFull.ASVehicle_SpaceFighter_Skaarj","XGame.MutUDamageReward","UTV2004s.utvMutator"),Maps=("MOV-UT2004-Intro","Mov-UT2-intro"))
}
