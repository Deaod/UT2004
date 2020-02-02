class DamTypeMinigunBullet extends WeaponDamageType
	abstract;

defaultproperties
{
     WeaponClass=Class'XWeapons.Minigun'
     DeathString="%o was mowed down by %k's minigun."
     FemaleSuicide="%o turned the minigun on herself."
     MaleSuicide="%o turned the minigun on himself."
     bRagdollBullet=True
     bBulletHit=True
     FlashFog=(X=600.000000)
     KDamageImpulse=2000.000000
     VehicleDamageScaling=0.650000
}
