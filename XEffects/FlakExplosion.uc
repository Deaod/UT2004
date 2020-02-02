//=============================================================================
// FlakExplosion
//=============================================================================
class FlakExplosion extends RocketExplosion;

#EXEC TEXTURE IMPORT NAME=fexpt FILE=textures\explob.tga GROUP=Skins DXT=5 
#exec AUDIO IMPORT FILE="Sounds\explosion4.WAV" NAME="FlakExplosionSnd" GROUP="Effects"

defaultproperties
{
     mStartParticles=5
     mLifeRange(0)=0.900000
     mLifeRange(1)=1.800000
     mDirDev=(X=2.000000,Y=2.000000,Z=2.000000)
     mPosDev=(X=55.000000,Y=55.000000,Z=55.000000)
     mSpeedRange(1)=20.000000
     mMassRange(0)=-0.200000
     mMassRange(1)=-0.600000
     mSpinRange(0)=-3.000000
     mSpinRange(1)=3.000000
     mSizeRange(0)=91.000000
     mSizeRange(1)=161.000000
     LightSaturation=100
     LightRadius=8.000000
     bHighDetail=True
     Texture=Texture'XEffects.Skins.fexpt'
     Skins(0)=Texture'XEffects.Skins.fexpt'
}
