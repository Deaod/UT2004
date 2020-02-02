class LinkProjSparks extends xEmitter;

#exec OBJ LOAD FILE=XEffectMat.utx

defaultproperties
{
     mParticleType=PT_Line
     mRegen=False
     mStartParticles=8
     mMaxParticles=8
     mLifeRange(0)=0.500000
     mLifeRange(1)=0.500000
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mDirDev=(X=1.500000,Y=1.500000,Z=1.500000)
     mPosDev=(X=10.000000,Y=10.000000,Z=10.000000)
     mSpawnVecB=(X=14.000000,Z=0.060000)
     mSpeedRange(0)=100.000000
     mSpeedRange(1)=175.000000
     mMassRange(0)=2.000000
     mMassRange(1)=2.000000
     mSizeRange(0)=8.000000
     mSizeRange(1)=12.000000
     mColorRange(0)=(B=150,G=150,R=150)
     mColorRange(1)=(B=150,G=150,R=150)
     mAttenKa=0.100000
     Skins(0)=Texture'XEffectMat.Link.link_spark_green'
     Style=STY_Translucent
}
