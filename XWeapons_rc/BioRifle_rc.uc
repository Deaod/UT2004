class BioRifle_rc extends Resource;

#exec OBJ LOAD FILE=WeaponSkins.utx

// goop //
#exec MESH      IMPORT      MESH=GoopMesh ANIVFILE=MODELS\Goop_a.3D DATAFILE=MODELS\Goop_d.3D X=0 Y=0 Z=0
#exec MESH      ORIGIN      MESH=GoopMesh X=0 Y=0 Z=30 YAW=0 PITCH=-64 ROLL=0
#exec MESH      SEQUENCE    MESH=GoopMesh SEQ=Flying  STARTFRAME=3   NUMFRAMES=11
#exec MESH      SEQUENCE    MESH=GoopMesh SEQ=Hit     STARTFRAME=20  NUMFRAMES=18
#exec MESH      SEQUENCE    MESH=GoopMesh SEQ=Drip    STARTFRAME=40  NUMFRAMES=39
#exec MESH      SEQUENCE    MESH=GoopMesh SEQ=Slide   STARTFRAME=83  NUMFRAMES=39
#exec MESH      SEQUENCE    MESH=GoopMesh SEQ=Shrivel STARTFRAME=126  NUMFRAMES=9
#exec MESHMAP   SCALE       MESHMAP=GoopMesh X=0.04 Y=0.04 Z=0.08

defaultproperties
{
}
