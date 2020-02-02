class SmallRedeemerExplosion extends RocketExplosion;

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer )
		Spawn(class'ExplosionCrap');
}

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
}
