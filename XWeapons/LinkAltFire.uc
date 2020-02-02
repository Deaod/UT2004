class LinkAltFire extends ProjectileFire;

var sound LinkedFireSound;
var string LinkedFireForce;  // jdf

function DrawMuzzleFlash(Canvas Canvas)
{
    if (FlashEmitter != None)
    {
        FlashEmitter.SetRotation(Weapon.Rotation);
        Super.DrawMuzzleFlash(Canvas);
    }
}

simulated function bool AllowFire()
{
    return ( Weapon.AmmoAmount(ThisModeNum) >= 1 );
}

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local LinkProjectile Proj;

    Start += Vector(Dir) * 10.0 * LinkGun(Weapon).Links;
    Proj = Weapon.Spawn(class'XWeapons.LinkProjectile',,, Start, Dir);
    if ( Proj != None )
    {
		Proj.Links = LinkGun(Weapon).Links;
		Proj.LinkAdjust();
	}
    return Proj;
}

function FlashMuzzleFlash()
{
    if (FlashEmitter != None)
    {
        if (LinkGun(Weapon).Links > 0)
            FlashEmitter.Skins[0] = FinalBlend'XEffectMat.LinkMuzProjYellowFB';
        else
            FlashEmitter.Skins[0] = FinalBlend'XEffectMat.LinkMuzProjGreenFB';
    }
    Super.FlashMuzzleFlash();
}

function ServerPlayFiring()
{
    if (LinkGun(Weapon).Links > 0)
        FireSound = LinkedFireSound;
    else
        FireSound = default.FireSound;
    Super.ServerPlayFiring();
}

function PlayFiring()
{
    if (LinkGun(Weapon).Links > 0)
        FireSound = LinkedFireSound;
    else
        FireSound = default.FireSound;
    Super.PlayFiring();
}

defaultproperties
{
     LinkedFireSound=Sound'WeaponSounds.LinkGun.BLinkedFire'
     LinkedFireForce="BLinkedFire"
     ProjSpawnOffset=(X=25.000000,Y=8.000000,Z=-3.000000)
     FireLoopAnim=
     FireEndAnim=
     FireAnimRate=0.750000
     FireSound=SoundGroup'WeaponSounds.PulseRifle.PulseRifleFire'
     FireForce="TranslocatorFire"
     FireRate=0.200000
     AmmoClass=Class'XWeapons.LinkAmmo'
     AmmoPerFire=2
     ShakeRotMag=(X=40.000000)
     ShakeRotRate=(X=2000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(Y=1.000000)
     ShakeOffsetRate=(Y=-2000.000000)
     ShakeOffsetTime=4.000000
     ProjectileClass=Class'XWeapons.LinkProjectile'
     BotRefireRate=0.990000
     WarnTargetPct=0.100000
     FlashEmitterClass=Class'XEffects.LinkMuzFlashProj1st'
}
