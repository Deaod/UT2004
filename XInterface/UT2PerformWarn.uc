class UT2PerformWarn extends UT2K3GUIPage;

function bool InternalOnClick(GUIComponent Sender)
{
	Controller.CloseMenu(false);
	return true;
}

defaultproperties
{
     bRequire640x480=False
     Begin Object Class=GUIButton Name=DialogBackground
         StyleName="ListBox"
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=False
         bNeverFocus=True
         OnKeyEvent=DialogBackground.InternalOnKeyEvent
     End Object
     Controls(0)=GUIButton'XInterface.UT2PerformWarn.DialogBackground'

     Begin Object Class=GUIButton Name=OkButton
         Caption="OK"
         WinTop=0.550000
         WinLeft=0.400000
         WinWidth=0.200000
         OnClick=UT2PerformWarn.InternalOnClick
         OnKeyEvent=OkButton.InternalOnKeyEvent
     End Object
     Controls(1)=GUIButton'XInterface.UT2PerformWarn.OkButton'

     Begin Object Class=GUILabel Name=DialogText
         Caption="WARNING"
         TextAlign=TXTA_Center
         TextColor=(B=106,G=41,R=14)
         TextFont="UT2HeaderFont"
         WinTop=0.400000
         WinHeight=32.000000
     End Object
     Controls(2)=GUILabel'XInterface.UT2PerformWarn.DialogText'

     Begin Object Class=GUILabel Name=DialogText2
         Caption="The change you are making may adversely affect your performance."
         TextAlign=TXTA_Center
         TextColor=(B=106,G=41,R=14)
         WinTop=0.450000
         WinHeight=32.000000
     End Object
     Controls(3)=GUILabel'XInterface.UT2PerformWarn.DialogText2'

     WinTop=0.375000
     WinHeight=0.250000
}
