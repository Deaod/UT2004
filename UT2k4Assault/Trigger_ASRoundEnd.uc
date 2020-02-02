//=============================================================================
// Trigger_ASRoundEnd
//
//=============================================================================

class Trigger_ASRoundEnd extends Triggers;

event Trigger( Actor Other, Pawn EventInstigator )
{
	if ( Role < Role_Authority )
		return;

	if ( !Level.Game.IsA('ASGameInfo') )
		return;

	ASGameInfo(Level.Game).EndRound(ERER_AttackersWin, EventInstigator, "Attackers Win!");
}

defaultproperties
{
     bCollideActors=False
}
