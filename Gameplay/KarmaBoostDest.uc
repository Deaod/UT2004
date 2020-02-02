class KarmaBoostDest extends NavigationPoint
	placeable;

event int SpecialCost(Pawn Other, ReachSpec Path)
{
	if ( (Vehicle(Other) == None) || !Vehicle(Other).bCanDoTrickJumps )
		return 10000000;	

	return -0.5 * Path.Distance;
}

defaultproperties
{
     bSpecialForced=True
     bVehicleDestination=True
}
