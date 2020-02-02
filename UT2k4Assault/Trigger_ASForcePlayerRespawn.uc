//=============================================================================
// Trigger_ASForcePlayerRespawn
//=============================================================================
// Triggered Actor that will respawn the Instigator.
//=============================================================================

class Trigger_ASForcePlayerRespawn extends Triggers;

var()	enum EPSM_AssaultTeam
{
	EPSM_Attackers,
	EPSM_Defenders,
} AssaultTeam;

var()	enum EFTR_Constraint
{
	EFTRC_All,
	EFTRC_PawnClass,
} Constraint;


var()	class<Pawn>	ConstraintPawnClass;	// Trigger will only be relevant to a specific Pawn class ?
var()	name		PSM_OverrideTag;		// force player to use a specific PlayerStartManager
var()	bool		bTryToRepossess;		// Try to repossess old Pawn instead of Spawning a new one (when driving a vehicle...)


event Trigger( Actor Other, Pawn EventInstigator )
{
	local Controller C;

	if ( Role < Role_Authority || !Level.Game.IsA('ASGameInfo') )
		return;

	if ( EventInstigator == None )
		return;

	C = EventInstigator.Controller;

 	if ( (C!=None) && (C.PlayerReplicationInfo != None) && !C.PlayerReplicationInfo.bOnlySpectator 
		&& ApprovePlayerTeam(C.PlayerReplicationInfo.Team.TeamIndex) )
    {
		// Pawn class constraint
		if ( Constraint == EFTRC_PawnClass && ConstraintPawnClass != None 
			&& C.PawnClass != ConstraintPawnClass )
			return;

		// Force player to use a specific PlayerSpawnManager
		if ( PSM_OverrideTag != '' && PSM_OverrideTag != 'None' )
			C.Event = PSM_OverrideTag;

		// Try to repossess OldPawn if possible
		if ( bTryToRepossess && EventInstigator.IsA('Vehicle') )
			Vehicle(EventInstigator).KDriverLeave( true );

		ASGameInfo(Level.Game).RespawnPlayer( C, false );
    }
}


// Check if a Team is valid
function bool ApprovePlayerTeam(byte Team)
{
	if ( Level.Game.IsA('ASGameInfo') )
	{
		if ( AssaultTeam == EPSM_Attackers ) { 
			if ( ASGameInfo(Level.Game).IsAttackingTeam(Team) ) return true; }
		else if ( !ASGameInfo(Level.Game).IsAttackingTeam(Team) ) return true;
	}	

	return false;
}


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     bTryToRepossess=True
     bCollideActors=False
}
