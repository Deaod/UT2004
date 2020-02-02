class ACTION_HealActor extends ScriptedAction;

var(Action) name HealTag;
var(Action) int HealAmount;
var(Action) class<DamageType> DamageType;

function bool InitActionFor(ScriptedController C)
{
	local Actor a;

	if (HealTag != 'None')
		ForEach C.AllActors(class'Actor', a, HealTag)
			a.HealDamage(HealAmount, C, DamageType);

	return false;
}

defaultproperties
{
     ActionString="Heal actor"
}
