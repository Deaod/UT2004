class LinkMuzFlashProj1st extends xEmitter;
 
#exec OBJ LOAD FILE=xGameShaders.utx
#exec OBJ LOAD FILE=XEffectMat.utx

var int mNumPerFlash;

simulated function Trigger(Actor Other, Pawn EventInstigator)
{
    mStartParticles += mNumPerFlash;
}

defaultproperties
{
     mNumPerFlash=2
     mParticleType=PT_Mesh
     mStartParticles=0
     mMaxParticles=5
     mLifeRange(0)=0.100000
     mLifeRange(1)=0.140000
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
     mColorRange(0)=(B=75,G=75,R=75)
     mColorRange(1)=(B=75,G=75,R=75)
     mRandTextures=True
     mNumTileColumns=2
     mNumTileRows=2
     mMeshNodes(0)=StaticMesh'XEffects.LinkMuzFlashMesh'
     bHidden=True
     Skins(0)=FinalBlend'XEffectMat.Link.LinkMuzProjGreenFB'
}
