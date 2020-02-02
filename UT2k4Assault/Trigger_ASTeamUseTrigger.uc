//=============================================================================
// Trigger_ASTeamUseTrigger: if a player stands within proximity of this trigger, and hits Use, 
// it will send Trigger/UnTrigger to actors whose names match 'EventName'.
//=============================================================================

class Trigger_ASTeamUseTrigger extends Triggers;

var()	enum AT_AssaultTeam
{
	AT_All,
	AT_Attackers,
	AT_Defenders,
} AssaultTeam;

var() localized string Message;

function bool SelfTriggered()
{
	return true;
}

function UsedBy( Pawn user )
{
	TriggerEvent(Event, self, user);
}

function Touch( Actor Other )
{
	if ( Pawn(Other) != None && ApprovePlayerTeam( Pawn(Other).GetTeamNum() ) )
	{
	    // Send a string message to the toucher.
	    if( Message != "" )
		    Pawn(Other).ClientMessage( Message );

		if ( AIController(Pawn(Other).Controller) != None )
			UsedBy(Pawn(Other));
	}
}

// Check if a Team is valid
function bool ApprovePlayerTeam(byte Team)
{
	if ( AssaultTeam == AT_All )
		return true;

	if ( Level.Game.IsA('ASGameInfo') )
	{
		if ( AssaultTeam == AT_Attackers ) { 
			if ( ASGameInfo(Level.Game).IsAttackingTeam(Team) ) return true; }
		else if ( !ASGameInfo(Level.Game).IsAttackingTeam(Team) ) return true;
	}	

	return false;
}

defaultproperties
{
}
