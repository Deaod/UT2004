class UTWeaponPickup extends WeaponPickup;

var(WeaponPickup) vector StandUp;	// rotation change used by WeaponLocker
var(WeaponPickup) float LockerOffset;

simulated event ClientTrigger()
{
	bHidden = true;
	if ( EffectIsRelevant(Location, false) && !Level.GetLocalPlayerController().BeyondViewDistance(Location, CullDistance)  )
		spawn(class'WeaponFadeEffect',self);
}
	
function RespawnEffect()
{
	spawn(class'PlayerSpawnEffect');
}

State FadeOut
{
	function Tick(float DeltaTime)
	{
		disable('Tick');
	}

	function BeginState()
	{
		bHidden = true;
		LifeSpan = 1.0;
		bClientTrigger = !bClientTrigger;
		if ( Level.NetMode != NM_DedicatedServer )
			ClientTrigger();
	}
}

defaultproperties
{
     StandUp=(Z=0.750000)
     LockerOffset=35.000000
     MessageClass=Class'UnrealGame.PickupMessagePlus'
}
