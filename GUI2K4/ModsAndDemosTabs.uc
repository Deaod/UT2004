// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class ModsAndDemosTabs extends UT2K4TabPanel
	abstract;

var UT2K4ModsAndDemos MyPage;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	super.InitComponent(MyController,MyOwner);
	MyPage = UT2K4ModsAndDemos(MyOwner.MenuOwner);
}

function ShowPanel(bool bShow)
{
	if (bShow)
		MyPage.MyFooter.TabChange(Tag);

	super.ShowPanel(bShow);
}

defaultproperties
{
}
