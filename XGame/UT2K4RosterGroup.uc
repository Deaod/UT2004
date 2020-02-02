//==============================================================================
// Roster Group, a collection of rosters, used in Single Player to group the
// diffirent enemy teams into difficulty levels
//
// Written by Michiel Hendriks
// (c) 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4RosterGroup extends Object abstract;

/** all team rosters */
var array<string> Rosters;
/** the difficulty of this roster */
var int Difficulty;

defaultproperties
{
}
