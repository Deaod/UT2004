// ====================================================================
// Tab for login/midgame menu that has all the important clickable controls
// This is the Invasion version (forces FFA mode even though Invasion is technically a team game)
//
// Written by Matt Oelfke
// (C) 2003, Epic Games, Inc. All Rights Reserved
// ====================================================================

class UT2K4Tab_PlayerLoginControlsInvasion extends UT2K4Tab_PlayerLoginControls;

function InitGRI()
{
	if ( !(GetGRI().GameClass == "Engine.GameInfo") )
	{
		bTeamGame = False;
		bFFAGame = True;
		Super.InitGRI();
	}
}

defaultproperties
{
}
