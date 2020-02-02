//=============================================================================
// BioSmoke
//=============================================================================
class BioSmoke extends pclSmoke;

#exec  TEXTURE IMPORT NAME=BiolifeMap_t FILE=Textures\BioSmokeColorMap.PCX LODSET=3 DXT=5

simulated function PostBeginPlay()
{
	SetTimer(0.1,False);
	Super.PostBeginPlay();
}

simulated function Timer()
{
	mRegen=False;
}

defaultproperties
{
     mStartParticles=1
     mLifeRange(0)=0.400000
     mLifeRange(1)=0.700000
     mRegenRange(0)=150.000000
     mRegenRange(1)=150.000000
     mDirDev=(X=1.400000,Y=1.400000,Z=1.400000)
     mPosDev=(X=10.800000,Y=10.800000,Z=10.800000)
     mSpeedRange(0)=20.000000
     mSpeedRange(1)=45.000000
     mSpinRange(0)=10.000000
     mSpinRange(1)=90.000000
     mSizeRange(0)=60.000000
     mSizeRange(1)=60.000000
     mGrowthRate=70.000000
     mLifeColorMap=Texture'XEffects.BiolifeMap_t'
     Physics=PHYS_Trailer
     LifeSpan=1.200000
}
