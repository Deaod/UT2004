//==============================================================================
//	Created on: 08/15/2003
//	Description
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UT2K4ServerInfo extends UT2K4GUIPage;

var automated GUIImage      i_Background;
var automated GUITabControl c_Tabs;
var automated GUITitleBar   t_Header;
var automated GUIFooter     t_Footer;
var automated GUIButton     b_Close;


var array<string>               PanelClass;
var localized array<string>     PanelCaption;
var localized array<string>     PanelHint;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;
    Super.InitComponent(MyController, MyOwner);

	if ( PlayerOwner() != None && PlayerOwner().GameReplicationInfo != None )
	    SetTitle();

    c_Tabs.MyFooter = t_Footer;
	for ( i = 0; i < PanelClass.Length && i < PanelCaption.Length && i < PanelHint.Length; i++ )
	    c_Tabs.AddTab(PanelCaption[i],PanelClass[i],,PanelHint[i]);
}

function bool ButtonClicked(GUIComponent Sender)
{
    Controller.CloseMenu(true);
    return true;
}

event ChangeHint(string NewHint)
{
    t_Footer.SetCaption(NewHint);
}

function SetTitle()
{
	t_Header.SetCaption(PlayerOwner().GameReplicationInfo.ServerName);
}

defaultproperties
{
     Begin Object Class=GUIImage Name=ServerInfoBackground
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageStyle=ISTY_Stretched
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     i_Background=GUIImage'GUI2K4.UT2K4ServerInfo.ServerInfoBackground'

     Begin Object Class=GUITabControl Name=ServerInfoTabs
         bFillSpace=True
         bDockPanels=True
         TabHeight=0.040000
         WinTop=0.100000
         WinHeight=0.060000
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=True
         OnActivate=ServerInfoTabs.InternalOnActivate
     End Object
     c_Tabs=GUITabControl'GUI2K4.UT2K4ServerInfo.ServerInfoTabs'

     Begin Object Class=GUITitleBar Name=ServerInfoHeader
         Effect=FinalBlend'InterfaceContent.Menu.CO_Final'
         StyleName="Header"
         WinHeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     t_Header=GUITitleBar'GUI2K4.UT2K4ServerInfo.ServerInfoHeader'

     Begin Object Class=GUIFooter Name=ServerInfoFooter
         WinTop=0.925000
         WinHeight=0.075000
     End Object
     t_Footer=GUIFooter'GUI2K4.UT2K4ServerInfo.ServerInfoFooter'

     Begin Object Class=GUIButton Name=ServerBackButton
         Caption="Close"
         Hint="Close this menu"
         WinTop=0.934167
         WinLeft=0.848750
         WinWidth=0.120000
         WinHeight=0.055000
         RenderWeight=0.510000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=UT2K4ServerInfo.ButtonClicked
         OnKeyEvent=ServerBackButton.InternalOnKeyEvent
     End Object
     b_Close=GUIButton'GUI2K4.UT2K4ServerInfo.ServerBackButton'

     PanelClass(0)="GUI2K4.UT2K4Tab_ServerMOTD"
     PanelClass(1)="GUI2K4.UT2K4Tab_ServerInfo"
     PanelClass(2)="GUI2K4.UT2K4Tab_ServerMapList"
     PanelCaption(0)="MOTD"
     PanelCaption(1)="Rules"
     PanelCaption(2)="Maps"
     PanelHint(0)="Message of the Day"
     PanelHint(1)="Game Rules"
     PanelHint(2)="Map Rotation"
     bAllowedAsLast=True
     WinTop=0.100000
     WinLeft=0.200000
     WinWidth=0.600000
     WinHeight=0.800000
}
