// ====================================================================
//  Class: BonusPack.MutantGameReplicationInfo
//
//  New GRI for Mutant game type. Used to replicate mutant position etc.
//
//  Written by James Golding
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class MutantGameReplicationInfo extends GameReplicationInfo;

var vector					MutantLocation;
var PlayerReplicationInfo	MutantPRI;

var PlayerReplicationInfo	BottomFeederPRI;

replication
{
	reliable if(Role == ROLE_Authority)
		MutantLocation, MutantPRI, BottomFeederPRI;
}

// every so often - update replication position of Mutant.
function PostBeginPlay()
{
	if(Role == ROLE_Authority)
		SetTimer(0.2, true);
}

function Timer()
{
	local Controller pred;

	pred = xMutantGame(Level.Game).CurrentMutant;

	if(pred != None)
	{
		MutantLocation = pred.Pawn.Location;
	}
	
	super.timer();
}

defaultproperties
{
}
