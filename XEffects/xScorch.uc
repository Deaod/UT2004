//=============================================================================
// xscorch
//=============================================================================
class xScorch extends Projector
	abstract;

var() float Lifetime;
var() float PushBack;
var() bool  RandomOrient;

event PreBeginPlay()
{
	local PlayerController PC;

    if ( (Level.NetMode == NM_DedicatedServer) || (Level.DecalStayScale == 0.f) )
    {
        Destroy();
        return;
    }
	PC = Level.GetLocalPlayerController();
	if ( PC.BeyondViewDistance(Location, CullDistance) )
    {
        Destroy();
        return;
    }

	Super.PreBeginPlay();
}

function PostBeginPlay()
{
    local Vector RX, RY, RZ;
    local Rotator R;

	if ( PhysicsVolume.bNoDecals )
	{
		Destroy();
		return;
	}
    if( RandomOrient )
    {
        R.Yaw = 0;
        R.Pitch = 0;
        R.Roll = Rand(65535);
        GetAxes(R,RX,RY,RZ);
        RX = RX >> Rotation;
        RY = RY >> Rotation;
        RZ = RZ >> Rotation;
        R = OrthoRotation(RX,RY,RZ);
        SetRotation(R);
    }
    SetLocation( Location - Vector(Rotation)*PushBack );
    Super.PostBeginPlay();

    Lifespan = FMax(0.5, LifeSpan + (Rand(4) - 2));

    if ( Level.bDropDetail )
		LifeSpan *= 0.5;
    AbandonProjector(LifeSpan*Level.DecalStayScale);
    Destroy();
}

defaultproperties
{
     PushBack=24.000000
     RandomOrient=True
     FOV=1
     MaxTraceDistance=60
     bProjectActor=False
     bClipBSP=True
     FadeInTime=0.125000
     GradientTexture=Texture'Engine.GRADIENT_Clip'
     bStatic=False
     LifeSpan=8.000000
     bGameRelevant=True
}
