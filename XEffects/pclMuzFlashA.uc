// ============================================================
// pclMuzFlashA
// 
// Machinegun 1st person muzzle flash
// ============================================================
 
class pclMuzFlashA extends xEmitter;

#exec TEXTURE IMPORT NAME=MuzFlashA_t FILE=Textures\MuzzleFlashA.tga GROUP="Skins" LODSET=3 DXT=1

event Trigger( Actor Other, Pawn EventInstigator )
{
    mStartParticles = ClampToMaxParticles(100);
}

defaultproperties
{
     mRegenPause=True
     mStartParticles=0
     mMaxParticles=2
     mLifeRange(0)=0.050000
     mLifeRange(1)=0.050000
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mPosRelative=True
     mRandOrient=True
     mSizeRange(0)=35.000000
     mSizeRange(1)=70.000000
     mColorRange(0)=(B=95,G=95,R=95)
     mColorRange(1)=(B=95,G=95,R=95)
     mAttenuate=False
     bHidden=True
     bOnlyOwnerSee=True
     DrawScale=0.750000
     Skins(0)=Texture'XEffects.Skins.MuzFlashA_t'
     Style=STY_Additive
}
