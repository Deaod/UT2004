class ShockRifle_rc extends Resource;

// beam texture //
#exec TEXTURE   IMPORT      NAME=ShockBeamTex FILE=textures\shockbeampurple.tga GROUP=Effects LODSET=0 MIPS=0
#exec TEXTURE   IMPORT      NAME=ShockBeamRedTex FILE=textures\shockbeamred.tga GROUP=Effects LODSET=0 MIPS=0

// explosion emitter lifemap //
#exec TEXTURE   IMPORT      NAME=ShockLifeMap_t FILE=Textures\ShockBeamColorMap.PCX Mips=Off LODSET=0

#exec MESH      IMPORT      MESH=ShockCoreMesh      ANIVFILE=models\shock_core_elec_a.3d DATAFILE=models\shock_core_elec_d.3d
#exec MESH      ORIGIN      MESH=ShockCoreMesh      X=0 Y=0 Z=0 PITCH=0 YAW=0 ROLL=0
#exec MESHMAP   SCALE       MESHMAP=ShockCoreMesh   X=1.0 Y=1.0 Z=2.0

defaultproperties
{
}
