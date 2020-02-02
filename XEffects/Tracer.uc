//=============================================================================
// Tracer.
//=============================================================================
class Tracer extends xEmitter;

#exec TEXTURE  IMPORT NAME=TracerT FILE=textures\TracerPcl.tga GROUP="Skins"

defaultproperties
{
     mParticleType=PT_Line
     mStartParticles=0
     mMaxParticles=100
     mLifeRange(0)=0.700000
     mLifeRange(1)=1.000000
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mSpeedRange(0)=5000.000000
     mSpeedRange(1)=5000.000000
     mAirResistance=0.000000
     mSizeRange(0)=4.000000
     mSizeRange(1)=4.000000
     Skins(0)=Texture'XEffects.Skins.TracerT'
     Style=STY_Translucent
}
