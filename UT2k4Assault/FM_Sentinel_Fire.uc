//=============================================================================
// FM_Sentinel_Fire
//=============================================================================

class FM_Sentinel_Fire extends ProjectileFire;

var	class<Projectile>	TeamProjectileClasses[2];


function DoFireEffect()
{
	local Vector	ProjOffset;
	local Vector	Start, X,Y,Z, HL, HN;

	if ( Instigator.IsA('ASVehicle') )
		ProjOffset = ASVehicle(Instigator).VehicleProjSpawnOffset;

	ProjSpawnOffset = ProjOffset;

	Instigator.MakeNoise(1.0);
    Instigator.GetAxes(Instigator.Rotation, X, Y, Z);

	Start = MyGetFireStart(X, Y, Z);

	ASVehicle(Instigator).CalcWeaponFire( HL, HN );
	SpawnProjectile(Start, Rotator(HL - Start));
}

simulated function vector MyGetFireStart(vector X, vector Y, vector Z)
{
    return Instigator.Location + X*ProjSpawnOffset.X + Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;
}


function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;

	p = Weapon.Spawn(TeamProjectileClasses[Instigator.GetTeamNum()], Instigator, , Start, Dir);
    if ( p == None )
        return None;

    p.Damage *= DamageAtten;
    return p;
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
     TeamProjectileClasses(0)=Class'UT2k4Assault.PROJ_Sentinel_Laser_Red'
     TeamProjectileClasses(1)=Class'UT2k4Assault.PROJ_Sentinel_Laser'
     ProjSpawnOffset=(X=200.000000,Y=14.000000,Z=-14.000000)
     FireLoopAnim=
     FireEndAnim=
     FireAnimRate=0.450000
     TweenTime=0.000000
     FireSound=Sound'AssaultSounds.HumanShip.HnShipFire01'
     FireForce="TranslocatorFire"
     FireRate=0.250000
     AmmoClass=Class'UT2k4Assault.Ammo_Dummy'
     ShakeRotMag=(X=40.000000)
     ShakeRotRate=(X=2000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(Y=1.000000)
     ShakeOffsetRate=(Y=-2000.000000)
     ShakeOffsetTime=4.000000
     BotRefireRate=0.990000
     WarnTargetPct=0.400000
}
