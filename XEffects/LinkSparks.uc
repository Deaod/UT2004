class LinkSparks extends xEmitter;

#exec OBJ LOAD FILE=XEffectMat.utx

var float DesiredRegen;

simulated function SetLinkStatus(int Links, bool bLinking, float ls)
{
    mSizeRange[0] = default.mSizeRange[0] * (ls*1.0 + 1);
    mSizeRange[1] = default.mSizeRange[1] * (ls*1.0 + 1);
    mSpeedRange[0] = default.mSpeedRange[0] * (ls*0.7 + 1);
    mSpeedRange[1] = default.mSpeedRange[1] * (ls*0.7 + 1);
    mLifeRange[0] = default.mLifeRange[0] * (ls + 1);
    mLifeRange[1] = mLifeRange[0];
    DesiredRegen = default.mRegenRange[0] * (ls + 1);
    if (Links == 0)
        Skins[0] = Texture'XEffectMat.Link.link_spark_green';
    else
        Skins[0] = Texture'XEffectMat.Link.link_spark_yellow';
}

defaultproperties
{
     DesiredRegen=40.000000
     mParticleType=PT_Line
     mStartParticles=0
     mMaxParticles=40
     mLifeRange(0)=0.500000
     mLifeRange(1)=0.500000
     mRegenRange(0)=40.000000
     mRegenRange(1)=40.000000
     mDirDev=(X=0.500000,Y=1.000000,Z=1.000000)
     mPosDev=(X=8.000000,Y=8.000000,Z=8.000000)
     mSpawnVecB=(X=12.000000,Z=0.060000)
     mSpeedRange(0)=-175.000000
     mSpeedRange(1)=-225.000000
     mMassRange(0)=2.000000
     mMassRange(1)=2.000000
     mSizeRange(0)=8.000000
     mSizeRange(1)=12.000000
     mColorRange(0)=(B=150,G=150,R=150)
     mColorRange(1)=(B=150,G=150,R=150)
     mAttenKa=0.100000
     LightType=LT_Steady
     LightHue=100
     LightSaturation=100
     LightBrightness=180.000000
     LightRadius=3.000000
     bDynamicLight=True
     Skins(0)=Texture'XEffectMat.Link.link_spark_green'
     Style=STY_Additive
}
