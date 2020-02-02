//=============================================================================
// ACTION_ASOpenSentinel
//=============================================================================
// Awake Sentinels...
// For AS-MotherShip intro
//=============================================================================
// Created by Laurent Delayen
// © 2004, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class ACTION_ASOpenSentinel extends ScriptedAction;

var(Action)		name	SentinelTag;

function bool InitActionFor(ScriptedController C)
{
	local ASVehicle_Sentinel	Sentinel;

	if ( SentinelTag != 'None' )
	{
		ForEach C.DynamicActors(class'ASVehicle_Sentinel', Sentinel, SentinelTag)
			Sentinel.AwakeSentinel();;
	}

	return false;	
}

function string GetActionString()
{
	return ActionString @ SentinelTag;
}

defaultproperties
{
     ActionString="Awake sentinel"
}
