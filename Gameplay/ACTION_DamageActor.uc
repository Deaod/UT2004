class ACTION_DamageActor extends ScriptedAction;

var(Action) name DamageTag;
var(Action) int DamageAmount;
var(Action) class<DamageType> DamageType;

function bool InitActionFor(ScriptedController C)
{
	local Actor a;

	if (DamageTag != 'None')
		ForEach C.AllActors(class'Actor', a, DamageTag)
			a.TakeDamage(DamageAmount, C.Pawn, a.Location, vect(0,0,0), DamageType);

	return false;
}

defaultproperties
{
     ActionString="Damage actor"
}
