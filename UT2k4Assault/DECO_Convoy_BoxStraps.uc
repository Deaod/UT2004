class DECO_Convoy_BoxStraps extends Decoration;

#exec MESH IMPORT MESH=Convoy_BoxStraps ANIVFILE=Models\BoxStraps_a.3d DATAFILE=Models\BoxStraps_d.3d
#exec MESH ORIGIN MESH=Convoy_BoxStraps X=0 Y=0 Z=0 PITCH=0 YAW=0 ROLL=0
#exec MESH LODPARAMS MESH=Convoy_BoxStraps STRENGTH=0.5
#exec MESH SEQUENCE MESH=Convoy_BoxStraps SEQ=Wind       STARTFRAME=0   NUMFRAMES=9

#exec MESHMAP SCALE MESHMAP=Convoy_BoxStraps X=1 Y=1 Z=1


#exec MESH IMPORT MESH=Convoy_LargeStrap ANIVFILE=Models\LargeStrap_a.3d DATAFILE=Models\LargeStrap_d.3d
#exec MESH ORIGIN MESH=Convoy_LargeStrap X=0 Y=0 Z=0 PITCH=0 YAW=0 ROLL=0
#exec MESH LODPARAMS MESH=Convoy_LargeStrap STRENGTH=0.5
#exec MESH SEQUENCE MESH=Convoy_LargeStrap SEQ=Wind       STARTFRAME=0   NUMFRAMES=9

#exec MESHMAP SCALE MESHMAP=Convoy_LargeStrap X=1 Y=1 Z=1


#exec MESH IMPORT MESH=Convoy_LrgRoundStrap ANIVFILE=Models\LrgRoundStrap_a.3d DATAFILE=Models\LrgRoundStrap_d.3d
#exec MESH ORIGIN MESH=Convoy_LrgRoundStrap X=0 Y=0 Z=0 PITCH=0 YAW=0 ROLL=0
#exec MESH LODPARAMS MESH=Convoy_LrgRoundStrap STRENGTH=0.5
#exec MESH SEQUENCE MESH=Convoy_LrgRoundStrap SEQ=Wind       STARTFRAME=0   NUMFRAMES=9

#exec MESHMAP SCALE MESHMAP=Convoy_LrgRoundStrap X=1 Y=1 Z=1


#exec MESH IMPORT MESH=Convoy_MediumStrap ANIVFILE=Models\MediumStrap_a.3d DATAFILE=Models\MediumStrap_d.3d
#exec MESH ORIGIN MESH=Convoy_MediumStrap X=0 Y=0 Z=0 PITCH=0 YAW=0 ROLL=0
#exec MESH LODPARAMS MESH=Convoy_MediumStrap STRENGTH=0.5
#exec MESH SEQUENCE MESH=Convoy_MediumStrap SEQ=Wind       STARTFRAME=0   NUMFRAMES=9

#exec MESHMAP SCALE MESHMAP=Convoy_MediumStrap X=1 Y=1 Z=1


#exec MESH IMPORT MESH=Convoy_MedRoundStrap ANIVFILE=Models\MedRoundStrap_a.3d DATAFILE=Models\MedRoundStrap_d.3d
#exec MESH ORIGIN MESH=Convoy_MedRoundStrap X=0 Y=0 Z=0 PITCH=0 YAW=0 ROLL=0
#exec MESH LODPARAMS MESH=Convoy_MedRoundStrap STRENGTH=0.5
#exec MESH SEQUENCE MESH=Convoy_MedRoundStrap SEQ=Wind       STARTFRAME=0   NUMFRAMES=9

#exec MESHMAP SCALE MESHMAP=Convoy_MedRoundStrap X=1 Y=1 Z=1


#exec MESH IMPORT MESH=Convoy_SmRoundStrap ANIVFILE=Models\SmRoundStrap_a.3d DATAFILE=Models\SmRoundStrap_d.3d
#exec MESH ORIGIN MESH=Convoy_SmRoundStrap X=0 Y=0 Z=0 PITCH=0 YAW=0 ROLL=0
#exec MESH LODPARAMS MESH=Convoy_SmRoundStrap STRENGTH=0.5

#exec MESH SEQUENCE MESH=Convoy_SmRoundStrap SEQ=Wind       STARTFRAME=0   NUMFRAMES=9

#exec MESHMAP SCALE MESHMAP=Convoy_SmRoundStrap X=1 Y=1 Z=1


simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	LoopAnim('Wind', 1.0, 0.1);
}

/*
simulated function AnimEnd(int Channel)
{
	PlayAnim('Wind', 1.0, 0.1);
}
*/
//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     bStatic=False
     bNoDelete=True
     RemoteRole=ROLE_None
     Mesh=VertMesh'UT2k4Assault.Convoy_BoxStraps'
     Skins(0)=Texture'AS_Vehicles_TX.Decos.PC_StrapSkin'
     AmbientGlow=48
     bMovable=False
     bCanBeDamaged=False
     bShouldBaseAtStartup=False
     bEdShouldSnap=True
}
