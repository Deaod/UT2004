class ACTION_FireWeaponAt extends ScriptedAction;

var(Action) name ShootTargetTag;
var Actor ShootTarget;

function bool InitActionFor(ScriptedController C)
{
	if ( ShootTarget == None )
	{
		ForEach C.AllActors(class'Actor',ShootTarget,ShootTargetTag)
			break;
	}
	if ( ShootTarget != None )
		C.FireWeaponAt(ShootTarget);
	return false;	
}

defaultproperties
{
     ActionString="fire weapon"
}
