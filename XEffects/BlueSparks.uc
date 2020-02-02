//=============================================================================
// BlueSparks.
//=============================================================================
class BlueSparks extends xEmitter;

#exec TEXTURE IMPORT NAME=pcl_BlueSpark FILE=TEXTURES\BlueSpark.tga GROUP=Skins ALPHA=1 DXT=5

defaultproperties
{
     mParticleType=PT_Line
     mRegen=False
     mStartParticles=20
     mMaxParticles=10
     mLifeRange(0)=0.800000
     mLifeRange(1)=1.200000
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mDirDev=(X=0.400000,Y=0.400000,Z=0.400000)
     mPosDev=(X=0.200000,Y=0.200000,Z=0.200000)
     mSpawnVecB=(X=2.000000,Z=0.060000)
     mSpeedRange(0)=250.000000
     mSpeedRange(1)=350.000000
     mMassRange(0)=1.500000
     mMassRange(1)=2.500000
     mAirResistance=0.200000
     mSizeRange(0)=1.000000
     mSizeRange(1)=2.000000
     mGrowthRate=-1.000000
     mAttenKa=0.100000
     bHighDetail=True
     Skins(0)=Texture'XEffects.Skins.pcl_BlueSpark'
     ScaleGlow=2.000000
     Style=STY_Additive
}
