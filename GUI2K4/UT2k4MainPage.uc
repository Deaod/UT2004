//====================================================================
//  Base class for all main menu pages.
//
//  Written by Ron Prestenback
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class UT2K4MainPage extends UT2K4GUIPage;

var automated GUITabControl     c_Tabs;

var automated GUIHeader         t_Header;
var automated ButtonFooter      t_Footer;
var automated BackgroundImage   i_Background;

var automated	GUIImage 	    i_bkChar, i_bkScan;

/** file where the higscores are stored */
var string HighScoreFile;
var private globalconfig string TotalUnlockedCharacters;

var array<string>               PanelClass;
var localized array<string>     PanelCaption;
var localized array<string>     PanelHint;



function InitComponent(GUIController MyC, GUIComponent MyO)
{
	Super.InitComponent(MyC, MyO);

	c_Tabs.MyFooter = t_Footer;
	t_Header.DockedTabs = c_Tabs;
}

function InternalOnChange(GUIComponent Sender);
/*
event Opened(GUIComponent Sender)
{
	Super.Opened(Sender);

	if ( bPersistent && c_Tabs != None && c_Tabs.FocusedControl == None )
		c_Tabs.SetFocus(None);
}
*/

function HandleParameters(string Param1, string Param2)
{
	if ( Param1 != "" )
	{
		if ( c_Tabs != none )
			c_Tabs.ActivateTabByName(Param1, True);
	}
}

function bool GetRestoreParams( out string Param1, out string Param2 )
{
	if ( c_Tabs != None && c_Tabs.ActiveTab != None )
	{
		Param1 = c_Tabs.ActiveTab.Caption;
		return True;
	}

	return False;
}

static function bool UnlockCharacter( string CharName )
{
	local int i;
	local array<string> Unlocked;

	if ( CharName == "" )
		return false;

	Split(default.TotalUnlockedCharacters, ";", Unlocked);
	for ( i = 0; i < Unlocked.Length; i++ )
		if ( Unlocked[i] ~= CharName )
			return false;

	Unlocked[Unlocked.Length] = CharName;

	default.TotalUnlockedCharacters = JoinArray(Unlocked, ";", True);
	StaticSaveConfig();
	return true;
}

// Caution: you must verify that the specified CharName is a locked character by default, before calling this function
static function bool IsUnlocked( string CharName )
{
	return CharName != "" && (InStr(";" $ Caps(default.TotalUnlockedCharacters) $ ";", ";" $ Caps(CharName) $ ";") != -1);
}

defaultproperties
{
     Begin Object Class=GUITabControl Name=PageTabs
         bDockPanels=True
         TabHeight=0.040000
         BackgroundStyleName="TabBackground"
         WinLeft=0.010000
         WinWidth=0.980000
         WinHeight=0.040000
         RenderWeight=0.490000
         TabOrder=3
         bAcceptsInput=True
         OnActivate=PageTabs.InternalOnActivate
         OnChange=UT2k4MainPage.InternalOnChange
     End Object
     c_Tabs=GUITabControl'GUI2K4.UT2k4MainPage.PageTabs'

     Begin Object Class=BackgroundImage Name=PageBackground
         Image=Texture'2K4Menus.BkRenders.Bgndtile'
         ImageStyle=ISTY_PartialScaled
         X1=0
         Y1=0
         X2=4
         Y2=768
         RenderWeight=0.010000
     End Object
     i_Background=BackgroundImage'GUI2K4.UT2k4MainPage.PageBackground'

     Begin Object Class=GUIImage Name=BkChar
         Image=Texture'2K4Menus.BkRenders.Char01'
         ImageStyle=ISTY_Scaled
         X1=0
         Y1=0
         X2=1024
         Y2=768
         WinHeight=1.000000
         RenderWeight=0.020000
     End Object
     i_bkChar=GUIImage'GUI2K4.UT2k4MainPage.BkChar'

     Begin Object Class=BackgroundImage Name=PageScanLine
         Image=Texture'2K4Menus.BkRenders.Scanlines'
         ImageColor=(A=32)
         ImageStyle=ISTY_Tiled
         ImageRenderStyle=MSTY_Alpha
         X1=0
         Y1=0
         X2=32
         Y2=32
         RenderWeight=0.030000
     End Object
     i_bkScan=BackgroundImage'GUI2K4.UT2k4MainPage.PageScanLine'

     HighScoreFile="UT2004HighScores"
     bPersistent=True
     bRestorable=True
     WinTop=0.000000
     WinHeight=1.000000
}
