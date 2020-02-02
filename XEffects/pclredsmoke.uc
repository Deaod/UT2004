//=============================================================================
// pclRedSmoke
//=============================================================================
class pclRedSmoke extends xEmitter;

#exec  TEXTURE IMPORT NAME=TrailLifeMap_t FILE=Textures\RocketTrailColorMap.PCX DXT=1 LODSET=3
#exec  TEXTURE IMPORT NAME=WispSmoke_t FILE=Textures\smoke_wisp.tga LODSET=2 DXT=1 LODSET=3

defaultproperties
{
     mMaxParticles=100
     mLifeRange(0)=0.800000
     mLifeRange(1)=1.000000
     mRegenRange(0)=80.000000
     mRegenRange(1)=100.000000
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mRandOrient=True
     mSpinRange(0)=-4.000000
     mSpinRange(1)=4.000000
     mSizeRange(0)=35.000000
     mSizeRange(1)=40.000000
     mGrowthRate=3.000000
     mAttenuate=False
     mRandTextures=True
     mNumTileColumns=4
     mNumTileRows=4
     mLifeColorMap=Texture'XEffects.TrailLifeMap_t'
     Physics=PHYS_Trailer
     LifeSpan=10.000000
     Skins(0)=Texture'XEffects.WispSmoke_t'
     Style=STY_Translucent
}
