class BioChargedFire extends ProjectileFire;

var() float GoopUpRate;
var() int MaxGoopLoad;
var() int GoopLoad;
var() Sound HoldSound;

function InitEffects()
{
    Super.InitEffects();
    if( FlashEmitter == None )
        FlashEmitter = Weapon.GetFireMode(0).FlashEmitter;
}

function DrawMuzzleFlash(Canvas Canvas)
{
	if ( FlashEmitter != None )
		FlashEmitter.SetRotation(Weapon.Rotation);
    Super.DrawMuzzleFlash(Canvas);
}

function ModeHoldFire()
{
    if ( Weapon.AmmoAmount(ThisModeNum) > 0 )
    {
        Super.ModeHoldFire();
        GotoState('Hold');
    }
}

function float MaxRange()
{
	return 1500;
}

simulated function bool AllowFire()
{
    return (Weapon.AmmoAmount(ThisModeNum) > 0 || GoopLoad > 0);
}

simulated function PlayStartHold()
{
    Weapon.PlayAnim('AltFire', 1.0 / (GoopUpRate*MaxGoopLoad), 0.1);
}

simulated function PlayFiring()
{
	Super.PlayFiring();
	Weapon.OutOfAmmo();
}

state Hold
{
    simulated function BeginState()
    {
        GoopLoad = 0;
        SetTimer(GoopUpRate, true);
        Weapon.PlayOwnedSound(sound'WeaponSounds.Biorifle_charge',SLOT_Interact,TransientSoundVolume);
        Weapon.ClientPlayForceFeedback( "BioRiflePowerUp" );  // jdf
        Timer();
    }

    simulated function Timer()
    {
		if ( Weapon.AmmoAmount(ThisModeNum) > 0 )
			GoopLoad++;
        Weapon.ConsumeAmmo(ThisModeNum, 1);
        if (GoopLoad == MaxGoopLoad || Weapon.AmmoAmount(ThisModeNum) == 0)
        {
            SetTimer(0.0, false);
			Instigator.AmbientSound = sound'NewWeaponSounds.BioGoopLoop';
			Instigator.SoundRadius = 50;
			Instigator.SoundVolume = 50;
        }
    }

    simulated function EndState()
    {
		if ( (Instigator != None) && (Instigator.AmbientSound == sound'NewWeaponSounds.BioGoopLoop') )
			Instigator.AmbientSound = None;
		Instigator.SoundRadius = Instigator.Default.SoundRadius;
		Instigator.SoundVolume = Instigator.Default.SoundVolume;

        StopForceFeedback( "BioRiflePowerUp" );  // jdf
    }
}

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local BioGlob Glob;

    GotoState('');

    if (GoopLoad == 0) return None;

    Glob = Weapon.Spawn(class'BioGlob',,, Start, Dir);
    if ( Glob != None )
    {
		Glob.Damage *= DamageAtten;
		Glob.SetGoopLevel(GoopLoad);
		Glob.AdjustSpeed();
    }
    GoopLoad = 0;
    if ( Weapon.AmmoAmount(ThisModeNum) <= 0 )
        Weapon.OutOfAmmo();
    return Glob;
}

function StartBerserk()
{
	if ( (Level.GRI != None) && (Level.GRI.WeaponBerserk > 1.0) )
		return;
    GoopUpRate = default.GoopUpRate*0.75;
}

function StopBerserk()
{
	if ( (Level.GRI != None) && (Level.GRI.WeaponBerserk > 1.0) )
		return;
    GoopUpRate = default.GoopUpRate;
}

function StartSuperBerserk()
{
    GoopUpRate = default.GoopUpRate/Level.GRI.WeaponBerserk;
}

defaultproperties
{
     GoopUpRate=0.250000
     MaxGoopLoad=10
     HoldSound=SoundGroup'WeaponSounds.BioRifle.BioRiflePowerUp'
     ProjSpawnOffset=(X=20.000000,Y=9.000000,Z=-6.000000)
     bSplashDamage=True
     bRecommendSplashDamage=True
     bTossed=True
     bFireOnRelease=True
     FireEndAnim=
     FireSound=SoundGroup'WeaponSounds.BioRifle.BioRifleFire'
     FireForce="BioRifleFire"
     FireRate=0.330000
     AmmoClass=Class'XWeapons.BioAmmo'
     ShakeRotMag=(X=100.000000)
     ShakeRotRate=(X=1000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-4.000000,Z=-4.000000)
     ShakeOffsetRate=(X=1000.000000,Z=1000.000000)
     ShakeOffsetTime=2.000000
     ProjectileClass=Class'XWeapons.BioGlob'
     BotRefireRate=0.500000
     WarnTargetPct=0.800000
}
