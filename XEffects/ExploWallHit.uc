class ExploWallHit extends xHeavyWallHitEffect;

simulated function SpawnEffects()
{
	PlaySound(ImpactSounds[Rand(10)]);

	if ( PhysicsVolume.bWaterVolume )
	{
		Spawn(class'pclImpactSmoke');
		return;
	}
	if ( (Level.DetailMode == DM_Low) || Level.bDropDetail )
	{
		Spawn(class'XEffects.SmallExplosion');
		return;
	}

	Spawn(class'pclImpactSmoke');
	Spawn(class'XEffects.SmallExplosion');
}

defaultproperties
{
}
