//==============================================================================
// Single Player Qualification menu
//
// Written by Michiel Hendriks
// (c) 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4SPTab_Qualification extends UT2K4SPTab_SingleLadder;

/**
	Select the next match, if total play time = 0 minutes and no match has been
	finished, auto select the tutorial
*/
function selectNextMatch()
{
	if ((GP.TotalTime == 0) && (GP.LadderProgress[LadderId] <= 1))
	{
		onMatchClick(Entries[0]);
		return;
	}
	super.selectNextMatch();
}

defaultproperties
{
     LadderId=0
     EntryLabels(0)="Tutorial"
     EntryLabels(1)="One on One"
     EntryLabels(2)="Cut-throat Deathmatch"
     EntryLabels(3)="Cut-throat Deathmatch"
     EntryLabels(4)="Five-way Deathmatch"
     EntryLabels(5)="Draft your team then defeat them"
     PanelCaption="Qualification"
}
