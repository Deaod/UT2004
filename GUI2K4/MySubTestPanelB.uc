// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class MySubTestPanelB extends TestPanelBase;

var Automated GUIListBox ListBoxTest;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i,c;

	Super.Initcomponent(MyController, MyOwner);

    c = rand(75)+25;
    for (i=0;i<c;i++)
    	ListBoxTest.List.Add("All Work & No Play Makes Me Sad");

}

defaultproperties
{
     Begin Object Class=GUIListBox Name=Cone
         bVisibleWhenEmpty=True
         OnCreateComponent=Cone.InternalOnCreateComponent
         WinHeight=1.000000
     End Object
     ListBoxTest=GUIListBox'GUI2K4.MySubTestPanelB.Cone'

     Background=Texture'InterfaceContent.Backgrounds.bg11'
     WinTop=55.980499
     WinHeight=0.807813
}
