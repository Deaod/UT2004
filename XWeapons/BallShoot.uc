class BallShoot extends ProjectileFire;

simulated function bool AllowFire()
{
    return true;
}

function ModeDoFire()
{
    local xBombFlag Bomb;
    local Translauncher T;
    
    Bomb = xBombFlag( Instigator.PlayerReplicationInfo.HasFlag );
 	if ( Bomb.bBallDrainsTransloc )
 	{
		T = Translauncher(Instigator.FindInventoryType(class'Translauncher'));
		if ( T != None )
			T.DrainCharges();		
	}
    Super.ModeDoFire();
    
    // make sure to switch to a new weapon
    if (PlayerController(Instigator.Controller) != None && Instigator.IsLocallyControlled()
        && (Instigator.PendingWeapon == Weapon || Instigator.PendingWeapon == None))
    {
        PlayerController(Instigator.Controller).ClientSwitchToBestWeapon();
    }
}

function DoFireEffect()
{
    local xBombFlag Bomb;
    
    if (Weapon.Role != ROLE_Authority)
        return;

    if( Instigator.PlayerReplicationInfo.HasFlag == None )
        return;
    
    Bomb = xBombFlag( Instigator.PlayerReplicationInfo.HasFlag );

    if ( Bomb == None )
        return;

    BallLauncher(Weapon).launchedBall = true;
	Super.DoFireEffect();
}

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local xBombFlag bomb;
    local vector ThrowDir;

    Bomb = xBombFlag ( Weapon.Instigator.Controller.PlayerReplicationInfo.HasFlag );
    Bomb.PassTarget = BallLauncher(Weapon).PassTarget;
	ThrowDir = Bomb.ThrowSpeed * vector(Dir);
	bomb.Throw(Start, ThrowDir);
	BallLauncher(Weapon).PassTarget = None;
    return None;
}

defaultproperties
{
     bWaitForRelease=True
     bModeExclusive=False
     FireSound=Sound'WeaponSounds.Misc.ballgun_launch'
     FireForce="ballgun_launch"
     FireRate=0.250000
     AmmoClass=Class'XWeapons.BallAmmo'
}
