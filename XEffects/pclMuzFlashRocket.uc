// ============================================================
// pclMuzFlashRocket
// 
// 1st person muzzle flash
// ============================================================
 
class pclMuzFlashRocket extends pclMuzFlashA;

#exec TEXTURE IMPORT NAME=MuzFlashRocket_t FILE=Textures\MuzzleFlashRocket.tga GROUP="Skins" LODSET=3 DXT=1

defaultproperties
{
     mSizeRange(0)=48.500000
     mSizeRange(1)=55.000000
     Texture=Texture'XEffects.Skins.MuzFlashRocket_t'
     Skins(0)=Texture'XEffects.Skins.MuzFlashRocket_t'
}
