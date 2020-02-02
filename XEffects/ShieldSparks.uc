//=============================================================================
// ShieldSparks.
//=============================================================================
class ShieldSparks extends xEmitter;

#exec OBJ LOAD FILE=XEffectMat.utx

defaultproperties
{
     mParticleType=PT_Line
     mStartParticles=0
     mMaxParticles=20
     mDelayRange(1)=0.100000
     mLifeRange(0)=0.400000
     mLifeRange(1)=0.600000
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mDirDev=(X=0.900000,Y=0.900000,Z=0.900000)
     mPosDev=(X=6.000000,Y=6.000000,Z=6.000000)
     mSpawnVecB=(X=2.000000,Z=0.030000)
     mSpeedRange(0)=150.000000
     mSpeedRange(1)=300.000000
     mMassRange(0)=1.500000
     mMassRange(1)=2.500000
     mAirResistance=0.000000
     mSizeRange(0)=2.500000
     mSizeRange(1)=2.500000
     mGrowthRate=-4.000000
     mAttenKa=0.000000
     Skins(0)=Texture'XEffectMat.Shield.ShieldSpark'
     Style=STY_Additive
}
