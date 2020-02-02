class VolumeTrigger extends Triggers;

event Trigger( Actor Other, Pawn EventInstigator )
{
    local Volume V;
    
	if ( Role < Role_Authority )
		return;
    
	ForEach AllActors(class'Volume', V, Event)
		V.Trigger(Other, EventInstigator);
}

defaultproperties
{
     bCollideActors=False
}
