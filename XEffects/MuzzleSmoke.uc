// ============================================================
// MuzzleSmoke: 
// ============================================================

class MuzzleSmoke extends pclLightSmoke;

function PostBeginPlay()
{
    disable('Tick');
}

event Trigger( Actor Other, Pawn EventInstigator )
{
    mRegenRange[0] = 30.0;
    mRegenRange[1] = mRegenRange[0];
    enable('Tick');
}

event Tick(float dt)
{
    if (mRegenRange[0] > 1.0)
    {
        mRegenRange[0] = Lerp(dt, mRegenRange[0], 0.0);
    }
    else
    {
        mRegenRange[0] = 0.0;
        disable('Tick');
    }

    mRegenRange[1] = mRegenRange[0];
}

defaultproperties
{
     mStartParticles=0
     mMaxParticles=30
     mLifeRange(0)=0.600000
     mLifeRange(1)=1.200000
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mDirDev=(X=0.300000,Y=0.300000,Z=0.300000)
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mMassRange(0)=-0.250000
     mMassRange(1)=-0.150000
     mSizeRange(0)=5.000000
     mSizeRange(1)=10.000000
     mGrowthRate=4.000000
     mColorRange(0)=(B=70,G=70,R=70)
     mColorRange(1)=(B=113,G=113,R=113)
     bHidden=True
     bOnlyOwnerSee=True
     bHighDetail=True
}
