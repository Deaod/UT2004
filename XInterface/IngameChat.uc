// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class IngameChat extends UT2K3GUIPage;

var ExtendedConsole MyConsole;
var GUIEditBox MyEditBox;
var bool bIgnoreChar;
var int OldCMC;
var byte CloseKey;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local string KeyName;

 	Super.InitComponent(MyController, MyOwner);

    MyEditBox = GUIEditBox(Controls[2]);
    MyEditBox.OnKeyEvent = InternalOnKeyEvent;
    MyEditBox.OnKeyType = InternalOnKeyType;
    OnClose = MyOnClose;

    GUIScrollTextBox(Controls[1]).MyScrollText.bNeverFocus=true;

    KeyName = PlayerOwner().ConsoleCommand("BINDINGTOKEY InGameChat");
    if (KeyName != "")
	    CloseKey = byte(PlayerOwner().ConsoleCommand("KEYNUMBER"@KeyName));
}

function Clear()
{
	local GUIScrollTextBox MyText;

    MyText =  GUIScrollTextBox(Controls[1]);
    MyText.MyScrollText.SetContent("");
}


event HandleParameters(string Param1, string Param2)
{
	bIgnoreChar = true;
	MyEditBox.SetFocus(none);
    OldCMC = PlayerOwner().MyHud.ConsoleMessageCount;
    PlayerOwner().Myhud.ConsoleMessageCount = 0;
}

function MyOnClose(optional Bool bCanceled)
{
 	if (MyConsole!=None)
    {
    	MyConsole.ChatMenu = None;
        MyConsole=None;
    }
    PlayerOwner().MyHud.ConsoleMessageCount = OldCMC;
    super.OnClose(bCanceled);
}

function bool InternalOnKeyType(out byte Key, optional string Unicode)
{
    if (bIgnorechar)
    {
    	bIgnoreChar=false;
        return true;
    }

    return MyEditBox.InternalOnKeyType(key, Unicode);
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	local string cmd;

	if (key == CloseKey && State == 1)
	{
		Controller.CloseMenu(false);
		return true;
	}

	if (key==0x0d && State==3)
    {
        if ( Left(MyEditBox.TextStr,1)=="/" )
        	cmd = right(MyEditBox.TextStr,len(MyEditBox.TextStr)-1);
        else if ( Left(MyEditBox.TextStr,1)=="." )
        	cmd = "teamsay"@right(MyEditBox.TextStr,len(MyEditBox.TextStr)-1);
        else
        	cmd = "say"@MyEditBox.TextStr;

    	PlayerOwner().ConsoleCommand(cmd);
        MyEditBox.TextStr="";
        return true;
    }

	return MyEditBox.InternalOnKeyEvent(key,state,delta);
}

defaultproperties
{
     bRequire640x480=False
     bPersistent=True
     bAllowedAsLast=True
     Begin Object Class=GUIImage Name=ChatBackground
         Image=Texture'InterfaceContent.Menu.SquareBoxA'
         ImageStyle=ISTY_Stretched
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     Controls(0)=GUIImage'XInterface.IngameChat.ChatBackground'

     Begin Object Class=GUIScrollTextBox Name=chatText
         bNoTeletype=True
         CharDelay=0.002500
         EOLDelay=0.000000
         OnCreateComponent=chatText.InternalOnCreateComponent
         WinTop=0.020000
         WinLeft=0.030000
         WinWidth=0.940000
         WinHeight=0.880000
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     Controls(1)=GUIScrollTextBox'XInterface.IngameChat.chatText'

     Begin Object Class=GUIEditBox Name=ChatEdit
         StyleName="SquareButton"
         WinTop=0.940000
         bBoundToParent=True
         bScaleToParent=True
         OnActivate=ChatEdit.InternalActivate
         OnDeActivate=ChatEdit.InternalDeactivate
         OnKeyType=ChatEdit.InternalOnKeyType
         OnKeyEvent=ChatEdit.InternalOnKeyEvent
     End Object
     Controls(2)=GUIEditBox'XInterface.IngameChat.ChatEdit'

     WinTop=0.100000
     WinLeft=0.100000
     WinWidth=0.800000
     WinHeight=0.800000
}
