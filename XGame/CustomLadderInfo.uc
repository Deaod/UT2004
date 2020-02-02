//==============================================================================
// Base class for custom ladders
//
// Written by Michiel Hendriks
// (c) 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class CustomLadderInfo extends Object abstract;

var string LadderName;
var localized array<string> EntryLabels;
var array<UT2K4MatchInfo> Matches;

/**
	called when the game was a challenge game and was not one of the default special events.
	Fill the GUIPages array with pages you want to be opened after this special event has been processed.
	Yes I know this method sucks, but it was the best I could come up with without a lot of changes in the current system.
*/
static function HandleSpecialEvent(UT2K4GameProfile GP, array<string> SpecialEvent, out array<ChallengeGame.TriString> GUIPages)
{
}

/** Handle match requirements, return false if a requirement has not been met */
static function bool HandleRequirements(UT2K4GameProfile GP, array<string> SpecialEvent, out array<ChallengeGame.TriString> GUIPages)
{
	return true;
}

/**
	will be called after the default info has been added to the history record.
	override this to change or append additional into.
*/
static function AddHistoryRecord(UT2K4GameProfile GP, int offset, GameInfo Game, PlayerReplicationInfo PRI, UT2K4MatchInfo MI)
{
}

defaultproperties
{
     LadderName="Custom Ladder"
}
