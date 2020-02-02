//=============================================================================
// ACTION_ASSetPlayerSpawnArea
//=============================================================================
// Turn ON or OFF PlayerSpawnManagers
//=============================================================================
// Created by Laurent Delayen
// © 2004, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class ACTION_ASSetPlayerSpawnArea extends ScriptedAction;

var(Action) name				PlayerSpawnManagerTag;
var(Action) bool				bEnabled;
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
		PSMs[i].SetEnabled( bEnabled );

	return false;	
}

function string GetActionString()
{
	return ActionString @ PlayerSpawnManagerTag @ "bEnabled" @ bEnabled ;
}

defaultproperties
{
     ActionString="ACTION_ASSetPlayerSpawnArea"
}
