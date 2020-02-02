//==============================================================================
//	Created on: 08/29/2003
//	PlayerChatManager serves as a proxy between GameInfo and PlayerController to intercept
//	and alter player chat.
//
//	All types of chat (text, speech, voice) must go through PlayerChatManager in order to reach the client.
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//
// TODO: Allow players to restrict speech based on type (taunt, order, etc.)
//==============================================================================
class PlayerChatManager extends Info
	native;

var PlayerController PlayerOwner;

event PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( PlayerController(Owner) == None )
		Destroy();

	if ( bDeleteMe )
		return;

	PlayerOwner = PlayerController(Owner);
}

simulated function ReceiveBanInfo(string S);
simulated function TrackNewPlayer(int PlayerID, string PlayerHash, string PlayerAddress);
simulated function UnTrackPlayer(int PlayerID);

function bool AcceptText( PlayerReplicationInfo Sender, out string Msg, optional name Type ) { return true; }
function bool AcceptLocalized( Actor Sender, class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object Obj ) { return true; }
function bool AcceptSpeech(PlayerReplicationInfo Sender)               { return true; }
event bool AcceptVoice(PlayerReplicationInfo Sender)                   { return true; }
simulated function bool SetRestriction(string PlayerHash, byte Type)   { return true; }
simulated function bool SetRestrictionID(int PlayerID, byte Type)      { return true; }
simulated function bool AddRestriction(string PlayerHash, byte Type)   { return True; }
simulated function bool AddRestrictionID(int PlayerID, byte Type)      { return True; }
simulated function bool ClearRestriction(string PlayerHash, byte Type) { return true; }
simulated function bool ClearRestrictionID(int PlayerID, byte Type)    { return true; }
function bool IsBanned(PlayerReplicationInfo PRI)                      { return false; }
simulated function bool ClientIsBanned(string PlayerHash)              { return false; }
simulated function byte GetPlayerRestriction(int PlayerID)             { return 0;     }
simulated function int Count();

simulated function ChatDebug();

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
}
