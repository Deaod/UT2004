//=============================================================================
// ACTION_PlayerViewShake
//=============================================================================
// Shake player's view within radius. Against ViewShakes, it works client side
//=============================================================================
// Created by Laurent Delayen
// © 2004, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class ACTION_PlayerViewShake extends ScriptedAction;

var(Action)	float	Radius;
var(Action)	int		Intensity;

function bool InitActionFor(ScriptedController C)
{
	local Controller	Ctrl;

	for ( Ctrl=C.Level.ControllerList; Ctrl!=None; Ctrl=Ctrl.NextController )
		if ( (PlayerController(Ctrl) != None) 
			&& (VSize(C.Location - PlayerController(Ctrl).ViewTarget.Location) < Radius) )		
			Ctrl.DamageShake( Intensity );

	return false;	
}

function string GetActionString()
{
	return ActionString @ "Radius:" @ Radius @ "Intensity:" @ Intensity;
}

defaultproperties
{
     Radius=2000.000000
     Intensity=25
     ActionString="PlayerViewShake"
}
