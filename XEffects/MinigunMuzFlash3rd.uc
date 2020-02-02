class MinigunMuzFlash3rd extends xEmitter;

// muzzle flash //
#exec STATICMESH IMPORT     NAME=MinigunFlashMesh FILE=Models\MinigunFlash.lwo COLLISION=0
 
var int mNumPerFlash;

function Trigger(Actor Other, Pawn EventInstigator)
{
    mStartParticles = mNumPerFlash;
    mGrowthRate = default.mGrowthRate;
    mLifeRange[0] = default.mLifeRange[0];
    mLifeRange[1] = default.mLifeRange[1];
}

defaultproperties
{
     mNumPerFlash=1
     mParticleType=PT_Mesh
     mStartParticles=0
     mMaxParticles=6
     mLifeRange(0)=0.150000
     mLifeRange(1)=0.200000
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mSpawnVecB=(Z=0.000000)
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mPosRelative=True
     mAirResistance=0.000000
     mRandOrient=True
     mSizeRange(0)=0.050000
     mSizeRange(1)=0.080000
     mGrowthRate=2.200000
     mRandTextures=True
     mMeshNodes(0)=StaticMesh'XEffects.MinigunFlashMesh'
     Skins(0)=FinalBlend'XGameShaders.WeaponShaders.MinigunFlashFinal'
     Style=STY_Additive
}
