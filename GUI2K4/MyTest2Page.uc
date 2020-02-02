// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class MyTest2Page extends TestPageBase;

var automated GUIImage i_Background;
var automated GUIEditbox ed_Test;

defaultproperties
{
     Begin Object Class=GUIImage Name=PageBackground
         Image=Texture'2K4Menus.Controls.popupBorder_b'
         WinTop=0.200000
         WinLeft=0.200000
         WinWidth=0.600000
         WinHeight=0.600000
     End Object
     i_Background=GUIImage'GUI2K4.MyTest2Page.PageBackground'

     Begin Object Class=GUIEditBox Name=TestEdit
         WinTop=0.200000
         WinLeft=0.200000
         WinWidth=0.200000
         WinHeight=0.200000
         OnActivate=TestEdit.InternalActivate
         OnDeActivate=TestEdit.InternalDeactivate
         OnKeyType=TestEdit.InternalOnKeyType
         OnKeyEvent=TestEdit.InternalOnKeyEvent
     End Object
     ed_Test=GUIEditBox'GUI2K4.MyTest2Page.TestEdit'

     Background=Texture'2K4Menus.Controls.menuBackground2'
     WinHeight=1.000000
}
