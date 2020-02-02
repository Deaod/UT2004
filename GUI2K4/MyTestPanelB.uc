// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class MyTestPanelB extends TestPanelBase;

var Automated moComboBox ComboTest;
var Automated GUILabel lbListBoxTest;
var Automated GUIListBox ListBoxTest;
var Automated GUILabel lbScrollTextBox;
var Automated GUIScrollTextBox ScrollTextBoxTest;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i,c;
    local string t;

	Super.Initcomponent(MyController, MyOwner);

    c = rand(30)+5;
    for (i=0;i<c;i++)
    	ComboTest.AddItem("Test "$Rand(100));


    c = rand(75)+25;
    for (i=0;i<c;i++)
    	ListBoxTest.List.Add("Testing "$Rand(100));

	ListBoxTest.SetFriendlyLabel(lbListBoxTest);


    c = rand(75)+25;
    for (i=0;i<c;i++)
    {
    	if (t!="")
        	t = T $"|";

    	t = t$"All Work & No Play Makes Me Sad";
    }

    ScrollTextBoxTest.SetContent(t);
	ScrollTextBoxTest.SetFriendlyLabel(lbScrollTextBox);

}

defaultproperties
{
     Begin Object Class=moComboBox Name=caOne
         ComponentJustification=TXTA_Left
         Caption="moComboBox Test"
         OnCreateComponent=caOne.InternalOnCreateComponent
         Hint="This is a combo box"
         WinTop=0.079339
         WinLeft=0.031250
         WinHeight=0.060000
         TabOrder=0
     End Object
     ComboTest=moComboBox'GUI2K4.MyTestPanelB.caOne'

     Begin Object Class=GUILabel Name=laTwo
         Caption="ListBox Test"
         WinTop=0.200000
         WinLeft=0.031250
         WinWidth=0.156250
         WinHeight=0.050000
     End Object
     lbListBoxTest=GUILabel'GUI2K4.MyTestPanelB.laTwo'

     Begin Object Class=GUIListBox Name=caTwo
         bVisibleWhenEmpty=True
         OnCreateComponent=caTwo.InternalOnCreateComponent
         WinTop=0.251653
         WinLeft=0.031250
         WinWidth=0.445313
         WinHeight=0.706250
         TabOrder=1
     End Object
     ListBoxTest=GUIListBox'GUI2K4.MyTestPanelB.caTwo'

     Begin Object Class=GUILabel Name=laThree
         Caption="Scrolling Text Test"
         WinTop=0.200000
         WinLeft=0.515625
         WinWidth=0.257813
         WinHeight=0.050000
     End Object
     lbScrollTextBox=GUILabel'GUI2K4.MyTestPanelB.laThree'

     Begin Object Class=GUIScrollTextBox Name=caThree
         CharDelay=0.050000
         bVisibleWhenEmpty=True
         OnCreateComponent=caThree.InternalOnCreateComponent
         WinTop=0.251653
         WinLeft=0.515625
         WinWidth=0.445313
         WinHeight=0.706250
         TabOrder=2
     End Object
     ScrollTextBoxTest=GUIScrollTextBox'GUI2K4.MyTestPanelB.caThree'

     Background=Texture'InterfaceContent.Backgrounds.bg11'
     WinTop=55.980499
     WinHeight=0.807813
}
