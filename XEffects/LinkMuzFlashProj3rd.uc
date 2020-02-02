class LinkMuzFlashProj3rd extends xEmitter;

#exec OBJ LOAD FILE=XEffectMat.utx

#exec STATICMESH IMPORT NAME=LinkMuzFlashMesh FILE=Models\link_projectile_flash.lwo COLLISION=0

simulated event Trigger( Actor Other, Pawn EventInstigator )
{
    mStartParticles = 1;
}

defaultproperties
{
     mParticleType=PT_Mesh
     mStartParticles=0
     mMaxParticles=3
     mLifeRange(0)=0.080000
     mLifeRange(1)=0.120000
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mPosRelative=True
     mAirResistance=0.000000
     mSizeRange(0)=0.600000
     mSizeRange(1)=0.600000
     mColorRange(0)=(B=70,G=70,R=70)
     mColorRange(1)=(B=70,G=70,R=70)
     mAttenKa=0.000000
     mRandTextures=True
     mNumTileColumns=2
     mNumTileRows=2
     mMeshNodes(0)=StaticMesh'XEffects.LinkMuzFlashMesh'
     Skins(0)=FinalBlend'XEffectMat.Link.LinkMuzProjGreenFB'
}
