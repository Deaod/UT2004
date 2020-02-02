class LadderInfo extends Object
	abstract;

/*
 * LadderInfo contains all the information needed to determine 
 * the contents of each step in the single-player ladder, and 
 * to determine what match is next in each ladder.
 * 
 * author:  polge
 * last edit: capps
 */

var()	editinline	array<MatchInfo>	DMMatches;
var()	editinline	array<MatchInfo>	TDMMatches;
var()	editinline	array<MatchInfo>	DOMMatches;
var()	editinline	array<MatchInfo>	CTFMatches;
var()	editinline	array<MatchInfo>	BRMatches;
var()	editinline	array<MatchInfo>	ChampionshipMatches;

const DMLadderIndex = 0;
const TDMLadderIndex = 1;
const DOMLadderIndex = 2;
const CTFLadderIndex = 3;
const BRLadderIndex = 4;
const ChampionshipLadderIndex = 5;

var int OpenNextLadderAtRung[5];

static function string UpdateLadders(GameProfile G, int CurrentLadder)
{
	local string SpecialEvent;
	
	if ( G.LadderRung[CurrentLadder] > G.CurrentMenuRung ) {
		// they've chosen to play a match they've completed previously
		return "";
	}
	
	// updates ladder rungs appropriately
	switch( CurrentLadder )
	{
		case DMLadderIndex:
			/*if ( Default.OpenNextLadderAtRung[CurrentLadder] == G.LadderRung[CurrentLadder] )
			{
				G.LadderRung[TDMLadderIndex] = 0;
				SpecialEvent = "TDM OPENED";
			} 
			else if ( G.LadderRung[CurrentLadder] >= Default.DMMatches.Length )
			{
				G.LadderRung[CurrentLadder] = Default.DMMatches.Length;
				SpecialEvent = "DM COMPLETE";
			}
			else */
			SpecialEvent = Default.DMMatches[G.LadderRung[CurrentLadder]].SpecialEvent;
			break;
		case TDMLadderIndex:
			/*if ( G.LadderRung[CurrentLadder] >= Default.TDMMatches.Length )
			{
				G.LadderRung[CurrentLadder] = Default.TDMMatches.Length;
				SpecialEvent = "TDM COMPLETE";
			}
			else if ( Default.OpenNextLadderAtRung[CurrentLadder] == G.LadderRung[CurrentLadder] )
			{
				G.LadderRung[DOMLadderIndex] = 0;
				SpecialEvent = "DOM OPENED";
			}
			else */
				SpecialEvent = Default.TDMMatches[G.LadderRung[CurrentLadder]].SpecialEvent;
			break;
		case DOMLadderIndex:
			/*if ( G.LadderRung[CurrentLadder] >= Default.DOMMatches.Length )
			{
				G.LadderRung[CurrentLadder] = Default.DOMMatches.Length;
				SpecialEvent = "DOM COMPLETE";
			}
			else if ( Default.OpenNextLadderAtRung[CurrentLadder] == G.LadderRung[CurrentLadder] )
			{
				G.LadderRung[CTFLadderIndex] = 0;
				SpecialEvent = "CTF OPENED";
			}
			else */
				SpecialEvent = Default.DOMMatches[G.LadderRung[CurrentLadder]].SpecialEvent;
			break;
		case CTFLadderIndex:
			/*if ( G.LadderRung[CurrentLadder] >= Default.CTFMatches.Length )
			{
				G.LadderRung[CurrentLadder] = Default.CTFMatches.Length;
				SpecialEvent = "CTF COMPLETE";
			}
			else if ( Default.OpenNextLadderAtRung[CurrentLadder] == G.LadderRung[CurrentLadder] )
			{
				G.LadderRung[BRLadderIndex] = 0;
				SpecialEvent = "BR OPENED";
			}
			else */
				SpecialEvent = Default.CTFMatches[G.LadderRung[CurrentLadder]].SpecialEvent;
			break;
		case BRLadderIndex:
			/*if ( G.LadderRung[CurrentLadder] >= Default.BRMatches.Length )
			{
				G.LadderRung[CurrentLadder] = Default.BRMatches.Length;
				SpecialEvent = "BR COMPLETE";
			}
			else */
				SpecialEvent = Default.BRMatches[G.LadderRung[CurrentLadder]].SpecialEvent;
			break;
		case ChampionshipLadderIndex:
			/* if ( G.LadderRung[CurrentLadder] >= Default.ChampionshipMatches.Length )
			{
				G.LadderRung[CurrentLadder] = Default.ChampionshipMatches.Length;
				SpecialEvent = "CHAMPIONSHIP COMPLETE";
			}
			else */
				SpecialEvent = Default.ChampionshipMatches[G.LadderRung[CurrentLadder]].SpecialEvent;
			break;
	}

	// open new ladder if appropriate
	if ( InStr (SpecialEvent, "OPENED") >= 0 )
	{
		if ( Left (SpecialEvent, 3) == "TDM" ) 
		{
			G.LadderRung[TDMLadderIndex] = 0;
		}
		else if ( Left (SpecialEvent, 3) == "CTF" ) 
		{
			G.LadderRung[CTFLadderIndex] = 0;
		}
		else if ( Left (SpecialEvent, 3) == "DOM" ) 
		{
			G.LadderRung[DOMLadderIndex] = 0;
		}
		else if ( Left (SpecialEvent, 2) == "BR" ) 
		{
			G.LadderRung[BRLadderIndex] = 0;
		}
	}

	G.LadderRung[CurrentLadder] += 1;

	// check if championship ladder should be opened
	if ( (G.LadderRung[5] == -1)
		&& (G.LadderRung[0] >= Default.DMMatches.Length)
		&& (G.LadderRung[1] >= Default.TDMMatches.Length)
		&& (G.LadderRung[2] >= Default.DOMMatches.Length)
		&& (G.LadderRung[3] >= Default.CTFMatches.Length)
		&& (G.LadderRung[4] >= Default.BRMatches.Length) )
	{
		G.LadderRung[5] = 0;
		SpecialEvent = "CHAMPIONSHIP OPENED";
	}
	return SpecialEvent;		
}

// robust checks are in LadderInfo, returns none if not found
static function MatchInfo GetMatchInfo(int ladder, int rung) {

	local array<MatchInfo> matcharray;

	if (rung < 0) {
		return none;
	}

	switch (ladder) {
		case DMLadderIndex:
			matcharray = Default.DMMatches;
			break;
		case TDMLadderIndex:
			matcharray = Default.TDMMatches;
			break;
		case DOMLadderIndex:
			matcharray = Default.DOMMatches;
			break;
		case CTFLadderIndex:
			matcharray = Default.CTFMatches;
			break;
		case BRLadderIndex:
			matcharray = Default.BRMatches;
			break;
		case ChampionshipLadderIndex:
			matcharray = Default.ChampionshipMatches;
			break;
	}

	if ( matcharray.Length <= 0 ) {
		return none;
	}

	if ( rung >= matcharray.Length ) 
	{
		return matcharray[matcharray.Length-1];
	}

	return matcharray[rung];
}

static function MatchInfo GetCurrentMatchInfo(GameProfile G) {
	return GetMatchInfo (G.CurrentLadder, G.CurrentMenuRung);
}

static function string MakeURLFor(GameProfile G)
{
	local MatchInfo M;
	local string URL;

	M = GetCurrentMatchInfo(G);

	if ( M == none ) {
		Log("SINGLEPLAYER LadderInfo::MakeURLFor MatchInfo invalid.");
		return "";
	}

	G.EnemyTeam = M.EnemyTeamName;
	G.Difficulty = G.BaseDifficulty + M.DifficultyModifier;
	
	URL = M.LevelName$"?Name="$G.PlayerName$"?Character="$G.PlayerCharacter$"?SaveGame="$G.PackageName$M.URLString;
	if ( M.GoalScore != 0 )
		URL = URL$"?GoalScore="$M.GoalScore;
	if ( M.NumBots > 0 )
		URL = URL$"?NumBots="$M.NumBots;
	if ( M.GameType != "" )
		URL = URL$"?Game="$M.GameType;
	URL = URL$"?Team=1";  // always blue team
	return URL;
}

// Used in menus:  this is the gametype info for the next match
//FIXME!!  Useless and unfortunate code, must use localization mechanism
//@@ LOCALIZE ME
static function string GetMatchDescription (GameProfile G){
	local string retval;

	switch (G.CurrentLadder) {
	case DMLadderIndex:
		retval = "Deathmatch";
		break;
	case TDMLadderIndex:
		retval = "Team Deathmatch";
		break;
	case DOMLadderIndex:
		retval = "Domination";
		break;
	case CTFLadderIndex:
		retval = "Capture the Flag";
		break;
	case BRLadderIndex:
		retval = "Bombing Run";
		break;
	case ChampionshipLadderIndex:
		retval = "Championship Match";
		break;
	}

	return retval;
}

// handy helper function to convert numbers to lengths
static function int LengthOfLadder(int ladder) {
	switch (ladder) {
		case DMLadderIndex:
			return Default.DMMatches.Length;
		case TDMLadderIndex:
			return Default.TDMMatches.Length;
		case DOMLadderIndex:
			return Default.DOMMatches.Length;
		case CTFLadderIndex:
			return Default.CTFMatches.Length;
		case BRLadderIndex:
			return Default.BRMatches.Length;
		case ChampionshipLadderIndex:
			return Default.ChampionshipMatches.Length;
		default:
			return -1;		
	}
}

defaultproperties
{
     CTFMatches(0)=MatchInfo'Engine.LadderInfo.CTFMatchInfo1'
     OpenNextLadderAtRung(0)=3
     OpenNextLadderAtRung(1)=3
     OpenNextLadderAtRung(2)=2
     OpenNextLadderAtRung(3)=3
     OpenNextLadderAtRung(4)=3
}
