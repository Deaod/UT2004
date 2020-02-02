//==============================================================================
// Phantom Team Roster, game will shut down when you actually use this team
//
// Written by Michiel Hendriks
// (c) 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4PhantomRoster extends UT2K4TeamRoster abstract;

function Initialize(int TeamBots)
{
	Error("Tried to use a UT2K4PhantomRoster in game");
}

defaultproperties
{
}
