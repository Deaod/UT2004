//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSPRVSideGunPawn extends ONSWeaponPawn;

function bool StopWeaponFiring()
{
	if ( bWeaponIsAltFiring && (Bot(Controller) != None) )
	{
		Gun.CalcWeaponFire();
		Gun.AltFire(Controller);
	}
	return Super.StopWeaponFiring();
}

defaultproperties
{
     GunClass=Class'Onslaught.ONSPRVSideGun'
     ExitPositions(0)=(Y=165.000000,Z=100.000000)
     ExitPositions(1)=(Y=-165.000000,Z=100.000000)
     ExitPositions(2)=(Y=165.000000,Z=-100.000000)
     ExitPositions(3)=(Y=-165.000000,Z=-100.000000)
     EntryPosition=(X=40.000000,Y=50.000000,Z=-100.000000)
     EntryRadius=170.000000
     FPCamPos=(Z=20.000000)
     TPCamDistance=150.000000
     TPCamLookat=(X=0.000000,Z=50.000000)
     DriverDamageMult=0.400000
     VehiclePositionString="in a HellBender's side turret"
     VehicleNameString="HellBender Side Turret"
}
