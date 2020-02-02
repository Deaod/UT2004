class DamTypeAttackCraftMissle extends VehicleDamageType
	abstract;

static function ScoreKill(Controller Killer, Controller Killed)
{
	if (Killed != None && Killer != Killed && Vehicle(Killed.Pawn) != None && Vehicle(Killed.Pawn).bCanFly)
	{
		//Maybe add to game stats?
		if (PlayerController(Killer) != None)
			PlayerController(Killer).ReceiveLocalizedMessage(class'ONSVehicleKillMessage', 6);
	}
}

defaultproperties
{
     VehicleClass=Class'Onslaught.ONSAttackCraft'
     DeathString="%o couldn't avoid %k's air-to-air missile."
     FemaleSuicide="%o blasted herself out of the sky."
     MaleSuicide="%o blasted himself out of the sky."
     bDelayedDamage=True
     VehicleDamageScaling=1.500000
     VehicleMomentumScaling=0.750000
}
