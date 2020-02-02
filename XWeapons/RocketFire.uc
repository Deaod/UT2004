class RocketFire extends ProjectileFire;

function PlayFireEnd()
{
}

function InitEffects()
{
    Super.InitEffects();
    if ( FlashEmitter != None )
		Weapon.AttachToBone(FlashEmitter, 'tip');
}

function PlayFiring()
{
    Super.PlayFiring();
    RocketLauncher(Weapon).PlayFiring(true);
}

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;
    
    p = RocketLauncher(Weapon).SpawnProjectile(Start, Dir);
    if ( p != None )
		p.Damage *= DamageAtten;
    return p;
}

defaultproperties
{
     ProjSpawnOffset=(X=25.000000,Y=6.000000,Z=-6.000000)
     bSplashDamage=True
     bSplashJump=True
     bRecommendSplashDamage=True
     TweenTime=0.000000
     FireSound=SoundGroup'WeaponSounds.RocketLauncher.RocketLauncherFire'
     FireForce="RocketLauncherFire"
     FireRate=0.900000
     AmmoClass=Class'XWeapons.RocketAmmo'
     AmmoPerFire=1
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-20.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     ProjectileClass=Class'XWeapons.RocketProj'
     BotRefireRate=0.500000
     WarnTargetPct=0.900000
     FlashEmitterClass=Class'XEffects.RocketMuzFlash1st'
}
