class ShockCombo extends Actor;

#exec OBJ LOAD FILE=XEffectMat.utx

#exec MESH      IMPORT      MESH=ShockVortexMesh    ANIVFILE=models\shock_vortex_a.3d DATAFILE=models\shock_vortex_d.3d
#exec MESH      SEQUENCE    MESH=ShockVortexMesh    SEQ=Explode STARTFRAME=0 NUMFRAMES=55 RATE=30
#exec MESH      ORIGIN      MESH=ShockVortexMesh    X=0 Y=0 Z=0 PITCH=0 YAW=0 ROLL=0
#exec MESHMAP   SCALE       MESHMAP=ShockVortexMesh X=1.0 Y=1.0 Z=2.0

#exec STATICMESH IMPORT NAME=EffectsSphere144 FILE=Models\EffectsSphere144.lwo COLLISION=0


var ShockComboFlare Flare;

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Level.NetMode != NM_DedicatedServer)
    {
        Spawn(class'ShockComboExpRing');
        Flare = Spawn(class'ShockComboFlare');
        //Spawn(class'ShockComboSphere');
        Spawn(class'ShockComboCore');
        Spawn(class'ShockComboSphereDark');
        Spawn(class'ShockComboVortex');
        Spawn(class'ShockComboWiggles');
        Spawn(class'ShockComboFlash');
    }
}

auto simulated state Combo
{
Begin:
    Sleep(0.9);
    //Spawn(class'ShockAltExplosion');
    if ( Flare != None )
    {
		Flare.mStartParticles = 2;
		Flare.mRegenRange[0] = 0.0;
		Flare.mRegenRange[1] = 0.0;
		Flare.mLifeRange[0] = 0.3;
		Flare.mLifeRange[1] = 0.3;
		Flare.mSizeRange[0] = 150;
		Flare.mSizeRange[1] = 150;
		Flare.mGrowthRate = -500;
		Flare.mAttenKa = 0.9;
	}
    LightType = LT_None;
}

defaultproperties
{
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=195
     LightSaturation=100
     LightBrightness=255.000000
     LightRadius=10.000000
     DrawType=DT_None
     bDynamicLight=True
     bNetTemporary=True
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=2.000000
     bCollideActors=True
     ForceType=FT_Constant
     ForceRadius=300.000000
     ForceScale=-500.000000
}
