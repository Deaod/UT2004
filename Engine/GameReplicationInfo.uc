//=============================================================================
// GameReplicationInfo.
//=============================================================================
class GameReplicationInfo extends ReplicationInfo
	native nativereplication exportstructs;

var string GameName;						// Assigned by GameInfo.
var string GameClass;						// Assigned by GameInfo.
var bool bTeamGame;							// Assigned by GameInfo.
var bool bStopCountDown;
var bool bMatchHasBegun;
var bool bTeamSymbolsUpdated;
var bool bNoTeamSkins;
var bool bForceTeamSkins;
var bool bForceNoPlayerLights;
var bool bAllowPlayerLights;
var bool bFastWeaponSwitching;
var bool bNoTeamChanges;

var int  RemainingTime, ElapsedTime, RemainingMinute;
var float SecondCount;
var int GoalScore;
var int TimeLimit;
var int MaxLives;
var int MinNetPlayers;
var float WeaponBerserk;

var TeamInfo Teams[2];

var() globalconfig string ServerName;		// Name of the server, i.e.: Bob's Server.
var() globalconfig string ShortName;        // Abbreviated name of server, i.e.: B's Serv (stupid example)
var() globalconfig string AdminName;		// Name of the server admin.
var() globalconfig string AdminEmail;       // Email address of the server admin.
var() globalconfig int	  ServerRegion;		// Region of the game server.

var() globalconfig string MessageOfTheDay;
var() deprecated string MOTDLine1, MOTDLine2, MOTDLine3, MOTDLine4;

var Actor Winner;			// set by gameinfo when game ends
var VoiceChatReplicationInfo VoiceReplicationInfo;

var() texture TeamSymbols[2];
var() array<PlayerReplicationInfo> PRIArray;

// mc - localized PlayInfo descriptions & extra info
const PROPNUM = 4;
var localized string GRIPropsDisplayText[PROPNUM];
var localized string GRIPropDescText[PROPNUM];

var vector FlagPos;	// replicated 2D position of one object
var EFlagState FlagState[2];
var PlayerReplicationInfo FlagHolder[2];	// hack to work around flag holder replication FIXME remove when break net compatibility
var PlayerReplicationInfo FlagTarget;		// used by Bombing Run (targeted player)

// stats
var int MatchID;

var int BotDifficulty;		// for bPlayersVsBots

replication
{
	reliable if ( bNetDirty && (Role == ROLE_Authority) )
		bStopCountDown, Winner, Teams, FlagPos, FlagState, bMatchHasBegun, MatchID, FlagTarget;

	reliable if ( !bNetInitial && bNetDirty && (Role == ROLE_Authority) )
		RemainingMinute;

	reliable if ( bNetInitial && (Role==ROLE_Authority) )
		GameName, GameClass, bTeamGame, bNoTeamSkins, bForceTeamSkins, bForceNoPlayerLights, WeaponBerserk, bAllowPlayerLights, bFastWeaponSwitching,
		RemainingTime, ElapsedTime, MessageOfTheDay, ServerName, ShortName, AdminName,
		AdminEmail, ServerRegion, GoalScore, MaxLives, TimeLimit, TeamSymbols,
		VoiceReplicationInfo, MinNetPlayers, bNoTeamChanges,BotDifficulty;
}


simulated function PostNetBeginPlay()
{
	local PlayerReplicationInfo PRI;


	Level.GRI = self;

	if ( VoiceReplicationInfo == None )
		foreach DynamicActors(class'VoiceChatReplicationInfo', VoiceReplicationInfo)
			break;

	ForEach DynamicActors(class'PlayerReplicationInfo',PRI)
		AddPRI(PRI);

	if ( Level.NetMode == NM_Client )
		TeamSymbolNotify();
}

simulated function TeamSymbolNotify()
{
	local Actor A;
	if ( TeamSymbols[0] == None )
		return;
	bTeamSymbolsUpdated = true;
	ForEach AllActors(class'Actor', A)
		A.SetGRI(self);
}

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(TeamSymbols[0]);
	Level.AddPrecacheMaterial(TeamSymbols[1]);
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	MessageOfTheDay = repl(MessageOfTheDay, chr(160),' ');

	if( Level.NetMode == NM_Client )
	{
		// clear variables so we don't display our own values if the server has them left blank
		ServerName = "";
		AdminName = "";
		AdminEmail = "";
		MessageOfTheDay = "";
	}

	SecondCount = Level.TimeSeconds;
	SetTimer(Level.TimeDilation, true);
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();
	Winner = None;
}

simulated function Timer()
{
	local int i;
	local PlayerReplicationInfo OldHolder[2];
	local Controller C;

	if ( Level.NetMode == NM_Client )
	{
		ElapsedTime++;
		if ( RemainingMinute != 0 )
		{
			RemainingTime = RemainingMinute;
			RemainingMinute = 0;
		}
		if ( (RemainingTime > 0) && !bStopCountDown )
			RemainingTime--;
		if ( !bTeamSymbolsUpdated )
			TeamSymbolNotify();
		SetTimer(Level.TimeDilation, true);
	}
	else if ( Level.NetMode != NM_Standalone )
	{
		OldHolder[0] = FlagHolder[0];
		OldHolder[1] = FlagHolder[1];
		FlagHolder[0] = None;
		FlagHolder[1] = None;
		for ( i=0; i<PRIArray.length; i++ )
			if ( (PRIArray[i].HasFlag != None) && (PRIArray[i].Team != None) )
				FlagHolder[PRIArray[i].Team.TeamIndex] = PRIArray[i];

		for ( i=0; i<2; i++ )
			if ( OldHolder[i] != FlagHolder[i] )
			{
				for ( C=Level.ControllerList; C!=None; C=C.NextController )
					if ( PlayerController(C) != None )
						PlayerController(C).ClientUpdateFlagHolder(FlagHolder[i],i);
			}
	}
}

simulated function PlayerReplicationInfo FindPlayerByID( int PlayerID )
{
    local int i;

    for( i=0; i<PRIArray.Length; i++ )
    {
        if( PRIArray[i].PlayerID == PlayerID )
            return PRIArray[i];
    }
    return None;
}


simulated function AddPRI(PlayerReplicationInfo PRI)
{
	local byte NewVoiceID;
	local int i;

    if ( Level.NetMode == NM_ListenServer || Level.NetMode == NM_DedicatedServer )
    {
    	for (i = 0; i < PRIArray.Length; i++)
    	{
			if ( PRIArray[i].VoiceID == NewVoiceID )
    		{
    			i = -1;
    			NewVoiceID++;
    			continue;
    		}
    	}

    	if ( NewVoiceID >= 32 )
    		NewVoiceID = 0;

    	PRI.VoiceID = NewVoiceID;
    }

    PRIArray[PRIArray.Length] = PRI;
}

simulated function RemovePRI(PlayerReplicationInfo PRI)
{
    local int i;

    for (i=0; i<PRIArray.Length; i++)
    {
        if (PRIArray[i] == PRI)
        {
        	PRIArray.Remove(i,1);
            return;
        }
    }

	log("GameReplicationInfo::RemovePRI() pri="$PRI$" not found.", 'Error');
}

simulated function GetPRIArray(out array<PlayerReplicationInfo> pris)
{
    local int i;
    local int num;

    pris.Remove(0, pris.Length);
    for (i=0; i<PRIArray.Length; i++)
    {
        if (PRIArray[i] != None)
            pris[num++] = PRIArray[i];
    }
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	local int i;

	Super.FillPlayInfo(PlayInfo);  // Always begin with calling parent

	PlayInfo.AddSetting(default.ServerGroup,  "ServerName",       default.GRIPropsDisplayText[i++], 255, 1, "Text",                     "60",,True);
	PlayInfo.AddSetting(default.ServerGroup,  "AdminName",        default.GRIPropsDisplayText[i++], 255, 1, "Text",                     "40",,True,True);
	PlayInfo.AddSetting(default.ServerGroup,  "AdminEmail",       default.GRIPropsDisplayText[i++], 255, 1, "Text",                     "60",,True,True);
	PlayInfo.AddSetting(default.ServerGroup,  "MessageOfTheDay",  default.GRIPropsDisplayText[i++], 251, 1, "Custom","255;;GUI2K4.MOTDConfigPage",,True,True);
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "ServerName":	    return default.GRIPropDescText[0];
		case "AdminName":	    return default.GRIPropDescText[1];
		case "AdminEmail":	    return default.GRIPropDescText[2];
		case "MessageOfTheDay":	return default.GRIPropDescText[3];
	}

	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
     bStopCountDown=True
     WeaponBerserk=1.000000
     ServerName="UT2004 Server"
     ShortName="UT2 Server"
     GRIPropsDisplayText(0)="Server Name"
     GRIPropsDisplayText(1)="Admin Name"
     GRIPropsDisplayText(2)="Admin E-Mail"
     GRIPropsDisplayText(3)="MOTD"
     GRIPropDescText(0)="Server name shown on server browser."
     GRIPropDescText(1)="Server administrator's name"
     GRIPropDescText(2)="Server administrator's email address."
     GRIPropDescText(3)="Message of the Day"
     BotDifficulty=-1
}
