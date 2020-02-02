//=============================================================================
// SuperHealthCharger.
//=============================================================================
class SuperHealthCharger extends xPickupBase;

#exec OBJ LOAD FILE=2k4ChargerMeshes.usx

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetLocation(Location + vect(0,0,-1)); // adjust because reduced drawscale
}

defaultproperties
{
     PowerUp=Class'XPickups.SuperHealthPack'
     SpawnHeight=60.000000
     bDelayedSpawn=True
     NewStaticMesh=StaticMesh'2k4ChargerMeshes.ChargerMeshes.HealthChargerMESH-DS'
     NewPrePivot=(Z=2.750000)
     NewDrawScale=0.700000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'XGame_rc.HealthChargerMesh'
     Texture=None
     DrawScale=0.800000
}
