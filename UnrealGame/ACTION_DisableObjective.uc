//=============================================================================
// ACTION_DisableObjective
//=============================================================================
// Complete objectives
//=============================================================================
// Created by Laurent Delayen
// © 2004, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class ACTION_DisableObjective extends ScriptedAction;

var(Action) name	ObjectiveTag;
var(Action)	bool	bClearInstigator;				// do not relay instigator. If Objective is completed, medal will not be given
var(Action) bool	bTriggerObjectiveInstantly;		// Trigger Objective Instantly
var	GameObjective	GO;

event PostBeginPlay( ScriptedSequence SS )
{
	super.PostBeginPlay( SS );
	if ( ObjectiveTag != 'None' )
	{
		ForEach SS.AllActors(class'GameObjective', GO, ObjectiveTag)
			break;
	}
}

function bool InitActionFor(ScriptedController C)
{
	local Pawn Instigator;
	
	if ( !bClearInstigator )
		Instigator = C.GetInstigator();

	if ( GO != None )
	{
		GO.bClearInstigator = bClearInstigator;
		if ( bTriggerObjectiveInstantly )
			GO.DisableObjective( Instigator );
		GO.CompleteObjective( Instigator );
	}

	return false;	
}

function string GetActionString()
{
	return ActionString @ ObjectiveTag;
}

defaultproperties
{
     bClearInstigator=True
     ActionString="disable objective"
}
