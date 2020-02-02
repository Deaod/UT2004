class UT2BadCDKeyMsg extends UT2K3GUIPage;


var bool bIgnoreEsc;

var		localized string LeaveMPButtonText;
var		localized string LeaveSPButtonText;

var		float ButtonWidth;
var		float ButtonHeight;
var		float ButtonHGap;
var		float ButtonVGap;
var		float BarHeight;
var		float BarVPos;


function bool InternalOnClick(GUIComponent Sender)
{

	if(Sender==Controls[1]) // OK
	{
		Controller.ReplaceMenu("xinterface.UT2MainMenu");
	}
	
	return true;
}

defaultproperties
{
     bIgnoreEsc=True
     bRequire640x480=False
     OpenSound=Sound'MenuSounds.selectDshort'
     Begin Object Class=GUIButton Name=BadCDBackground
         StyleName="SquareBar"
         WinTop=0.375000
         WinHeight=0.250000
         bAcceptsInput=False
         bNeverFocus=True
         OnKeyEvent=BadCDBackground.InternalOnKeyEvent
     End Object
     Controls(0)=GUIButton'XInterface.UT2BadCDKeyMsg.BadCDBackground'

     Begin Object Class=GUIButton Name=BadCDOk
         Caption="OK"
         StyleName="MidGameButton"
         WinTop=0.675000
         WinLeft=0.375000
         WinWidth=0.250000
         WinHeight=0.050000
         bBoundToParent=True
         OnClick=UT2BadCDKeyMsg.InternalOnClick
         OnKeyEvent=BadCDOk.InternalOnKeyEvent
     End Object
     Controls(1)=GUIButton'XInterface.UT2BadCDKeyMsg.BadCDOk'

     Begin Object Class=GUILabel Name=BadCDLabel
         Caption="Your CD key is invalid or in use by another player"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2HeaderFont"
         bMultiLine=True
         WinTop=0.125000
         WinHeight=0.500000
         bBoundToParent=True
     End Object
     Controls(2)=GUILabel'XInterface.UT2BadCDKeyMsg.BadCDLabel'

     WinTop=0.375000
     WinHeight=0.250000
}
