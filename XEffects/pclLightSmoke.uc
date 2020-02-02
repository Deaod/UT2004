//=============================================================================
// pclLightSmoke
//=============================================================================
class pclLightSmoke extends pclSmoke;

#exec  TEXTURE IMPORT NAME=EmitLightSmoke_t FILE=Textures\smokelight_a.tga LODSET=3 DXT=1

defaultproperties
{
     mStartParticles=1
     mLifeRange(0)=0.800000
     mLifeRange(1)=1.400000
     mRegenRange(0)=150.000000
     mRegenRange(1)=150.000000
     mDirDev=(X=0.600000,Y=0.600000,Z=0.600000)
     mSpeedRange(0)=80.000000
     mSpeedRange(1)=110.000000
     mSizeRange(0)=70.000000
     mSizeRange(1)=86.000000
     mColorRange(0)=(B=75,G=75,R=75)
     mColorRange(1)=(B=110,G=110,R=110)
     Skins(0)=Texture'XEffects.EmitLightSmoke_t'
}
