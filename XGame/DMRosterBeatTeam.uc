class DMRosterBeatTeam extends xDMRoster;

/*
 * Roster for deathmatch levels.
 * Each level has its own roster.  
 * This special roster subclass is used to populate an enemy team with the
 * player's selected teammates.
 */

// called immediately after spawning the roster class
function Initialize(int TeamBots)
{
	local GameProfile GP;
	local int i, j;

	GP = Level.Game.CurrentGameProfile;
	if ( GP == none ) {
		Log("DMRosterBeatTeam::Initialized() failed.  GameProfile == none.");
		return;
	}

	// create roster entries for single player's teammates
	for ( i=0; i<GP.PlayerTeam.Length; i++ )
	{
		j = Roster.Length;
		Roster.Length = Roster.Length + 1;
		Roster[j] = class'xRosterEntry'.Static.CreateRosterEntryCharacter(GP.PlayerTeam[i]);
	}

	// remaining team-specific info, might be used in menus at some point
	TeamName = GP.TeamName;
	TeamSymbolName = GP.TeamSymbolName;

	super.Initialize(TeamBots);
}
	

defaultproperties
{
     TeamSymbolName="TeamSymbols_UT2003.Sym01"
     TeamName="Death Match"
}
