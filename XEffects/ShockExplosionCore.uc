class ShockExplosionCore extends xEmitter;

#exec OBJ LOAD FILE=XEffectMat.utx

defaultproperties
{
     mRegen=False
     mMaxParticles=1
     mLifeRange(0)=1.000000
     mLifeRange(1)=1.000000
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mSizeRange(0)=40.000000
     mSizeRange(1)=40.000000
     mGrowthRate=100.000000
     mAttenKa=0.000000
     bHighDetail=True
     Skins(0)=Texture'XEffectMat.Shock.shock_core'
     Style=STY_Additive
}
