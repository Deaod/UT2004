//=============================================================================
// The light class.
//=============================================================================
class Light extends Actor
	placeable
	native;

#exec Texture Import File=Textures\S_Light.pcx  Name=S_Light Mips=Off MASKED=1

var (Corona)	float	MinCoronaSize;
var (Corona)	float	MaxCoronaSize;
var (Corona)	float	CoronaRotation;
var (Corona)	float	CoronaRotationOffset;
var (Corona)	bool	UseOwnFinalBlend;

defaultproperties
{
     MaxCoronaSize=1000.000000
     LightType=LT_Steady
     LightSaturation=255
     LightBrightness=64.000000
     LightRadius=64.000000
     LightPeriod=32
     LightCone=128
     bStatic=True
     bHidden=True
     bNoDelete=True
     Texture=Texture'Engine.S_Light'
     bMovable=False
     CollisionRadius=24.000000
     CollisionHeight=24.000000
}
