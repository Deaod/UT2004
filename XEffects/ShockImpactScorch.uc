class ShockImpactScorch extends xScorch;

#exec TEXTURE IMPORT NAME=ShockHeatDecal FILE=TEXTURES\DECALS\ShockHeatDecal.tga LODSET=2 ADDITIVE=1 UCLAMPMODE=CLAMP VCLAMPMODE=CLAMP

defaultproperties
{
     FrameBufferBlendingOp=PB_Add
     ProjTexture=Texture'XEffects.ShockHeatDecal'
     CullDistance=7000.000000
     LifeSpan=2.200000
     DrawScale=0.500000
}
