class Ball_rc extends Resource;

#exec OBJ LOAD FILE=XGameShaders.utx
#exec OBJ LOAD FILE=XGameTextures.utx

#exec STATICMESH IMPORT NAME=BombDeliveryMesh FILE=Models\BombGate.lwo
#exec STATICMESH IMPORT NAME=BombSpawnMesh FILE=Models\BombDelivery.lwo
#exec STATICMESH IMPORT NAME=BallMesh FILE=Models\Ball.lwo COLLISION=0
#exec STATICMESH IMPORT NAME=BombEffectMesh FILE=..\xeffects\Models\bombeffect.lwo COLLISION=0

defaultproperties
{
}
