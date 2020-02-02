class DamTypeIonCannonBlast extends VehicleDamageType
	abstract;

defaultproperties
{
     VehicleClass=Class'UT2k4AssaultFull.ASTurret_IonCannon'
     DeathString="%o was OBLITERATED by %k"
     FemaleSuicide="%o was OBLITERATED"
     MaleSuicide="%o was OBLITERATED"
     bArmorStops=False
     bDetonatesGoop=True
     bSkeletize=True
     GibModifier=0.000000
     DamageOverlayMaterial=Shader'UT2004Weapons.Shaders.ShockHitShader'
     DamageOverlayTime=1.000000
     VehicleDamageScaling=2.000000
}
