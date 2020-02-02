class RedeemerGuidedFire extends RedeemerFire;

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local RedeemerWarhead Warhead;
	local PlayerController Possessor;
	
    Warhead = Weapon.Spawn(class'XWeapons.RedeemerWarhead', Instigator,, Start, Dir);
    if (Warhead == None)
		Warhead = Weapon.Spawn(class'XWeapons.RedeemerWarhead', Instigator,, Instigator.Location, Dir);
    if (Warhead != None)
    {
		Warhead.OldPawn = Instigator;
		Warhead.PlaySound(FireSound);
		Possessor = PlayerController(Instigator.Controller);
		Possessor.bAltFire = 0;
		if ( Possessor != None )
		{
			if ( Instigator.InCurrentCombo() )
				Possessor.Adrenaline = 0;
			Possessor.UnPossess();
			Instigator.SetOwner(Possessor);
			Instigator.PlayerReplicationInfo = Possessor.PlayerReplicationInfo;
			Possessor.Possess(Warhead);
		}
		Warhead.Velocity = Warhead.AirSpeed * Vector(Warhead.Rotation);
		Warhead.Acceleration = Warhead.Velocity;
		WarHead.MyTeam = Possessor.PlayerReplicationInfo.Team;
    }
    else 
    {
	 	Weapon.Spawn(class'SmallRedeemerExplosion');	
		Weapon.HurtRadius(500, 400, class'DamTypeRedeemer', 100000, Instigator.Location);
	}

	bIsFiring = false;
    StopFiring();
    return None;
}

defaultproperties
{
}
