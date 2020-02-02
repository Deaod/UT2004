class PainterBeamSpot extends xEmitter;

#exec OBJ LOAD FILE=XEffectMat.utx

defaultproperties
{
     mParticleType=PT_Disc
     mStartParticles=0
     mMaxParticles=1
     mLifeRange(0)=5.000000
     mLifeRange(1)=5.000000
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mPosRelative=True
     mRandOrient=True
     mSizeRange(0)=30.000000
     mSizeRange(1)=30.000000
     mAttenKa=0.000000
     LightType=LT_Steady
     LightSaturation=20
     LightBrightness=220.000000
     LightRadius=1.000000
     bDynamicLight=True
     Skins(0)=Texture'XEffectMat.Shock.shock_mark_heat'
     Style=STY_Additive
}
