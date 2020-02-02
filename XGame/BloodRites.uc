//==============================================================================
// Single Player Challenge Game code
// A blood rite challenge is a challenge against an whole team. The prize is a
// exchange of team mates.
//
// Written by Michiel Hendriks
// (c) 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class BloodRites extends ChallengeGame;

/** menu to display when we lost out team mate */
var string UntradeMenu;
/** The trade menu */
var string TradeMenu;
/** entry fee multiplicator of the bot's price */
var float ChalFeeMultiply;

/**
	We have two special events: TRADE and UNTRADE
	Both have the arguments <teamname> <playername>
	In case of TRADE you get a player to add to your team, unless your team is
	already full, then you have to remove one firts.
	UNTRADE will just give you the message that a team mate has been removed
	from your team.
*/
static function HandleSpecialEvent(UT2K4GameProfile GP, array<string> SpecialEvent, out array<TriString> GUIPages)
{
	local class<UT2K4TeamRoster> ETI;
	local array<string> NewTeamRoster;
	local int i;

	if (SpecialEvent[0] == "TRADE")
	{
		GUIPages.length = GUIPages.length+1;
		GUIPages[GUIPages.length-1].GUIPage = default.TradeMenu;
		GUIPages[GUIPages.length-1].Param1 = SpecialEvent[1];
		GUIPages[GUIPages.length-1].Param2 = SpecialEvent[2];

		// remove the player from that team
		if (!GP.GetAltTeamRoster(SpecialEvent[1], NewTeamRoster))
		{
			ETI = class<UT2K4TeamRoster>(DynamicLoadObject(SpecialEvent[1], class'Class'));
			if (ETI != none) NewTeamRoster = ETI.default.RosterNames;
			else Warn("Some Nali cow ate the enemy team class");
		}
		for (i = 0; i < NewTeamRoster.length; i++)
		{
			if (NewTeamRoster[i] ~= SpecialEvent[2])
			{
				NewTeamRoster.remove(i, 1);
				break;
			}
		}
		GP.SetAltTeamRoster(SpecialEvent[1], NewTeamRoster);
		// update bot stats
		i = GP.GetBotPosition(SpecialEvent[2]);
		if (i > -1)
		{
			GP.BotStats[i].Health = 100;
			GP.BotStats[i].TeamId = -1;
			// refund entry fee
			GP.Balance += GP.BotStats[i].Price*default.ChalFeeMultiply;
		}
	}
	else if (SpecialEvent[0] == "UNTRADE")
	{
		GUIPages.length = GUIPages.length+1;
		GUIPages[GUIPages.length-1].GUIPage = default.UnTradeMenu;
		GUIPages[GUIPages.length-1].Param1 = SpecialEvent[1];
		GUIPages[GUIPages.length-1].Param2 = SpecialEvent[2];
		// remove the player from our team
		GP.ReleaseTeammate(SpecialEvent[2]);
		// add it to the enemy team
		if (!GP.GetAltTeamRoster(SpecialEvent[1], NewTeamRoster))
		{
			ETI = class<UT2K4TeamRoster>(DynamicLoadObject(SpecialEvent[1], class'Class'));
			if (ETI != none) NewTeamRoster = ETI.default.RosterNames;
			else Warn("Some Nali cow ate the enemy team class");
		}
		if (NewTeamRoster.length == 0)
		{
			NewTeamRoster.length = NewTeamRoster.length+1;
			NewTeamRoster[NewTeamRoster.length-1] = SpecialEvent[2];
			// update bot stats
			i = GP.GetBotPosition(SpecialEvent[2]);
			if (i > -1)
			{
				GP.BotStats[i].Health = 100;
				GP.BotStats[i].TeamId = GP.GetTeamPosition(SpecialEvent[1]);
			}
		}
		GP.SetAltTeamRoster(SpecialEvent[1], NewTeamRoster);
	}
}

/** when we where challenged the SpecialEvent logic goes the other way around */
static function PostRegisterGame(UT2K4GameProfile GP, GameInfo currentGame, PlayerReplicationInfo PRI)
{
	// do the switch
	if (GP.bGotChallenged)
	{
		if (!GP.bWonMatch) GP.SpecialEvent $= ";"$GP.ChallengeInfo.SpecialEvent;
		else {
			// remove the UNTRADE
			GP.SpecialEvent = repl(GP.SpecialEvent, GP.ChallengeInfo.SpecialEvent, "");
		}
	}
}

static function AddHistoryRecord(UT2K4GameProfile GP, int offset, GameInfo Game, PlayerReplicationInfo PRI, UT2K4MatchInfo MI)
{
	super.AddHistoryRecord(GP, offset, game, PRI, MI);

}

static function bool canChallenge(optional UT2K4GameProfile GP)
{
	if (GP == none) return true;
	return GP.completedLadder(GP.UT2K4GameLadder.default.LID_TDM);
}

static function bool payTeamMates(UT2K4GameProfile GP)
{
	return ! GP.bGotChallenged;
}

static function StartChallenge(UT2K4GameProfile GP, LevelInfo myLevel)
{
	GP.SpecialEvent = "";
	if (GP.bGotChallenged) GP.SpecialEvent = GP.ChallengeInfo.SpecialEvent; // so you can't chicken out
	GP.bIsChallenge = true;
	GP.Balance -= GP.ChallengeInfo.EntryFee;
	GP.ChallengeGameClass = default.class;
	GP.StartNewMatch ( -1, myLevel );
}

defaultproperties
{
     UntradeMenu="GUI2K4.UT2K4SP_CGBRUntrade"
     TradeMenu="GUI2K4.UT2K4SP_CGBRTrade"
     ChalFeeMultiply=3.000000
     ChallengeName="Bloodrites"
     ChallengeDescription="Challenge an enemy team for one for their team mates."
     ChallengeMenu="GUI2K4.UT2K4SP_CGBloodRites"
}
