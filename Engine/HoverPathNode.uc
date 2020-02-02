//-----------------------------------------------------------
//
//-----------------------------------------------------------
class HoverPathNode extends RoadPathNode
		native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

event int SpecialCost(Pawn Other, ReachSpec Path)
{
	if ( Other.bCanFly || (Vehicle(Other) != None && Vehicle(Other).bCanHover) )
		return 0;

	return 100000000;
}

defaultproperties
{
     bNotBased=True
     bSpecialForced=True
     bForcedOnly=True
     CollisionHeight=120.000000
}
