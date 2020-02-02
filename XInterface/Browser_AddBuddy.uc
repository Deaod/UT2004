class Browser_AddBuddy extends UT2K3GUIPage;

var moEditBox	MyNewBuddy;
var	Browser_ServerListPageBuddy	MyBuddyPage;

function InitComponent(GUIController pMyController, GUIComponent MyOwner)
{
	Super.InitComponent(pMyController, MyOwner);

	MyNewBuddy = moEditBox(Controls[1]);
}

function bool InternalOnClick(GUIComponent Sender)
{
	local string buddyName;

	if(Sender == Controls[4])
	{
		buddyName = MyNewBuddy.GetText();

		if(buddyName == "")
			return true;

		MyBuddyPage.Buddies.Length = MyBuddyPage.Buddies.Length + 1;
		MyBuddyPage.Buddies[MyBuddyPage.Buddies.Length - 1] = buddyName;
		MyBuddyPage.MyBuddyList.ItemCount = MyBuddyPage.Buddies.Length;
		MyBuddyPage.SaveConfig();
	}

	Controller.CloseMenu(false);

	return true;
}
		

defaultproperties
{
     Begin Object Class=GUIButton Name=VidOKBackground
         StyleName="SquareBar"
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=False
         bNeverFocus=True
         OnKeyEvent=VidOKBackground.InternalOnKeyEvent
     End Object
     Controls(0)=GUIButton'XInterface.Browser_AddBuddy.VidOKBackground'

     Begin Object Class=moEditBox Name=BuddyEntryBox
         LabelJustification=TXTA_Right
         CaptionWidth=0.550000
         Caption="Buddy Name: "
         LabelFont="UT2SmallFont"
         LabelColor=(B=255,G=255,R=255)
         OnCreateComponent=BuddyEntryBox.InternalOnCreateComponent
         WinTop=0.466667
         WinLeft=0.160000
         WinHeight=0.050000
     End Object
     Controls(1)=moEditBox'XInterface.Browser_AddBuddy.BuddyEntryBox'

     Begin Object Class=GUIButton Name=CancelButton
         Caption="CANCEL"
         WinTop=0.750000
         WinLeft=0.650000
         WinWidth=0.200000
         bBoundToParent=True
         OnClick=Browser_AddBuddy.InternalOnClick
         OnKeyEvent=CancelButton.InternalOnKeyEvent
     End Object
     Controls(2)=GUIButton'XInterface.Browser_AddBuddy.CancelButton'

     Begin Object Class=GUILabel Name=AddBuddyDesc
         Caption="Add Buddy"
         TextAlign=TXTA_Center
         TextColor=(B=0,G=200,R=230)
         TextFont="UT2HeaderFont"
         WinTop=0.400000
         WinHeight=32.000000
     End Object
     Controls(3)=GUILabel'XInterface.Browser_AddBuddy.AddBuddyDesc'

     Begin Object Class=GUIButton Name=OkButton
         Caption="OK"
         WinTop=0.750000
         WinLeft=0.125000
         WinWidth=0.200000
         bBoundToParent=True
         OnClick=Browser_AddBuddy.InternalOnClick
         OnKeyEvent=OkButton.InternalOnKeyEvent
     End Object
     Controls(4)=GUIButton'XInterface.Browser_AddBuddy.OkButton'

     WinTop=0.375000
     WinHeight=0.250000
}
