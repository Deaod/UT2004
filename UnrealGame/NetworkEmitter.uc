//=============================================================================
// NetworkEmitter: Relays triggering and resetting to client-side emitters
//=============================================================================
// Should only be used by Level Designers when *really* necessary
// (needs client-side triggering and/or resetting)
// Gameplay spawned FX should *NOT* use this.
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class NetworkEmitter extends Emitter;

var byte	TriggerCount, OldTriggerCount;	// triggering history since last reset
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
	
	Reset();
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
	if ( bNotFirstCall && ResetCount > OldResetCount ) // ignore Initial reset replicated value (for players joining during game)
		Reset();
	OldResetCount = ResetCount;
	bNotFirstCall = true;
}

simulated event Trigger( Actor Other, Pawn EventInstigator )
{
	local int i;

	if ( Level.NetMode != NM_Client )
	{
		NetUpdateTime = Level.TimeSeconds - 1;
		TriggerCount++;
	}

	if ( Level.NetMode != NM_DedicatedServer )
	{
		for( i=0; i<Emitters.Length; i++ )
			if ( Emitters[i] != None )
				Emitters[i].Trigger();
	}
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
     bAlwaysRelevant=True
     bReplicateMovement=False
     bSkipActorPropertyReplication=True
     bOnlyDirtyReplication=True
     RemoteRole=ROLE_DumbProxy
     NetUpdateFrequency=0.100000
     bNetNotify=True
}
