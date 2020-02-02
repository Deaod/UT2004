class BodyEffect extends Effects;

var class<DamageType> DamageType;
var vector HitLoc;

function PostBeginPlay()
{
	local ColorModifier Alpha;
	local float frame, rate;
    local name seq;

	Super.PostBeginPlay();
	LinkMesh(Owner.Mesh);
	Owner.GetAnimParams( 0, seq, frame, rate );
	PlayAnim(seq, 0, 0);
	SetAnimFrame(frame);
	StopAnimating();
	Alpha = ColorModifier(Level.ObjectPool.AllocateObject(class'ColorModifier'));
	Alpha.Material = Skins[0];
	Alpha.AlphaBlend = true;
	Alpha.RenderTwoSided = true;
	Alpha.Color.A = 128;
	Skins[0] = Alpha;
	Skins[1] = Alpha;
	Skins[2] = Alpha;
}

simulated function Tick(float deltaTime)
{
	SetDrawScale(DrawScale * (1 + 0.5*DeltaTime));
	ColorModifier(Skins[0]).Color.A = int(128.f * (LifeSpan / default.LifeSpan));
}

simulated function Destroyed()
{
	if ( xPawn(Owner) != None )
	{
		xPawn(Owner).bFrozenBody = false;
		xPawn(Owner).PlayDyingAnimation(DamageType, HitLoc);
	}
	Level.ObjectPool.FreeObject(Skins[0]);
	Skins[0] = None;
	Skins[1] = None;
	Skins[2] = None;
	Super.Destroyed();
}

defaultproperties
{
     DrawType=DT_Mesh
     LifeSpan=0.650000
     Skins(0)=Shader'XGameShaders.PlayerShaders.LinkHit'
     Skins(1)=Shader'XGameShaders.PlayerShaders.LinkHit'
     Skins(2)=Shader'XGameShaders.PlayerShaders.LinkHit'
}
