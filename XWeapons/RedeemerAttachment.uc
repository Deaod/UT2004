class RedeemerAttachment extends xWeaponAttachment;

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
                SetBoneRotation('bone flash', R, 0, 1.0);
            }
        }
    }

    Super.ThirdPersonEffects();
}

defaultproperties
{
     bHeavy=True
     CullDistance=5000.000000
     Mesh=SkeletalMesh'Weapons.Redeemer_3rd'
     RelativeLocation=(X=-35.000000)
     RelativeRotation=(Yaw=49152,Roll=32768)
     DrawScale=0.600000
}
