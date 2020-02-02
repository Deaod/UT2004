//=============================================================================
// ACTION_ASTeleportToSpawnArea
//=============================================================================
// Complete objectives
//=============================================================================
// Created by Laurent Delayen
// © 2004, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class ACTION_ASTeleportToSpawnArea extends ScriptedAction;

var(Action) name				PlayerSpawnManagerTag;
var	Array<PlayerSpawnManager>	PSMs;

event PostBeginPlay( ScriptedSequence SS )
{
	local PlayerSpawnManager	PSM;

	super.PostBeginPlay( SS );
	if ( PlayerSpawnManagerTag != 'None' )
	{
		ForEach SS.AllActors(class'PlayerSpawnManager', PSM, PlayerSpawnManagerTag)
			PSMs[PSMs.Length] = PSM;
	}
}

function bool InitActionFor(ScriptedController C)
{
	local int	i;

	for (i=0; i<PSMs.Length; i++)
		ASGameInfo(C.Level.Game).NewSpawnAreaEnabled( PSMs[i].AssaultTeam == EPSM_Defenders );

	return false;	
}

function string GetActionString()
{
	return ActionString @ PlayerSpawnManagerTag;
}

defaultproperties
{
     ActionString="teleport to spawn area"
}
