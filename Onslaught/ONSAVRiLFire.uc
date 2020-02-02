class ONSAVRiLFire extends ProjectileFire;

var vector  KickMomentum;
var float ReloadAnimDelay;

function PlayFiring()
{
    Super.PlayFiring();
    if (Weapon.HasAnim(ReloadAnim))
	   SetTimer(ReloadAnimDelay, false);
}

function Projectile SpawnProjectile(vector Start, rotator Dir)
{
	local Projectile P;

	P = Super.SpawnProjectile(Start, Dir);
	if (P != None)
		P.SetOwner(Weapon);

	return P;
}

function Timer()
{
	if (Weapon.ClientState == WS_ReadyToFire)
	{
		Weapon.PlayAnim(ReloadAnim, ReloadAnimRate, TweenTime);
		Weapon.PlaySound(ReloadSound,SLOT_None,,,512.0,,false);
		ClientPlayForceFeedback(ReloadForce);
	}
}

function ShakeView()
{
    Super.ShakeView();

    if (Instigator != None)
        Instigator.AddVelocity(KickMomentum >> Instigator.Rotation);
}

function float MaxRange()
{
	return 15000;
}

function StartBerserk()
{
	if (Level.GRI != None && Level.GRI.WeaponBerserk > 1.0)
		return;

	Super.StartBerserk();

	ReloadAnimDelay = default.ReloadAnimDelay * 0.75;
}

function StopBerserk()
{
	if (Level.GRI != None && Level.GRI.WeaponBerserk > 1.0)
		return;

	Super.StopBerserk();

	ReloadAnimDelay = default.ReloadAnimDelay;
}

function StartSuperBerserk()
{
	Super.StartSuperBerserk();

	ReloadAnimDelay = default.ReloadAnimDelay / Level.GRI.WeaponBerserk;
}

defaultproperties
{
     KickMomentum=(X=-350.000000,Z=175.000000)
     ReloadAnimDelay=1.000000
     ProjSpawnOffset=(X=25.000000,Y=6.000000,Z=-6.000000)
     bSplashDamage=True
     bModeExclusive=False
     FireAnimRate=1.100000
     ReloadAnimRate=1.350000
     TweenTime=0.000000
     FireSound=Sound'ONSVehicleSounds-S.AVRiL.AvrilFire01'
     ReloadSound=Sound'ONSVehicleSounds-S.AVRiL.AvrilReload01'
     FireForce="AVRiLFire"
     ReloadForce="AVRiLReload"
     FireRate=4.000000
     AmmoClass=Class'Onslaught.ONSAVRiLAmmo'
     AmmoPerFire=1
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-20.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     ProjectileClass=Class'Onslaught.ONSAVRiLRocket'
     BotRefireRate=0.500000
     WarnTargetPct=1.000000
}
