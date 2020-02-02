//=============================================================================
// HealthPack_rc
//=============================================================================
class HealthPack_rc extends Resource;

#exec OBJ LOAD FILE=XGameTextures.utx
#exec STATICMESH IMPORT NAME=HealthPack FILE=Models\Health1M.lwo COLLISION=0
#exec STATICMESH IMPORT NAME=MiniHealthPack FILE=Models\MiniHealth.lwo COLLISION=0

defaultproperties
{
}
