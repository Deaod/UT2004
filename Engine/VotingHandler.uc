// ====================================================================
//  Class:  Engine.VotingHandler
//
//	Base class for the VotingHandler that handles the server side of
//  map and kick voting.
//
//  Written by Bruce Bickar
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class VotingHandler extends Info;

struct MapVoteGameConfig
{
	var string GameClass; // code class of game type. XGame.xDeathMatch
	var string Prefix;    // MapName Prefix. DM, CTF, BR etc.
	var string Acronym;   // Game Acronym (appended to map names in messages to help identify game type for map)
	var string GameName;  // Name or Title of the game type. "DeathMatch", "Capture The Flag"
	var string Mutators;  // Mutators to load with this gametype. "XGame.MutInstaGib,UnrealGame.MutBigHead,UnrealGame.MutLowGrav"
	var string Options;   // Game Options
};

struct MapVoteGameConfigLite
{
	var string GameClass; // code class of game type. XGame.xDeathMatch
	var string Prefix;    // MapName Prefix. DM, CTF, BR etc.
	var string GameName;  // Name or Title of the game type. "DeathMatch", "Capture The Flag"
};

struct MapVoteMapList
{
	var string MapName;
	var int PlayCount;
	var int Sequence;
	var bool bEnabled;
};

struct MapHistoryInfo
{
	var string M;  // MapName  - Used short/single character var names to keep ini file smaller
	var int    P;  // Play count. Number of times map has been played
	var int    S;  // Sequence. The order in which the map was played
	var string G;  // per map game options
	var string U;  // per map mutators
};

struct MapVoteScore
{
	var int MapIndex;
	var int GameConfigIndex;
	var int VoteCount;
};

struct KickVoteScore
{
	var int PlayerID;
	//var string PlayerName;
	var int Team;
	var int KickVoteCount;
};

struct AccumulationData  // used to save player's unused vote between maps when in Accumulation mode
{
	var string Name;
	var int VoteCount;
};

function PlayerJoin(PlayerController Player);
function PlayerExit(Controller Exiting);
function bool HandleRestartGame()
{
	return true;
}
function string GetConfigArrayData(string ConfigArrayName, int RowIndex, int ColumnIndex); // should return "type;maxlength;value"
function string GetConfigArrayColumnTitle(string ConfigArrayName, int ColumnIndex);
function DeleteConfigArrayItem(string ConfigArrayName, int RowIndex);
function int AddConfigArrayItem(string ConfigArrayName);
function UpdateConfigArrayItem(string ConfigArrayName, int RowIndex, int ColumnIndex, string NewValue);
function int GetConfigArrayItemCount(string ConfigArrayName);

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);
}

static function bool IsEnabled()
{
	return false;
}

function ReloadAll( optional bool bParam );

// server querying
function GetServerDetails( out GameInfo.ServerResponseLine ServerState );

defaultproperties
{
}
