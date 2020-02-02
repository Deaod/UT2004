class TransFire extends ProjectileFire;

var() Sound TransFireSound;
var() Sound RecallFireSound;
var() String TransFireForce;
var() String RecallFireForce;

simulated function PlayFiring()
{
    if (!TransLauncher(Weapon).bBeaconDeployed)
    {
        Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
        ClientPlayForceFeedback( TransFireForce );  // jdf
    }
}

function Rotator AdjustAim(Vector Start, float InAimError)
{
    return Instigator.Controller.Rotation;
}

simulated function bool AllowFire()
{
    return ( TransLauncher(Weapon).AmmoChargeF >= 1.0 );
}

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local TransBeacon TransBeacon;

    if (TransLauncher(Weapon).TransBeacon == None)
    {
		if ( (Instigator == None) || (Instigator.PlayerReplicationInfo == None) || (Instigator.PlayerReplicationInfo.Team == None) )
			TransBeacon = Weapon.Spawn(class'XWeapons.TransBeacon',,, Start, Dir);
		else if ( Instigator.PlayerReplicationInfo.Team.TeamIndex == 0 )
			TransBeacon = Weapon.Spawn(class'XWeapons.RedBeacon',,, Start, Dir);
		else
			TransBeacon = Weapon.Spawn(class'XWeapons.BlueBeacon',,, Start, Dir);
        TransLauncher(Weapon).TransBeacon = TransBeacon;
        Weapon.PlaySound(TransFireSound,SLOT_Interact,,,,,false);
    }
    else
    {
        TransLauncher(Weapon).ViewPlayer();
        if ( TransLauncher(Weapon).TransBeacon.Disrupted() )
        {
			if( (Instigator != None) && (PlayerController(Instigator.Controller) != None) )
				PlayerController(Instigator.Controller).ClientPlaySound(Sound'WeaponSounds.BSeekLost1');
		}
		else
		{
			TransLauncher(Weapon).TransBeacon.Destroy();
			TransLauncher(Weapon).TransBeacon = None;
			Weapon.PlaySound(RecallFireSound,SLOT_Interact,,,,,false);
		}
    }
    return TransBeacon;
}

defaultproperties
{
     TransFireSound=SoundGroup'WeaponSounds.Translocator.TranslocatorFire'
     RecallFireSound=SoundGroup'WeaponSounds.Translocator.TranslocatorModuleRegeneration'
     TransFireForce="TranslocatorFire"
     RecallFireForce="TranslocatorModuleRegeneration"
     ProjSpawnOffset=(X=25.000000,Y=8.000000)
     bLeadTarget=False
     bWaitForRelease=True
     bModeExclusive=False
     FireAnimRate=1.500000
     FireRate=0.250000
     AmmoPerFire=1
     ProjectileClass=Class'XWeapons.TransBeacon'
     BotRefireRate=0.300000
}
