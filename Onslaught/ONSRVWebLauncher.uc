//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSRVWebLauncher extends ONSWeapon;

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx

var()	float	SpreadAngle; // Angle between initial shots, in radians.
var()	float	InheritVelocityScale; // Amount of vehicles velocity
var()	float	MinProjectiles, MaxProjectiles, MaxHoldTime;
var	float	StartHoldTime;
var	bool	bHoldingFire;
var sound   ChargeUpSound, ChargeLoop;

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.PowerBolt');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.ElecPanels');
    L.AddPrecacheMaterial(Material'EpicParticles.Beams.HotBolt03aw');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.HardSpot');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.PowerBolt');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.ElecPanels');
    Level.AddPrecacheMaterial(Material'EpicParticles.Beams.HotBolt03aw');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.HardSpot');

    Super.UpdatePrecacheMaterials();
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Weapons.ONSMuzzleFlash');
	Super.UpdatePrecacheStaticMeshes();
}

simulated function SetFireRateModifier(float Modifier)
{
	Super.SetFireRateModifier(Modifier);

	MaxHoldTime = default.MaxHoldTime / Modifier;
}

function byte BestMode()
{
	return 0;
}

simulated function float MaxRange()
{
	AimTraceRange = 6000;

	return AimTraceRange;
}

simulated function float ChargeBar()
{
	if (bHoldingFire)
		return (FMin(Level.TimeSeconds - StartHoldTime, MaxHoldTime) / MaxHoldTime);
	else
		return 0;
}

state ProjectileFireMode
{
	simulated function OwnerEffects()
	{
		if (Role < ROLE_Authority && !bHoldingFire && !bIsAltFire)
		{
			bHoldingFire = true;
			StartHoldTime = Level.TimeSeconds;
		}
	}

	simulated function ClientStopFire(Controller C, bool bWasAltFire)
	{
		Super.ClientStopFire(C, bWasAltFire);

		if (FireCountdown <= 0)
		{
			ClientPlayForceFeedback("BioRifleFire");
			ShakeView();
		}

		if (Role < ROLE_Authority)
		{
			bHoldingFire = false;
			if (FireCountdown <= 0)
			{
				//FIXME make sounds clientside as well!
				if (bIsAltFire)
					FireCountdown = AltFireInterval;
				else
					FireCountdown = FireInterval;

		        FlashMuzzleFlash();

		        if (!bIsAltFire)
                    PlaySound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
		    }
		}
	}

	function Fire(Controller C)
	{
		if (!bHoldingFire)
		{
			StartHoldTime = Level.TimeSeconds;
			bHoldingFire = true;
            AmbientSound = ChargeUpSound;
            SetTimer(MaxHoldTime, False);
		}
	}

    function Timer()
    {
        if (bHoldingFire)
            AmbientSound = ChargeLoop;
    }

	function CeaseFire(Controller C)
	{
		local vector GunDir, RightDir, FireDir;
		local int i, NumProjectiles;
		local float SpreadAngleRad, FireAngleRad; // Radians
		local ONSRVWebProjectileLeader Leader;
		local ONSRVWebProjectile P;

		if (!bHoldingFire)
			return;

		ClientPlayForceFeedback("BioRifleFire");

		AmbientSound = None;

		CalcWeaponFire();

		if (bCorrectAim)
			WeaponFireRotation = AdjustAim(false);

		// Defines plane in which projectiles will start travelling in.
		GunDir = vector(WeaponFireRotation);
		RightDir = normal( GunDir Cross vect(0,0,1) );

		NumProjectiles = MinProjectiles + (MaxProjectiles - MinProjectiles) * (FMin(Level.TimeSeconds - StartHoldTime, MaxHoldTime) / MaxHoldTime);
		bHoldingFire = false;

		SpreadAngleRad = SpreadAngle * (Pi/180.0);

		// Spawn all the projectiles
		for(i=0; i<NumProjectiles; i++)
		{
			FireAngleRad = (-0.5 * SpreadAngleRad * (NumProjectiles - 1)) + (i * SpreadAngleRad); // So shots are centered around FireAngle of zero.
			FireDir = (Cos(FireAngleRad) * GunDir) + (Sin(FireAngleRad) * RightDir);

			if(i == 0)
			{
				Leader = spawn(class'ONSRVWebProjectileLeader', self, , WeaponFireLocation, rotator(FireDir));

				if(Leader != None)
				{
					Leader.Velocity += InheritVelocityScale * Instigator.Velocity;

					Leader.Projectiles.Length = NumProjectiles;
					Leader.ProjTeam = C.GetTeamNum();

					Leader.Projectiles[0] = Leader;
					Leader.ProjNumber = 0;
					Leader.Leader = Leader;
				}
			}
			else
			{
				P = spawn(class'ONSRVWebProjectile', self, , WeaponFireLocation, rotator(FireDir));

				if(P != None && Leader != None)
				{
					Leader.Projectiles[i] = P;
					P.ProjNumber = i;
					P.Leader = Leader;
				}
			}
		}

		ShakeView();
		FlashMuzzleFlash();

		// Play firing noise
		if (bAmbientFireSound)
			AmbientSound = FireSoundClass;
		else
			PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);

		FireCountdown = FireInterval;
	}
}

defaultproperties
{
     SpreadAngle=10.000000
     MinProjectiles=3.000000
     MaxProjectiles=7.000000
     MaxHoldTime=2.000000
     ChargeUpSound=Sound'ONSVehicleSounds-S.RV.RVChargeUp01'
     ChargeLoop=Sound'ONSVehicleSounds-S.RV.RVChargeLoop01'
     YawBone="rvGUNTurret"
     PitchBone="rvGUNbody"
     WeaponFireAttachmentBone="RVfirePoint"
     bShowChargingBar=True
     bDoOffsetTrace=True
     FireInterval=1.000000
     FlashEmitterClass=Class'Onslaught.ONSRVWebLauncherMuzzleFlash'
     FireSoundClass=Sound'ONSVehicleSounds-S.WebLauncher.WebFire'
     FireSoundVolume=255.000000
     DamageType=Class'Onslaught.DamTypeONSChainGun'
     ProjectileClass=Class'Onslaught.ONSRVWebProjectile'
     AIInfo(0)=(bLeadTarget=True,bFireOnRelease=True,WarnTargetPct=0.500000,RefireRate=0.650000)
     CullDistance=7500.000000
     Mesh=SkeletalMesh'ONSWeapons-A.RVnewGun'
     SoundVolume=150
}
