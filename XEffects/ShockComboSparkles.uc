class ShockComboSparkles extends xEmitter;

#exec OBJ LOAD FILE=XEffectMat.utx

defaultproperties
{
     mSpawningType=ST_Explode
     mRegenPause=True
     mRegenOnTime(0)=0.650000
     mRegenOnTime(1)=0.650000
     mRegenOffTime(0)=10.000000
     mRegenOffTime(1)=10.000000
     mStartParticles=0
     mMaxParticles=25
     mLifeRange(0)=0.750000
     mLifeRange(1)=0.750000
     mRegenRange(0)=25.000000
     mRegenRange(1)=25.000000
     mPosDev=(X=120.000000,Y=120.000000,Z=120.000000)
     mSpeedRange(0)=-250.000000
     mSpeedRange(1)=-250.000000
     mSizeRange(0)=65.000000
     mSizeRange(1)=65.000000
     mGrowthRate=-80.000000
     mAttenKa=0.300000
     LifeSpan=2.000000
     Skins(0)=Texture'XEffectMat.Shock.shock_sparkle'
     Style=STY_Translucent
}
