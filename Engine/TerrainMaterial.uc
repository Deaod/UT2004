class TerrainMaterial extends RenderedMaterial
	native
	noteditinlinenew;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

struct native TerrainMaterialLayer
{
	var material		Texture;
	var bitmapmaterial	AlphaWeight;
	var matrix			TextureMatrix;
};

var const array<TerrainMaterialLayer> Layers;
var const byte RenderMethod;
var const bool FirstPass;

defaultproperties
{
     MaterialType=256
}
