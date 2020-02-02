// ====================================================================
//  Class:  XGame.xIntroPawn
//  Parent: UnrealGame.UnrealPawn
//
//  These pawns are used in the intro sequence.
// ====================================================================

class xIntroPawn extends UnrealPawn;

var ShadowProjector PawnShadow;

var() vector ShadowDirection;
var() byte ShadowDarkness;
var() string MeshNameString;

function AddDefaultInventory();	// Override

simulated function Destroyed()
{
    if( PawnShadow != None )
        PawnShadow.Destroy();

    Super.Destroyed();
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

	if ( (Mesh == None) && (MeshNameString != "") )
		LinkMesh(mesh(DynamicLoadObject(MeshNameString,class'Mesh')));
	
	if(bShadowCast)
	{
		PawnShadow = Spawn(class'ShadowProjector',Self,'',Location);
		PawnShadow.ShadowActor = self;
		PawnShadow.RootMotion = True;
		PawnShadow.LightDirection = Normal(ShadowDirection);
		PawnShadow.LightDistance = 192;
		PawnShadow.MaxTraceDistance = 350;
		PawnShadow.InitShadow();
		PawnShadow.ShadowTexture.ShadowDarkness = ShadowDarkness;
	}
}

defaultproperties
{
     ShadowDirection=(X=1.000000,Y=1.000000,Z=5.000000)
     ShadowDarkness=192
     BaseEyeHeight=38.000000
     EyeHeight=38.000000
     ControllerClass=None
     bLightingVisibility=False
     MaxLights=8
     CollisionRadius=25.000000
     CollisionHeight=43.000000
}
