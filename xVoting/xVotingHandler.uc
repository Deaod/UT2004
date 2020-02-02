// ====================================================================
//  Class:  xVoting.xVotingHandler
//
//	xVotingHandler handles the server side of map voting, kick voting,
//  and match setup.
//
//  Written by Bruce Bickar
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class xVotingHandler extends VotingHandler config;

// work variables
var array<VotingReplicationInfo> MVRI; // used to communicated between players and server
var int           MapCount;      // number of maps
var bool          bLevelSwitchPending;
var bool          bMidGameVote;
var int           TimeLeft,ScoreBoardTime,ServerTravelTime;
var array<MapVoteScore> MapVoteCount;
var array<KickVoteScore> KickVoteCount;
var class<MapVoteHistory> MapVoteHistoryClass;
var array<MapVoteMapList> MapList;
var MapVoteHistory History;
var string        TextMessage;
var string        ServerTravelString;
var bool          bAutoDetectMode; // true if mapvote enabled but not configuration

// ---- INI Configuration setting variables ----
var() config array<MapVoteGameConfig> GameConfig;
var() config int    VoteTimeLimit;
var() config int    ScoreBoardDelay;
var() config bool   bAutoOpen;
var() config int    MidGameVotePercent;
var() config bool   bScoreMode;
var() config bool   bAccumulationMode;
var() config bool   bEliminationMode;
var() config int    MinMapCount;
var() config string MapVoteHistoryType;
var() config int    RepeatLimit;
var() config int    DefaultGameConfig;
var() config bool   bDefaultToCurrentGameType;
var() config bool   bMapVote;
var() config bool   bKickVote;
var() config bool   bMatchSetup;
var() config int    KickPercent;
var() config bool   bAnonymousKicking;
var() config string MapListLoaderType;
var() config array<AccumulationData> AccInfo; // used to save player's unused votes between maps when in Accumulation mode
var() config int    ServerNumber;
var() config int    CurrentGameConfig;

// MatchSetup
var MatchConfig MatchProfile;
var string GameConfigPage;
var string MapListConfigPage;

// Localization variables
var localized string lmsgInvalidPassword;
var localized string lmsgMatchSetupPermission;
var localized string lmsgKickVote;
var localized string lmsgAnonymousKickVote;
var localized string lmsgKickVoteAdmin;
var localized string lmsgMapWon;
var localized string lmsgMidGameVote;
var localized string lmsgSpectatorsCantVote;
var localized string lmsgMapVotedFor;
var localized string lmsgMapVotedForWithCount;
var localized string PropsDisplayText[17];
var localized string PropDescription[17];
var localized string lmsgAdminMapChange;
var localized string lmsgGameConfigColumnTitle[6];

const MAPVOTEALLOWED = True;
const KICKVOTEALLOWED = True;
const MATCHSETUPALLOWED = False;

static function bool IsEnabled()
{
	return ( Default.bMapVote || Default.bKickVote || Default.bMatchSetup );
}

//================================================================================================
//                                    Startup/Event Code
//================================================================================================
function PostBeginPlay()
{
	local int i;

	Super.PostBeginPlay();

	// disable voting in single player mode
    if( Level.NetMode == NM_StandAlone )
		return;

	if ( Level.IsDemoBuild() )
	{
		bMapVote = False;
		bKickVote = False;
	}

	bMatchSetup = bMatchSetup && MATCHSETUPALLOWED;

	if(bKickVote)
		log("Kick Voting Enabled",'MapVote');
	else
		log("Kick Voting Disabled",'MapVote');

	if(bMapVote)
	{
		log("Map Voting Enabled",'MapVote');
		// check current game settings
		if( GameConfig.Length > 0 )
		{
			if( !(string(Level.Game.Class) ~= GameConfig[CurrentGameConfig].GameClass) )
			{
				CurrentGameConfig = 0;
				// find matching game type in game config
				for( i=0; i<GameConfig.Length; i++)
				{
					if(GameConfig[i].GameClass ~= string(Level.Game.Class))
					{
						CurrentGameConfig = i;
						break;
					}
				}
			}
		}
		else
			CurrentGameConfig = 0;
		LoadMapList();
	}
	else
		log("Map Voting Disabled",'MapVote');

	if(bMatchSetup)
	{
		log("MatchSetup Enabled",'MapVote');

		MatchProfile = CreateMatchProfile();
		MatchProfile.Init(Level);
		MatchProfile.LoadCurrentSettings();
	}
	else
		log("MatchSetup Disabled",'MapVote');
}
//------------------------------------------------------------------------------------------------
function PlayerJoin(PlayerController Player)
{
	// disable voting in single player mode
    if( Level.NetMode == NM_StandAlone )
		return;

	if(!Player.IsA('XPlayer')) // no bots
		return;

	if(bMapVote || bKickVote || bMatchSetup)
	{
		Log("___New Player Joined - " $ Player.PlayerReplicationInfo.PlayerName $ ", " $ Player.GetPlayerNetworkAddress(),'MapVote');
		AddMapVoteReplicationInfo(Player);
	}
}
//------------------------------------------------------------------------------------------------
function PlayerExit(Controller Exiting)
{
	local int i,x,ExitingPlayerIndex;

	// disable voting in single player mode
    if( Level.NetMode == NM_StandAlone )
		return;

    ExitingPlayerIndex = -1;

	log("____PlayerExit", 'MapVoteDebug');

	if(bMapVote || bKickVote || bMatchSetup)
	{
		// find the MVRI belonging to the exiting player
		for(i=0;i < MVRI.Length;i++)
		{
		    // remove players vote from vote count
			if( MVRI[i] != none && (MVRI[i].PlayerOwner == none || MVRI[i].PlayerOwner == Exiting) )
			{
				log("exiting player MVRI found " $ i,'MapVoteDebug');
				ExitingPlayerIndex = i;
				if( bMapVote && MVRI[ExitingPlayerIndex].MapVote > -1 && MVRI[ExitingPlayerIndex].GameVote > -1 )
				{
					for( x=0; x<MapVoteCount.Length; x++ )
					{
						if( MVRI[ExitingPlayerIndex].MapVote == MapVoteCount[x].MapIndex &&
							MVRI[ExitingPlayerIndex].GameVote == MapVoteCount[x].GameConfigIndex)
						{
							MapVoteCount[x].VoteCount -= MVRI[ExitingPlayerIndex].VoteCount;
							UpdateVoteCount(MapVoteCount[x].MapIndex, MapVoteCount[x].GameConfigIndex, MapVoteCount[x].VoteCount);
							break;
						}
					}
				}

				if( bKickVote )
				{
					// clear votes for exiting player
					UpdateKickVoteCount( MVRI[ExitingPlayerIndex].PlayerID, 0 );

					// decrease votecount for player that the exiting player voted against
					if( MVRI[ExitingPlayerIndex].KickVote > -1 && MVRI[MVRI[ExitingPlayerIndex].KickVote] != none )
						UpdateKickVoteCount( MVRI[MVRI[ExitingPlayerIndex].KickVote].PlayerID, -1);
				}
			}

			if( bKickVote && ExitingPlayerIndex > -1 && MVRI[i] != none && MVRI[i].KickVote == ExitingPlayerIndex )
				MVRI[i].KickVote = -1;

			if( MVRI[i] != none && (MVRI[i].PlayerOwner == none || MVRI[i].PlayerOwner == Exiting) )
			{
				log("___Destroying VRI...",'MapVoteDebug');
				MVRI[i].Destroy();
				MVRI[i] = none;
				if( bKickVote )
					TallyKickVotes();
				if( bMapVote )
					TallyVotes(false);
			}
		}
	}
}
//------------------------------------------------------------------------------------------------
function AddMapVoteReplicationInfo(PlayerController Player)
{
	local VotingReplicationInfo M;

	log("___Spawning VotingReplicationInfo",'MapVoteDebug');
	M = Spawn(class'VotingReplicationInfo',Player,,Player.Location);
	if(M == None)
	{
		Log("___Failed to spawn VotingReplicationInfo",'MapVote');
		return;
	}

	M.PlayerID = Player.PlayerReplicationInfo.PlayerID;
	MVRI[MVRI.Length] = M;
}
//================================================================================================
//                                    Map Voting
//================================================================================================
function LoadMapList()
{
	local int i,EnabledMapCount;
	local class<MapListLoader> MapListLoaderClass;
	local MapListLoader Loader;

	MapList.Length = 0; // clear
	MapCount = 0;

	MapVoteHistoryClass = class<MapVoteHistory>(DynamicLoadObject(MapVoteHistoryType, class'Class'));
	History = new(None,"MapVoteHistory"$string(ServerNumber)) MapVoteHistoryClass;
	if(History == None) // Failed to spawn MapVoteHistory
		History = new(None,"MapVoteHistory"$string(ServerNumber)) class'MapVoteHistory_INI';

	log("GameTypes:",'MapVote');

	if(GameConfig.Length == 0)
	{
		bAutoDetectMode = true;
		// default to ONLY current game type and maps
		GameConfig.Length = 1;
		GameConfig[0].GameClass = string(Level.Game.Class);
		GameConfig[0].Prefix = Level.Game.MapPrefix;
		GameConfig[0].Acronym = Level.Game.Acronym;
		GameConfig[0].GameName = Level.Game.GameName;
		GameConfig[0].Mutators="";
		GameConfig[0].Options="";
//		GameConfig.Length = 10;
//		// UT2003 game types
//		GameConfig[0].GameClass="XGame.xDeathMatch";GameConfig[0].Prefix="DM";GameConfig[0].Acronym="DM";GameConfig[0].GameName="DeathMatch";GameConfig[0].Mutators="";GameConfig[0].Options="";
//		GameConfig[1].GameClass="XGame.xTeamGame";GameConfig[1].Prefix="DM";GameConfig[1].Acronym="TDM";GameConfig[1].GameName="Team DeathMatch";GameConfig[1].Mutators="";GameConfig[1].Options="";
//		GameConfig[2].GameClass="XGame.xDoubleDom";GameConfig[2].Prefix="DOM";GameConfig[2].Acronym="DOM";GameConfig[2].GameName="Double Domination";GameConfig[2].Mutators="";GameConfig[2].Options="";
//		GameConfig[3].GameClass="XGame.xCTFGame";GameConfig[3].Prefix="CTF";GameConfig[3].Acronym="CTF";GameConfig[3].GameName="Capture the Flag";GameConfig[3].Mutators="";GameConfig[3].Options="";
//		GameConfig[4].GameClass="XGame.xBombingRun";GameConfig[4].Prefix="BR";GameConfig[4].Acronym="BR";GameConfig[4].GameName="Bombing Run";GameConfig[4].Mutators="";GameConfig[4].Options="";
//        // bonus pack game types
//		GameConfig[5].GameClass="BonusPack.xMutantGame";GameConfig[5].Prefix="DM";GameConfig[5].Acronym="MUT";GameConfig[5].GameName="Mutant";GameConfig[5].Mutators="";GameConfig[5].Options="";
//		GameConfig[6].GameClass="BonusPack.xLastManStandingGame";GameConfig[6].Prefix="DM";GameConfig[6].Acronym="LMS";GameConfig[6].GameName="Last Man Standing";GameConfig[6].Mutators="";GameConfig[6].Options="";
//		GameConfig[7].GameClass="SkaarjPack.Invasion";GameConfig[7].Prefix="DM";GameConfig[7].Acronym="INV";GameConfig[7].GameName="Invasion";GameConfig[7].Mutators="";GameConfig[7].Options="";
//		// UT2004 game types
//		GameConfig[8].GameClass="Onslaught.ONSOnslaughtGame";GameConfig[8].Prefix="ONS";GameConfig[8].Acronym="ONS";GameConfig[8].GameName="Onslaught";GameConfig[8].Mutators="";GameConfig[8].Options="";
//		GameConfig[9].GameClass="UT2k4Assault.ASGameInfo";GameConfig[9].Prefix="AS";GameConfig[9].Acronym="AS";GameConfig[9].GameName="Assault";GameConfig[9].Mutators="";GameConfig[9].Options="";
	}
	MapCount = 0;

	for(i=0;i < GameConfig.Length;i++)
		if(GameConfig[i].GameClass != "")
			log(GameConfig[i].GameName,'MapVote');

	log("MapListLoaderType = " $ MapListLoaderType,'MapVote');

	MapListLoaderClass = class<MapListLoader>(DynamicLoadObject(MapListLoaderType, class'Class'));
	Loader = spawn(MapListLoaderClass);
	if(Loader == None) // Failed to spawn MapListLoader
		Loader = spawn(class'DefaultMapListLoader'); // default
	Loader.LoadMapList(self);

	log(MapCount $ " maps loaded.",'MapVote');

	History.Save();

	if(bEliminationMode)
	{
		// Count the Remaining Enabled maps
		EnabledMapCount = 0;
		for(i=0;i<MapCount;i++)
		{
			if(MapList[i].bEnabled)
				EnabledMapCount++;
		}
		if(EnabledMapCount < MinMapCount || EnabledMapCount == 0)
		{
			log("Elimination Mode Reset/Reload.",'MapVote');
			RepeatLimit = 0;
			MapList.Length = 0;
			MapCount = 0;
			SaveConfig();
			Loader.LoadMapList(self);
		}
	}
	Loader.Destroy();
}
//------------------------------------------------------------------------------------------------
function AddMap(string MapName, string Mutators, string GameOptions) // called from the MapListLoader
{
	local MapHistoryInfo MapInfo;
	local bool bUpdate;
	local int i;

	for(i=0; i < MapList.Length; i++)  // dont add duplicate map names
		if(MapName ~= MapList[i].MapName)
			return;

	MapInfo = History.GetMapHistory(MapName);

	MapList.Length = MapCount + 1;
	MapList[MapCount].MapName = MapName;
	MapList[MapCount].PlayCount = MapInfo.P;
	MapList[MapCount].Sequence = MapInfo.S;
	if(MapInfo.S <= RepeatLimit && MapInfo.S != 0)
		MapList[MapCount].bEnabled = false; // dont allow players to vote for this one
	else
		MapList[MapCount].bEnabled = true;
	MapCount++;

	if(Mutators != "" && Mutators != MapInfo.U)
	{
		MapInfo.U = Mutators;
		bUpdate = True;
	}

	if(GameOptions != "" && GameOptions != MapInfo.G)
	{
		MapInfo.G = GameOptions;
		bUpdate = True;
	}

	if(MapInfo.M == "") // if map not found in MapVoteHistory then add it
	{
		MapInfo.M = MapName;
		bUpdate = True;
	}

	if(bUpdate)
		History.AddMap(MapInfo);
}
//------------------------------------------------------------------------------------------------
function int GetMVRIIndex(PlayerController Player)
{
	local int i;

	for(i=0;i < MVRI.Length;i++)
		if(MVRI[i] != None && MVRI[i].PlayerOwner == Player)
			return i;
	return -1;
}
//------------------------------------------------------------------------------------------------
function SubmitMapVote(int MapIndex, int GameIndex, Actor Voter)
{
	local int Index, VoteCount, PrevMapVote, PrevGameVote;
	local MapHistoryInfo MapInfo;

	if(bLevelSwitchPending)
		return;

	Index = GetMVRIIndex(PlayerController(Voter));

	// check for invalid vote from unpatch players
	if( !IsValidVote(MapIndex, GameIndex) )
		return;

	if(PlayerController(Voter).PlayerReplicationInfo.bAdmin)  // Administrator Vote
	{
		TextMessage = lmsgAdminMapChange;
		TextMessage = Repl(TextMessage, "%mapname%", MapList[MapIndex].MapName $ "(" $ GameConfig[GameIndex].Acronym $ ")");
		Level.Game.Broadcast(self,TextMessage);

		log("Admin has forced map switch to " $ MapList[MapIndex].MapName $ "(" $ GameConfig[GameIndex].Acronym $ ")",'MapVote');

		CloseAllVoteWindows();

		bLevelSwitchPending = true;

		MapInfo = History.PlayMap(MapList[MapIndex].MapName);

		ServerTravelString = SetupGameMap(MapList[MapIndex], GameIndex, MapInfo);
		log("ServerTravelString = " $ ServerTravelString ,'MapVoteDebug');

		Level.ServerTravel(ServerTravelString, false);    // change the map

		settimer(1,true);
		return;
	}

	if( PlayerController(Voter).PlayerReplicationInfo.bOnlySpectator )
	{
		// Spectators cant vote
		PlayerController(Voter).ClientMessage(lmsgSpectatorsCantVote);
		return;
	}

	// check for invalid map, invalid gametype, player isnt revoting same as previous vote, and map choosen isnt disabled
	if(MapIndex < 0 ||
		MapIndex >= MapCount ||
		GameIndex >= GameConfig.Length ||
		(MVRI[Index].GameVote == GameIndex && MVRI[Index].MapVote == MapIndex) ||
		!MapList[MapIndex].bEnabled)
		return;

	log("___" $ Index $ " - " $ PlayerController(Voter).PlayerReplicationInfo.PlayerName $ " voted for " $ MapList[MapIndex].MapName $ "(" $ GameConfig[GameIndex].Acronym $ ")",'MapVote');

	PrevMapVote = MVRI[Index].MapVote;
	PrevGameVote = MVRI[Index].GameVote;
	MVRI[Index].MapVote = MapIndex;
	MVRI[Index].GameVote = GameIndex;

	if(bAccumulationMode)
	{
		if(bScoreMode)
		{
			VoteCount = GetAccVote(PlayerController(Voter)) + int(GetPlayerScore(PlayerController(Voter)));
			TextMessage = lmsgMapVotedForWithCount;
			TextMessage = repl(TextMessage, "%playername%", PlayerController(Voter).PlayerReplicationInfo.PlayerName );
			TextMessage = repl(TextMessage, "%votecount%", string(VoteCount) );
			TextMessage = repl(TextMessage, "%mapname%", MapList[MapIndex].MapName $ "(" $ GameConfig[GameIndex].Acronym $ ")" );
			Level.Game.Broadcast(self,TextMessage);
		}
		else
		{
			VoteCount = GetAccVote(PlayerController(Voter)) + 1;
			TextMessage = lmsgMapVotedForWithCount;
			TextMessage = repl(TextMessage, "%playername%", PlayerController(Voter).PlayerReplicationInfo.PlayerName );
			TextMessage = repl(TextMessage, "%votecount%", string(VoteCount) );
			TextMessage = repl(TextMessage, "%mapname%", MapList[MapIndex].MapName $ "(" $ GameConfig[GameIndex].Acronym $ ")" );
			Level.Game.Broadcast(self,TextMessage);
		}
	}
	else
	{
		if(bScoreMode)
		{
			VoteCount = int(GetPlayerScore(PlayerController(Voter)));
			TextMessage = lmsgMapVotedForWithCount;
			TextMessage = repl(TextMessage, "%playername%", PlayerController(Voter).PlayerReplicationInfo.PlayerName );
			TextMessage = repl(TextMessage, "%votecount%", string(VoteCount) );
			TextMessage = repl(TextMessage, "%mapname%", MapList[MapIndex].MapName $ "(" $ GameConfig[GameIndex].Acronym $ ")" );
			Level.Game.Broadcast(self,TextMessage);
		}
		else
		{
			VoteCount =  1;
			TextMessage = lmsgMapVotedFor;
			TextMessage = repl(TextMessage, "%playername%", PlayerController(Voter).PlayerReplicationInfo.PlayerName );
			TextMessage = repl(TextMessage, "%mapname%", MapList[MapIndex].MapName $ "(" $ GameConfig[GameIndex].Acronym $ ")" );
			Level.Game.Broadcast(self,TextMessage);
		}
	}
	UpdateVoteCount(MapIndex, GameIndex, VoteCount);
	if( PrevMapVote > -1 && PrevGameVote > -1 )
		UpdateVoteCount(PrevMapVote, PrevGameVote, -MVRI[Index].VoteCount); // undo previous vote
	MVRI[Index].VoteCount = VoteCount;
	TallyVotes(false);
}
//------------------------------------------------------------------------------------------------
function bool IsValidVote(int MapIndex, int GameIndex)
{
	local int i;
	local array<string> PrefixList;

	// check if the maps prefix is one listed for the gametype
	Split(GameConfig[GameIndex].Prefix, ",", PrefixList);

	for( i=0; i<PreFixList.Length; i++)
		if( left(MapList[MapIndex].MapName, len(PrefixList[i])) ~= PrefixList[i] )
			return true;

	return false;
}
//------------------------------------------------------------------------------------------------
function UpdateVoteCount(int MapIndex, int GameIndex, int VoteCount)
{
	local int x,i;
	local bool bFound;
	local MapVoteScore MVCData;

	// search for matching record
	for( x=0; x<MapVoteCount.Length; x++ )
	{
		if( MapVoteCount[x].GameConfigIndex == GameIndex &&
		    MapVoteCount[x].MapIndex == MapIndex)
		{
			MapVoteCount[x].VoteCount += VoteCount;
			MVCData = MapVoteCount[x];
			if(MapVoteCount[x].VoteCount <= 0)
				MapVoteCount.Remove( x, 1);
			bFound = true;
			break;
		}
	}

	if( !bFound && VoteCount > 0) // add new if not found
	{
		x = MapVoteCount.Length;
		MapVoteCount.Insert(x,1);
		MapVoteCount[x].GameConfigIndex = GameIndex;
		MapVoteCount[x].MapIndex = MapIndex;
		MapVoteCount[x].VoteCount = VoteCount;
		MVCData = MapVoteCount[x];
	}

	// send update to all players
	for( i=0; i<MVRI.Length; i++ )
	{
		if( MVRI[i] != none && MVRI[i].PlayerOwner != none )
			MVRI[i].ReceiveMapVoteCount(MVCData, False);
	}
}
//------------------------------------------------------------------------------------------------
function TallyVotes(bool bForceMapSwitch)
{
	local int        index,x,y,topmap,r,mapidx,gameidx;
	local array<int> VoteCount;
	local array<int> Ranking;
	local int        PlayersThatVoted;
	local int        TieCount;
	local string     CurrentMap;
	local int        Votes;
	local MapHistoryInfo MapInfo;

	if(bLevelSwitchPending)
		return;

	PlayersThatVoted = 0;
	VoteCount.Length = GameConfig.Length * MapCount;
	// note: VoteCount array is a 2 dimension array VoteCount[GameConfigIndex, MapIndex]
	//       Maps ->
	//       0 1 2 3 4 5 6 7 8
	// G     - - - - - - - - -
	// a  0 |0 0 0 0 0 0 0 2 0
	// m  1 |0 0 0 2 0 0 0 0 0
	// e  2 |0 6 0 0 0 5 0 0 0
	// s  3 |0 0 0 3 0 0 0 0 0

	for(x=0;x < MVRI.Length;x++) // for each player
	{
		if(MVRI[x] != none && MVRI[x].MapVote > -1 && MVRI[x].GameVote > -1) // if this player has voted
		{
			PlayersThatVoted++;

			if(bScoreMode)
			{
				if(bAccumulationMode)
					Votes = GetAccVote(MVRI[x].PlayerOwner) + int(GetPlayerScore(MVRI[x].PlayerOwner));
				else
					Votes = int(GetPlayerScore(MVRI[x].PlayerOwner));
			}
			else
			{  // Not Score Mode == Majority (one vote per player)
				if(bAccumulationMode)
					Votes = GetAccVote(MVRI[x].PlayerOwner) + 1;
				else
					Votes = 1;
			}
			VoteCount[MVRI[x].GameVote * MapCount + MVRI[x].MapVote] = VoteCount[MVRI[x].GameVote * MapCount + MVRI[x].MapVote] + Votes;

			if(!bScoreMode)
			{
				// If more then half the players voted for the same map as this player then force a winner
				if(Level.Game.NumPlayers > 2 && float(VoteCount[MVRI[x].GameVote * MapCount + MVRI[x].MapVote]) / float(Level.Game.NumPlayers) > 0.5 && Level.Game.bGameEnded)
					bForceMapSwitch = true;
			}
		}
	}
	log("___Voted - " $ PlayersThatVoted,'MapVoteDebug');

	if(Level.Game.NumPlayers > 2 && !Level.Game.bGameEnded && !bMidGameVote && (float(PlayersThatVoted) / float(Level.Game.NumPlayers)) * 100 >= MidGameVotePercent) // Mid game vote initiated
	{
		Level.Game.Broadcast(self,lmsgMidGameVote);
		bMidGameVote = true;
		// Start voting count-down timer
		TimeLeft = VoteTimeLimit;
		ScoreBoardTime = 1;
		settimer(1,true);
	}

	index = 0;
	for(x=0;x < VoteCount.Length;x++) // for each map
	{
		if(VoteCount[x] > 0)
		{
			Ranking.Insert(index,1);
			Ranking[index++] = x; // copy all vote indexes to the ranking list if someone has voted for it.
		}
	}

	if(PlayersThatVoted > 1)
	{
		// bubble sort ranking list by vote count
		for(x=0; x<index-1; x++)
		{
			for(y=x+1; y<index; y++)
			{
				if(VoteCount[Ranking[x]] < VoteCount[Ranking[y]])
				{
				topmap = Ranking[x];
				Ranking[x] = Ranking[y];
				Ranking[y] = topmap;
				}
			}
		}
	}
	else
	{
		if(PlayersThatVoted == 0)
		{
			GetDefaultMap(mapidx, gameidx);
			topmap = gameidx * MapCount + mapidx;
		}
		else
			topmap = Ranking[0];  // only one player voted
	}

	//Check for a tie
	if(PlayersThatVoted > 1) // need more than one player vote for a tie
	{
		if(index > 1 && VoteCount[Ranking[0]] == VoteCount[Ranking[1]] && VoteCount[Ranking[0]] != 0)
		{
			TieCount = 1;
			for(x=1; x<index; x++)
			{
				if(VoteCount[Ranking[0]] == VoteCount[Ranking[x]])
				TieCount++;
			}
			//reminder ---> int Rand( int Max ); Returns a random number from 0 to Max-1.
			topmap = Ranking[Rand(TieCount)];

			// Don't allow same map to be choosen
			CurrentMap = GetURLMap();

			r = 0;
			while(MapList[topmap - (topmap/MapCount) * MapCount].MapName ~= CurrentMap)
			{
				topmap = Ranking[Rand(TieCount)];
				if(r++>100)
					break;  // just incase
			}
		}
		else
		{
			topmap = Ranking[0];
		}
	}

	// if everyone has voted go ahead and change map
	if(bForceMapSwitch || (Level.Game.NumPlayers == PlayersThatVoted && Level.Game.NumPlayers > 0) )
	{
		if(MapList[topmap - topmap/MapCount * MapCount].MapName == "")
			return;

		TextMessage = lmsgMapWon;
		TextMessage = repl(TextMessage,"%mapname%",MapList[topmap - topmap/MapCount * MapCount].MapName $ "(" $ GameConfig[topmap/MapCount].Acronym $ ")");
		Level.Game.Broadcast(self,TextMessage);

		CloseAllVoteWindows();

		MapInfo = History.PlayMap(MapList[topmap - topmap/MapCount * MapCount].MapName);

		ServerTravelString = SetupGameMap(MapList[topmap - topmap/MapCount * MapCount], topmap/MapCount, MapInfo);
		log("ServerTravelString = " $ ServerTravelString ,'MapVoteDebug');

		History.Save();

		if(bEliminationMode)
			RepeatLimit++;

		if(bAccumulationMode)
			SaveAccVotes(topmap - topmap/MapCount * MapCount, topmap/MapCount);

		//if(bEliminationMode || bAccumulationMode)
		CurrentGameConfig = topmap/MapCount;
		if( !bAutoDetectMode )
			SaveConfig();

		bLevelSwitchPending = true;
		settimer(Level.TimeDilation,true);  // timer() will monitor the server-travel and detect a failure

		Level.ServerTravel(ServerTravelString, false);    // change the map
	}
}
//------------------------------------------------------------------------------------------------
event timer()
{
	local int mapidx,gameidx,i;
	local MapHistoryInfo MapInfo;

	if(bLevelSwitchPending)
	{
		if( Level.NextURL == "" )
		{
			if(Level.NextSwitchCountdown < 0)  // if negative then level switch failed
			{
				Log("___Map change Failed, bad or missing map file.",'MapVote');
				GetDefaultMap(mapidx, gameidx);
				MapInfo = History.PlayMap(MapList[mapidx].MapName);
				ServerTravelString = SetupGameMap(MapList[mapidx], gameidx, MapInfo);
				log("ServerTravelString = " $ ServerTravelString ,'MapVoteDebug');
				History.Save();
				Level.ServerTravel(ServerTravelString, false);    // change the map
			}
		}
		return;
	}

	if(ScoreBoardTime > -1)
	{
		if(ScoreBoardTime == 0)
			OpenAllVoteWindows();
		ScoreBoardTime--;
		return;
	}
	TimeLeft--;

	if(TimeLeft == 60 || TimeLeft == 30 || TimeLeft == 20 || TimeLeft == 10)  // play announcer count down voice
	{
		//log("___CountDown " $ TimeLeft,'MapVoteDebug');
		//BroadcastLocalizedMessage(class'MapVoteCountDownMsg', TimeLeft);
		for( i=0; i<MVRI.Length; i++)
			if(MVRI[i] != none && MVRI[i].PlayerOwner != none )
				MVRI[i].PlayCountDown(TimeLeft);
	}

	//if(TimeLeft < 11 && TimeLeft > 0 )  // play announcer voice Count Down
	//	BroadcastLocalizedMessage(class'VotingTimerMessage', TimeLeft);

	if(TimeLeft == 0)  // force level switch if time limit is up
		TallyVotes(true);   // if no-one has voted a random map will be choosen
}
//------------------------------------------------------------------------------------------------
function CloseAllVoteWindows()
{
	local int i;

	for(i=0; i < MVRI.Length;i++)
	{
		if(MVRI[i] != none)
		{
			//log("___Closing window " $ i,'MapVoteDebug');
			MVRI[i].CloseWindow();
		}
	}
}
//------------------------------------------------------------------------------------------------
function OpenAllVoteWindows()
{
	local int i;

	for(i=0; i < MVRI.Length;i++)
	{
		if(MVRI[i] != none)
		{
			//log("Opening window " $ i,'MapVoteDebug');
			MVRI[i].OpenWindow();
		}
	}
}
//------------------------------------------------------------------------------------------------
function string SetupGameMap(MapVoteMapList MapInfo, int GameIndex, MapHistoryInfo MapHistoryInfo)
{
	local string ReturnString;
	local string MutatorString;
	local string OptionString;

	// Add Per-GameType Mutators
	if(GameConfig[GameIndex].Mutators != "")
		MutatorString = MutatorString $ GameConfig[GameIndex].Mutators;

	// Add Per-Map Mutators
	if(MapHistoryInfo.U != "")
		MutatorString = MutatorString $ "," $ MapHistoryInfo.U;

	// Add Per-GameType Game Options
	if(GameConfig[GameIndex].Options != "")
		OptionString = OptionString $ Repl(Repl(GameConfig[GameIndex].Options,",","?")," ","");

	// Add Per-Map Game Options
	if(MapHistoryInfo.G != "")
		OptionString = OptionString $ "?" $ MapHistoryInfo.G;

	// create URL
	ReturnString = MapInfo.MapName; //$ ".ut2";
	ReturnString = ReturnString $ "?Game=" $ GameConfig[GameIndex].GameClass;

	if(MutatorString != "")
		ReturnString = ReturnString $ "?Mutator=" $ MutatorString;

	if(OptionString != "")
		ReturnString = ReturnString $ "?" $ OptionString;

	return ReturnString;
}
//------------------------------------------------------------------------------------------------
function bool HandleRestartGame()
{
	local int i;
	// Called by GameInfo.RestartGame at End Of Game
	// Return False to prevent traveling to next map
    log("____HandleRestartGame", 'MapVoteDebug');

	// disable voting in single player mode
    if( Level.NetMode == NM_StandAlone )
		return true;

	if( bMatchSetup ) // check if any match setup in progress
	{
		for( i=0; i<MVRI.Length; i++)
			if( MVRI[i] != none && MVRI[i].bMatchSetupPermitted )
				return false; // don't contine to next map
	}

	if(bMapVote && bAutoOpen)
	{
		//check if the game is an assault mod for UT2k3Assault
		if(string(Level.Game.Class) ~= "RoARAssault.xAssault")
			if(int(Level.Game.GameReplicationInfo.GetPropertyText("Part")) != 2)
				return true;

		// Start voting count-down timer
		TimeLeft = VoteTimeLimit;
		ScoreBoardTime = ScoreBoardDelay;
		settimer(1,true);
  		return false;
	}
	return true;
}
//------------------------------------------------------------------------------------------------
function MapVoteMapList GetMapList(int p_MapIndex)
{
	return MapList[p_MapIndex];
}
//------------------------------------------------------------------------------------------------
function MapVoteGameConfigLite GetGameConfig(int p_GameConfigIndex)
{
	local MapVoteGameConfigLite GameConfigItem;

	GameConfigItem.GameClass = GameConfig[p_GameConfigIndex].GameClass;
	GameConfigItem.Prefix = GameConfig[p_GameConfigIndex].Prefix;
	GameConfigItem.GameName = GameConfig[p_GameConfigIndex].GameName;

	return GameConfigItem;
}
//------------------------------------------------------------------------------------------------
function float GetPlayerScore(PlayerController Player)
{
	local float PlayerScore;

	if( !Level.Game.bGameEnded )
		PlayerScore = 1;
	else
		PlayerScore = Player.PlayerReplicationInfo.Score;

	if(PlayerScore < 1)
		PlayerScore = 1;

	return PlayerScore;
}
//------------------------------------------------------------------------------------------------
function int GetAccVote(PlayerController Player)
{
	local int x,PlayerAccVotes;
	local string PlayerName;

	PlayerName = Player.PlayerReplicationInfo.PlayerName;

	if(PlayerName == "")
		return(0);

	if(AccInfo.Length > 0)
	{
		// Find the players name in the saved accumulated votes
		for(x=0;x<AccInfo.Length;x++)
		{
			if(AccInfo[x].Name == PlayerName)
			{
				PlayerAccVotes = AccInfo[x].VoteCount;
				break;
			}
		}
	}
	else
		PlayerAccVotes = 0;
	return(PlayerAccVotes);
}
//------------------------------------------------------------------------------------------------
function SaveAccVotes(int WinningMapIndex, int WinningGameIndex)
{
	local Controller C;
	local PlayerController P;
	local int x, Index;
	local bool bFound;

	if(AccInfo.Length > 0)
	{
		for(x=0;x<AccInfo.Length;x++)
		{
			if(AccInfo[x].Name != "")
			{
				bFound = false;
				for(C=Level.ControllerList;C!=None;C=C.NextController)
				{
					P = PlayerController(C);
					if(C.bIsPlayer && P != None && AccInfo[x].Name == P.PlayerReplicationInfo.PlayerName)
					{
						Index = GetMVRIIndex(P);
						if(MVRI[Index] != None && MVRI[Index].MapVote != WinningMapIndex && MVRI[Index].GameVote != WinningGameIndex)
						{
							bFound = true;
							if(bScoreMode)
								AccInfo[x].VoteCount = AccInfo[x].VoteCount + int(GetPlayerScore(P));
							else
								AccInfo[x].VoteCount++;
						}
						break;
					}
				}
				if(!bFound)  // If this player is not here anymore remove or voted for winning map then remove
				{
					AccInfo[x].Name = "";
					AccInfo[x].VoteCount = 0;
				}
			}
		}

		// Remove blank entries
		for(x=AccInfo.Length-1;x>=0;x--)
		{
			if(AccInfo[x].Name == "")
			{
				//log("Removeing " $ AccInfo[x].Name);
				AccInfo.Remove(x,1);
			}
		}
	}

	// Add players who have not voted
	for(C=Level.ControllerList;C!=None;C=C.NextController)
	{
		P = PlayerController(C);
		if(C.bIsPlayer && P != None)
		{
			bFound = false;
			if(AccInfo.Length > 0)
			{
				for(x=0;x<AccInfo.Length;x++)
				{
					if(AccInfo[x].Name == P.PlayerReplicationInfo.PlayerName)
					{
						bFound = true;
						break;
					}
				}
			}
			Index = GetMVRIIndex(P);
			if(!bFound && MVRI[Index].MapVote != WinningMapIndex && MVRI[Index].GameVote != WinningGameIndex)
			{
				// Not found, so add it
				AccInfo.Insert(AccInfo.Length,1);
				AccInfo[AccInfo.Length - 1].Name = P.PlayerReplicationInfo.PlayerName;
				if(bScoreMode)
					AccInfo[AccInfo.Length - 1].VoteCount = int(GetPlayerScore(P));
				else
					AccInfo[AccInfo.Length - 1].VoteCount = 1;
			}
		}
	}
}
//------------------------------------------------------------------------------------------------
function GetDefaultMap(out int mapidx, out int gameidx)
{
	local int i,x,y,r,p,GCIdx;
	local array<string> PrefixList;
	local bool bLoop;

	if(MapCount <= 0)
		return;

	// set the default gametype
	if(bDefaultToCurrentGameType)
		GCIdx = CurrentGameConfig;
	else
		GCIdx = DefaultGameConfig;

	// Parse Prefix list for default game type
	PrefixList.Length = 0;
	p = Split(GameConfig[GCIdx].Prefix, ",", PrefixList);
	if(PrefixList.Length == 0)
	{
		gameidx = GCIdx;
		mapidx = 0;
		return;
	}

	// choose a map at random, check if it is enabled and the prefix is in the prefix list
	r=0;
	bLoop = True;
	while(bLoop)
	{
		i = Rand(MapCount);
		if( MapList[i].bEnabled )
		{
			for(x=0; x < PrefixList.Length; x++)
			{
				if( left(MapList[i].MapName, len(PrefixList[x])) ~= PrefixList[x] )
				{
					bLoop = false;
					break;
				}
			}
		}

		if(bLoop && r++ > 100)
		{
			// give up after 100 unsuccessful attempts.
			// find the first map that matches up to default gametype
            for(i=0;i<=MapCount;i++)
			{
				if( MapList[i].bEnabled )
				{
					for(x=0; x < PrefixList.Length; x++)
					{
						if( left(MapList[i].MapName, len(PrefixList[x])) ~= PrefixList[x] )
						{
							// ding ding ding, found one
							bLoop = false;
							break;
						}
					}
				}
			}

			if(bLoop) // still didnt find any, then find the first enabled map and find its gameconfig
			{
				for(i=0;i<=MapCount;i++)
				{
					if( MapList[i].bEnabled )
					{
						// find prefix in GameConfigs
						for(y=0;y<GameConfig.Length;y++)
						{
							// Parse Prefix list for game type
							PrefixList.Length = 0;
							p = Split(GameConfig[y].Prefix, ",", PrefixList);
							if(PrefixList.Length > 0)
							{
								for(x=0; x < PrefixList.Length; x++)
								{
									if( left(MapList[i].MapName, len(PrefixList[x])) ~= PrefixList[x] )
									{
										// ding ding ding, found one
										GCIdx = y;
										bLoop = false;
										break;
									}
								}
							}
							if(!bLoop)
								break;
						}
						break;
					}
				}
			}
			break;
		}
	}
	gameidx = GCIdx;
	mapidx = i;
	log("Default Map Choosen = " $ MapList[mapidx].MapName $ "(" $ GameConfig[gameidx].Acronym $ ")",'MapVoteDebug');
}
//================================================================================================
//                                    Kick Voting
//================================================================================================
function SubmitKickVote(int PlayerID, Actor Voter)
{
	local int VoterID, VictumID, i, PreviousVote;
	local bool bFound;
	local string PlayerName;

	log("SubmitKickVote " $ PlayerID, 'MapVoteDebug');

	if(bLevelSwitchPending || !bKickVote)
		return;

	VoterID = GetMVRIIndex(PlayerController(Voter));

	// Find Player
	bFound = false;
	for(i=0;i < MVRI.Length;i++)
	{
		if(MVRI[i] != none && MVRI[i].PlayerOwner.PlayerReplicationInfo.PlayerID == PlayerID)
		{
			bFound = true;
			VictumID = i;
			PlayerName = MVRI[i].PlayerOwner.PlayerReplicationInfo.PlayerName;
			break;
		}
	}
	if(!bFound)
		return;

	if( MVRI[VoterID].KickVote == VictumID ) // if vote is for same player stop
		return;

	if( PlayerController(Voter).PlayerReplicationInfo.bAdmin )  // Administrator Vote
	{
		log("___Admin " $ PlayerController(Voter).PlayerReplicationInfo.PlayerName $ " kicked " $ PlayerName,'MapVote');
		KickPlayer(VictumID);
		return;
	}

	if( PlayerController(Voter).PlayerReplicationInfo.bOnlySpectator )
	{
		// Spectators cant vote
		PlayerController(Voter).ClientMessage(lmsgSpectatorsCantVote);
		return;
	}

	// cant kick admin
	if(MVRI[VictumID].PlayerOwner.PlayerReplicationInfo.bAdmin || NetConnection(MVRI[VictumID].PlayerOwner.Player) == None)
	{
		TextMessage = lmsgKickVoteAdmin;
		TextMessage = repl(TextMessage,"%playername%",PlayerController(Voter).PlayerReplicationInfo.PlayerName);
		Level.Game.Broadcast(self,TextMessage);
		return;
	}

	log("___" $ PlayerController(Voter).PlayerReplicationInfo.PlayerName $ " placed a kick vote against " $ PlayerName,'MapVote');
	if(bAnonymousKicking)
	{
		TextMessage = lmsgAnonymousKickVote;
		TextMessage = repl(TextMessage,"%playername%",PlayerName);
		Level.Game.Broadcast(self,TextMessage);
	}
	else
	{
		TextMessage = lmsgKickVote;
		TextMessage = repl(TextMessage,"%playername1%",PlayerController(Voter).PlayerReplicationInfo.PlayerName);
		TextMessage = repl(TextMessage,"%playername2%",PlayerName);
		Level.Game.Broadcast(self,TextMessage);
	}
	PreviousVote = MVRI[VoterID].KickVote;
	MVRI[VoterID].KickVote = VictumID;

  	UpdateKickVoteCount(MVRI[VictumID].PlayerID, 1);
	if( PreviousVote > -1 )
		UpdateKickVoteCount(MVRI[PreviousVote].PlayerID, -1); // undo previous vote

	TallyKickVotes();
}
//------------------------------------------------------------------------------------------------
function UpdateKickVoteCount(int PlayerID, int VoteCountDelta)
{
	local int x,i;
	local bool bFound;

	if( PlayerID < 0 )
		return;

	// search for matching record
	for( x=0; x<KickVoteCount.Length; x++ )
	{
		if( KickVoteCount[x].PlayerID == PlayerID)
		{
			if( VoteCountDelta == 0 )
				KickVoteCount[x].KickVoteCount = 0;
			else
				KickVoteCount[x].KickVoteCount += VoteCountDelta;

			if( KickVoteCount[x].KickVoteCount < 0 )
			   KickVoteCount[x].KickVoteCount = 0;
			bFound = true;
			break;
		}
	}

	if( !bFound && VoteCountDelta > 0) // add new if not found
	{
		x = KickVoteCount.Length;
		KickVoteCount.Insert(x,1);
		KickVoteCount[x].PlayerID = PlayerID;
		KickVoteCount[x].KickVoteCount = 1;
	}

	// send update to all players
	for( i=0; i<MVRI.Length; i++ )
	{
		if( MVRI[i] != none && MVRI[i].PlayerOwner != none && x < KickVoteCount.Length )
			MVRI[i].ReceiveKickVoteCount(KickVoteCount[x], False);
	}
}
//------------------------------------------------------------------------------------------------
function TallyKickVotes()
{
	local int i,x,y,index,PlayersThatVoted,Lamer;
	local array<int> VoteCount;
	local array<int> Ranking;

	VoteCount.Length = MVRI.Length;

	// tally up the votes
	for(i=0;i < MVRI.Length;i++)
	{
		if(MVRI[i] != None && MVRI[i].KickVote != -1) // if this player has voted
		{
			PlayersThatVoted++;
			VoteCount[MVRI[i].KickVote]++; // increment the votecount for this player
		}
	}

	index = 0;
	for(i=0;i < VoteCount.Length;i++) // for each player
	{
		if(VoteCount[i] > 0)
		{
			Ranking.Insert(index,1);
			Ranking[index++] = i;
		}
	}

	if(PlayersThatVoted > 1)
	{
		// bubble sort ranking list by vote count
		for(x=0; x<index-1; x++)
		{
			for(y=x+1; y<index; y++)
			{
				if(VoteCount[Ranking[x]] < VoteCount[Ranking[y]])
				{
				Lamer = Ranking[x];
				Ranking[x] = Ranking[y];
				Ranking[y] = Lamer;
				}
			}
		}
		Lamer = Ranking[0];
	}

	// if more than KickPercent of the players voted to kick this player then kick
	// TODO: For TESTING only , remove
	//if(Level.Game.NumPlayers > 2 && ((float(VoteCount[Lamer])/float(Level.Game.NumPlayers))*100 >= KickPercent))
	if(((float(VoteCount[Lamer])/float(Level.Game.NumPlayers))*100 >= KickPercent))
	{
		KickPlayer(Lamer);
		return;
	}
}
//------------------------------------------------------------------------------------------------
function KickPlayer(int PlayerIndex)
{
	local int i;

	if( MVRI[PlayerIndex] == none || MVRI[PlayerIndex].PlayerOwner == none )
		return;

	TextMessage = "%playername% has been kicked.";
	TextMessage = repl(TextMessage,"%playername%",MVRI[PlayerIndex].PlayerOwner.PlayerReplicationInfo.PlayerName);
	Level.Game.Broadcast(self,TextMessage);

	if(bKickVote)
	{
		// Reset votes
		for(i=0;i < MVRI.Length;i++)
		{
			if(MVRI[i] != None && MVRI[i].KickVote != -1)
				MVRI[i].KickVote = -1;
		}
	}

	//close his/her voting window if open
	if(MVRI[PlayerIndex] != None)
		MVRI[PlayerIndex].CloseWindow();

	log("___" $ MVRI[PlayerIndex].PlayerOwner.PlayerReplicationInfo.PlayerName $ " has been kicked.",'MapVote');
	Level.Game.AccessControl.BanPlayer(MVRI[PlayerIndex].PlayerOwner, True); // session type ban
}
//================================================================================================
//                                    MatchSetup
//================================================================================================
function bool MatchSetupLogin(string UserID, string Password, Actor Requestor, out int SecLevel)
{
	local xAdminUser AdminUser;

	if( bMatchSetup && PlayerController(Requestor) != none )
	{
		if( UserID ~= "Admin" && PlayerController(Requestor).PlayerReplicationInfo.bAdmin )
		{
			SecLevel = 255;
			return True; // this user is already logged in as an administrator
		}

		if( Level.Game.AccessControl.AdminLogin( PlayerController(Requestor), UserID, Password) )
		{
			// Xm = MatchSetup Priv
			if( Level.Game.AccessControl.CanPerform(PlayerController(Requestor), "Xm") )
			{
				Log(UserID $ " has logged in to MatchSetup.");
				AdminUser = Level.Game.AccessControl.GetUser(UserID);
				if( AdminUser != none )
					SecLevel = AdminUser.MaxSecLevel();
				else
					SecLevel = 0;
				// hack for default AccessControl setup
				if( SecLevel == 0 && PlayerController(Requestor).PlayerReplicationInfo.bAdmin )
					SecLevel = 255;

				Log("SecLevel = " $ SecLevel);
				return True;
			}
			else
			{
				log(UserID $ " doesnt have MatchSetup permissions.");
				PlayerController(Requestor).ClientMessage(lmsgMatchSetupPermission);
				Return False;
			}
		}
		else
		{
			Log(UserID $ " password was invalid.");
			PlayerController(Requestor).ClientMessage(lmsgInvalidPassword);
			return False;
		}
	}
}
//------------------------------------------------------------------------------------------------
function MatchSetupLogout(Actor Requestor)
{
	if( bMatchSetup && PlayerController(Requestor) != none )
		Level.Game.AccessControl.AdminLogout( PlayerController(Requestor) );
}
//================================================================================================
//                                    Configuration
//================================================================================================
static function FillPlayInfo(PlayInfo PlayInfo)
{
	// this sends configuration settings to ether the WebAdmin, Server Rules GUI,
	// or MatchSetup via the PlayInfo class.
	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting(default.MapVoteGroup,"bMapVote",default.PropsDisplayText[0],0,1,"Check",,,True,False);
	PlayInfo.AddSetting(default.MapVoteGroup,"bAutoOpen",default.PropsDisplayText[1],0,1,"Check",,,True,True);
	PlayInfo.AddSetting(default.MapVoteGroup,"ScoreBoardDelay",default.PropsDisplayText[2],0,1,"Text","3;0:60",,True,True);
	PlayInfo.AddSetting(default.MapVoteGroup,"bScoreMode",default.PropsDisplayText[3],0,1,"Check",,,True,True);
	PlayInfo.AddSetting(default.MapVoteGroup,"bAccumulationMode",default.PropsDisplayText[4],0,1,"Check",,,True,True);
	PlayInfo.AddSetting(default.MapVoteGroup,"bEliminationMode",default.PropsDisplayText[5],0,1,"Check",,,True,True);
	PlayInfo.AddSetting(default.MapVoteGroup,"MinMapCount",default.PropsDisplayText[6],0,1,"Text","4;1:9999",,True,True);
	PlayInfo.AddSetting(default.MapVoteGroup,"RepeatLimit",default.PropsDisplayText[7],0,1,"Text","4;0:9999",,True,True);
	PlayInfo.AddSetting(default.MapVoteGroup,"VoteTimeLimit",default.PropsDisplayText[8],0,1,"Text","3;10:300",,True,True);
	PlayInfo.AddSetting(default.MapVoteGroup,"MidGameVotePercent",default.PropsDisplayText[9],0,1,"Text","3;1:100",,True,True);
	PlayInfo.AddSetting(default.MapVoteGroup,"bDefaultToCurrentGameType",default.PropsDisplayText[10],0,1,"Check",,,True,True);
	PlayInfo.AddSetting(default.MapVoteGroup,"GameConfig",default.PropsDisplayText[15],0, 1,"Custom",";;"$default.GameConfigPage,,True,True);
	//PlayInfo.AddSetting(default.MapVoteGroup,"MapListLoaderType",default.PropsDisplayText[16],0, 1,"Custom",";;"$default.MapListConfigPage,,True,True);

	PlayInfo.AddSetting(default.KickVoteGroup,"bKickVote",default.PropsDisplayText[11],0,1,"Check",,,True,True);
	PlayInfo.AddSetting(default.KickVoteGroup,"KickPercent",default.PropsDisplayText[12],0,1,"Text","3;1:100",,True,True);
	PlayInfo.AddSetting(default.KickVoteGroup,"bAnonymousKicking",default.PropsDisplayText[13],0,1,"Check",,,True,True);

	PlayInfo.AddSetting(default.ServerGroup,"bMatchSetup",default.PropsDisplayText[14],0,1,"Check",,,True,True);

	class'DefaultMapListLoader'.static.FillPlayInfo(PlayInfo);
	PlayInfo.PopClass();
}

static event bool AcceptPlayInfoProperty(string PropertyName)
{
	if ( class'LevelInfo'.static.IsDemoBuild() )
		return false;

	switch ( PropertyName )
	{
	case "bMapVote":
	case "bAutoOpen":
	case "ScoreBoardDelay":
	case "bScoreMode":
	case "bAccumulationMode":
	case "bEliminationMode":
	case "MinMapCount":
	case "RepeatLimit":
	case "VoteTimeLimit":
	case "MidGameVotePercent":
	case "bDefaultToCurrentGameType":
	case "GameConfig":
	case "MapListLoaderType":
		 return MAPVOTEALLOWED;

	case "bKickVote":
	case "KickPercent":
	case "bAnonymousKicking":
		return KICKVOTEALLOWED;

	case "bMatchSetup":
		return MATCHSETUPALLOWED;
	}

	return Super.AcceptPlayInfoProperty(PropertyName);
}

//------------------------------------------------------------------------------------------------
static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "bMapVote":					return default.PropDescription[0];
		case "bAutoOpen":					return default.PropDescription[1];
		case "ScoreBoardDelay":				return default.PropDescription[2];
		case "bScoreMode":					return default.PropDescription[3];
		case "bAccumulationMode":			return default.PropDescription[4];
		case "bEliminationMode":			return default.PropDescription[5];
		case "MinMapCount":					return default.PropDescription[6];
		case "RepeatLimit":					return default.PropDescription[7];
		case "VoteTimeLimit":				return default.PropDescription[8];
		case "MidGameVotePercent":			return default.PropDescription[9];
		case "bDefaultToCurrentGameType":	return default.PropDescription[10];
		case "bKickVote":					return default.PropDescription[11];
		case "KickPercent":					return default.PropDescription[12];
		case "bAnonymousKicking":			return default.PropDescription[13];
		case "bMatchSetup":			        return default.PropDescription[14];
		case "GameConfig":                  return default.PropDescription[15];
		case "MapListLoaderType":           return default.PropDescription[16];
	}
	return "";
}
//------------------------------------------------------------------------------------------------
function string GetConfigArrayData(string ConfigArrayName, int RowIndex, int ColumnIndex)
{
	switch( Caps(ConfigArrayName) )
	{
		case "GAMECONFIG":
			if( RowIndex > GameConfig.Length-1 || ColumnIndex > 5 )
				return "";

			switch( ColumnIndex )
			{
	        	case 0:
					return "GAMETYPE;50;" $ GameConfig[RowIndex].GameClass;
				case 1:
					return "TEXT;50;" $ GameConfig[RowIndex].Prefix;
				case 2:
					return "TEXT;20;" $ GameConfig[RowIndex].Acronym;
				case 3:
					return "TEXT;50;" $ GameConfig[RowIndex].GameName;
				case 4:
					return "MUTATORS;255;" $ GameConfig[RowIndex].Mutators;
				case 5:
					return "TEXT;255;" $ GameConfig[RowIndex].Options;
				default:
					return "";
			}
			break;

		case "MAPLIST":
			// TODO: *
			break;
	}
}
//------------------------------------------------------------------------------------------------
function string GetConfigArrayColumnTitle(string ConfigArrayName, int ColumnIndex)
{
	switch( Caps(ConfigArrayName) )
	{
		case "GAMECONFIG":
			if( ColumnIndex > 5 || ColumnIndex < 0 )
				return "";
   			return lmsgGameConfigColumnTitle[ColumnIndex];

		case "MAPLIST":
			// TODO: *
			break;
	}
}
//------------------------------------------------------------------------------------------------
function DeleteConfigArrayItem(string ConfigArrayName, int RowIndex)
{
	switch( Caps(ConfigArrayName) )
	{
		case "GAMECONFIG":
			if( RowIndex < 0 || RowIndex > GameConfig.Length-1 )
				return;
			GameConfig.Remove(RowIndex,1);
   			return;

		case "MAPLIST":
			// TODO: *
			break;
	}
}
//------------------------------------------------------------------------------------------------
function int AddConfigArrayItem(string ConfigArrayName)
{
	switch( Caps(ConfigArrayName) )
	{
		case "GAMECONFIG":
			GameConfig.Insert(GameConfig.Length,1);
			GameConfig[GameConfig.Length-1].GameClass = "XGame.xDeathMatch";
			GameConfig[GameConfig.Length-1].Prefix = "";
			GameConfig[GameConfig.Length-1].Acronym = "";
			GameConfig[GameConfig.Length-1].GameName = "new";
			GameConfig[GameConfig.Length-1].Mutators = "";
			GameConfig[GameConfig.Length-1].Options = "";
   			return GameConfig.Length-1;

		case "MAPLIST":
			// TODO: *
			break;
	}
}
//------------------------------------------------------------------------------------------------
function UpdateConfigArrayItem(string ConfigArrayName, int RowIndex, int ColumnIndex, string NewValue)
{
	switch( Caps(ConfigArrayName) )
	{
		case "GAMECONFIG":
			if( RowIndex < 0 || RowIndex > GameConfig.Length-1 || ColumnIndex > 5 )
				return;

			switch( ColumnIndex )
			{
	        	case 0:
					GameConfig[RowIndex].GameClass = NewValue;
					break;
				case 1:
					GameConfig[RowIndex].Prefix = NewValue;
					break;
				case 2:
					GameConfig[RowIndex].Acronym = NewValue;
					break;
				case 3:
					GameConfig[RowIndex].GameName = NewValue;
					break;
				case 4:
					GameConfig[RowIndex].Mutators = NewValue;
					break;
				case 5:
					GameConfig[RowIndex].Options = NewValue;
					break;
			}
   			return;

		case "MAPLIST":
			// TODO: *
			break;
	}
}
//------------------------------------------------------------------------------------------------
function int GetConfigArrayItemCount(string ConfigArrayName)
{
	switch( Caps(ConfigArrayName) )
	{
		case "GAMECONFIG":
   			return GameConfig.Length;

		case "MAPLIST":
			// TODO: *
			break;
	}
}
//------------------------------------------------------------------------------------------------
function ReloadAll( optional bool bParam )
{
	// TODO: ReloadAll
	ReloadMatchConfig(bParam,bParam);
}
//------------------------------------------------------------------------------------------------
function PropagateValue( VotingReplicationInfo Sender, string Type, string SettingName, string NewValue )
{
	local int i;

	// BroadCast change to all other MatchSetup users.
	for( i=0; i<MVRI.Length; i++)
	{
		if(MVRI[i].bMatchSetupPermitted && MVRI[i] != Sender)
		{
			MVRI[i].SendClientResponse( Type, MVRI[i].UpdateID, SettingName $ Chr(27) $ NewValue );
			MVRI[i].bMatchSetupAccepted = false;
		}
	}
}
//------------------------------------------------------------------------------------------------
function ReloadMatchConfig( bool bRefreshMaps, bool bRefreshMuts, optional PlayerController Caller )
{
	local int i;

	for ( i = 0; i < MVRI.Length; i++ )
	{
		// TODO - optimize to determine which settings need to be sent and only send those
		if ( MVRI[i] != None && MVRI[i].bMatchSetupPermitted )
		{
			// If we want a full refresh, have the client request the full refresh, so
			// that the client's current lists will be cleared first
			if ( bRefreshMaps && bRefreshMuts )
				MVRI[i].SendClientResponse(MVRI[i].LoginID,"1");
			else MVRI[i].RequestMatchSettings(bRefreshMaps, bRefreshMuts);
		}
	}
}
//------------------------------------------------------------------------------------------------
function MatchConfig CreateMatchProfile()
{
	return new(None, "MatchConfig" $ Chr(27) $ Level.Game.Class $ Chr(27) $ ServerNumber) class'MatchConfig';
}
//------------------------------------------------------------------------------------------------
function GetServerDetails( out GameInfo.ServerResponseLine ServerState )
{
	local int i;
	i = ServerState.ServerInfo.Length;

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "MapVoting";
	ServerState.ServerInfo[i++].Value = Locs(bMapVote);

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "KickVoting";
	ServerState.ServerInfo[i++].Value = Locs(bKickVote);
}
//------------------------------------------------------------------------------------------------

defaultproperties
{
     VoteTimeLimit=70
     ScoreBoardDelay=5
     bAutoOpen=True
     MidGameVotePercent=50
     MinMapCount=2
     MapVoteHistoryType="xVoting.MapVoteHistory_INI"
     RepeatLimit=4
     bDefaultToCurrentGameType=True
     KickPercent=51
     bAnonymousKicking=True
     MapListLoaderType="xVoting.DefaultMapListLoader"
     ServerNumber=1
     GameConfigPage="xVoting.MapVoteGameConfigPage"
     MapListConfigPage="xVoting.MapVoteMapListConfigPage"
     lmsgInvalidPassword="The password entered is invalid !"
     lmsgMatchSetupPermission="Sorry, you do not have permission to use Match Setup !"
     lmsgKickVote="%playername1% placed a kick vote against %playername2%"
     lmsgAnonymousKickVote="A kick vote has been placed against %playername%"
     lmsgKickVoteAdmin="%playername% attempted to submit a kick vote against the server administrator !"
     lmsgMapWon="%mapname% has won !"
     lmsgMidGameVote="Mid-Game Map Voting has been initiated !!!!"
     lmsgSpectatorsCantVote="Sorry, Spectators can not vote."
     lmsgMapVotedFor="%playername% has voted for %mapname%"
     lmsgMapVotedForWithCount="%playername% has placed %votecount% votes for %mapname%"
     PropsDisplayText(0)="Enable Map Voting"
     PropsDisplayText(1)="Auto Open GUI"
     PropsDisplayText(2)="ScoreBoard Delay"
     PropsDisplayText(3)="Score Mode"
     PropsDisplayText(4)="Accumulation Mode"
     PropsDisplayText(5)="Elimination Mode"
     PropsDisplayText(6)="Minimum Maps"
     PropsDisplayText(7)="Repeat Limit"
     PropsDisplayText(8)="Voting Time Limit"
     PropsDisplayText(9)="Mid-Game Vote Percent"
     PropsDisplayText(10)="Default Current GameType"
     PropsDisplayText(11)="Enable Kick Voting"
     PropsDisplayText(12)="Kick Vote Percent"
     PropsDisplayText(13)="Anonymous Kick Voting"
     PropsDisplayText(14)="Allow Match Setup"
     PropsDisplayText(15)="Game Configuration"
     PropsDisplayText(16)="Map List Configuration"
     PropDescription(0)="If enabled players can vote for maps."
     PropDescription(1)="If enabled the Map voting interface will automatically open at the end of each game."
     PropDescription(2)="Sets the number of seconds to delay after the end of each game before opening the voting interface."
     PropDescription(3)="If enabled, each player gets his or her score worth of votes."
     PropDescription(4)="If enabled, each player will accumulate votes each game until they win."
     PropDescription(5)="If enabled, available maps are disabled as they are played until there are X maps left."
     PropDescription(6)="The number of enabled maps that remain in the map list (in Elimination mode) before the map list is reset."
     PropDescription(7)="Number of previously played maps that should not be votable."
     PropDescription(8)="Limits how much time (in seconds) to allow for voting."
     PropDescription(9)="Percentage of players that must vote to trigger a Mid-Game vote."
     PropDescription(10)="If enabled, and there are no players on the server then the server will stay on the current game type."
     PropDescription(11)="If enable players can vote to kick other players."
     PropDescription(12)="The percentage of players that must vote against an individual player to have them kicked from the server."
     PropDescription(13)="If enabled players can place Kick votes without anyone knowing who placed the vote."
     PropDescription(14)="Enables match setup on the server - valid admin username & password is required in order to use this feature"
     PropDescription(15)="Opens the map voting game configuration screen"
     PropDescription(16)="Opens the map voting list configuration screen"
     lmsgAdminMapChange="Admin has forced map switch to %mapname%"
     lmsgGameConfigColumnTitle(0)="GameType"
     lmsgGameConfigColumnTitle(1)="MapPrefixes"
     lmsgGameConfigColumnTitle(2)="Abbreviation"
     lmsgGameConfigColumnTitle(3)="Name"
     lmsgGameConfigColumnTitle(4)="Mutators"
     lmsgGameConfigColumnTitle(5)="Options"
}
