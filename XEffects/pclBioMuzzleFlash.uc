// ============================================================
// pclBioMuzFlash
// 
// BioRifle 1st person muzzle flash
// ============================================================
 
class pclBioMuzzleFlash extends pclMuzFlashA;

#exec TEXTURE IMPORT NAME=MuzFlashBio_t FILE=Textures\MuzzleFlashBio.tga GROUP="Skins" LODSET=3 DXT=1

defaultproperties
{
     mStartParticles=2
     mLifeRange(1)=0.060000
     mRandOrient=False
     mSizeRange(0)=46.500000
     mSizeRange(1)=49.000000
     mColorRange(0)=(B=100,G=100,R=100)
     mColorRange(1)=(B=100,G=100,R=100)
     Skins(0)=Texture'XEffects.Skins.MuzFlashBio_t'
}
