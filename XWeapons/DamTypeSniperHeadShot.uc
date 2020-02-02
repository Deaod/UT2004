class DamTypeSniperHeadShot extends WeaponDamageType
	abstract;

var class<LocalMessage> KillerMessage;
var sound HeadHunter; // OBSOLETE

static function IncrementKills(Controller Killer)
{
	local xPlayerReplicationInfo xPRI;
	
	if ( PlayerController(Killer) == None )
		return;
		
	PlayerController(Killer).ReceiveLocalizedMessage( Default.KillerMessage, 0, Killer.PlayerReplicationInfo, None, None );
	xPRI = xPlayerReplicationInfo(Killer.PlayerReplicationInfo);
	if ( xPRI != None )
	{
		xPRI.headcount++;
		if ( (xPRI.headcount == 15) && (UnrealPlayer(Killer) != None) )
			UnrealPlayer(Killer).ClientDelayedAnnouncementNamed('HeadHunter',15);
	}
}		

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictemHealth )
{
    HitEffects[0] = class'HitSmoke';
    HitEffects[1] = class'HitFlameBig';
}

defaultproperties
{
     KillerMessage=Class'XGame.SpecialKillMessage'
     WeaponClass=Class'XWeapons.SniperRifle'
     DeathString="%o's cranium was made extra crispy by %k's lightning gun."
     FemaleSuicide="%o violated the laws of space-time and sniped herself."
     MaleSuicide="%o violated the laws of space-time and sniped himself."
     bAlwaysSevers=True
     bSpecial=True
     bCauseConvulsions=True
     DamageOverlayMaterial=Shader'XGameShaders.PlayerShaders.LightningHit'
     DamageOverlayTime=0.900000
}
