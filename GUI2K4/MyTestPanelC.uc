// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class MyTestPanelC extends TestPanelBase;

var Automated GUISplitter MainSplitter;

defaultproperties
{
     Begin Object Class=GUISplitter Name=Cone
         DefaultPanels(0)="GUI2K4.MySubTestPanelA"
         DefaultPanels(1)="GUI2K4.MySubTestPanelB"
         MaxPercentage=0.800000
         WinHeight=1.000000
     End Object
     MainSplitter=GUISplitter'GUI2K4.MyTestPanelC.Cone'

     Background=Texture'InterfaceContent.Backgrounds.bg11'
     WinTop=55.980499
     WinHeight=0.807813
}
