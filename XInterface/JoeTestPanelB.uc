// ====================================================================
//  Class:  XInterface.JoeTestPanelA
//  Parent: XInterface.GUITabPanel
//
//  <Enter a description here>
// ====================================================================

class JoeTestPanelB extends TestPanelBase;

function InitPanel()
{
}

defaultproperties
{
     Background=Texture'InterfaceContent.Backgrounds.bg09'
     Begin Object Class=GUIEditBox Name=TestEditB
         TextStr="DAMN HOT"
         WinTop=0.500000
         WinLeft=0.100000
         WinWidth=0.800000
         WinHeight=48.000000
         OnActivate=TestEditB.InternalActivate
         OnDeActivate=TestEditB.InternalDeactivate
         OnKeyType=TestEditB.InternalOnKeyType
         OnKeyEvent=TestEditB.InternalOnKeyEvent
     End Object
     Controls(0)=GUIEditBox'XInterface.JoeTestPanelB.TestEditB'

     WinTop=0.600000
     WinHeight=0.400000
}
