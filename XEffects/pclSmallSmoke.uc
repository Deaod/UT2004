//=============================================================================
// pclSmallSmoke
//=============================================================================
class pclSmallSmoke extends xEmitter;

#exec  TEXTURE IMPORT NAME=EmitSmoke_t FILE=Textures\smoke_a.tga DXT=1 LODSET=3

defaultproperties
{
     mStartParticles=2
     mMaxParticles=20
     mDelayRange(1)=0.010000
     mLifeRange(0)=1.300000
     mLifeRange(1)=2.400000
     mRegenRange(0)=4.000000
     mRegenRange(1)=7.000000
     mDirDev=(X=0.200000,Y=0.200000,Z=0.200000)
     mPosDev=(X=0.100000,Y=0.100000,Z=0.100000)
     mSpeedRange(0)=10.000000
     mSpeedRange(1)=23.000000
     mRandOrient=True
     mSizeRange(0)=20.000000
     mSizeRange(1)=30.000000
     mColorRange(0)=(B=100,G=100,R=140)
     mColorRange(1)=(B=180,G=180,R=180)
     mRandTextures=True
     mNumTileColumns=4
     mNumTileRows=4
     Skins(0)=Texture'XEffects.EmitSmoke_t'
     ScaleGlow=2.000000
     Style=STY_Translucent
}
