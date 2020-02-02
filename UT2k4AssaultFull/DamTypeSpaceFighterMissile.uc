class DamTypeSpaceFighterMissile extends VehicleDamageType
	abstract;

static function ScoreKill(Controller Killer, Controller Killed)
{
	if (Killed != None && Killer != Killed && Vehicle(Killed.Pawn) != None && Vehicle(Killed.Pawn).bCanFly)
	{
		if ( ASVehicle_SpaceFighter(Killer.Pawn) == None )
			return;

		ASVehicle_SpaceFighter(Killer.Pawn).TopGunCount++;

		//Maybe add to game stats?
		if ( ASVehicle_SpaceFighter(Killer.Pawn).TopGunCount == 5 && PlayerController(Killer) != None )
		{
			ASVehicle_SpaceFighter(Killer.Pawn).TopGunCount = 0;
			PlayerController(Killer).ReceiveLocalizedMessage(class'Message_ASKillMessages', 0);
		}
	}
}

defaultproperties
{
     VehicleClass=Class'UT2k4AssaultFull.ASVehicle_SpaceFighter_Human'
     DeathString="%o couldn't avoid %k's missile."
     FemaleSuicide="%o blasted herself out of space."
     MaleSuicide="%o blasted himself out of space."
     bDelayedDamage=True
}
