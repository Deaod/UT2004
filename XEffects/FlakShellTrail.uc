//=============================================================================
// FlakShellTrail
//=============================================================================
class FlakShellTrail extends pclSmoke; 

#exec  TEXTURE IMPORT NAME=FlakMap_t FILE=Textures\FlakColorMap.PCX LODSET=3 DXT=1

defaultproperties
{
     mStartParticles=1
     mLifeRange(0)=0.500000
     mLifeRange(1)=0.600000
     mRegenRange(0)=50.000000
     mRegenRange(1)=50.000000
     mDirDev=(X=0.100000,Y=0.100000,Z=0.100000)
     mPosDev=(X=2.000000,Y=2.000000,Z=2.000000)
     mSizeRange(0)=20.000000
     mSizeRange(1)=35.000000
     mGrowthRate=15.000000
     Physics=PHYS_Trailer
     LifeSpan=5.000000
     Skins(0)=Texture'XEffects.SmokeAlphab_t'
     Style=STY_Alpha
}
