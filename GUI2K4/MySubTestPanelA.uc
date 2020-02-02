// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class MySubTestPanelA extends TestPanelBase;

var Automated GUIMultiColumnListBox MultiColumnListBoxTest;

defaultproperties
{
     Begin Object Class=GUIMultiColumnListBox Name=Cone
         DefaultListClass="GUI2K4.MyTestMultiColumnList"
         bVisibleWhenEmpty=True
         OnCreateComponent=Cone.InternalOnCreateComponent
         WinHeight=1.000000
         Begin Object Class=GUIContextMenu Name=cTestMenu
             ContextItems(0)="Test 0"
             ContextItems(1)="Test 1"
             ContextItems(2)="Fuck YOU"
             ContextItems(3)="ABCDEFGHIJKLM"
             ContextItems(4)="NOPQR"
         End Object
         ContextMenu=GUIContextMenu'GUI2K4.MySubTestPanelA.cTestMenu'

     End Object
     MultiColumnListBoxTest=GUIMultiColumnListBox'GUI2K4.MySubTestPanelA.Cone'

     Background=Texture'InterfaceContent.Backgrounds.bg11'
     WinTop=55.980499
     WinHeight=0.807813
}
