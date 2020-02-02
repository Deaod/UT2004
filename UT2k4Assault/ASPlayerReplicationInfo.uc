//=============================================================================
// ASPlayerReplicationInfo
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class ASPlayerReplicationInfo extends xPlayerReplicationInfo;

var byte	DisabledObjectivesCount;
var byte	DisabledFinalObjective;
var byte	DestroyedVehicles;
var float	TrophiesXOffset;			// for drawing tropheys on scoreboard
var String	PawnOverrideClass;

var	bool	bAutoRespawn;				// for reinforcements
var bool	bTeleportToSpawnArea;		// Player can teleport to new spawn area
var int		TeleportTime;				// countdown until valid

replication
{
	reliable if ( bNetDirty && Role == ROLE_Authority )
		DisabledObjectivesCount, DisabledFinalObjective, bAutoRespawn, bTeleportToSpawnArea, TeleportTime, DestroyedVehicles;
}

function Timer()
{
	local NavigationPoint	NP;
	local Controller		C;
	local GameObjective		GO;

	super.Timer();

	if ( bBot && bTeleportToSpawnArea && TeleportTime != Level.TimeSeconds )
	{
		C	= Controller(Owner);
		GO	= ASGameInfo(Level.Game).GetCurrentObjective();

		if ( GO == None || !CanBotTeleport( C ) )
		{
			bTeleportToSpawnArea = false;
			return;
		}

		// Only Teleport if far from new Spawn Area
		NP = Level.Game.FindPlayerStart( C, C.GetTeamNum() );

		// Check if worth respawning
		if ( VSize(GO.Location - C.Pawn.Location) > VSize(GO.Location - NP.Location) + 1024 )
			ASGameInfo(Level.Game).TeleportPlayerToSpawn( C );
		else
		{
			bTeleportToSpawnArea = false;
		}
	}
}

function bool CanBotTeleport( Controller C )
{
	local Vehicle	V;

	if ( C.Pawn == None )
		return false;

	// Don't exit if in a vehicle, except turrets
	if ( Vehicle(C.Pawn) != None )
	{
		V = Vehicle(C.Pawn);
		if ( V.IndependentVehicle() && !V.bStationary )
			return false;
		
		if ( !V.IndependentVehicle() && !V.GetVehicleBase().bStationary )
			return false;
	}

	return true;
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	PawnOverrideClass		= "";
	HasFlag					= None;
	bReadyToPlay			= false;
	NumLives				= 0;
	bOutOfLives				= false;
	bTeleportToSpawnArea	= false;
}

defaultproperties
{
}
