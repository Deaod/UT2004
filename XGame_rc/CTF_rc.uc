class CTF_rc extends Resource;

#exec OBJ LOAD FILE=XGameTextures.utx

// CTF Flag
#exec MESH IMPORT MESH=FlagMesh ANIVFILE=MODELS\flag_a.3d DATAFILE=MODELS\flag_d.3d
#exec MESH ORIGIN MESH=FlagMesh X=-0.0 Y=0.0 Z=-75.0 PITCH=0 YAW=0 ROLL=0
#exec MESH SEQUENCE MESH=FlagMesh SEQ=All   STARTFRAME=0   NUMFRAMES=255
#exec MESH SEQUENCE MESH=FlagMesh SEQ=Flag  STARTFRAME=0   NUMFRAMES=255
#exec MESHMAP SCALE MESHMAP=FlagMesh X=0.10 Y=0.10 Z=0.2

// CTF Flag Base
#exec STATICMESH IMPORT NAME=FlagBaseMesh FILE=Models\FlagBase.lwo COLLISION=0

defaultproperties
{
}
