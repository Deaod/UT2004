class GameProfile extends Object
	native;

var()	string	  PackageName;
var()	int		 ManifestIndex;


enum EPlayerPos			
{
	POS_Auto,
	POS_Defense,
	POS_Offense,
	POS_Roam,
	/*POS_Captain,  Not handy for dropdown display */
	POS_Supporting
};
const NUM_POSITIONS = 5;
var localized string PositionName[5];		// text names of these positions

var EPlayerPos PlayerPositions[7];			// only need positions for AI team, so 7 max
const TEAM_SIZE = 7;
var()	array<string> PlayerTeam;		   // Player team members
var		int			PlayerLineup[4];		// Lineup for current match.  Stores index into PlayerTeam array.
const LINEUP_SIZE = 4;
var		string		EnemyTeam;				// Opponent team name for pending/current match
var		string		TeamName;				// Player team name
var		string		TeamSymbolName;			// name of team symbol

var()	float		BaseDifficulty;		// configured at start of single player
var()	float	   Difficulty;

var		int			SalaryCap;			// allowable salary cap for team roster

// stored here, but also passed separately on URL
var		string		PlayerName;
var		string		PlayerCharacter;

// player's stats - individual experience
var()  int			Kills;
var()  int			Goals;
var()  int			Deaths;
var()  int			Wins;
var()  int			Matches;

// Ladders:  -1 = Locked
var int LadderRung[6];
const NUM_LADDERS = 6;

var string SpecialEvent;
var string GameLadderName;
var class<LadderInfo> GameLadder;

// current match
var int CurrentLadder;
var transient int CurrentMenuRung;		// set by menu system, used for starting a match, in LadderInfo.  if -1, use next match in order
var transient Object NextMatchObject;	// Used by GUI SP Pages for holding the Button for Next Match
var transient Object ChampBorderObject;	// Used by GUI SP Pages for holding the border for Championship.  
										// Sad hack, but easiest way to communicate GUI objects between Ladder and Qual tabs
var bool bInLadderGame;		// Used to see if we should return to the SP menu after the match has finished, 
													// also used to check if we should use the LoadingClass vignette
var bool bWonMatch;


// constructor:  set up the GameLadder
function Initialize(GameInfo currentGame, string pn)
{
	local Controller C;

	if (GameLadder == none) 
	{
		GameLadder = class<LadderInfo>(DynamicLoadObject(GameLadderName, class'Class'));
	}
	PackageName=pn;
	PlayerName=pn;

	// set character, player in current game
	for ( C=currentGame.Level.ControllerList; C!=None; C=C.NextController ) 
	{
		if ( PlayerController(C) != None ) 
		{
			currentGame.ChangeName (PlayerController(C), PlayerName, false);	
			break;		
		}
	}
	NextMatchObject=None;
	ChampBorderObject=None;
}

// skip this rung of the ladder without saving
function CheatSkipMatch(GameInfo CurrentGame)
{
	SpecialEvent = GameLadder.static.UpdateLadders(self,CurrentLadder); // updates LadderRungs appropriately
	ContinueSinglePlayerGame(CurrentGame.Level);
}

// skip directly to a certain ladder/rung
// takes a single number (54) and splits into ladder 5, match 4
function CheatJumpMatch(GameInfo currentGame, int param) {
	local Controller C;
	local int newladder, newrung;

	newladder = param/10;
	newrung = param-(newladder*10);
	if (newladder < 0 || newladder >= NUM_LADDERS || newrung < 0) 
		return;
	bInLadderGame=true;
	CurrentLadder = newladder;
	LadderRung[CurrentLadder] = newrung;
	CurrentMenuRung=newrung;

	// open game
	for ( C=currentGame.Level.ControllerList; C!=None; C=C.NextController ) 
	{
		if ( PlayerController(C) != None ) 
		{
			PlayerController(C).ConsoleCommand("START"@GameLadder.static.MakeURLFor(self));
			break;		
		}
	}
}

// robust checks are in LadderInfo, returns none if not found
function MatchInfo GetMatchInfo(int ladder, int rung) {
	if ( GameLadder != none ) 
	{
		return GameLadder.static.GetMatchInfo(ladder,rung);
	} 
	else 
	{
		return none;
	}
}

// After a game is completed, this function should be called to 
// record the player's statistics and update the ladder.
// Currently called from Deathmatch 'MatchOver' state
function RegisterGame(GameInfo currentGame, PlayerReplicationInfo PRI)
{
	Log("SINGLEPLAYER GameProfile::RegisterGame for profile"@self.packagename);
	Kills += PRI.Kills;
	Goals += PRI.GoalsScored;
	Deaths += PRI.Deaths;
	Matches++;
	if ( bWonMatch ) {
		//Log("SINGLEPLAYER GameProfile::RegisterGame player won the match.");	
		SpecialEvent = GameLadder.static.UpdateLadders(self,CurrentLadder); // updates LadderRungs appropriately
		Wins++;
	}
	bWonMatch = false;
}

// Send the player to the next match in the given ladder
function StartNewMatch(int PickedLadder, LevelInfo CurrentLevel)
{
	local Controller C;

	bWonMatch = false;
	bInLadderGame=true;
	CurrentLadder = PickedLadder;
	CurrentLevel.Game.SavePackage(PackageName);
	
	// open game
	for ( C=currentLevel.ControllerList; C!=None; C=C.NextController ) 
	{
		if ( PlayerController(C) != None ) 
		{
			PlayerController(C).ConsoleCommand("START"@GameLadder.static.MakeURLFor(self));
			break;		
		}
	}
}

// Handy helper function to find the player's first unfinished ladder
// If no ladders are unfinished, return 0 for DM ladder
function int FindFirstUnfinishedLadder() {
	local int i;
	
	for (i=0; i<6; i++) 
	{		
		// 6 is magic from number of ladders, declared above
		if (LadderRung[i] < GameLadder.static.LengthOfLadder(i)) {
			return i;		
		}
	}
	return 0;
}

// override in subclasses!
function ContinueSinglePlayerGame(LevelInfo level, optional bool bReplace)
{
	Level.Game.SavePackage(PackageName);

	// the direct call to startnewmatch is to avoid using a game-specific menu system
	StartNewMatch(FindFirstUnfinishedLadder(), level);
}

// Used in menus:  this is the gametype info for the next match
function string GetMatchDescription()
{
	return GameLadder.static.GetMatchDescription(self);
}

// accessor
function static int GetNumPositions()
{
	return NUM_POSITIONS;
}

// return number of teammates needed for currently selected match
// assumes player team always gets an odd player
function int GetNumTeammatesForMatch()
{
	local MatchInfo M;

	M = GameLadder.static.GetCurrentMatchInfo(self);

	if ( M.GameType ~= "xGame.xDeathmatch" || M.GameType ~= "xGame.BossDM" ) 
		return 0;
	else
		return M.NumBots / 2;
}


function static string TextPositionDescription(int posnval) 
{
	local string retval;

	if (posnval < 0 || posnval > NUM_POSITIONS)	// magic number based on team size of 7
		return "Error";

	switch (posnval) {
		case EPlayerPos.POS_Auto:
			retval = default.PositionName[0];
			break;
		case EPlayerPos.POS_Defense:
			retval = default.PositionName[1];
			break;
		case EPlayerPos.POS_Offense:
			retval = default.PositionName[2];
			break;
		case EPlayerPos.POS_Roam:
			retval = default.PositionName[3];
			break;
/*		case EPlayerPos.POS_Captain:
			retval = "CAPTAIN";
			break;*/
		case EPlayerPos.POS_Supporting:
			retval = default.PositionName[4];
			break;
	}

	return retval;
}

function static EPlayerPos EnumPositionDescription(string posnval) 
{	
	local EPlayerPos retval;

	if (posnval == default.PositionName[0]) {
		retval = EPlayerPos.POS_Auto;
	} else if (posnval == default.PositionName[1]) {
		retval = EPlayerPos.POS_Defense;
	} else if (posnval == default.PositionName[2]) {
		retval = EPlayerPos.POS_Offense;
	} else if (posnval == default.PositionName[3]) {
		retval = EPlayerPos.POS_Roam;
	} else if (posnval == default.PositionName[4]) {
		retval = EPlayerPos.POS_Supporting;
	} else 
		retval = EPlayerPos.POS_Auto;

	return retval;
}

function string GetPositionDescription(int playernum) 
{
	if (playernum < 0 || playernum >= TEAM_SIZE)	
		return "Error";
	return TextPositionDescription(PlayerPositions[playernum]);
}

// takes a lineup position (1-4) and sets that player's game position
function SetPosition (int lineupnum, string posn)
{
	if ((lineupnum >= 0) && (lineupnum < 4))
		PlayerPositions[PlayerLineup[lineupnum]] = EnumPositionDescription(posn);
}

// called when adjusting the lineup
// takes lineup position (1-4) and team position (1-7) and makes it all work
function SetLineup (int lineuppos, int teampos)
{
	local int oldlineuppos, oldteammate, i;

	// check bounds
	if ( lineuppos < 0 || lineuppos > LINEUP_SIZE ) 
		return;
	if ( teampos < 0 || teampos >= TEAM_SIZE )
		return;
	if ( PlayerLineup[lineuppos] == teampos )	// no-op
		return;

	// check to see if player 'teampos' was already in the lineup 
	oldlineuppos=-1;
	for ( i=0; i<LINEUP_SIZE; i++ )
	{
		if ( PlayerLineup[i] == teampos ) 
		{
			oldlineuppos = i;
			break;
		}
	}
	if ( oldlineuppos >= 0 ) {
		oldteammate = PlayerLineup[lineuppos];
	}
	PlayerLineup[lineuppos] = teampos;
	if ( oldlineuppos >= 0 ) {
		PlayerLineup[oldlineuppos] = oldteammate;
	}
}

// add teammate to the next available position on the team
// return false if not added because already on team or no room
// assumes it's a legal player record
function bool AddTeammate(string botname) 
{
	local int i;
	
	if ( botname == "" ) 
	{
		return false;
	}

	for ( i=0; i<TEAM_SIZE; i++ ) 
	{
		if ( i >= PlayerTeam.Length || PlayerTeam[i] == "" ) 
		{
			Playerteam[i] = botname;
			return true;
		}
		if ( PlayerTeam[i] ~= botname ) 
		{
			// already on team
			return false;
		}
	}

	return false;  // never found space
}

// remove teammate from the team
// return false if not removed because not on team 
function bool ReleaseTeammate(string botname) 
{
	local int i, j;
	
	if ( botname == "" ) 
	{
		return false;
	}

	for ( i=0; i<PlayerTeam.Length; i++ ) 
	{
		if ( PlayerTeam[i] ~= botname ) 
		{
			// player is on team, shuffle list 
			for ( j=i; j<PlayerTeam.Length-1; j++ ) 
			{
				PlayerTeam[j] = PlayerTeam[j+1];
			}
			PlayerTeam[PlayerTeam.Length-1] = "";
			return true;
		}
	}

	return false;  // never found botname
}

function ClearTeammates() 
{
	local int i;
	for ( i=0; i<PlayerTeam.Length; i++ ) 
	{
		PlayerTeam[i] = "";
	}
}

function ReportCheat(PlayerController Cheater, string cheat);

function bool CanChangeTeam(Controller Other, int NewTeam)
{
	return true;
}

defaultproperties
{
     PackageName="Default"
     PositionName(0)="AUTO-ASSIGN"
     PositionName(1)="DEFENSE"
     PositionName(2)="OFFENSE"
     PositionName(3)="ROAM"
     PositionName(4)="SUPPORT"
     PlayerLineup(1)=1
     PlayerLineup(2)=2
     PlayerLineup(3)=3
     BaseDifficulty=1.000000
     PlayerName="Name"
     PlayerCharacter="Roc"
     ladderrung(1)=-1
     ladderrung(2)=-1
     ladderrung(3)=-1
     ladderrung(4)=-1
     ladderrung(5)=-1
     GameLadderName="Engine.LadderInfo"
}
