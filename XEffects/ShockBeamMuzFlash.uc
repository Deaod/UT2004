class ShockBeamMuzFlash extends xEmitter;

#exec OBJ LOAD FILE=XEffectMat.utx

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
     mLifeRange(0)=0.140000
     mLifeRange(1)=0.140000
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mSpawnVecB=(Z=0.000000)
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mPosRelative=True
     mAirResistance=0.000000
     mSizeRange(0)=0.500000
     mSizeRange(1)=0.500000
     mGrowthRate=5.000000
     mAttenKa=0.000000
     mMeshNodes(0)=StaticMesh'WeaponStaticMesh.ShockMuzFlash'
     Skins(0)=FinalBlend'XEffectMat.Shock.ShockFlashFB'
     Style=STY_Additive
}
