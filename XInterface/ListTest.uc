class ListTest extends TestPageBase;

//var GUIList	TheList;
//var GUIStringCollection Col1, Col2;
var GUIScrollText	tScroll;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
local string newText;

	Super.InitComponent(MyController, MyOwner);
	tScroll=GUIScrollTextBox(Controls[0]).MyScrollText;

	newText = "This is a simple test of multiline splitting that should be happening very easily but i will debug to be sure that whatever the length is set at it wont bug."$Chr(10)$Chr(10);
	newText = newText$"But more importantly i must also handle having more than just 1 line of text and see how this is dealt with."$Chr(10);
	newText = newText$"I wonder how this would be dealt with if i wasnt taking care of it and if Joe wasnt going to do it."$Chr(10)$Chr(10);
	newText = newText$"Bah, We'll see later since no one seems to reply to my messages.";

	tScroll.SetContent(newText);
//	TheList=GUIList(Controls[0]);
//	Col1=GUIStringCollection(GUIListCollection(Controls[1]).MyCollection);
//	Col2=GUIStringCollection(GUIListCollection(Controls[2]).MyCollection);
//	Col2.bMultiSelect=true;
	Controller.bDesignMode = false;
}

function bool AddClick(GUIComponent Sender)
{
//	TheList.Add("Simple Item Text");
//	Col1.AddItem("Simple Item Text"@Col1.Count());
//	Col2.AddItem("Simple Item Text"@Col1.Count());
	return true;
}

defaultproperties
{
     Begin Object Class=GUIScrollTextBox Name=Scroller
         CharDelay=0.050000
         EOLDelay=0.600000
         OnCreateComponent=Scroller.InternalOnCreateComponent
         WinTop=0.050000
         WinLeft=0.050000
         WinWidth=0.350000
         WinHeight=0.200000
     End Object
     Controls(0)=GUIScrollTextBox'XInterface.ListTest.Scroller'

     Begin Object Class=GUIButton Name=btnAddItems
         WinTop=0.550000
         WinLeft=0.050000
         WinWidth=0.400000
         WinHeight=0.060000
         OnClick=ListTest.AddClick
         OnKeyEvent=btnAddItems.InternalOnKeyEvent
     End Object
     Controls(1)=GUIButton'XInterface.ListTest.btnAddItems'

}
