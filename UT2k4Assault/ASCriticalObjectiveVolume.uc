//=============================================================================
// ASCriticalObjectiveVolume
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class ASCriticalObjectiveVolume extends Volume;

var		Info		CheckTimer;
var()	class<Pawn> ConstraintPawnClass;

function PostBeginPlay()
{
	// skip associatedactor setup..
	super(Brush).PostBeginPlay();
}

function Destroyed()
{
	if ( CheckTimer != None )
	{
		CheckTimer.Destroy();
		CheckTimer = None;
	}

	super.Destroyed();
}

function bool IsCriticalPawn( Pawn P )
{
	if ( !ClassIsChildOf(P.Class, ConstraintPawnClass) )
		return false;

	if ( P.Health > 0 && P.Controller != None 
		&& P.Controller.GetTeamNum() == 1 - Level.Game.GetDefenderNum() )
		return true;

	return false;
}


auto state Safe
{
	event Touch( Actor Other )
	{
		local GameObjective GO;

		if ( Other != None && Other.IsA('Pawn') && IsCriticalPawn( Pawn(Other) ) )
		{
			// Attackers have breached the 'Critical' objective volume (!!!)
			// Set Objectives to 'critical'
			for ( GO=TeamGame(Level.Game).Teams[0].AI.Objectives; GO!=None; GO=GO.NextObjective )
			{
				if ( GO.MyBaseVolume == Self && GO.IsActive() )
				{
					GO.SetCriticalStatus( true );
					if ( GO.DefenseSquad != None )
						GO.DefenseSquad.Team.AI.CriticalObjectiveWarning(GO, Pawn(Other));
				}
			}

			GotoState('Critical');
		}
	}
}

function bool IsStillCritical()
{
	local Pawn			P;
	local GameObjective GO;

	foreach TouchingActors(class'Pawn', P)
		if ( IsCriticalPawn( P ) )
		{
			for ( GO=TeamGame(Level.Game).Teams[0].AI.Objectives; GO!=None; GO=GO.NextObjective )
			{
				if ( GO.MyBaseVolume == Self && GO.IsActive() && (GO.DefenseSquad != None) )
					GO.DefenseSquad.Team.AI.CriticalObjectiveWarning(GO, P);
			}
			return true;
		}
			
	// Turn active objectives to 'safe'
	for ( GO=TeamGame(Level.Game).Teams[0].AI.Objectives; GO!=None; GO=GO.NextObjective )
	{
		if ( GO.MyBaseVolume == Self )
			GO.SetCriticalStatus( false );
	}

	return false;
}

state Critical
{
	function TimerPop(VolumeTimer T)
	{
		if ( !IsStillCritical() )
			GotoState('Safe');
	}

	function BeginState()
	{
		if ( CheckTimer == None )
			CheckTimer = Spawn(class'VolumeTimer', Self);
	}
}

/*	Objective has been disabled... check if the volume should keep on monitoring breaching... 
	( several objectives might be sharing the same volume ) */
state ObjectiveDisabled
{
	function BeginState()
	{
		local GameObjective GO;
		local bool			bStillCritical;

		for ( GO=TeamGame(Level.Game).Teams[0].AI.Objectives; GO!=None; GO=GO.NextObjective )
		{
			if ( GO.MyBaseVolume == Self && !GO.bDisabled )
				bStillCritical = true;
		}

		// if there is at least another active objective... keep on monitoring!
		if ( bStillCritical )
		{
			GotoState('Critical');
			return;
		}

		GotoState('Disabled');
	}
}

state Disabled
{
	function BeginState()
	{
		if ( CheckTimer != None )
		{
			CheckTimer.Destroy();
			CheckTimer = None;
		}
	}
}

function Reset()
{
	super.Reset();
	GotoState('Safe');
}

defaultproperties
{
     ConstraintPawnClass=Class'Engine.Pawn'
}
