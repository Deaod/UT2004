class DECO_ConvoyFlag extends Decoration;

#exec MESH IMPORT MESH=ConvoyFlag ANIVFILE=Models\Flag_a.3d DATAFILE=Models\Flag_d.3d
#exec MESH ORIGIN MESH=ConvoyFlag X=0 Y=0 Z=0 PITCH=0 YAW=0 ROLL=0

#exec MESH SEQUENCE MESH=ConvoyFlag SEQ=Flag       STARTFRAME=0   NUMFRAMES=10

#exec MESHMAP SCALE MESHMAP=ConvoyFlag X=1 Y=1 Z=1

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     RemoteRole=ROLE_None
     Mesh=VertMesh'UT2k4Assault.ConvoyFlag'
     DrawScale=10.000000
     AmbientGlow=48
     bCanBeDamaged=False
     bShouldBaseAtStartup=False
     bEdShouldSnap=True
}
