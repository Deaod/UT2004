class DominationPoint_rc extends Resource;

#exec OBJ LOAD FILE=XGameTextures.utx

#exec STATICMESH IMPORT NAME=DominationPointMesh FILE=Models\DominationPoint.lwo COLLISION=0

#exec STATICMESH IMPORT NAME=DomAMesh FILE=Models\A.lwo COLLISION=0
#exec STATICMESH IMPORT NAME=DomBMesh FILE=Models\B.lwo COLLISION=0
#exec STATICMESH IMPORT NAME=DomRing  FILE=Models\Ring.lwo COLLISION=0

defaultproperties
{
}
