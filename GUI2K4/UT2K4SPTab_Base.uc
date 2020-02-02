//==============================================================================
// Base component for all single player tabs
// Mostly based upon the original Tab_SPPanelBase
//
// Written by Michiel Hendriks
// (c) 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4SPTab_Base extends UT2K4TabPanel abstract;

var localized string CaptionPlay, CaptionLoad, CaptionCreate, CaptionDone,
						CaptionCancel, CaptionBack;

var UT2K4GameProfile GP;
var UT2K4SP_Main MainWindow;
var name LogPrefix;
var class<UT2K4GameProfile> ProfileClass;

function InitComponent(GUIController pMyController, GUIComponent MyOwner)
{
	Super.Initcomponent(pMyController, MyOwner);
	GP = UT2K4GameProfile(PlayerOwner().Level.Game.CurrentGameProfile);
	if (GP != none) LogPrefix = GP.LogPrefix;
	GetMainWindow();
}

/** make sure the main window is set */
function ShowPanel(bool bShow)
{
	GetMainWindow();
	Super.ShowPanel(bShow);
	if (bShow)
	{
		MainWindow.btnPlay.Caption = CaptionPlay;
		MainWindow.btnBack.Caption = CaptionBack;
	}
}

/** get the main window */
function GetMainWindow()
{
	if (MainWindow != none) return;
	if (UT2K4SP_Main(Controller.ActivePage) != None)
	{
		MainWindow = UT2K4SP_Main(Controller.ActivePage);
		return;
	}
	else {/*
		for (i = Controller.MenuStack.length-1; i>=0; i--)
		{
			if (UT2K4SP_Main(Controller.MenuStack[i]) != None)
			{
				MainWindow = UT2K4SP_Main(Controller.MenuStack[i]);
				return;
			}
		}
		*/
		MainWindow = UT2K4SP_Main(Controller.FindMenuByClass(class'UT2K4SP_Main'));
		if ( MainWindow != None )
			return;
	}
	Warn("MainWindow not found");
}

/**
	Will be called when the "play" button on the main page is clicked
*/
function bool onPlayClick()
{
	return false;
}

/**
	Enable/disable the play button
*/
function btnPlayEnabled(bool bEnabled)
{
	GetMainWindow();
	if (!bEnabled) MainWindow.btnPlay.DisableMe();
		else MainWindow.btnPlay.EnableMe();
}

/**
	Will be called when the "back" button on the main page is clicked
	return false for the default behavior (close main menu)
*/
function bool onBackClick()
{
	return false;
}

/**
	will be called on each open tab when the main window get's a close request
*/
function bool CanClose(optional Bool bCancelled)
{
	return true;
}

/**
	Return the actual profile name, without the prefix
*/
function string getProfileName(coerce string profilename)
{
	GetMainWindow();
	return Mid(profilename, Len(MainWindow.ProfilePrefix));
}

defaultproperties
{
     CaptionPlay="PLAY"
     CaptionLoad="LOAD"
     CaptionCreate="CREATE"
     CaptionDone="DONE"
     CaptionCancel="CANCEL"
     CaptionBack="BACK"
     LogPrefix="SinglePlayer"
     profileclass=Class'XGame.UT2K4GameProfile'
     FadeInTime=0.250000
     WinTop=0.150000
     WinHeight=0.720000
}
