//==============================================================================
//  Created on: 12/30/2003
//  Description
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class MatchConfigPage extends VotingPage;

var automated GUITabControl c_Groups;
var array<MatchSetupPanelBase> Panels;
var() config array<string> PanelClass, PanelHint;

var() bool bDirty;

function InitComponent(GUIController InController, GUIComponent InOwner)
{
	local int i;
	local MatchSetupPanelBase Panel;

	Super.InitComponent(InController, InOwner);

	f_Chat.OnAccept = AcceptAndSave;
	f_Chat.OnSubmit = SubmitActive;
	c_Groups.MyFooter = f_Chat;

	MVRI.ProcessResponse = OnResponse;
	for ( i = 0; i < PanelClass.Length && i < PanelHint.Length; i++ )
	{
		Panel = MatchSetupPanelBase(c_Groups.AddTab("", PanelClass[i],,PanelHint[i]));
		if ( Panel != None )
		{
			Panels[Panels.Length] = Panel;
			Panel.VRI = MVRI;
			Panel.SendCommand = SendCommand;
			Panel.OnChange = PanelChanged;

			if ( Panel.IsLoggedIn() )
				Panel.OnLogIn();
			else Panel.OnLogOut();
		}
	}
}

function InternalOnChange( GUIComponent Sender )
{
	if ( MatchSetupPanelBase(Sender) != None )
		bDirty = true;
}

function SendCommand( string Command )
{
	if ( MVRI != None )
		MVRI.SendCommand(Command);
}

function OnResponse( string Response )
{
	local int i;
	local string Type, Info, Data;

//	log("Received response from MVRI:"@Response);

	DecodeResponse(Response, Type, Info, Data);
	if ( HandleResponse(Type, Info, Data) )
		return;

	for ( i = 0; i < Panels.Length; i++ )
		if ( Panels[i].HandleResponse(Type, Info, Data) )
			return;
}

function bool HandleResponse(string Type, string Info, string Data)
{
	local int i;

	if ( Type ~= "login" )
	{
		if ( Info == "" )
		{
			for ( i = 0; i < Panels.Length; i++ )
			{
				if ( MatchSetupLoginPanel(Panels[i]) != None )
					MatchSetupLoginPanel(Panels[i]).LoginFailed();
				else
					Panels[i].OnLogout();
			}

			return true;
		}

		for ( i = 0; i < Panels.Length; i++ )
		{
			if ( Panels[i] != None )
				Panels[i].OnLogIn();
		}

		return true;
	}

	if ( Type ~= "logout" )
	{
		for ( i = 0; i < Panels.Length; i++ )
			if ( Panels[i] != None )
				Panels[i].OnLogOut();
	}

	if ( Type ~= class'VotingReplicationInfo'.default.StatusID )
	{
		if ( Info ~= class'VotingReplicationInfo'.default.CompleteID )
		{
			for ( i = 0; i < Panels.Length; i++ )
				Panels[i].ReceiveComplete();

			return true;
		}
	}

	return false;
}

static function DecodeResponse( string Response, out string Type, out string Info, out string Data )
{
	local string str;

	Type = "";
	Info = "";
	Data = "";

	if ( Response == "" )
		return;

	if ( Divide(Response, ":", Type, str) )
	{
		if ( !Divide(str, ";", Info, Data) )
			Info = str;
	}
	else Type = Response;
}

event bool NotifyLevelChange()
{
	bPersistent = false;
	LevelChanged();
	return true;
}

function PanelChanged( GUIComponent Sender )
{
	bDirty = true;
}

function SubmitActive()
{
	local int i;

	if ( c_Groups.ActiveTab != None && c_Groups.ActiveTab.MyPanel != None )
	{
		for ( i = 0; i < Panels.Length; i++ )
		{
			if ( Panels[i] == c_Groups.ActiveTab.MyPanel )
			{
				if ( Panels[i].bDirty == true )
					Panels[i].SubmitChanges();
				break;
			}
		}
	}
}

function AcceptAndSave()
{
	local int i;

	for ( i = 0; i < Panels.Length; i++ )
	{
		if ( Panels[i].bDirty )
			Panels[i].SubmitChanges();
	}

	MVRI.MatchSettingsSubmit();

	bDirty = false;
}

defaultproperties
{
     Begin Object Class=GUITabControl Name=MatchSetupTabControl
         bDockPanels=True
         TabHeight=0.040000
         StyleName="TabBackground"
         WinTop=0.020833
         WinLeft=0.014062
         WinWidth=0.971875
         WinHeight=0.718125
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=True
         OnActivate=MatchSetupTabControl.InternalOnActivate
     End Object
     c_Groups=GUITabControl'xVoting.MatchConfigPage.MatchSetupTabControl'

     PanelClass(0)="xVoting.MatchSetupLoginPanel"
     PanelClass(1)="xVoting.MatchSetupMain"
     PanelClass(2)="xVoting.MatchSetupMaps"
     PanelClass(3)="xVoting.MatchSetupMutator"
     PanelClass(4)="xVoting.MatchSetupRules"
     PanelHint(0)="Enter your match setup username and password"
     PanelHint(1)="General match parameters"
     PanelHint(2)="Select the maps that should be played during the match"
     PanelHint(3)="Select the mutators that should be active during the match"
     PanelHint(4)="Select the rules that will be used in the match"
     bPersistent=True
     OpenSound=Sound'MenuSounds.selectDshort'
}
