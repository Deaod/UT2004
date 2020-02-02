// ============================================================
// HitFlameBig 
// ============================================================

class HitFlameBig extends xEmitter;

state Ticking
{
	simulated function Tick( float dt )
	{
		if( LifeSpan < 3.0 )
		{
			mRegenRange[0] *= LifeSpan / 3;
			mRegenRange[1] = mRegenRange[0];
			SoundVolume = byte(float(SoundVolume) * (LifeSpan / 3));
		}
	}
}

simulated function timer()
{
	GotoState('Ticking');
}

simulated function PostNetBeginPlay()
{
	SetTimer(LifeSpan - 3.0,false);
	Super.PostNetBeginPlay();
}

defaultproperties
{
     mStartParticles=0
     mLifeRange(0)=0.300000
     mLifeRange(1)=0.500000
     mRegenRange(0)=200.000000
     mRegenRange(1)=200.000000
     mPosDev=(X=3.000000,Y=3.000000,Z=3.000000)
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mMassRange(0)=-1.000000
     mMassRange(1)=-1.200000
     mSizeRange(1)=25.000000
     mGrowthRate=-16.000000
     mAttenKa=0.500000
     mNumTileColumns=4
     mNumTileRows=4
     AmbientSound=Sound'GeneralAmbience.firefx11'
     LifeSpan=10.000000
     Skins(0)=Texture'EmitterTextures.MultiFrame.LargeFlames'
     Style=STY_Translucent
     SoundVolume=190
     SoundRadius=32.000000
}
