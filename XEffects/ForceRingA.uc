class ForceRingA extends xEmitter;

simulated function Trigger( Actor Other, Pawn EventInstigator )
{
    mRegenRange[0] = 16.0;
    mRegenRange[1] = 16.0;
    SetTimer(0.2, false);
}

simulated function Timer()
{
    mRegenRange[0] = 0.0;
    mRegenRange[1] = 0.0;
}

defaultproperties
{
     mParticleType=PT_Disc
     mStartParticles=0
     mMaxParticles=10
     mLifeRange(0)=0.250000
     mLifeRange(1)=0.250000
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mSpeedRange(0)=100.000000
     mSpeedRange(1)=100.000000
     mPosRelative=True
     mSizeRange(0)=1.000000
     mSizeRange(1)=1.000000
     mGrowthRate=100.000000
     mColorRange(0)=(B=32,R=32)
     mColorRange(1)=(B=32,R=32)
     mAttenKa=0.000000
     bOnlyOwnerSee=True
     Skins(0)=Texture'XEffectMat.Shock.shock_ring_b'
     Style=STY_Additive
}
