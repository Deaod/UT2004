//UT2004 weapon base with new staticmesh
//to automatically convert all xWeaponBases in a level to have this mesh, use the editor console command "NewPickupBases"
class NewWeaponBase extends xWeaponBase;

defaultproperties
{
     StaticMesh=StaticMesh'2k4ChargerMeshes.ChargerMeshes.WeaponChargerMesh-DS'
     PrePivot=(Z=3.700000)
}
