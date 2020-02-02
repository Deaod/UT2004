class ShadowProjector extends Projector;

var() Actor					ShadowActor;
var() vector				LightDirection;
var() float					LightDistance;
var() bool					RootMotion;
var() bool					bBlobShadow;
var() bool					bShadowActive;
var ShadowBitmapMaterial	ShadowTexture;

event PostBeginPlay()
{
	Super(Actor).PostBeginPlay();
}

event Destroyed()
{
	if(ShadowTexture != None)
	{
		ShadowTexture.ShadowActor = None;
		
		if(!ShadowTexture.Invalid)
			Level.ObjectPool.FreeObject(ShadowTexture);

		ShadowTexture = None;
		ProjTexture = None;
	}

	Super.Destroyed();
}

function InitShadow()
{
	local Plane		BoundingSphere;

	if(ShadowActor != None)
	{
		BoundingSphere = ShadowActor.GetRenderBoundingSphere();
		FOV = Atan(BoundingSphere.W * 2 + 160, LightDistance) * 180 / PI;

		ShadowTexture = ShadowBitmapMaterial(Level.ObjectPool.AllocateObject(class'ShadowBitmapMaterial'));
		ProjTexture = ShadowTexture;

		if(ShadowTexture != None)
		{
			SetDrawScale(LightDistance * tan(0.5 * FOV * PI / 180) / (0.5 * ShadowTexture.USize));

			ShadowTexture.Invalid = False;
			ShadowTexture.bBlobShadow = bBlobShadow;
			ShadowTexture.ShadowActor = ShadowActor;
			ShadowTexture.LightDirection = Normal(LightDirection);
			ShadowTexture.LightDistance = LightDistance;
			ShadowTexture.LightFOV = FOV;
			ShadowTexture.CullDistance = CullDistance; 
    
			Enable('Tick');
			UpdateShadow();
		}
		else
			Log(Name$".InitShadow: Failed to allocate texture");
	}
	else
		Log(Name$".InitShadow: No actor");
}

function UpdateShadow()
{
	local coords	C;

	DetachProjector(true);

	if( (ShadowActor != None) && !ShadowActor.bHidden && (Level.TimeSeconds - ShadowActor.LastRenderTime < 4) && (ShadowTexture != None) && bShadowActive )
	{
		if( ShadowTexture.Invalid )
			Destroy();
		else
		{
			if(RootMotion && ShadowActor.DrawType == DT_Mesh && ShadowActor.Mesh != None)
			{
				C = ShadowActor.GetBoneCoords('');
				SetLocation(C.Origin);
			}
			else
				SetLocation(ShadowActor.Location + vect(0,0,5));

			SetRotation(Rotator(Normal(-LightDirection)));

			ShadowTexture.Dirty = true;
	        
            AttachProjector();
		}
	}
}

function Tick(float DeltaTime)
{
	UpdateShadow();
}

defaultproperties
{
     bShadowActive=True
     bProjectActor=False
     bClipBSP=True
     bGradient=True
     bProjectOnAlpha=True
     bProjectOnParallelBSP=True
     bDynamicAttach=True
     CullDistance=1200.000000
     bStatic=False
     bOwnerNoSee=True
}
