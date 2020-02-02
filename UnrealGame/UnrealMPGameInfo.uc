//=============================================================================
// UnrealMPGameInfo.
//
//
//=============================================================================
class UnrealMPGameInfo extends GameInfo
	HideDropDown
	CacheExempt
	config;

// Sort of a hack here to keep single player and multiplayer bot options seperate without having two properties
// 0: SP - Use MinPlayers 1: SP - Use Map defaults 2: SP - Use Roster
// 4: MP - UseMinPlayers 8: MP: Use Roster	16: players vs bots
var globalconfig byte		BotMode;
var globalconfig int		MinPlayers;			// bots fill in to guarantee this level in net game
var globalconfig float		EndTimeDelay;
var globalconfig float		BotRatio;			// only used when bPlayersVsBots is true

var bool 		bPreloadAllSkins;	// OBSOLETE
var              string     DefaultVoiceChannel; // default active channel for incoming players
var config		 bool		bAllowPrivateChat;	// Allow private chat channels on this server
var bool					bTeamScoreRounds;
var bool					bSoaking;
var bool			bPlayersVsBots;

var float EndTime;
var TranslocatorBeacon BeaconList;
var SpecialVehicleObjective SpecialVehicleObjectives;
var class<Scoreboard> LocalStatsScreenClass;
var() string VoiceReplicationInfoType;

// mc - localized PlayInfo descriptions & extra info
const MPPROPNUM = 4;
var localized string MPGIPropsDisplayText[MPPROPNUM];
var localized string MPGIPropDescText[MPPROPNUM];
var localized string BotModeText;

// <hack>
var localized string SPBotText, MPBotText, SPBotDesc, MPBotDesc, BotOptions[4];
// </hack>

var MasterServerUplink MSUplink;
var bool bMSUplinkSet;

event PreLogin
(
    string Options,
    string Address,
    string PlayerID,
    out string Error,
    out string FailCode
)
{

	local MasterServerUplink MSU;

	super.PreLogin(Options,Address,PlayerID, Error, FailCode);
	if (Error=="" && FailCode == "")
	{
		if (!bMSUplinkSet)
		{
			foreach AllActors(class'MasterServerUplink',MSU)
			{
				MSUplink = MSU;
			}
			bMSUplinkSet = true;
		}

		if (bMSUplinkSet && MSUplink!=None)
		{
			MSUplink.ForceGameStateRefresh(5);
		}

	}
}
event PlayerController Login
(
    string Portal,
    string Options,
    out string Error
)
{
	local PlayerController PC;

	PC = Super.Login( Portal, Options, Error );

	if ( PC != None )
	{
		if ( Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer )
		{
			PC.VoiceReplicationInfo = VoiceReplicationInfo;
			if ( Level.NetMode == NM_ListenServer && Level.GetLocalPlayerController() == PC )
				PC.InitializeVoiceChat();
		}
	}

	return PC;
}
// rjp --
function InitVoiceReplicationInfo()
{
	local class<VoiceChatReplicationInfo> VRIClass;
	local int i;

	if (Level.NetMode == NM_StandAlone || Level.NetMode == NM_Client)
		return;

	if ( VoiceReplicationInfoType != "" )
	{
		VRIClass = class<VoiceChatReplicationInfo>(DynamicLoadObject(VoiceReplicationInfoType,class'Class'));
		if ( VRIClass != None )
			VoiceReplicationInfoClass = VRIClass;
	}

    if (VoiceReplicationInfoClass != None && VoiceReplicationInfo == None)
	    VoiceReplicationInfo = Spawn(VoiceReplicationInfoClass);

	Super.InitVoiceReplicationInfo();
	VoiceReplicationInfo.bPrivateChat = bAllowPrivateChat;

	i = VoiceReplicationInfo.GetChannelIndex(DefaultVoiceChannel);
	if ( i != -1 && i != VoiceReplicationInfo.DefaultChannel )
		VoiceReplicationInfo.DefaultChannel = i;
}

function InitMaplistHandler()
{
	local class<MaplistManagerBase> MaplistManagerClass;

	if ( MaplistHandler != None )
		return;

	if ( MaplistHandlerType !="" )
		MaplistManagerClass = class<MaplistManagerBase>(DynamicLoadObject(MaplistHandlerType, class'Class'));

	if ( MaplistManagerClass == None )
		MaplistManagerClass = MaplistHandlerClass;

	if ( MaplistManagerClass != None )
		MaplistHandler = Spawn(MaplistManagerClass);
}

function ChangeVoiceChannel( PlayerReplicationInfo PRI, int NewChannelIndex, int OldChannelIndex )
{
	local VoiceChatRoom NewChannel, OldChannel;

	if ( PRI == None )
	{
		log("ChangeVoiceChannel - no PRI!",'VoiceChat');
		return;
	}

	if ( VoiceReplicationInfo == None )
	{
		log("ChangeVoiceChannel - no VoiceReplicationInfo!",'VoiceChat');
		return;
	}

	if ( NewChannelIndex >= 0 )
	{
		NewChannel = VoiceReplicationInfo.GetChannelAt(NewChannelIndex);
		if ( NewChannel == None )
		{
			log("ChangeVoiceChannel - invalid channel index requested! ("$PRI@NewChannelIndex$")",'VoiceChat');
			return;
		}

		NewChannel.AddMember(PRI);
	}

	OldChannel = VoiceReplicationInfo.GetChannelAt(OldChannelIndex);
	if ( OldChannel != None )
		OldChannel.RemoveMember(PRI);
}
// -- rjp
function SpecialEvent(PlayerReplicationInfo Who, string Desc)
{
	if ( GameStats != None )
		GameStats.SpecialEvent(Who,Desc);
}

function KillEvent(string Killtype, PlayerReplicationInfo Killer, PlayerReplicationInfo Victim, class<DamageType> Damage)
{
	local TeamPlayerReplicationInfo TPRI;

	TPRI = TeamPlayerReplicationInfo(Victim);
	if ( TPRI != None )
	{
		if ( Killer == None || Killer == Victim )
			TPRI.Suicides++;
		TPRI.AddWeaponDeath(Damage);
	}

	TPRI = TeamPlayerReplicationInfo(Killer);
	if ( TPRI != None )
		if ( TPRI != Victim )
			TPRI.AddWeaponKill(Damage);

	if ( GameStats != None )
		GameStats.KillEvent(KillType, Killer, Victim, Damage);
}

function GameEvent(string GEvent, string Desc, PlayerReplicationInfo Who)
{
	local TeamPlayerReplicationInfo TPRI;

	if ( GameStats != None )
		GameStats.GameEvent(GEvent, Desc, Who);

	TPRI = TeamPlayerReplicationInfo(Who);

	if ( TPRI == None )
		return;

	if ( (GEvent ~= "flag_taken") || (GEvent ~= "flag_pickup")
		|| (GEvent ~= "bomb_taken") || (GEvent ~= "Bomb_pickup") )
	{
		TPRI.FlagTouches++;
		return;
	}

	if ( GEvent ~= "flag_returned" )
	{
		TPRI.FlagReturns++;
		return;
	}
}

function ScoreEvent(PlayerReplicationInfo Who, float Points, string Desc)
{
	if ( GameStats != None )
		GameStats.ScoreEvent(Who,Points,Desc);
}

function TeamScoreEvent(int Team, float Points, string Desc)
{
	if ( GameStats != None )
		GameStats.TeamScoreEvent(Team,Points,Desc);
}

function int GetNumPlayers()
{
	if ( NumPlayers > 0 )
		return Max(NumPlayers, Min(NumPlayers+NumBots, MaxPlayers-1));
	return NumPlayers;
}

function bool ShouldRespawn(Pickup Other)
{
	return false;
}

function float SpawnWait(AIController B)
{
	if ( B.PlayerReplicationInfo.bOutOfLives )
		return 999;
	if ( Level.NetMode == NM_Standalone )
	{
		if ( NumBots < 4 )
			return 0;
		return ( 0.5 * FMax(2,NumBots-4) * FRand() );
	}
	if ( bPlayersVsBots )
		return 0;
	return FRand();
}

function bool TooManyBots(Controller botToRemove)
{
	return ( (Level.NetMode != NM_Standalone) && (NumBots + NumPlayers > MinPlayers) );
}

function RestartGame()
{
	if ( bGameRestarted )
		return;
    if ( CurrentGameProfile != None )
    {
		CurrentGameProfile.ContinueSinglePlayerGame(Level);
		return;
	}
	if ( EndTime > Level.TimeSeconds ) // still showing end screen
		return;

	Super.RestartGame();
}

static function Texture GetRandomTeamSymbol(int base)
{
    local string SymbolName;
    local int SymbolIndex, RawIndex;
    local array<string> TeamSymbols;
	local texture Result;

    class'CacheManager'.static.GetTeamSymbolList( TeamSymbols, True );

    RawIndex = Rand(TeamSymbols.Length - base);
    SymbolIndex = base + RawIndex;
    if ( SymbolIndex >= TeamSymbols.Length )
    	SymbolIndex = RawIndex;

	SymbolName = TeamSymbols[SymbolIndex];
    result = Texture(DynamicLoadObject(SymbolName, class'Texture'));

    if ( result == None )
		result = Texture(DynamicLoadObject(TeamSymbols[0], class'Texture'));
    if ( result == None )
    	warn("No Team Symbol! (TeamSymbols[0] is invalid)");
    return result;
}

// Stubs
function ObjectiveDisabled( GameObjective DisabledObjective );
function FindNewObjectives( GameObjective DisabledObjective );
function GameObject GetGameObject( Name GameObjectName );
function ScoreGameObject( Controller C, GameObject GO );
function ChangeLoadOut(PlayerController P, string LoadoutName);
function ForceAddBot();
function bool CanShowPathTo(PlayerController P, int TeamNum);
function ShowPathTo(PlayerController P, int TeamNum);

function int AdjustDestroyObjectiveDamage( int Damage, Controller InstigatedBy, GameObjective GO )
{
	return Damage;
}

function bool CanDisableObjective( GameObjective GO )
{
	return true;
}

/* only allow pickups if they are in the pawns loadout
*/
function bool PickupQuery(Pawn Other, Pickup item)
{
	local byte bAllowPickup;

	if ( (GameRulesModifiers != None) && GameRulesModifiers.OverridePickupQuery(Other, item, bAllowPickup) )
		return (bAllowPickup == 1);

	if ( (UnrealPawn(Other) != None) && !UnrealPawn(Other).IsInLoadout(item.inventorytype) )
		return false;

	if ( Other.Inventory == None )
		return true;
	else
		return !Other.Inventory.HandlePickupQuery(Item);
}

function InitPlacedBot(Controller C, RosterEntry R);

function GetServerDetails(out ServerResponseLine ServerState)
{
	Super.GetServerDetails(ServerState);

	AddServerDetail( ServerState, "MinPlayers", MinPlayers );
	AddServerDetail( ServerState, "EndTimeDelay", EndTimeDelay );
}

// <hack>
static function AdjustBotInterface(bool bSinglePlayer)
{
	if ( bSinglePlayer )
	{
		default.MPGIPropsDisplayText[0] = default.SPBotText;
		default.MPGIPropDescText[0] = default.SPBotDesc;
		default.BotModeText = GenerateBotOptions( True );
	}
	else
	{
		default.MPGIPropsDisplayText[0] = default.MPBotText;
		default.MPGIPropDescText[0] = default.MPBotDesc;
		default.BotModeText = GenerateBotOptions( False );
	}
}

static function string GenerateBotOptions(bool bSinglePlayer)
{
	local string option;
	local byte value;

	if ( bSinglePlayer )
	{
		// Get the value of MP botmode
		value = default.BotMode & 12;

		// Give three options - 0, 1, 2
		option =        value     $ ";" $ default.BotOptions[0];
		option $= ";" $ value | 1 $ ";" $ default.BotOptions[1];
		option $= ";" $ value | 2 $ ";" $ default.BotOptions[2];
	}

	else
	{
		// get the value of SP botmode
		value = default.BotMode & 3;

		// Give three options - 4, 8, 16
		option =        value | 4 $ ";" $ default.BotOptions[0];
		option $= ";" $ value | 8 $ ";" $ default.BotOptions[2];
		if ( Default.bTeamGame )
			option $= ";" $ value | 16 $ ";" $ default.BotOptions[3];
	}

	return option;
}
// </hack>

static function FillPlayInfo(PlayInfo PlayInfo)
{
	local int i;

	Super.FillPlayInfo(PlayInfo);  // Always begin with calling parent

	PlayInfo.AddSetting(default.BotsGroup,  "MinPlayers",         default.MPGIPropsDisplayText[i++], 0,   0,   "Text",            "3;0:32");
	PlayInfo.AddSetting(default.GameGroup,  "EndTimeDelay",       default.MPGIPropsDisplayText[i++], 1,   1,   "Text",                    ,     ,     , True);
	PlayInfo.AddSetting(default.BotsGroup,  "BotMode",			   default.MPGIPropsDisplayText[i++], 30,  1, "Select", default.BotModeText);
	PlayInfo.AddSetting(default.RulesGroup, "bAllowPrivateChat",  default.MPGIPropsDisplayText[i++], 254, 1,  "Check",                    , "Xv", True, True);
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "MinPlayers":			return default.MPGIPropDescText[0];
		case "EndTimeDelay":		return default.MPGIPropDescText[1];
		case "BotMode":				return default.MPGIPropDescText[2];
		case "bAllowPrivateChat": 	return default.MPGIPropDescText[3];
	}

	return Super.GetDescriptionText(PropName);
}

function int MultiMinPlayers()
{
	return MinPlayers;
}

defaultproperties
{
     BotMode=5
     EndTimeDelay=4.000000
     BotRatio=1.000000
     bAllowPrivateChat=True
     LocalStatsScreenClass=Class'UnrealGame.DMStatsScreen'
     MPGIPropsDisplayText(0)="Min Players"
     MPGIPropsDisplayText(1)="Delay at End of Game"
     MPGIPropsDisplayText(2)="Bot Mode"
     MPGIPropsDisplayText(3)="Allow Private Chat"
     MPGIPropDescText(0)="Bots fill server if necessary to make sure at least this many participant in the match."
     MPGIPropDescText(1)="How long to wait after the match ends before switching to the next map."
     MPGIPropDescText(2)="Specify how the number of bots in the match is determined."
     MPGIPropDescText(3)="Controls whether clients are allowed to create and join individual private chat rooms on this server"
     BotModeText="0;Specify Number;1;Use Map Defaults;2;Use Bot Roster"
     SPBotText="Number Of Bots"
     MPBotText="Min Players"
     SPBotDesc="Specify the number of bots that should join your match."
     MPBotDesc="Bots fill server if necessary to make sure at least this many participants in the match."
     BotOptions(0)="Specify Number"
     BotOptions(1)="Use Map Defaults"
     BotOptions(2)="Use Bot Roster"
     BotOptions(3)="Players vs Bots"
     PlayerControllerClassName="UnrealGame.UnrealPlayer"
     VoiceReplicationInfoClass=Class'UnrealGame.UnrealVoiceReplicationInfo'
}
