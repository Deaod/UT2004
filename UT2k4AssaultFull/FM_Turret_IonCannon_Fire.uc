//=============================================================================
// FM_Turret_IonCannon_Fire
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class FM_Turret_IonCannon_Fire extends InstantFire;

var() class<FX_Turret_IonCannon_BeamFire> BeamEffectClass;

var	bool	bFired, bDoNotRelease;


event ModeHoldFire()
{
	if ( NextFireTime > Level.TimeSeconds )
		return;

	WA_Turret_IonCannon(Weapon.ThirdPersonActor).PlayCharge();
	WA_Turret_IonCannon(Weapon.ThirdPersonActor).ChargeCount++;
}

event ModeDoFire()
{
	// If Fire was released before MaxHoldTime was reached, abort Ion Cannon power up
	if ( HoldTime < MaxHoldTime )
	{
		HoldTime	= 0.f;
		bIsFiring	= false;

		WA_Turret_IonCannon(Weapon.ThirdPersonActor).PlayRelease();
		WA_Turret_IonCannon(Weapon.ThirdPersonActor).ReleaseCount++;

		return;
	}

	bFired = true;
	super.ModeDoFire();
	NextFireTime = Level.TimeSeconds + FireRate;
}


function StopFiring()
{
	if ( HoldTime > 0.f )
	{
		ModeDoFire();
		bFired = false;
	}
}

function bool IsFiring()
{
	return bIsFiring || (HoldTime > 0.f);
}

function DoFireEffect()
{
    local Vector	StartTrace, HL, HN;
    local Rotator	R;
	local Actor		HitActor;

	if ( Instigator == None )
		return;

    Instigator.MakeNoise(1.0);

    // Get Vehicle Fire Offset

    StartTrace	= ASVehicle(Instigator).GetFireStart();
	HitActor	= ASVehicle(Instigator).CalcWeaponFire( HL, HN );
	R			= Rotator(HL - StartTrace);
	DoTrace(StartTrace, R);
}

function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
    local FX_Turret_IonCannon_BeamFire Beam;

    Beam = Weapon.Spawn(BeamEffectClass,,, Start, Dir);
    if (ReflectNum != 0) Beam.Instigator = None; // prevents client side repositioning of beam start
    Beam.AimAt(HitLocation, HitNormal);
}

simulated function bool AllowFire()
{
    return true;
}

defaultproperties
{
     BeamEffectClass=Class'UT2k4AssaultFull.FX_Turret_IonCannon_BeamFire'
     DamageType=Class'XWeapons.DamTypeShockBeam'
     TraceRange=20000.000000
     bSplashDamage=True
     bRecommendSplashDamage=True
     bFireOnRelease=True
     MaxHoldTime=4.000000
     FireRate=4.000000
     AmmoClass=Class'UT2k4Assault.Ammo_Dummy'
     BotRefireRate=0.990000
}
