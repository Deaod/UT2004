//==============================================================================
//	Created on: 08/18/2003
//	This class handles localized messages dealing with voice chatrooms.
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class ChatRoomMessage extends LocalMessage;

var localized string AnonText;
var localized string ChatRoomString[16];

static function string AssembleMessage(
	int Index,
	string ChannelTitle,
	optional PlayerReplicationInfo RelatedPRI
	)
{
	local string Text;

	if ( RelatedPRI != None )
		Text = Repl( default.ChatRoomString[Index], "%pri%", RelatedPRI.PlayerName );
	else if ( InStr(default.ChatRoomString[Index], "%pri%") != -1 )
		Text = Repl(default.ChatRoomString[Index], "%pri%", default.AnonText);
	else
		Text = default.ChatRoomString[Index];

	if ( ChannelTitle != "" )
		return Repl( Text, "%title%", ChannelTitle );

	else return Text;
}

static function bool IsConsoleMessage( int Index )
{
	switch ( Index )
	{
	case 1:
	case 7:
	case 8:
	case 9:
	case 10:
	case 11:
	case 12:
		return False;
	}

	return Super.IsConsoleMessage(Index);
}

defaultproperties
{
     AnonText="Someone"
     ChatRoomString(0)="Invalid channel or channel couldn't be found: '%title%'"
     ChatRoomString(1)="Already a member of channel '%title%'"
     ChatRoomString(2)="Channel '%title%' requires a password!"
     ChatRoomString(3)="Incorrect password specified for channel '%title%'"
     ChatRoomString(4)="You have been banned from channel '%title%'"
     ChatRoomString(5)="Couldn't join channel '%title%'.  Channel full!"
     ChatRoomString(6)="You are not allowed to join channel '%title%'"
     ChatRoomString(7)="Successfully joined channel '%title%'"
     ChatRoomString(8)="You left channel '%title%'"
     ChatRoomString(9)="Now speaking on channel '%title%'"
     ChatRoomString(10)="No longer speaking on channel '%title%'"
     ChatRoomString(11)="'%pri%' joined channel '%title%'"
     ChatRoomString(12)="'%pri%' left channel '%title%'"
     ChatRoomString(13)="Successfully banned '%pri%' from your personal chat channel"
     ChatRoomString(14)="Voice-chat ban action not successful.  No player with the specified ID was found"
     ChatRoomString(15)="Voice chat is not enabled on this server"
}
