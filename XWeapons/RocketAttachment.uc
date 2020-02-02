class RocketAttachment extends xWeaponAttachment;

var class<xEmitter>     MuzFlashClass;
var xEmitter            MuzFlash;

simulated function Destroyed()
{
    if (MuzFlash != None)
        MuzFlash.Destroy();

    Super.Destroyed();
}

simulated event ThirdPersonEffects()
{
    local rotator r;

    if ( Level.NetMode != NM_DedicatedServer && FlashCount > 0 )
	{
        if (MuzFlash == None)
        {
            MuzFlash = Spawn(MuzFlashClass);
            if ( MuzFlash != None )
				AttachToBone(MuzFlash, 'tip');
        }
        if (MuzFlash != None)
        {
            MuzFlash.mStartParticles++;
            r.Roll = Rand(65536);
            SetBoneRotation('Bone_Flash', r, 0, 1.f);
        }
    }

    Super.ThirdPersonEffects();
}

defaultproperties
{
     MuzFlashClass=Class'XEffects.RocketMuzFlash3rd'
     bHeavy=True
     Mesh=SkeletalMesh'Weapons.RocketLauncher_3rd'
}
