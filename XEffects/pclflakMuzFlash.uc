// ============================================================
// pclFlakMuzFlash
// 
// Flak Cannon 1st person muzzle flash
// ============================================================
 
class pclFlakMuzFlash extends pclMuzFlashA;

#exec TEXTURE IMPORT NAME=MuzFlashFlak_t FILE=Textures\FlakFlash.tga GROUP="Skins" LODSET=3 DXT=1

defaultproperties
{
     mSizeRange(0)=85.000000
     mSizeRange(1)=110.000000
     Texture=Texture'XEffects.Skins.MuzFlashFlak_t'
     Skins(0)=Texture'XEffects.Skins.MuzFlashFlak_t'
     Style=STY_Translucent
}
