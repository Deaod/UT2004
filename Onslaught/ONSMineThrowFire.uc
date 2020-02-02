//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSMineThrowFire extends BioFire;

var class<Projectile> RedMineClass;
var class<Projectile> BlueMineClass;

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;
    local int x;

    if (Weapon.Instigator.GetTeamNum() == 0)
        ProjectileClass = RedMineClass;

    if (Weapon.Instigator.GetTeamNum() == 1)
        ProjectileClass = BlueMineClass;

    if( ProjectileClass != None )
        p = Weapon.Spawn(ProjectileClass, Weapon,, Start, Dir);

    if( p == None )
        return None;

    p.Damage *= DamageAtten;
    if (ONSMineLayer(Weapon) != None)
    {
        if (ONSMineLayer(Weapon).CurrentMines >= ONSMineLayer(Weapon).MaxMines)
	{
		for (x = 0; x < ONSMineLayer(Weapon).Mines.length; x++)
		{
			if (ONSMineLayer(Weapon).Mines[x] == None)
			{
				ONSMineLayer(Weapon).Mines.Remove(x, 1);
				x--;
			}
			else
			{
				ONSMineLayer(Weapon).Mines[x].Destroy();
				ONSMineLayer(Weapon).Mines.Remove(x, 1);
				break;
			}
		}
	}
	ONSMineLayer(Weapon).Mines[ONSMineLayer(Weapon).Mines.length] = p;
    	ONSMineLayer(Weapon).CurrentMines++;
    }

    return p;
}

function PlayFiring()
{
    Super.PlayFiring();
    ONSMineLayer(Weapon).PlayFiring(true);
}

defaultproperties
{
     RedMineClass=Class'Onslaught.ONSMineProjectileRED'
     BlueMineClass=Class'Onslaught.ONSMineProjectileBLUE'
     FireSound=Sound'ONSVehicleSounds-S.SpiderMines.SpiderMineFire01'
     FireRate=1.100000
     AmmoClass=Class'Onslaught.ONSMineAmmo'
     ProjectileClass=Class'Onslaught.ONSMineProjectile'
}
