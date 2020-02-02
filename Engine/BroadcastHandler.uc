//=============================================================================
// BroadcastHandler
//
// Message broadcasting is delegated to BroadCastHandler by the GameInfo.
// The BroadCastHandler handles both text messages (typed by a player) and
// localized messages (which are identified by a LocalMessage class and id).
// GameInfos produce localized messages using their DeathMessageClass and
// GameMessageClass classes.
//
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class BroadcastHandler extends Info
	config;

// rjp --  Generally, you should only need to override the 'Accept' functions
var BroadcastHandler 		NextBroadcastHandler;
var class<BroadcastHandler> NextBroadcastHandlerClass;
// -- rjp

var	int			    SentText;
var globalconfig bool		bMuteSpectators;				// Whether spectators are allowed to speak.
var globalconfig bool		bPartitionSpectators;			// Whether spectators are can only speak to spectators.

const PROPNUM = 2;
var localized string BHDisplayText[PROPNUM];
var localized string BHDescText[PROPNUM];

function UpdateSentText()
{
	SentText = 0;
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);  // Always begin with calling parent

	PlayInfo.AddSetting(default.ChatGroup,   "bMuteSpectators",		default.BHDisplayText[0], 	0, 1,	"Check",,,True,True);
	PlayInfo.AddSetting(default.ChatGroup,   "bPartitionSpectators",	default.BHDisplayText[1],	1, 1,	"Check",,,True,True);

	if ( default.NextBroadcastHandlerClass != None )
	{
		default.NextBroadcastHandlerClass.static.FillPlayInfo(PlayInfo);
		PlayInfo.PopClass();
	}
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "bMuteSpectators":		return default.BHDescText[0];
		case "bPartitionSpectators":return default.BHDescText[1];
	}

	return Super.GetDescriptionText(PropName);
}

/* Whether actor is allowed to broadcast messages now.
*/
function bool AllowsBroadcast( actor broadcaster, int Len )
{
	if ( bMuteSpectators && (PlayerController(Broadcaster) != None)
		&& !PlayerController(Broadcaster).PlayerReplicationInfo.bAdmin
		&& (PlayerController(Broadcaster).PlayerReplicationInfo.bOnlySpectator
			|| PlayerController(Broadcaster).PlayerReplicationInfo.bOutOfLives)  )
		return false;

	SentText += Len;

	if ( NextBroadcastHandler != None && !NextBroadcastHandler.HandlerAllowsBroadcast(Broadcaster, SentText) )
		return false;

	return ( (Level.Pauser != None) || (SentText < 200) );
}

function bool HandlerAllowsBroadcast( Actor Broadcaster, int SentTextNum )
{
	if ( NextBroadcastHandler != None )
		return NextBroadcastHandler.HandlerAllowsBroadcast(Broadcaster, SentTextNum);

	return true;
}

function BroadcastText( PlayerReplicationInfo SenderPRI, PlayerController Receiver, coerce string Msg, optional name Type )
{
	if ( !AcceptBroadcastText(Receiver, SenderPRI, Msg, Type) )
		return;

	if ( NextBroadcastHandler != None )
		NextBroadcastHandler.BroadcastText( SenderPRI, Receiver, Msg, Type );
	else Receiver.TeamMessage( SenderPRI, Msg, Type );
}

function BroadcastLocalized( Actor Sender, PlayerController Receiver, class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	if ( !AcceptBroadcastLocalized(Receiver, Sender, Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject) )
		return;

	if ( NextBroadcastHandler != None )
		NextBroadcastHandler.BroadcastLocalized( Sender, Receiver, Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
	else Receiver.ReceiveLocalizedMessage( Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
}

function Broadcast( Actor Sender, coerce string Msg, optional name Type )
{
	local Controller C;
	local PlayerController P;
	local PlayerReplicationInfo PRI;

	// see if allowed (limit to prevent spamming)
	if ( !AllowsBroadcast(Sender, Len(Msg)) )
		return;

	if ( Pawn(Sender) != None )
		PRI = Pawn(Sender).PlayerReplicationInfo;
	else if ( Controller(Sender) != None )
		PRI = Controller(Sender).PlayerReplicationInfo;

	if ( bPartitionSpectators && !Level.Game.bGameEnded && (PRI != None) && !PRI.bAdmin && (PRI.bOnlySpectator || PRI.bOutOfLives) )
	{
		For ( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			P = PlayerController(C);
			if ( (P != None) && (P.PlayerReplicationInfo.bOnlySpectator || P.PlayerReplicationInfo.bOutOfLives) )
				BroadcastText(PRI, P, Msg, Type);
		}
	}
	else
	{
		For ( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			P = PlayerController(C);
			if ( P != None )
				BroadcastText(PRI, P, Msg, Type);
		}
	}
}

function BroadcastTeam( Controller Sender, coerce string Msg, optional name Type )
{
	local Controller C;
	local PlayerController P;

	// see if allowed (limit to prevent spamming)
	if ( !AllowsBroadcast(Sender, Len(Msg)) )
		return;

	if ( bPartitionSpectators && !Level.Game.bGameEnded && (Sender != None) && !Sender.PlayerReplicationInfo.bAdmin && (Sender.PlayerReplicationInfo.bOnlySpectator || Sender.PlayerReplicationInfo.bOutOfLives) )
	{
		For ( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			P = PlayerController(C);
			if ( (P != None) && (P.PlayerReplicationInfo.Team == Sender.PlayerReplicationInfo.Team)
				&& (P.PlayerReplicationInfo.bOnlySpectator || P.PlayerReplicationInfo.bOutOfLives) )
				BroadcastText(Sender.PlayerReplicationInfo, P, Msg, Type);
		}
	}
	else
	{
		For ( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			P = PlayerController(C);
			if ( (P != None) && (P.PlayerReplicationInfo.Team == Sender.PlayerReplicationInfo.Team) )
				BroadcastText(Sender.PlayerReplicationInfo, P, Msg, Type);
		}
	}
}

/*
 Broadcast a localized message to all players.
 Most messages deal with 0 to 2 related PRIs.
 The LocalMessage class defines how the PRI's and optional actor are used.
*/
event AllowBroadcastLocalized( actor Sender, class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	local Controller C;
	local PlayerController P;

	For ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		P = PlayerController(C);
		if ( P != None )
			BroadcastLocalized(Sender, P, Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	}
}

// rjp --- Linked list for broadcast handlers
function RegisterBroadcastHandler(BroadcastHandler NewBH)
{
	if ( NextBroadcastHandler == None )
	{
		NextBroadcastHandler = NewBH;
		default.NextBroadcastHandlerClass = NewBH.Class;
	}

	else NextBroadcastHandler.RegisterBroadcastHandler(NewBH);
}

function bool AcceptBroadcastText( PlayerController Receiver, PlayerReplicationInfo SenderPRI, out string Msg, optional name Type )
{
	if ( NextBroadcastHandler != None )
		return NextBroadcastHandler.AcceptBroadcastText(Receiver, SenderPRI, Msg, Type);

	return true;
}

function bool AcceptBroadcastLocalized(PlayerController Receiver, Actor Sender, class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object Obj)
{
	if ( NextBroadcastHandler != None )
		return NextBroadcastHandler.AcceptBroadcastLocalized(Receiver, Sender, Message, Switch, RelatedPRI_1, RelatedPRI_2, Obj);

	return true;
}

function bool AcceptBroadcastSpeech(PlayerController Receiver, PlayerReplicationInfo SenderPRI)
{
	if ( NextBroadcastHandler != None )
		return NextBroadcastHandler.AcceptBroadcastSpeech(Receiver, SenderPRI);

	return true;
}

function bool AcceptBroadcastVoice(PlayerController Receiver, PlayerReplicationInfo SenderPRI)
{
	if ( NextBroadcastHandler != None )
		return NextBroadcastHandler.AcceptBroadcastVoice(Receiver, SenderPRI);

	return true;
}
// --- rjp

event Destroyed()
{
	default.NextBroadcastHandlerClass = None;
	Super.Destroyed();
}

defaultproperties
{
     BHDisplayText(0)="Mute Spectators"
     BHDisplayText(1)="Partition Spectators"
     BHDescText(0)="Check this option to prevent spectators from chatting during the game."
     BHDescText(1)="Check this option to separate spectator chat from player chat."
}
