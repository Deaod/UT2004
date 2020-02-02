//=============================================================================
// A camera, used in UnrealEd.
//=============================================================================
class Camera extends PlayerController
	native;

// Sprite.
#exec Texture Import File=Textures\S_Camera.pcx Name=S_Camera Mips=Off MASKED=1

defaultproperties
{
     LightBrightness=100.000000
     LightRadius=16.000000
     Location=(X=-500.000000,Y=-300.000000,Z=300.000000)
     Texture=Texture'Engine.S_Camera'
     CollisionRadius=16.000000
     CollisionHeight=39.000000
     bDirectional=True
}
