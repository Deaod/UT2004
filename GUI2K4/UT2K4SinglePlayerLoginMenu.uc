//==============================================================================
// Midgame menu for ladder matches
//
// Written by Michiel Hendriks
// (c) 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4SinglePlayerLoginMenu extends UT2K4PlayerLoginMenu;

function AddPanels()
{
	Panels[0].ClassName = "GUI2K4.UT2K4Tab_SinglePlayerLoginControls";
	Super.AddPanels();
}

defaultproperties
{
}
