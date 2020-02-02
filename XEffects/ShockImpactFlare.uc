class ShockImpactFlare extends xEmitter;

#exec OBJ LOAD FILE=XEffectMat.utx

defaultproperties
{
     mParticleType=PT_Disc
     mRegen=False
     mStartParticles=3
     mMaxParticles=3
     mLifeRange(0)=0.500000
     mLifeRange(1)=0.500000
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mRandOrient=True
     mSpinRange(0)=-100.000000
     mSpinRange(1)=100.000000
     mSizeRange(0)=50.000000
     mSizeRange(1)=60.000000
     mGrowthRate=100.000000
     mAttenKa=0.000000
     Skins(0)=Texture'XEffectMat.Shock.shock_flare_a'
     Style=STY_Additive
}
