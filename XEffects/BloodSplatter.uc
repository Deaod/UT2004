class BloodSplatter extends xScorch;

var texture Splats[3];

simulated function PostBeginPlay()
{
    ProjTexture = splats[Rand(3)];
    Super.PostBeginPlay();
}

defaultproperties
{
     Splats(0)=Texture'XEffects.BloodSplat1'
     Splats(1)=Texture'XEffects.BloodSplat2'
     Splats(2)=Texture'XEffects.BloodSplat3'
     ProjTexture=Texture'XEffects.BloodSplat1'
     FOV=6
     bClipStaticMesh=True
     CullDistance=7000.000000
     LifeSpan=5.000000
}
