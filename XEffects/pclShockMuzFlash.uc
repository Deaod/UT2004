// ============================================================
// pclShockMuzFlash
// 
// ShockRifle 1st person muzzle flash
// ============================================================
 
class pclShockMuzFlash extends pclMuzFlashA;

#exec TEXTURE IMPORT NAME=MuzShockFlash_t FILE=Textures\Shockmuz.tga GROUP="Skins" DXT=1 LODSET=3

defaultproperties
{
     mStartParticles=1
     mMaxParticles=1
     mRandOrient=False
     mSizeRange(0)=10.500000
     mSizeRange(1)=11.000000
     mColorRange(0)=(B=200,G=200,R=200)
     mColorRange(1)=(B=200,G=200,R=200)
     Skins(0)=Texture'XEffects.Skins.MuzShockFlash_t'
     Style=STY_Translucent
}
