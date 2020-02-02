//=============================================================================
// LeavingBattleFieldVolume
//=============================================================================

class LeavingBattleFieldVolume extends Volume;

var	VolumeTimer	CheckTimer;

function PostBeginPlay()
{
	// skip associatedactor setup..
	super(Brush).PostBeginPlay();

	if ( CheckTimer == None )
	{
		CheckTimer = Spawn(class'VolumeTimer', Self);
		if ( CheckTimer != None )
			CheckTimer.TimerFrequency = 2;
	}
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

function TimerPop(VolumeTimer T)
{
	local Pawn			P;

	foreach TouchingActors(class'Pawn', P)
		if ( PlayerController(P.Controller) != None )
			PlayerController(P.Controller).ReceiveLocalizedMessage(class'Message_ASKillMessages', 7);
}

defaultproperties
{
}
