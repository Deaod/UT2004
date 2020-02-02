class RocketSmokeRing extends xEmitter;

#exec TEXTURE IMPORT NAME=SmokeAlphab_t FILE=Textures\smoke_alphabright.tga Alpha=1 DXT=5

defaultproperties
{
     mSpawningType=ST_ExplodeRing
     mRegen=False
     mStartParticles=15
     mMaxParticles=15
     mLifeRange(0)=1.300000
     mLifeRange(1)=1.700000
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mPosDev=(X=20.000000,Y=20.000000,Z=20.000000)
     mSpeedRange(0)=100.000000
     mSpeedRange(1)=100.000000
     mPosRelative=True
     mAirResistance=1.900000
     mRandOrient=True
     mSpinRange(0)=-50.000000
     mSpinRange(1)=50.000000
     mSizeRange(0)=20.000000
     mSizeRange(1)=30.000000
     mGrowthRate=40.000000
     mAttenKa=0.000000
     mAttenKb=0.500000
     mAttenFunc=ATF_SmoothStep
     mRandTextures=True
     mNumTileColumns=4
     mNumTileRows=4
     Skins(0)=Texture'XEffects.SmokeAlphab_t'
     Style=STY_Alpha
}
