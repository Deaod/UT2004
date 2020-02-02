//=============================================================================
// DecorationList:  Defines a list of decorations which can be attached to volumes
//=============================================================================

class DecorationList extends KeyPoint
	placeable
	native;

#exec Texture Import File=Textures\DecorationList.pcx Name=S_DecorationList Mips=Off MASKED=1

struct DecorationType
{
	var() StaticMesh	StaticMesh;
	var() range			Count;
	var() range			DrawScale;
	var() int			bAlign;
	var() int			bRandomPitch;
	var() int			bRandomYaw;
	var() int			bRandomRoll;
};

var(List) array<DecorationType> Decorations;

defaultproperties
{
     Texture=Texture'Engine.S_DecorationList'
}
