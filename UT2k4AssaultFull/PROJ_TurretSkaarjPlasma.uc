//=============================================================================
// PROJ_TurretSkaarjPlasma
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class PROJ_TurretSkaarjPlasma extends Projectile;

var Emitter			FX;
var	class<Emitter>	PlasmaClass;
var FX_PlasmaImpact	FX_Impact;


simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	Velocity		= Speed * Vector(Rotation);

	if ( Level.NetMode != NM_DedicatedServer )
		SetupProjectile();
}

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    Acceleration	= Velocity * 5;
}

simulated function Destroyed()
{
    if ( FX != None )
        FX.Destroy();

	super.Destroyed();
}

simulated function SetupProjectile()
{
	FX = Spawn(PlasmaClass, Self,, Location, Rotation);

	if ( FX != None )
		FX.SetBase( Self );
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if ( EffectIsRelevant(Location, false) )
		SpawnExplodeFX(HitLocation, HitNormal);

	PlaySound(Sound'WeaponSounds.BioRifle.BioRifleGoo2');
	Destroy();
}

simulated function SpawnExplodeFX(vector HitLocation, vector HitNormal)
{
	FX_Impact = Spawn(class'FX_PlasmaImpact',,, HitLocation + HitNormal * 2, rotator(HitNormal));
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	if ( Instigator != None && (Other == Instigator) )
		return;

    if (Other == Owner) return;

	if ( !Other.IsA('Projectile') || Other.bProjTarget )
	{
		if ( Role == ROLE_Authority )
		{
			if ( Instigator == None || Instigator.Controller == None )
				Other.SetDelayedDamageInstigatorController( InstigatorController );

			Other.TakeDamage(Damage, Instigator, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType);
		}

		Explode(HitLocation, -Normal(Velocity));
	}
}


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     PlasmaClass=Class'UT2k4AssaultFull.FX_SpaceFighter_SkaarjPlasma'
     Speed=8000.000000
     MaxSpeed=100000.000000
     Damage=45.000000
     MomentumTransfer=5000.000000
     MyDamageType=Class'UT2k4AssaultFull.DamTypeBallTurretPlasma'
     DrawType=DT_None
     AmbientSound=Sound'WeaponSounds.LinkGun.LinkGunProjectile'
     LifeSpan=1.400000
     SoundVolume=255
     SoundRadius=50.000000
     ForceType=FT_Constant
     ForceRadius=30.000000
     ForceScale=5.000000
}
