class ShieldFire extends WeaponFire;

var class<DamageType> DamageType;       // weapon fire damage type (no projectile, so we put this here)
var float ShieldRange;                  // from pawn centre
var float MinHoldTime;                  // held for this time or less will do minimum damage/force. held for MaxHoldTime will do max
var float MinForce, MaxForce;           // force to other players
var float MinDamage, MaxDamage;         // damage to other players
var float SelfForceScale;               // %force to self (when shielding a wall)
var float SelfDamageScale;              // %damage to self (when shielding a wall)
var float MinSelfDamage;
var Sound ChargingSound;                // charging sound
var xEmitter ChargingEmitter;           // emitter class while charging
var float AutoFireTestFreq;
var float FullyChargedTime;				// held for this long will do max damage
var bool bAutoRelease;
var bool bStartedChargingForce;
var	byte  ChargingSoundVolume;
var Pawn AutoHitPawn;
var float AutoHitTime;

// jdf ---
var String ChargingForce;
// --- jdf

simulated function DestroyEffects()
{
    if (ChargingEmitter != None)
        ChargingEmitter.Destroy();
	Super.DestroyEffects();
}

simulated function InitEffects()
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		ChargingEmitter = Weapon.Spawn(class'XEffects.ShieldCharge');
		ChargingEmitter.mRegenPause = true;
	}
    bStartedChargingForce = false;  // jdf
    Super.InitEffects();
}

function DrawMuzzleFlash(Canvas Canvas)
{
    if (ChargingEmitter != None && HoldTime > 0.0 && !bNowWaiting)
    {
		ChargingEmitter.SetLocation( Weapon.GetEffectStart() );
        Canvas.DrawActor( ChargingEmitter, false, false, Weapon.DisplayFOV );
    }

    if (FlashEmitter != None)
    {
        FlashEmitter.SetLocation( Weapon.GetEffectStart() );
        if ( Weapon.WeaponCentered() )
 			FlashEmitter.SetRotation(Weapon.Instigator.GetViewRotation());
        else
			FlashEmitter.SetRotation(Weapon.Rotation);
        Canvas.DrawActor( FlashEmitter, false, false, Weapon.DisplayFOV );
    }

    if ( (Instigator.AmbientSound == ChargingSound) && ((HoldTime <= 0.0) || bNowWaiting) )
	{
        Instigator.AmbientSound = None;
		Instigator.SoundVolume = Instigator.Default.SoundVolume;
	}

}

function Rotator AdjustAim(Vector Start, float InAimError)
{
	local rotator Aim, EnemyAim;

	if ( AIController(Instigator.Controller) != None )
	{
		Aim = Instigator.Rotation;
		if ( Instigator.Controller.Enemy != None )
		{
			EnemyAim = rotator(Instigator.Controller.Enemy.Location - Start);
			Aim.Pitch = EnemyAim.Pitch;
		}
		return Aim;
	}
	else
		return super.AdjustAim(Start,InAimError);
}

function DoFireEffect()
{
	local Vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
    local Rotator Aim;
	local Actor Other;
    local float Scale, Damage, Force;

	Instigator.MakeNoise(1.0);
    Weapon.GetViewAxes(X,Y,Z);
	bAutoRelease = false;

	if ( (AutoHitPawn != None) && (Level.TimeSeconds - AutoHitTime < 0.15) )
	{
		Other = AutoHitPawn;
		HitLocation = Other.Location;
		AutoHitPawn = None;
	}
	else
	{
		StartTrace = Instigator.Location;
		Aim = AdjustAim(StartTrace, AimError);
		EndTrace = StartTrace + ShieldRange * Vector(Aim);
		Other = Weapon.Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
	}

    Scale = (FClamp(HoldTime, MinHoldTime, FullyChargedTime) - MinHoldTime) / (FullyChargedTime - MinHoldTime); // result 0 to 1
    Damage = MinDamage + Scale * (MaxDamage - MinDamage);
    Force = MinForce + Scale * (MaxForce - MinForce);

    Instigator.AmbientSound = None;
	Instigator.SoundVolume = Instigator.Default.SoundVolume;

    if (ChargingEmitter != None)
        ChargingEmitter.mRegenPause = true;

    if ( Other != None && Other != Instigator )
    {
		if ( Pawn(Other) != None || (Decoration(Other) != None && Decoration(Other).bDamageable) )
        	Other.TakeDamage(Damage, Instigator, HitLocation, Force*(X+vect(0,0,0.5)), DamageType);
		else
		{
			if ( xPawn(Instigator).bBerserk )
				Force *= 2.0;
			Instigator.TakeDamage(MinSelfDamage+SelfDamageScale*Damage, Instigator, HitLocation, -SelfForceScale*Force*X, DamageType);
			if ( DestroyableObjective(Other) != None )
		      	Other.TakeDamage(Damage, Instigator, HitLocation, Force*(X+vect(0,0,0.5)), DamageType);
		}
    }

    SetTimer(0, false);
}

function ModeHoldFire()
{
    SetTimer(AutoFireTestFreq, true);
}

function bool IsFiring()
{
	return ( bIsFiring || bAutoRelease );
}

function Timer()
{
    local Actor Other;
    local Vector HitLocation, HitNormal, StartTrace, EndTrace;
    local Rotator Aim;
    local float Regen;
    local float ChargeScale;

    if (HoldTime > 0.0 && !bNowWaiting)
    {
	    StartTrace = Instigator.Location;
		Aim = AdjustAim(StartTrace, AimError);
	    EndTrace = StartTrace + ShieldRange * Vector(Aim);

        Other = Weapon.Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
        if ( (Pawn(Other) != None) && (Other != Instigator) )
        {
			bAutoRelease = true;
            bIsFiring = false;
            Instigator.AmbientSound = None;
			Instigator.SoundVolume = Instigator.Default.SoundVolume;
            AutoHitPawn = Pawn(Other);
            AutoHitTime = Level.TimeSeconds;
            if (ChargingEmitter != None)
                ChargingEmitter.mRegenPause = true;
        }
        else
        {
            Instigator.AmbientSound = ChargingSound;
			Instigator.SoundVolume = ChargingSoundVolume;
            ChargeScale = FMin(HoldTime, FullyChargedTime);
            if (ChargingEmitter != None)
            {
                ChargingEmitter.mRegenPause = false;
                Regen = ChargeScale * 10 + 20;
                ChargingEmitter.mRegenRange[0] = Regen;
                ChargingEmitter.mRegenRange[1] = Regen;
                ChargingEmitter.mSpeedRange[0] = ChargeScale * -15.0;
                ChargingEmitter.mSpeedRange[1] = ChargeScale * -15.0;
                Regen = FMax((ChargeScale / 30.0),0.20);
                ChargingEmitter.mLifeRange[0] = Regen;
                ChargingEmitter.mLifeRange[1] = Regen;
            }

            if (!bStartedChargingForce)
            {
                bStartedChargingForce = true;
                ClientPlayForceFeedback( ChargingForce );
            }
        }
    }
    else
    {
		if ( Instigator.AmbientSound == ChargingSound )
		{
			Instigator.AmbientSound = None;
			Instigator.SoundVolume = Instigator.Default.SoundVolume;
		}

        SetTimer(0, false);
    }
}

simulated function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Instigator.Location;
}

function StartBerserk()
{
	if ( (Level.GRI != None) && (Level.GRI.WeaponBerserk > 1.0) )
		return;
    MaxHoldTime = default.MaxHoldTime * 0.75;
    FullyChargedTime = default.FullyChargedTime * 0.75;
}

function StopBerserk()
{
	if ( (Level.GRI != None) && (Level.GRI.WeaponBerserk > 1.0) )
		return;
    MaxHoldTime = default.MaxHoldTime;
    FullyChargedTime = default.FullyChargedTime;
}

function StartSuperBerserk()
{
    MaxHoldTime = default.MaxHoldTime/Level.GRI.WeaponBerserk;
    FullyChargedTime = default.FullyChargedTime/Level.GRI.WeaponBerserk;
    MinDamage = Default.MinDamage * Level.GRI.WeaponBerserk;
    MaxDamage = Default.MaxDamage * Level.GRI.WeaponBerserk;
}

function PlayPreFire()
{
    Weapon.PlayAnim('Charge', 1.0/FullyChargedTime, 0.1);
}

// jdf ---
function PlayFiring()
{
    bStartedChargingForce = false;
    StopForceFeedback(ChargingForce);
    Super.PlayFiring();
}
// --- jdf

defaultproperties
{
     DamageType=Class'XWeapons.DamTypeShieldImpact'
     ShieldRange=112.000000
     MinHoldTime=0.400000
     MinForce=65000.000000
     MaxForce=100000.000000
     MinDamage=40.000000
     MaxDamage=150.000000
     SelfForceScale=1.000000
     SelfDamageScale=0.300000
     MinSelfDamage=8.000000
     ChargingSound=Sound'WeaponSounds.Misc.shieldgun_charge'
     AutoFireTestFreq=0.150000
     FullyChargedTime=2.500000
     ChargingSoundVolume=200
     ChargingForce="shieldgun_charge"
     bFireOnRelease=True
     TransientSoundVolume=1.000000
     PreFireAnim="Charge"
     FireLoopAnim=
     FireEndAnim=
     TweenTime=0.000000
     FireSound=ProceduralSound'WeaponSounds.PShieldGunFire.P1ShieldGunFire'
     FireForce="ShieldGunFire"
     FireRate=0.600000
     AmmoClass=Class'XWeapons.ShieldAmmo'
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-20.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=1.000000
     WarnTargetPct=0.100000
     FlashEmitterClass=Class'XEffects.ForceRingA'
}
