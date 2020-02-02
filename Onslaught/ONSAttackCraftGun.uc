//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSAttackCraftGun extends ONSWeapon;

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx

var class<Projectile> TeamProjectileClasses[2];
var float MinAim;

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStarRed');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaHeadRed');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaHeadBlue');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels1');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar2');
    L.AddPrecacheMaterial(Material'EpicParticles.Flares.FlashFlare1');
    L.AddPrecacheMaterial(Material'EmitterTextures.MultiFrame.rockchunks02');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaFlare');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStarRed');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaHeadRed');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaHeadBlue');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels1');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar2');
    Level.AddPrecacheMaterial(Material'EpicParticles.Flares.FlashFlare1');
    Level.AddPrecacheMaterial(Material'EmitterTextures.MultiFrame.rockchunks02');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaFlare');

    Super.UpdatePrecacheMaterials();
}

function byte BestMode()
{
	local bot B;

	B = Bot(Instigator.Controller);
	if ( B == None )
		return 0;

	if ( (Vehicle(B.Enemy) != None)
	     && (B.Enemy.bCanFly || B.Enemy.IsA('ONSHoverCraft')) && (FRand() < 0.3 + 0.1 * B.Skill) )
		return 1;
	else
		return 0;
}

state ProjectileFireMode
{
	function Fire(Controller C)
	{
		if (Vehicle(Owner) != None && Vehicle(Owner).Team < 2)
			ProjectileClass = TeamProjectileClasses[Vehicle(Owner).Team];
		else
			ProjectileClass = TeamProjectileClasses[0];

		Super.Fire(C);
	}

	function AltFire(Controller C)
	{
		local ONSAttackCraftMissle M;
		local Vehicle V, Best;
		local float CurAim, BestAim;

		M = ONSAttackCraftMissle(SpawnProjectile(AltFireProjectileClass, True));
		if (M != None)
		{
			if (AIController(Instigator.Controller) != None)
			{
				V = Vehicle(Instigator.Controller.Enemy);
				if (V != None && (V.bCanFly || V.IsA('ONSHoverCraft')) && Instigator.FastTrace(V.Location, Instigator.Location))
					M.SetHomingTarget(V);
			}
			else
			{
				BestAim = MinAim;
				for (V = Level.Game.VehicleList; V != None; V = V.NextVehicle)
					if ((V.bCanFly || V.IsA('ONSHoverCraft')) && V != Instigator && Instigator.GetTeamNum() != V.GetTeamNum())
					{
						CurAim = Normal(V.Location - WeaponFireLocation) dot vector(WeaponFireRotation);
						if (CurAim > BestAim && Instigator.FastTrace(V.Location, Instigator.Location))
						{
							Best = V;
							BestAim = CurAim;
						}
					}
				if (Best != None)
					M.SetHomingTarget(Best);
			}
		}
	}
}

defaultproperties
{
     TeamProjectileClasses(0)=Class'Onslaught.ONSAttackCraftPlasmaProjectileRed'
     TeamProjectileClasses(1)=Class'Onslaught.ONSAttackCraftPlasmaProjectileBlue'
     MinAim=0.900000
     YawBone="PlasmaGunBarrel"
     PitchBone="PlasmaGunBarrel"
     PitchUpLimit=18000
     PitchDownLimit=49153
     WeaponFireAttachmentBone="PlasmaGunBarrel"
     DualFireOffset=50.000000
     RotationsPerSecond=1.200000
     FireInterval=0.200000
     AltFireInterval=3.000000
     FireSoundClass=Sound'ONSVehicleSounds-S.LaserSounds.Laser01'
     AltFireSoundClass=Sound'ONSVehicleSounds-S.AVRiL.AvrilFire01'
     FireForce="Laser01"
     AltFireForce="Laser01"
     ProjectileClass=Class'Onslaught.ONSAttackCraftPlasmaProjectileRed'
     AltFireProjectileClass=Class'Onslaught.ONSAttackCraftMissle'
     AIInfo(0)=(bLeadTarget=True,RefireRate=0.950000)
     AIInfo(1)=(bLeadTarget=True,aimerror=400.000000,RefireRate=0.500000)
     Mesh=SkeletalMesh'ONSWeapons-A.PlasmaGun'
}
