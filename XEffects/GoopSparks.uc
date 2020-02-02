class GoopSparks extends xEmitter;

#exec OBJ LOAD FILE=XEffectMat.utx

defaultproperties
{
     mParticleType=PT_Line
     mRegen=False
     mStartParticles=10
     mMaxParticles=10
     mLifeRange(0)=0.500000
     mLifeRange(1)=0.800000
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mDirDev=(X=0.800000,Y=0.800000,Z=0.800000)
     mSpawnVecB=(X=8.000000,Z=0.040000)
     mSpeedRange(0)=80.000000
     mSpeedRange(1)=240.000000
     mMassRange(0)=1.500000
     mMassRange(1)=2.000000
     mAirResistance=2.000000
     mSizeRange(0)=4.000000
     mSizeRange(1)=4.000000
     mGrowthRate=-2.000000
     mColorRange(0)=(B=180,G=160,R=160)
     mColorRange(1)=(B=180,G=160,R=160)
     mAttenKa=0.000000
     Skins(0)=Texture'XEffectMat.Link.link_spark_green'
     ScaleGlow=2.000000
     Style=STY_Additive
}
