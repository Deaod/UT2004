class DamTypeONSVehicleExplosion extends DamageType
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth)
{
    HitEffects[0] = class'HitSmoke';

    if( VictimHealth <= 0 )
        HitEffects[1] = class'HitFlameBig';
    else if ( FRand() < 0.8 )
        HitEffects[1] = class'HitFlame';
}

defaultproperties
{
     DeathString="%k took out %o with a vehicle explosion."
     FemaleSuicide="%o was a little too close to the vehicle she blew up."
     MaleSuicide="%o was a little too close to the vehicle he blew up."
     bDetonatesGoop=True
     bThrowRagdoll=True
     bFlaming=True
     GibPerterbation=0.150000
}
