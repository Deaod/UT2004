class ImpactDust extends xEmitter;

var() float MaxImpactParticles;

simulated function Kick( Vector position, float atten )
{
	SetLocation( position );
	mLastPos = position;
	mStartParticles = ClampToMaxParticles(mStartParticles + MaxImpactParticles * atten);
}

defaultproperties
{
     MaxImpactParticles=20.000000
     mSpawningType=ST_AimedSphere
     mMaxParticles=150
     mDelayRange(1)=0.100000
     mLifeRange(0)=0.800000
     mLifeRange(1)=1.400000
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mDirDev=(X=1.000000,Y=1.000000)
     mPosDev=(X=8.000000,Y=8.000000)
     mSpeedRange(0)=20.000000
     mSpeedRange(1)=30.000000
     mMassRange(0)=-0.050000
     mMassRange(1)=-0.100000
     mSizeRange(0)=20.000000
     mSizeRange(1)=25.000000
     mColorRange(0)=(B=16,G=16,R=11)
     mColorRange(1)=(B=22,G=22,R=22)
     mAttenKa=0.050000
     mNumTileColumns=4
     mNumTileRows=4
     Skins(0)=Texture'XEffects.EmitLightSmoke_t'
     Style=STY_Translucent
}
