// ====================================================================
//  Class:  XInterface.UT2QuitPage
//  Parent: XInterface.GUIMultiComponent
//
//  <Enter a description here>
// ====================================================================

class UT2QuitPage extends UT2K3GUIPage;


function bool InternalOnClick(GUIComponent Sender)
{
	if (Sender==Controls[1])
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

defaultproperties
{
     bRequire640x480=False
     Begin Object Class=GUIButton Name=QuitBackground
         StyleName="SquareBar"
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=False
         bNeverFocus=True
         OnKeyEvent=QuitBackground.InternalOnKeyEvent
     End Object
     Controls(0)=GUIButton'XInterface.UT2QuitPage.QuitBackground'

     Begin Object Class=GUIButton Name=YesButton
         Caption="YES"
         WinTop=0.750000
         WinLeft=0.125000
         WinWidth=0.200000
         bBoundToParent=True
         OnClick=UT2QuitPage.InternalOnClick
         OnKeyEvent=YesButton.InternalOnKeyEvent
     End Object
     Controls(1)=GUIButton'XInterface.UT2QuitPage.YesButton'

     Begin Object Class=GUIButton Name=NoButton
         Caption="NO"
         WinTop=0.750000
         WinLeft=0.650000
         WinWidth=0.200000
         bBoundToParent=True
         OnClick=UT2QuitPage.InternalOnClick
         OnKeyEvent=NoButton.InternalOnKeyEvent
     End Object
     Controls(2)=GUIButton'XInterface.UT2QuitPage.NoButton'

     Begin Object Class=GUILabel Name=QuitDesc
         Caption="Are you sure you wish to quit?"
         TextAlign=TXTA_Center
         TextColor=(B=0,G=180,R=220)
         TextFont="UT2HeaderFont"
         WinTop=0.400000
         WinHeight=32.000000
     End Object
     Controls(3)=GUILabel'XInterface.UT2QuitPage.QuitDesc'

     WinTop=0.375000
     WinHeight=0.250000
}
