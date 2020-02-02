class TeamBanner_rc extends Resource;
 
#exec MESH IMPORT MESH=TeamBannerMesh ANIVFILE=MODELS\TeamBanner_a.3D DATAFILE=MODELS\TeamBanner_d.3D X=0 Y=0 Z=0 LODSTYLE=3 
//#exec MESH ORIGIN MESH=TeamBannerMesh X=0.000000 Y=0.000000 Z=0.000000 PITCH=0 YAW=0 ROLL=0
#exec MESH SEQUENCE MESH=TeamBannerMesh SEQ=All       STARTFRAME=0   NUMFRAMES=169
#exec MESH SEQUENCE MESH=TeamBannerMesh SEQ=AnimFlag  STARTFRAME=0   NUMFRAMES=169
#exec MESHMAP SCALE MESHMAP=TeamBannerMesh X=0.1 Y=0.1 Z=0.2

defaultproperties
{
}
