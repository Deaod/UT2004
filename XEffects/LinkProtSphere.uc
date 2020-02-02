class LinkProtSphere extends xEmitter;

#exec OBJ LOAD FILE=XEffectMat.utx

defaultproperties
{
     mParticleType=PT_Disc
     mMaxParticles=6
     mLifeRange(0)=0.250000
     mLifeRange(1)=0.250000
     mRegenRange(0)=12.000000
     mRegenRange(1)=12.000000
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mPosRelative=True
     mRandOrient=True
     mSpinRange(0)=-100.000000
     mSpinRange(1)=100.000000
     mSizeRange(0)=35.000000
     mSizeRange(1)=35.000000
     mColorRange(0)=(B=180,G=180,R=180)
     mColorRange(1)=(B=180,G=180,R=180)
     mAttenKa=0.000000
     Skins(0)=Texture'XEffectMat.Link.link_muz_red'
     Style=STY_Translucent
}
