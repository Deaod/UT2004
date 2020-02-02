//==============================================================================
//	Created on: 08/11/2003
//	Menu that pops up when attempting to connect to a password protected server
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UT2K4GetPassword extends UT2K4GetDataMenu;

var string	RetryURL;
var localized string IncorrectPassword;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(Mycontroller, MyOwner);
	PlayerOwner().ClearProgressMessages();

//	ed_Data.MyEditBox.OnKeyEvent = InternalOnKeyEvent;
	ed_Data.MyEditBox.bConvertSpaces = true;
}

function HandleParameters(string URL, string FailCode)
{
	RetryURL = URL;
	if ( FailCode ~= "WRONGPW" )
		l_Text.Caption = IncorrectPassword;
}

function bool InternalOnClick(GUIComponent Sender)
{
	if ( Sender == b_OK  ) // Retry
		RetryPassword();

	else if ( Sender == b_Cancel ) // Fail
		Controller.ReplaceMenu(Controller.GetServerBrowserPage());

	return true;
}

function RetryPassword()
{
	local string 			EntryString;
	local ExtendedConsole	MyConsole;

	EntryString = ed_Data.GetText();
	MyConsole = ExtendedConsole(PlayerOwner().Player.Console);

	if ( MyConsole != None && EntryString != "" )
		SavePassword(MyConsole, EntryString);

	PlayerOwner().ClientTravel(
		Eval( EntryString != "",
			  RetryURL $ "?password=" $ EntryString,
			  RetryURL
			), TRAVEL_Absolute,false);

	Controller.CloseAll(false,True);
}

function SavePassword( ExtendedConsole InConsole, string InPassword )
{
	local int i;

	if ( InConsole != None )
	{
		for (i = 0; i < InConsole.SavedPasswords.Length; i++)
		{
			if ( InConsole.SavedPasswords[i].Server == InConsole.LastConnectedServer )
			{
				InConsole.SavedPasswords[i].Password = InPassword;
				break;
			}
		}

		if ( i == InConsole.SavedPasswords.Length )
		{
			InConsole.SavedPasswords.Length = InConsole.SavedPasswords.Length + 1;
			InConsole.SavedPasswords[i].Server = InConsole.LastConnectedServer;
			InConsole.SavedPasswords[i].Password = InPassword;
		}

		InConsole.SaveConfig();
	}
}

defaultproperties
{
     IncorrectPassword="Incorrect password specified.  Please try again."
     Begin Object Class=GUIButton Name=GetPassFail
         Caption="CANCEL"
         WinTop=0.547122
         WinLeft=0.586523
         WinWidth=0.147500
         WinHeight=0.045000
         TabOrder=2
         bBoundToParent=True
         OnClick=UT2K4GetPassword.InternalOnClick
         OnKeyEvent=GetPassFail.InternalOnKeyEvent
     End Object
     b_Cancel=GUIButton'GUI2K4.UT2K4GetPassword.GetPassFail'

     Begin Object Class=moEditBox Name=GetPassPW
         CaptionWidth=0.400000
         Caption="Server Password"
         OnCreateComponent=GetPassPW.InternalOnCreateComponent
         WinTop=0.485366
         WinLeft=0.209375
         WinWidth=0.562500
         TabOrder=0
     End Object
     ed_Data=moEditBox'GUI2K4.UT2K4GetPassword.GetPassPW'

     Begin Object Class=GUIButton Name=GetPassRetry
         Caption="SUBMIT"
         WinTop=0.730455
         WinLeft=0.320899
         WinWidth=0.147500
         WinHeight=0.045000
         TabOrder=1
         bBoundToParent=True
         OnClick=UT2K4GetPassword.InternalOnClick
         OnKeyEvent=GetPassRetry.InternalOnKeyEvent
     End Object
     b_OK=GUIButton'GUI2K4.UT2K4GetPassword.GetPassRetry'

     Begin Object Class=GUILabel Name=GetPassLabel
         Caption="A password is required to play on this server."
         TextAlign=TXTA_Center
         FontScale=FNS_Large
         StyleName="TextLabel"
         WinTop=0.302230
         WinLeft=0.027930
         WinWidth=0.940430
         WinHeight=0.054688
         bBoundToParent=True
     End Object
     l_Text=GUILabel'GUI2K4.UT2K4GetPassword.GetPassLabel'

     bAllowedAsLast=True
     OpenSound=Sound'MenuSounds.selectDshort'
}
