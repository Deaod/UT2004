class MinigunMuzFlash1st extends xEmitter;

#exec OBJ LOAD FILE=xGameShaders.utx

#exec STATICMESH IMPORT NAME=MinigunMuzFlash1stMesh FILE=Models\MinigunMuzFlash1st.lwo COLLISION=0

var int mNumPerFlash;

simulated function Trigger(Actor Other, Pawn EventInstigator)
{
    mStartParticles += mNumPerFlash;
}

defaultproperties
{
     mNumPerFlash=5
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
     mSizeRange(0)=0.050000
     mSizeRange(1)=0.080000
     mGrowthRate=3.000000
     mRandTextures=True
     mTileAnimation=True
     mNumTileColumns=2
     mNumTileRows=2
     mMeshNodes(0)=StaticMesh'XEffects.MinigunMuzFlash1stMesh'
     DrawScale=0.900000
     Skins(0)=FinalBlend'XGameShaders.WeaponShaders.MinigunMuzFlash1stFinal'
     Style=STY_Additive
}
