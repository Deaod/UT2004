class ShockExplosion extends xEmitter;

simulated event PostBeginPlay()
{
	local PlayerController PC;
	
    Super.PostBeginPlay();

    SetTimer(0.5, false);
    if ( Level.bDropDetail )
	{
		bDynamicLight = false;
		LightType = LT_None;
	}
	else
	{
		PC = Level.GetLocalPlayerController();
		if ( (PC.ViewTarget == None) || (VSize(PC.ViewTarget.Location - Location) > 4000) ) 
		{
			LightType = LT_None;
			bDynamicLight = false;
		}
	}
}

simulated function Timer()
{
    LightType = LT_None;
}

defaultproperties
{
     mParticleType=PT_Mesh
     mMaxParticles=1
     mLifeRange(0)=0.600000
     mLifeRange(1)=0.600000
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mRandOrient=True
     mSizeRange(0)=0.600000
     mSizeRange(1)=0.600000
     mGrowthRate=1.200000
     mColorRange(0)=(B=100,G=100,R=100)
     mColorRange(1)=(B=100,G=100,R=100)
     mAttenKa=0.300000
     mAttenFunc=ATF_ExpInOut
     mMeshNodes(0)=StaticMesh'XEffects.EffectsSphere144'
     LightType=LT_Steady
     LightHue=195
     LightSaturation=85
     LightBrightness=255.000000
     LightRadius=5.000000
     bAttenByLife=True
     bDynamicLight=True
     LifeSpan=2.000000
     Skins(0)=FinalBlend'XEffectMat.Shock.ShockDarkFB'
}
