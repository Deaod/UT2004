class ONSHeadlightProjector extends Projector
	native;

defaultproperties
{
     MaterialBlendingOp=PB_Modulate
     FrameBufferBlendingOp=PB_Add
     FOV=40
     MaxTraceDistance=2048
     bClipBSP=True
     bProjectOnUnlit=True
     bGradient=True
     bProjectOnAlpha=True
     bProjectOnParallelBSP=True
     bDynamicAttach=True
     bNoProjectOnOwner=True
     CullDistance=2000.000000
     bLightChanged=True
     bStatic=False
     bDetailAttachment=True
     DrawScale=0.650000
     bHardAttach=True
}
