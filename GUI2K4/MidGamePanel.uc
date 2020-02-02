//==============================================================================
//  Created on: 11/12/2003
//  Base class for mid-game menu tabs
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class MidGamePanel extends UT2K4TabPanel
	abstract;

var() bool bLocked;

delegate ModifiedChatRestriction( MidGamePanel Sender, int PlayerID );
function UpdateChatRestriction( int PlayerID )
{
	log(Name@"UpdateChatRestriction PlayerID:"$PlayerID,'ChatManager');
}

function bool PlayerIDIsMine( coerce int idx )
{
	local PlayerController PC;

	PC = PlayerOwner();
	if ( PC != None && PC.PlayerReplicationInfo != None && PC.PlayerReplicationInfo.PlayerID == idx )
		return true;

	return false;
}

function Free()
{
	bLocked = true;
	Super.Free();
}

function LevelChanged()
{
	bLocked = true;
	Super.LevelChanged();
}

defaultproperties
{
}
