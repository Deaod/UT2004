//=============================================================================
// FM_LinkTurret_Fire
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class FM_LinkTurret_Fire extends ProjectileFire;

var sound	LinkedFireSound;
var string	LinkedFireForce;  // jdf

function DoFireEffect()
{
	local vector	Start, HL, HN;

	Instigator.MakeNoise(1.0);

	Start = ASVehicle(Instigator).GetFireStart();
	ASVehicle(Instigator).CalcWeaponFire( HL, HN );
	SpawnProjectile(Start, Rotator(HL-Start) );
}

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local PROJ_LinkTurret_Plasma Proj;

    Start += Vector(Dir) * 10.0 * Weapon_LinkTurret(Weapon).Links;
    Proj = Weapon.Spawn(class'UT2k4AssaultFull.PROJ_LinkTurret_Plasma',,, Start, Dir);
    if ( Proj != None )
    {
		Proj.Links = Weapon_LinkTurret(Weapon).Links;
		Proj.LinkAdjust();
	}
    return Proj;
}

function ServerPlayFiring()
{
    if ( Weapon_LinkTurret(Weapon).Links > 0 )
        FireSound = LinkedFireSound;
    else
        FireSound = default.FireSound;

    super.ServerPlayFiring();
}

function PlayFiring()
{
    if ( Weapon_LinkTurret(Weapon).Links > 0 )
        FireSound = LinkedFireSound;
    else
        FireSound = default.FireSound;
    super.PlayFiring();
}

simulated function bool AllowFire()
{
    return true;
}

defaultproperties
{
     LinkedFireSound=Sound'WeaponSounds.LinkGun.BLinkedFire'
     LinkedFireForce="BLinkedFire"
     FireLoopAnim=
     FireEndAnim=
     FireSound=SoundGroup'WeaponSounds.PulseRifle.PulseRifleFire'
     FireForce="TranslocatorFire"
     FireRate=0.350000
     AmmoClass=Class'UT2k4Assault.Ammo_Dummy'
     ShakeRotMag=(X=40.000000)
     ShakeRotRate=(X=2000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(Y=1.000000)
     ShakeOffsetRate=(Y=-2000.000000)
     ShakeOffsetTime=4.000000
     BotRefireRate=0.990000
     WarnTargetPct=0.100000
}
