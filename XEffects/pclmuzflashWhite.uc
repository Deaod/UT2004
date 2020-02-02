// ============================================================
// pclMuzFlashWhite
// 
// 1st person muzzle flash
// ============================================================
 
class pclMuzFlashWhite extends pclMuzFlashA;

#exec TEXTURE IMPORT NAME=MuzFlashWhite_t FILE=Textures\MuzzleFlashWhite.tga GROUP="Skins" LODSET=3 DXT=1

defaultproperties
{
     mSizeRange(0)=37.000000
     mSizeRange(1)=40.000000
     Texture=Texture'XEffects.Skins.MuzFlashWhite_t'
     Skins(0)=Texture'XEffects.Skins.MuzFlashWhite_t'
}
