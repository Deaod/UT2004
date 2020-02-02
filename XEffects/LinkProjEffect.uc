class LinkProjEffect extends xEmitter;

#exec OBJ LOAD FILE=XEffectMat.utx

defaultproperties
{
     mStartParticles=0
     mLifeRange(0)=0.700000
     mLifeRange(1)=0.700000
     mRegenRange(0)=16.000000
     mRegenRange(1)=16.000000
     mDirDev=(Y=0.010000,Z=0.010000)
     mPosDev=(Y=4.000000,Z=4.000000)
     mSpeedRange(0)=225.000000
     mSpeedRange(1)=225.000000
     mAirResistance=0.000000
     mOwnerVelocityFactor=1.000000
     mSpinRange(0)=-200.000000
     mSpinRange(1)=200.000000
     mSizeRange(0)=18.000000
     mSizeRange(1)=18.000000
     mGrowthRate=-18.000000
     mColorRange(0)=(B=170,G=170,R=170)
     mColorRange(1)=(B=170,G=170,R=170)
     mAttenKa=0.000000
     bHighDetail=True
     Physics=PHYS_Trailer
     Skins(0)=Texture'XEffectMat.Link.link_muz_green'
     Style=STY_Additive
}
