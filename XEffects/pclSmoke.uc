//=============================================================================
// pclSmoke
//=============================================================================
class pclSmoke extends xEmitter;

#exec  TEXTURE IMPORT NAME=EmitSmoke_t FILE=Textures\smoke_a.tga LODSET=2 DXT=5

defaultproperties
{
     mStartParticles=2
     mMaxParticles=150
     mLifeRange(0)=1.000000
     mLifeRange(1)=1.000000
     mRegenRange(0)=140.000000
     mRegenRange(1)=140.000000
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mRandOrient=True
     mSizeRange(0)=45.000000
     mSizeRange(1)=45.000000
     mColorRange(0)=(B=100,G=110,R=120)
     mColorRange(1)=(B=180,G=180,R=180)
     mRandTextures=True
     mNumTileColumns=4
     mNumTileRows=4
     Skins(0)=Texture'XEffects.EmitSmoke_t'
     ScaleGlow=2.000000
     Style=STY_Translucent
}
