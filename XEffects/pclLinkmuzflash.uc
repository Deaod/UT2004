// ============================================================
// pclLinkMuzFlash
// 
// Machinegun 1st person muzzle flash
// ============================================================
 
class pclLinkMuzFlash extends pclMuzFlashA;

#exec TEXTURE IMPORT NAME=MuzFlashLink_t FILE=Textures\MuzzleFlashLink.tga GROUP="Skins" LODSET=3 DXT=1

defaultproperties
{
     mStartParticles=2
     mSizeRange(0)=110.000000
     mSizeRange(1)=120.000000
     mColorRange(0)=(B=200,G=200,R=200)
     mColorRange(1)=(B=200,G=200,R=200)
     Skins(0)=Texture'XEffects.Skins.MuzFlashLink_t'
     Style=STY_Translucent
}
