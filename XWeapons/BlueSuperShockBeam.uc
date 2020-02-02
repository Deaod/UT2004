class BlueSuperShockBeam extends ShockBeamEffect;

simulated function SpawnEffects()
{
	local ShockBeamEffect E;
	
	Super.SpawnEffects();
	E = Spawn(class'ExtraBlueBeam');
	if ( E != None )
		E.AimAt(mSpawnVecA, HitNormal); 
}

defaultproperties
{
     CoilClass=Class'XWeapons.ShockBeamCoilBlue'
     LightHue=230
     bNetTemporary=False
     Skins(0)=ColorModifier'InstagibEffects.Effects.BlueSuperShockTex'
}
