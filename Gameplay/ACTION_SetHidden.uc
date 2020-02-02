class ACTION_SetHidden extends ScriptedAction;

var(Action) bool bHidden;
var(Action) name HideActorTag;

var Array<Actor> Target;

event PostBeginPlay( ScriptedSequence SS )
{
	local Actor A;

	if ( HideActorTag != '' )
	{
		ForEach SS.AllActors(class'Actor', A, HideActorTag)
			Target[Target.Length] = A;
	}
}

function bool InitActionFor(ScriptedController C)
{
	local int i;

	if ( Target.Length > 0 )
	{
		For (i=0; i<Target.Length; i++)
			Target[i].bHidden = bHidden;
	}
	else
		C.GetInstigator().bHidden = bHidden;

	return false;	
}

defaultproperties
{
}
