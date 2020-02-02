class ShockBeamCoil extends xEmitter;

#exec OBJ LOAD FILE=XEffectMat.utx
#exec STATICMESH IMPORT NAME=ShockCoil FILE=Models\ShockCoil.lwo COLLISION=0
// cylinder is 30 units long. mRegenDist=DrawScale*30

defaultproperties
{
     mParticleType=PT_Beam
     mMaxParticles=1
     mLifeRange(0)=1.000000
     mRegenDist=90.000000
     mSpinRange(0)=32000.000000
     mSizeRange(0)=0.300000
     mSizeRange(1)=0.600000
     mColorRange(0)=(B=50,G=50,R=50)
     mColorRange(1)=(B=50,G=50,R=50)
     mMeshNodes(0)=StaticMesh'XEffects.ShockCoil'
     bHighDetail=True
     LifeSpan=0.750000
     DrawScale3D=(X=3.000000,Y=15.000000,Z=15.000000)
     Skins(0)=FinalBlend'XEffectMat.Shock.ShockCoilFB'
}
