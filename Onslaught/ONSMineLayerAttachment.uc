//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSMineLayerAttachment extends xWeaponAttachment;

var xEmitter MuzFlash3rd;

simulated function Destroyed()
{
    if (MuzFlash3rd != None)
        MuzFlash3rd.Destroy();
    Super.Destroyed();
}

simulated event ThirdPersonEffects()
{
//    local Rotator R;
//
//    if ( Level.NetMode != NM_DedicatedServer && FlashCount > 0 )
//    {
//        if (MuzFlash3rd == None)
//        {
//            MuzFlash3rd = Spawn(class'XEffects.BioMuzFlash1st');
//            MuzFlash3rd.bHidden = false;
//            AttachToBone(MuzFlash3rd, 'tip');
//        }
//        if (MuzFlash3rd != None)
//        {
//            R.Roll = Rand(65536);
//            SetBoneRotation('Bone_Flash', R, 0, 1.0);
//            MuzFlash3rd.mStartParticles++;
//        }
//    }

    Super.ThirdPersonEffects();
}

defaultproperties
{
     bHeavy=True
     Mesh=SkeletalMesh'ONSWeapons-A.MineLayer_3rd'
     DrawScale=0.280000
}
