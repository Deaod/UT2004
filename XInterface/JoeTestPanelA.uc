// ====================================================================
//  Class:  XInterface.JoeTestPanelA
//  Parent: XInterface.GUITabPanel
//
//  <Enter a description here>
// ====================================================================

class JoeTestPanelA extends TestPanelBase;

function InitPanel()
{
}

defaultproperties
{
     Background=Texture'InterfaceContent.Backgrounds.bg10'
     Begin Object Class=GUIButton Name=TestButtonA
         Caption="Wow"
         WinTop=0.250000
         WinLeft=0.250000
         WinWidth=0.500000
         WinHeight=48.000000
         OnKeyEvent=TestButtonA.InternalOnKeyEvent
     End Object
     Controls(0)=GUIButton'XInterface.JoeTestPanelA.TestButtonA'

     Begin Object Class=GUIButton Name=TestButtonB
         Caption="Damn"
         WinTop=0.550000
         WinLeft=0.250000
         WinWidth=0.500000
         WinHeight=48.000000
         OnKeyEvent=TestButtonB.InternalOnKeyEvent
     End Object
     Controls(1)=GUIButton'XInterface.JoeTestPanelA.TestButtonB'

     WinTop=0.650000
     WinHeight=0.300000
}
