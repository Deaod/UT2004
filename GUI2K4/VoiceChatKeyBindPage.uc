//==============================================================================
//	Created on: 09/14/2003
//	Configures a keybind and channel name for quickly switching active voice chat room
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class VoiceChatKeyBindPage extends LargeWindow;

var automated GUILabel  l_PageTitle, l_KeyLabel1, l_KeyLabel2, l_Key1, l_Key2;
var automated moEditBox ed_ChannelName;
var automated GUIButton b_OK/*, b_Cancel*/;

var localized string NoneText, AnyKeyText;

var string Channel;
var array<string> Keys, LocalizedKeys;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	l_Key1.Caption = NoneText;
	l_Key2.Caption = NoneText;
}

function HandleParameters(string Value, string Nothing)
{
	Channel = Value;
	ed_ChannelName.SetText(Channel);
	GetBinds();
}

function GetBinds()
{
	UpdateLabel(l_Key1, False);
	UpdateLabel(l_Key2, False);

	Controller.GetAssignedKeys("Speak" @ Channel, Keys, LocalizedKeys);

	if ( LocalizedKeys.Length > 0 )
		l_Key1.Caption = LocalizedKeys[0];

	if ( LocalizedKeys.Length > 1 )
		l_Key2.Caption = LocalizedKeys[1];
}

function bool CloseClick(GUIComponent Sender)
{
	Controller.CloseMenu(False);
	return true;
}

function InternalOnChange(GUIComponent Sender)
{
	switch ( Sender )
	{
		case ed_ChannelName:
			Channel = ed_ChannelName.GetText();
			break;
	}
}

function bool KeyClick(GUIComponent Sender)
{
	if ( GUILabel(Sender) != None )
	{
		UpdateLabel( GUILabel(Sender), True );
	    Controller.OnNeedRawKeyPress = RawKeyPress;
	    Controller.Master.bRequireRawJoystick = True;
	    PlayerOwner().ConsoleCommand("toggleime 0");

	    return true;
	}

	return false;
}

function UpdateLabel( GUILabel Label, bool bWaitingForRawInput )
{
	if ( Label == None )
		return;

	if ( bWaitingForRawInput )
	{
		Label.Caption = AnyKeyText;
		Label.FontScale = FNS_Small;
	}
	else
	{
		Label.FontScale = FNS_Medium;
		Label.Caption = NoneText;
	}
}

function bool RawKeyPress(byte NewKey)
{
	local string NewKeyName, LocalizedKeyName;

    Controller.OnNeedRawKeyPress = None;
    Controller.Master.bRequireRawJoystick = False;
    PlayerOwner().ConsoleCommand("toggleime 1");

	if ( NewKey == 0x1B )
	{
		GetBinds();
		return true;
	}

	Controller.KeyNameFromIndex( NewKey, NewKeyName, LocalizedKeyName );

	Controller.SetKeyBind( NewKeyName, "Speak" @ Channel );
	PlayerOwner().ClientPlaySound(Controller.ClickSound);

    GetBinds();
    return true;
}

defaultproperties
{
     Begin Object Class=GUILabel Name=Title
         Caption="Modify Quick Switch KeyBind"
         FontScale=FNS_Large
         StyleName="TextLabel"
         WinTop=0.388802
         WinLeft=0.185352
         WinWidth=0.629687
         WinHeight=0.068164
     End Object
     l_PageTitle=GUILabel'GUI2K4.VoiceChatKeyBindPage.Title'

     Begin Object Class=GUILabel Name=KeyLabel1
         Caption="Key 1"
         StyleName="TextLabel"
         WinTop=0.487760
         WinLeft=0.464649
         WinWidth=0.082813
         WinHeight=0.038867
     End Object
     l_KeyLabel1=GUILabel'GUI2K4.VoiceChatKeyBindPage.KeyLabel1'

     Begin Object Class=GUILabel Name=KeyLabel2
         Caption="Key 2"
         StyleName="TextLabel"
         WinTop=0.487760
         WinLeft=0.654102
         WinWidth=0.200000
         WinHeight=0.038867
     End Object
     l_KeyLabel2=GUILabel'GUI2K4.VoiceChatKeyBindPage.KeyLabel2'

     Begin Object Class=GUILabel Name=Key1
         bMultiLine=True
         StyleName="TextLabel"
         WinTop=0.529427
         WinLeft=0.463673
         WinWidth=0.163867
         WinHeight=0.082813
         bAcceptsInput=True
         OnClick=VoiceChatKeyBindPage.KeyClick
     End Object
     l_Key1=GUILabel'GUI2K4.VoiceChatKeyBindPage.Key1'

     Begin Object Class=GUILabel Name=Key2
         bMultiLine=True
         StyleName="TextLabel"
         WinTop=0.529427
         WinLeft=0.654102
         WinWidth=0.130664
         WinHeight=0.082813
         bAcceptsInput=True
         OnClick=VoiceChatKeyBindPage.KeyClick
     End Object
     l_Key2=GUILabel'GUI2K4.VoiceChatKeyBindPage.Key2'

     Begin Object Class=moEditBox Name=ChannelName
         bVerticalLayout=True
         LabelJustification=TXTA_Center
         Caption="Channel Name"
         OnCreateComponent=ChannelName.InternalOnCreateComponent
         WinTop=0.486458
         WinLeft=0.142383
         WinWidth=0.278125
         WinHeight=0.087695
         OnChange=VoiceChatKeyBindPage.InternalOnChange
     End Object
     ed_ChannelName=moEditBox'GUI2K4.VoiceChatKeyBindPage.ChannelName'

     Begin Object Class=GUIButton Name=OkButton
         Caption="Apply"
         WinTop=0.616667
         WinLeft=0.673633
         WinWidth=0.116992
         OnClick=VoiceChatKeyBindPage.CloseClick
         OnKeyEvent=OkButton.InternalOnKeyEvent
     End Object
     b_OK=GUIButton'GUI2K4.VoiceChatKeyBindPage.OkButton'

     NoneText="None"
     AnyKeyText="Press Any Key|To Bind Command"
     WinTop=0.375000
     WinLeft=0.000000
     WinWidth=1.000000
     WinHeight=0.300000
}
