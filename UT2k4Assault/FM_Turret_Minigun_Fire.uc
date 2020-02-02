//=============================================================================
// FM_Turret_Minigun_Fire
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class FM_Turret_Minigun_Fire extends InstantFire;

function DoFireEffect()
{
    local Vector	StartTrace, HL, HN;
    local Rotator	R;
	local Actor		HitActor;

	if ( Instigator == None )
		return;

    Instigator.MakeNoise(1.0);

    StartTrace	= ASVehicle(Instigator).GetFireStart();
	HitActor	= ASVehicle(Instigator).CalcWeaponFire( HL, HN );
    R = Rotator(Normal(HL-StartTrace) + VRand()*FRand()*Spread);
	DoTrace(StartTrace, R);
}

simulated function bool AllowFire()
{
    return true;
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     DamageType=Class'UT2k4Assault.DamTypeMinigunTurretBullet'
     DamageMin=20
     DamageMax=25
     TraceRange=11000.000000
     FireLoopAnim=
     FireEndAnim=
     FireForce="TranslocatorFire"
     FireRate=0.150000
     AmmoClass=Class'UT2k4Assault.Ammo_Dummy'
     ShakeRotMag=(X=40.000000)
     ShakeRotRate=(X=2000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(Y=1.000000)
     ShakeOffsetRate=(Y=-2000.000000)
     ShakeOffsetTime=4.000000
     BotRefireRate=0.990000
     WarnTargetPct=0.150000
     Spread=0.015000
     SpreadStyle=SS_Random
}
