// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class UT2AdminMenu extends UT2K3GUIPage;

var GUITabControl TabC;
var Tab_AdminPlayerList PlayerList;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
 	Super.InitComponent(MyController, MyOwner);

    TabC = GUITabControl(Controls[5]);
	PlayerList = Tab_AdminPlayerList(TabC.AddTab("Players","xinterface.Tab_AdminPlayerList",,"Player Mgt.",true));

	if (PlayerList!=None)
    	PlayerList.ReloadList();

}

function HandleParameters(string Param1, string Param2)
{
	PlayerList.bAdvancedAdmin = bool(Param1);
}

function bool ButtonClicked(GUIComponent Sender)
{
	Controller.CloseMenu(true);
    return true;
}
/*
event ChangeHint(string NewHint)
{
	GUITitleBar(Controls[3]).Caption = NewHint;
}
*/

defaultproperties
{
     bRequire640x480=False
     bAllowedAsLast=True
     Begin Object Class=GUIImage Name=AdminInfoBackground
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageStyle=ISTY_Stretched
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     Controls(0)=GUIImage'XInterface.UT2AdminMenu.AdminInfoBackground'

     Begin Object Class=GUIImage Name=AdminInfoBackground2
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageStyle=ISTY_Stretched
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     Controls(1)=GUIImage'XInterface.UT2AdminMenu.AdminInfoBackground2'

     Begin Object Class=GUITitleBar Name=AdminInfoHeader
         Effect=FinalBlend'InterfaceContent.Menu.CO_Final'
         Caption="Admin In-Game Menu"
         StyleName="Header"
         WinHeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(2)=GUITitleBar'XInterface.UT2AdminMenu.AdminInfoHeader'

     Begin Object Class=GUITitleBar Name=AdminInfoFooter
         bUseTextHeight=False
         StyleName="Footer"
         WinTop=0.925000
         WinHeight=0.075000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(3)=GUITitleBar'XInterface.UT2AdminMenu.AdminInfoFooter'

     Begin Object Class=GUIButton Name=AdminBackButton
         Caption="Close"
         StyleName="SquareMenuButton"
         Hint="Close this menu"
         WinTop=0.934167
         WinLeft=0.868750
         WinWidth=0.120000
         WinHeight=0.055000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=UT2AdminMenu.ButtonClicked
         OnKeyEvent=AdminBackButton.InternalOnKeyEvent
     End Object
     Controls(4)=GUIButton'XInterface.UT2AdminMenu.AdminBackButton'

     Begin Object Class=GUITabControl Name=AdminInfoTabs
         bDockPanels=True
         TabHeight=0.040000
         WinTop=0.100000
         WinHeight=0.060000
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=True
         OnActivate=AdminInfoTabs.InternalOnActivate
     End Object
     Controls(5)=GUITabControl'XInterface.UT2AdminMenu.AdminInfoTabs'

     WinTop=0.100000
     WinLeft=0.020000
     WinWidth=0.960000
     WinHeight=0.800000
}
