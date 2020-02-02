//=============================================================================
// FlashExplosion
//=============================================================================
class FlashExplosion extends xEmitter;

#EXEC TEXTURE IMPORT NAME=ExplosionFlashTex FILE=textures\FlashExp.tga  Alpha=1 GROUP=Skins DXT=5

defaultproperties
{
     mRegen=False
     mMaxParticles=1
     mLifeRange(0)=0.250000
     mLifeRange(1)=0.250000
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mRandOrient=True
     mSpinRange(0)=-45.000000
     mSpinRange(1)=45.000000
     mSizeRange(0)=150.000000
     mSizeRange(1)=150.000000
     mGrowthRate=500.000000
     LifeSpan=0.300000
     Texture=Texture'XEffects.Skins.ExplosionFlashTex'
     Skins(0)=Texture'XEffects.Skins.ExplosionFlashTex'
     Style=STY_Translucent
}
