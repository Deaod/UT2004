//==============================================================================
//  Created on: 01/02/2004
//  Base class for all match setup panels
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
// TODO:  CONFLICTS!!!  someone updates a setting that you've already changed...their change is replicated down
//  what to do about this?
//==============================================================================

class MatchSetupPanelBase extends UT2K4TabPanel
	abstract;

var() string Group;
var() editconst noexport VotingReplicationInfo VRI;
var() bool bDirty;

function InitPanel()
{
	local int i;

	for ( i = 0; i < Controls.Length; i++ )
		Controls[i].OnChange = InternalOnChange;
}

function bool IsAdmin()
{
	local PlayerController PC;

	PC = PlayerOwner();
	return PC != None && PC.PlayerReplicationInfo != None && PC.PlayerReplicationInfo.bAdmin;
}

function bool IsLoggedIn()
{
	return IsAdmin() || VRI != None && VRI.bMatchSetupPermitted;
}

// Called when the player logs in, or when the voting replication info requests a full refresh
delegate OnLogIn();
// Called when the player logs out
delegate OnLogOut();
// Called by panels to send info the server
delegate SendCommand( string Cmd );

function LoggedIn() { EnableComponent(MyButton); }
function LoggedOut() { DisableComponent(MyButton); }

// Called on the active panel when 'Submit' is clicked
function SubmitChanges() { bDirty = false; }
// Called when information is received from the server
function bool HandleResponse(string Type, string Info, string Data) { return false; }
// Called when data transfer from the server is completed
function ReceiveComplete();
// Called when something has been changed on the panel
function InternalOnChange(GUIComponent Sender)
{
	bDirty = true;
	OnChange(Self);
}


event Free()
{
	VRI = None;
	Super.Free();
}

defaultproperties
{
     OnLogIn=MatchSetupPanelBase.LoggedIn
     OnLogOut=MatchSetupPanelBase.LoggedOut
}
