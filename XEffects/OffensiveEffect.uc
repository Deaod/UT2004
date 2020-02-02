class OffensiveEffect extends xEmitter;

defaultproperties
{
     mParticleType=PT_Mesh
     mStartParticles=0
     mMaxParticles=10
     mLifeRange(0)=1.000000
     mLifeRange(1)=1.000000
     mRegenRange(0)=3.000000
     mRegenRange(1)=3.000000
     mPosDev=(X=10.000000,Y=10.000000,Z=10.000000)
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mPosRelative=True
     mAirResistance=0.000000
     mRandOrient=True
     mSizeRange(0)=0.700000
     mSizeRange(1)=1.100000
     mColorRange(0)=(B=150,G=150,R=250)
     mColorRange(1)=(B=150,G=150,R=250)
     mAttenKa=0.500000
     mAttenFunc=ATF_ExpInOut
     mMeshNodes(0)=StaticMesh'XEffects.TeleRing'
     bTrailerSameRotation=True
     bNetTemporary=False
     bReplicateMovement=False
     Physics=PHYS_Trailer
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=60.000000
     Skins(0)=FinalBlend'XEffectMat.Combos.RedBoltFB'
     Style=STY_Additive
}
