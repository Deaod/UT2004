//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSPRVRearGun extends ONSWeapon;

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx

var class<ONSChargeBeamEffect> BeamEffectClass;
var float StartHoldTime;
var float MaxHoldTime; //wait this long between shots for full damage
var float DamageScale, MinDamageScale;
var bool bHoldingFire;
var sound ChargingSound, ChargedLoop;

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Material'EpicParticles.Flares.SoftFlare');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.BeamBolt1a');
    L.AddPrecacheMaterial(Material'XEffectMat.shock_flare_a');
    L.AddPrecacheMaterial(Material'XEffectMat.Shock_ring_b');
    L.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_mark_heat');
    L.AddPrecacheMaterial(Material'XEffectMat.shock_core');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaFlare');
    L.AddPrecacheMaterial(Material'EpicParticles.Beams.HotBolt04aw');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.BurnFlare');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'EpicParticles.Flares.SoftFlare');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.BeamBolt1a');
    Level.AddPrecacheMaterial(Material'XEffectMat.shock_flare_a');
    Level.AddPrecacheMaterial(Material'XEffectMat.Shock_ring_b');
    Level.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_mark_heat');
    Level.AddPrecacheMaterial(Material'XEffectMat.shock_core');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaFlare');
    Level.AddPrecacheMaterial(Material'EpicParticles.Beams.HotBolt04aw');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.BurnFlare');

    Super.UpdatePrecacheMaterials();
}

simulated function SetFireRateModifier(float Modifier)
{
	Super.SetFireRateModifier(Modifier);

	MaxHoldTime = default.MaxHoldTime / Modifier;
}

simulated function float ChargeBar()
{
	if (bHoldingFire)
		return (FMin(Level.TimeSeconds - StartHoldTime, MaxHoldTime) / MaxHoldTime);
	else
		return 0;
}

function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
	local ONSChargeBeamEffect Beam;

	if (ReflectNum == 0)
		Start = WeaponFireLocation;

	Beam = spawn(BeamEffectClass,,, Start, Dir);
	Beam.SetDrawScale(DamageScale);
	Beam.HitLocation = HitLocation;

	if (Level.NetMode != NM_DedicatedServer)
		Beam.SetupBeam();
}

simulated function InitEffects()
{
	Super.InitEffects();

	if (FlashEmitter != None)
		FlashEmitter.Trigger(self, Instigator);
}

state InstantFireMode
{
	simulated function OwnerEffects()
	{
		if (Role < ROLE_Authority && !bHoldingFire)
		{
			bHoldingFire = true;
			StartHoldTime = Level.TimeSeconds;
			if (FlashEmitter != None)
				FlashEmitter.Reset();
		}
	}

	simulated function ClientStopFire(Controller C, bool bWasAltFire)
	{
		Super.ClientStopFire(C, bWasAltFire);

		if (FireCountdown <= 0)
		{
			ClientPlayForceFeedback(FireForce);
			ShakeView();
		}

		if (Role < ROLE_Authority)
		{
			bHoldingFire = false;
			if (FireCountdown <= 0)
			{
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
			if (FlashEmitter != None)
				FlashEmitter.Reset();
			bClientTrigger = !bClientTrigger;
			AmbientSound = ChargingSound;
			SetTimer(MaxHoldTime, False);
		}
	}

    function Timer()
    {
        if (bHoldingFire)
            AmbientSound = ChargedLoop;
    }

	function CeaseFire(Controller C)
	{
		if (!bHoldingFire)
			return;

		ClientPlayForceFeedback(FireForce);

		AmbientSound = None;

		CalcWeaponFire();

		if (bCorrectAim)
			WeaponFireRotation = AdjustAim(false);

		DamageScale = FClamp((Level.TimeSeconds - StartHoldTime) / MaxHoldTime, MinDamageScale, 1.0);
		DamageMin = default.DamageMin * DamageScale;
		DamageMax = default.DamageMax * DamageScale;
		Momentum = default.Momentum * DamageScale;
		FireSoundPitch = 2.0 - DamageScale;

		Super.Fire(C);
		FireCountdown = FireInterval;
		bHoldingFire = false;
	}

	simulated function ClientTrigger()
	{
		if (Instigator != None && !Instigator.IsLocallyControlled() && FlashEmitter != None)
			FlashEmitter.Reset();
	}
}

defaultproperties
{
     BeamEffectClass=Class'Onslaught.ONSChargeBeamEffect'
     MaxHoldTime=2.500000
     MinDamageScale=0.150000
     ChargingSound=Sound'ONSVehicleSounds-S.PRV.PRVChargeUp'
     ChargedLoop=Sound'ONSVehicleSounds-S.PRV.PRVChargeLoop'
     YawBone="REARgunBASE"
     PitchBone="REARgunTURRET"
     PitchUpLimit=15000
     PitchDownLimit=57500
     WeaponFireAttachmentBone="Dummy02"
     GunnerAttachmentBone="REARgunBASE"
     bInstantRotation=True
     bInstantFire=True
     bShowChargingBar=True
     bDoOffsetTrace=True
     RedSkin=Shader'VMVehicles-TX.NEWprvGroup.newPRVredSHAD'
     BlueSkin=Shader'VMVehicles-TX.NEWprvGroup.newPRVshad'
     FireInterval=0.750000
     FlashEmitterClass=Class'Onslaught.ONSPRVRearGunCharge'
     FireSoundClass=Sound'ONSVehicleSounds-S.PRV.PRVFire04'
     FireForce="PRVRearFire"
     DamageType=Class'Onslaught.DamTypeChargingBeam'
     DamageMin=200
     DamageMax=200
     TraceRange=20000.000000
     Momentum=150000.000000
     AIInfo(0)=(bInstantHit=True,bFireOnRelease=True,RefireRate=0.850000)
     Mesh=SkeletalMesh'ONSWeapons-A.PRVrearGUN'
     DrawScale=0.800000
}
