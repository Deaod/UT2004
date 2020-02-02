//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSBombDropper extends ONSWeapon;

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx

//state ProjectileFireMode
//{
//    function SpawnProjectile(class<Projectile> ProjClass)
//    {
//        local Projectile P;
//
//        P = spawn(ProjClass, self, , WeaponFireLocation, WeaponFireRotation);
//
//    	if (P != None)
//    	{
//            P.Velocity = Instigator.Velocity + (vect(0,0,-1000) << Owner.Rotation);
//
//            // Play firing noise
//            PlaySound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,,,, false);
//        }
//    }
//}

defaultproperties
{
     YawStartConstraint=65535.000000
     YawEndConstraint=-65535.000000
     PitchUpLimit=65535
     PitchDownLimit=-65535
     WeaponFireAttachmentBone="PlasmaGunBarrel"
     bAimable=False
     bInheritVelocity=True
     FireInterval=0.400000
     FireSoundClass=SoundGroup'WeaponSounds.RocketLauncher.RocketLauncherFire'
     ProjectileClass=Class'OnslaughtFull.ONSBomberRocketProjectile'
     Mesh=SkeletalMesh'ONSWeapons-A.PlasmaGun'
}
