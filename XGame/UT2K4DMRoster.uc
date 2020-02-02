//==============================================================================
// Roster for single player DM games, Players are selected randomly 
// Roster consist from unknown players from: Juggs, Mercs and Egypt
//
// Written by Michiel Hendriks
// (c) 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4DMRoster extends xDMRoster config;

/** To create the same team in the loading screen and actual game */
var config array<string> UsedBots;
var array<string> BotList;

function PostBeginPlay()
{
	if (UsedBots.Length != 0) RosterNames = UsedBots;
	Super.PostBeginPlay();
}

function PreInitialize(int TeamBots)
{
	local int i;
	Roster.Length = 0;
	UsedBots.Length = 0;
	for (i = 0; i < TeamBots; i++)
	{
		AddPlayerFromList();
	}
	SaveConfig();
}

function AddPlayerFromList()
{
	local int i, n;
	rand(BotList.length); // for randomness' sake
	i = rand(BotList.length);
	n = roster.length;
	Roster.Length = n+1;
	UsedBots.Length = n+1;
	Roster[n] = class'xRosterEntry'.static.CreateRosterEntryCharacter(BotList[i]);
	Roster[n].PrecacheRosterFor(self);
	UsedBots[n] = BotList[i];
	BotList.Remove(i, 1);
}

defaultproperties
{
     BotList(0)="Avalanche"
     BotList(1)="Sorrow"
     BotList(2)="Perdition"
     BotList(3)="Vengeance"
     BotList(4)="Stargazer"
     BotList(5)="Phantom"
     BotList(6)="Kain"
     BotList(7)="Silhouette"
     BotList(8)="Sphinx"
     BotList(9)="Natron"
     BotList(10)="Nafiret"
     BotList(11)="Tranquility"
     TeamName="Death Match"
}
