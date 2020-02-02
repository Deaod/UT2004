//=============================================================================
// RoadPathNode
// Useful for vehicles, particularly on terrain
//=============================================================================

#exec Texture Import File=Textures\Road.tga Name=S_RoadPath Mips=Off MASKED=1

class RoadPathNode extends PathNode
	native;

var() float MaxRoadDist;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

defaultproperties
{
     MaxRoadDist=10000.000000
     bVehicleDestination=True
     Texture=Texture'Engine.S_RoadPath'
     DrawScale=0.400000
}
