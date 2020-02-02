//=============================================================================
// AlienBloodExplosion
//=============================================================================
class AlienBloodExplosion extends xEmitter;

defaultproperties
{
     mRegen=False
     mStartParticles=100
     mMaxParticles=100
     mDelayRange(1)=0.100000
     mLifeRange(0)=2.500000
     mLifeRange(1)=2.500000
     mRegenRange(0)=140.000000
     mRegenRange(1)=140.000000
     mDirDev=(X=0.700000,Y=0.700000,Z=0.700000)
     mPosDev=(X=15.000000,Y=15.000000,Z=45.000000)
     mSpeedRange(0)=80.000000
     mSpeedRange(1)=80.000000
     mMassRange(0)=0.500000
     mMassRange(1)=0.500000
     mAirResistance=1.300000
     mRandOrient=True
     mSizeRange(0)=30.000000
     mSizeRange(1)=50.000000
     mColorRange(1)=(B=77,G=160,R=253)
     Skins(0)=Texture'XGameShadersB.Blood.BloodPuffGreen'
     Style=STY_Alpha
}
