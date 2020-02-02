//=============================================================================
// ASVehicleFactory_SentinelFloor
// Specific factory for Floor Sentinels
//=============================================================================

class ASVehicleFactory_SentinelFloor extends ASVehicleFactory;

var()	bool	bSpawnCampProtection;	// makes sentinels super strong

function VehicleSpawned()
{
	super.VehicleSpawned();
	ASVehicle_Sentinel(Child).bSpawnCampProtection = bSpawnCampProtection;
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     bSpawnCampProtection=True
     bSpawnBuildEffect=False
     VehicleLinkHealMult=0.150000
     VehicleClass=Class'UT2k4Assault.ASVehicle_Sentinel_Floor'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'AS_Weapons_SM.Turret.FloorTurretStaticEditor'
     DrawScale=0.500000
     PrePivot=(Z=150.000000)
     AmbientGlow=48
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bEdShouldSnap=True
}
