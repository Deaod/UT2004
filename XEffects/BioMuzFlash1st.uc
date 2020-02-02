class BioMuzFlash1st extends xEmitter;
 
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
     mMaxParticles=5
     mLifeRange(0)=0.100000
     mLifeRange(1)=0.150000
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mSpawnVecB=(Z=0.000000)
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mPosRelative=True
     mAirResistance=0.000000
     mRandOrient=True
     mSizeRange(0)=0.600000
     mSizeRange(1)=0.800000
     mGrowthRate=10.000000
     mColorRange(0)=(B=180,G=180,R=180)
     mColorRange(1)=(B=180,G=180,R=180)
     mMeshNodes(0)=StaticMesh'XEffects.FlakMuzFlashMesh'
     bHidden=True
     Skins(0)=FinalBlend'XGameShaders.WeaponShaders.BioFlashFinal'
}
