//=============================================================================
// TransDeRes.
//=============================================================================
class TransDeRes extends xEmitter;

#exec Texture Import File=Textures\GreySpark.tga Name=GreySpark Alpha=1 DXT=5

defaultproperties
{
     mParticleType=PT_Line
     mSpawningType=ST_OwnerSkeleton
     mStartParticles=10
     mMaxParticles=150
     mDelayRange(1)=0.100000
     mLifeRange(0)=0.300000
     mLifeRange(1)=0.300000
     mRegenRange(0)=550.000000
     mRegenRange(1)=550.000000
     mPosDev=(X=6.000000,Y=6.000000,Z=6.000000)
     mSpawnVecB=(X=4.000000,Z=0.070000)
     mSpeedRange(0)=100.000000
     mSpeedRange(1)=200.000000
     mAirResistance=0.000000
     mSizeRange(0)=2.500000
     mSizeRange(1)=1.500000
     mGrowthRate=-4.000000
     mColorRange(0)=(B=15,G=15,R=235)
     mColorRange(1)=(B=15,G=15,R=235)
     mAttenKa=0.100000
     bAttenByLife=True
     LifeSpan=1.000000
     Skins(0)=Texture'XEffects.GreySpark'
     Style=STY_Additive
}
