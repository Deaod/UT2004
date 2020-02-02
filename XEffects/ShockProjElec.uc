class ShockProjElec extends xEmitter;

#exec OBJ LOAD FILE=XEffectMat.utx

defaultproperties
{
     mMaxParticles=5
     mLifeRange(0)=0.500000
     mLifeRange(1)=0.500000
     mRegenRange(0)=5.000000
     mRegenRange(1)=5.000000
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mPosRelative=True
     mRandOrient=True
     mSpinRange(0)=-120.000000
     mSpinRange(1)=120.000000
     mSizeRange(0)=75.000000
     mSizeRange(1)=75.000000
     mColorRange(0)=(B=200,G=200,R=200)
     mColorRange(1)=(B=200,G=200,R=200)
     Physics=PHYS_Trailer
     Skins(0)=Texture'XEffectMat.Shock.shock_flare_a'
     Style=STY_Additive
}
