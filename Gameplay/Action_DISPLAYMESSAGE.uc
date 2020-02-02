class ACTION_DisplayMessage extends ScriptedAction;

var(Action) localized string		Message;
var(Action) bool		bBroadcast;
var(Action) name		MessageType;

function bool InitActionFor(ScriptedController C)
{
	local Pawn	P;

	P = C.GetInstigator();
	if ( bBroadCast )
		C.Level.Game.Broadcast(P, Message, MessageType); // Broadcast message to all players.
	else if ( P != None )
		P.ClientMessage( Message, MessageType ); 

	return false;	
}

function string GetActionString()
{
	return ActionString@Message;
}

defaultproperties
{
     messagetype="CriticalEvent"
     ActionString="display message"
}
