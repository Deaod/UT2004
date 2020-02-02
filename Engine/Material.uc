//=============================================================================
// Material: Abstract material class
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Material extends Object
	native
	hidecategories(Object)
	collapsecategories
	noexport;

#exec Texture Import File=Textures\DefaultTexture.pcx

var() Material FallbackMaterial;
var Material DefaultMaterial;
var const transient bool UseFallback;	// Render device should use the fallback.
var const transient bool Validated;		// Material has been validated as renderable.

// sjs ---
var() enum ESurfaceTypes
{
	EST_Default,
	EST_Rock,
	EST_Dirt,
	EST_Metal,
	EST_Wood,
	EST_Plant,
	EST_Flesh,
    EST_Ice,
    EST_Snow,
    EST_Water,
    EST_Glass,
    EST_Custom00,
    EST_Custom01,
    EST_Custom02,
    EST_Custom03,
    EST_Custom04,
    EST_Custom05,
    EST_Custom06,
    EST_Custom07,
    EST_Custom08,
    EST_Custom09,
    EST_Custom10,
    EST_Custom11,
    EST_Custom12,
    EST_Custom13,
    EST_Custom14,
    EST_Custom15,
    EST_Custom16,
    EST_Custom17,
    EST_Custom18,
    EST_Custom19,
    EST_Custom20,
    EST_Custom21,
    EST_Custom22,
    EST_Custom23,
    EST_Custom24,
    EST_Custom25,
    EST_Custom26,
    EST_Custom27,
    EST_Custom28,
    EST_Custom29,
    EST_Custom30,
    EST_Custom31,
} SurfaceType;
// --- sjs

var int MaterialType;					// Material type flag - allows faster Cast<>

function Reset()
{
	if( FallbackMaterial != None )
		FallbackMaterial.Reset();
}

function Trigger( Actor Other, Actor EventInstigator )
{
	if( FallbackMaterial != None )
		FallbackMaterial.Trigger( Other, EventInstigator );
}

native function int MaterialUSize();
native function int MaterialVSize();

defaultproperties
{
     DefaultMaterial=Texture'Engine.DefaultTexture'
}
