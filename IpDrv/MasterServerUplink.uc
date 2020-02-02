class MasterServerUplink extends MasterServerLink
    config
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

enum EServerToMaster
{
	STM_ClientResponse,
	STM_GameState,
	STM_Stats,
	STM_ClientDisconnectFailed,
	STM_MD5Version,
	STM_CheckOptionReply,
};

enum EMasterToServer
{
	MTS_ClientChallenge,
	MTS_ClientAuthFailed,
	MTS_Shutdown,
	MTS_MatchID,
	MTS_MD5Update,
	MTS_UpdateOption,
	MTS_CheckOption,
    MTS_ClientMD5Fail,
    MTS_ClientBanned,
    MTS_ClientDupKey,
    MTS_UTANBan,
};

enum EHeartbeatType
{
	HB_QueryInterface,
	HB_GamePort,
	HB_GamespyQueryPort,
};

// MD5 data coming from the master server.
struct native export MD5UpdateData
{
	var string Guid;
	var string MD5;
	var INT Revision;
};

var bool bInitialStateCached;
var GameInfo.ServerResponseLine ServerState, FullCachedServerState, CachedServerState;
var float CacheRefreshTime;
var int CachePlayerCount;
var MasterServerGameStats GameStats;
var UdpLink	GamespyQueryLink;
var const int MatchID;
var float ReconnectTime;
var bool bReconnectPending;

// config
var globalconfig bool DoUplink;
var globalconfig bool UplinkToGamespy;
var globalconfig bool SendStats;
var globalconfig bool ServerBehindNAT;
var globalconfig bool DoLANBroadcast;
var globalconfig bool bIgnoreUTANBans;

const MSUPROPNUM = 3;
var localized string MSUPropText[MSUPROPNUM];
var localized string MSUPropDesc[MSUPROPNUM];

// sorry, no code for you!
native function Reconnect();
native function ForceGameStateRefresh(int When);

event BeginPlay()
{
	local class<UdpLink> LinkClass;

	if( DoUplink )
	{
		// if we're uplinking to gamespy, also spawn the gamespy actors.
		if( UplinkToGamespy )
		{
			LinkClass = class<UdpLink>(DynamicLoadObject("IpDrv.UdpGamespyQuery", class'Class'));
			if ( LinkClass != None )
				GamespyQueryLink = Spawn( LinkClass );

			// FMasterServerUplink needs this for NAT.
			LinkClass = class<UdpLink>(DynamicLoadObject("IpDrv.UdpGamespyUplink", class'Class'));
			if ( LinkClass != None )
				Spawn( LinkClass );
		}

		// If we're sending stats,
		if( SendStats )
		{
			foreach AllActors(class'MasterServerGameStats', GameStats )
			{
				if( GameStats.Uplink == None )
					GameStats.Uplink = Self;
				else
					GameStats = None;
				break;
			}
			if( GameStats == None )
				Log("MasterServerUplink: MasterServerGameStats not found - stats uploading disabled.");
		}
	}

	Reconnect();
}

// Called when the connection to the master server fails or doesn't connect.
event ConnectionFailed( bool bShouldReconnect )
{
	// This master Server Index is bad.

	Log("Master server connection failed");
	bReconnectPending = bShouldReconnect;
	if (bShouldReconnect)
	{
		if (ActiveMasterServerList.Length>0 && LastMSIndex<ActiveMasterServerList.Length)
			ActiveMasterServerList.Remove(LastMSIndex,1);

		if (ActiveMasterServerList.Length==0)
			ReconnectTime=10.0;
		else
			ReconnectTime=2.0;
	}
	else
		ReconnectTime = 0;
}

// Called when we should refresh the game state
event Refresh()
{
	if ( (!bInitialStateCached) || ( Level.TimeSeconds > CacheRefreshTime )  )
	{
		Level.Game.GetServerInfo(FullCachedServerState);
		Level.Game.GetServerDetails(FullCachedServerState);

		CachedServerState = FullCachedServerState;

		Level.Game.GetServerPlayers(FullCachedServerState);

		ServerState 		= FullCachedServerState;
		CacheRefreshTime 	= Level.TimeSeconds + 60;
		bInitialStateCached = false;
	}
	else if (Level.Game.NumPlayers != CachePlayerCount)
	{
		ServerState = CachedServerState;

		Level.Game.GetServerPlayers(ServerState);

		FullCachedServerState = ServerState;

	}
	else
		ServerState = FullCachedServerState;

	CachePlayerCount = Level.Game.NumPlayers;
}

// Call to log a stat line
native event bool LogStatLine( string StatLine );

// Handle disconnection.
simulated function Tick( float Delta )
{
	Super.Tick(Delta);
	if( bReconnectPending )
	{
		ReconnectTime -= Delta;
		if( ReconnectTime <= 0.0 )
		{
			Log("Attempting to reconnect to master server!");
			bReconnectPending = False;
			Reconnect();
		}
	}
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting(default.ServerGroup, "DoUplink", 	default.MSUPropText[0], 	255, 1, "Check",,,True);
	PlayInfo.AddSetting(default.ServerGroup, "bIgnoreUTANBans", default.MSUPropText[2], 255, 1, "Check",,,True);
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "DoUplink":			return default.MSUPropDesc[0];
		case "SendStats":			return default.MSUPropDesc[1];
		case "bIgnoreUTANBans":		return default.MSUPropDesc[2];
	}

	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
     CachePlayerCount=-1
     DoUplink=True
     UplinkToGamespy=True
     SendStats=True
     MSUPropText(0)="Advertise Server"
     MSUPropText(1)="Process Stats"
     MSUPropText(2)="Ignore UTAN Bans"
     MSUPropDesc(0)="if true, your server is advertised on the internet server browser."
     MSUPropDesc(1)="Publishes player stats from your server on the UT2004 stats website."
     MSUPropDesc(2)="If true, your server will ignore UTAN based bans coming from the master server."
}
