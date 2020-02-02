class ONSTurretController extends TurretController;

function Possess(Pawn aPawn)
{
	Super.Possess(aPawn);

	if (ONSWeaponPawn(aPawn) != None && ONSWeaponPawn(aPawn).Gun != None)
		ONSWeaponPawn(aPawn).Gun.bActive = true;
}

function bool SameTeamAs(Controller C)
{
	if (ONSStationaryWeaponPawn(Pawn) == None || ONSStationaryWeaponPawn(Pawn).bPowered)
		return Super.SameTeamAs(C);

	return true; //don't shoot at anybody when unpowered
}

state Engaged
{
	function BeginState()
	{
		Focus = Enemy;
		Target = Enemy;
		bFire = 1;
		Pawn.Fire(0);
	}
}

State WaitForTarget
{
	function BeginState()
	{
		Target = Enemy;
		bFire = 1;
		Pawn.Fire(0);
	}
}

defaultproperties
{
}
