class BulletDecal extends xScorch;

#exec TEXTURE IMPORT NAME=bulletpock FILE=TEXTURES\pock.tga LODSET=2 MODULATED=1 UCLAMPMODE=CLAMP VCLAMPMODE=CLAMP

function PostBeginPlay()
{
	if ( FRand() < 0.75 )
		LifeSpan *= 0.5;
	Super.PostBeginPlay();
}

defaultproperties
{
     RandomOrient=False
     ProjTexture=Texture'XEffects.bulletpock'
     bClipStaticMesh=True
     CullDistance=3000.000000
     bHighDetail=True
     LifeSpan=3.200000
     DrawScale=0.180000
}
