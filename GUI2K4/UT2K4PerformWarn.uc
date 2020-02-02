// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class UT2K4PerformWarn extends UT2K4GenericMessageBox;

var automated moCheckbox ch_NeverShowAgain;

function HandleParameters( string Param1, string Param2 )
{
	local float f;

	f = float(Param1);
	if ( f != 0.0 )
		SetTimer(f);
}

function Timer()
{
	Controller.CloseMenu(false);
}

function bool InternalOnClick(GUIComponent Sender)
{
	Controller.CloseMenu(false);
	return true;
}

function CheckBoxClick(GUIComponent Sender)
{
	class'Settings_Tabs'.default.bExpert = ch_NeverShowAgain.IsChecked();
	class'Settings_Tabs'.static.StaticSaveConfig();
}

function InternalOnLoadIni( GUIComponent Sender, string Value )
{
	ch_NeverShowAgain.Checked(class'Settings_Tabs'.default.bExpert);
}

defaultproperties
{
     Begin Object Class=moCheckBox Name=HideCheckbox
         bFlipped=True
         ComponentJustification=TXTA_Left
         CaptionWidth=0.930000
         ComponentWidth=0.070000
         Caption="  do not display this warning again"
         OnCreateComponent=HideCheckbox.InternalOnCreateComponent
         FontScale=FNS_Small
         IniOption="@Internal"
         Hint="Check this to disable showing warning messages when adjusting properties in the Settings menu"
         WinTop=0.499479
         WinLeft=0.312500
         WinWidth=0.370000
         TabOrder=1
         OnChange=UT2K4PerformWarn.CheckBoxClick
         OnLoadINI=UT2K4PerformWarn.InternalOnLoadINI
     End Object
     ch_NeverShowAgain=moCheckBox'GUI2K4.UT2K4PerformWarn.HideCheckbox'

     Begin Object Class=GUIButton Name=OkButton
         Caption="OK"
         WinTop=0.550000
         WinLeft=0.439063
         WinWidth=0.121875
         TabOrder=0
         OnClick=UT2K4PerformWarn.InternalOnClick
         OnKeyEvent=OkButton.InternalOnKeyEvent
     End Object
     b_OK=GUIButton'GUI2K4.UT2K4PerformWarn.OkButton'

     Begin Object Class=GUILabel Name=DialogText
         Caption="WARNING"
         TextAlign=TXTA_Center
         FontScale=FNS_Large
         StyleName="TextLabel"
         WinTop=0.400000
         WinHeight=0.040000
     End Object
     l_Text=GUILabel'GUI2K4.UT2K4PerformWarn.DialogText'

     Begin Object Class=GUILabel Name=DialogText2
         Caption="The change you are making may adversely affect your performance."
         TextAlign=TXTA_Center
         StyleName="TextLabel"
         WinTop=0.450000
         WinHeight=0.040000
     End Object
     l_Text2=GUILabel'GUI2K4.UT2K4PerformWarn.DialogText2'

     OpenSound=Sound'MenuSounds.selectDshort'
}
