class DamTypeMinigunTurretBullet extends VehicleDamageType
	abstract;

defaultproperties
{
     VehicleClass=Class'UT2k4Assault.ASTurret_Minigun'
     DeathString="%o was mowed down by %k's minigun turret."
     FemaleSuicide="%o turned the minigun on herself."
     MaleSuicide="%o turned the minigun on himself."
     bRagdollBullet=True
     bBulletHit=True
     FlashFog=(X=600.000000)
     KDamageImpulse=2000.000000
     VehicleDamageScaling=0.750000
}
