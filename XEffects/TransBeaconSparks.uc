//=============================================================================
// TransBeaconSparks.
//=============================================================================
class TransBeaconSparks extends xEmitter;

defaultproperties
{
     mParticleType=PT_Line
     mRegenOnTime(0)=0.200000
     mRegenOnTime(1)=0.500000
     mRegenOffTime(0)=0.500000
     mRegenOffTime(1)=0.800000
     mStartParticles=0
     mMaxParticles=20
     mDelayRange(1)=0.100000
     mLifeRange(0)=0.400000
     mLifeRange(1)=0.600000
     mRegenRange(0)=60.000000
     mRegenRange(1)=60.000000
     mDirDev=(X=0.600000,Y=0.600000,Z=0.600000)
     mPosDev=(X=0.800000,Y=0.800000,Z=0.800000)
     mSpawnVecB=(X=2.000000,Z=0.030000)
     mSpeedRange(0)=150.000000
     mSpeedRange(1)=200.000000
     mMassRange(0)=1.500000
     mMassRange(1)=2.500000
     mAirResistance=0.000000
     mSizeRange(0)=2.500000
     mSizeRange(1)=1.500000
     mGrowthRate=-4.000000
     mAttenKa=0.000000
     CullDistance=4000.000000
     Skins(0)=Texture'XEffects.Skins.BotSpark'
     ScaleGlow=2.000000
     Style=STY_Additive
}
