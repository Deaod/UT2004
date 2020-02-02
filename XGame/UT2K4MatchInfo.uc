//==============================================================================
// Additonal Match Info for UT2004 Ladder games
//
// Written by Michiel Hendriks
// (c) 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4MatchInfo extends MatchInfo;

/**
	Custom thumbnails, to override default behavior
*/
var Material ThumbnailActive, ThumbnailInActive;

/** alternative maps to use */
var array<string> AltLevels;
/**
	this number of entries in the AltLevels array has a higher priority,
	this means that only these will be randomly selected
*/
var byte Priority;

/** prize money you win */
var int PrizeMoney;

/** Fee to pay when you want to enter this match */
var int EntryFee;

/** a string with requirement information, parsed in UT2K4SP_Main and called from UT2K4SP_TabLadderBase */
var string Requirements;

/** if > 0 a time limit is set on the match */
var float TimeLimit;

defaultproperties
{
}
