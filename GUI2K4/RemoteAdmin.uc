//==============================================================================
//  Created on: 11/23/2003
//  GUI for server administration
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class RemoteAdmin extends LargeWindow;

var automated GUITitleBar   t_Title;
var automated moComboBox    co_Options;
var automated moCheckBox    ch_Autologout;
var automated GUIImage      i_Border;

var() noexport /*editconst*/ bool bLoggedIn;

var() config array<string> AdminOptionClass;
var() config bool bAutologout;

var() editconst noexport AdminPanelBase ap_Active;
var() localized string LoggedInText, LoggedOutText;


event InitComponent(GUIController C, GUIComponent O)
{
	super.InitComponent(C, O);

	InitializePanels();
}

event Opened(GUIComponent Sender)
{
	Super.Opened(Sender);

	Controller.OnAdminReply = InternalAdminReply;
	ReloadActivePanel();
}

event Closed(GUIComponent Sender, bool bCancelled)
{
	Super.Closed(Sender, bCancelled);

	if ( bAutologout )
		PlayerOwner().AdminCommand("AdminLogout");

	Controller.OnAdminReply = None;
}

event bool NotifyLevelChange()
{
	bPersistent = False;
	LevelChanged();
	return true;
}

function InitializePanels()
{
	local int i;
	local class<AdminPanelBase> panelclass;

	co_Options.ResetComponent();
	for ( i = 0; i < AdminOptionClass.Length; i++ )
	{
		if ( AdminOptionClass[i] == "" )
			continue;

		panelclass = class<AdminPanelBase>(DynamicLoadObject(AdminOptionClass[i], class'Class'));
		if ( panelclass != None )
			co_Options.AddItem( panelclass.default.PanelCaption, new(None) panelclass );
	}

	if ( IsAdmin() )
		co_Options.MyComboBox.List.SilentSetIndex(1);
}

function ReloadActivePanel()
{
	local AdminPanelBase panel;

	panel = AdminPanelBase(co_Options.GetObject());
	if ( panel != None )
	{
		if ( ap_Active != None )
			RemoveComponent(ap_Active, True);

		ap_Active = AdminPanelBase(AppendComponent(panel, True));
		ap_Active.ShowPanel();
	}
}

function bool IsAdmin()
{
	return PlayerOwner() != None && PlayerOwner().PlayerReplicationInfo != None && PlayerOwner().PlayerReplicationInfo.bAdmin;
}

function InternalAdminReply( string Reply )
{
	local int i;
	local array<string> Results;
	local string Key, Value;

	if ( Reply == "" )
	{
		LoggedOut();
		return;
	}
	
	log("Received AdminReply '"$Reply$"'");
	Split(Reply, ";", Results);

	for ( i = 0; i < Results.Length; i++ )
	{
		if ( Divide(Results[i], "=", Key, Value) )
		{
			if ( Key ~= "name" && IsAdmin() )
				LoggedIn(Value);
				
			else if ( Key ~= "adv" )
				SetAdvanced(Value);
		}
	}
}

function LoggedIn( string AdminName )
{
	t_Title.SetCaption( Repl(LoggedInText, "%name%", AdminName) );
	EnableComponent(co_Options);
	if ( !bLoggedIn )
	{
		bLoggedIn = True;
		ap_Active.LoggedIn(AdminName);
	}
}

function LoggedOut()
{
	bLoggedIn = False;
	ap_Active.LoggedOut();
	
	t_Title.SetCaption( LoggedOutText );
	co_Options.SetIndex(0);
	DisableComponent(co_Options);
}

function SetAdvanced( coerce bool bIsAdvanced )
{
	local int i;
	local AdminPanelBase p;

	for ( i = 0; i < co_Options.ItemCount(); i++ )
	{
		p = AdminPanelBase(co_Options.MyComboBox.List.GetObjectAtIndex(i));
		if ( p != None )
			p.SetAdvanced(bIsAdvanced);
	}
}

function InternalOnChange( GUIComponent Sender )
{
	switch ( Sender )
	{
		case co_Options:
			ReloadActivePanel();
			break;

		case ch_Autologout:
			bAutologout = ch_Autologout.IsChecked();
			SaveConfig();
			break;
	}
}

defaultproperties
{
     Begin Object Class=moComboBox Name=OptionsCombo
         bReadOnly=True
         CaptionWidth=0.270000
         Caption="Section:"
         OnCreateComponent=OptionsCombo.InternalOnCreateComponent
         Hint="Select the desired group of administration options to configure"
         WinTop=0.031249
         WinLeft=0.010625
         WinWidth=0.595311
         WinHeight=0.078125
         bBoundToParent=True
         bScaleToParent=True
         OnChange=RemoteAdmin.InternalOnChange
     End Object
     co_Options=moComboBox'GUI2K4.RemoteAdmin.OptionsCombo'

     Begin Object Class=moCheckBox Name=AutoLogout
         Caption="AutoLogout"
         OnCreateComponent=AutoLogout.InternalOnCreateComponent
         Hint="Enable to automatically logout as admin when this menu is closed."
         WinTop=0.031249
         WinLeft=0.668750
         WinWidth=0.312500
         WinHeight=0.078125
         OnChange=RemoteAdmin.InternalOnChange
     End Object
     ch_Autologout=moCheckBox'GUI2K4.RemoteAdmin.AutoLogout'

     Begin Object Class=GUIImage Name=BorderImage
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.122862
         WinHeight=0.016522
         bBoundToParent=True
         bScaleToParent=True
     End Object
     i_Border=GUIImage'GUI2K4.RemoteAdmin.BorderImage'

     AdminOptionClass(0)="GUI2K4.AdminPanelLogin"
     AdminOptionClass(1)="GUI2K4.AdminPanelGeneral"
     AdminOptionClass(2)="GUI2K4.AdminPanelMaps"
     AdminOptionClass(3)="GUI2K4.AdminPanelPlayers"
     LoggedInText="Logged in as '%name%'"
     LoggedOutText="Not logged in"
}
