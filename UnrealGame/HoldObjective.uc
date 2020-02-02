//==============================================================================
// HoldObjective
//==============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================

class HoldObjective extends ProximityObjective;

var()	name			MoverTag;
var		Array<Mover>	LinkedMover;

struct TouchingPlayer
{
	var Controller	C;
	var float		TouchTime;
};

var array<TouchingPlayer>	TouchingPlayers;		// List of touching players (for score sharing)
var	Controller				LastPlayerTouching;

var array<Actor>	Touchers;		// List of touching actors (used for TrueTouch() en TrueUnTouch() events)

var float	TotalHeldTime;
var bool	bIsHeld, bIsTriggerControl;

var()	bool	bLocationFX;
var		Emitter	LocationFX;

replication
{
	unreliable if ( (Role==ROLE_Authority) && bReplicateObjective && bNetDirty )
		bIsHeld;
}


simulated function PostBeginPlay()
{
	local Mover	myMover;

	super.PostBeginPlay();

	if ( MoverTag == '' )
		warn( Self @ "MoverTag not defined!!!" );
	else
	{
		ForEach AllActors(class'Mover', myMover, MoverTag)
		{
			if ( myMover.InitialState == 'TriggerControl' )
				bIsTriggerControl = true;

			LinkedMover[LinkedMover.Length] = myMover;
			if ( myMover.Event == '' )
				warn( myMover @ "doesn't have it's Event set. It should trigger back the HoldObjective" @ Self );
		}
	}
}

/* TellBotHowToDisable()
tell bot what to do to disable me.
return true if valid/useable instructions were given
*/
function bool TellBotHowToDisable(Bot B)
{
	local Bot NextBot;
	if ( (VSize(B.Pawn.Location - Location) < 1000) && B.LineOfSightTo(self) )
	{
		// if teammate already touching, then don't need to
		for ( NextBot=B.Squad.SquadMembers; NextBot!=None; NextBot=NextBot.NextSquadMember )
			if ( (NextBot != B) && (NextBot.Pawn != None) && NextBot.Pawn.ReachedDestination(self) )
				return false;
	}
	if ( (B.Enemy != None) && (B.Skill > 4*FRand()) && (B.Pawn.Health < 250 * FRand()) && B.Pawn.ReachedDestination(self) )
		B.bShieldSelf = true;
	return Super.TellBotHowToDisable(B);
}


event Touch( Actor Other )
{
	local Pawn	P;

	P = Pawn( Other );
	if ( P != None && IsRelevant(P, true) )
		AddNewTouchingPlayer( P.Controller );
}

event UnTouch( Actor Other )
{
	local Pawn	P;

	P = Pawn( Other );
	if ( P != None && IsRelevant(P, true) )
		RemoveTouchingPlayer( P.Controller );
}

/* ToucherDied() called when Pawn P dies, to untrigger player only triggers */
function PlayerToucherDied( Pawn P )
{
	RemoveTouchingPlayer( P.GetKillerController() );
}


function AddNewTouchingPlayer( Controller C )
{
	local int				i;
	local TouchingPlayer	TP;

	TP.C = C;
	TP.TouchTime = Level.TimeSeconds;
	TouchingPlayers[TouchingPlayers.Length] = TP;

	bIsHeld = true;
	CheckPlayCriticalAlarm();

	for ( i=0; i<LinkedMover.Length; i++ )
		LinkedMover[i].Trigger( Self, C.Pawn );

	if ( C != None )
	{
		for ( i=0;i<4;i++ )
			if ( C.GoalList[i] == self )
			{
				C.GoalList[i] = None;
				break;
			}
	}
}

function RemoveTouchingPlayer( Controller C )
{
	local int	i, j;
	local float	HoldTime;

	for ( i=0;i<TouchingPlayers.Length;i++ )
		if ( TouchingPlayers[i].C == C )
		{
			HoldTime = Level.TimeSeconds - TouchingPlayers[i].TouchTime;
			if ( !bIsTriggerControl && HoldTime > 0 )
			{
				AddScorer( C, HoldTime );
				TotalHeldTime += HoldTime;
			}
			LastPlayerTouching = C;
			DelayedDamageInstigatorController = C;
			TouchingPlayers.Remove(i,1);
			if ( TouchingPlayers.Length == 0 )
			{
				bIsHeld = false;
				CheckPlayCriticalAlarm();
			}

			for ( j=0;j<LinkedMover.Length;j++ )
			{
				LinkedMover[j].UnTrigger( Self, C.Pawn );
			}

			break;
		}
}


/* Award Assault score to player(s) who completed the objective */
function AwardAssaultScore( int Score )
{
	local int	i;
	local float	HoldTime, BestHeldTime;

	// Add touching time of current touchers
	if ( TouchingPlayers.Length > 0 )
		for (i=0; i<TouchingPlayers.Length; i++)
			if ( TouchingPlayers[i].C != None )
			{
				HoldTime = Level.TimeSeconds - TouchingPlayers[i].TouchTime;
				AddScorer( TouchingPlayers[i].C, HoldTime );
				TotalHeldTime += HoldTime;

				// Force Trophy on player currently holding objective for the longest time
				if ( HoldTime > BestHeldTime )
				{
					BestHeldTime	= HoldTime;
					DisabledBy		= TouchingPlayers[i].C.PlayerReplicationInfo;
				}
			}

	// Convert Scorers Pct to real Pct...
	for (i=0; i<Scorers.Length; i++)
		Scorers[i].Pct = Scorers[i].Pct / TotalHeldTime;

	ShareScore( Score, "Objective_Completed" );
}

/* Called by mover once completed */
function Trigger(Actor Other, Pawn Instigator)
{
	local int	i;
	local float	BestTime;
	local Pawn	RealInstigator;

	if ( bDisabled )
		return;

	if ( bBotOnlyObjective )
	{
		RealInstigator = None;
	}
	else
	{
		// Set the players triggering the objective for the longest time to be the instigator
		if ( TouchingPlayers.Length > 0 )
		{
			for (i=0; i<TouchingPlayers.Length; i++)
			{
				if ( BestTime == 0 || TouchingPlayers[i].TouchTime < BestTime )
				{
					if ( TouchingPlayers[i].C.Pawn != None )
					{
						BestTime			= TouchingPlayers[i].TouchTime;
						RealInstigator		= TouchingPlayers[i].C.Pawn;
						LastPlayerTouching	= TouchingPlayers[i].C;			// in case RealInstigator doesn't exist when sharing scores.
					}
					else
						DelayedDamageInstigatorController = TouchingPlayers[i].C;	// Pawn may be dead...
				}
			}
		}

		if ( RealInstigator == None )
		{
			if ( Instigator != None && Instigator.Controller != None )
			{
				RealInstigator		= Instigator;
				LastPlayerTouching	= Instigator.Controller;
			}
			else if ( LastPlayerTouching != None && LastPlayerTouching.Pawn != None )
			{
				RealInstigator = LastPlayerTouching.Pawn;
			}
			else if ( DelayedDamageInstigatorController != None )
			{
				RealInstigator = DelayedDamageInstigatorController.Pawn;
			}
		}
	}

	DisableObjective( RealInstigator );
}

/* triggered by intro cinematic to auto complete objective */
function CompleteObjective( Pawn Instigator )
{
	local int i;

	for ( i=0;i<LinkedMover.Length;i++ )
		LinkedMover[i].Trigger( Self, Instigator );
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	LastPlayerTouching		= None;
	Touchers.Length			= 0;
	TouchingPlayers.Length	= 0;
	TotalHeldTime			= 0;
	bIsHeld					= false;

	super.Reset();
}

/* returns objective's progress status 1->0 (=disabled)
	Assumes mover(s) only have 1 keyframe */
simulated function float GetObjectiveProgress()
{
	local int	i, BestMover;
	local float	BestTime;

	if ( !bDisabled && LinkedMover.Length > 0 )
	{
		// If linked to several movers, pick longest MoveTime
		for ( i=0;i<LinkedMover.Length;i++ )
			if ( LinkedMover[i].MoveTime > BestTime )
			{
				BestTime	= LinkedMover[i].MoveTime;
				BestMover	= i;
			}

		if ( LinkedMover[BestMover].KeyNum >= LinkedMover[BestMover].PrevKeyNum )
			return  (1.f - LinkedMover[BestMover].PhysAlpha);	// opening
		else
			return  LinkedMover[BestMover].PhysAlpha;			// closing
	}
	return 0;
}

/* holdobjective critical when in a critical volume or when holding it */
simulated function bool IsCritical()
{
	return (IsActive() && (bIsCritical || bIsHeld));
}

/* Add pulsing overlay on objective's physical representation */
simulated function SetObjectiveOverlay( bool bShow )
{
	super.SetObjectiveOverlay( bShow );

	// Toggle stand location FX
	if ( bLocationFX && Level.NetMode != NM_DedicatedServer )
	{
		if ( LocationFX == None )
			LocationFX = Spawn(class'FX_HoldObjective', Self,, Location - CollisionHeight*0.95*vect(0,0,1) );

		if ( LocationFX != None )
			LocationFX.bHidden = !bShow;
	}
}

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Material'AS_FX_TX.Emitter.HoldArrow');
	super.UpdatePrecacheMaterials();
}

defaultproperties
{
     bLocationFX=True
     ObjectiveName="Hold Objective"
     ObjectiveTypeIcon=FinalBlend'AS_FX_TX.Icons.OBJ_Hold_FB'
     ObjectiveDescription="Touch and Hold Objective to disable it."
     Objective_Info_Attacker="Hold Objective"
     bReceivePlayerToucherDiedNotify=True
}
