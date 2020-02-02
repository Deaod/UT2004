// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class MyTestPage extends TestPageBase;

#exec OBJ LOAD FILE=InterfaceContent.utx

var Automated GUIHeader TabHeader;
var Automated GUITabControl TabC;
var Automated GUITitleBar TabFooter;
var Automated GUIButton BackButton;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{

	Super.Initcomponent(MyController, MyOwner);

	TabHeader.DockedTabs = TabC;
    TabC.AddTab("Component Test","GUI2K4.MyTestPanelA",,"Test of many non-list components");
    TabC.AddTab("List Tests","GUI2K4.MyTestPanelB",,"Test of list components");
    TabC.AddTab("Splitter","GUI2K4.MyTestPanelC",,"Test of the Splitter component");

}

function TabChange(GUIComponent Sender)
{
	if (GUITabButton(Sender)==none)
		return;

	TabHeader.SetCaption("Testing : "$GUITabButton(Sender).Caption);
}

event ChangeHint(string NewHint)
{
	TabFooter.SetCaption(NewHint);
}


function bool ButtonClicked(GUIComponent Sender)
{
	local CacheManager.MapRecord Record;

	Record = class'CacheManager'.static.getMapRecord("CTF-Maul");
	return true;
}

event bool NotifyLevelChange()
{
	Controller.CloseMenu(true);
	return Super.NotifyLevelChange();
}

defaultproperties
{
     Begin Object Class=GUIHeader Name=MyHeader
         Effect=FinalBlend'InterfaceContent.Menu.CO_Final'
         Caption="Settings"
         WinTop=0.005414
         WinHeight=36.000000
     End Object
     TabHeader=GUIHeader'GUI2K4.MyTestPage.MyHeader'

     Begin Object Class=GUITabControl Name=MyTabs
         bDockPanels=True
         TabHeight=0.040000
         WinTop=0.250000
         WinHeight=48.000000
         bAcceptsInput=True
         OnActivate=MyTabs.InternalOnActivate
         OnChange=MyTestPage.TabChange
     End Object
     TabC=GUITabControl'GUI2K4.MyTestPage.MyTabs'

     Begin Object Class=GUITitleBar Name=MyFooter
         bUseTextHeight=False
         StyleName="Footer"
         WinTop=0.942397
         WinLeft=0.120000
         WinWidth=0.880000
         WinHeight=0.055000
     End Object
     TabFooter=GUITitleBar'GUI2K4.MyTestPage.MyFooter'

     Begin Object Class=GUIButton Name=MyBackButton
         Caption="BACK"
         StyleName="SquareMenuButton"
         Hint="Return to Previous Menu"
         WinTop=0.942397
         WinWidth=0.120000
         WinHeight=0.055000
         OnClick=MyTestPage.ButtonClicked
         OnKeyEvent=MyBackButton.InternalOnKeyEvent
     End Object
     BackButton=GUIButton'GUI2K4.MyTestPage.MyBackButton'

     Background=Texture'InterfaceContent.Backgrounds.bg11'
     WinHeight=1.000000
}
