//==============================================================================
//	Created on: 08/15/2003
//	Menu that appears when user has invalid CD-key or CD-key is already used.
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UT2K4BadCDKeyMsg extends BlackoutWindow;

var automated GUIButton b_OK;
var automated GUILabel l_Title;

function bool InternalOnClick(GUIComponent Sender)
{
	if ( Sender == b_OK ) // OK
		Controller.ReplaceMenu(class'GameEngine'.default.MainMenuClass);

	return true;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	if ( State == 3 && (Key == 0x0D || Key == 0x0B) )	// Enter / Escape
		return InternalOnClick(b_OK);

	return false;
}

defaultproperties
{
     Begin Object Class=GUIButton Name=OkButton
         Caption="OK"
         WinTop=0.550000
         WinLeft=0.400000
         WinWidth=0.200000
         OnClick=UT2K4BadCDKeyMsg.InternalOnClick
         OnKeyEvent=OkButton.InternalOnKeyEvent
     End Object
     b_OK=GUIButton'GUI2K4.UT2K4BadCDKeyMsg.OkButton'

     Begin Object Class=GUILabel Name=BadCDLabel
         Caption="Your CD key is invalid or in use by another player"
         TextAlign=TXTA_Center
         bMultiLine=True
         FontScale=FNS_Large
         StyleName="TextLabel"
         WinTop=0.383333
         WinHeight=0.231250
         bBoundToParent=True
     End Object
     l_Title=GUILabel'GUI2K4.UT2K4BadCDKeyMsg.BadCDLabel'

     OnKeyEvent=UT2K4BadCDKeyMsg.InternalOnKeyEvent
}
