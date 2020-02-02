//=============================================================================
// WallSparks.
//=============================================================================
class WallSparks extends xEmitter;

#exec TEXTURE IMPORT NAME=pcl_Spark FILE=TEXTURES\Spark.tga GROUP=Skins ALPHA=1 DXT=5

defaultproperties
{
     mParticleType=PT_Line
     mRegen=False
     mStartParticles=8
     mMaxParticles=8
     mLifeRange(0)=0.500000
     mLifeRange(1)=0.800000
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mDirDev=(X=0.600000,Y=0.600000,Z=0.600000)
     mPosDev=(X=0.800000,Y=0.800000,Z=0.800000)
     mSpawnVecB=(X=5.000000,Z=0.030000)
     mSpeedRange(0)=50.000000
     mSpeedRange(1)=300.000000
     mMassRange(0)=1.500000
     mMassRange(1)=2.500000
     mAirResistance=0.000000
     mSizeRange(0)=3.000000
     mSizeRange(1)=2.000000
     mGrowthRate=-4.000000
     mAttenKa=0.000000
     Skins(0)=Texture'XEffects.Skins.pcl_Spark'
     ScaleGlow=2.000000
     Style=STY_Additive
}
