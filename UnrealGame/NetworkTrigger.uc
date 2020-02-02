//=============================================================================
// NetworkTrigger: Relays triggering and resetting to client-side actors
//=============================================================================
// Should only be used by Level Designers when *really* necessary
// (needs client-side triggering and/or resetting)
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class NetworkTrigger extends Actor
	placeable;

var byte	TriggerCount, OldTriggerCount; // triggering history since last reset
var byte	ResetCount, OldResetCount;
var bool	bNotFirstCall;

replication
{
	unreliable if ( Role == ROLE_Authority && bNetDirty )
		TriggerCount, ResetCount;
}

simulated function PostNetBeginPlay()
{
	super.PostNetBeginPlay();
	
	DoClientReset();
	UpdateTriggerCount();
	OldResetCount = ResetCount;
}

/* keeps track of triggering history, client will perform the exact sequence when joining a game */
simulated function UpdateTriggerCount()
{
	local int i;

	if ( TriggerCount > OldTriggerCount )
		for (i=OldTriggerCount; i<TriggerCount; i++)
			Trigger(None, None);

	OldTriggerCount = TriggerCount;
}

simulated event PostNetReceive()
{ 
	super.PostNetReceive();
	
	UpdateTriggerCount();
	if ( bNotFirstCall && ResetCount > OldResetCount )	// ignore Initial reset replicated value (for players joining during game)
		DoClientReset();

	OldResetCount = ResetCount;
	bNotFirstCall = true;
}

simulated function DoClientReset()
{
	local Actor A;

	ForEach AllActors(class'Actor', A, Event)
		A.Reset();
}

simulated event Trigger( Actor Other, Pawn EventInstigator )
{
	if ( Level.NetMode != NM_Client )
	{
		NetUpdateTime = Level.TimeSeconds - 1;
		TriggerCount++;
	}
	
	if ( Level.NetMode != NM_DedicatedServer )
		TriggerEvent( Event, Other, EventInstigator );
}


simulated function Reset()
{
	if ( Level.NetMode != NM_Client )
	{
		NetUpdateTime = Level.TimeSeconds - 1;
		ResetCount++;
		TriggerCount = 0;
	}

	super.Reset();	
}

defaultproperties
{
     bHidden=True
     bNoDelete=True
     bAlwaysRelevant=True
     bReplicateMovement=False
     bSkipActorPropertyReplication=True
     bOnlyDirtyReplication=True
     NetUpdateFrequency=0.100000
     bNetNotify=True
}
