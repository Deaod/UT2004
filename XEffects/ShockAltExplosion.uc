//=============================================================================
// ShockAltExplosion
//=============================================================================
class ShockAltExplosion extends xEmitter;

#EXEC TEXTURE IMPORT NAME=seexpt FILE=textures\ShockExplosion.tga GROUP=Skins DXT=5

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
     mDirDev=(X=1.000000,Y=1.000000,Z=1.000000)
     mPosDev=(X=30.000000,Y=30.000000,Z=30.000000)
     mSpeedRange(0)=20.000000
     mSpeedRange(1)=50.000000
     mMassRange(0)=-0.100000
     mMassRange(1)=-0.200000
     mRandOrient=True
     mSpinRange(0)=-20.000000
     mSpinRange(1)=20.000000
     mSizeRange(0)=60.000000
     mSizeRange(1)=90.000000
     mGrowthRate=20.000000
     Skins(0)=Texture'XEffects.Skins.seexpt'
     Style=STY_Translucent
}
