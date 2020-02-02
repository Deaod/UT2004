//==============================================================================
// Single Player Challenge Game code - base class
//
// Written by Michiel Hendriks
// (c) 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class ChallengeGame extends Object abstract;

/** name of this challenge */
var localized string ChallengeName;
/** description of the challenge */
var localized string ChallengeDescription;
var localized string msgGotChallenged, msgWeChallenged, msgFor;

/** the challenge configuration menu */
var string ChallengeMenu;

struct TriString
{
	var string GUIPage;
	var string Param1, Param2;
};

/** called from GameProfile.RegisterGame() before anything is processed */
static function PreRegisterGame(UT2K4GameProfile GP, GameInfo currentGame, PlayerReplicationInfo PRI)
{
}

/** called from GameProfile.RegisterGame() after everything is processed */
static function PostRegisterGame(UT2K4GameProfile GP, GameInfo currentGame, PlayerReplicationInfo PRI)
{
}

/** start this challenge */
static function StartChallenge(UT2K4GameProfile GP, LevelInfo myLevel)
{
	GP.SpecialEvent = "";
	GP.bIsChallenge = true;
	GP.Balance -= GP.ChallengeInfo.EntryFee;
	GP.ChallengeGameClass = default.class;
	GP.StartNewMatch ( -1, myLevel );
}

/**
	called when the game was a challenge game and was not one of the default special events.
	Fill the GUIPages array with pages you want to be opened after this special event has been processed.
	Yes I know this method sucks, but it was the best I could come up with without a lot of changes in the current system.
*/
static function HandleSpecialEvent(UT2K4GameProfile GP, array<string> SpecialEvent, out array<TriString> GUIPages)
{
}

/** Handle match requirements, return false if a requirement has not been met */
static function bool HandleRequirements(UT2K4GameProfile GP, array<string> SpecialEvent, out array<TriString> GUIPages)
{
	return true;
}

/**
	will be called after the default info has been added to the history record.
	override this to change or append additional into.
*/
static function AddHistoryRecord(UT2K4GameProfile GP, int offset, GameInfo Game, PlayerReplicationInfo PRI, UT2K4MatchInfo MI)
{
	if (GP.bGotChallenged) GP.FightHistory[offset].MatchExtra = default.msgGotChallenged;
	else GP.FightHistory[offset].MatchExtra = default.msgWeChallenged;
	if (GP.ChallengeVariable != "") GP.FightHistory[offset].MatchExtra @= default.msgFor@GP.ChallengeVariable;
}

/**
	Return true when this challenge game can be used to challenge the player
*/
static function bool canChallenge(optional UT2K4GameProfile GP)
{
	return true;
}

/** return true when the team mates should be payed */
static function bool payTeamMates(UT2K4GameProfile GP)
{
	return true;
}

/**
	Return true when a team mate _may_ be injured, this does not mean a team mate will be injured.
	By default only challenged that where initiated by the player may have a team mate injured.
 */
static function bool injureTeamMate(UT2K4GameProfile GP)
{
	return !GP.bGotChallenged;
}

defaultproperties
{
     msgGotChallenged="We got challenged"
     msgWeChallenged="We challenged"
     msgFor="for"
}
