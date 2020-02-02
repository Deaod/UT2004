//==============================================================================
// Class to hold the single player highscores
//
// Written by Michiel Hendriks
// (c) 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class SPHighScore extends SPHighScoreBase;

struct HighScoreEntry
{
	var string Name;
	var int Balance;
	var int Matches;
	var int Wins;
	var float Difficulty;
	var bool bDrone;				// false if it's a real entry
};
/** sorted list */
var array<HighScoreEntry> Scores;
var int MaxEntries;

var localized string CheaterName;

/** To prevent cheating */
var protected string PlayerIDHash;

delegate CharUnlocked( string CharName );

/** return's true when added */
function int AddHighScore(UT2K4GameProfile GP)
{
	local int i, newscore;
	local HighScoreEntry newEntry;
	if (GP.isCheater()) newEntry.Name = CheaterName;
		else newEntry.Name = GP.PlayerName;
	newEntry.Balance = GP.Balance;
	newEntry.Matches = GP.Matches;
	newEntry.Wins = GP.Wins;
	newEntry.Difficulty = GP.Difficulty;
	newEntry.bDrone = false;

	newscore = CalcScore(newEntry);
	for (i = 0; i < Scores.length; i++)
	{
		// find first worse entry
		if (CalcScore(Scores[i]) < newscore) break;
	}
	if (i >= MaxEntries) return -1;
	Scores.Insert(i, 1);
	Scores[i] = newEntry;
	Scores.length = MaxEntries;
	return i;
}

static function int CalcScore(HighScoreEntry entry)
{
	local int res;
	res = (entry.Difficulty*100000)-(entry.Matches*100)+entry.Balance;
	return res;
}

function UnlockChar(string char, optional string PlayerHash)
{
	local int i;
	if ((PlayerIDHash != PlayerHash) && (PlayerHash != ""))
	{
		UnlockedChars.length = 0;
		PlayerIDHash = PlayerHash;
	}
	for (i = 0; i < UnlockedChars.length; i++)
	{
		if (UnlockedChars[i] == Char) return;
	}
	UnlockedChars.length = UnlockedChars.length+1;
	UnlockedChars[UnlockedChars.length-1] = char;

	if ( char != "" )
		CharUnlocked(char);
}

function string StoredPlayerID()
{
	return PlayerIDHash;
}

defaultproperties
{
     Scores(0)=(Name="Xan Kriegor",Balance=5000,Matches=40,Wins=40,Difficulty=2.000000,bDrone=True)
     Scores(1)=(Name="Clan Lord",Balance=4900,Matches=45,Wins=41,Difficulty=2.000000,bDrone=True)
     Scores(2)=(Name="Malcolm",Balance=4800,Matches=50,Wins=42,Difficulty=2.000000,bDrone=True)
     Scores(3)=(Name="Dominator",Balance=4700,Matches=55,Wins=43,Difficulty=2.000000,bDrone=True)
     Scores(4)=(Name="Enigma",Balance=4600,Matches=60,Wins=44,Difficulty=2.000000,bDrone=True)
     Scores(5)=(Name="Jakob",Balance=4500,Matches=65,Wins=45,Difficulty=2.000000,bDrone=True)
     Scores(6)=(Name="Cyclops",Balance=4400,Matches=70,Wins=46,Difficulty=2.000000,bDrone=True)
     Scores(7)=(Name="Drekorig",Balance=4300,Matches=75,Wins=47,Difficulty=2.000000,bDrone=True)
     Scores(8)=(Name="Aryss",Balance=4200,Matches=80,Wins=48,Difficulty=2.000000,bDrone=True)
     Scores(9)=(Name="Axon",Balance=4100,Matches=85,Wins=49,Difficulty=2.000000,bDrone=True)
     Scores(10)=(Name="Skakruk",Balance=4000,Matches=90,Wins=50,Difficulty=2.000000,bDrone=True)
     Scores(11)=(Name="Tamika",Balance=3900,Matches=95,Wins=51,Difficulty=2.000000,bDrone=True)
     Scores(12)=(Name="Cathode",Balance=3800,Matches=100,Wins=52,Difficulty=2.000000,bDrone=True)
     Scores(13)=(Name="Guardian",Balance=3700,Matches=105,Wins=53,Difficulty=2.000000,bDrone=True)
     Scores(14)=(Name="Othello",Balance=3600,Matches=110,Wins=54,Difficulty=2.000000,bDrone=True)
     Scores(15)=(Name="Kraagesh",Balance=3500,Matches=115,Wins=55,Difficulty=2.000000,bDrone=True)
     Scores(16)=(Name="Azure",Balance=3400,Matches=120,Wins=56,Difficulty=2.000000,bDrone=True)
     Scores(17)=(Name="Mr.Crow",Balance=3300,Matches=125,Wins=57,Difficulty=2.000000,bDrone=True)
     Scores(18)=(Name="Gaargod",Balance=3200,Matches=130,Wins=58,Difficulty=2.000000,bDrone=True)
     Scores(19)=(Name="Annika",Balance=3100,Matches=135,Wins=59,Difficulty=2.000000,bDrone=True)
     Scores(20)=(Name="Greith",Balance=3000,Matches=140,Wins=60,Difficulty=2.000000,bDrone=True)
     Scores(21)=(Name="Gkublok",Balance=2900,Matches=145,Wins=61,Difficulty=2.000000,bDrone=True)
     Scores(22)=(Name="Zarina",Balance=2800,Matches=150,Wins=62,Difficulty=2.000000,bDrone=True)
     Scores(23)=(Name="Gorge",Balance=2700,Matches=155,Wins=63,Difficulty=2.000000,bDrone=True)
     Scores(24)=(Name="Perdition",Balance=2600,Matches=160,Wins=64,Difficulty=2.000000,bDrone=True)
     MaxEntries=25
     CheaterName="*** CHEATER ***"
}
