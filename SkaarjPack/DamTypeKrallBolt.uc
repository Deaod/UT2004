class DamTypeKrallBolt extends DamageType
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictemHealth )
{
    HitEffects[0] = class'HitSmoke';
}

defaultproperties
{
     DeathString="%o was zapped by a krall."
     bDetonatesGoop=True
     KDamageImpulse=10000.000000
}
