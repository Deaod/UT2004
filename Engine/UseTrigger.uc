//=============================================================================
// UseTrigger: if a player stands within proximity of this trigger, and hits Use, 
// it will send Trigger/UnTrigger to actors whose names match 'EventName'.
//=============================================================================
class UseTrigger extends Triggers;

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
	if ( Pawn(Other) != None )
	{
	    // Send a string message to the toucher.
	    if( Message != "" )
		    Pawn(Other).ClientMessage( Message );

		if ( AIController(Pawn(Other).Controller) != None )
			UsedBy(Pawn(Other));
	}
}

defaultproperties
{
}
