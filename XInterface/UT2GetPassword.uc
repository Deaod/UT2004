class UT2GetPassword extends UT2K3GUIPage;


var bool bIgnoreEsc;

var		localized string LeaveMPButtonText;
var		localized string LeaveSPButtonText;

var		float ButtonWidth;
var		float ButtonHeight;
var		float ButtonHGap;
var		float ButtonVGap;
var		float BarHeight;
var		float BarVPos;

var string	RetryURL;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(Mycontroller, MyOwner);
	PlayerOwner().ClearProgressMessages();

	moEditBox(Controls[1]).MyEditBox.bConvertSpaces = true;


}

function HandleParameters(string URL,string Unused)
{
	RetryURL = URL;
}

function bool InternalOnClick(GUIComponent Sender)
{
	local ExtendedConsole	MyConsole;

	if(Sender==Controls[2] && Len(moEditbox(Controls[1]).GetText()) > 0) // Retry
	{
		MyConsole = ExtendedConsole(PlayerOwner().Player.Console);

		if(MyConsole != None)
		{
			MyConsole.SavedPasswords.Length = MyConsole.SavedPasswords.Length + 1;
			MyConsole.SavedPasswords[MyConsole.SavedPasswords.Length - 1].Server = MyConsole.LastConnectedServer;
			MyConsole.SavedPasswords[MyConsole.SavedPasswords.Length - 1].Password = moEditbox(Controls[1]).GetText();
			MyConsole.SaveConfig();
		}

		PlayerOwner().ClientTravel(RetryURL$"?password="$moEditbox(Controls[1]).GetText(),TRAVEL_Absolute,false);
		Controller.CloseAll(false);
	}
	if(Sender==Controls[3]) // Fail
	{
		Controller.ReplaceMenu("xinterface.UT2MainMenu");
	}

	return true;
}

defaultproperties
{
     bIgnoreEsc=True
     bAllowedAsLast=True
     OpenSound=Sound'MenuSounds.selectDshort'
     Begin Object Class=GUIButton Name=GetPassBackground
         StyleName="RoundButton"
         WinTop=0.375000
         WinLeft=0.087500
         WinWidth=0.831251
         WinHeight=0.306250
         bAcceptsInput=False
         bNeverFocus=True
         OnKeyEvent=GetPassBackground.InternalOnKeyEvent
     End Object
     Controls(0)=GUIButton'XInterface.UT2GetPassword.GetPassBackground'

     Begin Object Class=moEditBox Name=GetPassPW
         CaptionWidth=0.400000
         Caption="Server Password"
         OnCreateComponent=GetPassPW.InternalOnCreateComponent
         WinTop=0.508594
         WinLeft=0.250000
         WinHeight=0.060000
     End Object
     Controls(1)=moEditBox'XInterface.UT2GetPassword.GetPassPW'

     Begin Object Class=GUIButton Name=GetPassRetry
         Caption="Retry"
         StyleName="MidGameButton"
         WinTop=0.941666
         WinLeft=0.400000
         WinWidth=0.250000
         WinHeight=0.050000
         bBoundToParent=True
         OnClick=UT2GetPassword.InternalOnClick
         OnKeyEvent=GetPassRetry.InternalOnKeyEvent
     End Object
     Controls(2)=GUIButton'XInterface.UT2GetPassword.GetPassRetry'

     Begin Object Class=GUIButton Name=GetPassFail
         Caption="Cancel"
         StyleName="MidGameButton"
         WinTop=0.941666
         WinLeft=0.650000
         WinWidth=0.250000
         WinHeight=0.050000
         bBoundToParent=True
         OnClick=UT2GetPassword.InternalOnClick
         OnKeyEvent=GetPassFail.InternalOnKeyEvent
     End Object
     Controls(3)=GUIButton'XInterface.UT2GetPassword.GetPassFail'

     Begin Object Class=GUILabel Name=GetPassLabel
         Caption="A password is required to play on this server."
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2HeaderFont"
         bMultiLine=True
         WinTop=0.125000
         WinHeight=0.500000
         bBoundToParent=True
     End Object
     Controls(4)=GUILabel'XInterface.UT2GetPassword.GetPassLabel'

     WinTop=0.375000
     WinHeight=0.250000
}
