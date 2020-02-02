//=============================================================================
// ChildLightningBolt.
//=============================================================================
class ChildLightningBolt extends xEmitter;


simulated function bool CheckMaxEffectDistance(PlayerController P, vector SpawnLocation)
{
	return !P.BeyondViewDistance(SpawnLocation,5000);
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    // pass in +vect(0,0,2) to EffectIsRelevant() because this actor just spawned too (not valid to check if its been rendered)
	if( EffectIsRelevant(Location+vect(0,0,2),false) )
        Spawn(class'ChildBlueSparks',,,Location,Rotation);
}

defaultproperties
{
     mParticleType=PT_Branch
     mRegen=False
     mStartParticles=10
     mMaxParticles=10
     mLifeRange(0)=0.500000
     mLifeRange(1)=0.500000
     mPosDev=(X=15.000000,Y=15.000000,Z=15.000000)
     mSpawnVecB=(X=20.000000,Z=10.000000)
     mSizeRange(0)=15.000000
     mSizeRange(1)=15.000000
     blockOnNet=True
     bReplicateMovement=False
     bSkipActorPropertyReplication=True
     RemoteRole=ROLE_DumbProxy
     LifeSpan=0.500000
     Skins(0)=Texture'XEffects.Skins.LightningBoltT'
     Style=STY_Additive
}
