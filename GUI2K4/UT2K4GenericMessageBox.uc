// ====================================================================
// Generic message box. For any dialog box that has nothing but a caption,
// message, and OK button.
//
// Written by Matt Oelfke
// (C) 2003, Epic Games
// ====================================================================

class UT2K4GenericMessageBox extends MessageWindow;

var automated GUIButton b_OK;
var automated GUILabel  l_Text, l_Text2;

function bool InternalOnClick(GUIComponent Sender)
{
	Controller.CloseMenu(false);
	return true;
}

function HandleParameters(string Param1, string Param2)
{
	if ( Param1 != "" )
		l_Text.Caption = Param1;

	if ( Param2 != "" )
		l_Text2.Caption = Param2;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	if ( Key == 0x0D && State == 3 )	// Enter
		return InternalOnClick(b_OK);

	return false;
}

defaultproperties
{
     Begin Object Class=GUIButton Name=OkButton
         Caption="OK"
         WinTop=0.549479
         WinLeft=0.400000
         WinWidth=0.200000
         OnClick=UT2K4GenericMessageBox.InternalOnClick
         OnKeyEvent=OkButton.InternalOnKeyEvent
     End Object
     b_OK=GUIButton'GUI2K4.UT2K4GenericMessageBox.OkButton'

     Begin Object Class=GUILabel Name=DialogText
         Caption="WARNING"
         TextAlign=TXTA_Center
         VertAlign=TXTA_Center
         FontScale=FNS_Large
         StyleName="TextButton"
         WinTop=0.389843
         WinLeft=0.056771
         WinWidth=0.884722
         WinHeight=0.042149
     End Object
     l_Text=GUILabel'GUI2K4.UT2K4GenericMessageBox.DialogText'

     Begin Object Class=GUILabel Name=DialogText2
         TextAlign=TXTA_Center
         bMultiLine=True
         StyleName="TextLabel"
         WinTop=0.431249
         WinLeft=0.043750
         WinWidth=0.912500
         WinHeight=0.126524
     End Object
     l_Text2=GUILabel'GUI2K4.UT2K4GenericMessageBox.DialogText2'

     OnKeyEvent=UT2K4GenericMessageBox.InternalOnKeyEvent
}
