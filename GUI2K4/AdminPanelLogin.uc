//==============================================================================
//  Created on: 11/12/2003
//  Default screen that appears until successfully logged in
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class AdminPanelLogin extends AdminPanelBase
	config(LoginCache);

var() config bool bStoreLogins;
var() config array<AutoLoginInfo> LoginHistory;
var() localized string WaitingForLoginText, LoggedText;

var automated moEditBox  ed_LoginName, ed_LoginPassword;
var automated GUIButton  b_Login, b_Logout;
var automated GUILabel   l_Status;

var() editconst noexport string CurrentIP, CurrentPort;

function InitComponent( GUIController C, GUIComponent O )
{
	local PlayerController PC;
	local string str;
	local int i;

	Super.InitComponent(C, O);

	PC = PlayerOwner();
	str = PC.GetServerNetworkAddress();

	if ( str != "" )
	{
		if ( !Divide(str, ":", CurrentIP, CurrentPort) )
		{
			CurrentIP = str;
			CurrentPort = "7777";
		}
	}

	i = FindCredentials(CurrentIP, CurrentPort);
	if ( i != -1 )
	{
		ed_Loginname.SetText(LoginHistory[i].Username);
		ed_LoginPassword.SetText(LoginHistory[i].Password);

		if ( LoginHistory[i].bAutoLogin )
			InternalOnClick(b_Login);
	}
}

protected function UpdateStatus(string NewStatusMsg )
{
	l_Status.Caption = NewStatusMsg;
}

function bool InternalOnClick(GUIComponent Sender)
{
	local PlayerController PC;
	local string cmd, uname, upass;

	PC = PlayerOwner();
	if ( PC == None )
		return true;

	if ( Sender == b_Login )
	{
		cmd = "AdminLogin";
		uname = ed_LoginName.GetText();
		upass = ed_LoginPassword.GetText();

		UpdateStatus(WaitingForLoginText);
	}

	else if ( Sender == b_Logout )
		cmd = "AdminLogout";

	if ( uname != "" )
		cmd @= uname;

	if ( upass != "" )
		cmd @= upass;

	AdminCommand(cmd);
	return true;
}

function LoggedIn( string AdminName )
{
	DisableComponent(b_Login);
	DisableComponent(ed_LoginName);
	DisableComponent(ed_LoginPassword);

	EnableComponent(b_Logout);
	UpdateStatus(Repl(LoggedText, "%name%", AdminName));

	SaveCredentials();
}

function LoggedOut()
{
	DisableComponent(b_Logout);
	EnableComponent(b_Login);
	EnableComponent(ed_LoginName);
	EnableComponent(ed_LoginPassword);

	UpdateStatus("");
}

protected function int FindCredentials( coerce string IP, coerce string Port )
{
	local int i;

	for ( i = 0; i < LoginHistory.Length; i++ )
		if ( LoginHistory[i].IP == IP && LoginHistory[i].Port == Port )
			return i;

	return -1;
}

protected function SaveCredentials()
{
	local AutoLoginInfo NewInfo;
	local int i;

	if ( !bStoreLogins )
		return;

	NewInfo.UserName = ed_LoginName.GetText();
	NewInfo.Password = ed_LoginPassword.GetText();
	if ( NewInfo.Password == "" )
		return;

	NewInfo.IP = CurrentIP;
	NewInfo.Port = CurrentPort;

	i = FindCredentials(NewInfo.IP, NewInfo.Port);
	if ( i == -1 )
		i = LoginHistory.Length;

	LoginHistory[i] = NewInfo;
	SaveConfig();
}

defaultproperties
{
     WaitingForLoginText="Please wait while your login credentials are verified..."
     Begin Object Class=moEditBox Name=LoginNameEditbox
         LabelJustification=TXTA_Right
         CaptionWidth=0.200000
         Caption="Login Name: "
         OnCreateComponent=LoginNameEditbox.InternalOnCreateComponent
         Hint="Enter your admin username"
         WinTop=0.091667
         WinLeft=0.089063
         WinWidth=0.895312
         WinHeight=0.098438
         bBoundToParent=True
         bScaleToParent=True
     End Object
     ed_LoginName=moEditBox'GUI2K4.AdminPanelLogin.LoginNameEditbox'

     Begin Object Class=moEditBox Name=LoginPasswordEditBox
         bMaskText=True
         LabelJustification=TXTA_Right
         CaptionWidth=0.200000
         Caption="Login Password: "
         OnCreateComponent=LoginPasswordEditBox.InternalOnCreateComponent
         Hint="Enter your admin password"
         WinTop=0.236667
         WinLeft=0.014062
         WinWidth=0.970312
         WinHeight=0.098437
         bBoundToParent=True
         bScaleToParent=True
     End Object
     ed_LoginPassword=moEditBox'GUI2K4.AdminPanelLogin.LoginPasswordEditBox'

     Begin Object Class=GUIButton Name=LoginButton
         Caption="LOGIN"
         WinTop=0.418750
         WinLeft=0.360938
         WinWidth=0.286607
         WinHeight=0.092188
         bBoundToParent=True
         bScaleToParent=True
         OnClick=AdminPanelLogin.InternalOnClick
         OnKeyEvent=LoginButton.InternalOnKeyEvent
     End Object
     b_Login=GUIButton'GUI2K4.AdminPanelLogin.LoginButton'

     Begin Object Class=GUIButton Name=LogoutButton
         Caption="LOGOUT"
         WinTop=0.418750
         WinLeft=0.360938
         WinWidth=0.286607
         WinHeight=0.092188
         bBoundToParent=True
         bScaleToParent=True
         OnClick=AdminPanelLogin.InternalOnClick
         OnKeyEvent=LogoutButton.InternalOnKeyEvent
     End Object
     b_Logout=GUIButton'GUI2K4.AdminPanelLogin.LogoutButton'

     Begin Object Class=GUILabel Name=StatusLabel
         TextAlign=TXTA_Center
         bMultiLine=True
         FontScale=FNS_Large
         StyleName="TextLabel"
         WinTop=0.585417
         WinLeft=0.005312
         WinWidth=0.992189
         WinHeight=0.407813
     End Object
     l_Status=GUILabel'GUI2K4.AdminPanelLogin.StatusLabel'

     PanelCaption="Login"
}
