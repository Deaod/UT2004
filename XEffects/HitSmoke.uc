// ============================================================
// HitSmoke: 
// ============================================================

class HitSmoke extends xEmitter;

state Ticking
{
	simulated function Tick( float dt )
	{
		if( LifeSpan < 1.0 )
		{
			mRegenRange[0] *= LifeSpan;
			mRegenRange[1] = mRegenRange[0];
		}
	}
}

simulated function timer()
{
	GotoState('Ticking');
}

simulated function PostNetBeginPlay()
{
	SetTimer(LifeSpan - 1.0,false);
	Super.PostNetBeginPlay();
}

defaultproperties
{
     mStartParticles=0
     mMaxParticles=40
     mLifeRange(0)=1.000000
     mLifeRange(1)=1.100000
     mRegenRange(0)=50.000000
     mRegenRange(1)=50.000000
     mDirDev=(X=0.300000,Y=0.300000,Z=0.300000)
     mPosDev=(X=3.300000,Y=3.300000,Z=3.300000)
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mMassRange(0)=-0.100000
     mMassRange(1)=-0.200000
     mSizeRange(0)=15.000000
     mSizeRange(1)=20.000000
     mGrowthRate=25.000000
     mColorRange(0)=(B=50,G=50,R=50)
     mColorRange(1)=(B=100,G=100,R=100)
     mNumTileColumns=4
     mNumTileRows=4
     bHidden=True
     LifeSpan=10.000000
     Skins(0)=Texture'XEffects.EmitSmoke_t'
     Style=STY_Subtractive
}
