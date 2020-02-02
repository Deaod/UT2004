//=============================================================================
// KVehicle spawner location.
//=============================================================================

class KVehicleFactory extends SVehicleFactory 
	placeable;

#exec Texture Import File=Textures\S_KVehFact.pcx Name=S_KVehFact Mips=Off MASKED=1

var()	class<KVehicle>		KVehicleClass;

event Trigger( Actor Other, Pawn EventInstigator )
{
	local KVehicle CreatedVehicle;

	if ( VehicleCount >= MaxVehicleCount )
		return;

	if ( KVehicleClass != None )
	{
		CreatedVehicle = Spawn(KVehicleClass, , , Location, Rotation);
		if ( CreatedVehicle != None )
		{
			VehicleCount++;
			CreatedVehicle.ParentFactory = Self;
		}
	}
}

defaultproperties
{
}
