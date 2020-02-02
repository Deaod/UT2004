class UT2DeferChangeRes extends UT2K3GUIPage;

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
     Controls(0)=GUIButton'XInterface.UT2DeferChangeRes.DialogBackground'

     Begin Object Class=GUIButton Name=OkButton
         Caption="OK"
         WinTop=0.550000
         WinLeft=0.400000
         WinWidth=0.200000
         OnClick=UT2DeferChangeRes.InternalOnClick
         OnKeyEvent=OkButton.InternalOnKeyEvent
     End Object
     Controls(1)=GUIButton'XInterface.UT2DeferChangeRes.OkButton'

     Begin Object Class=GUILabel Name=DialogText
         Caption="The resolution you have chosen is lower than the minimum menu resolution."
         TextAlign=TXTA_Center
         TextColor=(B=0,G=180,R=220)
         WinTop=0.400000
         WinHeight=32.000000
     End Object
     Controls(2)=GUILabel'XInterface.UT2DeferChangeRes.DialogText'

     Begin Object Class=GUILabel Name=DialogText2
         Caption="It will be applied when you next enter gameplay."
         TextAlign=TXTA_Center
         TextColor=(B=0,G=180,R=220)
         WinTop=0.450000
         WinHeight=32.000000
     End Object
     Controls(3)=GUILabel'XInterface.UT2DeferChangeRes.DialogText2'

     WinTop=0.375000
     WinHeight=0.250000
}
