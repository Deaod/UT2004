//=============================================================================
// ASVehicleFactory_SentinelCeiling
// Specific factory for Ceiling Sentinels
//=============================================================================

class ASVehicleFactory_SentinelCeiling extends ASVehicleFactory;

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
     VehicleClass=Class'UT2k4Assault.ASVehicle_Sentinel_Ceiling'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'AS_Weapons_SM.Turret.CeilingTurretEditor'
     DrawScale=0.500000
     PrePivot=(Z=-160.000000)
     AmbientGlow=48
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bEdShouldSnap=True
}
