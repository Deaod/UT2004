// ====================================================================
//  Class:  UT2K4UI.GUICharacterListTeam
//  Parent: UT2K4UI.GUICharacterList
//
//  Specialized version of charlist that allows manual addition/
//  removal of players.
//  author: capps 8/25/02
// ====================================================================

class GUICharacterListTeam extends GUICharacterList;

function InitList()
{
	ItemCount = 0;
}

/** Include only those players described with Menu=s */
function InitListInclusive(string s) {
	local int i,j;
	local array<xUtil.PlayerRecord> AllPlayerList;

	class'xUtil'.static.GetPlayerList(AllPlayerList);

	// Filter out to only characters with the 's' menu setting
	j=0;
	for(i=0; i<AllPlayerList.Length; i++)
	{
		if(AllPlayerList[i].Menu == s)
			PlayerList[j++] = AllPlayerList[i];
	}

	ItemCount = j;
	Index = 0;
}

/** Include all players except those described with Menu=s */
function InitListIncl(array<string> menus, optional string Race) {
	local int i,j;
	local array<xUtil.PlayerRecord> AllPlayerList;
	local string menulist;

	menulist = ";"$JoinArray(menus, ";")$";";
	class'xUtil'.static.GetPlayerList(AllPlayerList);

	// Filter out to only characters without the 's' menu setting
	j=0;
	for(i=0; i<AllPlayerList.Length; i++)
	{
		if ( InStr(menulist, ";"$AllPlayerList[i].Menu$";") != -1 && (Race=="" || (Caps(AllPlayerList[i].Species.default.SpeciesName)==Race)) )
			PlayerList[j++] = AllPlayerList[i];
	}

	ItemCount = j;
	Index = 0;
}

/** Include all players except those described with Menu=s */
function InitListExclusive(string s, optional string s2) {
	local int i,j;
	local array<xUtil.PlayerRecord> AllPlayerList;

	class'xUtil'.static.GetPlayerList(AllPlayerList);

	// Filter out to only characters without the 's' menu setting
	j=0;
	for(i=0; i<AllPlayerList.Length; i++)
	{
		if( (AllPlayerList[i].Menu != s) &&
			( (s2 == "") ||
			  (s2 != "" && AllPlayerList[i].Menu != s2)))	// if s2 isn't empty, use it as a filter too
			PlayerList[j++] = AllPlayerList[i];
	}

	ItemCount = j;
	Index = 0;
}

/** Include all players except those described with Menu=s */
function InitListExcl(array<string> menus, optional string Race) {
	local int i,j;
	local array<xUtil.PlayerRecord> AllPlayerList;
	local string menulist;

	menulist = ";"$JoinArray(menus, ";")$";";
	class'xUtil'.static.GetPlayerList(AllPlayerList);

	// Filter out to only characters without the 's' menu setting
	j=0;
	for(i=0; i<AllPlayerList.Length; i++)
	{
		if ( InStr(menulist, ";"$AllPlayerList[i].Menu$";") == -1 && (Race=="" || (Caps(AllPlayerList[i].Species.default.SpeciesName)==Race)) )
			PlayerList[j++] = AllPlayerList[i];
	}

	ItemCount = j;
	Index = 0;
}


/** Populate list with Player team members */
function ResetList(array<xUtil.PlayerRecord> PlayerTeam, int numchars)
{
	local int i;

	if ( PlayerTeam.Length < numchars ) {
		Log("GUICharacterListTeam::ResetList() could not reset list; invalid team.");
		return;
	}

	for ( i=0; i < numchars; i++ ) {
		PlayerList[i] = PlayerTeam[i];
	}
	ItemCount = numchars;
}

/** populate the player list based on default player names */
function PopulateList(array<string> PlayerNames)
{
	local int i, j;
	local array<xUtil.PlayerRecord> PRlist;

	PlayerList.length = PlayerNames.length;
	class'xUtil'.static.GetPlayerList(PRlist);
	for (i = 0; i < PlayerNames.length; i++)
	{
		for (j = 0; j < PRlist.length; j++)
		{
			if (PlayerNames[i] ~= PRlist[j].DefaultName)
			{
				PlayerList[i] = PRlist[j];
				break;
			}
		}
	}
	ItemCount = PlayerNames.length;
}

defaultproperties
{
}
