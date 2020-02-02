class ShockComboWiggles extends xEmitter;

#exec OBJ LOAD FILE=XEffectMat.utx

defaultproperties
{
     mParticleType=PT_Disc
     mSpawningType=ST_Explode
     mRegenPause=True
     mStartParticles=25
     mMaxParticles=25
     mLifeRange(0)=0.750000
     mLifeRange(1)=0.750000
     mRegenRange(0)=25.000000
     mRegenRange(1)=25.000000
     mPosDev=(X=20.000000,Y=20.000000,Z=20.000000)
     mSpeedRange(0)=300.000000
     mSpeedRange(1)=300.000000
     mSizeRange(0)=120.000000
     mSizeRange(1)=120.000000
     mColorRange(0)=(B=80,G=100,R=80)
     mColorRange(1)=(B=120,G=100,R=120)
     LifeSpan=2.000000
     Skins(0)=Texture'XEffectMat.Shock.shock_sparkle'
     Style=STY_Translucent
}
