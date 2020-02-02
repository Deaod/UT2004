//=============================================================================
// ONSHoverTank_IonPlasma_Weapon
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class ONSHoverTank_IonPlasma_Weapon extends ONSHoverTankCannon;

var()	class<FX_Turret_IonCannon_BeamFire> BeamEffectClass;
var		float	StartHoldTime, MaxHoldTime, ShockMomentum, ShockRadius;
var		bool	bHoldingFire, bFireMode;
var		int		BeamCount, OldBeamCount;

var	sound	ChargingSound, ShockSound;

var	FX_IonPlasmaTank_AimLaser	AimLaser;

replication
{
    reliable if ( bNetDirty && !bNetOwner && Role == ROLE_Authority )
		bFireMode, BeamCount;
}

simulated function Destroyed()
{
	KillLaserBeam();

	super.Destroyed();
}

function PlayFiring()
{
	AmbientSound = None;
	PlaySound(sound'WeaponSounds.BExplosion5', SLOT_None, FireSoundVolume/255.0,,,, False);
}

function PlayChargeUp()
{
	AmbientSound = ChargingSound;
}

function PlayRelease()
{
	AmbientSound = None;
	PlaySound(sound'WeaponSounds.TranslocatorModuleRegeneration', SLOT_None, FireSoundVolume/255.0,,,, False);
}

simulated event FlashMuzzleFlash()
{
	super.FlashMuzzleFlash();

	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( !IsAltFire() && BeamCount != OldBeamCount )
		{
			OldBeamCount = BeamCount;
			PlayAnim('Fire', 0.5, 0);
			super.ShakeView();
		}
	}
}

simulated function bool IsAltFire()
{
	if ( Instigator.IsLocallyControlled() )
		return bIsAltFire;

	return bFireMode;
}

simulated function ShakeView()
{
	if ( IsAltFire() )
		super.ShakeView();
}

simulated function float ChargeBar()
{
	if ( bHoldingFire )
		return (FMin(Level.TimeSeconds - StartHoldTime, MaxHoldTime) / MaxHoldTime);
	else
		return 0;
}

function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
    local FX_Turret_IonCannon_BeamFire Beam;

    Beam = Spawn(BeamEffectClass,,, Start, Dir);
    if (ReflectNum != 0) Beam.Instigator = None; // prevents client side repositioning of beam start
    Beam.AimAt(HitLocation, HitNormal);
}

function SpawnLaserBeam()
{
	CalcWeaponFire();
    AimLaser = Spawn(class'FX_IonPlasmaTank_AimLaser', Self,, WeaponFireLocation, WeaponFireRotation);
}

function KillLaserBeam()
{
	if ( AimLaser != None )
	{
		AimLaser.Destroy();
		AimLaser = None;
	}
}

simulated function UpdateLaserBeamLocation( out vector Start, out vector HitLocation )
{
	local vector	HitNormal;
	local rotator	Dir;

	CalcWeaponFire();
	Start		= WeaponFireLocation;
	Dir			= WeaponFireRotation;
	HitLocation	= vect(0,0,0);
	SimulateTraceFire( Start, Dir, HitLocation, HitNormal );
	//log("UpdateLaserBeamLocation WFL:" @ WeaponFireLocation @ "WFR:" @ WeaponFireRotation
	//	@ "Start:" @ Start @ "HL:" @ HitLocation );
}

event bool AttemptFire( Controller C, bool bAltFire )
{
	bFireMode = bAltFire;
	return super.AttemptFire( C, bAltFire );
}

state ProjectileFireMode
{
	simulated function ClientStartFire(Controller C, bool bAltFire)
	{
		bFireMode	= bAltFire;
		bIsAltFire	= bAltFire;
		//log("ClientStartFire");
		if ( !bAltFire )
		{
			if ( Role < ROLE_Authority && FireCountdown <= 0 )
			{
				bHoldingFire	= true;
				StartHoldTime	= Level.TimeSeconds;
				SetTimer( MaxHoldTime, false );
			}
			else
				SetTimer( FireCountDown, false );	// synch to starthold matches server (done in timer)
			//super.ClientStartFire(C, bAltFire);


		}
		else
		{
			super.ClientStartFire(C, bAltFire);
		}
	}

	simulated function Timer()
	{
		if ( !bHoldingFire )
		{
			if ( Role < Role_Authority && !bFireMode )
			{
				bHoldingFire	= true;
				StartHoldTime	= Level.TimeSeconds;
				SetTimer( MaxHoldTime, false );
			}
			return;
		}

		bHoldingFire	= false;
		FireCountdown	= FireInterval;
		SetTimer(FireInterval, false);

		if ( Role == ROLE_Authority )
		{
			KillLaserBeam();
			CalcWeaponFire();
			FlashCount++;
			PlayFiring();

			if ( AmbientEffectEmitter != None )
				AmbientEffectEmitter.SetEmitterStatus( true );

			TraceFire(WeaponFireLocation, WeaponFireRotation);
		}
		BeamCount++;
		FlashMuzzleFlash();
	}

	simulated function ClientStopFire(Controller C, bool bWasAltFire)
	{
		//log("ClientStopFire");
		super.ClientStopFire(C, bWasAltFire);

		if ( bHoldingFire )
		{
			bHoldingFire	= false;
			FireCountdown	= FireInterval;
			ClientPlayForceFeedback("BioRifleFire");
		}
		SetTimer(0, false);
	}

	function Fire(Controller C)
	{
		NetUpdateTime = Level.TimeSeconds - 1;
		bFireMode = false;
		//log("Fire");
		if ( !bHoldingFire )
		{
			PlayChargeUp();
			StartHoldTime	= Level.TimeSeconds;
			bHoldingFire	= true;
			SetTimer( MaxHoldTime, false );
			SpawnLaserBeam();
		}
	}

	function AltFire(Controller C)
	{
		local actor		Shock;
		local float		DistScale, dist;
		local vector	dir, StartLocation;
		local Pawn		Victims;

		NetUpdateTime = Level.TimeSeconds - 1;
		bFireMode = true;
		//log("AltFire");
		StartLocation = Instigator.Location;

		PlaySound(ShockSound, SLOT_None, 128/255.0,,, 2.5, False);

		Shock = Spawn(class'FX_IonPlasmaTank_ShockWave', Self,, StartLocation);
		Shock.SetBase( Instigator );

		foreach VisibleCollidingActors( class'Pawn', Victims, ShockRadius, StartLocation )
		{
			//log("found:" @ Victims.GetHumanReadableName() );
			// don't let Shock affect fluid - VisibleCollisingActors doesn't really work for them - jag
			if( (Victims != Instigator) && (Victims.Controller != None)
				&& (Victims.Controller.GetTeamNum() != Instigator.GetTeamNum())
				&& (Victims.Role == ROLE_Authority) )
			{

				dir = Victims.Location - StartLocation;
				dir.Z = 0;
				dist = FMax(1,VSize(dir));
				dir = Normal(Dir)*0.5 + vect(0,0,1);
				DistScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/ShockRadius);
				Victims.AddVelocity( DistScale * ShockMomentum * dir );
				//Victims.Velocity = (DistScale * ShockMomentum * dir);
				//Victims.TakeDamage(0, Instigator, Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				//(DistScale * ShockMomentum * dir), None	);
				//log("Victims:" @ Victims.GetHumanReadableName() @ "DistScale:" @ DistScale );
			}
		}
	}

	function CeaseFire(Controller C)
	{
		//log("CeaseFire");

		KillLaserBeam();

		if ( bHoldingFire )
		{
			if ( Role == Role_Authority )
				PlayRelease();

			SetTimer(0, false);
			bHoldingFire	= false;
			FireCountdown	= FireInterval;
		}
	}
}

defaultproperties
{
     BeamEffectClass=Class'OnslaughtFull.ONSHoverTank_IonPlasma_BeamFire'
     MaxHoldTime=2.000000
     ShockMomentum=750.000000
     ShockRadius=1792.000000
     ChargingSound=Sound'AssaultSounds.AssaultRifle.IonPowerUp'
     ShockSound=Sound'ONSVehicleSounds-S.AVRiL.AvrilFire01'
     RedSkin=None
     BlueSkin=None
     FireInterval=1.500000
     AltFireInterval=1.500000
     EffectEmitterClass=None
     FireSoundClass=Sound'WeaponSounds.BaseImpactAndExplosions.BExplosion5'
     DamageMin=0
     DamageMax=0
     TraceRange=20000.000000
     ProjectileClass=None
     AIInfo(0)=(WarnTargetPct=0.990000,RefireRate=0.990000)
     Mesh=SkeletalMesh'AS_VehiclesFull_M.IonTankTurretSimple'
     SoundPitch=112
     SoundRadius=512.000000
}
