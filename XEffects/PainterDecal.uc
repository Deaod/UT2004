class PainterDecal extends xScorch;

#exec TEXTURE IMPORT NAME=PainterDecalMark FILE=TEXTURES\DECALS\BoltImpact.tga Alpha=1 LODSET=2 DXT=5 UCLAMPMODE=CLAMP VCLAMPMODE=CLAMP

defaultproperties
{
     FrameBufferBlendingOp=PB_Add
     ProjTexture=Texture'XEffects.PainterDecalMark'
     LifeSpan=1.500000
     Style=STY_Additive
}
