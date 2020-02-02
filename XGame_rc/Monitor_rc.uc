class Monitor_rc extends Resource;

#exec OBJ LOAD FILE=XGameTextures.utx

// monitor A
#exec STATICMESH IMPORT NAME=MonitorAMesh FILE=Models\MonitorA.lwo
#exec STATICMESH SETPROJECTION MESH=MonitorAMesh AREAID=0

// monitor B
#exec STATICMESH IMPORT NAME=MonitorBMesh FILE=Models\MonitorB.lwo
#exec STATICMESH SETPROJECTION MESH=MonitorBMesh AREAID=0

// monitor C
#exec STATICMESH IMPORT NAME=MonitorCMesh FILE=Models\MonitorC.lwo
#exec STATICMESH SETPROJECTION MESH=MonitorCMesh AREAID=0

// monitor D
#exec STATICMESH IMPORT NAME=MonitorDMesh FILE=Models\MonitorD.lwo
#exec STATICMESH SETPROJECTION MESH=MonitorDMesh AREAID=0

defaultproperties
{
}
