//==============================================================================
//	Created on: 08/29/2003
//	This page pops up when attempting to enter a chatroom which has a password.
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UT2K4ChatPassword extends UT2K4GetDataMenu;

var string ChatRoomTitle;
var localized string IncorrectPassword;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(Mycontroller, MyOwner);
	PlayerOwner().ClearProgressMessages();

	ed_Data.MyEditBox.bConvertSpaces = true;
	ed_Data.MaskText(True);
}

function HandleParameters(string Title, string FailCode)
{
	ChatRoomTitle = Title;
	if ( FailCode ~= "WRONGPW" )
		l_Text.Caption = Repl(IncorrectPassword, "%ChatRoom%", ChatRoomTitle);
}

function bool InternalOnClick(GUIComponent Sender)
{
	if ( Sender == b_OK  ) // Retry
		RetryPassword();

	else if ( Sender == b_Cancel ) // Fail
		Controller.CloseMenu(True);

	return true;
}

function RetryPassword()
{
	local string Password;
	local PlayerController PC;

	Password = GetDataString();
	PC = PlayerOwner();

	if ( Password == "" || PC == None )
		return;

	Controller.CloseAll(false,True);
	PC.Join(ChatRoomTitle,Password);
}

defaultproperties
{
     IncorrectPassword="Incorrect password specified for channel '%ChatRoom%' ."
     Begin Object Class=GUIButton Name=GetPassFail
         Caption="CANCEL"
         WinTop=0.561667
         WinLeft=0.586523
         WinWidth=0.147500
         WinHeight=0.045000
         TabOrder=2
         bBoundToParent=True
         OnClick=UT2K4ChatPassword.InternalOnClick
         OnKeyEvent=GetPassFail.InternalOnKeyEvent
     End Object
     b_Cancel=GUIButton'GUI2K4.UT2K4ChatPassword.GetPassFail'

     Begin Object Class=moEditBox Name=GetPassPW
         CaptionWidth=0.400000
         Caption="Chat Room Password"
         OnCreateComponent=GetPassPW.InternalOnCreateComponent
         WinTop=0.497450
         WinLeft=0.212500
         WinWidth=0.643751
         WinHeight=0.047305
         TabOrder=0
     End Object
     ed_Data=moEditBox'GUI2K4.UT2K4ChatPassword.GetPassPW'

     Begin Object Class=GUIButton Name=GetPassRetry
         Caption="RETRY"
         WinTop=0.561667
         WinLeft=0.346289
         WinWidth=0.131641
         TabOrder=1
         bBoundToParent=True
         OnClick=UT2K4ChatPassword.InternalOnClick
         OnKeyEvent=GetPassRetry.InternalOnKeyEvent
     End Object
     b_OK=GUIButton'GUI2K4.UT2K4ChatPassword.GetPassRetry'

     Begin Object Class=GUILabel Name=GetPassLabel
         Caption="A password is required to join this chat room"
         TextAlign=TXTA_Center
         bMultiLine=True
         FontScale=FNS_Large
         StyleName="TextLabel"
         WinTop=0.318897
         WinLeft=0.010742
         WinWidth=0.995117
         WinHeight=0.054688
         bBoundToParent=True
     End Object
     l_Text=GUILabel'GUI2K4.UT2K4ChatPassword.GetPassLabel'

     bAllowedAsLast=True
     OpenSound=Sound'MenuSounds.selectDshort'
}
