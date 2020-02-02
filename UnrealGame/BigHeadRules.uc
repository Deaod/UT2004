class BigHeadRules extends GameRules;

var MutBigHead BigHeadMutator;

function ScoreKill(Controller Killer, Controller Killed)
{
	if ( (Killer != None) && (Killer.Pawn != None) )
	{
		if ( Vehicle(Killer.Pawn) != None )
		{
			if ( Vehicle(Killer.Pawn).Driver != None )
				Vehicle(Killer.Pawn).Driver.SetHeadScale(BigHeadMutator.GetHeadScaleFor(Killer.Pawn));
		}
		else
			Killer.Pawn.SetHeadScale(BigHeadMutator.GetHeadScaleFor(Killer.Pawn));
	}

	if ( NextGameRules != None )
		NextGameRules.ScoreKill(Killer,Killed);
}

defaultproperties
{
}
