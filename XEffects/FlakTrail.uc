//=============================================================================
// FlakTrail
//=============================================================================
class FlakTrail extends pclSmoke;

#exec TEXTURE  IMPORT NAME=FlakTrailTex FILE=textures\FlakTrailPCL.tga

defaultproperties
{
     mParticleType=PT_Stream
     mStartParticles=0
     mMaxParticles=40
     mLifeRange(0)=0.100000
     mLifeRange(1)=0.100000
     mRegenRange(0)=60.000000
     mRegenRange(1)=60.000000
     mSpawnVecB=(X=20.000000,Z=0.000000)
     mSizeRange(0)=2.000000
     mSizeRange(1)=3.000000
     mGrowthRate=-0.500000
     mColorRange(0)=(B=255,G=255,R=255)
     mColorRange(1)=(B=255,G=255,R=255)
     mNumTileColumns=1
     mNumTileRows=1
     Physics=PHYS_Trailer
     LifeSpan=2.900000
     Skins(0)=Texture'XEffects.FlakTrailTex'
     Style=STY_Additive
}
