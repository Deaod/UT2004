//=============================================================================
// FM_SpaceFighter_InstantHitLaser
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class FM_SpaceFighter_InstantHitLaser extends InstantFire;

var	bool				bSwitch;
var name				FireAnimLeft, FireAnimRight;
var	Sound				FireSounds[2];


event ModeDoFire()
{
	bSwitch = ( (WeaponAttachment(Weapon.ThirdPersonActor).FlashCount % 2) == 1 );
	super.ModeDoFire();
}

function DoFireEffect()
{
    local Vector	StartTrace, HL, HN;
    local Rotator	R;

	if ( Instigator == None || !Instigator.IsA('ASVehicle') )
	{
		super.DoFireEffect();
		return;
	}

	if ( ASVehicle_SpaceFighter_Skaarj(Instigator) != None )	// hack for Skaarj SF damagetype
		DamageType = class'DamTypeSpaceFighterLaser_Skaarj';

    Instigator.MakeNoise(1.0);

    StartTrace	= ASVehicle(Instigator).GetFireStart();
	ASVehicle(Instigator).CalcWeaponFire( HL, HN );

    R = Rotator( Normal(HL-StartTrace) );

	DoTrace(StartTrace, R);
}

function PlayFiring()
{
	if ( Weapon.Mesh != None )
	{
		if ( bSwitch && Weapon.HasAnim(FireAnimRight) )
			FireAnim = FireAnimRight;
		else if ( !bSwitch && Weapon.HasAnim(FireAnimLeft) )
			FireAnim = FireAnimLeft;
	}

	UpdateFireSound();

	super.PlayFiring();
}

simulated function UpdateFireSound()
{
	if ( Instigator.IsA('ASTurret') || Instigator.IsA('ASVehicle_SpaceFighter_Skaarj') )
		FireSound = FireSounds[0];
	else
		FireSound = FireSounds[1];
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
     FireAnimLeft="FireL"
     FireAnimRight="FireR"
     FireSounds(0)=Sound'ONSVehicleSounds-S.LaserSounds.Laser02'
     FireSounds(1)=Sound'AssaultSounds.HumanShip.HnShipFire01'
     DamageType=Class'UT2k4AssaultFull.DamTypeSpaceFighterLaser'
     DamageMin=30
     DamageMax=40
     TraceRange=65536.000000
     FireLoopAnim=
     FireEndAnim=
     FireAnimRate=0.450000
     TweenTime=0.000000
     FireSound=SoundGroup'WeaponSounds.PulseRifle.PulseRifleFire'
     FireForce="TranslocatorFire"
     FireRate=0.200000
     AmmoClass=Class'UT2k4Assault.Ammo_Dummy'
     ShakeRotMag=(X=40.000000)
     ShakeRotRate=(X=2000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(Y=1.000000)
     ShakeOffsetRate=(Y=-2000.000000)
     ShakeOffsetTime=4.000000
     BotRefireRate=0.990000
     WarnTargetPct=0.200000
     aimerror=800.000000
}
