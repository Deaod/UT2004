//=============================================================================
// Rain.
//=============================================================================
class Rain extends xEmitter;

#exec TEXTURE IMPORT NAME=pcl_rain FILE=TEXTURES\rain.tga GROUP=Skins ALPHA=1 DXT=5

defaultproperties
{
     mStartParticles=150
     mLifeRange(0)=0.500000
     mLifeRange(1)=1.000000
     mRegenRange(0)=150.000000
     mRegenRange(1)=150.000000
     mPosDev=(X=1000.799988,Y=1000.799988,Z=300.799988)
     mSpeedRange(0)=3000.000000
     mSpeedRange(1)=3000.000000
     mMassRange(0)=1.700000
     mMassRange(1)=1.700000
     mSizeRange(0)=3.500000
     mSizeRange(1)=3.500000
     mAttenuate=False
     Skins(0)=Texture'XEffects.Skins.pcl_rain'
     Style=STY_Translucent
}
