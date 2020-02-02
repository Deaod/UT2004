//UT2004 health base with new staticmesh
//to automatically convert all HealthChargers in a level to have this mesh, use the editor console command "NewPickupBases"
class NewHealthCharger extends HealthCharger;

defaultproperties
{
     StaticMesh=StaticMesh'2k4ChargerMeshes.ChargerMeshes.HealthChargerMESH-DS'
     DrawScale=0.450000
     PrePivot=(Z=2.500000)
}
