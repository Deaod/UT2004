//==============================================================================
//	Created on: 08/29/2003
//	UnrealPlayerChatManager is responsible for tracking each player's chat preferences and restrictions.
//  When a client joins the game, a new UnrealPlayerChatManager object is spawned for that player, and replicated
//  to the client.   When the UnrealPlayerChatManager object arrives on the client, it requests a list of player hashes
//  for all players currently connected to the server.
//  The hashes received from the server are matched against the local client's stored restrictions.  When a match is
//  found, UnrealPlayerChatManager updates the server's copy of the tracking information with the client's restriction.
//
//  Thereafter, when the client's copy of the UnrealPlayerChatManager object is notified that a new client has
//  connected, it requests the hash information for that player in order to match it against the client's stored
//  restrictions.
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UnrealPlayerChatManager extends PlayerChatManager
	config(ChatRestriction);

const NOTEXT = 1;
const NOSPEECH = 2;
const NOVOICE = 4;
const BANNED = 8;

struct StoredChatBan
{
	var string PlayerHash;
	var byte Restriction;
};

struct ChatBan
{
	var int PlayerID;
	var string PlayerHash;
	var string PlayerAddress;
	var byte PlayerVoiceMask;
	var byte Restriction;	// 1 - Text, 2 - Speech, 4 - Voice, 8 - Banned from private chat
};

// Restricted player hashes.
var globalconfig protected array<StoredChatBan> StoredChatRestrictions;
var protected array<ChatBan>					ChatRestrictions;


simulated function ChatDebug()
{
	local int i;

	for ( i = 0; i < StoredChatRestrictions.Length; i++ )
	{
		log("   StoredChatRestrictions["$i$"] Hash:"$StoredChatRestrictions[i].PlayerHash@"Restriction:"$StoredChatRestrictions[i].Restriction);

	}

	for ( i = 0; i < ChatRestrictions.Length; i++ )
	{
		LogChatRestriction(i);
	}
}

simulated function LogChatRestriction(int i)
{
	log("   ChatRestrictions["$i$"] PlayerID:"$ChatRestrictions[i].PlayerID@
			"Hash:"$ChatRestrictions[i].PlayerHash@
			"Address:"$ChatRestrictions[i].PlayerAddress@
			"Mask:"$ChatRestrictions[i].PlayerVoiceMask@
			"Restriction:"$ChatRestrictions[i].Restriction);
}

// Called from TrackNewPlayer when we receive a new player's information - check to see if we placed a restriction on
// this player during a previous match
simulated protected function bool LoadChatBan(string PlayerHash, out byte OutRestriction)
{
	local int i;

	for ( i = 0; i < StoredChatRestrictions.Length; i++ )
	{
		if ( StoredChatRestrictions[i].PlayerHash == PlayerHash )
		{
			OutRestriction = StoredChatRestrictions[i].Restriction;
			return true;
		}
	}

	return false;
}

// Save the PlayerHash and Restriction to persistent array
simulated protected function StoreChatBan(string PlayerHash, byte Restriction)
{
	local int i;

	// First, determine if this player is already in our list - if so, replace the restriction with the specified one
	for ( i = 0; i < StoredChatRestrictions.Length; i++ )
	{
		if ( StoredChatRestrictions[i].PlayerHash == PlayerHash )
			break;
	}

	if ( i == StoredChatRestrictions.Length )
	{
		// If the restriction is 0, stop here - no restriction
		if ( Restriction == 0 )
			return;

		StoredChatRestrictions.Length = i + 1;
	}
	else if ( Restriction == 0 )
	{
		StoredChatRestrictions.Remove(i,1);
		return;
	}

log("StoreChatBan PlayerHash:"$PlayerHash@"Restriction:"$Restriction,'ChatManager');
	StoredChatRestrictions[i].PlayerHash = PlayerHash;
	StoredChatRestrictions[i].Restriction = Restriction;
}

// Called from xPlayer.ServerRequestBanInfo - used to track player hashes on the client
simulated function ReceiveBanInfo(string S)
{
	local array<string> Arr;
	local int PlayerID;
	local string PlayerHash, PlayerAddress;

	log(Name@"ReceiveBanInfo S:"$S,'ChatManager');
	Split(S, Chr(27), Arr);

	if ( Arr.Length < 3 )
	{
		log("Error receiving ban info Arr.Length:"$Arr.Length@S,'ChatManager');
		return;
	}

	PlayerID = int(Arr[0]);
	PlayerHash = Arr[1];
	PlayerAddress = Arr[2];

	TrackNewPlayer(PlayerID, PlayerHash, PlayerAddress);
}

// Called when we've received a new playerhash from ReceiveBanInfo -
simulated function TrackNewPlayer(int PlayerID, string PlayerHash, string PlayerAddress)
{
	local int i;
	local PlayerReplicationInfo PRI;
	local byte NewRestriction;

	if ( PlayerOwner == None )
	{
		log(Name@"Couldn't update server tracking - No PlayerOwner!",'ChatManager');
		return;
	}

	log(Name@"___________________TrackNewPlayer PlayerID:"$PlayerID@"PlayerHash:"$PlayerHash@"PlayerAddress:"$PlayerAddress,'ChatManager');

	// First, check if we're already tracking this player
	for ( i = 0; i < ChatRestrictions.Length; i++ )
		if ( ChatRestrictions[i].PlayerID == PlayerID )
			break;

	if ( i == ChatRestrictions.Length )
		ChatRestrictions.Length = ChatRestrictions.Length + 1;

	// Next, check if we've got this player's hash in our list of stored bans...if so, notify the server about our preference
	if ( Role < ROLE_Authority && LoadChatBan(PlayerHash, NewRestriction) )
		PlayerOwner.ServerChatRestriction(PlayerID, NewRestriction);

	else if ( Level.NetMode == NM_ListenServer && PlayerOwner == Level.GetLocalPlayerController() )
		LoadChatBan(PlayerHash, NewRestriction);

	// Now, add this player to the instance tracking
	ChatRestrictions[i].PlayerID = PlayerID;
	ChatRestrictions[i].PlayerHash = PlayerHash;
	ChatRestrictions[i].PlayerAddress = PlayerAddress;
	ChatRestrictions[i].Restriction = NewRestriction;


	// Finally, add this player's voice mask to the tracking info  (only happens on server).
	// VoiceID is used to determine which players are in which channels
	PRI = PlayerOwner.GameReplicationInfo.FindPlayerByID(PlayerID);
	if ( PRI != None )
		ChatRestrictions[i].PlayerVoiceMask = PRI.VoiceID;
//	else log(Name@"TrackNewPlayer No PRI so couldn't update VoiceID for ChatRestrictions["$i$"]",'ChatManager');
}

simulated function UnTrackPlayer(int PlayerID)
{
	local int i;

	log("Untrack player:"$PlayerID,'ChatManager');
	// Remove this player from the ban tracking system
	for ( i = 0; i < ChatRestrictions.Length; i++ )
	{
		if ( ChatRestrictions[i].PlayerID == PlayerID )
		{
			ChatRestrictions.Remove(i,1);
			return;
		}
	}

	log("Untrack player couldn't find restriction for PlayerID:"$PlayerID,'ChatManager');
}

// Returns whether we should receive text messages from Sender
function bool AcceptText( PlayerReplicationInfo Sender, out string Msg, optional name Type )
{
	local int i;

	if ( Sender == None )
		return Super.AcceptText(Sender, Msg, Type);

	i = GetIDIndex(Sender.PlayerID);
	if ( !IsValid(i) )
		return true;

	log(Name@"Owner:"$PlayerOwner.PlayerReplicationInfo.PlayerName@"Restriction for Index "$i$":"$ChatRestrictions[i].Restriction,'ChatManager');
	return !bool(ChatRestrictions[i].Restriction & NOTEXT);
}

// Returns whether we should receive Speech messages from Sender
function bool AcceptSpeech(PlayerReplicationInfo SenderPRI)
{
	local int i;

	if ( SenderPRI == None )
		return Super.AcceptSpeech(SenderPRI);

	i = GetIDIndex(SenderPRI.PlayerID);
	if ( !IsValid(i) )
		return true;

	return !bool(ChatRestrictions[i].Restriction & NOSPEECH);
}

// Returns whether we should accept voice messages from sender
event bool AcceptVoice(PlayerReplicationInfo SenderPRI)
{
	local int i;

	if ( SenderPRI == None )
		return Super.AcceptVoice(SenderPRI);

	i = GetIDIndex(SenderPRI.PlayerID);
	if ( !IsValid(i) )
		return true;

	return !bool(ChatRestrictions[i].Restriction & NOVOICE);
}

function bool IsBanned(PlayerReplicationInfo PRI)
{
	local int i;
	local string PlayerHash;

	PlayerHash = PlayerController(PRI.Owner).GetPlayerIDHash();
	log(Name@"IsBanned() PRI:"$PRI.Name,'ChatManager');
	for (i = 0; i < ChatRestrictions.Length; i++)
	{
		if (ChatRestrictions[i].PlayerHash == PlayerHash)
		{
			log(Name@"IsBanned() found matching PlayerHash for"@PlayerHash$":"$i@"Restriction:"$ChatRestrictions[i].Restriction,'ChatManager');
			return bool(ChatRestrictions[i].Restriction & BANNED);
		}
	}

	return Super.IsBanned(PRI);
}

// Update the restrictions on chat for a player
simulated function bool SetRestriction(string PlayerHash, byte Type)
{
	local int i;

	i = GetHashIndex(PlayerHash);

log(Name@"SetRestriction PlayerHash:"$PlayerHash@"i:"$i@"Type:"$Type,'ChatManager');
	if ( !IsValid(i) )
	{
		// If we aren't currently tracking this player, and the restriction is none, don't add the restriction
		if ( Type == 0 )
			return false;

		i = ChatRestrictions.Length;
		ChatRestrictions.Length = i + 1;
	}

	// If the new restriction is the same as the current restriction, stop here
	else if ( ChatRestrictions[i].Restriction == Type )
		return false;

	ChatRestrictions[i].Restriction = Type;

	// If we're the client, copy the restriction to the persistent array
	if ( IsLocal() )
	{
		StoreChatBan(PlayerHash, Type);
		SaveConfig();
	}
	return true;
}

simulated function bool SetRestrictionID(int PlayerID, byte Type)
{
	local string PlayerHash;

	log(Name@"SetRestrictionID PlayerID:"$PlayerID@"Type:"$Type,'ChatManager');

	// Query the player's hash from the tracking system
	PlayerHash = GetPlayerHash(PlayerID);
	if ( PlayerHash == "" )
		return false;

	return SetRestriction(PlayerHash, Type);
}

simulated function bool AddRestriction( string PlayerHash, byte Type )
{
	return MergeRestriction( GetHashIndex(PlayerHash), Type );
}

simulated function bool AddRestrictionID( int PlayerID, byte Type )
{
	return AddRestriction(GetPlayerHash(PlayerID), Type);
}

simulated function bool ClearRestriction( string PlayerHash, byte Type )
{
	return UnMergeRestriction( GetHashIndex(PlayerHash), Type);
}

simulated function bool ClearRestrictionID( int PlayerID, byte Type )
{
	return ClearRestriction( GetPlayerHash(PlayerID), Type);
}

// Used to update a restriction if calling function doesn't know the current restriction of the player
// This function cannot be used to _remove_ a restriction - use UnMerge restriction instead
simulated function bool MergeRestriction(int Index, byte NewType)
{
	if ( !IsValid(Index) )
		return false;

	// First, clear the bits
	ChatRestrictions[Index].Restriction = ChatRestrictions[Index].Restriction & ~NewType;

	// Now, set the bits
	ChatRestrictions[Index].Restriction = ChatRestrictions[Index].Restriction | NewType;

	if ( IsLocal() )
	{
		StoreChatBan(ChatRestrictions[Index].PlayerHash, ChatRestrictions[Index].Restriction);
		SaveConfig();
	}

	return True;
}

simulated function bool UnMergeRestriction(int Index, byte NewType)
{
	if ( !IsValid(Index) )
		return false;

	if ( !bool(ChatRestrictions[Index].Restriction & NewType) )
		return False;

	ChatRestrictions[Index].Restriction = ChatRestrictions[Index].Restriction & ~NewType;
	if ( IsLocal() )
	{
		StoreChatBan(ChatRestrictions[Index].PlayerHash, ChatRestrictions[Index].Restriction);
		SaveConfig();
	}

	return True;
}

//###############################################################################################################
//
//
//		Query functions
//

simulated function byte GetPlayerRestriction(int PlayerID)
{
	local int i;

	i = GetIDIndex(PlayerID);
	if ( !IsValid(i) )
		return Super.GetPlayerRestriction(PlayerID);

	return ChatRestrictions[i].Restriction;
}

simulated function bool ClientIsBanned(string PlayerHash)
{
	local int i;

	if ( PlayerHash == "" )
		return True;

	for (i = 0; i < ChatRestrictions.Length; i++)
		if (ChatRestrictions[i].PlayerHash == PlayerHash)
			return bool(ChatRestrictions[i].Restriction & BANNED);

	return Super.ClientIsBanned(PlayerHash);
}

simulated protected function string GetPlayerHash(int PlayerID)
{
	local int i;

	if ( PlayerID < 1 )
		return "";

	for ( i = 0; i < ChatRestrictions.Length; i++ )
	{
		log(Name@"GetPlayerHash Match:"$PlayerID@"Test["$i$"]:"$ChatRestrictions[i].PlayerID);
		if ( ChatRestrictions[i].PlayerID == PlayerID )
			return ChatRestrictions[i].PlayerHash;
	}

	return "";
}

simulated protected function int GetIDIndex(int PlayerID)
{
	local int i;

	if ( PlayerID < 1 )
		return -1;

	for ( i = 0; i < ChatRestrictions.Length; i++ )
		if ( ChatRestrictions[i].PlayerID == PlayerID )
			return i;

	return -1;
}

simulated protected function int GetHashIndex(string PlayerHash)
{
	local int i;

	if ( PlayerHash == "" )
		return -1;

	for ( i = 0; i < ChatRestrictions.Length; i++ )
		if ( ChatRestrictions[i].PlayerHash == PlayerHash )
			return i;

	return -1;
}

simulated protected function bool IsValid(int i)
{
	return i >= 0 && i < ChatRestrictions.Length;
}

simulated function bool IsLocal()
{
	return Level.NetMode == NM_Client ||
		(Level.NetMode == NM_ListenServer &&
		PlayerOwner != None && PlayerOwner == Level.GetLocalPlayerController());
}

simulated function int Count()
{
	return ChatRestrictions.Length;
}

defaultproperties
{
}
