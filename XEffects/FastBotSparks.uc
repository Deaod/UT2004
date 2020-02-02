//=============================================================================
// FastBotSparks.
//=============================================================================
class FastBotSparks extends xEmitter;

#exec TEXTURE IMPORT NAME=BotSpark FILE=TEXTURES\BotSpark.tga GROUP=Skins ALPHA=1 DXT=5

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
}

defaultproperties
{
     mParticleType=PT_Line
     mStartParticles=0
     mMaxParticles=20
     mDelayRange(1)=0.050000
     mLifeRange(0)=0.100000
     mLifeRange(1)=0.200000
     mRegenRange(0)=60.000000
     mRegenRange(1)=60.000000
     mDirDev=(X=0.600000,Y=0.600000,Z=0.600000)
     mPosDev=(X=0.800000,Y=0.800000,Z=0.800000)
     mSpawnVecB=(X=2.000000,Z=0.030000)
     mSpeedRange(0)=150.000000
     mSpeedRange(1)=200.000000
     mMassRange(0)=1.500000
     mMassRange(1)=2.500000
     mAirResistance=0.000000
     mSizeRange(0)=2.500000
     mSizeRange(1)=1.500000
     mGrowthRate=-4.000000
     mAttenKa=0.000000
     LifeSpan=0.200000
     Skins(0)=Texture'XEffects.Skins.BotSpark'
     ScaleGlow=2.000000
     Style=STY_Additive
}
