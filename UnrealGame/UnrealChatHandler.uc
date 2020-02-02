//==============================================================================
//	Created on: 08/29/2003
//	Description
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UnrealChatHandler extends BroadcastHandler;

var bool bDebug;

function ToggleChatDebug()
{
	bDebug = !bDebug;
}

function DoChatDebug()
{
	local array<PlayerController> Arr;
	local int i;

	if ( !bDebug )
		ToggleChatDebug();

	Level.Game.GetPlayerControllerList(Arr);

	log("Controller list length:"$Arr.Length,'ChatManager');
	for (i = 0; i < Arr.Length; i++)
	{
		if ( Arr[i].ChatManager == None )
		{
			log(Arr[i].Name@"PC["$i$"].ChatManager None ("$Arr[i].PlayerReplicationInfo.PlayerName$")",'ChatManager');
			log("");
			continue;
		}

		log(Arr[i].Name@"PC["$i$"] ("$Arr[i].PlayerReplicationInfo.PlayerName$") Chat Handler Information",'ChatManager');
		Arr[i].ChatManager.ChatDebug();

		log("");
	}
}

function bool AcceptBroadcastText( PlayerController Receiver, PlayerReplicationInfo SenderPRI, out string Msg, optional name Type )
{
	local bool Result;

	if ( Receiver != None && Receiver.ChatManager != None )
	{
		Result = Receiver.ChatManager.AcceptText(SenderPRI, Msg, Type);
		if ( bDebug )
		{
			log("AcceptBroadcastText() Receiver:"$Receiver.Name@"Sender:"$SenderPRI.PlayerName@"Allowed:"$Result,'ChatManager');
			if ( !Result )
				return false;
		}

		else if ( !Receiver.ChatManager.AcceptText(SenderPRI, Msg, Type) )
			return false;
	}
	else if ( bDebug )
	{
		log("AcceptBroadcastText() Receiver:"$Receiver.Name@"Receiver.ChatManager:"$Receiver.ChatManager,'ChatManager');
	}

	return Super.AcceptBroadcastText(Receiver, SenderPRI, Msg, Type);
}

function bool AcceptBroadcastLocalized(PlayerController Receiver, Actor Sender, class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object Obj)
{
	if ( Receiver != None && Receiver.ChatManager != None )
	{
		if ( !Receiver.ChatManager.AcceptLocalized(Sender, Message, Switch, RelatedPRI_1, RelatedPRI_2, Obj) )
			return false;
	}

	return Super.AcceptBroadcastLocalized(Receiver, Sender, Message, Switch, RelatedPRI_1, RelatedPRI_2, Obj);
}

function bool AcceptBroadcastSpeech(PlayerController Receiver, PlayerReplicationInfo SenderPRI)
{
	local bool bResult;

	if ( Receiver != None && Receiver.ChatManager != None )
	{
		bResult = Receiver.ChatManager.AcceptSpeech(SenderPRI);
		if ( bDebug )
		{
			log("AcceptBroadcastSpeech() Receiver:"$Receiver.Name@"Sender:"$SenderPRI.PlayerName@"Allowed:"$bResult,'ChatManager');
			if ( !bResult )
				return false;
		}

		else if ( !Receiver.ChatManager.AcceptSpeech(SenderPRI) )
			return false;
	}
	else if ( bDebug )
	{
		log("AcceptBroadcastSpeech() Receiver:"$Receiver.Name@"Receiver.ChatManager:"$Receiver.ChatManager,'ChatManager');
	}

	return Super.AcceptBroadcastSpeech(Receiver, SenderPRI);
}

function bool AcceptBroadcastVoice(PlayerController Receiver, PlayerReplicationInfo Sender)
{
	if ( Receiver != None && Receiver.ChatManager != None )
	{
		if ( !Receiver.ChatManager.AcceptVoice(Sender) )
			return false;
	}

	return Super.AcceptBroadcastVoice(Receiver, Sender);
}

defaultproperties
{
}
