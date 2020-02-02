//=============================================================================
// ShockBoltEffect
//=============================================================================
class ShockBoltEffect extends xEmitter;

#exec TEXTURE  IMPORT NAME=LsBBT FILE=textures\ShockEffect.tga GROUP="Skins"

defaultproperties
{
     mStartParticles=10
     mMaxParticles=10
     mLifeRange(0)=0.200000
     mLifeRange(1)=0.400000
     mRegenRange(0)=30.000000
     mRegenRange(1)=30.000000
     mPosDev=(X=5.000000,Y=5.000000,Z=5.000000)
     mPosRelative=True
     mRandOrient=True
     mSizeRange(0)=40.000000
     mSizeRange(1)=85.000000
     Physics=PHYS_Trailer
     LifeSpan=10.000000
     Skins(0)=Texture'XEffects.Skins.LsBBT'
     Style=STY_Translucent
}
