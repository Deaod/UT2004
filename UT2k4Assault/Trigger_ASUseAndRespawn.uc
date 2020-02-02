//=============================================================================
// Trigger_ASUseAndRespawn
//=============================================================================
// Triggered using the "Use" key and respawns Player.
// Optionnal PSM_Override_Tag allows to force player to respawn is a specific
// Spawning Area (overriding its bEnabled status)
//=============================================================================

class Trigger_ASUseAndRespawn extends SVehicleTrigger
	placeable;

var()	enum AT_AssaultTeam
{
	AT_All,
	AT_Attackers,
	AT_Defenders,
} AssaultTeam;

var()	name	PSM_Override_Tag; // To force Player to use a specific PlayerSpawnManager
var float LastFailTime;	//used by AI

// Check if a Team is valid
function bool ApprovePlayerTeam(byte Team)
{
	if ( AssaultTeam == AT_All )
		return true;

	if ( Level.Game.IsA('ASGameInfo') )
	{
		if ( AssaultTeam == AT_Attackers ) { 
			if ( ASGameInfo(Level.Game).IsAttackingTeam(Team) ) return true; }
		else if ( !ASGameInfo(Level.Game).IsAttackingTeam(Team) ) return true;
	}	

	return false;
}


function Touch( Actor Other )
{
	local xPawn			User;
	local Controller	C;

	User = xPawn(Other);

	if ( !bEnabled || (User == None) || (User.Controller == None) )
		return;
		
	C = User.Controller;

	if ( ((C.RouteGoal == self) || (C.Movetarget == self)) && (AIController(C) != None) )
	{
		if ( (C.PlayerReplicationInfo != None) && !C.PlayerReplicationInfo.bOnlySpectator 
			&& ApprovePlayerTeam(C.PlayerReplicationInfo.Team.TeamIndex) )
			UsedBy(User);

		return;
	}

	// Send a string message to the toucher.
	User.ReceiveLocalizedMessage(class'Vehicles.BulldogMessage', 0);
}


function UsedBy( Pawn user )
{
	if ( !bEnabled || (User == None) || (User.Controller == None) )
		return;

	if ( !Level.Game.IsA('ASGameInfo') )
		return;

	User.PlayTeleportEffect(true, true);

	// Force player to use a specific Spawn area
	if ( PSM_Override_Tag != '' && PSM_Override_Tag != 'None' )
		User.Controller.Event = PSM_Override_Tag;

	ASGameInfo(Level.Game).RespawnPlayer( User.Controller, false );
}


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     bNoDelete=True
     bCollideActors=True
}
