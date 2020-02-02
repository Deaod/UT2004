//==============================================================================
// Team Roster, UT2K4 style
// Note: the first name in the RosterNames array is considered the Team Leader
//
// Written by Michiel Hendriks
// (c) 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4TeamRoster extends xTeamRoster abstract;

/**	Description */
var localized string TeamDescription;
/**	Team voiceover */
var sound VoiceOver;
/** Only the team name */
var sound TeamNameSound;
/**	Difficulty level */
var int TeamLevel;
/** The team leader, if this is empty the first RosterNames is used */
var string TeamLeader;

/** If TeamBots == 1 use the team leader, else use the default behavior */
function Initialize(int TeamBots)
{
	local array<string> RosterOverride;
	local int i;
	if (UT2K4GameProfile(Level.Game.CurrentGameProfile) != none)
	{
		if (UT2K4GameProfile(Level.Game.CurrentGameProfile).GetAltTeamRoster(string(class), RosterOverride))
		{
			RosterNames = RosterOverride;
			Roster.Length = RosterNames.length;
			for ( i = 0; i < RosterNames.Length; i++ )
			{
				Roster[i] = class'xRosterEntry'.Static.CreateRosterEntryCharacter(RosterNames[i]);
			}
		}
	}
	if (TeamBots != 1)
	{
		Super.Initialize(TeamBots);
		return;
	}
	// else pick the team leader
	if (TeamLeader == "") TeamLeader = RosterNames[0];
	Roster.Length = 1;
	Roster[0] = class'xRosterEntry'.Static.CreateRosterEntryCharacter(TeamLeader);
	Roster[0].PrecacheRosterFor(self);
}

function bool AddToTeam(Controller Other)
{
	local SquadAI DMSquad;
	// if a team game use the default routine
	if (TeamGame(Level.Game) != none) return Super.AddToTeam(Other);
	// otherwise add fake squads
	if ( Bot(Other) != None )
	{
		DMSquad = spawn(DeathMatch(Level.Game).DMSquadClass);
		DMSquad.AddBot(Bot(Other));
	}
	Other.PlayerReplicationInfo.Team = None;
	return true;
}

defaultproperties
{
}
