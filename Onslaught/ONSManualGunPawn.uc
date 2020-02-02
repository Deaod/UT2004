//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSManualGunPawn extends ONSStationaryWeaponPawn;

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx

simulated function ActivateOverlay(bool bActive)
{
	if (Controller==None)
		return;

    Super.ActivateOverlay(bActive);
    if (Gun != None)
    {
        if (bActive)
            Gun.SetBoneScale(4, 0.0, 'TurretCockpit');
        else
            Gun.SetBoneScale(4, 1.0, 'TurretCockpit');
    }
}

defaultproperties
{
     GunClass=Class'Onslaught.ONSManualGun'
     CameraBone="TurretCockpit"
     DrivePos=(X=-50.000000,Z=48.000000)
     EntryRadius=175.000000
     FPCamPos=(X=-27.000000,Z=26.000000)
     TPCamDistance=450.000000
     TPCamLookat=(X=-200.000000,Z=220.000000)
     DriverDamageMult=0.000000
     HUDOverlayClass=Class'Onslaught.ONSManualGunOverlay'
     HUDOverlayOffset=(X=60.000000,Z=-25.000000)
     HUDOverlayFOV=45.000000
     HealthMax=450.000000
     Health=450
     StaticMesh=StaticMesh'ONSDeadVehicles-SM.MANUALbaseGunDEAD'
     Mesh=SkeletalMesh'ONSWeapons-A.NewManualGun'
     bPathColliding=True
}
