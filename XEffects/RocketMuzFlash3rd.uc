class RocketMuzFlash3rd extends xEmitter;

var int mNumPerFlash;

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
     mSizeRange(0)=0.120000
     mSizeRange(1)=0.120000
     mGrowthRate=2.200000
     mRandTextures=True
     mMeshNodes(0)=StaticMesh'XEffects.MinigunFlashMesh'
     Skins(0)=FinalBlend'XGameShaders.WeaponShaders.MinigunFlashFinal'
     Style=STY_Additive
}
