//=============================================================================
// TeamGame.
//=============================================================================
class TeamGame extends DeathMatch
	HideDropDown
	CacheExempt
	config;

var globalconfig	bool	bBalanceTeams;			// bots balance teams
var globalconfig	bool	bPlayersBalanceTeams;	// players balance teams
var config			bool	bAllowNonTeamChat;
var 				bool	bScoreTeamKills;
var 				bool	bSpawnInTeamArea;	// players spawn in marked team playerstarts
var					bool	bScoreVictimsTarget;	// Should we check a victims target for bonuses

var config			float	FriendlyFireScale;		//scale friendly fire damage by this value
var					int		MaxTeamSize;			// OBSOLETE - no longer used
var					float   TeammateBoost;

var	UnrealTeamInfo Teams[2];
var string BlueTeamName, RedTeamName;		// when specific pre-designed teams are specified on the URL
var class<TeamAI> 			TeamAIType[2];
var String PathWhisps[2];
var localized string NearString, BareHanded;

var name CaptureSoundName[2];
var name TakeLeadName[2];
var name IncreaseLeadName[2];

// localized PlayInfo descriptions & extra info
const TGPROPNUM = 5;
var localized string TGPropsDisplayText[TGPROPNUM];
var localized string TGPropDescText[TGPROPNUM];

var(LoadingHints) private localized array<string> TGHints;

var() float ADR_Goal;
var() float ADR_Return;
var() float ADR_Control;

var texture TempSymbols[2];

var float LastEndGameTauntTime;
var localized string EndGameComments[10], EndGameTaunts[10], EndGameVictoryRemarks[10], EndGameLossRemarks[10], EndGameResponses[10];
var byte EndGameCommented[10], EndGameRemark[10];
var int LastEndGameComment, LastEndGameRemark, LastEndGameResponse;

function PostBeginPlay()
{
	local int i;

	if ( InitialBots > 0 )
	{
		Teams[0] = GetRedTeam(0.5 * InitialBots + 1);
		Teams[1] = GetBlueTeam(0.5 * InitialBots + 1);
	}
	else
	{
		Teams[0] = GetRedTeam(0);
		Teams[1] = GetBlueTeam(0);
	}
	for (i=0;i<2;i++)
	{
		Teams[i].TeamIndex = i;
		Teams[i].AI = Spawn(TeamAIType[i]);
		Teams[i].AI.Team = Teams[i];
		GameReplicationInfo.Teams[i] = Teams[i];
	}
	Teams[0].AI.EnemyTeam = Teams[1];
	Teams[1].AI.EnemyTeam = Teams[0];
	Teams[0].AI.SetObjectiveLists();
	Teams[1].AI.SetObjectiveLists();
	Super.PostBeginPlay();
}

event SetGrammar()
{
	LoadSRGrammar("TDM");
}

function int ParseOrder(string OrderString)
{
	switch ( OrderString )
	{
		case "DEFEND":
		case "TAKE ALPHA":
			return 0;
		case "ATTACK":
		case "TAKE BRAVO":
			return 2;
		case "COVER":
			return 3;
		case "HOLD":
			return 1;
		case "FREELANCE":
			return 4;
		case "GIMME":
			return 256;
		case "JUMP":
			return 257;
		case "STATUS":
			return 258;
		case "TAUNT":
			return 259;
		case "SUICIDE":
			return 260;
	}
}

function bool ApplyOrder( PlayerController Sender, int RecipientID, int OrderID )
{
	local controller P;

	if( OrderID > 255 )
	{
		if( OrderID == 260 )	// SUICIDE
		{
			if ( Level.NetMode == NM_Standalone )
			{
				for ( P=Level.ControllerList; P!= None; P=P.NextController )
				{
					if ( (Bot(P) != None) && (Bot(P).Pawn != None) && (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == Sender.PlayerReplicationInfo.Team)
						&& ((RecipientID == -1) || (RecipientID == P.PlayerReplicationInfo.TeamID)) )
					{
						Bot(P).Pawn.KilledBy( Bot(P).Pawn );
						if ( RecipientID == P.PlayerReplicationInfo.TeamID )
							break;
					}
				}
			}
			return true;
		}
		else
		if( OrderID == 259 )	// TAUNT
		{
			for ( P=Level.ControllerList; P!= None; P=P.NextController )
			{
				if ( (Bot(P) != None) && (Bot(P).Pawn != None) && (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == Sender.PlayerReplicationInfo.Team)
					&& ((RecipientID == -1) || (RecipientID == P.PlayerReplicationInfo.TeamID)) )
				{
					Bot(P).ForceCelebrate();
					if ( RecipientID == P.PlayerReplicationInfo.TeamID )
						break;
				}
			}
			return true;
		}
		else
		if( OrderID == 256 ) // GIMME
		{
			if ( (Level.NetMode != NM_Standalone) && (RecipientID == -1) )
				return true;
			for ( P=Level.ControllerList; P!= None; P=P.NextController )
			{
				if ( (Bot(P) != None) && (Bot(P).Pawn != None) && (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == Sender.PlayerReplicationInfo.Team)
					&& ((RecipientID == -1) || (RecipientID == P.PlayerReplicationInfo.TeamID)) )
				{
					Bot(P).ForceGiveWeapon();
					if ( RecipientID == P.PlayerReplicationInfo.TeamID )
						break;
				}
			}
			return true;
		}
		else
		if( OrderID == 257 ) // JUMP
		{
			if ( (Level.NetMode != NM_Standalone) && (RecipientID == -1) )
				return true;
			for ( P=Level.ControllerList; P!= None; P=P.NextController )
			{
				if ( (Bot(P) != None) && (Bot(P).Pawn != None) && (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == Sender.PlayerReplicationInfo.Team)
					&& ((RecipientID == -1) || (RecipientID == P.PlayerReplicationInfo.TeamID)) )
				{
					Bot(P).Pawn.bWantsToCrouch = false;
					Bot(P).Pawn.DoJump(false);
					if ( RecipientID == P.PlayerReplicationInfo.TeamID )
						break;
				}
			}
			return true;
		}
		else
		if( OrderID == 258 ) // STATUS
		{
			for ( P=Level.ControllerList; P!= None; P=P.NextController )
			{
				if ( (Bot(P) != None) && (Bot(P).Pawn != None) && (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == Sender.PlayerReplicationInfo.Team)
					&& ((RecipientID == -1) || (RecipientID == P.PlayerReplicationInfo.TeamID)) )
				{
					Bot(P).SendMessage(Sender.PlayerReplicationInfo, 'OTHER', GetStatus(Sender, Bot(p)), 0, 'TEAM');
					if ( RecipientID == P.PlayerReplicationInfo.TeamID )
						break;
				}
			}
			return true;
		}
		else
			return false;
	}
	else
	{
		for ( P=Level.ControllerList; P!= None; P=P.NextController )
		{
			if ( (Bot(P) != None) && (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == Sender.PlayerReplicationInfo.Team) )
			{
				Bot(P).bInstantAck = true;
				if ( RecipientID == -1 )
					P.BotVoiceMessage('ORDER', OrderID, Sender);
				else if ( RecipientID == P.PlayerReplicationInfo.TeamID )
				{
					P.BotVoiceMessage('ORDER', OrderID, Sender);
					Bot(P).bInstantAck = false;
					break;
				}
				Bot(P).bInstantAck = false;
			}
		}
	}
	return true;
}

function int ParseRecipient( string Recipient )
{
	local int RecipientID,i;

	if( Recipient == "" )
	{
		RecipientID = -2;
	}
	else
	if( Recipient == "TEAM" )
	{
		RecipientID = -1;
	}
	else
	{
		RecipientID = -2;
		for( i=0; i<15; i++ )
		{
			if( Recipient ~= CallSigns[i] )
			{
				RecipientID = i;
				break;
			}
		}
	}
	return RecipientID;
}

function ParseRecipients( out int RecipientIDs[3], out int NumRecipients, out string OrderString )
{
	local string Recipient, Rest;
	local int RecipientID;
	local bool Done;

	RecipientIDs[0] = -2;
	RecipientIDs[1] = -2;
	RecipientIDs[2] = -2;
	NumRecipients	= 0;

	Done			= false;

	if( !Divide( OrderString, " ", Recipient, Rest ) )
		return;

	do
	{
		RecipientID = ParseRecipient( Recipient );

		if( RecipientID != -2 )
		{
			OrderString = Rest;
			Done = !Divide( OrderString, " ", Recipient, Rest );
			RecipientIDs[NumRecipients] = RecipientID;
			NumRecipients++;
		}
		else
			Done = true;
	}
	until( (NumRecipients==3) || Done );
}

/* Parse voice command and give order to bot
*/
function ParseVoiceCommand( PlayerController Sender, string RecognizedString )
{
	local int RecipientIDs[3];
	local int NumRecipients, OrderID, i;
	local string OrderString;

	// Nothing to be done if there is no sender.
	if ( Sender == None )
		return;

	// Parse who to send orders to.
	OrderString = RecognizedString;
	ParseRecipients( RecipientIDs, NumRecipients, OrderString );

	// Abort if no recipients.
	if( NumRecipients == 0 )
		return;

	// Parse the order once.
	OrderID = ParseOrder( OrderString );

	// Apply the order to possibly multiple recipients.
	for( i=0; i<NumRecipients; i++ )
		ApplyOrder( Sender, RecipientIDs[i], OrderID );
}

function int GetStatus(PlayerController Sender, Bot B)
{
	local name BotOrders;
	local int i, count;

	BotOrders = B.GetOrders();
	if ( B.Pawn == None )
	{
		if ( (BotOrders == 'DEFEND') && (B.Squad.Size == 1) )
			return 0;
	}
	else if ( B.PlayerReplicationInfo.HasFlag != None )
	{
		if ( B.Pawn.Health < 50 )
			return 13;
		return 2;
	}
	else if ( B.Enemy == None )
	{
		if ( BotOrders == 'DEFEND' )
			return 11;
		if ( (BotOrders == 'ATTACK') && B.bReachedGatherPoint )
			return 9;
	}
	else if ( B.EnemyVisible() )
	{
		if ( (B.Enemy.PlayerReplicationInfo != None) && (B.Enemy.PlayerReplicationInfo.HasFlag != None) )
			return BallCarrierMessage();
		if ( (BotOrders == 'DEFEND') && (((B.GoalScript != None) && (VSize(B.GoalScript.Location - B.Pawn.Location) < 1500)) || B.Squad.SquadObjective.BotNearObjective(B)) )
		{
			for ( i=0; i<8; i++ )
				if ( (B.Squad.Enemies[i] != None) && (B.Squad.Enemies[i].Health > 0) )
					Count++;

			if ( Count > 2 )
			{
				if ( B.Pawn.Health < 60 )
					return 21;
				return 22;
			}
			return 20;
		}
		if ( (BotOrders != 'FOLLOW') || (B.Squad.SquadLeader != Sender) )
		{
			for ( i=0; i<8; i++ )
				if ( (B.Squad.Enemies[i] != None) && (B.Squad.Enemies[i].Health > 0) )
					Count++;

			if ( Count > 1 )
			{
				if ( B.Pawn.Health < 60 )
				{
					if ( (BotOrders == 'ATTACK') || (BotOrders == 'FREELANCE') )
						return 13;
					return 21;
				}
			}
		}
	}
	else if ( B.Pawn.Health < 50 )
		return 13;
	else if ( (BotOrders == 'DEFEND') && (B.Squad.SquadObjective != None)
				&& (((B.GoalScript != None) && (VSize(B.GoalScript.Location - B.Pawn.Location) < 1500)) || B.Squad.SquadObjective.BotNearObjective(B)) )
		return 20;
	if ( (BotOrders == 'HOLD') &&  B.Pawn.ReachedDestination(B.GoalScript) )
		return 9;
	if ( (BotOrders == 'FOLLOW') && (B.Squad.SquadLeader == Sender) && (B.Squad.SquadLeader.Pawn != None)
			&& B.LineOfSightTo(B.Squad.SquadLeader.Pawn) )
		return 3;
	if ( BotOrders == 'DEFEND' )
		return 26;
	if ( BotOrders == 'ATTACK' )
	{
		if ( B.bFinalStretch )
			return 10;
		return 27;
	}
	return 11;
}

function int BallCarrierMessage()
{
	return 12;
}

static function PrecacheGameAnnouncements(AnnouncerVoice V, bool bRewardSounds)
{
	Super.PrecacheGameAnnouncements(V,bRewardSounds);
	if ( !bRewardSounds )
	{
		V.PrecacheSound('Red_Team_Scores');
		V.PrecacheSound('Blue_Team_Scores');
		V.PrecacheSound('Red_Team_increases_their_lead');
		V.PrecacheSound('Blue_Team_increases_their_lead');
		V.PrecacheSound('Red_Team_takes_the_lead');
		V.PrecacheSound('Blue_Team_takes_the_lead');
	}
	else
		V.PrecacheSound('HatTrick');
}

/* OBSOLETE UpdateAnnouncements() - preload all announcer phrases used by this actor */
simulated function UpdateAnnouncements() {}

// check if all other players are out
function bool CheckMaxLives(PlayerReplicationInfo Scorer)
{
    local Controller C;
    local PlayerReplicationInfo Living;
    local bool bNoneLeft;

    if ( MaxLives > 0 )
    {
		if ( (Scorer != None) && !Scorer.bOutOfLives )
			Living = Scorer;
        bNoneLeft = true;
        for ( C=Level.ControllerList; C!=None; C=C.NextController )
            if ( (C.PlayerReplicationInfo != None) && C.bIsPlayer
                && !C.PlayerReplicationInfo.bOutOfLives
                && !C.PlayerReplicationInfo.bOnlySpectator )
            {
				if ( Living == None )
					Living = C.PlayerReplicationInfo;
				else if ( (C.PlayerReplicationInfo != Living) && (C.PlayerReplicationInfo.Team != Living.Team) )
			   	{
    	        	bNoneLeft = false;
	            	break;
				}
            }
        if ( bNoneLeft )
        {
			if ( Living != None )
				EndGame(Living,"LastMan");
			else
				EndGame(Scorer,"LastMan");
			return true;
		}
    }
    return false;
}

function TeamInfo OtherTeam(TeamInfo Requester)
{
	if ( Requester == Teams[0] )
		return Teams[1];
	return Teams[0];
}

function OverrideInitialBots()
{
	InitialBots = Teams[0].OverrideInitialBots(InitialBots,Teams[1]);
}

function PreLoadNamedBot(string BotName)
{
	local int first, second;

	second	= 1;
	// always imbalance teams in favor of bot team in single player
	if ( (StandalonePlayer != None ) && (StandalonePlayer.PlayerReplicationInfo.Team.TeamIndex == 1) )
	{
		first = 1;
		second = 0;
	}
	if ( 1 + Teams[first].Roster.Length < Teams[second].Roster.Length )
		Teams[first].AddNamedBot(BotName);
	else
		Teams[second].AddNamedBot(BotName);
}

function PreLoadBot()
{
	if ( Teams[0].Roster.Length < 0.5 * InitialBots + 1 )
		Teams[0].AddRandomPlayer();
	if ( Teams[1].Roster.Length < 0.5 * InitialBots + 1 )
		Teams[1].AddRandomPlayer();
}

/* create a player team, and fill from the team roster
*/
function UnrealTeamInfo GetBlueTeam(int TeamBots)
{
	local class<UnrealTeamInfo> RosterClass;
	local UnrealTeamInfo Roster;

    if ( CurrentGameProfile != None )
	{
		RosterClass = class<UnrealTeamInfo>(DynamicLoadObject(DefaultEnemyRosterClass,class'Class'));
		Roster = Spawn(RosterClass);
		Roster.FillPlayerTeam(CurrentGameProfile);
		return Roster;
	}
	else if ( BlueTeamName != "" )
		RosterClass = class<UnrealTeamInfo>(DynamicLoadObject(BlueTeamName,class'Class'));
	else
		RosterClass = class<UnrealTeamInfo>(DynamicLoadObject(DefaultEnemyRosterClass,class'Class'));
	Roster = spawn(RosterClass);
	Roster.Initialize(TeamBots);
	return Roster;
}

function UnrealTeamInfo GetRedTeam(int TeamBots)
{
	EnemyRosterName = RedTeamName;
	return Super.GetBotTeam(TeamBots);
}

// Parse options for this game...
event InitGame( string Options, out string Error )
{
	local string InOpt;
	local class<TeamAI> InType;
	local string RedSymbolName,BlueSymbolName;
	local texture NewSymbol;

	Super.InitGame(Options, Error);
	InOpt = ParseOption( Options, "RedTeamAI");
	if ( InOpt != "" )
	{
		InType = class<TeamAI>(DynamicLoadObject(InOpt, class'Class'));
		if ( InType != None )
			TeamAIType[0] = InType;
	}

	InOpt = ParseOption( Options, "BlueTeamAI");
	if ( InOpt != "" )
	{
		InType = class<TeamAI>(DynamicLoadObject(InOpt, class'Class'));
		if ( InType != None )
			TeamAIType[1] = InType;
	}

	// get passed in teams
	RedTeamName = ParseOption( Options, "RedTeam");
	BlueTeamName = ParseOption( Options, "BlueTeam");

	if ( RedTeamName != "" )
	{
		bCustomBots = true;
		if ( BlueTeamName == "" )
			BlueTeamName = "xGame.TeamBlueConfigured";
	}
	else if ( BlueTeamName != "" )
	{
		bCustomBots = true;
		RedTeamName = "xGame.TeamRedConfigured";
	}

	// set teamsymbols (optional)
	RedSymbolName = ParseOption( Options, "RedTeamSymbol");
	BlueSymbolName = ParseOption( Options, "BlueTeamSymbol");
	if ( RedSymbolName != "" )
	{
		NewSymbol = Texture(DynamicLoadObject(RedSymbolName,class'Texture'));
		if ( NewSymbol != None )
			TempSymbols[0] = NewSymbol;
	}
	if ( BlueSymbolName != "" )
	{
		NewSymbol = Texture(DynamicLoadObject(BlueSymbolName,class'Texture'));
		if ( NewSymbol != None )
			TempSymbols[1] = NewSymbol;
	}

	InOpt = ParseOption( Options, "FF");
	if ( InOpt != "" )
		FriendlyFireScale = FMin(1.0,float(InOpt));
	if ( CurrentGameProfile != None )
	{
		FriendlyFireScale = 0.0;
	}

	InOpt = ParseOption( Options, "FriendlyFireScale");
	if ( InOpt != "" )
		FriendlyFireScale = FMin(1.0,float(InOpt));
	if ( CurrentGameProfile != None )
	{
		FriendlyFireScale = 0.0;
	}

	InOpt = ParseOption(Options, "BalanceTeams");
	if ( InOpt != "" )
	{
		bBalanceTeams = bool(InOpt);
		bPlayersBalanceTeams = bBalanceTeams;
	}
}

function InitTeamSymbols()
{
	if ( (TempSymbols[0] == None) && (Teams[0].TeamSymbolName != "") )
		TempSymbols[0] = Texture(DynamicLoadObject(Teams[0].TeamSymbolName,class'Texture'));
	if ( (TempSymbols[1] == None) && (Teams[1].TeamSymbolName != "") )
		TempSymbols[1] = Texture(DynamicLoadObject(Teams[1].TeamSymbolName,class'Texture'));

	GameReplicationInfo.TeamSymbols[0] = TempSymbols[0];
	GameReplicationInfo.TeamSymbols[1] = TempSymbols[1];
	Super.InitTeamSymbols();
}

function int GetMinPlayers()
{
	local int LevelMinPlayers;

	// make sure min number of players is an even number
	LevelMinPlayers = Super.GetMinPlayers();
	if ((LevelMinPlayers & 1) != 0)
		return LevelMinPlayers + 1;
	else
		return LevelMinPlayers;
}

function bool CanShowPathTo(PlayerController P, int TeamNum)
{
	return true;
}

function ShowPathTo(PlayerController P, int TeamNum)
{
	local GameObjective			G, Best;
	local class<WillowWhisp>	WWclass;

	for ( G=Teams[0].AI.Objectives; G!=None; G=G.NextObjective )
		if ( G.BetterObjectiveThan(Best, TeamNum, P.PlayerReplicationInfo.Team.TeamIndex) )
			Best = G;

	if ( (Best != None) && (P.FindPathToward(Best, false) != None) )
	{
		WWclass = class<WillowWhisp>(DynamicLoadObject(PathWhisps[TeamNum], class'Class'));
		Spawn(WWclass, P,, P.Pawn.Location);
	}
}

function RestartPlayer( Controller aPlayer )
{
	local TeamInfo BotTeam, OtherTeam;

	if ( (!bPlayersVsBots || (Level.NetMode == NM_Standalone)) && bBalanceTeams && (Bot(aPlayer) != None) && (!bCustomBots || (Level.NetMode != NM_Standalone)) )
	{
		BotTeam = aPlayer.PlayerReplicationInfo.Team;
		if ( BotTeam == Teams[0] )
			OtherTeam = Teams[1];
		else
			OtherTeam = Teams[0];

		if ( OtherTeam.Size < BotTeam.Size - 1 )
		{
			aPlayer.Destroy();
			return;
		}
	}
	Super.RestartPlayer(aPlayer);
}

/* For TeamGame, tell teams about kills rather than each individual bot
*/
function NotifyKilled(Controller Killer, Controller Killed, Pawn KilledPawn)
{
	Teams[0].AI.NotifyKilled(Killer,Killed,KilledPawn);
	Teams[1].AI.NotifyKilled(Killer,Killed,KilledPawn);
}

function IncrementGoalsScored(PlayerReplicationInfo PRI)
{
	PRI.GoalsScored += 1;
	if ( (PRI.GoalsScored == 3) && (UnrealPlayer(PRI.Owner) != None) )
		UnrealPlayer(PRI.Owner).ClientDelayedAnnouncementNamed('HatTrick',30);
}

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	local Controller P;
    local bool bLastMan;

	if ( bOverTime )
	{
		if ( Numbots + NumPlayers == 0 )
			return true;
		bLastMan = true;
		for ( P=Level.ControllerList; P!=None; P=P.nextController )
			if ( (P.PlayerReplicationInfo != None) && !P.PlayerReplicationInfo.bOutOfLives )
			{
				bLastMan = false;
				break;
			}
		if ( bLastMan )
			return true;
	}

    bLastMan = ( Reason ~= "LastMan" );

	if ( !bLastMan && (GameRulesModifiers != None) && !GameRulesModifiers.CheckEndGame(Winner, Reason) )
		return false;

	if ( bTeamScoreRounds )
	{
		if ( Winner != None )
		{
			Winner.Team.Score += 1;
			Winner.Team.NetUpdateTime = Level.TimeSeconds - 1;
		}
	}
	else if ( !bLastMan && (Teams[1].Score == Teams[0].Score) )
	{
		// tie
		if ( !bOverTimeBroadcast )
		{
			StartupStage = 7;
			PlayStartupMessage();
			bOverTimeBroadcast = true;
		}
		return false;
	}
	if ( bLastMan )
		GameReplicationInfo.Winner = Winner.Team;
	else if ( Teams[1].Score > Teams[0].Score )
		GameReplicationInfo.Winner = Teams[1];
	else
		GameReplicationInfo.Winner = Teams[0];

	if ( Winner == None )
	{
		for ( P=Level.ControllerList; P!=None; P=P.nextController )
			if ( (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == GameReplicationInfo.Winner)
				&& ((Winner == None) || (P.PlayerReplicationInfo.Score > Winner.Score)) )
			{
				Winner = P.PlayerReplicationInfo;
			}
	}

	EndTime = Level.TimeSeconds + EndTimeDelay;

	SetEndGameFocus(Winner);
	return true;
}

function SetEndGameFocus(PlayerReplicationInfo Winner)
{
	local Controller P;
	local PlayerController player;

	if ( Winner != None )
		EndGameFocus = Controller(Winner.Owner).Pawn;
	if ( EndGameFocus != None )
		EndGameFocus.bAlwaysRelevant = true;

	for ( P=Level.ControllerList; P!=None; P=P.nextController )
	{
		player = PlayerController(P);
		if ( Player != None )
		{
			if ( !Player.PlayerReplicationInfo.bOnlySpectator )
			PlayWinMessage(Player, (Player.PlayerReplicationInfo.Team == GameReplicationInfo.Winner));
			player.ClientSetBehindView(true);
			if ( EndGameFocus != None )
            {
				Player.ClientSetViewTarget(EndGameFocus);
                Player.SetViewTarget(EndGameFocus);
            }
			player.ClientGameEnded();
			if ( CurrentGameProfile != None )
				CurrentGameProfile.bWonMatch = (Player.PlayerReplicationInfo.Team == GameReplicationInfo.Winner);
		}
		P.GameHasEnded();
	}
}

//-------------------------------------------------------------------------------------
// Level gameplay modification


function bool CanSpectate( PlayerController Viewer, bool bOnlySpectator, actor ViewTarget )
{
	if ( ViewTarget == None )
		return false;
	if ( bOnlySpectator )
	{
		if ( Controller(ViewTarget) != None )
			return ( (Controller(ViewTarget).PlayerReplicationInfo != None)
				&& !Controller(ViewTarget).PlayerReplicationInfo.bOnlySpectator );
		return true;
	}
	if ( Controller(ViewTarget) != None )
		return ( (Controller(ViewTarget).PlayerReplicationInfo != None)
				&& !Controller(ViewTarget).PlayerReplicationInfo.bOnlySpectator
				&& (Controller(ViewTarget).PlayerReplicationInfo.Team == Viewer.PlayerReplicationInfo.Team) );
	return ( (Pawn(ViewTarget) != None) && Pawn(ViewTarget).IsPlayerPawn()
		&& (Pawn(ViewTarget).PlayerReplicationInfo.Team == Viewer.PlayerReplicationInfo.Team) );
}

//------------------------------------------------------------------------------
// Game Querying.
function GetServerDetails( out ServerResponseLine ServerState )
{
	Super.GetServerDetails( ServerState );

	AddServerDetail( ServerState, "BalanceTeams",  bBalanceTeams);
	AddServerDetail( ServerState, "PlayersBalanceTeams",  bPlayersBalanceTeams);
	AddServerDetail( ServerState, "FriendlyFireScale", int(FriendlyFireScale*100) $ "%" );
}

//------------------------------------------------------------------------------
function UnrealTeamInfo GetBotTeam(optional int TeamBots)
{
	local int first, second;

	if ( bPlayersVsBots && (Level.NetMode != NM_Standalone) )
		return Teams[0];

	if ( (Level.NetMode == NM_Standalone) || !bBalanceTeams )
	{
		if ( Teams[0].AllBotsSpawned() )
	    {
			bBalanceTeams = false;
		    if ( !Teams[1].AllBotsSpawned() )
			    return Teams[1];
	    }
	    else if ( Teams[1].AllBotsSpawned() )
	    {
			bBalanceTeams = false;
		    return Teams[0];
		}
	}

	second = 1;

	// always imbalance teams in favor of bot team in single player
	if ( StandalonePlayer != None && StandalonePlayer.PlayerReplicationInfo.Team != None
	     && StandalonePlayer.PlayerReplicationInfo.Team.TeamIndex == 1 )
	{
		first = 1;
		second = 0;
	}
	if ( Teams[first].Size < Teams[second].Size )
		return Teams[first];
	else
		return Teams[second];
}

function UnrealTeamInfo FindTeamFor(Controller C)
{
	if ( Teams[0].BelongsOnTeam(C.Pawn.Class) )
		return Teams[0];
	if ( Teams[1].BelongsOnTeam(C.Pawn.Class) )
		return Teams[1];
	return GetBotTeam();
}

/* Return a picked team number if none was specified
*/
function byte PickTeam(byte num, Controller C)
{
	local UnrealTeamInfo SmallTeam, BigTeam, NewTeam;
	local Controller B;
	local int BigTeamBots, SmallTeamBots;

	if ( bPlayersVsBots && (Level.NetMode != NM_Standalone) )
	{
		if ( PlayerController(C) != None )
			return 1;
		return 0;
	}

	SmallTeam = Teams[0];
	BigTeam = Teams[1];

	if ( SmallTeam.Size > BigTeam.Size )
	{
		SmallTeam = Teams[1];
		BigTeam = Teams[0];
	}

	if ( num < 2 )
		NewTeam = Teams[num];

	if ( NewTeam == None )
		NewTeam = SmallTeam;
	else if ( bPlayersBalanceTeams && (Level.NetMode != NM_Standalone) && (PlayerController(C) != None) )
	{
		if ( SmallTeam.Size < BigTeam.Size )
			NewTeam = SmallTeam;
		else
		{
			// count number of bots on each team
			for ( B=Level.ControllerList; B!=None; B=B.NextController )
			{
				if ( (B.PlayerReplicationInfo != None) && B.PlayerReplicationInfo.bBot )
				{
					if ( B.PlayerReplicationInfo.Team == BigTeam )
						BigTeamBots++;
					else if ( B.PlayerReplicationInfo.Team == SmallTeam )
						SmallTeamBots++;
				}
			}

			if ( BigTeamBots > 0 )
			{
				// balance the number of players on each team
				if ( SmallTeam.Size - SmallTeamBots < BigTeam.Size - BigTeamBots )
					NewTeam = SmallTeam;
				else if ( BigTeam.Size - BigTeamBots < SmallTeam.Size - SmallTeamBots )
					NewTeam = BigTeam;
				else if ( SmallTeamBots == 0 )
					NewTeam = BigTeam;
			}
			else if ( SmallTeamBots > 0 )
				NewTeam = SmallTeam;
			else if ( UnrealTeamInfo(C.PlayerReplicationInfo.Team) != None )
				NewTeam = UnrealTeamInfo(C.PlayerReplicationInfo.Team);
		}
	}

	return NewTeam.TeamIndex;
}

/* ChangeTeam()
*/
function bool ChangeTeam(Controller Other, int num, bool bNewTeam)
{
	local UnrealTeamInfo NewTeam;

	if ( bMustJoinBeforeStart && GameReplicationInfo.bMatchHasBegun )
		return false;	// only allow team changes before match starts

	if (CurrentGameProfile != none)
	{
		if (!CurrentGameProfile.CanChangeTeam(Other, num)) return false;
	}

	if ( Other.IsA('PlayerController') && Other.PlayerReplicationInfo.bOnlySpectator )
	{
		Other.PlayerReplicationInfo.Team = None;
		return true;
	}

	NewTeam = Teams[PickTeam(num,Other)];

	// check if already on this team
	if ( Other.PlayerReplicationInfo.Team == NewTeam )
		return false;

	Other.StartSpot = None;

	if ( Other.PlayerReplicationInfo.Team != None )
		Other.PlayerReplicationInfo.Team.RemoveFromTeam(Other);

	if ( NewTeam.AddToTeam(Other) )
	{
		BroadcastLocalizedMessage( GameMessageClass, 3, Other.PlayerReplicationInfo, None, NewTeam );

		if ( bNewTeam && PlayerController(Other)!=None )
			GameEvent("TeamChange",""$num,Other.PlayerReplicationInfo);
	}
	return true;
}

/* Rate whether player should choose this NavigationPoint as its start
*/
function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
	local PlayerStart P;

	P = PlayerStart(N);
	if ( P == None )
		return -10000000;
	if ( bSpawnInTeamArea && (Team != P.TeamNumber) )
		return -9000000;

	return Super.RatePlayerStart(N,Team,Player);
}

/* CheckScore()
see if this score means the game ends
*/
function CheckScore(PlayerReplicationInfo Scorer)
{
	if ( CheckMaxLives(Scorer) )
		return;

    if ( (GameRulesModifiers != None) && GameRulesModifiers.CheckScore(Scorer) )
		return;

    if (  !bOverTime && (GoalScore == 0) )
		return;
    if ( (Scorer != None) && (Scorer.Team != None) && (Scorer.Team.Score >= GoalScore) )
		EndGame(Scorer,"teamscorelimit");

    if ( (Scorer != None) && bOverTime )
		EndGame(Scorer,"timelimit");
}

function bool CriticalPlayer(Controller Other)
{
	if ( (GameRulesModifiers != None) && (GameRulesModifiers.CriticalPlayer(Other)) )
		return true;
	if ( (Other.PlayerReplicationInfo != None) && (Other.PlayerReplicationInfo.HasFlag != None) )
		return true;

	return false;
}

// ==========================================================================
// FindVictimsTarget - Tries to determine who the victim was aiming at
// ==========================================================================

function Pawn FindVictimsTarget(Controller Other)
{

	local Vector Start,X,Y,Z;
	local float Dist,Aim;
	local Actor Target;

	if (Other==None || Other.Pawn==None || Other.Pawn.Weapon==None)	// If they have no weapon, they can't be targetting someone
		return None;

	GetAxes(Other.Pawn.GetViewRotation(),X,Y,Z);
	Start = Other.Pawn.Location + Other.Pawn.CalcDrawOffset(Other.Pawn.Weapon);
	Aim = 0.97;
	Target = Other.PickTarget(aim,dist,X,Start,4000.f); //amb

	return Pawn(Target);

}

function bool NearGoal(Controller C)
{
	return false;
}

function ScoreKill(Controller Killer, Controller Other)
{
	local Pawn Target;

	if ( !Other.bIsPlayer || ((Killer != None) && !Killer.bIsPlayer) )
	{
		Super.ScoreKill(Killer, Other);
		if ( !bScoreTeamKills && (Killer != None) && Killer.bIsPlayer && (MaxLives > 0) )
			CheckScore(Killer.PlayerReplicationInfo);
		return;
	}

	if ( (Killer == None) || (Killer == Other)
		|| (Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team) )
	{
		if ( (Killer!=None) && (Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team) )
		{
			if ( Other.PlayerReplicationInfo.HasFlag != None )
			{
				Killer.AwardAdrenaline(ADR_MajorKill);
				GameObject(Other.PlayerReplicationInfo.HasFlag).bLastSecondSave = NearGoal(Other);
			}

			// Kill Bonuses work as follows (in additional to the default 1 point
			//	+1 Point for killing an enemy targetting an important player on your team
			//	+2 Points for killing an enemy important player

			if ( CriticalPlayer(Other) )
			{
				Killer.PlayerReplicationInfo.Score+= 2;
				Killer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
				ScoreEvent(Killer.PlayerReplicationInfo,1,"critical_frag");
			}

			if (bScoreVictimsTarget)
			{
				Target = FindVictimsTarget(Other);
				if ( (Target!=None) && (Target.PlayerReplicationInfo!=None) &&
				       (Target.PlayerReplicationInfo.Team == Killer.PlayerReplicationInfo.Team) && CriticalPlayer(Target.Controller) )
				{
					Killer.PlayerReplicationInfo.Score+=1;
					Killer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
					ScoreEvent(Killer.PlayerReplicationInfo,1,"team_protect_frag");
				}
			}

		}
		Super.ScoreKill(Killer, Other);
	}
	else if ( GameRulesModifiers != None )
		GameRulesModifiers.ScoreKill(Killer, Other);

	if ( !bScoreTeamKills )
	{
		if ( Other.bIsPlayer && (Killer != None) && Killer.bIsPlayer && (Killer != Other)
			&& (Killer.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team) )
		{
			Killer.PlayerReplicationInfo.Score -= 1;
			Killer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
			ScoreEvent(Killer.PlayerReplicationInfo, -1, "team_frag");
		}
		if ( MaxLives > 0 )
			CheckScore(Killer.PlayerReplicationInfo);
		return;
	}
	if ( Other.bIsPlayer )
	{
		if ( (Killer == None) || (Killer == Other) )
		{
			Other.PlayerReplicationInfo.Team.Score -= 1;
			Other.PlayerReplicationInfo.Team.NetUpdateTime = Level.TimeSeconds - 1;
			TeamScoreEvent(Killer.PlayerReplicationInfo.Team.TeamIndex, 1, "team_frag");
		}
		else if ( Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team )
		{
			Killer.PlayerReplicationInfo.Team.Score += 1;
			Killer.PlayerReplicationInfo.Team.NetUpdateTime = Level.TimeSeconds - 1;
			TeamScoreEvent(Killer.PlayerReplicationInfo.Team.TeamIndex, 1, "tdm_frag");
		}
		else if ( FriendlyFireScale > 0 )
		{
			Killer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
			Killer.PlayerReplicationInfo.Score -= 1;
			Killer.PlayerReplicationInfo.Team.Score -= 1;
			Killer.PlayerReplicationInfo.Team.NetUpdateTime = Level.TimeSeconds - 1;
			TeamScoreEvent(Killer.PlayerReplicationInfo.Team.TeamIndex, 1, "team_frag");
		}
	}

	// check score again to see if team won
    if ( (Killer != None) && bScoreTeamKills )
		CheckScore(Killer.PlayerReplicationInfo);
}

function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
	local int InjuredTeam, InstigatorTeam;
	local controller InstigatorController;

	if ( InstigatedBy != None )
		InstigatorController = InstigatedBy.Controller;

	if ( InstigatorController == None )
	{
		if ( DamageType.default.bDelayedDamage )
			InstigatorController = injured.DelayedDamageInstigatorController;
		if ( InstigatorController == None )
			return Super.ReduceDamage( Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );
	}

	InjuredTeam = Injured.GetTeamNum();
	InstigatorTeam = InstigatorController.GetTeamNum();
	if ( InstigatorController != injured.Controller )
	{
		if ( (InjuredTeam != 255) && (InstigatorTeam != 255) )
		{
			if ( InjuredTeam == InstigatorTeam )
			{
				if ( class<WeaponDamageType>(DamageType) != None || class<VehicleDamageType>(DamageType) != None )
					Momentum *= TeammateBoost;
				if ( (Bot(injured.Controller) != None) && (InstigatorController.Pawn != None) )
					Bot(Injured.Controller).YellAt(InstigatorController.Pawn);
				else if ( (PlayerController(Injured.Controller) != None)
						&& Injured.Controller.AutoTaunt() )
					Injured.Controller.SendMessage(InstigatorController.PlayerReplicationInfo, 'FRIENDLYFIRE', Rand(3), 5, 'TEAM');

				if ( FriendlyFireScale==0.0 || (Vehicle(injured) != None && Vehicle(injured).bNoFriendlyFire) )
				{
					if ( GameRulesModifiers != None )
						return GameRulesModifiers.NetDamage( Damage, 0,injured,instigatedBy,HitLocation,Momentum,DamageType );
					else
						return 0;
				}
				Damage *= FriendlyFireScale;
			}
			else if ( !injured.IsHumanControlled() && (injured.Controller != None)
					&& (injured.PlayerReplicationInfo != None) && (injured.PlayerReplicationInfo.HasFlag != None) )
				injured.Controller.SendMessage(None, 'OTHER', injured.Controller.GetMessageIndex('INJURED'), 15, 'TEAM');
		}
	}
	return Super.ReduceDamage( Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );
}

function bool SameTeam(Controller a, Controller b)
{
    if(( a == None ) || ( b == None ))
        return( false );

    return (a.PlayerReplicationInfo.Team.TeamIndex == b.PlayerReplicationInfo.Team.TeamIndex);
}

function bool TooManyBots(Controller botToRemove)
{
	if ( (Level.NetMode != NM_Standalone) && bPlayersVsBots )
		return ( NumBots > Min(16,BotRatio*NumPlayers) );
	if ( (botToRemove.PlayerReplicationInfo != None)
		&& (botToRemove.PlayerReplicationInfo.Team != None) )
	{
		if ( botToRemove.PlayerReplicationInfo.Team == Teams[0] )
		{
			if ( Teams[0].Size < Teams[1].Size )
				return false;
		}
		else if ( Teams[1].Size < Teams[0].Size )
			return false;
	}
    return Super.TooManyBots(botToRemove);
}

function PlayEndOfMatchMessage()
{
	local controller C;

    if ( ((Teams[0].Score == 0) || (Teams[1].Score == 0))
		&& (Teams[0].Score + Teams[1].Score >= 3) )
	{
		for ( C = Level.ControllerList; C != None; C = C.NextController )
		{
			if ( C.IsA('PlayerController') )
			{
				if ( Teams[0].Score > Teams[1].Score )
				{
					if ( (C.PlayerReplicationInfo.Team == Teams[0]) || C.PlayerReplicationInfo.bOnlySpectator )
						PlayerController(C).PlayStatusAnnouncement(AltEndGameSoundName[0],1,true);
					else
						PlayerController(C).PlayStatusAnnouncement(AltEndGameSoundName[1],1,true);
				}
				else
				{
					if ( (C.PlayerReplicationInfo.Team == Teams[1]) || C.PlayerReplicationInfo.bOnlySpectator )
						PlayerController(C).PlayStatusAnnouncement(AltEndGameSoundName[0],1,true);
					else
						PlayerController(C).PlayStatusAnnouncement(AltEndGameSoundName[1],1,true);
				}
			}
		}
	}
    else
    {
		for ( C = Level.ControllerList; C != None; C = C.NextController )
		{
			if ( C.IsA('PlayerController') )
			{
				if (Teams[0].Score > Teams[1].Score)
					PlayerController(C).PlayStatusAnnouncement(EndGameSoundName[0],1,true);
				else
					PlayerController(C).PlayStatusAnnouncement(EndGameSoundName[1],1,true);
			}
		}
	}
}

static function string ParseChatPercVar(Mutator BaseMutator, controller Who, string Cmd)
{
	local float minDist, currDist, currInvDist,BestInvDist;
	local Actor Closest;
	local string near, where, locName;
	local InventorySpot S, BestInv;
	local GameObjective GO;
	local NavigationPoint N;

	if (Who.Pawn==None)
		return Cmd;

	if (cmd~="%H")
		return Who.Pawn.Health$" Health";

	if (cmd~="%W")
	{

		if (Who.Pawn.Weapon!=None)
			return Who.Pawn.Weapon.GetHumanReadableName();
		else if ( Vehicle(Who.Pawn) != None )
			return Vehicle(Who.Pawn).GetVehiclePositionString();
		else
			return Default.BareHanded;
	}

	if (cmd=="%%")
		return "%";

	if (cmd~="%L")
	{
		minDist=10000000.0;
		BestInvDist = 2000;
		// Check for a nearby game objective
		for ( N=Who.Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		{
			S = InventorySpot(N);
			if ( (S != None) && (S.MarkedItem != None) )
			{
				CurrInvDist = vsize(S.location - Who.Pawn.Location);
				if ( CurrInvDist < BestInvDist )
				{
					BestInvDist = CurrInvDist;
					BestInv = S;
				}
			}
			else
			{
				GO = GameObjective(N);
				if ( GO != None )
				{
					currDist = vsize(Go.location - Who.Pawn.Location);
					if(currDist < minDist)
					{
						minDist = currDist;
						Closest = Go;
					}
				}
			}
		}

		// If our closest gameobjective is more than 2048, look for nearby pickup base
		if ( (minDist > 2048) && (BestInvDist < minDist) && (BestInv != None) ) // Look for closer objects
		{
			Closest = BestInv.MarkedItem;
			near = BestInv.MarkedItem.GetHumanReadableName();
		}

		if(Who != None && Who.PlayerReplicationInfo != None)
		{
			locName = "("$Who.PlayerReplicationInfo.GetLocationName()$")";
		}
		if (Closest!=None)
		{
			if (GameObjective(Closest)!=None )
				return Default.NearString@GameObjective(Closest).GetHumanReadableName()@locName;
			else
			{
				where = Who.Level.Game.FindTeamDesignation(PlayerController(Who).GameReplicationInfo, Closest);

				if (Where=="")
					return Default.NearString@Near@locName;
				else
					return Default.NearString@where@near@locName;
			}
		}
	}

	return Super.ParseChatPercVar(BaseMutator, Who,Cmd);
}

static function string FindTeamDesignation(GameReplicationInfo GRI, actor A)
{
	if ( (GRI == None) || (GRI.Teams[0].HomeBase == None) || (GRI.Teams[1].HomeBase == None) )
		return "";

	if (vsize(A.location - GRI.Teams[0].HomeBase.Location) < vsize(A.location - GRI.Teams[1].HomeBase.Location))
		return GRI.Teams[0].GetHumanReadableName()$" ";
	else
		return GRI.Teams[1].GetHumanReadableName()$" ";
}

static function string ParseMessageString(Mutator BaseMutator, Controller Who, String Message)
{
	local string OutMsg;
	local string cmd;
	local int pos,i;

	OutMsg = "";
	pos = InStr(Message,"%");
	while (pos>-1)
	{
		if (pos>0)
		{
		  OutMsg = OutMsg$Left(Message,pos);
		  Message = Mid(Message,pos);
		  pos = 0;
	    }

		i = len(Message);
		cmd = mid(Message,pos,2);
		if (i-2 > 0)
			Message = right(Message,i-2);
		else
			Message = "";

		OutMsg = OutMsg$ParseChatPercVar(BaseMutator, Who,Cmd);
		pos = InStr(Message,"%");
	}

	if (Message!="")
		OutMsg=OutMsg$Message;

	return OutMsg;
}

function FindNewObjectives( GameObjective DisabledObjective )
{
	Teams[0].AI.FindNewObjectives(DisabledObjective);
	Teams[1].AI.FindNewObjectives(DisabledObjective);
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	local int i;

	Super.FillPlayInfo(PlayInfo);  // Always begin with calling parent

	PlayInfo.AddSetting(default.BotsGroup,  "bBalanceTeams",        default.TGPropsDisplayText[i++], 0,   2, "Check");
	PlayInfo.AddSetting(default.RulesGroup, "bPlayersBalanceTeams", default.TGPropsDisplayText[i++], 0,   1, "Check",            ,    ,True);
	PlayInfo.AddSetting(default.GameGroup,  "FriendlyFireScale",    default.TGPropsDisplayText[i++], 20,  1,  "Text", "8;0.0:1.0",    ,    ,True);
	PlayInfo.AddSetting(default.ChatGroup,  "bAllowNonTeamChat",	 default.TGPropsDisplayText[i++], 60,  1, "Check",            ,"Xv",True,True);
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "bBalanceTeams":			return default.TGPropDescText[0];
		case "bPlayersBalanceTeams":	return default.TGPropDescText[1];
		case "FriendlyFireScale":		return default.TGPropDescText[2];
		case "bAllowNonTeamChat":		return default.TGPropDescText[3];
	}

	return Super.GetDescriptionText(PropName);
}

static event bool AcceptPlayInfoProperty(string PropertyName)
{
	if ( InStr(PropertyName, "bColoredDMSkins") != -1 )
		return false;

	return Super.AcceptPlayInfoProperty(PropertyName);
}

function AnnounceScore(int ScoringTeam)
{
	local Controller C;
	local name ScoreSound;
	local int OtherTeam;

	if ( ScoringTeam == 1 )
		OtherTeam = 0;
	else
		OtherTeam = 1;

	if ( Teams[ScoringTeam].Score == Teams[OtherTeam].Score + 1 )
		ScoreSound = TakeLeadName[ScoringTeam];
	else if ( Teams[ScoringTeam].Score == Teams[OtherTeam].Score + 2 )
		ScoreSound = IncreaseLeadName[ScoringTeam];
	else
		ScoreSound = CaptureSoundName[ScoringTeam];

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if ( C.IsA('PlayerController') )
			PlayerController(C).PlayStatusAnnouncement(ScoreSound,1,true);
	}
}

function InitVoiceReplicationInfo()
{
	Super.InitVoiceReplicationInfo();
	if ( VoiceReplicationInfo != None && TeamVoiceReplicationInfo(VoiceReplicationInfo) != None )
		TeamVoiceReplicationInfo(VoiceReplicationInfo).bTeamChatOnly = !bAllowNonTeamChat;
}

event PostLogin( PlayerController NewPlayer )
{
	Super.PostLogin( NewPlayer );
	if ( NewPlayer.PlayerReplicationInfo.Team != None )
		GameEvent("TeamChange",""$NewPlayer.PlayerReplicationInfo.Team.TeamIndex,NewPlayer.PlayerReplicationInfo);
}

static function array<string> GetAllLoadHints(optional bool bThisClassOnly)
{
	local int i;
	local array<string> Hints;

	if ( !bThisClassOnly || default.TGHints.Length == 0 )
		Hints = Super.GetAllLoadHints();

	for ( i = 0; i < default.TGHints.Length; i++ )
		Hints[Hints.Length] = default.TGHints[i];

	return Hints;
}

function WeakObjectives()
{
	local GameObjective GO;

	for ( GO=Teams[0].AI.Objectives; GO!=None; GO=GO.NextObjective )
		if ( GO.IsA('DestroyableObjective') )
			DestroyableObjective(GO).Health = 1;
}

function bool PickEndGameTauntFor(Bot B)
{
	if ( Level.TimeSeconds - LastEndGameTauntTime < 1.5 )
		return false;

	if ( B.PlayerReplicationInfo.Team == None )
		return false;

	if ( B.PlayerReplicationInfo.Team != GameReplicationInfo.Winner )
		EndGameCommentFor(B);
	else
		EndGameTauntFor(B);
	LastEndGameTauntTime = Level.TimeSeconds;
	return true;
}

// what losers say
function EndGameCommentFor(Bot B)
{
	local Controller C,Best;
	local String S;

	if ( FRand() < 0.4 )
	{
		LastEndGameRemark = Rand(10);
		if ( EndGameRemark[LastEndGameRemark] == 0 )
		{
			S = EndGameLossRemarks[LastEndGameRemark];
            LastEndGameComment = -1;
			EndGameRemark[LastEndGameRemark] = 1;
			if ( LastEndGameRemark == 0 )
			{
				for ( C=Level.ControllerList; C!=None; C=C.NextController )
				{
					if ( (PlayerController(C) != None)
						&& ((Best == None) || (C.PlayerReplicationInfo.Score > Best.PlayerReplicationInfo.Score)) )
						Best = C;
				}
				if ( Best == None )
					return;
				S = Best.PlayerReplicationInfo.PlayerName@S;
			}
		}
		else
			return;
	}
	else
	{
		if ( LastEndGameComment == -1 )
		{
			LastEndGameComment = 10;
			S = EndGameResponses[Rand(10)];
		}
		else
		{
			LastEndGameComment = Rand(10);
			if ( EndGameCommented[LastEndGameComment] == 0 )
			{
				EndGameCommented[LastEndGameComment] = 1;
				S = EndGameComments[LastEndGameComment];
			}
			else
				return;
		}
	}
	Broadcast(B, S, 'Say');
}

// what winners say
function EndGameTauntFor(Bot B)
{
	local String S;

	if ( FRand() < 0.4 )
	{
		LastEndGameRemark = Rand(10);
		if ( EndGameRemark[LastEndGameRemark] == 0 )
		{
			S = EndGameVictoryRemarks[LastEndGameRemark];
            LastEndGameComment = -1;
			EndGameRemark[LastEndGameRemark] = 1;
		}
		else
			return;
	}
	else
	{
		if ( LastEndGameComment == -1 )
		{
			LastEndGameComment = 10;
			S = EndGameResponses[Rand(10)];
		}
		else
		{
			LastEndGameComment = Rand(10);
			if ( EndGameCommented[LastEndGameComment] == 0 )
			{
				EndGameCommented[LastEndGameComment] = 1;
				S = EndGameTaunts[LastEndGameComment];
			}
			else
				return;
		}
	}
	Broadcast(B, S, 'Say');
}

defaultproperties
{
     bBalanceTeams=True
     bPlayersBalanceTeams=True
     bScoreTeamKills=True
     MaxTeamSize=32
     TeammateBoost=0.300000
     TeamAIType(0)=Class'UnrealGame.TeamAI'
     TeamAIType(1)=Class'UnrealGame.TeamAI'
     PathWhisps(0)="XEffects.RedWhisp"
     PathWhisps(1)="XEffects.BlueWhisp"
     NearString="Near the"
     BareHanded="Bare Handed"
     CaptureSoundName(0)="Red_Team_Scores"
     CaptureSoundName(1)="Blue_Team_Scores"
     TakeLeadName(0)="Red_Team_takes_the_lead"
     TakeLeadName(1)="Blue_Team_takes_the_lead"
     IncreaseLeadName(0)="Red_Team_increases_their_lead"
     IncreaseLeadName(1)="Blue_Team_increases_their_lead"
     TGPropsDisplayText(0)="Bots Balance Teams"
     TGPropsDisplayText(1)="Players Balance Teams"
     TGPropsDisplayText(2)="Friendly Fire Scale"
     TGPropsDisplayText(3)="Cross-Team Priv. Chat"
     TGPropsDisplayText(4)="Max Team Size"
     TGPropDescText(0)="Bots will join or change teams to make sure they are even."
     TGPropDescText(1)="Players are forced to join the smaller team when they enter."
     TGPropDescText(2)="Specifies how much damage players from the same team can do to each other."
     TGPropDescText(3)="Determines whether members of opposing teams are allowed to join the same private chat room"
     TGPropDescText(4)="Maximum number of players on each team"
     TGHints(0)="If you miss a player's chat message, you can use %INGAMECHAT% to display a box of all chat messages you have received."
     TGHints(1)="Use the link gun alt fire beam to link up with link gun carrying teammates.  While linked, the teammate will receive a significant power boost to their link gun."
     TGHints(2)="You can toss your current weapon for a teammate by pressing %THROWWEAPON%."
     TGHints(3)="Teammates who have a link gun equipped will have a green team beacon above their heads instead of the standard yellow beacon."
     TGHints(4)="Press %VOICETALK% to voice chat with your team."
     TGHints(5)="Press %TEAMTALK% and type your message to send text messages to other team members."
     TGHints(6)="The text-to-speech feature that makes the game read text messages aloud can be enabled in the audio settings menu."
     ADR_Goal=25.000000
     ADR_Return=5.000000
     ADR_Control=2.000000
     EndGameComments(0)="lllllllamas"
     EndGameComments(1)="bye"
     EndGameComments(2)="gg"
     EndGameComments(3)="gg"
     EndGameComments(4)="gg everyone"
     EndGameComments(5)="Teams"
     EndGameComments(6)="omg"
     EndGameComments(7)="dammit!"
     EndGameComments(8)="my team sux0rs"
     EndGameComments(9)="gg"
     EndGameTaunts(0)="woot"
     EndGameTaunts(1)="DENIED!"
     EndGameTaunts(2)="gg everyone"
     EndGameTaunts(3)="gg"
     EndGameTaunts(4)="gg"
     EndGameTaunts(5)="PANTS!"
     EndGameTaunts(6)="owned"
     EndGameTaunts(7)="Booyah!"
     EndGameTaunts(8)="W00T!"
     EndGameTaunts(9)="oh yeah!"
     EndGameVictoryRemarks(0)="Take that to the bank, punks!"
     EndGameVictoryRemarks(1)="omg, so owned."
     EndGameVictoryRemarks(2)="Our Victory, Your Defeat"
     EndGameVictoryRemarks(3)="You know, practice might help"
     EndGameVictoryRemarks(4)="You suckas got served…"
     EndGameVictoryRemarks(5)="That was pathetic"
     EndGameVictoryRemarks(6)="Ya mamma!"
     EndGameVictoryRemarks(7)="pwned!"
     EndGameVictoryRemarks(8)="u r teh suk"
     EndGameVictoryRemarks(9)="Humans need better AI"
     EndGameLossRemarks(0)="was using an aimbot"
     EndGameLossRemarks(1)="Take a screenshot, this won’t happen again."
     EndGameLossRemarks(2)="crappy map"
     EndGameLossRemarks(3)="this server sux"
     EndGameLossRemarks(4)="Campers."
     EndGameLossRemarks(5)="Omg wtf wallhacking mofos"
     EndGameLossRemarks(6)="Where's Malcolm when you need him?"
     EndGameLossRemarks(7)="my team sux"
     EndGameLossRemarks(8)="OMG Epic plz fix kthxbye"
     EndGameLossRemarks(9)="Vwvwvwvwvwvwvwvwvwvwvwvzxcjjj"
     EndGameResponses(0)=":)"
     EndGameResponses(1)=";)"
     EndGameResponses(2)="haha"
     EndGameResponses(3)="LOL"
     EndGameResponses(4)="lol"
     EndGameResponses(5)="ROFL"
     EndGameResponses(6)="rofl"
     EndGameResponses(7)="werd"
     EndGameResponses(8)="ahaha"
     EndGameResponses(9)="omg"
     bMustHaveMultiplePlayers=True
     NumRounds=5
     EndMessageWait=3
     EndGameSoundName(0)="red_team_is_the_winner"
     EndGameSoundName(1)="blue_team_is_the_winner"
     SinglePlayerWait=2
     bCanChangeSkin=False
     bTeamGame=True
     ScoreBoardType="XInterface.ScoreBoardTeamDeathMatch"
     BeaconName="Team"
     GoalScore=60
     VoiceReplicationInfoClass=Class'UnrealGame.TeamVoiceReplicationInfo'
     Description="Two teams duke it out in a quest for battlefield supremacy.  The team with the most total frags wins."
}
