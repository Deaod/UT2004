//=============================================================================
// HealthCharger.
//=============================================================================
class HealthCharger extends xPickupBase;

#exec OBJ LOAD FILE=2k4ChargerMeshes.usx

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetLocation(Location + vect(0,0,-4)); // adjust because reduced drawscale
}

defaultproperties
{
     PowerUp=Class'XPickups.HealthPack'
     SpawnHeight=45.000000
     NewStaticMesh=StaticMesh'2k4ChargerMeshes.ChargerMeshes.HealthChargerMESH-DS'
     NewPrePivot=(Z=2.500000)
     NewDrawScale=0.450000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'XGame_rc.HealthChargerMesh'
     Texture=None
     DrawScale=0.500000
}
