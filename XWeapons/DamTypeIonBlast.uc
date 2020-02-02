class DamTypeIonBlast extends WeaponDamageType
	abstract;

defaultproperties
{
     WeaponClass=Class'XWeapons.Painter'
     DeathString="%o was OBLITERATED by %k!"
     FemaleSuicide="%o was OBLITERATED"
     MaleSuicide="%o was OBLITERATED"
     bArmorStops=False
     bDetonatesGoop=True
     bSkeletize=True
     bSuperWeapon=True
     GibModifier=0.000000
     DamageOverlayMaterial=Shader'UT2004Weapons.Shaders.ShockHitShader'
     DamageOverlayTime=1.000000
}
