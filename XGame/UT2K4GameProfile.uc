//==============================================================================
// Single Player Game Profile for storing the additional info
//
// Written by Michiel Hendriks
// (c) 2003, 2004, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4GameProfile extends UT2003GameProfile;

/** used to keep track of future changes */
var protected int revision;

var bool bDebug;

var class<UT2K4LadderInfo> UT2K4GameLadder;

/**	Progression in the ladders */
var array<int> LadderProgress;

/** The map that will be played, set by the "play" button */
var CacheManager.MapRecord ActiveMap;

/** seed to select the random level */
var int AltPath;

/** map selection record, this will override the default behavior of map selection for a match */
struct LevelPathRecord
{
	/** the selected ladder */
	var byte ladder;
	/** match in the selected ladder */
	var byte rung;
	/** the offset in the AltLevel array */
	var byte selection;
};
/** the selected path */
var array<LevelPathRecord> LevelRoute;

/**
	The actual team size
	Warning, absolute max size is 7 (set by GameProfile)
	Don't use this variable, call GetMaxTeamSize() instead
*/
var protected int MaxTeamSize;

/**
	Statistics for each bot in this profile.
	Saved per profile because they change during the tournament
*/
struct BotStatsRecord
{
	var string Name;
	/** updated price to 'buy' the player, this is also used to calculate the fee and injury treatment */
	var int Price;
	/** injury stats, 0 = dead (you don't want that ;)) */
	var byte Health;
	/** is this a free agent, e.g. can you hire him/her */
	var bool FreeAgent;
	/** location of his team in the TeamStats list */
	var int TeamId;
};
var array<BotStatsRecord> BotStats;

/**	Stats for each team */
struct TeamStatsRecord
{
	/** the fully qualified name of the team class */
	var string Name;
	/** the difficulty level of this team */
	var int Level;
	/** number of games played against this team */
	var int Matches;
	/** number of games this team won from you */
	var int Won;
	/** the rating of this team compared to you */
	var float Rating;
};
var array<TeamStatsRecord> TeamStats;

/** The current Player Balance */
var int Balance;
/** the minimal balance */
var int MinBalance;

/** total ingame time */
var float TotalTime;

/** Set to 'true' when the SP has been completed */
var bool bCompleted;
/** the best team played against, used for championship */
var string FinalEnemyTeam;

/** Player used a cheat */
var protected bool bCheater;
/** if set to true users can't unlock characters with this profile */
var protected bool bLocked;
/** prevent some cheating */
var protected string PlayerIDHash;

/**
	Team percentage modifier
	This value is multiplied with the fee for each player, lower value = lower take of the earnings
*/
var float TeamPercentage;
/** Percentage of the Match price that counts as bonus (per player) **/
var float MatchBonus;
/** The percentage of the team players fee to pay out when the team loses */
var float LoserFee;
/** Every time a bot played a match and won his fee increases with this */
var float FeeIncrease;

/** The chance a team player get's injured */
var float InjuryChance;
/** the offset in the BotStats array of the last injured player */
var int LastInjured;
/** injury treatment modifier */
var float InjuryTreatment;

/** Chance the losing enemy team will challenge you for a rematch */
var float ChallengeChance;

// Last match details --
/** if set to true the details are new and the detail window should be displayed */
var bool lmdFreshInfo;
/** player details from the last match */
struct PlayerMatchDetailsRecord
{
	var int ID;
	var string Name;
	var float Kills;
	var float Score;
	var float Deaths;
	var int Team;
	/** special awards won by this player, like Flag Monkey */
	var array<string> SpecialAwards;
};
/** per player details */
var array<PlayerMatchDetailsRecord> PlayerMatchDetails;
/** total change in the balance, includes payment and bonuses */
var int lmdBalanceChange;
/** true if the player won the match */
var bool lmdWonMatch;
/** enemy team class */
var string lmdEnemyTeam;
/** game type string */
var string lmdGameType;
/** true if the last match was a challenge match */
var bool lmdbChallengeGame;
/** map title */
var string lmdMap;
/** total prizemoney */
var int lmdPrizeMoney;
/** total bonus money */
var int lmdTotalBonusMoney;
/** last spree count */
var int lmdSpree[6];
/** last multikill count */
var int lmdMultiKills[7];
/** player ID of injured player */
var int lmdInjury;
/** health, stored here because player could have been healed */
var byte lmdInjuryHealth;
/** injury treatment gost */
var int lmdInjuryTreatment;
/** total match time */
var float lmdGameTime;
/** true if it was a team game */
var bool lmdTeamGame;
/** teamID of the player's team (usualy 1) */
var int lmdMyTeam;
struct PayCheckRecord
{
	var int BotId;
	var int Payment;
};
/** payment overview of you team mates */
var array<PayCheckRecord> PayCheck;

struct PhantomMatchRecord
{
	var int Team1; // team id in the team stats array
	var int Team2;
	var float ScoreTeam1;
	var float ScoreTeam2;
	var int LadderId;
	var int MatchId;
	var float GameTime;
};
/** phantom match overview */
var array<PhantomMatchRecord> PhantomMatches;
// -- Last match details

struct TeamMateRankingRecord
{
	var int BotID;
	var float Rank;
};
/** Used for payment and injuries, only valid during RegisterGame() */
var array<TeamMateRankingRecord> TeamMateRanking;

/** Phantom Teams to choose from */
var array<string> PhantomTeams;

/** when true use ChallengeInfo for information */
var bool bIsChallenge;
/** the challenge match info, obsolete? */
var UT2K4MatchInfo ChallengeInfo;
/** will be set to the challenge game class used if bIsChallenge = true*/
var class<ChallengeGame> ChallengeGameClass;
/** true we we got challenged, false if we took the initiative */
var bool bGotChallenged;
/** contains data about the challenge variables, used for fighthistory */
var string ChallengeVariable;

/** When set override the default LoginMenuClass with this one */
var string LoginMenuClass;

/** @ignore */
var name LogPrefix;

// more all time stats --
var int Spree[6];
var int MultiKills[7];
var int SpecialAwards[6];
// -- more all time stats

/** bonus received for each killing spree */
var int SpreeBonus[6];
/** bonus received for each multikill */
var int MultiKillBonus[7];

/** Special Awards labels */
var localized string msgSpecialAward[6];
/** special award levels */
var int sae_flackmonkey, sae_combowhore, sae_headhunter, sae_roadrampage, sae_hattrick, sae_untouchable;

var localized string msgCheater, msgCredits, msgCredit;

/** The fee you have to pay when you forfeit the game */
var protected float ForFeitFee;

/** percentage of the match prize a map challenge costs */
var float MapChallengeCost;

struct FightHistoryRecord
{
	/** yyyy-mm-dd */
	var int Date[3];
	/** hh:mm */
	var int Time[2];
	/** magic string, fields seperated by ';'				<br />
		field 1: match type (Ladder game, challenge game, custom ladder game) <br />
		field 2: match description
	*/
	var string MatchData;
	/** additional data, depends on the MatchData type */
	var string MatchExtra;
	/** map name */
	var string Level;
	/** gametype class, fully qualified */
	var string GameType;
	/** enemy team class, fully qualified */
	var string EnemyTeam;
	/** price money */
	var float PriceMoney;
	/** balance change */
	var float BalanceChange;
	/** bonus money won */
	var float BonusMoney;
	/** game time */
	var float GameTime;
	var bool WonGame;
	/** team scores, 1 = our team, 0 = enemy team */
	var float TeamScore[2];
	/** gee, what would this be then */
	var bool TeamGame;
	/** team layout */
	var string TeamLayout[2];

	/** player's score in this game */
	var float MyScore;
	/** number of kills */
	var int MyKills;
	/** number of deaths */
	var int MyDeaths;
	/** my awards */
	var string MyAwards;
	/** final position in the scoring table */
	var byte MyRating;
};
/** the history of all fights */
var array<FightHistoryRecord> FightHistory;

/** localized strings used for the fighthistory */
var localized string msgChallengeGame, msgAdditionalLadder,	msgMatch, msgLadderGame, msgChampionship;

/** team roster override record */
struct TeamRosterRecord
{
	/** fully qualified name of the team roster class */
	var string name;
	/** the alternative roster */
	var array<string> roster;
};
/** team roster override records */
var array<TeamRosterRecord> AltTeamRoster;

/** information about a custom ladder */
struct CustomLadderRecord
{
	/** the fully qualified name to the ladder class */
	var string LadderClass;
	/** current progress */
	var int progress;
};
/** custom ladders */
var array<CustomLadderRecord> CustomLadders;
/** will be set when a custom ladder has been played, and unset when not */
var class<CustomLadderInfo> LastCustomCladder;

/** if true match details will be shown after a match */
var bool bShowDetails;

/** call this when you create a new profile, this will set the protection data */
function CreateProfile(PlayerController PlayerOwner)
{
	if (PlayerIDHash == "") PlayerIDHash = PlayerOwner.GetPlayerIDHash();
}

/**
	call this when you load the profile, it will lock the profile
	when the PlayerIDHash has changed
*/
function LoadProfile(PlayerController PlayerOwner)
{
	if (PlayerIDHash != PlayerOwner.GetPlayerIDHash())
	{
		bLocked = true;
		PlayerIDHash = PlayerOwner.GetPlayerIDHash();
	}
}

/** initialize the profile, called at the beginning of each game */
function Initialize(GameInfo currentGame, string pn)
{
	local Controller C;

	if (UT2K4GameLadder == none)
	{
		UT2K4GameLadder = class<UT2K4LadderInfo>(DynamicLoadObject(GameLadderName, class'Class'));
		GameLadder = UT2K4GameLadder;
	}
	PackageName=pn;
	UpgradeGP();

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

	Playerteam.length = GetMaxTeamSize(); // make sure it's never larger than this

	if ((DeathMatch(currentGame) != none) && (LoginMenuClass != ""))
	{
		DeathMatch(currentGame).LoginMenuClass = LoginMenuClass;
	}

	//if (Balance < MinBalance) Balance = MinBalance;
}

/** Called on gamerestart */
function ContinueSinglePlayerGame(LevelInfo level, optional bool bReplace)
{
	local Controller C;
	local PlayerController PC;

	// set character, player in current game
	PC = none;
	for ( C=level.ControllerList; C!=None; C=C.NextController )
	{
		if ( PlayerController(C) != None ) {
			PC = PlayerController(C);
			break;
		}
	}
	if ( PC == none ) {
		return;
	}

	//if (Balance < MinBalance) Balance = MinBalance;

	if (!level.game.SavePackage(PackageName))
	{
		Warn("level.game.SavePackage("@PackageName@") FAILED.");
	}
	bIsChallenge = false;
	PC.ConsoleCommand("disconnect");
}

function CheatSkipMatch(GameInfo CurrentGame)
{
	local UT2K4MatchInfo MI;

	MI = UT2K4MatchInfo(GetMatchInfo(CurrentLadder, CurrentMenuRung));
	Balance = Balance + ForfeitFee + MI.PrizeMoney;;
	Super.CheatSkipMatch(CurrentGame);
}

/**
	After a game is completed, this function should be called to
	record the player's statistics and update the ladder.
	Currently called from Deathmatch 'MatchOver' state
*/
function RegisterGame(GameInfo currentGame, PlayerReplicationInfo PRI)
{
	local UT2K4MatchInfo MI;
	local int i, j, OldBalance;
	local float TeamRating;
	local array<PlayerReplicationInfo> PRIarray;
	local bool TempbIsChallenge, doPayTeamMates;
	local string tmp;

	MI = UT2K4MatchInfo(GetMatchInfo(CurrentLadder, CurrentMenuRung));
	Balance += ForFeitFee; // payback forfeitfee
	OldBalance = Balance;
	PayCheck.length = 0;
	SpecialEvent = "";

	TempbIsChallenge = bIsChallenge;
	if (bIsChallenge && ChallengeGameClass != none) ChallengeGameClass.static.PreRegisterGame(self, currentGame, PRI);

	Kills += PRI.Kills;
	Goals += PRI.GoalsScored;
	Deaths += PRI.Deaths;
	Matches++;
	TotalTime += currentGame.Level.TimeSeconds-currentGame.StartTime;

	lmdTotalBonusMoney = 0;
	LastInjured = -1;
	PayCheck.length = 0;
	PlayerMatchDetails.length = 0;
	if (TeamPlayerReplicationInfo(PRI) != none)
	{
		for (i = 0; i < 6; i++)
		{
			Spree[i] += TeamPlayerReplicationInfo(PRI).Spree[i];
			lmdSpree[i] = TeamPlayerReplicationInfo(PRI).Spree[i];
			lmdTotalBonusMoney += TeamPlayerReplicationInfo(PRI).Spree[i]*SpreeBonus[i];
		}
		for (i = 0; i < 7; i++)
		{
			MultiKills[i] += TeamPlayerReplicationInfo(PRI).MultiKills[i];
			lmdMultiKills[i] = TeamPlayerReplicationInfo(PRI).MultiKills[i];
			lmdTotalBonusMoney += TeamPlayerReplicationInfo(PRI).MultiKills[i]*MultiKillBonus[i];
		}
	}
	Balance += lmdTotalBonusMoney;

	if (CurrentLadder != UT2K4GameLadder.default.LID_DM)
	{
		i = GetTeamPosition(EnemyTeam, true);
		TeamStats[i].Matches++;
		if (!bWonMatch) TeamStats[i].Won++;
		TeamRating = 0;
		if (currentGame.bTeamGame)
		{
			// Rating is: team score / other team score * (team won match)
			// Rating will increase faster than it will decrease
			TeamRating = (TeamGame(currentGame).Teams[(PRI.Team.TeamIndex+1) % 2].Score+1.0)/(TeamGame(currentGame).Teams[PRI.Team.TeamIndex].Score+1.0);
			RankTeamMates(currentGame, PRI);
			if (TempbIsChallenge && ChallengeGameClass != none) doPayTeamMates = ChallengeGameClass.static.injureTeamMate(self);
			else doPayTeamMates = true;
			if (doPayTeamMates) InjureTeamMate();
		}
		else {
			// won from the whole team
			currentGame.GameReplicationInfo.GetPRIArray(PRIarray);
			for (j = 0; j < PRIarray.length; j++)
			{
				if ((PRIarray[j] != PRI) && (TeamRating < PRIarray[j].Score))
				{
					TeamRating = PRIarray[j].Score;
				}
			}
			TeamRating /= (PRI.Score+1.0);
		}
		if (bDebug) log("TeamRating ="@TeamRating, LogPrefix);
		if (bWonMatch) TeamRating *= -1; // enemy lost to rating is negative
		TeamStats[i].Rating += TeamRating;
	}
 	if (currentGame.bTeamGame && !bIsChallenge /*&& (completedLadder(class'UT2K4LadderInfo'.default.LID_TDM))*/)
	{
		/*
		rating
		-3/4		-- increase chance
		-2/4	    -- decrease chance
		-1/4       	-- increase chance
		4/3  ->3/4	-- increase chance
		4/2  ->3/2	-- decrease chance
		4/1  ->1/4	-- decrease chance
		*/
		if (TeamRating > 0) TeamRating = 0.5/TeamRating;
		else if (TeamRating > -0.5) TeamRating = -1-TeamRating;
		TeamRating = 0.5+abs(TeamRating);
		if (bDebug) Log("Challenge chance ="@TeamRating@(ChallengeChance*TeamRating));
		if ((frand() < ChallengeChance*TeamRating ))
		{
			// challene enemyteam game
			tmp = string(GetChallengeGame());
			if (tmp != "") SpecialEvent = "CHALLENGE"@EnemyTeam@tmp$";"$SpecialEvent; // make first because of possible message window
		}
	}
	if (TempbIsChallenge && ChallengeGameClass != none) doPayTeamMates = ChallengeGameClass.static.payTeamMates(self);
	else doPayTeamMates = true;
	if ( bWonMatch )
	{
		SpecialEvent $= ";"$GameLadder.static.UpdateLadders(self,CurrentLadder); // updates LadderRungs appropriately
		Wins++;
		// calculate new balance
		Balance += MI.PrizeMoney;
		if (currentGame.bTeamGame && doPayTeamMates) PayTeamMates(MI.PrizeMoney, TeamPercentage, (TeamMateRanking.length/2), FeeIncrease); // increase fee of 50% of the best players
	}
	else {
		// team mates take an percentage of the current balance
		if (currentGame.bTeamGame && doPayTeamMates) PayTeamMates(Balance, LoserFee, (TeamMateRanking.length/3), (FeeIncrease/2));
	}

	// Stats --
	lmdBalanceChange = Balance-OldBalance;
	procLastMatchDetails(currentGame, PRI, MI);
	AddHistoryRecord(currentGame, PRI, MI); // bIsChallenge must not been reset
	// only create phantom matches when we entered the tournament
	bIsChallenge = false; // to get proper match info
	if (completedLadder(UT2K4GameLadder.default.LID_DM)) procPhantomMatches(ceil(float(TeamStats.length-1)/2.0 * frand()));
	// -- Stats

	if (TempbIsChallenge && ChallengeGameClass != none) ChallengeGameClass.static.PostRegisterGame(self, currentGame, PRI);

	if (Balance < MinBalance)
	{
		Balance = MinBalance;
		SpecialEvent $= ";DONATION";
	}
	bWonMatch = false;
}

/** Send the player to the next match in the given ladder */
function StartNewMatch(int PickedLadder, LevelInfo CurrentLevel)
{
	local Controller C;
	local string NewURL;
	local int i;
	local bool doCancelFee;

	lmdFreshInfo= false;
	bWonMatch = false;
	bInLadderGame = true;
	CurrentLadder = PickedLadder;
	if (PickedLadder >= 10) LastCustomCladder = UT2K4GameLadder.default.AdditionalLadders[PickedLadder - 10];
	else LastCustomCladder = none;
	if (!bIsChallenge) ChallengeGameClass = none;
	NewURL = GameLadder.static.MakeURLFor(self);
	EnemyTeam = GetEnemyTeamName(EnemyTeam); // find enemy team, if needed
	if (bDebug) Log("Selected EnemyTeam ="@EnemyTeam, LogPrefix);
	if (!bIsChallenge) SpecialEvent = ""; // challenge class will/should do this

	doCancelFee = true;
	if (bIsChallenge && (ChallengeGameClass != none)) doCancelFee = ChallengeGameClass.static.payTeamMates(self);

	// calculate lamer forfeitfee
	TeamMateRanking.length = 0;
	if (doCancelFee)
	{
		for (i = 0; i < GetNumTeammatesForMatch(); i++)
		{
			TeamMateRanking.length = TeamMateRanking.length+1;
			TeamMateRanking[TeamMateRanking.length-1].BotID = GetBotPosition(PlayerTeam[PlayerLineup[i]]);
		}
		ForFeitFee = PayTeamMates(Balance, LoserFee);
		if (bDebug) log("ForFeitFee ="@ForFeitFee);
	}
	else ForFeitFee = 0;

	CurrentLevel.Game.SavePackage(PackageName);

	// open game
	for ( C=currentLevel.ControllerList; C!=None; C=C.NextController )
	{
		if ( PlayerController(C) != None )
		{
			PlayerController(C).ConsoleCommand("START"@NewURL);
			return;
		}
	}
	Warn("No local player controller found");
}

/** Will be called in case of a cheat */
function ReportCheat(PlayerController Cheater, string cheat)
{
	local string s;
	s = msgCheater;
	if (Cheater != none)
	{
		Cheater.ClearProgressMessages();
		Cheater.SetProgressTime(6);
		Cheater.SetProgressMessage(0, s, class'Canvas'.Static.MakeColor(255,0,0));
	}
	if (cheat != "") s @= "Player used cheat:"@cheat;
	Log(s, LogPrefix);
	bCheater = true;
}

/** return true of the Cheat flag has been set */
function bool IsCheater()
{
	return bCheater;
}

/** never allow team change unless we're god */
function bool CanChangeTeam(Controller Other, int NewTeam)
{
	if (Other.bGodMode) return true;
	return ( !Other.Level.Game.GameReplicationInfo.bMatchHasBegun && (Other.PlayerReplicationInfo != None) && (Other.PlayerReplicationInfo.Team == None) );
}

/** Overwritten to get alt matches */
function MatchInfo GetMatchInfo(int ladder, int rung)
{
	local int i;
	if ( bIsChallenge ) return ChallengeInfo;
	if ( UT2K4GameLadder != none )
	{
		i = GetSelectedLevel(ladder, rung);
		if (i > -1)	return UT2K4GameLadder.static.GetUT2K4MatchInfo(ladder, rung, i, true);
			else return UT2K4GameLadder.static.GetUT2K4MatchInfo(ladder, rung, AltPath);
	}
	else
	{
		Warn("UT2K4GameLadder == none");
		return none;
	}
}

/** return a selected UT2K4MatchInfo record */
function UT2K4MatchInfo GetSelectedMatchInfo(int ladder, int rung, int selection, optional bool bOrig)
{
	if ( UT2K4GameLadder != none )
	{
		if (bOrig) return UT2K4GameLadder.static.GetUT2K4MatchInfo(ladder, rung, AltPath);
			else return UT2K4GameLadder.static.GetUT2K4MatchInfo(ladder, rung, selection, true);
	}
	Warn("UT2K4GameLadder == none");
	return none;
}

/** check if there is an alternative level */
function bool HasAltLevel(int ladder, int rung)
{
	if ( UT2K4GameLadder != none ) return UT2K4GameLadder.static.HasAltLevel(ladder, rung);
	Warn("UT2K4GameLadder == none");
	return false;
}

/** get the alternative match ID */
function byte GetAltLevel(int ladder, int rung)
{
	if ( UT2K4GameLadder != none ) return UT2K4GameLadder.static.GetAltLevel(ladder, rung, AltPath, GetSelectedLevel(ladder, rung));
	Warn("UT2K4GameLadder == none");
	return -1;
}

/** Get the friendly game type name */
function string GetMatchDescription()
{
	local int i;
	local array<CacheManager.GameRecord> gr;

	if ( bIsChallenge )
	{
		class'CacheManager'.static.GetGameTypeList(gr);
		for (i = 0; i < gr.length; i++)
		{
			if (gr[i].classname ~= ChallengeInfo.GameType) return gr[i].GameName;
		}
		return "";
	}
	return GameLadder.static.GetMatchDescription(self);
}

/**
	return number of teammates needed for currently selected match
	assumes player team always gets an odd player
*/
function int GetNumTeammatesForMatch()
{
	local MatchInfo M;

	if ( bIsChallenge ) M = ChallengeInfo;
		else M = GameLadder.static.GetCurrentMatchInfo(self);
	return GetNumTeammatesForMatchInfo(m);
}

/**
	return number of teammates needed for the provided
	assumes player team always gets an odd player
*/
function int GetNumTeammatesForMatchInfo(MatchInfo M)
{
	if ( !IsTeamGametype(M.GameType) )
		return 0;
	else
		return M.NumBots / 2;
}

/** return true if it's a team game type */
function bool IsTeamGametype(string gametype)
{
	local CacheManager.GameRecord GR;
	if (gametype == "") return false;
	GR = class'CacheManager'.static.GetGameRecord(gametype);
	return GR.bTeamGame;
}

/** return the length of a selected ladder */
function int LengthOfLadder(int LadderId)
{
	if (GameLadder != none)
	{
		return GameLadder.static.LengthOfLadder(LadderId);
	}
	else {
		Warn("PC Load Letter");
		return -1;
	}
}

/** return the maximum size of a team that you manage */
function int GetMaxTeamSize()
{
	return MaxTeamSize;
}

/**
	Enable a ladder, this makes sure a ladder is not reset
	Special case, ladderid=-1 this will set all ladders except the championship
*/
function enableLadder(int ladderId)
{
	if (ladderId > LadderProgress.length) return;
	if (ladderId == -1)
	{
		enableLadder(UT2K4GameLadder.default.LID_DM); // DM
		enableLadder(UT2K4GameLadder.default.LID_TDM); // TDM
		enableLadder(UT2K4GameLadder.default.LID_CTF); // CTF
		enableLadder(UT2K4GameLadder.default.LID_BR); // BR
		enableLadder(UT2K4GameLadder.default.LID_DOM); // DDOM
		enableLadder(UT2K4GameLadder.default.LID_AS); // AS
	}
	else {
		if (LadderProgress[ladderId] == -1) LadderProgress[ladderId] = 0;
	}
}

/** get the progres of a custom ladder */
function int GetCustomLadderProgress(string LadderName)
{
	local int i;
	i = GetCustomLadder(LadderName);
	if (i == -1) return -1;
	return CustomLadders[i].progress;
}

/** set the progress of a custom ladder */
function SetCustomLadderProgress(string LadderName, int increase)
{
	local int i;
	i = GetCustomLadder(LadderName);
	if (i == -1) return;
	CustomLadders[i].progress += increase;
}

/** add a new custom ladder */
function RegisterCustomLadder(string LadderName)
{
	if (GetCustomLadder(LadderName) > -1) return;
	CustomLadders.length = CustomLadders.length+1;
	CustomLadders[CustomLadders.length-1].LadderClass = LadderName;
	CustomLadders[CustomLadders.length-1].progress = 0;
}

/** return the id of a custom ladder */
function int GetCustomLadder(string LadderName)
{
	local int i;
	for (i = 0; i < CustomLadders.length; i++)
	{
		if (CustomLadders[i].LadderClass ~= LadderName) return i;
	}
	return -1;
}


/**
	add teammate to the next available position on the team
	return false if not added because already on team or no room
	assumes it's a legal player record
*/
function bool AddTeammate(string botname)
{
	local int i;

	if ( botname == "" ) return false;
	for ( i=0; i < GetMaxTeamSize(); i++ )
	{
		if ( i >= PlayerTeam.Length || PlayerTeam[i] == "" )
		{
			Playerteam[i] = botname;
			i = GetBotPosition(botname, true);
			BotStats[i].FreeAgent = false;
			BotStats[i].TeamId = -1;
			if (bDebug) log("Added team mate:"@botname, LogPrefix);
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

/**
	remove teammate from the team
  return false if not removed because not on team
*/
function bool ReleaseTeammate(string botname)
{
	local int i, j;
	if ( botname == "" ) return false;

	for ( i=0; i < GetMaxTeamSize(); i++ )
	{
		if ( PlayerTeam[i] ~= botname )
		{
			// player is on team, shuffle list
			for ( j=i; j<PlayerTeam.Length-1; j++ )
			{
				PlayerTeam[j] = PlayerTeam[j+1];
			}
			PlayerTeam[PlayerTeam.Length-1] = "";
			j = GetBotPosition(botname, true);
			BotStats[j].FreeAgent = true;
			BotStats[j].TeamId = -1;
			if (bDebug) log("Released team mate:"@botname, LogPrefix);
			return true;
		}
	}
	return false;  // never found botname
}

/**	Return true if the bot is a teammate */
function bool IsTeammate(string botname)
{
	local int i;
	for ( i=0; i < GetMaxTeamSize(); i++ )
	{
		if ( PlayerTeam[i] ~= botname ) return true;
	}
	return false;
}

/**	returns the friendly name of the gametype selected */
function string GetLadderDescription(int LadderId, optional int MatchId)
{
	return UT2K4GameLadder.static.GetLadderDescription(LadderId, MatchId);
}

/** return true when the ladder has been completed */
function bool completedLadder(int LadderId)
{
	return LadderProgress[ladderId] >= LengthOfLadder(LadderId);
}

/** return true when the ChampionshipLadder is within reach*/
function bool openChampionshipLadder()
{
	return completedLadder(UT2K4GameLadder.default.LID_DOM) && completedLadder(UT2K4GameLadder.default.LID_CTF) &&
					completedLadder(UT2K4GameLadder.default.LID_AS) && completedLadder(UT2K4GameLadder.default.LID_BR);
}

/** Rank team mates based on how they did in the last match */
function RankTeamMates(GameInfo Game, PlayerReplicationInfo Me)
{
	local array<PlayerReplicationInfo> PRI;
	local int i, j;
	local float Rank;
	local TeamMateRankingRecord temp;

	TeamMateRanking.length = 0;
	Game.GameReplicationInfo.GetPRIArray(PRI);
	// create index
	for (i = 0; i < PRI.length; i++)
	{
		if ((PRI[i].Team == Me.Team) && (PRI[i] != Me))
		{
			Rank = (PRI[i].Kills+1)/(PRI[i].Deaths+1);
			TeamMateRanking.length = TeamMateRanking.length+1;
			TeamMateRanking[TeamMateRanking.length-1].BotID = GetBotPosition(PRI[i].PlayerName, true);
			TeamMateRanking[TeamMateRanking.length-1].Rank = Rank;
		}
	}
	// sort, since it's a small array, just use selection sort
	for (i = 0; i < TeamMateRanking.length; i++)
	{
		for (j = i+1; j < TeamMateRanking.length; j++)
		{
			if (TeamMateRanking[i].Rank < TeamMateRanking[j].Rank) // swap
			{
				temp = TeamMateRanking[i];
				TeamMateRanking[i] = TeamMateRanking[j];
				TeamMateRanking[j] = temp;
			}
		}
	}
	if (bDebug)
	{
		log("Rand team mates", LogPrefix);
		for (i = 0; i < TeamMateRanking.length; i++)
		{
			log(i$"]"@BotStats[TeamMateRanking[i].BotID].Name@TeamMateRanking[i].Rank);
		}
	}
}

/**
	Pay out the participating team mates and increase their fee
	A percentage of the match earnings is added/removed from their fee
	IncreaseFeeOf = number of team mates to pay
	updateFee = percentage to increase the fee
	Return the total payment
*/
function float PayTeamMates(int Money, float FeeModifier, optional int IncreaseFeeOf, optional float updateFee)
{
	local int i, botid;
	local float fee, totalFee;
	totalFee = 0;
	PayCheck.length = TeamMateRanking.Length;
	for (i = 0; i < TeamMateRanking.Length; i++)
	{
		botid = TeamMateRanking[i].BotID;
		fee = GetBotPrice(, botid) * FeeModifier;
		// Bonus: MatchPrize * MaxMatchBonus * Rank
		fee += Money * MatchBonus * ((TeamMateRanking.Length - i) / TeamMateRanking.Length);
		PayCheck[i].BotId = BotId;
		PayCheck[i].Payment = Fee;
		if (bDebug) log("Paycheck: "$i$"]"@BotStats[PayCheck[i].BotID].Name@PayCheck[i].Payment);
		balance -= Fee;
		totalFee += Fee;
		//Log("UT2K4GameProfile::PayTeamMates() - "@PlayerTeam[PlayerLineup[i]]@"earns"@fee, LogPrefix);
	}
	// increase payment of IncreaseFeeOf best team mates
	IncreaseFeeOf = TeamMateRanking.length-Min(IncreaseFeeOf, TeamMateRanking.length);
	for (i = TeamMateRanking.length-1; i >= IncreaseFeeOf; i--)
	{
		GetBotPrice(, TeamMateRanking[i].BotId, updateFee);
		if (bDebug) log("Increase fee: "$i$"]"@BotStats[TeamMateRanking[i].BotID].Name@updateFee);
	}
	return totalFee;
}

/**
	Find the price of this player
	If increase > 1 increase the fee with that amouth
	if 1 > increase > 0 multiply the fee with that amouth
	if increase == 0 do nothing
*/
function int GetBotPrice(optional string botname, optional int botid, optional float increase, optional bool bAdd)
{
	if (botname != "") botid = GetBotPosition(botname, bAdd);
	if ((botid == -1) || (botid > BotStats.length)) return -1;
	if (increase > 1) BotStats[botid].Price += increase;
	else if (increase > 0) BotStats[botid].Price *= (1+increase);
	return BotStats[botid].Price;
}

/** return the position of the bot in the botstats array */
function int GetBotPosition(string botname, optional bool bAdd)
{
	local int i;
	for (i = 0; i < BotStats.length; i++)
	{
		if (BotStats[i].Name ~= botname) return i;
	}
	if (bAdd)
	{
		//log("UT2K4GameProfile::GetBotPosition() - adding bot:"@botname, LogPrefix);
		BotStats.length = i+1;
		BotStats[i].Name = botname;
		BotStats[i].Price = class'xUtil'.static.GetSalaryFor(class'xUtil'.static.FindPlayerRecord(botname));
		BotStats[i].Health = 100;
		BotStats[i].FreeAgent = true;
		BotStats[i].TeamId = -1;
		return i;
	}
	return -1;
}

/**
	Find the worst team mate(s) and injure it
	Only one injury is supported
*/
function InjureTeamMate(optional int Number)
{
	local int i;
	if (Number <= 0) Number = 1;
	Number = TeamMateRanking.length-Min(Number, TeamMateRanking.length);

	for (i = TeamMateRanking.length-1; i >= Number; i--)
	{
		if (FRand() > InjuryChance) continue;
		// injury at least 5%
		// injury not more than 75%
		// player did bad = rank is low (kills/deaths)
		BotStats[TeamMateRanking[i].BotID].Health = min(TeamMateRanking[i].Rank*25, 60)+25+(10*frand());
		LastInjured = TeamMateRanking[i].BotID;
		if (bDebug) log("InjureTeamMate ="@BotStats[TeamMateRanking[i].BotID].Name@"got injured, health"@BotStats[TeamMateRanking[i].BotID].Health$"%", LogPrefix);
	}
}

/**
	Returns true when the player has a full team
*/
function bool HasFullTeam()
{
	local int i;
	for (i = 0; i < GetMaxTeamSize(); i++)
	{
		if (PlayerTeam[i] == "") return false;
	}
	return true;
}

/**
	Return the team name based on a magic string
	A magic string starts with a ';', if not asume it's a real team name
*/
function string GetEnemyTeamName(string MagicString)
{
	local array<string> parts, teams;
	local class<UT2K4RosterGroup> RGclass;
	local float X, mod;
	local int i, j;

	if (Left(MagicString, 1) != ";") return MagicString;
	if (Split(MagicString, ";", parts) < 3)
	{
		Warn("invalid magic string:"@MagicString);
		return "";
	}
	RGclass = class<UT2K4RosterGroup>(DynamicLoadObject(parts[1], class'Class'));
	if (RGclass == none)
	{
		Warn("Invalid team roster class:"@parts[1]);
		return "";
	}
	teams.length = 0;

	// final is the best team but set statically for each profile at the end
	if ((parts[2] ~= "final") && (FinalEnemyTeam != ""))
	{
		return FinalEnemyTeam;
	}
	if ((parts[2] ~= "least") || (parts[2] ~= "most")) // least/most played with this team
	{
		if (parts[2] ~= "most") mod = -1; else mod = 1;
		X = mod*MaxInt;
		for (i = 0; i < RGclass.default.Rosters.length; i++)
		{
			j = GetTeamPosition(RGclass.default.Rosters[i], true);
			if ((TeamStats[j].Matches*mod) == X) // same, so add
			{
				teams[teams.length] = RGclass.default.Rosters[i];
			}
			else if ((TeamStats[j].Matches*mod) < X) // reset list
			{
				X = TeamStats[j].Matches*mod;
				teams.length = 1;
				teams[0] = RGclass.default.Rosters[i];
			}
		}
	}
	else if ((parts[2] ~= "best") || (parts[2] ~= "worst") || (parts[2] ~= "final")) // best/worst team you played against
	{
		if (parts[2] ~= "worst") mod = -1; else mod = 1;
		X = mod*MaxInt*-1;
		for (i = 0; i < RGclass.default.Rosters.length; i++)
		{
			j = GetTeamPosition(RGclass.default.Rosters[i], true);
			if ((TeamStats[j].Rating*mod) == X) // same, so add
			{
				teams[teams.length] = RGclass.default.Rosters[i];
			}
			else if ((TeamStats[j].Rating*mod) > X) // reset list
			{
				X = TeamStats[j].Rating*mod;
				teams.length = 1;
				teams[0] = RGclass.default.Rosters[i];
			}
		}
	}
	else if (parts[2] ~= "random")
	{
		teams = RGclass.default.Rosters;
	}
	else {
		Warn("unsupported magic string:"@parts[2]);
	}
	if (teams.length == 0)
	{
		X = rand(RGclass.default.Rosters.length);
		Warn("empty team list, will use:"@RGclass.default.Rosters[X]);
		return RGclass.default.Rosters[X];
	}
	if (parts[2] ~= "final") // set final team
	{
		FinalEnemyTeam = teams[rand(teams.length)];
		return FinalEnemyTeam;
	}
	return teams[rand(teams.length)]; // return a random team
}

/** Find the position of this team in the list */
function int GetTeamPosition(string teamname, optional bool bAdd)
{
	local int j, i, k;
	local class<UT2K4TeamRoster> tr;

	for (j = 0; j < TeamStats.length; j++)
	{
		if (TeamStats[j].Name ~= teamname) return j;
	}
	if (bAdd) // team not found, add it
	{
		//log("UT2K4GameProfile::GetTeamPosition() - adding team:"@teamname, LogPrefix);
		TeamStats.length = j+1;
		TeamStats[j].Name = teamname;
		TeamStats[j].Matches = 0;
		TeamStats[j].Won = 0;
		// Add ream bots
		tr = class<UT2K4TeamRoster>(DynamicLoadObject(teamname, class'Class'));
		TeamStats[j].Level = tr.default.TeamLevel;
		for (i = 0; i < tr.default.RosterNames.length; i++)
		{
			k = GetBotPosition(tr.default.RosterNames[i], true);
			BotStats[k].TeamId = j;
			BotStats[k].FreeAgent = false; // default not free
		}
		return j;
	}
	return -1;
}

/**
	Generate stats for the last match, all except the balance change
*/
function procLastMatchDetails(GameInfo currentGame, PlayerReplicationInfo PRI, UT2K4MatchInfo MI)
{
	local array<PlayerReplicationInfo> PRIArray;
	local int i;

	lmdFreshInfo= true;
	lmdbChallengeGame = bIsChallenge;
	lmdTeamGame = currentGame.bTeamGame;
	lmdWonMatch = bWonMatch;
	lmdEnemyTeam = EnemyTeam;
	lmdGameType = currentGame.GameName;
	lmdGameTime = currentGame.Level.TimeSeconds-currentGame.StartTime;
	lmdMap = Left(string(currentGame.Level), InStr(string(currentGame.Level), "."));
	if (PRI.Team != none) lmdMyTeam = PRI.Team.TeamIndex; else lmdMyTeam = 0;
	if (MI != none)
	{
		lmdPrizeMoney = MI.PrizeMoney;
	}
	else {
		lmdPrizeMoney = 0;
	}
	lmdInjury = LastInjured;
	if (lmdInjury > -1)
	{
		lmdInjuryHealth = BotStats[lmdInjury].Health;
		lmdInjuryTreatment = int(round((100-lmdInjuryHealth)*BotStats[lmdInjury].Price/100*InjuryTreatment));
	}
	currentGame.GameReplicationInfo.GetPRIArray(PRIArray);
	PlayerMatchDetails.Length = PRIArray.Length;
	for (i = 0; i < PRIArray.Length; i++)
	{
		PlayerMatchDetails[i].ID = PRIArray[i].PlayerID;
		PlayerMatchDetails[i].Name = PRIArray[i].PlayerName;
		PlayerMatchDetails[i].Kills = PRIArray[i].Kills;
		//PlayerMatchDetails[i].Score = PRIArray[i].GoalsScored;
		PlayerMatchDetails[i].Score = PRIArray[i].Score; // use score instead
		PlayerMatchDetails[i].Deaths = PRIArray[i].Deaths;
		if (PRIArray[i].Team != none) PlayerMatchDetails[i].Team = PRIArray[i].Team.TeamIndex;
		else if (PRIArray[i] == PRI) PlayerMatchDetails[i].Team = 0;
		else {
			PlayerMatchDetails[i].Team = -1;
		}
		PlayerMatchDetails[i].SpecialAwards.Length = 0;
		if (TeamPlayerReplicationInfo(PRIArray[i]) != none)
		{
			if ( TeamPlayerReplicationInfo(PRIArray[i]).flakcount >= sae_flackmonkey )
			{
				PlayerMatchDetails[i].SpecialAwards[PlayerMatchDetails[i].SpecialAwards.length] = msgSpecialAward[0];
				if (PRIArray[i] == PRI) SpecialAwards[0]++;
			}
			if ( TeamPlayerReplicationInfo(PRIArray[i]).combocount >= sae_combowhore )
			{
				PlayerMatchDetails[i].SpecialAwards[PlayerMatchDetails[i].SpecialAwards.length] = msgSpecialAward[1];
				if (PRIArray[i] == PRI) SpecialAwards[1]++;
			}
			if ( TeamPlayerReplicationInfo(PRIArray[i]).headcount >= sae_headhunter )
			{
				PlayerMatchDetails[i].SpecialAwards[PlayerMatchDetails[i].SpecialAwards.length] = msgSpecialAward[2];
				if (PRIArray[i] == PRI) SpecialAwards[2]++;
			}
			if ( TeamPlayerReplicationInfo(PRIArray[i]).ranovercount >= sae_roadrampage )
			{
				PlayerMatchDetails[i].SpecialAwards[PlayerMatchDetails[i].SpecialAwards.length] = msgSpecialAward[3];
				if (PRIArray[i] == PRI) SpecialAwards[3]++;
			}
		}
		if ( PRIArray[i].GoalsScored >= sae_hattrick )
		{
			PlayerMatchDetails[i].SpecialAwards[PlayerMatchDetails[i].SpecialAwards.length] = msgSpecialAward[4];
			if (PRIArray[i] == PRI) SpecialAwards[4]++;
		}
		if (( PRIArray[i].Deaths == sae_untouchable ) && !lmdTeamGame)
		{
			PlayerMatchDetails[i].SpecialAwards[PlayerMatchDetails[i].SpecialAwards.length] = msgSpecialAward[5];
			if (PRIArray[i] == PRI) SpecialAwards[5]++;
		}
	}
}

/** Create information about other matches played by other teams */
function procPhantomMatches(int games)
{
	local array<int> MatchHistory;
	local array<TeamStatsRecord> PhantomEnemies;
	local UT2K4MatchInfo MI;
	local int i, j, n1, n2;

	PhantomMatches.Length = games;
	if (games == 0) return; // to save time

	PhantomEnemies = TeamStats;
	for (i = 0; i < PhantomEnemies.length; i++)
	{
		if (PhantomEnemies[i].Name ~= EnemyTeam)
		{
			PhantomEnemies.Remove(i, 1);
			break;
		}
	}
	MatchHistory[MatchHistory.length] = CurrentLadder*100+CurrentMenuRung; // remove own match

	while (games > 0)
	{
		if (PhantomEnemies.length <= 1) break; // no more enemies

		// find a random match
		do {
			PhantomMatches[games-1].LadderId = UT2K4GameLadder.static.GetRandomLadder();
			PhantomMatches[games-1].MatchId = rand(LengthOfLadder(PhantomMatches[games-1].LadderId));
			n1 = PhantomMatches[games-1].LadderId*100+PhantomMatches[games-1].MatchId;
			for (j = 0; j < MatchHistory.length; j++)
			{
				if (MatchHistory[j] == n1) break;
			}
		} until (j >= MatchHistory.length);
		MatchHistory[MatchHistory.length] = n1; // add this item
		MI = UT2K4MatchInfo(GetMatchInfo(PhantomMatches[games-1].LadderId, PhantomMatches[games-1].MatchId));

		// find team 1
		j = rand(PhantomEnemies.length);
		PhantomMatches[games-1].Team1 = GetTeamPosition(PhantomEnemies[j].Name);
		n1 = PhantomEnemies[j].Level;
		PhantomEnemies.Remove(j, 1);
		// find team 2
		j = rand(PhantomEnemies.length);
		PhantomMatches[games-1].Team2 = GetTeamPosition(PhantomEnemies[j].Name);
		n2 = PhantomEnemies[j].Level;
		PhantomEnemies.Remove(j, 1);

		// normalize levels, -1 -> equal team strength
		if (n1 == -1) n1 = max(n2, 0);
		if (n2 == -1) n2 = max(n1, 0);
		n1++;
		n2++;

		// calculate the odds that team1 wins
		if (rand(n1+n2) >= n2)
		{
			n2 = PhantomMatches[games-1].Team1;
			PhantomMatches[games-1].ScoreTeam1 = MI.GoalScore;
			PhantomMatches[games-1].ScoreTeam2 = (MI.GoalScore-1)*frand();
		}
		else {
			n2 = PhantomMatches[games-1].Team2;
			PhantomMatches[games-1].ScoreTeam1 = (MI.GoalScore-1)*frand();
			PhantomMatches[games-1].ScoreTeam2 = MI.GoalScore;
		}
		PhantomMatches[games-1].GameTime = (PhantomMatches[games-1].ScoreTeam1+1)*(PhantomMatches[games-1].ScoreTeam2+1)+(frand()*MI.PrizeMoney);

		// n2 is set to the winning team
		RandomIncreaseBotFee(n2, FeeIncrease/2);
		games--;
	}
}

/** Increase fee of a few bots that belong to TeamId */
function RandomIncreaseBotFee(int TeamId, float updateFee)
{
	local int i;
	for (i = 0; i < Botstats.length; i++)
	{
		if ((BotStats[i].TeamId == TeamId) && (frand() > 0.5))
		{
			GetBotPrice(, i, updateFee);
		}
	}
}

/** converts money to a formatted string */
static function string MoneyToString(int money)
{
	local string res, tmp, prefix;
	if (money == 0) return "0"@default.msgCredits;
	if (money < 0)
	{
		prefix = "-";
		money *= -1;
	}
	else prefix = "";

	res = "";
	if (money == 1) return prefix$"1"@default.msgCredit;
	while (money > 0)
	{
		if (tmp != "") res = ","$res;
		tmp = string(int(money%1000));
		money = money / 1000;
		if (money > 0) tmp = Right("00"$tmp,3);
		res = tmp$res;
	}
	return prefix$res@default.msgCredits;
}

/** return the stored player id, use this to check a profile before loading it */
function string StoredPlayerID()
{
	return PlayerIDHash;
}

/** return if a profile has been locked out for character unlocking */
function bool IsLocked()
{
	return bLocked;
}

/** return the level ID selected, or -1 if no selection */
function int GetSelectedLevel(int ladder, int rung)
{
	local int i;
	for (i = 0; i < LevelRoute.length; i++)
	{
		if (LevelRoute[i].ladder == ladder && LevelRoute[i].rung == rung) return LevelRoute[i].selection;
	}
	return -1;
}

/** set a level selection */
function SetSelectedLevel(int ladder, int rung, byte id)
{
	local int i;
	for (i = 0; i < LevelRoute.length; i++)
	{
		if (LevelRoute[i].ladder == ladder && LevelRoute[i].rung == rung) break;
	}
	if (i <= LevelRoute.length) LevelRoute.length = i+1;
	LevelRoute[i].ladder = ladder;
	LevelRoute[i].rung = rung;
	LevelRoute[i].selection = id;
}

/** remove a previous set selection */
function ResetSelectedLevel(int ladder, int rung)
{
	local int i;
	for (i = 0; i < LevelRoute.length; i++)
	{
		if (LevelRoute[i].ladder == ladder && LevelRoute[i].rung == rung)
		{
			LevelRoute.remove(i, 1);
			return;
		}
	}
}

/** get the alternative team roster */
function bool GetAltTeamRoster(string TeamRosterName, out array<string> result)
{
	local int i;
	result.length = 0;
	if (TeamRosterName == "") return false;
	//Log("GetAltTeamRoster"@TeamRosterName);
	for (i = 0; i < AltTeamRoster.length; i++)
	{
		if (AltTeamRoster[i].name ~= TeamRosterName)
		{
			result = AltTeamRoster[i].roster;
			return true;
		}
	}
	return false;
}

/** set the alternative team roster */
function SetAltTeamRoster(string TeamRosterName, array<string> NewRoster)
{
	local int i;
	if (TeamRosterName == "") return;
	for (i = 0; i < AltTeamRoster.length; i++)
	{
		if (AltTeamRoster[i].name ~= TeamRosterName) break;
	}
	if (AltTeamRoster.length <= i)
	{
		AltTeamRoster.length = i+1;
		AltTeamRoster[i].name = TeamRosterName;
	}
	AltTeamRoster[i].roster = NewRoster;
}

/**
	Adds the current match info to the history table
*/
function AddHistoryRecord(GameInfo Game, PlayerReplicationInfo PRI, UT2K4MatchInfo MI)
{
	local int i, j, n;
	local array<PlayerReplicationInfo> PRIArray;
	local string tmp;

	i = FightHistory.length;
	FightHistory.length = FightHistory.length+1;

	FightHistory[i].Date[0] = Game.Level.Year;
	FightHistory[i].Date[1] = Game.Level.Month;
	FightHistory[i].Date[2] = Game.Level.Day;
	FightHistory[i].Time[0] = Game.Level.Hour;
	FightHistory[i].Time[1] = Game.Level.Minute;

	FightHistory[i].Level = Left(string(Game.Level), InStr(string(Game.Level), "."));
	FightHistory[i].GameType = Game.GameName;
	FightHistory[i].EnemyTeam = EnemyTeam;
	if (MI != none) FightHistory[i].PriceMoney = MI.PrizeMoney;
	FightHistory[i].BalanceChange = lmdBalanceChange;
	FightHistory[i].BonusMoney = lmdTotalBonusMoney;
	FightHistory[i].GameTime = Game.Level.TimeSeconds-Game.StartTime;
	FightHistory[i].WonGame = bWonMatch;
	FightHistory[i].TeamGame = Game.bTeamGame;
	if (Game.bTeamGame)
	{
		Game.GameReplicationInfo.GetPRIArray(PRIArray);
		tmp = "";
		for (j = 0; j < PRIArray.Length; j++)
		{
			if (PRIArray[j].Team.TeamIndex == ((PRI.Team.TeamIndex+1) % 2))
			{
				if (tmp != "") tmp $= ", ";
				tmp $= PRIArray[j].PlayerName;
			}
		}
		FightHistory[i].TeamScore[0] = TeamGame(Game).Teams[(PRI.Team.TeamIndex+1) % 2].Score;
		FightHistory[i].TeamLayout[0] = tmp;
		tmp = "";
		for (j = 0; j < PRIArray.Length; j++)
		{
			if (PRIArray[j].Team.TeamIndex == PRI.Team.TeamIndex)
			{
				if (tmp != "") tmp $= ", ";
				tmp $= PRIArray[j].PlayerName;
			}
		}
		FightHistory[i].TeamScore[1] = TeamGame(Game).Teams[PRI.Team.TeamIndex].Score;
		FightHistory[i].TeamLayout[1] = tmp;
	}

	for (j = 0; j < PlayerMatchDetails.length; j++)
	{
		if (PlayerMatchDetails[j].ID == PRI.PlayerID)
		{
			FightHistory[i].MyScore = PlayerMatchDetails[j].Score;
			FightHistory[i].MyKills = PlayerMatchDetails[j].Kills;
			FightHistory[i].MyDeaths = PlayerMatchDetails[j].Deaths;
			for (n = 0; n < PlayerMatchDetails[j].SpecialAwards.length; n++)
			{
				if (FightHistory[i].MyAwards != "") FightHistory[i].MyAwards $= ", ";
				FightHistory[i].MyAwards $= PlayerMatchDetails[j].SpecialAwards[n];
			}
			break;
		}
	}

	if (bIsChallenge)
	{
		FightHistory[i].MatchData = msgChallengeGame$";"$ChallengeGameClass.default.ChallengeName;
		ChallengeGameClass.static.AddHistoryRecord(self, i, Game, PRI, MI);
	}
	else if (CurrentLadder >= 10)
	{
		FightHistory[i].MatchData = msgAdditionalLadder$";"$LastCustomCladder.default.LadderName@msgMatch@CurrentMenuRung;
		LastCustomCladder.static.AddHistoryRecord(self, i, Game, PRI, MI);
	}
	else {
		FightHistory[i].MatchData = msgLadderGame$";";
		switch (CurrentLadder)
		{
			case UT2K4GameLadder.default.LID_DM:
			case UT2K4GameLadder.default.LID_TDM:
			case UT2K4GameLadder.default.LID_CTF:
			case UT2K4GameLadder.default.LID_DOM:
			case UT2K4GameLadder.default.LID_BR:
			case UT2K4GameLadder.default.LID_AS:	FightHistory[i].MatchData $= GetLadderDescription(CurrentLadder);
													break;
			case UT2K4GameLadder.default.LID_CHAMP:	FightHistory[i].MatchData $= msgChampionship;
		}
		FightHistory[i].MatchData @= msgMatch@CurrentMenuRung;
	}
}

/** return a random or selected challenge game */
function class<ChallengeGame> GetChallengeGame(optional string ClassName)
{
	return UT2K4GameLadder.static.GetChallengeGame(ClassName, self);
}

/** return the minimal fee for x team members, only uses team mates that are healthy */
function float getMinimalTeamFee(int members, optional bool bIgnoreHealth)
{
	local array<int> fees;
	local int i, j, n, tmp;

	for (i = 0; i < GetMaxTeamSize(); i++)
	{
		j = GetBotPosition(PlayerTeam[i]);
		if ((j > -1) && ((BotStats[j].Health >= 100) || bIgnoreHealth))
		{
			tmp = BotStats[j].Price*LoserFee;
			for (n = 0; n < fees.Length; n++)
			{
				if (fees[n] > tmp)
				{
					fees.Insert(n, 1);
					fees[n] = tmp;
					break;
				}
			}
			if (n == fees.length)
			{
				fees.length = fees.length+1;
				fees[fees.length-1] = tmp;
			}
		}
	}
	if (fees.length < members) return 2147483647;
	j = 0;
	for (i = 0; i < members; i++)
	{
		j += fees[i];
	}
	return j;
}

/** get the minimal fee for this match, based on the entry fee for the
	match and the minimal fee to pay out to your team mates if you lose.
	If you don't have enough team mates the result is negative */
function int getMinimalEntryFeeFor(UT2K4MatchInfo MI, optional bool bIgnoreHealth)
{
	local int res;
 	res = MI.EntryFee;
	if (IsTeamGametype(MI.GameType))
	{
		res += getMinimalTeamFee(MI.NumBots / 2, bIgnoreHealth);
	}
	if (bDebug) log("getMinimalEntryFeeFor ="@res);
	return res;
}

function UpgradeGP()
{
	local int i;
	if (revision == 0)
	{
		log("Revision upgrade to 1", LogPrefix);
		MinBalance = 75;
		InjuryChance = 0.30+(BaseDifficulty / 30);
		ChallengeChance = 0.30+(BaseDifficulty / 30);
		FeeIncrease = 0.02+(BaseDifficulty / 300);
		TeamPercentage = 0.35+(BaseDifficulty / 30);
		MatchBonus = 0.03+(TeamPercentage / 10);
		revision = 1;
	}
	if (revision == 1)
	{
		log("Revision upgrade to 2", LogPrefix);
		TeamPercentage = 0.25+(BaseDifficulty / 30);
		MatchBonus = 0.05+(TeamPercentage / 10);
		revision = 2;
	}
	if (revision == 2)
	{
		log("Revision upgrade to 3", LogPrefix);
		InjuryTreatment = 0.75+(BaseDifficulty / 50);
		MapChallengeCost = 0.10+(BaseDifficulty / 100);
		revision = 3;
	}
	if (revision == 3)
	{
		log("Revision upgrade to 4", LogPrefix);
		for (i = TeamStats.Length-1; i >= 0; i--)
		{
			if (TeamStats[i].Name == "") TeamStats.Remove(i, 1);
		}
		for (i = BotStats.Length-1; i >= 0; i--)
		{
			if (BotStats[i].Name == "") BotStats.Remove(i, 1);
		}
		revision = 4;
	}
	if (revision == 4)
	{
		log("Revision upgrade to 5", LogPrefix);
		if (bCompleted && !bLocked && !bCheater)
		{
			if (completedLadder(UT2K4GameLadder.default.LID_CHAMP))
			{
				bCompleted = false;
				SpecialEvent = "COMPLETED CHAMP";
			}
		}
		revision = 5;
	}
}

defaultproperties
{
     Revision=5
     LadderProgress(0)=1
     LadderProgress(1)=-1
     LadderProgress(2)=-1
     LadderProgress(3)=-1
     LadderProgress(4)=-1
     LadderProgress(5)=-1
     LadderProgress(6)=-1
     MaxTeamSize=5
     Balance=250
     MinBalance=75
     TeamPercentage=0.250000
     MatchBonus=0.050000
     LoserFee=0.100000
     FeeIncrease=0.020000
     InjuryChance=0.300000
     LastInjured=-1
     InjuryTreatment=0.750000
     ChallengeChance=0.300000
     ChallengeInfo=UT2K4MatchInfo'XGame.UT2K4GameProfile.GPCHALINFO'
     LoginMenuClass="GUI2K4.UT2K4SinglePlayerLoginMenu"
     LogPrefix="SinglePlayer"
     SpreeBonus(0)=20
     SpreeBonus(1)=60
     SpreeBonus(2)=120
     SpreeBonus(3)=200
     SpreeBonus(4)=300
     SpreeBonus(5)=420
     MultiKillBonus(0)=10
     MultiKillBonus(1)=30
     MultiKillBonus(2)=60
     MultiKillBonus(3)=100
     MultiKillBonus(4)=150
     MultiKillBonus(5)=210
     MultiKillBonus(6)=280
     msgSpecialAward(0)="Flak Monkey"
     msgSpecialAward(1)="Combo Whore"
     msgSpecialAward(2)="Head Hunter"
     msgSpecialAward(3)="Road Rampage"
     msgSpecialAward(4)="Hat Trick"
     msgSpecialAward(5)="Untouchable"
     sae_flackmonkey=15
     sae_combowhore=15
     sae_headhunter=15
     sae_roadrampage=10
     sae_hattrick=3
     msgCheater="CHEATER!!!"
     msgCredits="credits"
     msgCredit="credit"
     MapChallengeCost=0.100000
     msgChallengeGame="Challenge game"
     msgAdditionalLadder="Additional ladder game"
     msgMatch="match"
     msgLadderGame="Ladder game"
     msgChampionship="Championship"
     bShowDetails=True
     GameLadderName="xGame.UT2K4LadderInfo"
}
