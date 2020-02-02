#exec OBJ LOAD FILE=VehicleFX.utx

class BulldogHeadlight extends DynamicProjector;

// Empty tick here - do detach/attach in Bulldog tick
function Tick(float Delta)
{

}

defaultproperties
{
     FrameBufferBlendingOp=PB_Add
     ProjTexture=Texture'VehicleFX.Projected.BullHeadlights'
     FOV=30
     MaxTraceDistance=2048
     bClipBSP=True
     bProjectOnUnlit=True
     bGradient=True
     bProjectOnAlpha=True
     bProjectOnParallelBSP=True
     bLightChanged=True
     DrawScale=0.650000
     bHardAttach=True
}
