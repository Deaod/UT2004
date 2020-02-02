//=============================================================================
// ASVehicleFactory_Turret
// Specific factory for ASTurret (MotherShip Energy turrets)
//=============================================================================

class ASVehicleFactory_Turret extends ASVehicleFactory;

var	Array<Trigger_ASUseAndPossess>	VTarray;

function PostBeginPlay()
{
	local Trigger_ASUseAndPossess	VT;

	super.PostBeginPlay();

	// Cache triggers used to possess Turret
	foreach DynamicActors(class'Trigger_ASUseAndPossess', VT)
	{
		if ( VT.PawnTag == VehicleTag )
			VTarray[VTarray.Length] = VT;
	}
}

function VehicleSpawned()
{
	local int	i;

	super.VehicleSpawned();

	// Assigned EntryTriggers to Turret...
	if ( VTarray.Length > 0 )
		for (i=0; i<VTarray.Length; i++)
		{
			ASTurret(Child).EntryTriggers[ASTurret(Child).EntryTriggers.Length] = VTarray[i];
			VTarray[i].VehicleSpawned();	// Spawned event to possess triggers...
		}
}

event VehicleDestroyed(Vehicle V)
{
	local int	i;

	super.VehicleDestroyed( V );

	// Send destroyed events to possess triggers...
	if ( VTarray.Length > 0 )
		for (i=0; i<VTarray.Length; i++)
			VTarray[i].VehicleDestroyed();
}

event VehicleUnPossessed( Vehicle V )
{
	local int	i;

	super.VehicleUnPossessed( V );

	// Send UnPossessed events to possess triggers...
	if ( VTarray.Length > 0 )
		for (i=0; i<VTarray.Length; i++)
			VTarray[i].VehicleUnPossessed();
}

event VehiclePossessed( Vehicle V )
{
	local int	i;

	super.VehiclePossessed( V );

	// Send UnPossessed events to possess triggers...
	if ( VTarray.Length > 0 )
		for (i=0; i<VTarray.Length; i++)
			VTarray[i].VehiclePossessed();
}


event PrevVehicle( Vehicle V )
{
	local int	i;

	if ( VTarray.Length > 0 )
		for (i=0; i<VTarray.Length; i++)
		{
			VTarray[i].PrevVehicle( Self, V );
			break;
		}
}

event NextVehicle( Vehicle V )
{
	local int	i;

	if ( VTarray.Length > 0 )
		for (i=0; i<VTarray.Length; i++)
		{
			VTarray[i].NextVehicle( Self, V );
			break;
		}
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     bSpawnBuildEffect=False
     VehicleClassStr="UT2k4AssaultFull.ASTurret_BallTurret"
     AIVisibilityDist=25000.000000
     VehicleClass=None
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'AS_Weapons_SM.Turret.ASTurret_Editor'
     DrawScale=5.000000
     AmbientGlow=96
     bEdShouldSnap=True
}
