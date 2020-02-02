//=============================================================================
// SubActionSceneSpeed:
//
// Alters the speed of the scene without affecting the engine speed.
//=============================================================================
class SubActionSceneSpeed extends MatSubAction
	native;

var(SceneSpeed)	range	SceneSpeed;

defaultproperties
{
     Icon=Texture'Engine.SubActionSceneSpeed'
     Desc="Scene Speed"
}
