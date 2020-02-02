class ACTION_FireWeapon extends ScriptedAction;

var(Action) bool bPressFire;
var(Action) bool bPressAltFire;

function bool InitActionFor(ScriptedController C)
{
	local vector ShootLoc;
	
	if ( (C.Pawn == None) || (C.Pawn.Weapon == None) )
		return false;

	if ( bPressFire )
	{
		if ( C.Pawn.Weapon.IsA('BallLauncher') )
		{
			if ( C.Target != None )
				ShootLoc = C.Target.Location;
			else
				ShootLoc = C.Pawn.Location + 1500 * vector(C.Pawn.Rotation);
			C.Pawn.Weapon.ShootHoop(C,ShootLoc);
		}
		else
		{
			C.Pawn.Weapon.StartFire(0);
			C.bFire = 1;
		}
	}
	else
	{
		C.Pawn.Weapon.StopFire(0);
		C.bFire = 0;
	}
	
	if ( bPressAltFire )
	{
		C.Pawn.Weapon.StartFire(1);
		C.bAltFire = 1;
	}
	else
	{
		C.Pawn.Weapon.StopFire(1);
		C.bAltFire = 0;
	}
	C.bFineWeaponControl = bPressFire || bPressAltFire;
	return false;	
}

defaultproperties
{
     ActionString="fire weapon"
}
