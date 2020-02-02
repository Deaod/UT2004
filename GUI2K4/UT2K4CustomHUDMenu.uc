//==============================================================================
//	Created on: 09/22/2003
//	Base class for all custom HUD settings menus
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UT2K4CustomHUDMenu extends LargeWindow
	abstract;

var class<GameInfo> GameClass;
var automated GUIButton b_Cancel, b_Reset, b_OK;

function HandleParameters( string GameClassName, string nothing )
{
	Super.HandleParameters(GameClassName, nothing);
	if ( InitializeGameClass(GameClassName) )
		LoadSettings();
}

function bool InitializeGameClass( string GameClassName );

event Closed( GUIComponent Sender, bool bCancelled )
{
	Super.Closed(Sender, bCancelled);

	if ( bCancelled )
		return;

	SaveSettings();
}

function bool InternalOnClick( GUIComponent Sender )
{
	if ( Sender == b_Reset )
		RestoreDefaults();
	else if ( GUIButton(Sender) != None )
		Controller.CloseMenu( GUIButton(Sender) == b_Cancel );

	return true;
}

function InternalOnChange(GUIComponent Sender);
function LoadSettings();
function SaveSettings();
function RestoreDefaults()
{
	LoadSettings();
}

defaultproperties
{
     DefaultLeft=0.125000
     DefaultTop=0.150000
     DefaultWidth=0.598398
     DefaultHeight=0.700000
     WinTop=0.150000
     WinLeft=0.125000
     WinWidth=0.598398
     WinHeight=0.700000
}
