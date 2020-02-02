class RocketTrailSmoke extends xEmitter;

#exec OBJ LOAD File=XGameShadersB.utx
#exec  TEXTURE IMPORT NAME=WispSmoke_t FILE=Textures\smoke_wisp.tga LODSET=2 DXT=1

defaultproperties
{
     mStartParticles=0
     mMaxParticles=150
     mLifeRange(0)=1.250000
     mLifeRange(1)=1.250000
     mRegenRange(0)=90.000000
     mRegenRange(1)=90.000000
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mMassRange(0)=-0.030000
     mMassRange(1)=-0.010000
     mRandOrient=True
     mSpinRange(0)=-75.000000
     mSpinRange(1)=75.000000
     mSizeRange(0)=15.000000
     mSizeRange(1)=20.000000
     mGrowthRate=13.000000
     mColorRange(1)=(B=210,G=210)
     mAttenFunc=ATF_ExpInOut
     mRandTextures=True
     mNumTileColumns=4
     mNumTileRows=4
     CullDistance=10000.000000
     Physics=PHYS_Trailer
     Skins(0)=Texture'XEffects.SmokeAlphab_t'
     Style=STY_Alpha
}
