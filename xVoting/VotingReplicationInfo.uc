// ====================================================================
//  Class:  xVoting.VotingReplicationInfo
//
//	The VotingReplicationInfo is responsible for voting related network
//  communications between the server and the player.
//
//  Written by Bruce Bickar
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class VotingReplicationInfo extends VotingReplicationInfoBase DependsOn(VotingHandler);

enum RepDataType
{
	REPDATATYPE_GameConfig,
	REPDATATYPE_MapList,
	REPDATATYPE_MapVoteCount,
	REPDATATYPE_KickVoteCount,
	REPDATATYPE_MatchConfig,
	REPDATATYPE_Maps,
	REPDATATYPE_Mutators
};

struct TickedReplicationQueueItem
{
	var RepDataType DataType;
	var int Index;
	var int Last;
};

struct MutatorData
{
    var string ClassName;
    var string FriendlyName;
};

var array<TickedReplicationQueueItem> TickedReplicationQueue;
var array<VotingHandler.MapVoteMapList> MapList;
var int MapCount;             // total count of maps

var array<VotingHandler.MapVoteGameConfigLite> GameConfig;  // game types
var int GameConfigCount;      // total count of game types
var int CurrentGameConfig;
var bool bWaitingForReply;     // used in replication

var array<VotingHandler.MapVoteScore> MapVoteCount; // holds vote counts
var array<VotingHandler.KickVoteScore> KickVoteCount; // holds vote counts

var int MapVote;      // Index of the map that the owner has voted for
var int VoteCount;
var int GameVote;     // Index of the Game type that the owner has voted for
var int KickVote;     // PlayerID of the that the owner has voted against to kick
var PlayerController PlayerOwner;    // player this RI belongs too
var int PlayerID;     // PlayerID of the owner. Needed to match up when player disconnects and owner == none
var byte Mode;        // voting mode enum

var bool bMapVote;             // Map voting enabled
var bool bKickVote;            // Kick voting enabled
var bool bMatchSetup;          // MatchSetup enabled
var bool bMatchSetupPermitted; // owner is logged in as a MatchSetup user.
var bool bMatchSetupAccepted;  // owner has accept the current match settings

var bool bSendingMatchSetup;   // currently sending match setup stuff to client
var int SecurityLevel;         // matchsetup users security level
var config bool bDebugLog;
var() name CountDownSounds[60];
var int CountDown;

var xVotingHandler VH;

// localization
var localized string lmsgSavedAsDefaultSuccess, lmsgNotAllAccepted;

// Client Response Identifiers
var string MapID, MutatorID, OptionID, GeneralID;
var string URLID, StatusID, MatchSetupID, LoginID, CompleteID;
var string AddID, RemoveID, UpdateID, FailedID, TournamentID, DemoRecID, GameTypeID;

//------------------------------------------------------------------------------------------------
replication
{
	// Variables the server should send to the client only initially
	reliable if( Role==ROLE_Authority && bNetInitial)
		PlayerOwner,
		MapCount,
		GameConfigCount,
		bKickVote,
		bMapVote,
		bMatchSetup,
		CurrentGameConfig;
		//bIsSpectator;

	// Variables or Functions the server should send to the client and keep updated if MapVoting enabled
	reliable if( Role==ROLE_Authority && bMapVote)
		ReceiveGameConfig,
		ReceiveMapInfo,
		CloseWindow,
		OpenWindow,
		ReceiveMapVoteCount,
		ReceiveKickVoteCount,
		Mode,
		PlayCountDown;

	// Functions the server should send to the client if KickVoting enabled
	reliable if( Role==ROLE_Authority && bKickVote)
		SendPlayerID;

	// Variables or Functions the server should send to the client
	// and keep updated if MatchSetup is enabled
	reliable if( Role==ROLE_Authority && bMatchSetup )
		bMatchSetupPermitted,
		bMatchSetupAccepted,
		SecurityLevel;

	// functions the client calls on the server
	reliable if( Role < ROLE_Authority )
		ReplicationReply,
		SendMapVote,
		SendKickVote,
		MatchSetupLogin,
		RequestMatchSettings,
		MatchSettingsSubmit,
		SaveAsDefault,
		RestoreDefaultProfile,
		MatchSetupLogout,
		RequestPlayerIP;
}
//------------------------------------------------------------------------------------------------
event PostBeginPlay()
{
	Super.PostBeginPlay();

	PlayerOwner = PlayerController(Owner);
	VH = xVotingHandler(Level.Game.VotingHandler);
}

simulated event PostNetBeginPlay()
{
	DebugLog("____VotingReplicationInfo.PostNetBeginPlay");
    Super.PostNetBeginPlay();
    GetServerData();
}
simulated event PostNetReceive()
{
	bNetNotify = NeedNetNotify();
	if ( !bNetNotify && Owner == None )
		SetOwner(PlayerOwner);
}

simulated function bool NeedNetNotify()
{
	return PlayerOwner == None;
}
simulated function GUIController GetController()
{
	if ( Level.NetMode == NM_ListenServer || Level.NetMode == NM_Client )
	{
		if ( PlayerOwner != None && PlayerOwner.Player != None )
			return GUIController(PlayerOwner.Player.GUIController);
	}

	return None;
}

//------------------------------------------------------------------------------------------------
simulated function GetServerData()
{
	// grab data from VotingHandler on server side
	if( Level.NetMode != NM_Client )
	{
		bKickVote = VH.bKickVote;
		bMapVote = VH.bMapVote;
		bMatchSetup = VH.bMatchSetup;
		MapCount = VH.MapCount;
		GameConfigCount = VH.GameConfig.Length;

		if( bMapVote )
		{
			Mode = byte(VH.bEliminationMode);
			Mode += byte(VH.bScoreMode) * 2;
			Mode += byte(VH.bAccumulationMode) * 4;

			CurrentGameConfig = VH.CurrentGameConfig;

			AddToTickedReplicationQueue(REPDATATYPE_GameConfig, GameConfigCount-1);
			AddToTickedReplicationQueue(REPDATATYPE_MapList, MapCount-1);
			if( VH.MapVoteCount.Length > 0 )
				AddToTickedReplicationQueue(REPDATATYPE_MapVoteCount, VH.MapVoteCount.Length-1);
		}

		if( bKickVote && VH.KickVoteCount.Length > 0 )
			AddToTickedReplicationQueue(REPDATATYPE_KickVoteCount, VH.KickVoteCount.Length-1);
	}
}
//------------------------------------------------------------------------------------------------
simulated function Tick(float DeltaTime)
{
	local int i;
	local bool bDedicated, bListening;

	if( TickedReplicationQueue.Length == 0 || bWaitingForReply)
		return;

	bDedicated = Level.NetMode == NM_DedicatedServer ||
	            (Level.NetMode == NM_ListenServer && PlayerOwner != none &&
				 PlayerOwner.Player.Console == none );

  	bListening = Level.NetMode == NM_ListenServer && PlayerOwner != none &&
	             PlayerOwner.Player.Console != none;

	if( !bDedicated && !bListening )
		return;

	i = TickedReplicationQueue.Length - 1;

	switch( TickedReplicationQueue[i].DataType )
	{
		case REPDATATYPE_GameConfig:
			TickedReplication_GameConfig(TickedReplicationQueue[i].Index, bDedicated);
 			break;
		case REPDATATYPE_MapList:
			TickedReplication_MapList(TickedReplicationQueue[i].Index, bDedicated);
			break;
		case REPDATATYPE_MapVoteCount:
			TickedReplication_MapVoteCount(TickedReplicationQueue[i].Index, bDedicated);
			break;
		case REPDATATYPE_KickVoteCount:
			TickedReplication_KickVoteCount(TickedReplicationQueue[i].Index, bDedicated);
			break;
		case REPDATATYPE_MatchConfig:
			TickedReplication_MatchConfig(TickedReplicationQueue[i].Index, bDedicated);
			break;
		case REPDATATYPE_Maps:
			TickedReplication_Maps(TickedReplicationQueue[i].Index, bDedicated);
			break;
		case REPDATATYPE_Mutators:
			TickedReplication_Mutators(TickedReplicationQueue[i].Index, bDedicated);
			break;
	}
	TickedReplicationQueue[i].Index++;
	if( TickedReplicationQueue[i].Index > TickedReplicationQueue[i].Last )
		TickedReplicationQueue.Remove(i,1);
}
//------------------------------------------------------------------------------------------------
function AddToTickedReplicationQueue(RepDataType Type, int Last)
{
	if( Last > -1 )
	{
		TickedReplicationQueue.Insert(0,1);
		TickedReplicationQueue[0].DataType = Type;
		TickedReplicationQueue[0].Index = 0;
		TickedReplicationQueue[0].Last = Last;
	}
}
//------------------------------------------------------------------------------------------------
function TickedReplication_GameConfig(int Index, bool bDedicated)
{
	local VotingHandler.MapVoteGameConfigLite GameConfigItem;

	GameConfigItem = VH.GetGameConfig(Index);
	DebugLog("___Sending " $ Index $ " - " $ GameConfigItem.GameName);
	if( bDedicated )
	{
		ReceiveGameConfig(GameConfigItem); // replicate one GameConfig each tick
		bWaitingForReply = True;
	}
	else
		GameConfig[GameConfig.Length] = GameConfigItem;
}
//------------------------------------------------------------------------------------------------
function TickedReplication_MapList(int Index, bool bDedicated)
{
 	local VotingHandler.MapVoteMapList MapInfo;

	MapInfo = VH.GetMapList(Index);
	DebugLog("___Sending " $ Index $ " - " $ MapInfo.MapName);

	if( bDedicated )
	{
		ReceiveMapInfo(MapInfo);  // replicate one map each tick until all maps are replicated.
		bWaitingForReply = True;
	}
	else
		MapList[MapList.Length] = MapInfo;
}
//------------------------------------------------------------------------------------------------
function TickedReplication_MatchConfig(int Index, bool bDedicated)
{
	local MatchConfig MatchProfile;
	local PlayInfo.PlayInfoData PIData;

	if( Index < 6 )
	{
		MatchProfile = VH.MatchProfile;
		switch( Index )
		{
			case 0:
				SendClientResponse( GeneralID, UpdateID $ Chr(27) $ GameTypeID, MatchProfile.GameClassString);
				break;
			case 1:
				SendClientResponse( MapID, UpdateID, MatchProfile.MapIndexList );
				break;
			case 2:
				SendClientResponse( MutatorID, UpdateID, MatchProfile.MutatorIndexList );
				break;
			case 3:
				SendClientResponse( GeneralID, UpdateId $ Chr(27) $ URLID, MatchProfile.Parameters );
				break;
			case 4:
				SendClientResponse( GeneralID, UpdateId $ Chr(27) $ TournamentID, string(MatchProfile.bTournamentMode) );
				break;
			case 5:
				SendClientResponse( GeneralID, UpdateID $ Chr(27) $ DemoRecID, MatchProfile.DemoRecFileName );
				break;
		}
		bWaitingForReply = bDedicated;
	}
	else
	{
		DebugLog("___Sending " $ VH.MatchProfile.PInfo.Settings[Index-6].SettingName);
		PIData = VH.MatchProfile.PInfo.Settings[Index-6];
		if( PIData.ArrayDim == -1) // no array properties (cant handle them)
		{
			SendClientResponse( OptionID, AddID, PIData.SettingName $ Chr(27) $ PIData.ClassFrom $ Chr(27) $ PIData.Value );
			bWaitingForReply = bDedicated;
		}
	}
}
//------------------------------------------------------------------------------------------------
function TickedReplication_MapVoteCount(int Index, bool bDedicated)
{
	DebugLog("___Sending MapVoteCountIndex " $ Index);
	if( bDedicated )
	{
		ReceiveMapVoteCount(VH.MapVoteCount[Index], True);
		bWaitingForReply = True;
	}
	else
		MapVoteCount[MapVoteCount.Length] = VH.MapVoteCount[Index];
}
//------------------------------------------------------------------------------------------------
function TickedReplication_KickVoteCount(int Index, bool bDedicated)
{
	DebugLog("___Sending KickVoteCountIndex " $ Index);
	if( bDedicated )
	{
		ReceiveKickVoteCount(VH.KickVoteCount[Index], True);
		bWaitingForReply = True;
	}
	else
		KickVoteCount[KickVoteCount.Length] = VH.KickVoteCount[Index];
}
//------------------------------------------------------------------------------------------------
function TickedReplication_Maps(int Index, bool bDedicated)
{
	DebugLog("TickedReplication_Maps " $ Index $ ", " $ VH.MatchProfile.Maps[Index].MapName);

	SendClientResponse(MapID, AddID, Index $ "," $ VH.MatchProfile.Maps[Index].MapName);
	bWaitingForReply = bDedicated;
}
//------------------------------------------------------------------------------------------------
function TickedReplication_Mutators(int Index, bool bDedicated)
{
	local MatchConfig MatchProfile;
	local MutatorData M;

	MatchProfile = VH.MatchProfile;
	DebugLog("TickedReplication_Mutators " $ Index $ ", " $ MatchProfile.Mutators[Index].ClassName);

	M.ClassName = MatchProfile.Mutators[Index].ClassName;
	M.FriendlyName = MatchProfile.Mutators[Index].FriendlyName;

	SendClientResponse( MutatorID, AddID, Index $ "," $ M.ClassName $ Chr(27) $ M.FriendlyName );
	bWaitingForReply = bDedicated;
}
//------------------------------------------------------------------------------------------------
simulated function ReceiveGameConfig(VotingHandler.MapVoteGameConfigLite p_GameConfig)
{
	GameConfig[GameConfig.Length] = p_GameConfig;
	DebugLog("___Receiving - " $ p_GameConfig.GameName);
	ReplicationReply();
}
//------------------------------------------------------------------------------------------------
simulated function ReceiveMapInfo(VotingHandler.MapVoteMapList MapInfo)
{
	MapList[MapList.Length] = MapInfo;
	DebugLog("___Receiving - " $ MapInfo.MapName);
	ReplicationReply();
}
//------------------------------------------------------------------------------------------------
simulated function ReceiveMapVoteCount(VotingHandler.MapVoteScore MVCData, bool bReply)
{
	local int i;
	local bool bFound;

	for( i=0; i<MapVoteCount.Length; i++ )
	{
		if( MVCData.MapIndex == MapVoteCount[i].MapIndex &&
			MVCData.GameConfigIndex == MapVoteCount[i].GameConfigIndex)
		{
			if( MVCData.VoteCount <= 0 )
				MapVoteCount.Remove( i, 1);  // canceled vote
			else
				MapVoteCount[i].VoteCount = MVCData.VoteCount; // updated vote
			bFound = True;
			break;
		}
	}

	if( !bFound ) // new vote
	{
		i = MapVoteCount.Length;
		MapVoteCount.Insert(i,1);
		MapVoteCount[i] = MVCData;
	}

	if( bReply )
		ReplicationReply();
	else if ( PlayerOwner != None && PlayerOwner.Player != None )
	{
		if ( MapVotingPage(GetController().ActivePage) != None )
			MapVotingPage(GetController().ActivePage).UpdateMapVoteCount(i,MVCData.VoteCount==0);
		if( MapInfoPage(GetController().ActivePage) != none )
			MapVotingPage(GetController().ActivePage.ParentPage).UpdateMapVoteCount(i,MVCData.VoteCount== 0);
	}
}
//------------------------------------------------------------------------------------------------
simulated function ReceiveKickVoteCount(VotingHandler.KickVoteScore KVCData, bool bReply)
{
	local int i;
	local bool bFound;

	for( i=0; i<KickVoteCount.Length; i++ )
	{
		if( KVCData.PlayerID == KickVoteCount[i].PlayerID )
		{
			KickVoteCount[i].KickVoteCount = KVCData.KickVoteCount;
			bFound = True;
			break;
		}
	}

	if( !bFound )
	{
		i = KickVoteCount.Length;
		KickVoteCount.Insert(i,1);
		KickVoteCount[i] = KVCData;
	}

	if( bReply )
		ReplicationReply();
	else
	{
		if( KickVotingPage(GetController().ActivePage) != None )
			KickVotingPage(GetController().ActivePage).UpdateKickVoteCount(KickVoteCount[i]);
	}
}
//------------------------------------------------------------------------------------------------
function ReplicationReply()
{
	bWaitingForReply = False;
	if ( bSendingMatchSetup && TickedReplicationQueue.Length == 0 )
	{
		SendClientResponse(StatusID, CompleteID);
		bSendingMatchSetup = false;
	}
}
//------------------------------------------------------------------------------------------------
function SendMapVote(int MapIndex, int p_GameIndex)
{
	DebugLog("MVRI.SendMapVote(" $ MapIndex $ ", " $ p_GameIndex $ ")");
	VH.SubmitMapVote(MapIndex,p_GameIndex,Owner);
}
//------------------------------------------------------------------------------------------------
function SendKickVote(int PlayerID)
{
	VH.SubmitKickVote(PlayerID, Owner);
}
//------------------------------------------------------------------------------------------------
simulated function CloseWindow()
{
	settimer(0,false);
	GetController().CloseAll(true);
}
//------------------------------------------------------------------------------------------------
simulated function OpenWindow()
{
	if ( GetController().FindMenuByClass(Class<GUIPage>(DynamicLoadObject(GetController().MapVotingMenu, Class'Class'))) != None
 			|| GetController().FindMenuByClass(Class'MapVotingPage') != none )
 	{
		return;
	}

	GetController().OpenMenu(GetController().MapVotingMenu);
}
//------------------------------------------------------------------------------------------------
simulated function string GetMapNameString(int Index)
{
	if(Index >= MapList.Length)
		return "";
	else
		return MapList[Index].MapName;
}
//------------------------------------------------------------------------------------------------
function MatchSetupLogin(string UserID, string Password)
{
	local int SecLevel;

	if( VH.MatchSetupLogin(UserID,Password,PlayerOwner,SecLevel) )
	{
		bMatchSetupPermitted=True;
		SecurityLevel = SecLevel;

		SendClientResponse(LoginID,"1");
	}
	else
	{
		bMatchSetupPermitted=False;
		SendClientResponse(LoginID);
	}
}
//------------------------------------------------------------------------------------------------
function MatchSetupLogout()
{
	bMatchSetupPermitted = false;
	bMatchSetupAccepted = false;
	bSendingMatchSetup = false;
	VH.MatchSetupLogout( PlayerOwner );

	SendClientResponse("logout");
}
//------------------------------------------------------------------------------------------------
function RequestMatchSettings(bool bRefreshMaps, bool bRefreshMutators)
{
	DebugLog("____RequestConfigSettings");

	if(bMatchSetupPermitted)
	{
		bMatchSetupAccepted = false;
		bSendingMatchSetup = true;

		// Send the full list of maps
		if ( bRefreshMaps )
			AddToTickedReplicationQueue(REPDATATYPE_Maps, VH.MatchProfile.Maps.Length-1);

		// Send the full list of mutators
		if ( bRefreshMutators )
			AddToTickedReplicationQueue(REPDATATYPE_Mutators, VH.MatchProfile.Mutators.Length-1);

		// Send the game configuration, including the active maps & mutators, command line params, and misc. settings
		AddToTickedReplicationQueue(REPDATATYPE_MatchConfig, VH.MatchProfile.PInfo.Settings.Length + 5);
	}
	else SendClientResponse(MatchSetupID, FailedID);
}
function SendClientResponse( string Identifier, optional string Response, optional string Data )
{
	if ( Identifier == "" )
		return;

	if ( Response != "" )
		Identifier $= ":" $ Response;

	if ( Data != "" )
		Identifier $= ";" $ Data;

	SendResponse(Identifier);
}

function ReceiveCommand( string Command )
{
	local string Type, Info, Data;

	DecodeCommand( Command, Type, Info, Data );
	HandleCommand( Type, Info, Data );
}

static function DecodeCommand( string Response, out string Type, out string Info, out string Data )
{
	local string str;

	Type = "";
	Info = "";
	Data = "";

	if ( Response == "" )
		return;

	if ( Divide(Response, ":", Type, str) )
	{
		if ( !Divide(str, ";", Info, Data) )
			Info = str;
	}
	else Type = Response;
}

function HandleCommand( string Type, string Info, string Data )
{
	local bool bPropagate;

	if ( Type == "" )
		return;

	log("HandleCommand Type: '"$Type$"'   Info: '"$Info$"'   Data: '"$Data$"'",'MapVoteDebug');
	switch ( Type )
	{
	case MapID:
		if ( bMatchSetupPermitted )
		{
			bMatchSetupAccepted = false;
			bPropagate = VH.MatchProfile.ChangeSetting(Type, Info);
		}

		break;

	case MutatorID:
		if ( bMatchSetupPermitted )
		{
			bMatchSetupAccepted = false;
			bPropagate = VH.MatchProfile.ChangeSetting( Type, Info );
		}
		break;

	case GeneralID:
		if ( bMatchSetupPermitted )
		{
			bMatchSetupAccepted = false;
			switch ( Info )
			{
			case OptionID:
			case TournamentID:
			case DemoRecID:
				bPropagate = VH.MatchProfile.ChangeSetting( Info, Data );
			}
		}

		break;
	}

	if ( bPropagate )
		VH.PropagateValue(Self, Type, Info, Data);
}

simulated function SendResponse(string Response)
{
	Super.SendResponse(Response);
	ReplicationReply();
}

//------------------------------------------------------------------------------------------------
function MatchSettingsSubmit()
{
	local int i;
	local bool bAllAccepted;

	DebugLog("____MatchSettingsSubmit()");

	if(bMatchSetupPermitted)
	{
		bAllAccepted = true;
		bMatchSetupAccepted = true;
		// check if any match setup users did not accept the settings
		for( i=0; i<VH.MVRI.Length; i++)
		{
			if(VH.MVRI[i].bMatchSetupPermitted && !VH.MVRI[i].bMatchSetupAccepted)
			{
				bAllAccepted = false;
				break;
			}
		}

		if( bAllAccepted ) // if all match setup users accepted then implement changes
			VH.MatchProfile.StartMatch();
		else SendClientResponse(StatusID, lmsgNotAllAccepted);
	}
}
//------------------------------------------------------------------------------------------------
function SaveAsDefault()
{
	DebugLog("____SaveAsDefault()");

	// double chech permissions just incase
	if( bMatchSetupPermitted && PlayerOwner.PlayerReplicationInfo.bAdmin )
	{
		VH.MatchProfile.SaveDefault();
		SendClientResponse(StatusID, lmsgSavedAsDefaultSuccess);
	}
}
//------------------------------------------------------------------------------------------------
function RestoreDefaultProfile()
{
	local MatchConfig MatchProfile;

	DebugLog("____RestoreDefaultProfile()");

	// double chech permissions just incase
	if( bMatchSetupPermitted )
	{
		MatchProfile = VH.MatchProfile;
		MatchProfile.RestoreDefault(PlayerOwner);
	}
}
//------------------------------------------------------------------------------------------------
simulated function PlayCountDown(int Count)
{
	local float t;

    if(Count > 10 && Count <= 60 && CountDownSounds[Count-1] != '')
        PlayerOwner.PlayStatusAnnouncement( CountDownSounds[Count-1], 1);

	if( Count == 10 )
	{
	    t = GetSoundDuration(PlayerOwner.StatusAnnouncer.PreCacheSound(CountDownSounds[9]));
	    if(t + 0.15 < 1)
			t = 1;
    	SetTimer(t + 0.15,false);
    	PlayerOwner.PlayStatusAnnouncement( CountDownSounds[9], 1);
    	CountDown = 9;
    }
}
//------------------------------------------------------------------------------------------------
simulated function Timer()
{
 	local float t;

    t = GetSoundDuration(PlayerOwner.StatusAnnouncer.PreCacheSound(CountDownSounds[CountDown-1]));
    if(t + 0.15 < 1)
		t = 1;
	PlayerOwner.PlayStatusAnnouncement( CountDownSounds[CountDown-1], 1);
	CountDown--;
	if( CountDown > 0 )
	   	SetTimer(t + 0.15,false);
}
//------------------------------------------------------------------------------------------------
function RequestPlayerIP( string PlayerName )
{
	local PlayerController P;

	if( PlayerOwner.PlayerReplicationInfo.bAdmin )
	{
	    foreach DynamicActors( class'PlayerController', P )
	    {
	    	if( P.PlayerReplicationInfo.PlayerName ~= PlayerName )
	    	{
	    		SendPlayerID(P.GetPlayerNetworkAddress(), P.GetPlayerIDHash());
	    		break;
	    	}
	    }
	}
}
//------------------------------------------------------------------------------------------------
simulated function SendPlayerID(string IPAddress, string PlayerID)
{
	local KickInfoPage Page;

	Page = KickInfoPage(GetController().ActivePage);
	if(Page != None)
	{
		Page.lb_PlayerInfoBox.Add(class'KickInfoPage'.default.IPText,IPAddress);
		Page.lb_PlayerInfoBox.Add(class'KickInfoPage'.default.IDText,PlayerID);
	}
}
//------------------------------------------------------------------------------------------------
simulated function DebugLog(string Text)
{
	if(bDebugLog)
		log(Text,'MapVoteDebug');
}
//------------------------------------------------------------------------------------------------

simulated function bool MatchSetupLocked() { return !bMatchSetupPermitted; }
simulated function bool MapVoteEnabled() { return bMapVote; }
simulated function bool KickVoteEnabled() { return bKickVote; }
simulated function bool MatchSetupEnabled() { return bMatchSetup; }

defaultproperties
{
     MapVote=-1
     GameVote=-1
     KickVote=-1
     CountDownSounds(0)="one"
     CountDownSounds(1)="two"
     CountDownSounds(2)="three"
     CountDownSounds(3)="four"
     CountDownSounds(4)="five"
     CountDownSounds(5)="six"
     CountDownSounds(6)="seven"
     CountDownSounds(7)="eight"
     CountDownSounds(8)="nine"
     CountDownSounds(9)="ten"
     CountDownSounds(19)="20_seconds"
     CountDownSounds(29)="30_seconds_remain"
     CountDownSounds(59)="1_minute_remains"
     lmsgSavedAsDefaultSuccess="Profile was saved as default successfully"
     lmsgNotAllAccepted="You have Accepted the current settings, Waiting for other users to accept."
     MapID="map"
     MutatorID="mutator"
     OptionID="option"
     GeneralID="general"
     URLID="url"
     StatusID="status"
     MatchSetupID="matchsetup"
     LoginID="login"
     CompleteID="done"
     AddID="add"
     RemoveID="remove"
     UpdateID="update"
     FailedID="failed"
     TournamentID="tournament"
     DemoRecID="demorec"
     GameTypeID="game"
     ProcessCommand=VotingReplicationInfo.ReceiveCommand
     bOnlyRelevantToOwner=True
     NetUpdateFrequency=1.000000
     bNetNotify=True
}
