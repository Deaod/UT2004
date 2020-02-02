//=============================================================================
// FX_IonPlasmaTank_AimLaser
//=============================================================================
// Created by Laurent Delayen (C) 2003 Epic Games
//=============================================================================

class FX_IonPlasmaTank_AimLaser extends FX_Turret_IonCannon_LaserBeam;

var	ONSHoverTank_IonPlasma_Weapon	WeaponOwner;

replication
{
    unreliable if ( Role == ROLE_Authority && bNetInitial && bNetOwner )
        WeaponOwner;
}

simulated function SetWeaponOwner()
{
	WeaponOwner = ONSHoverTank_IonPlasma_Weapon(Owner);
}

simulated function UpdateBeamLocation()
{
	if ( WeaponOwner != None )
		WeaponOwner.UpdateLaserBeamLocation(StartLocation, EndLocation);
}

defaultproperties
{
}
