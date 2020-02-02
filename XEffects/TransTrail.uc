//=============================================================================
// TransTrail
//=============================================================================
class TransTrail extends pclSmoke;

#exec TEXTURE  IMPORT NAME=TransTrailT FILE=textures\TransTrail.tga GROUP="Skins" MIPS=0

defaultproperties
{
     mParticleType=PT_Stream
     mStartParticles=0
     mMaxParticles=100
     mLifeRange(0)=1.500000
     mLifeRange(1)=1.500000
     mRegenRange(0)=20.000000
     mRegenRange(1)=20.000000
     mSpawnVecB=(X=10.000000,Z=0.000000)
     mSizeRange(0)=9.000000
     mSizeRange(1)=9.000000
     mGrowthRate=6.000000
     mColorRange(0)=(B=255,G=150,R=80)
     mColorRange(1)=(B=255,G=150,R=80)
     mAttenKa=0.000000
     mNumTileColumns=1
     mNumTileRows=1
     Physics=PHYS_Trailer
     Skins(0)=Texture'XEffects.Skins.TransTrailT'
     Style=STY_Additive
     bOwnerNoSee=True
}
