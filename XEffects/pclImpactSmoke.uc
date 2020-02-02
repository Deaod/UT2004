//=============================================================================
// pclImpactSmoke
//=============================================================================
class pclImpactSmoke extends xEmitter;

defaultproperties
{
     mRegen=False
     mStartParticles=7
     mMaxParticles=16
     mDelayRange(1)=0.100000
     mLifeRange(0)=0.500000
     mLifeRange(1)=1.500000
     mRegenRange(0)=140.000000
     mRegenRange(1)=140.000000
     mDirDev=(X=0.150000,Y=0.150000,Z=0.150000)
     mPosDev=(X=8.000000,Y=8.000000,Z=8.000000)
     mSpeedRange(0)=10.000000
     mSpeedRange(1)=60.000000
     mRandOrient=True
     mSpinRange(0)=-10.000000
     mSpinRange(1)=10.000000
     mSizeRange(1)=25.000000
     mColorRange(0)=(B=20,G=20,R=20)
     mColorRange(1)=(B=40,G=40,R=40)
     mRandTextures=True
     mNumTileColumns=4
     mNumTileRows=4
     CullDistance=7000.000000
     Skins(0)=Texture'XEffects.EmitSmoke_t'
     ScaleGlow=2.000000
     Style=STY_Translucent
}
