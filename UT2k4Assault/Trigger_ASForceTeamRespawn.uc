//=============================================================================
// Trigger_ASForceTeamRespawn
//=============================================================================
// Triggered actor that will respawn a whole Assault Team.
//=============================================================================

class Trigger_ASForceTeamRespawn extends Triggers;

event Trigger( Actor Other, Pawn EventInstigator )
{
	local Controller	C;
	local Pawn			OldPawn;

	if ( Role < Role_Authority || !Level.Game.IsA('ASGameInfo') )
		return;

    for ( C = Level.ControllerList; C != None; C = C.NextController )
		if ( (C.PlayerReplicationInfo != None) && !C.PlayerReplicationInfo.bOnlySpectator )
    	{
			if ( Vehicle(C.Pawn) != None )
				Vehicle(C.Pawn).KDriverLeave( true );

			if ( C.Pawn != None && C.Pawn.Weapon == None )
			{
				OldPawn = C.Pawn;
				C.UnPossess();
				OldPawn.Destroy();
				C.Pawn = None;
				Level.Game.RestartPlayer( C );
			}

			ASGameInfo(Level.Game).RespawnPlayer( C, false );
     	}
}

defaultproperties
{
     bCollideActors=False
}
