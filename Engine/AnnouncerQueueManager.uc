//==============================================================================
// AnnouncerQueueManager
//==============================================================================
// Queues Announcer messages and/or critical events
//=============================================================================
//	Created by Laurent Delayen
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================

class AnnouncerQueueManager extends Info;

enum EAPriority
{
	AP_Normal,					// Queue
	AP_NoDuplicates,			// Queue if not already in Queue
	AP_InstantPlay,				// Skip if Queue is not empty
	AP_InstantOrQueueSwitch,	// Queue only if queue is empty, or if queue is filled with items ONLY of the same switch (used for countdowns)
};

struct QueueItem
{
	var Name					Voice;	// Announcer Sound
	var	float					Delay;	// Delay until next Item is processed
	var byte					Switch;	// HUD notification
};

var	Array<QueueItem>	Queue;
var	float				LastTimerCheck;
var	float				GapTime;			// Time between playing 2 announcer sounds

var	PlayerController	Receiver;


simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	LastTimerCheck = Level.TimeSeconds;
	SetTimer( 0.1, true );
}

simulated function InitFor( PlayerController PC )
{
	Receiver = PC;
}


//
// Interface
//

/* Add Item to Queue */
function bool AddItemToQueue( Name ASound, optional EAPriority Priority, optional byte Switch )
{
	local QueueItem NewItem;

	if ( Receiver == None )
		return false;

	if ( Priority == AP_InstantPlay && IsQueueing() )
		return false;

	if ( Priority == AP_InstantOrQueueSwitch && !IsQueueingSwitch( Switch ) )
		return false;

	if ( Priority == AP_NoDuplicates && CanFindSoundInQueue( ASound ) )
		return false;

	NewItem.Voice	= ASound;
	NewItem.Switch	= Switch;

	if ( Priority == AP_InstantOrQueueSwitch )	// do not queue for these, but play instantly
		NewItem.Delay = 0.01;
	else if ( (ASound != '') && (Receiver.StatusAnnouncer != None) )
		NewItem.Delay = GetSoundDuration( Receiver.StatusAnnouncer.GetSound(ASound) ) + GapTime;
	else
		NewItem.Delay = GapTime;

	if ( Queue.Length == 0 )
	{
		LastTimerCheck = Level.TimeSeconds;
		ProcessQueueItem( NewItem );
	}

	Queue[Queue.Length] = NewItem;

	return true;
}

final function bool CanFindSoundInQueue( name DaSoundName )
{
	local int	i;

	for (i=0; i<Queue.Length; i++)
	{
		if ( Queue[i].Voice == DaSoundName )
			return true;
	}

	return false;
}

final function bool IsQueueing()
{
	return( Queue.Length > 0 );
}

final function bool IsQueueingSwitch( byte Switch )
{
	local int	i;

	if ( Queue.Length == 0 )
		return true;

	for (i=0; i<Queue.Length; i++)
	{
		if ( Queue[i].Switch != Switch )
			return false;
	}

	return true;
}

final function float GetQueueWaitTime()
{
	local int	i;
	local float	WaitTime;

	if ( !IsQueueing() )
		return 0.f;

	for (i=0; i<Queue.Length; i++)
		WaitTime += Queue[i].Delay;

	return WaitTime;
}


//
// Internal
//


function Timer()
{
	local float DeltaTime;

	DeltaTime =	(Level.TimeSeconds - LastTimerCheck) / Level.TimeDilation;

	if ( Queue.Length > 0 )
	{
		Queue[0].Delay -= DeltaTime;
		if ( Queue[0].Delay <= 0 )
		{
			if ( Queue.Length > 1 )
				ProcessQueueItem( Queue[1] );

			Queue.Remove(0, 1);
		}
	}

	LastTimerCheck = Level.TimeSeconds;
}


function ProcessQueueItem( QueueItem Item )
{
	if ( Receiver == None )
		return;

	if ( Item.Voice != '' )
		Receiver.PlayStatusAnnouncement(Item.Voice, 0, true);

	if ( Item.Switch > 0 )
		Receiver.myHUD.AnnouncementPlayed( Item.Voice, Item.Switch );	// HUD event
}


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     GapTime=0.100000
}
