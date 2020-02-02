//=============================================================================
// FM_SpaceFighter_AltFire
//=============================================================================

class FM_SpaceFighter_AltFire extends ProjectileFire;

function DoFireEffect()
{
	// Get Rocket spawn location
	if ( ASVehicle_SpaceFighter(Instigator) != None )
		ProjSpawnOffset = ASVehicle_SpaceFighter(Instigator).GetRocketSpawnLocation();

	MyDoFireEffect();
}

function MyDoFireEffect()
{
	local Vector Start, X,Y,Z;

	Instigator.MakeNoise(1.0);
	GetAxes(Instigator.Rotation, X, Y, Z);

	Start = MyGetFireStart(X, Y, Z);

	SpawnProjectile(Start, Instigator.Rotation);
}

function Projectile SpawnProjectile(vector Start, rotator Dir)
{
	local PROJ_SpaceFighter_Rocket	P;
	local Vehicle					Target;

	P = PROJ_SpaceFighter_Rocket(super.SpawnProjectile(Start, Dir));

	if ( P != None && ASVehicle_SpaceFighter_Skaarj(Instigator) != None )	// hack for Skaarj SF damagetype
		P.MyDamageType = class'DamTypeSpaceFighterMissileSkaarj';

	if ( P != None && ASVehicle_SpaceFighter(Instigator) != None )
	{
		if ( Instigator.Controller.IsA('PlayerController') )
			Target = ASVehicle_SpaceFighter(Instigator).CurrentTarget;
		else if ( Instigator.Controller.IsA('Bot') && Instigator.Controller.Enemy != None 
			&& (Bot(Instigator.Controller).Skill > FRand() * 5.f) )
		{
			// very basic AI to target enemies...
			Target = Vehicle(Instigator.Controller.Enemy);
		}
	}

	// Check that Target is directly visible
	if ( Target != None && Normal(Target.Location - Instigator.Location) Dot Vector(Instigator.Rotation) > 0 
		&& Weapon.FastTrace( Target.Location, Instigator.Location ) )
	{
		P.HomingTarget = Target;
		Target.NotifyEnemyLockedOn();
	}

	return P;
}

simulated function vector MyGetFireStart(vector X, vector Y, vector Z)
{
    return Instigator.Location + X*ProjSpawnOffset.X + Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;
}


simulated function bool AllowFire()
{
    return true;
}


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     ProjSpawnOffset=(Z=-25.000000)
     bSplashDamage=True
     bSplashJump=True
     bRecommendSplashDamage=True
     bModeExclusive=False
     TweenTime=0.000000
     FireSound=Sound'AssaultSounds.HumanShip.HnShipFire02'
     FireForce="RocketLauncherFire"
     FireRate=4.000000
     AmmoClass=Class'UT2k4Assault.Ammo_Dummy'
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-20.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     ProjectileClass=Class'UT2k4AssaultFull.PROJ_SpaceFighter_Rocket'
     BotRefireRate=0.500000
     WarnTargetPct=0.900000
}
