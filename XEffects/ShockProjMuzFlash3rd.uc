class ShockProjMuzFlash3rd extends xEmitter;

#exec OBJ LOAD FILE=xGameShaders.utx

var int mNumPerFlash;

simulated function Trigger(Actor Other, Pawn EventInstigator)
{
    mStartParticles += mNumPerFlash;
}

defaultproperties
{
     mNumPerFlash=1
     mParticleType=PT_Mesh
     mStartParticles=0
     mMaxParticles=6
     mLifeRange(0)=0.130000
     mLifeRange(1)=0.130000
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mSpawnVecB=(Z=0.000000)
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mPosRelative=True
     mAirResistance=0.000000
     mRandOrient=True
     mSizeRange(0)=0.350000
     mSizeRange(1)=0.400000
     mGrowthRate=3.200000
     mColorRange(0)=(R=50)
     mColorRange(1)=(R=50)
     mAttenKa=0.000000
     mRandTextures=True
     mMeshNodes(0)=StaticMesh'XEffects.MinigunFlashMesh'
     Skins(0)=FinalBlend'XGameShaders.WeaponShaders.ShockMuzFlash3rdFinal'
     Style=STY_Additive
}
