//=============================================================================
// ExplosionCrap.
class ExplosionCrap extends WallSparks;

#exec TEXTURE IMPORT NAME=pcl_Crapa FILE=MODELS\Crap.tga GROUP=Skins Alpha=1  DXT=5

defaultproperties
{
     mParticleType=PT_Sprite
     mStartParticles=150
     mMaxParticles=150
     mLifeRange(0)=1.200000
     mLifeRange(1)=2.400000
     mDirDev=(X=0.400000,Y=0.400000,Z=0.400000)
     mPosDev=(X=30.000000,Y=30.000000,Z=30.000000)
     mSpeedRange(0)=200.000000
     mSpeedRange(1)=700.000000
     mMassRange(0)=2.000000
     mMassRange(1)=3.500000
     mAirResistance=0.300000
     mRandOrient=True
     mSpinRange(0)=-80.000000
     mSpinRange(1)=80.000000
     mSizeRange(0)=2.000000
     mSizeRange(1)=6.000000
     mGrowthRate=0.000000
     mNumTileColumns=4
     mNumTileRows=4
     bHighDetail=True
     Skins(0)=Texture'EmitterTextures.MultiFrame.rockchunks02'
     Style=STY_Alpha
}
