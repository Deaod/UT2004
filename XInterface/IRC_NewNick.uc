class IRC_NewNick extends UT2K3GUIPage;

var moEditBox	MyNewNick;

var	IRC_System	SystemPage;
var GUILabel	NewNickPrompt;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	MyNewNick = moEditBox(Controls[1]);
	NewNickPrompt = GUILabel(Controls[2]);

	MyNewNick.SetText("");
}

function bool InternalOnClick(GUIComponent Sender)
{
	local string NewNick;

	if(Sender == Controls[3])
	{
		NewNick = MyNewNick.GetText();

		if(NewNick == "")
			return true;

		Log("NewNick "$NewNick);
		SystemPage.Link.SendCommandText("NICK "$NewNick);
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
     Controls(0)=GUIButton'XInterface.IRC_NewNick.VidOKBackground'

     Begin Object Class=moEditBox Name=NewNickEntry
         LabelJustification=TXTA_Right
         CaptionWidth=0.550000
         Caption="New Nickname: "
         LabelFont="UT2SmallFont"
         LabelColor=(B=255,G=255,R=255)
         OnCreateComponent=NewNickEntry.InternalOnCreateComponent
         WinTop=0.466667
         WinLeft=0.160000
         WinHeight=0.050000
     End Object
     Controls(1)=moEditBox'XInterface.IRC_NewNick.NewNickEntry'

     Begin Object Class=GUILabel Name=NickMesg
         TextAlign=TXTA_Center
         TextColor=(B=0,G=200,R=230)
         TextFont="UT2HeaderFont"
         WinTop=0.400000
         WinHeight=32.000000
     End Object
     Controls(2)=GUILabel'XInterface.IRC_NewNick.NickMesg'

     Begin Object Class=GUIButton Name=OkButton
         Caption="OK"
         WinTop=0.750000
         WinLeft=0.400000
         WinWidth=0.200000
         bBoundToParent=True
         OnClick=IRC_NewNick.InternalOnClick
         OnKeyEvent=OkButton.InternalOnKeyEvent
     End Object
     Controls(3)=GUIButton'XInterface.IRC_NewNick.OkButton'

     WinTop=0.375000
     WinHeight=0.250000
}
