//==============================================================================
//	Description
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class TeamVoiceReplicationInfo extends UnrealVoiceReplicationInfo;

var int RedTeamMask, BlueTeamMask;

// Whether players from opposing teams allowed to join each other's chatroom.
// Set from gameinfo
var bool bTeamChatOnly;

replication
{
	reliable if ( Role == ROLE_Authority && (bNetDirty || bNetInitial) )
		RedTeamMask, BlueTeamMask, bTeamChatOnly;
}

simulated event InitChannels()
{
	local VoiceChatRoom TeamVCR;

	Super.InitChannels();

	TeamVCR = AddVoiceChannel();
	if ( TeamVCR != None )
		TeamVCR.SetTeam(0);

	TeamVCR = AddVoiceChannel();
	if ( TeamVCR != None )
		TeamVCR.SetTeam(1);
}

simulated function bool ValidRoom( VoiceChatRoom Room )
{
	return bEnableVoiceChat && Room != None && Room.ChannelIndex < 4 && Room.Owner == Self;
}

function SetMask( VoiceChatRoom Room, int NewMask )
{
	if ( !ValidRoom(Room) )
		return;

	if ( Room.ChannelIndex == 2 )
		RedTeamMask = NewMask;

	else if ( Room.ChannelIndex == 3 )
		BlueTeamMask = NewMask;

	else Super.SetMask(Room,NewMask);
}

simulated function int GetMask( VoiceChatRoom Room )
{
	if ( !ValidRoom(Room) )
		return 0;

	if ( Room.ChannelIndex == 2 )
		return RedTeamMask;

	if ( Room.ChannelIndex == 3 )
		return BlueTeamMask;

	return Super.GetMask(Room);
}

simulated event int GetChannelIndex(string ChannelTitle, optional int TeamIndex)
{
	local int i;

	if ( ChannelTitle != "" )
	{		
		for (i = 0; i < Channels.Length; i++)
			if (Channels[i] != None && Channels[i].GetTitle() ~= ChannelTitle && Channels[i].GetTeam() == TeamIndex)
				return Channels[i].ChannelIndex;
	}

	return Super.GetChannelIndex(ChannelTitle, TeamIndex);
}
simulated function VoiceChatRoom GetChannel(string ChatRoomName, optional int TeamIndex)
{
	local int i;

//	log(Name@"GetChannel()"@ChatRoomName@TeamIndex,'VoiceChat');
	for (i = 0; i < Channels.Length; i++)
		if (Channels[i] != None && Channels[i].GetTitle() ~= ChatRoomName && Channels[i].Owner != None && Channels[i].GetTeam() == TeamIndex)
			return Channels[i];

	return Super.GetChannel(ChatRoomName, TeamIndex);
}

function VoiceChatRoom.EJoinChatResult JoinChannel(string ChannelTitle, PlayerReplicationInfo PRI, string Password)
{
	local VoiceChatRoom VCR;
	local int i;

	if (PRI != None || PRI.Team == None)
		return JCR_Invalid;

	VCR = GetChannel(ChannelTitle, PRI.Team.TeamIndex);
	if ( VCR == None )
		return JCR_Invalid;

	if ( VCR.GetTeam() != PRI.Team.TeamIndex )
	{
		if ( VCR.IsTeamChannel() )
			return JCR_NotAllowed;

		i = GetPublicChannelCount();
		if ( bTeamChatOnly && VCR.ChannelIndex > i )
			return JCR_NotAllowed;
	}

	return VCR.JoinChannel(PRI, Password);
}

function VoiceChatRoom.EJoinChatResult JoinChannelAt(int ChannelIndex, PlayerReplicationInfo PRI, string Password)
{
	local VoiceChatRoom VCR;
	local int i;

	if ( PRI == None || PRI.Team == None )
		return JCR_Invalid;

	VCR = GetChannelAt(ChannelIndex);
	if ( VCR.GetTeam() != PRI.Team.TeamIndex )
	{
		if ( VCR.IsTeamChannel() )
			return JCR_NotAllowed;

		i = GetPublicChannelCount();
		if ( bTeamChatOnly && VCR.ChannelIndex > i )
			return JCR_NotAllowed;
	}

	return VCR.JoinChannel(PRI, Password);
}

function NotifyTeamChange(PlayerReplicationInfo PRI, int TeamIndex)
{
	local int i, j, idx;

	if ( Role < ROLE_Authority )
		return;

	j = GetPublicChannelCount();
//	log(Name@"NotifyTeamChange PRI:"$PRI.PlayerName@"TeamIndex:"$TeamIndex@"GetPublicChannelCount():"$j@"PublicChannelCount:"$PublicChannelCount,'VoiceChat');
	for (i = 0; i < Channels.Length; i++)
	{
		if ( Channels[i] == None )
			continue;

		if ( Channels[i].ChannelIndex == -1 )
		{
			log(Name@"NotifyTeamChange"@i@Channels[i].Name@Channels[i].GetTitle()@"index is -1!",'VoiceChat');
			continue;
		}

		if ( Channels[i].ChannelIndex < j )
		{
			if (Channels[i].NotifyTeamChange(PRI, TeamIndex))
			{
				idx = GetOpposingTeamChannel(Channels[i].ChannelIndex);

				Level.Game.ChangeVoiceChannel( PRI, Channels[i].ChannelIndex, idx );
				if ( PlayerController(PRI.Owner) != None && PlayerController(PRI.Owner).ActiveRoom != None &&
				     PlayerController(PRI.Owner).ActiveRoom.ChannelIndex == idx )
				{
					PlayerController(PRI.Owner).ActiveRoom = Channels[i];
					PlayerController(PRI.Owner).ClientSetActiveRoom(Channels[i].ChannelIndex);
				}
			}
		}

		else
		{
			if ( bTeamChatOnly && Channels[i].IsMember(PRI) && Channels[i].GetTeam() != TeamIndex && Channels[i].Owner != PRI )
				Level.Game.ChangeVoiceChannel( PRI, -1, Channels[i].ChannelIndex );
		}
	}
}

simulated function string GetTitle( VoiceChatRoom Room )
{
	local int i, idx;

	if ( !ValidRoom(Room) )
		return Super.GetTitle(Room);

	idx = Room.ChannelIndex;
	if ( idx >= PublicChannelNames.Length )
	{
		i = (PublicChannelNames.Length - 2);
		idx -= i;
	}

	return PublicChannelNames[idx];
}

simulated function int GetOpposingTeamChannel(int ChannelIndex)
{
	local int i, cnt;
	local VoiceChatRoom Room;

	Room = GetChannelAt(ChannelIndex);
	cnt = GetPublicChannelCount();

	for ( i = 0; i < cnt; i++ )
		if ( Channels[i] != None && Channels[i] != Room && Channels[i].GetTitle() == Room.GetTitle() )
			return Channels[i].ChannelIndex;

	return -1;
}

defaultproperties
{
     PublicChannelNames(2)="Team"
     ChatRoomClass=Class'UnrealGame.UnrealTeamChatRoom'
     DefaultChannel=2
}
