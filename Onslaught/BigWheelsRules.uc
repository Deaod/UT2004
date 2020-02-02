class BigWheelsRules extends GameRules;

var MutBigWheels BigWheelsMutator;

function ScoreKill(Controller Killer, Controller Killed)
{
	local Vehicle V;

	// If the killer is a vehicle, then scale its wheels based on drivers performance.
	if ( (Killer != None) && (Killer.Pawn != None) )
	{
		V = Vehicle(Killer.Pawn);
		if ( V != None )
		{
			V.SetWheelsScale( BigWheelsMutator.GetWheelsScaleFor( V.PlayerReplicationInfo ) );
		}
	}

	if ( NextGameRules != None )
		NextGameRules.ScoreKill(Killer,Killed);
}

defaultproperties
{
}
