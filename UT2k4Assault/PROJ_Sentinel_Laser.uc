//=============================================================================
// PROJ_Sentinel_Laser
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class PROJ_Sentinel_Laser extends Projectile;

var		FX_Laser_Blue			Laser;
var		class<FX_Laser_Blue>	LaserClass;		// Human

simulated function PostNetBeginPlay()
{
	super.PostNetBeginPlay();

	Velocity		= Speed * Vector(Rotation);
	Acceleration	= Velocity;
	SetupProjectile();
}


simulated function Destroyed()
{
    if ( Laser != None )
        Laser.Destroy();

	super.Destroyed();
}

simulated function SetupProjectile()
{
	// FX
	if ( Level.NetMode != NM_DedicatedServer )
	{
		Laser = Spawn(LaserClass, Self,, Location, Rotation);

		if ( Laser != None )
		{
			Laser.SetBase( Self );
			Laser.SetScale( 0.67, 0.67 );
		}
	}
}


simulated function Explode(vector HitLocation, vector HitNormal)
{
	SpawnExplodeFX(HitLocation, HitNormal);

    PlaySound(Sound'WeaponSounds.BioRifle.BioRifleGoo2');
	Destroy();
}

simulated function SpawnExplodeFX(vector HitLocation, vector HitNormal)
{
    if ( EffectIsRelevant(Location, false) )
	{
		Spawn(class'FX_PlasmaImpact',,, HitLocation + HitNormal * 2, rotator(HitNormal));
	}
}

//==============
// Encroachment
function bool EncroachingOn( actor Other )
{
	if ( Other == Instigator || Other == Owner || Other.Owner == Instigator || Other.Base == Instigator )
		return false;

	super.EncroachingOn( Other );
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	local float		AdjustedDamage;

	if ( Instigator != None )
	{
		if (Other == Instigator) return;
		if (Other.Owner == Instigator || Other.Base == Instigator) return;
	}

	if (Other == Owner) return;

	if ( !Other.IsA('Projectile') || Other.bProjTarget )
	{
		if ( Role == ROLE_Authority )
		{
			if ( Instigator == None || Instigator.Controller == None )
				Other.SetDelayedDamageInstigatorController( InstigatorController );

			AdjustedDamage = Damage;
			if ( ASVehicle_Sentinel(Instigator) != None && ASVehicle_Sentinel(Instigator).bSpawnCampProtection )
				AdjustedDamage *= 10;

			Other.TakeDamage(AdjustedDamage, Instigator, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType);
		}
		Explode(HitLocation, -Normal(Velocity));
	}
}


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     LaserClass=Class'UT2k4Assault.FX_Laser_Blue'
     Speed=4000.000000
     MaxSpeed=8000.000000
     Damage=20.000000
     MomentumTransfer=1000.000000
     MyDamageType=Class'UT2k4Assault.DamTypeSentinelLaser'
     DrawType=DT_None
     AmbientSound=Sound'WeaponSounds.LinkGun.LinkGunProjectile'
     LifeSpan=3.000000
     SoundVolume=255
     SoundRadius=50.000000
     ForceType=FT_Constant
     ForceRadius=30.000000
     ForceScale=5.000000
}
