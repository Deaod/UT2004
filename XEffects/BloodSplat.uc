//=============================================================================
// BloodSplat.
//=============================================================================
class BloodSplat extends xEmitter;

#exec TEXTURE IMPORT NAME=pcl_Blooda FILE=TEXTURES\Blooda.tga GROUP=Skins Alpha=1 DXT=5

defaultproperties
{
     mRegen=False
     mStartParticles=14
     mLifeRange(0)=0.500000
     mLifeRange(1)=1.000000
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mDirDev=(X=0.300000,Y=0.300000,Z=0.300000)
     mPosDev=(X=1.800000,Y=1.800000,Z=1.800000)
     mSpeedRange(0)=100.000000
     mSpeedRange(1)=280.000000
     mMassRange(0)=0.800000
     mMassRange(1)=1.400000
     mRandOrient=True
     mSizeRange(0)=2.500000
     mSizeRange(1)=6.500000
     mRandTextures=True
     Skins(0)=Texture'XEffects.Skins.pcl_Blooda'
     ScaleGlow=2.000000
     Style=STY_Alpha
}
