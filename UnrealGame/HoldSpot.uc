class HoldSpot extends UnrealScriptedSequence
	notplaceable;

var vehicle HoldVehicle;


function Actor GetMoveTarget()
{
	if ( HoldVehicle != None )
	{
		if ( HoldVehicle.Health <= 0 )
			HoldVehicle = None;
		if ( HoldVehicle != None )
			return HoldVehicle.GetMoveTargetFor(None);
	}
	
	return self;
}

function FreeScript()
{
	Destroy();
}

defaultproperties
{
     bStatic=False
     bCollideWhenPlacing=False
}
