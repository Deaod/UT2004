//====================================================================
//  Parent: GUIPage
//   Class: XInterface.UT2K4MainPage
//    Date: 04-28-2003
//
//  Base class for all main menu pages.
//
//  Written by Ron Prestenback
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class UT2MainPage extends UT2K3GUIPage;

var automated GUITabControl 	c_Tabs;

var automated GUIHeader			t_Header;
var automated GUIFooter			t_Footer;

var array<string>				PanelClass;
var localized array<string>		PanelCaption;
var localized array<string>		PanelHint;

function InitComponent(GUIController MyC, GUIComponent MyO)
{
	Super.InitComponent(MyC, MyO);

	c_Tabs.OnChange = InternalOnChange;
	t_Header.DockedTabs = c_Tabs;
}

function InternalOnChange(GUIComponent Sender);

defaultproperties
{
     Begin Object Class=GUITabControl Name=PageTabs
         bDockPanels=True
         TabHeight=0.040000
         WinTop=0.250000
         WinHeight=48.000000
         bAcceptsInput=True
         OnActivate=PageTabs.InternalOnActivate
         OnChange=UT2MainPage.InternalOnChange
     End Object
     c_Tabs=GUITabControl'XInterface.UT2MainPage.PageTabs'

     Background=Texture'InterfaceContent.Backgrounds.bg10'
}
