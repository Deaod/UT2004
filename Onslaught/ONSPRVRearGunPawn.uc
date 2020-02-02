//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSPRVRearGunPawn extends ONSWeaponPawn;

function AltFire(optional float F)
{
	local PlayerController PC;

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = true;
	PC.ToggleZoom();
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
	local PlayerController PC;

	if (!bWasAltFire)
	{
		Super.ClientVehicleCeaseFire(bWasAltFire);
		return;
	}

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = false;
	PC.StopZoom();
}

simulated function ClientKDriverLeave(PlayerController PC)
{
	Super.ClientKDriverLeave(PC);

	bWeaponIsAltFiring = false;
	PC.EndZoom();
}

defaultproperties
{
     GunClass=Class'Onslaught.ONSPRVRearGun'
     bHasAltFire=False
     CameraBone="REARgunTURRET"
     DrivePos=(X=-20.000000,Z=90.000000)
     ExitPositions(0)=(X=-235.000000)
     ExitPositions(1)=(Y=165.000000)
     ExitPositions(2)=(Y=-165.000000)
     ExitPositions(3)=(Z=100.000000)
     EntryPosition=(X=-50.000000)
     EntryRadius=160.000000
     FPCamViewOffset=(Z=40.000000)
     TPCamDistance=350.000000
     TPCamLookat=(X=0.000000)
     TPCamWorldOffset=(Z=50.000000)
     DriverDamageMult=0.600000
     VehiclePositionString="in a HellBender's rear turret"
     VehicleNameString="HellBender Rear Turret"
}
