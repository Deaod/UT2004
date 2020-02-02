class BulldogFactory extends KVehicleFactory;

event Trigger( Actor Other, Pawn EventInstigator )
{
	local KVehicle CreatedVehicle;

	if(EventInstigator.IsA('Vehicle'))
		return;

	if(VehicleCount >= MaxVehicleCount)
	{
		if(EventInstigator != None)
			EventInstigator.ReceiveLocalizedMessage(class'Vehicles.BulldogMessage', 2);
		return;
	}

	if( KVehicleClass != None )
	{
		CreatedVehicle = spawn(KVehicleClass, , , Location, Rotation);
		if ( CreatedVehicle != None )
		{
			VehicleCount++;
			CreatedVehicle.ParentFactory = self;
		}
		else log("Couldn't spawn Bulldog");
	}
}

defaultproperties
{
     KVehicleClass=Class'Vehicles.Bulldog'
}
