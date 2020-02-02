//=============================================================================
// FlyingPathNode
// Useful for flying or swimming
//=============================================================================

#exec Texture Import File=Textures\FlyingApple.tga Name=S_FlyingPath Mips=Off MASKED=1

class FlyingPathNode extends PathNode
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

defaultproperties
{
     bNoAutoConnect=True
     bFlyingPreferred=True
     bVehicleDestination=True
     Texture=Texture'Engine.S_FlyingPath'
     DrawScale=0.400000
}
