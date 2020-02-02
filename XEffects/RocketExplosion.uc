//=============================================================================
// RocketExplosion
//=============================================================================
class RocketExplosion extends xEmitter;

#exec OBJ LOAD File=WeaponSounds.uax

#EXEC TEXTURE IMPORT NAME=Rexpt FILE=textures\explochunks.tga GROUP=Skins DXT=5

simulated function PostBeginPlay()
{
	local PlayerController PC;

	PC = Level.GetLocalPlayerController();
	if ( (PC.ViewTarget == None) || (VSize(PC.ViewTarget.Location - Location) > 5000) ) 
	{
		LightType = LT_None;
		bDynamicLight = false;
	}
	else 
	{
		Spawn(class'RocketSmokeRing');
		if ( Level.bDropDetail )
			LightRadius = 7;	
	}
}

defaultproperties
{
     mRegen=False
     mStartParticles=4
     mMaxParticles=4
     mLifeRange(0)=0.500000
     mLifeRange(1)=1.000000
     mDirDev=(X=1.000000,Y=1.000000,Z=1.000000)
     mSpeedRange(0)=3.000000
     mSpeedRange(1)=10.000000
     mRandOrient=True
     mSpinRange(0)=-20.000000
     mSpinRange(1)=20.000000
     mSizeRange(0)=100.000000
     mSizeRange(1)=200.000000
     LightType=LT_FadeOut
     LightHue=28
     LightSaturation=90
     LightBrightness=255.000000
     LightRadius=9.000000
     LightPeriod=32
     LightCone=128
     bDynamicLight=True
     LifeSpan=2.000000
     Skins(0)=Texture'XEffects.Skins.Rexpt'
     Style=STY_Additive
}
