//==============================================================================
// Single Player Ladder Info
//
// Written by Michiel Hendriks
// (c) 2003, 2004, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4LadderInfo extends LadderInfo config;

var() editinline array<UT2K4MatchInfo> ASMatches;

/**
	New constants for ladder ids
	defined as vars for static outside access
*/
var int LID_DM, LID_TDM, LID_CTF, LID_BR, LID_DOM, LID_AS, LID_CHAMP;

/** custom ladders you can add to the game */
var config array< class<CustomLadderInfo> > AdditionalLadders;

/** challenge games */
var config array< class<ChallengeGame> > ChallengeGames;
// config breaks the array

/** for backward compatibility */
static function MatchInfo GetMatchInfo(int ladder, int rung)
{
	return GetUT2K4MatchInfo(ladder, rung, 0, true);
}

/**
	Retreives the match info and fills in the alternative map
	path is used as a constant random to define the path, should be a very large number
	if bSelect then path is the position in the AltLevels array to use
*/
static function UT2K4MatchInfo GetUT2K4MatchInfo(int ladder, int rung, optional int path, optional bool bSelect)
{
	local array<MatchInfo> matcharray;
	local UT2K4MatchInfo selmatch;
	local string tmp;
	local int i;

	//log("GetUT2K4MatchInfo"@ladder@rung@path);

	if (rung < 0)
	{
		Warn("rung < 0");
		return none;
	}

	switch (ladder)
	{
		case default.LID_DM:		matcharray = Default.DMMatches;	break;
		case default.LID_TDM:		matcharray = Default.TDMMatches; break;
		case default.LID_CTF:		matcharray = Default.CTFMatches; break;
		case default.LID_BR:		matcharray = Default.BRMatches; break;
		case default.LID_DOM:		matcharray = Default.DOMMatches; break;
		case default.LID_AS:		matcharray = Default.ASMatches;	break;
		case default.LID_CHAMP:		matcharray = Default.ChampionshipMatches; break;
		default:	if ((ladder >= 10) && (default.AdditionalLadders.length > (ladder-10)))
					{
						matcharray = default.AdditionalLadders[ladder-10].default.Matches;
					}
	}

	if ( matcharray.Length <= 0 )
	{
		Warn("matcharray.Length <= 0");
		return none;
	}

	if ( rung >= matcharray.Length ) selmatch = UT2K4MatchInfo(matcharray[matcharray.Length-1]);
		else selmatch = UT2K4MatchInfo(matcharray[rung]);

	if ((selmatch != none) && bSelect && (selmatch.AltLevels.length > 0))
	{
		tmp = selmatch.AltLevels[path % selmatch.AltLevels.length];
		if (tmp != "") selmatch.LevelName = tmp;
	}
	else if ((selmatch != none) && (selmatch.AltLevels.length > 0)) // select one from the list
	{
		path = abs(path + ((rung+1) * (ladder+1)));
		if (selmatch.Priority > 0) i = selmatch.Priority;
			else i = selmatch.AltLevels.length;
		tmp = selmatch.AltLevels[path % i];
		if (tmp != "") selmatch.LevelName = tmp;
		//Log("Set level name to:"@selmatch.LevelName);
	}
	if ( selmatch == none ) Warn("selmatch == none");
	return selmatch;
}

/**
	get the ID of the alternative level
	match priority has no relevance here
*/
static function byte GetAltLevel(int ladder, int rung, int path, int selected)
{
	local array<MatchInfo> matcharray;
	local UT2K4MatchInfo selmatch;
	local int origpath;

	if (rung < 0) return -1;

	switch (ladder)
	{
		case default.LID_DM:		matcharray = Default.DMMatches;	break;
		case default.LID_TDM:		matcharray = Default.TDMMatches; break;
		case default.LID_CTF:		matcharray = Default.CTFMatches; break;
		case default.LID_BR:		matcharray = Default.BRMatches; break;
		case default.LID_DOM:		matcharray = Default.DOMMatches; break;
		case default.LID_AS:		matcharray = Default.ASMatches;	break;
		case default.LID_CHAMP:		matcharray = Default.ChampionshipMatches; break;
		default:	if ((ladder >= 10) && (default.AdditionalLadders.length > (ladder-10)))
					{
						matcharray = default.AdditionalLadders[ladder-10].default.Matches;
					}
	}

	if ( matcharray.Length <= 0 ) return -1;

	if ( rung >= matcharray.Length ) selmatch = UT2K4MatchInfo(matcharray[matcharray.Length-1]);
		else selmatch = UT2K4MatchInfo(matcharray[rung]);

	if ((selmatch != none) && (selmatch.AltLevels.length > 0))
	{
		origpath = abs(path + ((rung+1) * (ladder+1)));
		if (selmatch.Priority > 0) origpath = origpath % selmatch.Priority;
			else origpath = origpath % selmatch.AltLevels.length;

		if (selected == origpath || selected == -1)
		{
			path = (abs(path + ((rung+1) * (ladder+1)))+1) % selmatch.AltLevels.length;
			if (path == origpath) path = (path + 1) % selmatch.AltLevels.length;
			//Log("GetAltLevel (path)"@path@origpath);
			return path;
		}
		//Log("GetAltLevel (orig)"@origpath@selected);
		return origpath;
	}
	return -1;
}

/** check if there is an alternative level */
static function bool HasAltLevel(int ladder, int rung)
{
	local array<MatchInfo> matcharray;
	local UT2K4MatchInfo selmatch;

	if (rung < 0) return false;

	switch (ladder)
	{
		case default.LID_DM:		matcharray = Default.DMMatches;	break;
		case default.LID_TDM:		matcharray = Default.TDMMatches; break;
		case default.LID_CTF:		matcharray = Default.CTFMatches; break;
		case default.LID_BR:		matcharray = Default.BRMatches; break;
		case default.LID_DOM:		matcharray = Default.DOMMatches; break;
		case default.LID_AS:		matcharray = Default.ASMatches;	break;
		case default.LID_CHAMP:		matcharray = Default.ChampionshipMatches; break;
		default:	if ((ladder >= 10) && (default.AdditionalLadders.length > (ladder-10)))
					{
						matcharray = default.AdditionalLadders[ladder-10].default.Matches;
					}
	}

	if ( matcharray.Length <= 0 ) return false;

	if ( rung >= matcharray.Length ) selmatch = UT2K4MatchInfo(matcharray[matcharray.Length-1]);
		else selmatch = UT2K4MatchInfo(matcharray[rung]);
	if (selmatch == none) return false;
	return (selmatch.AltLevels.length > 1);
}

static function MatchInfo GetCurrentMatchInfo(GameProfile G)
{
	if (UT2K4GameProfile(G) != none ) return G.GetMatchInfo(G.CurrentLadder, G.CurrentMenuRung);
	return GetUT2K4MatchInfo(G.CurrentLadder, G.CurrentMenuRung);
}

/**
	Get the number of matches in a ladder
*/
static function int LengthOfLadder(int ladder)
{
	switch (ladder)
	{
		case default.LID_DM:	return Default.DMMatches.Length;
		case default.LID_TDM:	return Default.TDMMatches.Length;
		case default.LID_CTF:	return Default.CTFMatches.Length;
		case default.LID_BR:	return Default.BRMatches.Length;
		case default.LID_DOM:	return Default.DOMMatches.Length;
		case default.LID_AS:	return Default.ASMatches.Length;
		case default.LID_CHAMP:	return Default.ChampionshipMatches.Length;
		default:	if ((ladder >= 10) && (default.AdditionalLadders.length > (ladder-10)))
					{
						return default.AdditionalLadders[ladder-10].default.Matches.Length;
					}
					return -1;
	}
}

/**
	Update the ladder
*/
static function string UpdateLadders(GameProfile G, int CurrentLadder)
{
	local string SpecialEvent;
	local UT2K4GameProfile GP;
	local int i,j;

	GP = UT2K4GameProfile(G);
	if (GP == none)
	{
		Warn("PC Load Letter"); // wtf does that mean?
		return "";
	}

	if (GP.bIsChallenge) return GP.ChallengeInfo.SpecialEvent;

	if (CurrentLadder < 10)
	{
		if ( GP.LadderProgress[CurrentLadder] > G.CurrentMenuRung )
		{
			// they've chosen to play a match they've completed previously
			return "";
		}
	}

	// updates ladder rungs appropriately
	switch( CurrentLadder )
	{
		case default.LID_DM:
			SpecialEvent = Default.DMMatches[GP.LadderProgress[CurrentLadder]].SpecialEvent;
			break;
		case default.LID_TDM:
			SpecialEvent = Default.TDMMatches[GP.LadderProgress[CurrentLadder]].SpecialEvent;
			break;
		case default.LID_CTF:
			SpecialEvent = Default.CTFMatches[GP.LadderProgress[CurrentLadder]].SpecialEvent;
			break;
		case default.LID_BR:
			SpecialEvent = Default.BRMatches[GP.LadderProgress[CurrentLadder]].SpecialEvent;
			break;
		case default.LID_DOM:
			SpecialEvent = Default.DOMMatches[GP.LadderProgress[CurrentLadder]].SpecialEvent;
			break;
		case default.LID_AS:
			SpecialEvent = Default.ASMatches[GP.LadderProgress[CurrentLadder]].SpecialEvent;
			break;
		case default.LID_CHAMP:
			SpecialEvent = Default.ChampionshipMatches[GP.LadderProgress[CurrentLadder]].SpecialEvent;
			break;
		default:	i = CurrentLadder-10;
					if ((i >= 0) && (default.AdditionalLadders.length > i))
					{
						j = GP.GetCustomLadderProgress(string(default.AdditionalLadders[i]));
						if ( j > G.CurrentMenuRung ) return "";
						SpecialEvent = default.AdditionalLadders[i].default.Matches[j].SpecialEvent;
						GP.SetCustomLadderProgress(string(default.AdditionalLadders[i]), 1);
						return SpecialEvent;
					}
					return "";
	}

	GP.LadderProgress[CurrentLadder] += 1;
	return SpecialEvent;
}

/**
	Return the friendly name of the current match's gametype
*/
static function string GetMatchDescription (GameProfile G)
{
	return GetLadderDescription(G.CurrentLadder, G.CurrentMenuRung);
}

static function string GetLadderDescription(int LadderId, optional int MatchId)
{
	local string retval;
	local CacheManager.GameRecord gr;

	switch (LadderId)
	{
		case default.LID_DM:
			retval = default.DMMatches[MatchId].GameType;
			break;
		case default.LID_TDM:
			retval = default.TDMMatches[MatchId].GameType;
			break;
		case default.LID_CTF:
			retval = default.CTFMatches[MatchId].GameType;
			break;
		case default.LID_BR:
			retval = default.BRMatches[MatchId].GameType;
			break;
		case default.LID_DOM:
			retval = default.DOMMatches[MatchId].GameType;
			break;
		case default.LID_AS:
			retval = default.ASMatches[MatchId].GameType;
			break;
		case default.LID_CHAMP:
			retval = default.ChampionshipMatches[MatchId].GameType;
			break;
		default:	if ((LadderId >= 10) && (default.AdditionalLadders.length > (LadderId-10)))
					{
						retval = default.AdditionalLadders[LadderId-10].default.Matches[MatchId].GameType;
					}
					else return "";
	}
	gr = class'CacheManager'.static.GetGameRecord(retval);
	return gr.GameName;
}

/** return the id of a random ladder */
static function int GetRandomLadder(optional bool bIncludeChamp)
{
	// +1 because DM will never be returned
	if (bIncludeChamp) return rand(default.LID_CHAMP)+1;
		else return rand(default.LID_AS)+1;
}

/** create a URL for a selected profile */
static function string MakeURLFor(GameProfile G)
{
	if ((UT2K4GameProfile(G) != none) && (UT2K4GameProfile(G).bIsChallenge))
		return MakeURLFoMatchInfo(UT2K4GameProfile(G).ChallengeInfo, G);
	return MakeURLFoMatchInfo(GetCurrentMatchInfo(G), G);
}

/** create a URL for the selected MatchInfo */
static function string MakeURLFoMatchInfo(MatchInfo M, GameProfile G)
{
	local string URL;

	if ( M == none ) {
		Warn("MatchInfo == none");
		return "";
	}

	G.EnemyTeam = M.EnemyTeamName;
	G.Difficulty = G.BaseDifficulty + M.DifficultyModifier;

	URL = M.LevelName$"?Name="$G.PlayerName$"?Character="$G.PlayerCharacter$"?SaveGame="$G.PackageName$M.URLString;
	if ( M.GoalScore != 0 )
		URL $= "?GoalScore="$M.GoalScore;
	if ( M.NumBots > 0 )
		URL $= "?NumBots="$M.NumBots;
	if ( M.GameType != "" )
		URL $= "?Game="$M.GameType;
	URL $= "?Team=1?NoSaveDefPlayer?ResetDefPlayer";
	// with ?NoSaveDefPlayer the DefaultPlayer properties won't be saved to the user.ini
	// with ?ResetDefPlayer the DefaultPlayer properties will be restored from the saved settings
	if (UT2K4MatchInfo(M) != none)
	{
		if (UT2K4MatchInfo(M).TimeLimit > 0)
		{
			URL $= "?TimeLimit="$string(UT2K4MatchInfo(M).TimeLimit);
		}
	}
	return URL;
}

/** return a random or selected challenge game */
static function class<ChallengeGame> GetChallengeGame(optional string ClassName, optional UT2K4GameProfile GP)
{
	local array< class<ChallengeGame> > chalgames;
	local int i;
	//log("GetChallengeGame"@ClassName);
	if (ClassName == "")
	{
		chalgames = default.ChallengeGames;
		while (chalgames.length > 0)
		{
			i = rand(chalgames.length);
			if (chalgames[i].static.canChallenge(GP)) return chalgames[i];
			chalgames.Remove(i, 1);
		}
		return none;
	}
	for (i = 0; i < default.ChallengeGames.length; i++)
	{
		if (string(default.ChallengeGames[i]) ~= ClassName)
		{
			if (default.ChallengeGames[i].static.canChallenge(GP)) return default.ChallengeGames[i];
			return none;
		}
	}
	return none;
}

defaultproperties
{
     ASMatches(0)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.AS1'
     ASMatches(1)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.AS2'
     ASMatches(2)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.AS3'
     ASMatches(3)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.AS4'
     ASMatches(4)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.AS5'
     ASMatches(5)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.AS6'
     LID_TDM=1
     LID_CTF=2
     LID_BR=3
     LID_DOM=4
     LID_AS=5
     LID_CHAMP=6
     ChallengeGames(0)=Class'XGame.BloodRites'
     ChallengeGames(1)=Class'XGame.ManoEMano'
     DMMatches(0)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.DM0'
     DMMatches(1)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.DM1'
     DMMatches(2)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.DM2'
     DMMatches(3)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.DM3'
     DMMatches(4)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.DM4'
     DMMatches(5)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.DM5'
     TDMMatches(0)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.TDM1'
     TDMMatches(1)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.TDM2'
     TDMMatches(2)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.TDM3'
     TDMMatches(3)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.TDM4'
     DOMMatches(0)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.DOM1'
     DOMMatches(1)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.DOM2'
     DOMMatches(2)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.DOM3'
     DOMMatches(3)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.DOM4'
     DOMMatches(4)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.DOM5'
     DOMMatches(5)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.DOM6'
     CTFMatches(0)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.CTF1'
     CTFMatches(1)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.CTF2'
     CTFMatches(2)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.CTF3'
     CTFMatches(3)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.CTF4'
     CTFMatches(4)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.CTF5'
     CTFMatches(5)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.CTF6'
     CTFMatches(6)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.CTF7'
     CTFMatches(7)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.CTF8'
     BRMatches(0)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.BR1'
     BRMatches(1)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.BR2'
     BRMatches(2)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.BR3'
     BRMatches(3)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.BR4'
     BRMatches(4)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.BR5'
     BRMatches(5)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.BR6'
     BRMatches(6)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.BR7'
     BRMatches(7)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.BR8'
     ChampionshipMatches(0)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.CHAMP1'
     ChampionshipMatches(1)=UT2K4MatchInfo'XGame.UT2K4LadderInfo.CHAMP2'
}
