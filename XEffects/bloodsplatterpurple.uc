class BloodSplatterPurple extends xScorch;

var texture Splats[3];

simulated function PostBeginPlay()
{
    ProjTexture = splats[Rand(3)];
    Super.PostBeginPlay();
}

defaultproperties
{
     Splats(0)=Texture'XEffects.BloodSplat1P'
     Splats(1)=Texture'XEffects.BloodSplat2P'
     Splats(2)=Texture'XEffects.BloodSplat3P'
     ProjTexture=Texture'XEffects.BloodSplat1P'
     FOV=6
     bClipStaticMesh=True
     CullDistance=7000.000000
     LifeSpan=5.000000
}
