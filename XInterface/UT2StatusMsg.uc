// ====================================================================
//  Class:  XInterface.UT2StatusMsg
//  Parent: XInterface.GUIPage
//
//  <Enter a description here>
// ====================================================================

class UT2StatusMsg extends UT2K3GUIPage;


var bool bIgnoreEsc;

var		float ButtonWidth;
var		float ButtonHeight;
var		float ButtonHGap;
var		float ButtonVGap;
var		float BarHeight;
var		float BarVPos;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(Mycontroller, MyOwner);
	PlayerOwner().ClearProgressMessages();
}


function bool InternalOnClick(GUIComponent Sender)
{
	if(Sender==Controls[1]) // OK
	{	
		Controller.CloseMenu(false);
//		Controller.ReplaceMenu("xinterface.UT2MainMenu");
	}
	
	return true;
}

event HandleParameters(string Param1, string Param2)
{
	GUILabel(Controls[2]).Caption = Param1$"|"$Param2;
	PlayerOwner().ClearProgressMessages();
}

defaultproperties
{
     bIgnoreEsc=True
     bRequire640x480=False
     OpenSound=Sound'MenuSounds.selectDshort'
     Begin Object Class=GUIButton Name=NetStatBackground
         StyleName="SquareBar"
         WinTop=0.375000
         WinHeight=0.250000
         bAcceptsInput=False
         bNeverFocus=True
         OnKeyEvent=NetStatBackground.InternalOnKeyEvent
     End Object
     Controls(0)=GUIButton'XInterface.UT2StatusMsg.NetStatBackground'

     Begin Object Class=GUIButton Name=NetStatOk
         Caption="OK"
         StyleName="MidGameButton"
         WinTop=0.675000
         WinLeft=0.375000
         WinWidth=0.250000
         WinHeight=0.050000
         bBoundToParent=True
         OnClick=UT2StatusMsg.InternalOnClick
         OnKeyEvent=NetStatOk.InternalOnKeyEvent
     End Object
     Controls(1)=GUIButton'XInterface.UT2StatusMsg.NetStatOk'

     Begin Object Class=GUILabel Name=NetStatLabel
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2HeaderFont"
         bMultiLine=True
         WinTop=0.125000
         WinHeight=0.500000
         bBoundToParent=True
     End Object
     Controls(2)=GUILabel'XInterface.UT2StatusMsg.NetStatLabel'

     WinTop=0.375000
     WinHeight=0.250000
}
