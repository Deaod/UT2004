//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSMASSideGun extends ONSWeapon;

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaHead');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels1');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar2');
    L.AddPrecacheMaterial(Material'EpicParticles.Flares.FlashFlare1');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaHead');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels1');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar2');
    Level.AddPrecacheMaterial(Material'EpicParticles.Flares.FlashFlare1');

    Super.UpdatePrecacheMaterials();
}

defaultproperties
{
     YawBone="Object83"
     PitchBone="Object83"
     PitchUpLimit=15000
     WeaponFireAttachmentBone="Object85"
     GunnerAttachmentBone="Object83"
     WeaponFireOffset=20.000000
     DualFireOffset=10.000000
     bDoOffsetTrace=True
     FireInterval=0.150000
     AltFireInterval=0.150000
     FireSoundClass=Sound'ONSVehicleSounds-S.LaserSounds.Laser17'
     AltFireSoundClass=Sound'ONSVehicleSounds-S.LaserSounds.Laser17'
     FireForce="Laser01"
     AltFireForce="Laser01"
     DamageType=Class'Onslaught.DamTypePRVLaser'
     DamageMin=25
     DamageMax=25
     ProjectileClass=Class'OnslaughtFull.ONSMASPlasmaProjectile'
     Mesh=SkeletalMesh'ONSFullAnimations.MASPassengerGun'
}
