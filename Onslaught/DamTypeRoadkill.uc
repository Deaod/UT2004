class DamTypeRoadkill extends VehicleDamageType
	abstract;

var int MessageSwitchBase, NumMessages;

static function string DeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim)
{
	if (default.VehicleClass != None)
		return Default.DeathString @ default.VehicleClass.default.VehiclePositionString $ ".";
	else
		return Default.DeathString $ ".";
}

static function ScoreKill(Controller Killer, Controller Killed)
{
	local TeamPlayerReplicationInfo TPRI;

	if (Killer == Killed)
		return;

	TPRI = TeamPlayerReplicationInfo(Killer.PlayerReplicationInfo);
	if (TPRI != None)
	{
		TPRI.ranovercount++;
		if (TPRI.ranovercount == 10 && UnrealPlayer(Killer) != None)
		{
			UnrealPlayer(Killer).ClientDelayedAnnouncementNamed('RoadRampage', 15);
			return;
		}
	}

	if (PlayerController(Killer) != None)
		PlayerController(Killer).ReceiveLocalizedMessage(Default.MessageClass, Rand(Default.NumMessages) + Default.MessageSwitchBase);
}

defaultproperties
{
     NumMessages=4
     DeathString="%k ran over %o"
     FemaleSuicide="%o ran over herself."
     MaleSuicide="%o ran over himself."
     bLocationalHit=False
     bKUseTearOffMomentum=True
     bNeverSevers=True
     bExtraMomentumZ=False
     bVehicleHit=True
     GibModifier=2.000000
     GibPerterbation=0.500000
     MessageClass=Class'Onslaught.ONSVehicleKillMessage'
}
