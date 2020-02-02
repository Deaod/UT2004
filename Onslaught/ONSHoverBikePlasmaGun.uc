//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSHoverBikePlasmaGun extends ONSWeapon;

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaHead');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels1');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar2');
    L.AddPrecacheMaterial(Material'EpicParticles.Flares.FlashFlare1');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaHeadDesat');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaHead');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels1');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar2');
    Level.AddPrecacheMaterial(Material'EpicParticles.Flares.FlashFlare1');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaHeadDesat');

    Super.UpdatePrecacheMaterials();
}

state ProjectileFireMode
{
    function AltFire(Controller C)
    {
    }
}

defaultproperties
{
     YawBone="PlasmaGunBarrel"
     YawStartConstraint=57344.000000
     YawEndConstraint=8192.000000
     PitchBone="PlasmaGunBarrel"
     WeaponFireAttachmentBone="PlasmaGunBarrel"
     WeaponFireOffset=25.000000
     DualFireOffset=25.000000
     RotationsPerSecond=0.800000
     FireInterval=0.200000
     AltFireInterval=0.500000
     FireSoundClass=Sound'ONSVehicleSounds-S.HoverBike.HoverBikeFire01'
     FireForce="HoverBikeFire"
     ProjectileClass=Class'Onslaught.ONSHoverBikePlasmaProjectile'
     AIInfo(0)=(bLeadTarget=True)
     AIInfo(1)=(bLeadTarget=True)
     Mesh=SkeletalMesh'ONSWeapons-A.PlasmaGun'
}
