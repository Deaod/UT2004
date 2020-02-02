//=============================================================================
// FX_SpaceFighter_InstantHitLaser
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class FX_SpaceFighter_InstantHitLaser extends Projectile;

var Emitter			Laser;
var class<Emitter>	LaserClass;		// Human
var	class<Emitter>	PlasmaClass;	// Skaarj
var	bool			bIsPlasma;
var	float			ProjAccel;

simulated function PostBeginPlay()
{
	local float	InstigatorSpeed;

	super.PostBeginPlay();

	if ( Instigator != None )
		InstigatorSpeed	= VSize(Instigator.Velocity) * (Instigator.Velocity Dot Vector(Rotation));
	else
		InstigatorSpeed = 1000;

	Velocity		= InstigatorSpeed * Vector(Rotation) * 0.00001;
	Acceleration	= Velocity * InstigatorSpeed * 0.01;

	SetupProjectile();

	SetTimer(0.1, false);
}

simulated function Timer()
{
	Acceleration = Velocity * ProjAccel * ProjAccel;
}

simulated function Destroyed()
{
    if ( Laser != None )
        Laser.Destroy();

	super.Destroyed();
}

simulated function SetupProjectile()
{
	local class<Emitter>	FXClass;

	// FX
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( Instigator.IsA('ASVehicle_SpaceFighter_Skaarj') || Instigator.IsA('ASTurret') )
		{
			FXClass = PlasmaClass;
			bIsPlasma = true;
		}
		else
			FXClass = LaserClass;

		Laser = Spawn(FXClass, Self,, Location, Rotation);

		if ( Laser != None )
		{
			Laser.SetBase( Self );

			if ( !bIsPlasma )
				FX_Laser_Blue(Laser).SetScale(1.5, 6.0);
			else
				FX_SpaceFighter_SkaarjPlasma(Laser).SetScale( 1.0 );

			// Red version for Team 0
			if ( Instigator.GetTeamNum() == 0 )
			{
				if (  bIsPlasma )
					FX_SpaceFighter_SkaarjPlasma(Laser).SetRedColor();
				else
					FX_Laser_Blue(Laser).SetRedColor();
			}
		}
	}
}


simulated function Explode(vector HitLocation, vector HitNormal)
{
	Destroy();
}


simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	if ( Instigator != None )
	{	
		if (Other == Instigator) return;
	}
	if (Other == Owner) return;

	if ( !Other.IsA('Projectile') || Other.bProjTarget )
	{
		Explode(HitLocation, -Normal(Velocity));
	}
}


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     LaserClass=Class'UT2k4Assault.FX_Laser_Blue'
     PlasmaClass=Class'UT2k4AssaultFull.FX_SpaceFighter_SkaarjPlasma'
     ProjAccel=40000.000000
     Speed=1.000000
     MaxSpeed=250000.000000
     MomentumTransfer=1000.000000
     MyDamageType=Class'XWeapons.DamTypeLinkPlasma'
     ExplosionDecal=Class'XEffects.LinkBoltScorch'
     DrawType=DT_None
     RemoteRole=ROLE_None
     AmbientSound=Sound'WeaponSounds.LinkGun.LinkGunProjectile'
     LifeSpan=1.000000
     SoundVolume=255
     SoundRadius=50.000000
     ForceType=FT_Constant
     ForceRadius=30.000000
     ForceScale=5.000000
}
