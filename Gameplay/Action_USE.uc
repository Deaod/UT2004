class ACTION_Use extends ScriptedAction;

function bool InitActionFor(ScriptedController C)
{
    local Actor A;
	local Vehicle DrivenVehicle;

	C.bChangingPawns = true;
	DrivenVehicle = Vehicle(C.Pawn);
	if( DrivenVehicle != None )
	{
		DrivenVehicle.KDriverLeave(false);
		C.bChangingPawns = false;
		return false;
	}

    ForEach C.Pawn.VisibleCollidingActors(class'Vehicle', DrivenVehicle, 500)
    {
		DrivenVehicle.UsedBy(C.Pawn);
		C.bChangingPawns = false;
		return false;
    }

    // Send the 'DoUse' event to each actor player is touching.
    ForEach C.Pawn.TouchingActors(class'Actor', A)
        A.UsedBy(C.Pawn);

	if ( C.Pawn.Base != None )
		C.Pawn.Base.UsedBy( C.Pawn );

	C.bChangingPawns = false;
	return false;
}

defaultproperties
{
}
