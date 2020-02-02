class PainterAttachment extends xWeaponAttachment;

var LinkMuzFlashProj3rd MuzFlash;

simulated function Destroyed()
{
    if (MuzFlash != None)
        MuzFlash.Destroy();

    Super.Destroyed();
}

simulated event ThirdPersonEffects()
{
    local Rotator R;

    if ( Level.NetMode != NM_DedicatedServer && FlashCount > 0 )
	{
        if ( FiringMode == 0 )
        {
            if (MuzFlash == None)
            {
                //MuzFlash = Spawn(class'LinkMuzFlashProj3rd');
                //AttachToBone(MuzFlash, 'tip');
            }
            if (MuzFlash != None)
            {
                MuzFlash.Trigger(self, None);
                R.Roll = Rand(65536);
                SetBoneRotation('bone flashA', R, 0, 1.0);
            }
        }
    }

    Super.ThirdPersonEffects();
}

defaultproperties
{
     Mesh=SkeletalMesh'Weapons.Painter_3rd'
}
