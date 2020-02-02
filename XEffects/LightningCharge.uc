class LightningCharge extends xEmitter;

#exec TEXTURE IMPORT NAME=LightningChargeT FILE=textures\LightningCharge.tga DXT=1

defaultproperties
{
     mStartParticles=0
     mMaxParticles=10
     mLifeRange(0)=0.200000
     mLifeRange(1)=0.200000
     mRegenRange(0)=10.000000
     mRegenRange(1)=10.000000
     mPosDev=(X=10.000000)
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mPosRelative=True
     mRandOrient=True
     mSizeRange(0)=5.000000
     mSizeRange(1)=5.000000
     mAttenKa=0.000000
     mNumTileColumns=2
     mNumTileRows=2
     bNetTemporary=False
     RelativeLocation=(X=-30.000000)
     Skins(0)=Texture'XEffects.LightningChargeT'
     Style=STY_Additive
}
