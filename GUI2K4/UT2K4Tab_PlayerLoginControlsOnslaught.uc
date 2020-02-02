// ====================================================================
// Tab for login/midgame menu that has all the important clickable controls
// This is the Onslaught version (has changes to work with Onslaught map tab)
//
// Written by Matt Oelfke
// (C) 2003, Epic Games, Inc. All Rights Reserved
// ====================================================================

class UT2K4Tab_PlayerLoginControlsOnslaught extends UT2K4Tab_PlayerLoginControls;

function bool ButtonClicked(GUIComponent Sender)
{
	local PlayerController PC;

	PC = PlayerOwner();
	if ( GUITabControl(MenuOwner) != None && GUITabControl(MenuOwner).TabStack.Length > 0 &&
		GUITabControl(MenuOwner).TabStack[0] != None && GUITabControl(MenuOwner).TabStack[0].MyPanel != None )
	{
		if (Sender == i_JoinRed)
		{
			//hack to avoid bug where map is shown twice on listen/standalone games due to the game
			//being paused while in the menus
			if (PC.Level.NetMode != NM_Client && ONSPlayerReplicationInfo(PC.PlayerReplicationInfo) != None)
				ONSPlayerReplicationInfo(PC.PlayerReplicationInfo).ShowMapOnDeath = MAP_Never;

			//Join Red team
			if ( PC != None && (PC.PlayerReplicationInfo == None || PC.PlayerReplicationInfo.Team == None
			     || PC.PlayerReplicationInfo.Team.TeamIndex != 0) )
				PC.ChangeTeam(0);
			GUITabControl(MenuOwner).ActivateTab(GUITabControl(MenuOwner).TabStack[0], true);

			if (PC.Level.NetMode != NM_Client && ONSPlayerReplicationInfo(PC.PlayerReplicationInfo) != None)
				ONSPlayerReplicationInfo(PC.PlayerReplicationInfo).ShowMapOnDeath = ONSPlayerReplicationInfo(PC.PlayerReplicationInfo).default.ShowMapOnDeath;
		}
		else if (Sender == i_JoinBlue)
		{
			//hack to avoid bug where map is shown twice on listen/standalone games due to the game
			//being paused while in the menus
			if (PC.Level.NetMode != NM_Client && ONSPlayerReplicationInfo(PC.PlayerReplicationInfo) != None)
				ONSPlayerReplicationInfo(PC.PlayerReplicationInfo).ShowMapOnDeath = MAP_Never;

			//Join Blue team
			if ( PC != None && (PC.PlayerReplicationInfo == None || PC.PlayerReplicationInfo.Team == None
			     || PC.PlayerReplicationInfo.Team.TeamIndex != 1) )
				PC.ChangeTeam(1);
			GUITabControl(MenuOwner).ActivateTab(GUITabControl(MenuOwner).TabStack[0], true);

			if (PC.Level.NetMode != NM_Client && ONSPlayerReplicationInfo(PC.PlayerReplicationInfo) != None)
				ONSPlayerReplicationInfo(PC.PlayerReplicationInfo).ShowMapOnDeath = ONSPlayerReplicationInfo(PC.PlayerReplicationInfo).default.ShowMapOnDeath;
		}
		else
			return Super.ButtonClicked(Sender);
	}
	else
		return false;

	return true;
}

defaultproperties
{
}
