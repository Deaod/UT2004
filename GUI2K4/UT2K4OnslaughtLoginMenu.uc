//==============================================================================
//	Created on: 08/13/2003
//	Onslaught specific implementation of login menu
//
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UT2K4OnslaughtLoginMenu extends UT2K4PlayerLoginMenu;

var() GUITabItem OnslaughtMapPanel;

function AddPanels()
{
	Panels.Insert(0,1);
	Panels[0] = OnslaughtMapPanel;
	Panels[1].ClassName = "GUI2K4.UT2K4Tab_PlayerLoginControlsOnslaught";

	Super.AddPanels();
}

function HandleParameters(string Param1, string Param2)
{
	if (PlayerOwner().IsInState('PlayerWaiting') || PlayerOwner().IsDead())
	{
		c_Main.ActivateTabByName(OnslaughtMapPanel.Caption, True);
		return;
	}

	if (Param1 ~= "TL")
	{
		c_Main.ActivateTabByName(OnslaughtMapPanel.Caption, True);
		UT2K4Tab_OnslaughtMap(c_Main.ActiveTab.MyPanel).NodeTeleporting();
		return;
	}

	c_Main.ActivateTabByName(Panels[1].Caption, true);
}

defaultproperties
{
     OnslaughtMapPanel=(ClassName="GUI2K4.UT2K4Tab_OnslaughtMap",Caption="Map",Hint="Map of the area")
}
