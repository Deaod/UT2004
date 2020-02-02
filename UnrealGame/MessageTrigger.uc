//=============================================================================
// MessageTrigger
//=============================================================================
// Broadcasts a message to all players
//=============================================================================

class MessageTrigger extends Triggers;

var()	enum EMT_MessageType
{
	EMT_Default,
	EMT_CriticalEvent,
	EMT_DeathMessage,
	EMT_Say,
	EMT_TeamSay,
} MessageType;

var() localized string	Message;

var() byte	Team;


event Trigger( Actor Other, Pawn EventInstigator )
{
	local name				MSGType;
	local Controller		C;
	local PlayerController	P;

	switch ( MessageType )
	{
		case EMT_CriticalEvent	: MSGType = 'CriticalEvent';		break;
		case EMT_DeathMessage	: MSGType = 'xDeathMessage';		break;
		case EMT_Say			: MSGType = 'SayMessagePlus';		break;
		case EMT_TeamSay		: MSGType = 'TeamSayMessagePlus';	break;
		default					: MSGType = 'StringMessagePlus';	break;
	}

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		P = PlayerController(C);
		if ( P != None && CheckTeam(P) )
			P.TeamMessage(C.PlayerReplicationInfo, Message, MSGType);
	}
}

function bool CheckTeam( PlayerController P )
{
	local byte DefendingTeam;

	if ( Team == 255 )
		return true;

	DefendingTeam = Level.Game.GetDefenderNum();

	// Normal Player Team
	if ( DefendingTeam == 255 )
		return P.GetTeamNum() == Team;

	// Check Attackers
	if ( Team == 0 && DefendingTeam != P.GetTeamNum() )
		return true;

	// Check Defenders
	if ( Team == 1 && DefendingTeam == P.GetTeamNum() )
		return true;

	return false;
}

defaultproperties
{
     messagetype=EMT_CriticalEvent
     Message="My Message"
     Team=255
}
