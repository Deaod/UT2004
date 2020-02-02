class DamTypeLinkTurretPlasma extends VehicleDamageType
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictemHealth )
{
    HitEffects[0] = class'HitSmoke';
}

defaultproperties
{
     VehicleClass=Class'UT2k4AssaultFull.ASTurret_LinkTurret'
     DeathString="%o was served an extra helping of %k's plasma."
     FemaleSuicide="%o fried herself with her own plasma blast."
     MaleSuicide="%o fried himself with his own plasma blast."
     bDetonatesGoop=True
     FlashFog=(X=700.000000)
     DamageOverlayMaterial=Shader'XGameShaders.PlayerShaders.LinkHit'
     DamageOverlayTime=0.500000
}
