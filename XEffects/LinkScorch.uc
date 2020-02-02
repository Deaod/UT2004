class LinkScorch extends xScorch;

#exec TEXTURE IMPORT NAME=LBScorcht FILE=TEXTURES\DECALS\LinkBoltDecal.tga LODSET=2 Alpha=1 MODULATED=1 UCLAMPMODE=CLAMP VCLAMPMODE=CLAMP

defaultproperties
{
     ProjTexture=Texture'XEffects.rocketblastmark'
     CullDistance=4000.000000
     LifeSpan=1.000000
     DrawScale=0.400000
}
