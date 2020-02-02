//=============================================================================
// PlayerSpawnManager
//
// In Assault Player.PlayerReplicationInfo.Team and PlayerStart.TeamNumber do not match!
// The SpawnManager makes the connection between the team number and the right PlayerStart
// Taking in account things like:
// - which team is attacking or defending
// - multiple (consecutively triggered or not) spawn areas
// - forced pawn class with specific spawn areas
//
// How to use:
// - Add a PlayerSpawnManager for each Spawn area in the level
// - Due to the way UT handles playerstarts, 
//			you must have PlayerStart actors with TeamNumber=0 in the Level
//
// Parameters are self explanatory
//
//=============================================================================

class PlayerSpawnManager extends Info
	placeable;

var()	enum EPSM_AssaultTeam
{
	EPSM_Attackers,
	EPSM_Defenders,
} AssaultTeam;

var()	enum EPSM_ForcePossessPawn
{
	EPSM_None,								// No Force..
	EPSM_ForcedPawnClass,					// Forces Pawn class override at spawn
	EPSM_ForceDefaultPawnClass,				// Forces controller to use his default Pawn Class when spawning
} OverridePawnClass;

var()	class<Pawn>	ForcedPawnClass;			
var()	int			PlayerStartTeam;			// TeamNumber of the PlayerStart actors the manager is pointing to
var()	bool		bEnabled;					// Spawn manager active?

// backup
var		bool	BACKUP_bEnabled;
var() bool	bAllowTeleporting;	// Allow players to teleport there when it's enabled.

// Memory/Network/CPU optimizations
// When PlayerSpawnManager is trigger disabled, auto kill vehicles and shutdown vehicle factories
var()	editinline	array<Name>	DisabledVehicleFactoriesTag;	// Disable vehicle factories (and kill child)


simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	BACKUP_bEnabled = bEnabled;
}

simulated function UpdatePrecacheMaterials()
{
	super.UpdatePrecacheMaterials();

	if ( (ForcedPawnClass != None) && ( Level.NetMode != NM_DedicatedServer ) )
		ForcedPawnClass.static.StaticPrecache( Level );
}

function SetEnabled( bool bNewStatus )
{
	local ASVehicleFactory	ASVF;
	local int				i;

	if ( bNewStatus == bEnabled )
		return;

	bEnabled = bNewStatus;
	if ( !bEnabled )
	{
		if ( DisabledVehicleFactoriesTag.Length > 0 )
		{
			ForEach DynamicActors(class'ASVehicleFactory', ASVF)
				for (i=0; i<DisabledVehicleFactoriesTag.Length; i++)
				{
					if ( ASVF.Tag == DisabledVehicleFactoriesTag[i] )
						ASVF.ShutDown();
				}
		}
	}
	else if ( bAllowTeleporting )
		ASGameInfo(Level.Game).NewSpawnAreaEnabled( AssaultTeam == EPSM_Defenders );
}

function Trigger( actor Other, Pawn EventInstigator )
{
	if ( bEnabled )
		TriggerEvent( Event, Self, EventInstigator); // to enable another PlayerSpawnManager for example

	SetEnabled( !bEnabled );
}


// Check if a PlayerStart is valid
singular function bool ApprovePlayerStart(PlayerStart P, byte Team, Controller Player)
{
	Local name	OverrideTag;

	if ( Player == None || Player.Event == 'None' )
		OverrideTag = '';
	else
		OverrideTag = Player.Event;

	// Is PlayerSpawnManager active?
	if ( !bEnabled && OverrideTag == '' )
		return false;

	// Are we dealing with the right PlayerSpawnManger?
	if ( P.TeamNumber != PlayerStartTeam )
		return false;

	// Is the PlayerStart for the correct Player's Team ?
	if ( Level.Game.IsA('ASGameInfo') )
	{
		if ( AssaultTeam == EPSM_Attackers ) 
		{ 
			if ( !ASGameInfo(Level.Game).IsAttackingTeam(Team) ) return false; 
		}
		else if ( ASGameInfo(Level.Game).IsAttackingTeam(Team) ) return false;
	}	

	// Forced PlayerSpawnManager?
	if ( OverrideTag != '' && OverrideTag != Tag )
		return false;

	return true;
}

// Player spawned
function String PawnClassOverride(Controller C, NavigationPoint NP, byte Team)
{
	if ( OverridePawnClass == EPSM_None )
		return "";

	if ( C==None || NP==None || !NP.IsA('PlayerStart') )
		return "";

	if ( !ApprovePlayerStart(PlayerStart(NP), Team, C) )
		return "";

	// Pawn class override
	if ( OverridePawnClass == EPSM_ForcedPawnClass && ForcedPawnClass != None )
		return String(ForcedPawnClass);

	if ( OverridePawnClass == EPSM_ForceDefaultPawnClass ) /*obsolete*/
		return "";

	return "";
}


/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	super.Reset();
	bEnabled = BACKUP_bEnabled;
}


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     OverridePawnClass=EPSM_ForceDefaultPawnClass
     bEnabled=True
     bAllowTeleporting=True
     bNoDelete=True
}
