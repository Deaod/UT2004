class RedirectionTrigger extends Triggers;

var() name RedirectionEvent;

function Trigger( actor Other, pawn EventInstigator )
{
	local Pawn P;

	ForEach DynamicActors(class'Pawn',P,Event)
	{
		if ( P.Health > 0 )
			P.TriggerEvent(RedirectionEvent,self,P);
	}
}

defaultproperties
{
     bCollideActors=False
}
