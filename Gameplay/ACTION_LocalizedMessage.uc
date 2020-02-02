class ACTION_LocalizedMessage extends ScriptedAction;

var(Action)	class<LocalMessage> MessageClass;
var(Action) int MessageNum;

function bool InitActionFor(ScriptedController C)
{
	C.BroadcastLocalizedMessage( MessageClass, MessageNum, None, None, None );
	return false;	
}

function string GetActionString()
{
	return ActionString@MessageClass.static.GetString(MessageNum);
}

defaultproperties
{
     MessageClass=Class'Gameplay.ActionMessage'
     ActionString="Localized Message"
}
