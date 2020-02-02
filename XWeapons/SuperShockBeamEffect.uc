class SuperShockBeamEffect extends ShockBeamEffect;

#exec obj load file=InstagibEffects.utx

simulated function SpawnEffects()
{
	local ShockBeamEffect E;
	
	Super.SpawnEffects();
	E = Spawn(class'ExtraRedBeam');
	if ( E != None )
		E.AimAt(mSpawnVecA, HitNormal); 
}
	
simulated function SpawnImpactEffects(rotator HitRot, vector EffectLoc)
{
	Spawn(class'ShockImpactFlareB',,, EffectLoc, HitRot);
	Spawn(class'ShockImpactRingB',,, EffectLoc, HitRot);
	Spawn(class'ShockImpactScorch',,, EffectLoc, Rotator(-HitNormal));
	Spawn(class'ShockExplosionCoreB',,, EffectLoc, HitRot);
}

defaultproperties
{
     CoilClass=Class'XEffects.ShockBeamCoilB'
     MuzFlashClass=Class'XEffects.ShockMuzFlashB'
     MuzFlash3Class=Class'XEffects.ShockMuzFlashB3rd'
     bNetTemporary=False
     Skins(0)=ColorModifier'InstagibEffects.Effects.RedSuperShockBeam'
}
