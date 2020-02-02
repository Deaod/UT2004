class MutWheeledVehicleStunts extends Mutator;

var config float MaxForce;
var config float MaxSpin;
var config float JumpChargeTime;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	local ONSWheeledCraft V;

	V = ONSWheeledCraft(Other);
	if (V != None)
	{
		V.bAllowAirControl = true;

		V.bAllowChargingJump = true;
		V.bSpecialHUD = true;
//		V.bScriptedRise = true;
		V.MaxJumpForce = MaxForce;
		V.MaxJumpSpin = MaxSpin;
		V.JumpChargeTime = JumpChargeTime;
		V.bHasHandbrake = false;

		//easier to get big jumps so make it harder to get an award for it
		V.DaredevilThreshInAirDistance *= 1.5;
		V.DaredevilThreshInAirTime *= 1.5;
		V.DaredevilThreshInAirSpin *= 2.0;
	}

	return true;
}

defaultproperties
{
     MaxForce=200000.000000
     MaxSpin=80.000000
     JumpChargeTime=1.000000
     GroupName="VehicleStunts"
     FriendlyName="Stunt Vehicles"
     Description="Players can make the wheeled vehicles jump. Hold down the crouch key to charge up and then release to jump. They can also control wheeled vehicles in mid-air."
}
