//=============================================================================
// LinkBoltEffect
//=============================================================================
class LinkBoltEffect extends xEmitter;

#exec TEXTURE  IMPORT NAME=LBBT FILE=textures\LinkEffect.tga GROUP="Skins"

defaultproperties
{
     mStartParticles=0
     mMaxParticles=5
     mLifeRange(0)=0.300000
     mLifeRange(1)=0.600000
     mRegenRange(0)=15.000000
     mRegenRange(1)=15.000000
     mPosDev=(X=10.000000,Y=10.000000,Z=10.000000)
     mPosRelative=True
     mRandOrient=True
     mSizeRange(0)=60.000000
     mSizeRange(1)=60.000000
     Physics=PHYS_Trailer
     LifeSpan=2.000000
     Texture=Texture'XEffects.Skins.LBBT'
     Skins(0)=Texture'XEffects.Skins.LBBT'
     Style=STY_Translucent
}
