class Tab_SPPanelBase extends UT2K3TabPanel;

function OnProfileUpdated();
function OnMatchUpdated(int iLadder, int iMatch);

function GameProfile GetProfile()
{
	return PlayerOwner().Level.Game.CurrentGameProfile;
}

function GUITabControl MyTabControl()
{
	if (MyButton != None && MyButton.MenuOwner != None)
		return GUITabControl(MyButton.MenuOwner);

	if ( MenuOwner != None && MenuOwner.IsA('GUITabControl') )  // in case button hasn't been set up yet
		return GUITabControl(MenuOwner);

	return None;
}

// Report to every page that the profile was updated.
function ProfileUpdated()
{
local GUITabControl TC;
local int i;

	TC = MyTabControl();
	if (TC != None)
	{
		for (i = 0; i<TC.Controls.Length; i++)
			if (Tab_SPPanelBase(TC.Controls[i]) != None)
				Tab_SPPanelBase(TC.Controls[i]).OnProfileUpdated();
	}

	UT2SinglePlayerMain(MyTabControl().MenuOwner).ProfileUpdated();
}

// Report to every page that a new match was selected.
function MatchUpdated(int iLadder, int iMatch)
{
local GUITabControl TC;
local int i;

	TC = MyTabControl();
	if (TC != None)
	{
		for (i = 0; i<TC.Controls.Length; i++)
			if (Tab_SPPanelBase(TC.Controls[i]) != None)
				Tab_SPPanelBase(TC.Controls[i]).OnMatchUpdated(iLadder, iMatch);
	}
}

defaultproperties
{
}
