// ====================================================================
//  Class:  xVoting.MapVoteHistory
//
//	Interface class used for saving map voting stats/history data.
//
//  Written by Bruce Bickar
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================

//class MapVoteHistory extends Info DependsOn(VotingHandler);
class MapVoteHistory extends Object DependsOn(VotingHandler);

// This class is used by the VotingHandler to keep track of stats about maps
// that have been played on the server. The MapHistoryInfo data structure is 
// used to copy data in/out of this class.
//struct MapHistoryInfo
//{
//   var string M;  // MapName  - Used short/single character var names to keep ini file smaller
//   var int    P;  // Play count. Number of times map has been played
//   var int    S;  // Sequence. The order in which the map was played
//   var string G;  // per map game options
//   var string U;  // per map mutators
//};

// This class is meant to be inherited and functions implemented in the subclass.
// You can create subclasses in separate packages and then
// "plug-in" your subclass using the MapVoteHistoryType ini config setting in the VotingHandler.
// Examples: MapVoteHistoryType=Engine.MapVoteHistoryA  // default
//           MapVoteHistoryType=MyPackage.MapVoteHistory_ODBC
//           MapVoteHistoryType=MyOtherPackage.MapVoteHistory_XML 

function AddMap(VotingHandler.MapHistoryInfo MapInfo);  // add (or update if already exists) map to 
                                                        // the history data store.
function RemoveMap(string MapName);                     // remove a map from the history data store

function VotingHandler.MapHistoryInfo GetMapHistory(string MapName); // retrieve map info by MapName
function VotingHandler.MapHistoryInfo GetMapBySeq(int SeqNum);       // retrieve map info by Sequence number
function VotingHandler.MapHistoryInfo GetLeastPlayedMap();           // retrieve least played map info 
function VotingHandler.MapHistoryInfo GetMostPlayedMap();            // retrieve most played map info 

function VotingHandler.MapHistoryInfo PlayMap(string MapName); // increment maps playcount and set sequence to 1
                                                               // also returns map info to caller
function Save();                                               // save data changes to history data store

defaultproperties
{
}
