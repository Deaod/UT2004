class DamTypeAssaultBullet extends WeaponDamageType
	abstract;

defaultproperties
{
     WeaponClass=Class'XWeapons.AssaultRifle'
     DeathString="%o was ventilated by %k's assault rifle."
     FemaleSuicide="%o assaulted herself."
     MaleSuicide="%o assaulted himself."
     bRagdollBullet=True
     bBulletHit=True
     FlashFog=(X=600.000000)
     KDamageImpulse=2000.000000
     VehicleDamageScaling=0.700000
}
