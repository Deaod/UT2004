//=============================================================================
// banner.
//=============================================================================
class banner_rc extends Resource;

#exec MESH IMPORT MESH=banner ANIVFILE=MODELS\banner_a.3d DATAFILE=MODELS\banner_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=banner X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=banner SEQ=All    STARTFRAME=0 NUMFRAMES=169
#exec MESH SEQUENCE MESH=banner SEQ=banner STARTFRAME=0 NUMFRAMES=169

#exec OBJ LOAD FILE=SC_Volcano_T.utx

#exec MESHMAP NEW   MESHMAP=banner MESH=banner
#exec MESHMAP SCALE MESHMAP=banner X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=banner NUM=1 TEXTURE=SC_Volcano_T.Banners.SC_BannerRed_S

defaultproperties
{
}
