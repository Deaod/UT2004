//==============================================================================
//	Confirmation page for quitting the game.  Brings the user to an advertisement
//  page if this is the demo version of the game.
//
//	Created by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================

class UT2K4QuitPage extends BlackoutWindow;

var automated GUIButton YesButton;
var automated GUIButton NoButton;
var automated GUILabel 	QuitDesc;

function bool InternalOnClick(GUIComponent Sender)
{
	if (Sender==YesButton)
	{
		if(PlayerOwner().Level.IsDemoBuild())
			Controller.ReplaceMenu("XInterface.UT2DemoQuitPage");
		else
			PlayerOwner().ConsoleCommand("exit");
	}
	else
		Controller.CloseMenu(false);

	return true;
}

function bool InternalOnKeyEvent( out byte Key, out byte State, float Delta )
{
	if ( State == 3 )
	{
		if ( Key == 0x0B ) // Cancel
			InternalOnClick(NoButton);

		else if ( Key == 0x0D )
			InternalOnClick(YesButton);
	}

	return false;
}

defaultproperties
{
     Begin Object Class=GUIButton Name=cYesButton
         Caption="YES"
         WinTop=0.515625
         WinLeft=0.164063
         WinWidth=0.200000
         TabOrder=0
         OnClick=UT2K4QuitPage.InternalOnClick
         OnKeyEvent=cYesButton.InternalOnKeyEvent
     End Object
     YesButton=GUIButton'GUI2K4.UT2K4QuitPage.cYesButton'

     Begin Object Class=GUIButton Name=cNoButton
         Caption="NO"
         WinTop=0.515625
         WinLeft=0.610937
         WinWidth=0.200000
         TabOrder=1
         OnClick=UT2K4QuitPage.InternalOnClick
         OnKeyEvent=cNoButton.InternalOnKeyEvent
     End Object
     NoButton=GUIButton'GUI2K4.UT2K4QuitPage.cNoButton'

     Begin Object Class=GUILabel Name=cQuitDesc
         Caption="Are you sure you wish to quit?"
         TextAlign=TXTA_Center
         TextColor=(B=244,G=237,R=253)
         TextFont="UT2HeaderFont"
         WinTop=0.426042
         WinHeight=32.000000
         RenderWeight=4.000000
     End Object
     QuitDesc=GUILabel'GUI2K4.UT2K4QuitPage.cQuitDesc'

     OnKeyEvent=UT2K4QuitPage.InternalOnKeyEvent
}
