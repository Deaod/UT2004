//==============================================================================
//	UnrealTeamChatRoom allows the server to have two channels with the same name - one for each team
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UnrealTeamChatRoom extends UnrealChatRoom;

simulated function bool IsTeamChannel()
{
	return VoiceChatReplicationInfo(Owner) != None && !IsPublicChannel();
}

simulated function bool CanJoinChannel(PlayerReplicationInfo PRI)
{
	if ( !Super.CanJoinChannel(PRI) )
		return false;

	if ( PRI.Team == None )
	{
		log("CanJoinChannel returning false PRI.Team == None",'VoiceChat');
		return false;
	}

	if ( GetTeam() != PRI.Team.TeamIndex )
	{
		// Always allowed to join public channels
		if ( IsPublicChannel() )
			return true;

		// Team, Offense, Defense
		if ( IsTeamChannel() )
			return false;

		// Only if server allows cross-team private chat
		if ( TeamVoiceReplicationInfo(VoiceChatManager).bTeamChatOnly )
			return false;
	}

	return true;
}

// This function is called from TeamInfo.AddToTeam()
// It handles switching a player's membership in any "team" channels to the corresponding channel on the new team
function bool NotifyTeamChange(PlayerReplicationInfo PRI, int NewTeamIndex)
{
	local VoiceChatRoom Other;

	// Only one copy of public channels, so don't worry about it
	if ( IsPublicChannel() )
		return false;

	// Not joining our team - we don't care
	if ( GetTeam() != NewTeamIndex )
		return false;

	// This player is a member of this channel already, just skip
	if ( IsMember(PRI) )
		return false;

	if ( IsTeamChannel() )
	{
		// Find out if this player is a member of the opposing team's channel
		Other = VoiceChatManager.GetChannelAt(TeamVoiceReplicationInfo(VoiceChatManager).GetOpposingTeamChannel(ChannelIndex));
		if ( Other != None )
			return Other.IsMember(PRI);
	}

	return Super.NotifyTeamChange(PRI,NewTeamIndex);
}

defaultproperties
{
}
