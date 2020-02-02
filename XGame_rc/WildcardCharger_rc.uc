class WildcardCharger_rc extends Resource;

#exec OBJ LOAD FILE=XGameTextures.utx

#exec STATICMESH IMPORT NAME=WildcardChargerMesh FILE=Models\WildcardCharger.lwo COLLISION=0
#exec STATICMESH IMPORT NAME=HealthChargerMesh FILE=Models\HealthCharger.lwo COLLISION=0
#exec STATICMESH IMPORT NAME=ShieldChargerMesh FILE=Models\ShieldCharger.lwo COLLISION=0
#exec STATICMESH IMPORT NAME=AmmoChargerMesh FILE=Models\AmmoCharger.lwo COLLISION=0

defaultproperties
{
}
