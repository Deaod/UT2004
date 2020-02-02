// ============================================================
// pclMinigunMuzFlash
// 
// Minigun 1st person muzzle flash
// ============================================================
 
class pclMinigunMuzFlash extends pclMuzFlashA;

#exec TEXTURE IMPORT NAME=MuzFlashA_t FILE=Textures\MuzzleFlashA.tga GROUP="Skins" LODSET=3 DXT=1

defaultproperties
{
     mStartParticles=1
     mMaxParticles=1
     mSizeRange(0)=25.000000
     mSizeRange(1)=40.000000
     mColorRange(0)=(B=255,G=255,R=255)
     mColorRange(1)=(B=255,G=255,R=255)
     Texture=Texture'XEffects.Skins.MuzFlashA_t'
     Style=STY_Translucent
}
