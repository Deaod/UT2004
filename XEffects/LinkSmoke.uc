class LinkSmoke extends xEmitter;

#EXEC TEXTURE IMPORT NAME=GreenSmokeTex FILE=textures\Greenexplo.tga DXT=5

defaultproperties
{
     mSpawningType=ST_Explode
     mRegen=False
     mStartParticles=8
     mMaxParticles=8
     mLifeRange(0)=1.200000
     mLifeRange(1)=1.500000
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mDirDev=(X=1.500000,Y=1.500000,Z=1.500000)
     mPosDev=(X=20.000000,Y=20.000000,Z=20.000000)
     mSpeedRange(0)=10.000000
     mSpeedRange(1)=30.000000
     mMassRange(0)=-0.050000
     mMassRange(1)=-0.150000
     mRandOrient=True
     mSpinRange(0)=-30.000000
     mSpinRange(1)=30.000000
     mSizeRange(0)=30.000000
     mSizeRange(1)=60.000000
     bHighDetail=True
     Skins(0)=Texture'XEffects.GreenSmokeTex'
     Style=STY_Translucent
}
