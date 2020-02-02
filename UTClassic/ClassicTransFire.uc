class ClassicTransFire extends TransFire;


function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local TransBeacon TransBeacon;

    if (TransLauncher(Weapon).TransBeacon == None)
    {
		if ( (Instigator == None) || (Instigator.PlayerReplicationInfo == None) || (Instigator.PlayerReplicationInfo.Team == None) )
			TransBeacon = Weapon.Spawn(class'ClassicTransBeacon',,, Start, Dir);
		else if ( Instigator.PlayerReplicationInfo.Team.TeamIndex == 0 )
			TransBeacon = Weapon.Spawn(class'ClassicRedBeacon',,, Start, Dir);
		else
			TransBeacon = Weapon.Spawn(class'ClassicBlueBeacon',,, Start, Dir);
        TransLauncher(Weapon).TransBeacon = TransBeacon;
        Weapon.PlaySound(TransFireSound,SLOT_Interact,,,,,false);
    }
    else
    {
        TransLauncher(Weapon).ViewPlayer();
        TransLauncher(Weapon).TransBeacon.Destroy();
        TransLauncher(Weapon).TransBeacon = None;
        Weapon.PlaySound(RecallFireSound,SLOT_Interact,,,,,false);
    }
    return TransBeacon;
}

defaultproperties
{
     ProjectileClass=Class'UTClassic.ClassicTransBeacon'
}
