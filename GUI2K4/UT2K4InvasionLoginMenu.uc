//==============================================================================
//	Created on: 9/6/2003
//	Invasion specific implementation of login menu
//
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================

class UT2K4InvasionLoginMenu extends UT2K4PlayerLoginMenu;

function AddPanels()
{
	Panels[0].ClassName = "GUI2K4.UT2K4Tab_PlayerLoginControlsInvasion";
	Super.AddPanels();
}

defaultproperties
{
}
