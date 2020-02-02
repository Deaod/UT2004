//=============================================================================
// ASVehicleFactory_Turret
// Specific factory for Ion Cannon
//=============================================================================

class ASVehicleFactory_IonCannon extends ASVehicleFactory;

#exec OBJ LOAD File=AnnouncerAssault.uax

var() name ObjectiveTag[6];

function VehicleSpawned()
{
	local ASTurret T;
	local int i;
	
	Super.VehicleSpawned();
	
	T = ASTurret(Child);
	if ( T == None )
		return;
		
	for ( i=0; i<6; i++ )
		T.ObjectiveTag[i] = ObjectiveTag[i];
}	

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     bVehicleTeamLock=True
     bSpawnBuildEffect=False
     Announcement_Destroyed=Sound'AnnouncerAssault.Generic.Ion_Cannon_destroyed'
     VehicleClass=Class'UT2k4AssaultFull.ASTurret_IonCannon'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'AS_Weapons_SM.Turret.IonCannonStatic'
     DrawScale=0.660000
     AmbientGlow=96
     CollisionRadius=200.000000
     CollisionHeight=300.000000
     bEdShouldSnap=True
}
