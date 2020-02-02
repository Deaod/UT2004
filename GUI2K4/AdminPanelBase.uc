//==============================================================================
//  Created on: 11/12/2003
//  Base class for admin controls
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class AdminPanelBase extends GUIPanel;

var() localized string PanelCaption;
var() noexport  bool bAdvancedAdmin;

function bool IsAdmin()
{
	return PlayerOwner() != None && PlayerOwner().PlayerReplicationInfo != None && PlayerOwner().PlayerReplicationInfo.bAdmin;
}

function AdminCommand( string Command )
{
	if ( PlayerOwner() != None )
		PlayerOwner().AdminCommand(Command);
}

function LoggedIn( string AdminName );
function LoggedOut();

function SetAdvanced( bool bIsAdvanced )
{
	bAdvancedAdmin = bIsAdvanced;
}

function AdminReply(string Reply);
function ShowPanel();

defaultproperties
{
     WinTop=0.131250
     WinHeight=0.862502
     bBoundToParent=True
     bScaleToParent=True
}
