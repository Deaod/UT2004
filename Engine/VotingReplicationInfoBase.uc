//==============================================================================
//  Created on: 01/02/2004
//  Stub class for VotingReplicationInfo
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class VotingReplicationInfoBase extends ReplicationInfo
	abstract
	notplaceable;

replication
{
	reliable if ( Role == ROLE_Authority )
		SendResponse;

	reliable if ( Role < ROLE_Authority )
		SendCommand;
}

delegate ProcessCommand( string Command );
delegate ProcessResponse( string Response );

function SendCommand( string Cmd )
{
	ProcessCommand(Cmd);
}

simulated function SendResponse( string Response )
{
	ProcessResponse(Response);
}

simulated function bool MatchSetupLocked() { return false; }

simulated function bool MapVoteEnabled() { return false; }
simulated function bool KickVoteEnabled() { return false; }
simulated function bool MatchSetupEnabled() { return false; }

defaultproperties
{
}
