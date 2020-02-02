class DamTypeLinkTurretBeam extends VehicleDamageType
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictemHealth )
{
    HitEffects[0] = class'HitSmoke';
}

defaultproperties
{
     VehicleClass=Class'UT2k4AssaultFull.ASTurret_LinkTurret'
     DeathString="%o was carved up by %k's green shaft."
     FemaleSuicide="%o shafted herself."
     MaleSuicide="%o shafted himself."
     bDetonatesGoop=True
     bSkeletize=True
     bCausesBlood=False
     bLeaveBodyEffect=True
     DamageOverlayMaterial=Shader'XGameShaders.PlayerShaders.LinkHit'
     DamageOverlayTime=0.500000
}
