//=============================================================================
// ASGameInfo
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class ASGameInfo extends xTeamGame
	config;

// Config
var()	config	int				RoundLimit;			// number of pair of rounds
var				int				MaxRounds;			// converted to actual number of rounds played
var()	config	int				RoundTimeLimit;		// max round duration (in minutes)
var()	config	int				PracticeTimeLimit;	// practice duration (in seconds)

var		config	int				ReinforcementsFreq;			// Reinforcement frequency (seconds, 0 = no reinforcements)
var				int				ReinforcementsValidTime;	// delay while players are allowed to join last reinforcement
var				int				ReinforcementsCount;

var int	SuccessfulAssaultTimeLimit;		// if first attacking team sucessfully attacked, defenders will have to beat that time to win.

const ASPROPNUM = 5;
var localized string	ASPropsDisplayText[ASPROPNUM];
var localized string	ASPropDescText[ASPROPNUM];

var(LoadingHints) private localized array<string> ASHints;

// internal
var		byte		CurrentAttackingTeam;	// Current Attacking team index
var		byte		FirstAttackingTeam;
var		byte		CurrentRound;
var		int			RoundStartTime;
var		bool		bDisableReinforcements;

var	name	NewRoundSound;
var	name	AttackerWinRound[2];
var name	DefenderWinRound[2];
var name	DrawGameSound;

var GameObjective	CurrentObjective, LastDisabledObjective;
var vehicle KeyVehicle;

var Array<PlayerSpawnManager>	SpawnManagers;			// Handling player spawning

var SceneManager				CurrentMatineeScene;	// SP matinee intro cinematic
var ASCinematic_SceneManager	EndCinematic;			// MP outro cinematic

var	bool	bWeakObjectives;	// cheat

enum ERER_Reason
{
	ERER_AttackersWin,
	ERER_AttackersLose,
};

function Reset() {}	// we handle the reset...

/* CheckReady()
If tournament game, make sure that there is a valid game winning criterion
*/
function CheckReady() {}

function bool DivertSpaceFighter()
{
/*	local float R;

	R = RoundStartTime - RemainingTime;
	if ( R < 100 )
		return ( FRand() < 0.5 );
	else if ( R > 240 )
		return ( FRand() < 0.25 );
*/
	return ( FRand() < 0.4 );
}

function bool AllowTransloc() {	return false; }

static function bool NeverAllowTransloc()
{
	return true;
}

function TweakSkill(Bot B)
{
	if ( Level.NetMode != NM_Standalone )
		return;

	if ( (B.Pawn != None) && B.Pawn.IsA('ASVehicle_SpaceFighter_Skaarj') )
		B.Skill = AdjustedDifficulty;
	else if ( Level.GetLocalPlayerController().PlayerReplicationInfo.Team != B.PlayerReplicationInfo.Team );
		B.Skill = FMax(B.Skill, AdjustedDifficulty + 1.5);
}

function PostBeginPlay()
{
	local GameObjective			GO;
	local PlayerSpawnManager	PSM;

	super.PostBeginPlay();

	// Caching PlayerSpawnManagers
	ForEach AllActors(class'PlayerSpawnManager', PSM)
		SpawnManagers[SpawnManagers.Length] = PSM;

	// Force objective DefenderTeamIndex
	for ( GO=Teams[0].AI.Objectives; GO!=None; GO=GO.NextObjective )
	{
		GO.DefenderTeamIndex = 1 - CurrentAttackingTeam;
		GO.NetUpdateTime = Level.TimeSeconds - 1;
	}

	ForEach AllActors(class'ASCinematic_SceneManager', EndCinematic, 'OutroScene')
		break;
}

//
// Log a player in.
// Fails login if you set the Error string.
// PreLogin is called before Login, but significant game time may pass before
// Login is called, especially if content is downloaded.
//
event PlayerController Login
(
    string Portal,
    string Options,
    out string Error
)
{
	local	PlayerController	PC;
	local	bool				bSpectator;

	PC = super.Login( Portal, Options, Error );
	if ( PC != None )
	{

		if ( Level.NetMode == NM_StandAlone )
		{
			bSpectator = ( ParseOption( Options, "SpectatorOnly" ) ~= "1" );
			CurrentRound = 1;							// No PracticeRound offline
			if ( !bQuickStart && !bSpectator && !PC.PlayerReplicationInfo.bOnlySpectator )
				TriggerEvent('IntroScene', Self, None);		// try to play Matinee intro
		}
	}

	return PC;
}

// Parse options for this game...
event InitGame( string Options, out string Error )
{
	super.InitGame( Options, Error );

	RoundTimeLimit		= Max( 0, GetIntOption( Options, "RoundTimeLimit", RoundTimeLimit ) );
	PracticeTimeLimit	= Max( 0, GetIntOption( Options, "PracticeTimeLimit", PracticeTimeLimit ) );

	RoundLimit	= Max( 0, GetIntOption( Options, "RoundLimit", RoundLimit ) );
	MaxRounds	= RoundLimit * 2; // number of rounds played

	FirstAttackingTeam	= Max(0, GetIntOption( Options, "FirstAttackingTeam", FirstAttackingTeam ));
	ResetTimeDelay		= Max(0, GetIntOption( Options, "ResetTimeDelay", ResetTimeDelay ));
	ReinforcementsFreq	= Max(0, GetIntOption( Options, "ReinforcementsFreq", ReinforcementsFreq ));

	// Disable TimeLimit
	TimeLimit		= 0;
	RemainingTime	= (RoundTimeLimit + ResetTimeDelay + 1) * 60 * (MaxRounds + 2) + PracticeTimeLimit;
	if ( GameReplicationInfo != None )
		GameReplicationInfo.RemainingTime = RemainingTime;
}

function StartMatch()
{
	super.StartMatch();

	// If just played intro, reset everything
	if ( CurrentRound == 0 && Level.NetMode == NM_StandAlone )
		StartNewRound();
	else
		BeginRound();
}

function InitGameReplicationInfo()
{
    super.InitGameReplicationInfo();
	ASGameReplicationInfo(GameReplicationInfo).MaxRounds = RoundLimit * 2;
}

function Logout(Controller Exiting)
{
	if ( Exiting.PlayerReplicationInfo.HasFlag != None )
		GameObjectDropped( Exiting.PlayerReplicationInfo.HasFlag );

	super.Logout(Exiting);
}

function DiscardInventory( Pawn Other )
{
	if ( Other == None )
		return;

	if ( (Other.PlayerReplicationInfo != None) && (Other.PlayerReplicationInfo.HasFlag != None) )
		GameObjectDropped( Other.PlayerReplicationInfo.HasFlag );

	super.DiscardInventory(Other);
}

function GameObjectDropped( Decoration D )
{
	if ( D.IsA('GameObject_EnergyCore') )
		GameObject_EnergyCore(D).HolderDied();
	else
		D.Drop( vect(0,0,0) );
}

function BroadCast_AssaultRole_Message( PlayerController C )
{
	if ( !GameReplicationInfo.bMatchHasBegun || !IsPlaying() || bGameEnded || bWaitingToStartMatch )
		return;

	if ( IsAttackingTeam( C.GetTeamNum() ) )
		C.ReceiveLocalizedMessage( class'Message_AssaultTeamRole', 0, C.PlayerReplicationInfo );
	else
		C.ReceiveLocalizedMessage( class'Message_AssaultTeamRole', 1, C.PlayerReplicationInfo );
}

State MatchInProgress
{
	function Timer()
	{
		local Controller		C;
		local PlayerController	PC;
		local GameObjective		GO;

        super.Timer();

		if ( !bDisableReinforcements && ResetCountDown == 0 && ReinforcementsFreq > 0 )
		{
			ReinforcementsCount++;
			if ( ReinforcementsCount > ReinforcementsFreq+ReinforcementsValidTime )
			{
				ReinforcementsCount = 0;
				ASGameReplicationInfo(GameReplicationInfo).ReinforcementCountDown = ReinforcementsFreq;
			}
			else if ( ReinforcementsCount >= ReinforcementsFreq )
			{
				ASGameReplicationInfo(GameReplicationInfo).ReinforcementCountDown = 0;

				// Auto respawn "ready" players
				for ( C=Level.ControllerList; C!=None; C=C.NextController )
				{
					PC = PlayerController(C);
					if ( PC != None && PC.IsDead()
						&& ASPlayerReplicationInfo(PC.PlayerReplicationInfo).bAutoRespawn )
					{
						RestartPlayer( PC );
						ASPlayerReplicationInfo(PC.PlayerReplicationInfo).bAutoRespawn = false;
					}
				}
			}
		}

		// If TimeLimit is disabled, keep timing (but ignore TimeLimit criteria to end game)
        if ( TimeLimit < 1 )
        {
            GameReplicationInfo.bStopCountDown = false;
            RemainingTime--;
        }

		GameReplicationInfo.RemainingTime = RemainingTime;

		// Force all players to re-synch time every 10 seconds
		if ( RemainingTime % 60 == 0 )
			GameReplicationInfo.RemainingMinute = RemainingTime;

		if ( ResetCountDown > 0 )
        {
            ResetCountDown--;
            if ( ResetCountDown < 3 )
            {
				// blow up all redeemer guided warheads
				for ( C=Level.ControllerList; C!=None; C=C.NextController )
					if ( (C.Pawn != None) && C.Pawn.IsA('RedeemerWarhead') )
						C.Pawn.Fire(1);
			}

			if ( (ResetCountDown > 0) && (ResetCountDown < 10) )
			{
				BroadcastLocalizedMessage(class'TimerMessage', ResetCountDown);
				if ( ResetCountDown == 1 )
				{
					// pre-reset objectives, so they are properly setup when players respawn in network... (for replication)
					ASGameReplicationInfo(GameReplicationInfo).ObjectiveProgress	= 0;
					GameReplicationInfo.NetUpdateTime = Level.TimeSeconds;
					for ( GO=Teams[0].AI.Objectives; GO!=None; GO=GO.NextObjective )
					{
						GO.Reset();
						GO.NetUpdateTime = Level.TimeSeconds - 1;
					}
				}

			}
            else if ( ResetCountDown == 0 )
				StartNewRound();
		}
		else
		{
			if ( ASGameReplicationInfo(GameReplicationInfo).RoundTimeLimit > 0 && ((RoundStartTime-RemainingTime) >= ASGameReplicationInfo(GameReplicationInfo).RoundTimeLimit)  )
			{
				if ( IsPracticeRound() )
					EndRound(ERER_AttackersLose, None, "practicetimelimit"); // Start new round
				else
					EndRound(ERER_AttackersLose, None, "roundtimelimit"); // Start new round
			}
		}

	}

	function float SpawnWait(AIController B)
	{
		if ( B.IsA('xBot') && GameReplicationInfo.bMatchHasBegun && ResetCountDown == 0 && !bDisableReinforcements )
		{
			if ( ReinforcementsCount >= ReinforcementsFreq )
				return (ReinforcementsValidTime - (ReinforcementsCount - ReinforcementsFreq)) * FRand();
			else
				return (ReinforcementsFreq - ReinforcementsCount) + ReinforcementsValidTime * FRand();
		}
		else
			return super.SpawnWait( B );
	}

	// Player Can be restarted ?
  	function bool PlayerCanRestart( PlayerController aPlayer )
  	{
  		if ( GameReplicationInfo.bMatchHasBegun && ResetCountDown == 0 && !bDisableReinforcements )
  		{
  			if ( ReinforcementsCount < ReinforcementsFreq )
			{
				ASPlayerReplicationInfo(aPlayer.PlayerReplicationInfo).bAutoRespawn = true;
  				return false;
			}
  			else
  				return true;
  		}
  		else
  			return true;
  	}

	function bool PlayerCanRestartGame( PlayerController aPlayer )
	{
		return false;
	}

	function bool IsPlaying()
	{
		return ASGameReplicationInfo(GameReplicationInfo).RoundWinner == ERW_None && ResetCountDown == 0;
	}
}

State MatchOver
{
	function EndRound(ERER_Reason RoundEndReason, Pawn Instigator, String Reason) {}
}

/* cinematic started... */
event SceneStarted( SceneManager SM, Actor Other )
{
	if ( Other != None && Other.IsA('ASCinematic_SceneManager') )
	{
		// just use same event notifications as matinee.. no point in having 12000 different events..
		if ( Other == EndCinematic )
			GotoState('MPOutroCinematic');

		return;
	}

	CurrentMatineeScene = SM;
	if ( SM.Tag == 'IntroScene' )
		GotoState('SPIntroCinematic');
}

/* Matinee intro cinematic */
state SPIntroCinematic
{
	function BeginState()
	{
		Level.GetLocalPlayerController().bHideVehicleNoEntryIndicator = true;
		CurrentRound = 0;
		TriggerEvent('StartRound', Self, None);
	}

	event SceneStarted( SceneManager SM, Actor Other )
	{
		HighlightCurrentPhysicalObjectives();
		CurrentMatineeScene = SM;
	}

	function bool IsPlayingIntro()
	{
		return true;
	}

	function bool CanDisableObjective( GameObjective GO )
	{
		return true;
	}

	event SceneEnded( SceneManager SM, Actor Other )
	{
		// is Cinematic over ?
		if ( SM.NextSceneTag == '' || SM.NextSceneTag == 'None' || SM.bAbortCinematic )
			GotoState('MatchInProgress');
	}

	event SceneAbort()
	{
		local PlayerController PC;

		PC = Level.GetLocalPlayerController();
		if ( PC != None )
			PC.ConsoleCommand("stopsounds");

		CurrentMatineeScene.AbortScene();
	}

	function EndRound(ERER_Reason RoundEndReason, Pawn Instigator, String Reason);

	function EndState()
	{
		local PlayerController PC;

		PC = Level.GetLocalPlayerController();

		PC.bHideVehicleNoEntryIndicator = false;
		// When cinematic is over, force player to press fire before starting match
		if ( PC != None && PC.PlayerReplicationInfo != None )
			PC.GotoState('PlayerWaiting');

		GotoState('PendingMatch');
	}
}

auto State PendingMatch
{
	function EndRound(ERER_Reason RoundEndReason, Pawn Instigator, String Reason);

Begin:
	if ( bQuickStart )
		StartMatch();
}

/* network friendly outro */
state MPOutroCinematic
{
	event SceneEnded( SceneManager SM, Actor Other )
	{
		GotoState('MatchInProgress');
	}

	function BeginState()
	{
		local Controller		C, NextC;
		local PlayerController	PC;

		C = Level.ControllerList;

		// Set all players to RoundEnded state...
		while ( C != None  )
		{
			NextC = C.NextController;
			if ( C.PlayerReplicationInfo != None && !C.PlayerReplicationInfo.bOnlySpectator )
			{
				PC = PlayerController(C);
				if ( PC != None )
					PC.ClientRoundEnded();
				C.RoundHasEnded();
			}
			C = NextC;
		}
	}

	function bool PlayerCanRestartGame( PlayerController aPlayer )
	{
		return false;
	}

	function EndState()
	{
		// if RoundLimit reached, END GAME
		if ( CurrentRound >= MaxRounds )
		{
			// need to override DeathMatch::EndGame because it's not supporting Reason="roundlimit"
			super(GameInfo).EndGame(None, "roundlimit");

			if ( bGameEnded )
				GotoState('MatchOver');

			return;
		}

		ResetCountDown = ResetTimeDelay+1;
		QueueAnnouncerSound( NewRoundSound, 1, 255 );
	}
}

/* End of Game */
function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	local PlayerController		PC;
	local Controller			C;

	if ( Teams[1].Score > Teams[0].Score )
		GameReplicationInfo.Winner = Teams[1];
	else if ( Teams[1].Score < Teams[0].Score )
		GameReplicationInfo.Winner = Teams[0];
	else
		GameReplicationInfo.Winner = None;

	for ( C=Level.ControllerList; C!=None; C=C.nextController )
	{
		PC = PlayerController(C);
		if ( PC != None )
		{
			//if ( !PC.PlayerReplicationInfo.bOnlySpectator )
			//	PlayWinMessage(PC, (PC.PlayerReplicationInfo.Team == GameReplicationInfo.Winner));
			if ( CurrentGameProfile != None )
				CurrentGameProfile.bWonMatch = (PC.PlayerReplicationInfo.Team == GameReplicationInfo.Winner);
		}
	}

	EndTime = Level.TimeSeconds + EndTimeDelay;
	return true;
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
						PlayerController(C).QueueAnnouncement(AltEndGameSoundName[0], 1);
					else
						PlayerController(C).QueueAnnouncement(AltEndGameSoundName[1], 1);
				}
				else
				{
					if ( (C.PlayerReplicationInfo.Team == Teams[1]) || C.PlayerReplicationInfo.bOnlySpectator )
						PlayerController(C).QueueAnnouncement(AltEndGameSoundName[0], 1);
					else
						PlayerController(C).QueueAnnouncement(AltEndGameSoundName[1], 1);
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
				if ( Teams[1].Score > Teams[0].Score )
					PlayerController(C).QueueAnnouncement(EndGameSoundName[1], 1);	// Blue teams wins
				else if ( Teams[1].Score < Teams[0].Score )
					PlayerController(C).QueueAnnouncement(EndGameSoundName[0], 1);	// Red team wins
				else
					PlayerController(C).QueueAnnouncement(DrawGameSound, 1);	// Draw Game
			}
		}
	}
}


function EndRound(ERER_Reason RoundEndReason, Pawn Instigator, String Reason)
{
	local int					ScoringTeam;
	local PlayerReplicationInfo	PRI;
	local PlayerController		PC;
	local Controller			C, NextC;
	local GameObjective			ObjectiveFocus;
	local bool					bObjectiveHasEndCam, bSuccessfulAttack;

	// Ignore EndRound during reset countdown
	if ( !IsPlaying() || ResetCountDown > 0 )
		return;

	log("ASGameInfo::EndRound - Reason:"@Reason);

	// Find real round end instigator
	if ( RoundEndReason == ERER_AttackersWin && LastDisabledObjective != None && LastDisabledObjective.DisabledBy != None )
		PRI = LastDisabledObjective.DisabledBy;
	else if ( Instigator != None )
		PRI = Instigator.PlayerReplicationInfo;

	ObjectiveFocus = GetCurrentObjective();
	SuccessfulAssaultTimeLimit = 0;

	if ( IsPracticeRound() )
	{
		ASGameReplicationInfo(GameReplicationInfo).RoundWinner = ERW_PracticeRoundEnded;
		ASGameReplicationInfo(GameReplicationInfo).RoundOverTime = ASGameReplicationInfo(GameReplicationInfo).RoundTimeLimit - ASGameReplicationInfo(GameReplicationInfo).RoundStartTime + RemainingTime;
	}
	else
	{
		if ( RoundEndReason == ERER_AttackersWin )
		{
			// Reward player who instigated the win!
			if ( PRI != None && PRI.IsA('ASPlayerReplicationInfo') )
			{
				ASPlayerReplicationInfo(PRI).DisabledFinalObjective++;
				//log("EndRound Trophy given to" @ PRI.Owner.GetHumanReadableName() );
				GameEvent("EndRound_Trophy", "", PRI);
			}

			if ( CurrentRound % 2 == 1 )
				SuccessfulAssaultTimeLimit = RoundStartTime - RemainingTime;

			ScoringTeam = CurrentAttackingTeam;
			bSuccessfulAttack = true;
			GameEvent("AS_attackers_win", ""$ScoringTeam, PRI);

		}
		else
		{
			// If didn't win the round, save progress of current objective
			if ( ObjectiveFocus != None )
			{
				//log("Saving progress of current objective:" @ ObjectiveFocus.Objective_Info_Attacker @ ObjectiveFocus.GetObjectiveProgress() );
				ObjectiveFocus.SavedObjectiveProgress = ObjectiveFocus.GetObjectiveProgress();
				Teams[1-ObjectiveFocus.DefenderTeamIndex].CurrentObjectiveProgress = ObjectiveFocus.SavedObjectiveProgress;
			}
			ScoringTeam = 1 - CurrentAttackingTeam;
			GameEvent("AS_defenders_win", ""$ScoringTeam, PRI);
		}

		AnnounceScore( ScoringTeam );
		if ( CurrentRound % 2 == 0 )	// Every pair of rounds, once both teams have attacked, update teams score.
			SetPairOfRoundWinner();
	}

	TriggerEvent('EndRound', Self, Instigator);

	// Play End of Round cinematic...
	if ( bSuccessfulAttack && EndCinematic != None )
	{
		EndCinematic.Trigger( Self, None );
		return;
	}

	// If failed to attack display current objective, otherwise, display last disabled (=final one)
	if ( ObjectiveFocus == None && LastDisabledObjective != None )
		ObjectiveFocus = LastDisabledObjective;

	if ( ObjectiveFocus != None )
	{
		ObjectiveFocus.bAlwaysRelevant = true;
		if ( ObjectiveFocus.EndCamera != None && ASCinematic_Camera(ObjectiveFocus.EndCamera) != None )
			bObjectiveHasEndCam = true;

		C = Level.ControllerList;
		while ( C != None  )
		{
			NextC = C.NextController;
			if ( C.PlayerReplicationInfo != None && !C.PlayerReplicationInfo.bOnlySpectator )
			{
				PC = PlayerController(C);
				if ( PC != None )
				{
					if ( bObjectiveHasEndCam )	// Objective has a special End Cam setup...
						ASCinematic_Camera(ObjectiveFocus.EndCamera).ViewFixedObjective( PC, ObjectiveFocus );
					else						// Otherwise, just spectate objective in behindview/freecam
					{
						PC.ClientSetViewTarget( ObjectiveFocus );
						PC.SetViewTarget( ObjectiveFocus );
					}
					PC.ClientRoundEnded();
				}
				C.RoundHasEnded();
			}
			C = NextC;
		}
	}
	else
		log("ASGameInfo::EndRound ObjectiveFocus == None !!!!!!!!!");

	// if RoundLimit reached, END GAME
	if ( CurrentRound >= MaxRounds )
	{
		// need to override DeathMatch::EndGame because it's not supporting Reason="roundlimit"
		super(GameInfo).EndGame(None, "roundlimit");

		if ( bGameEnded )
            GotoState('MatchOver');

		return;
	}

	QueueAnnouncerSound( NewRoundSound, 1, 255 );
	ResetCountDown = ResetTimeDelay+1;
}

function PracticeRoundEnded()
{
	local Controller	C;

	// Practice Round Ended, reset scores!
	for ( C = Level.ControllerList; C != None; C = C.NextController )
		if ( C.PlayerReplicationInfo != None )
		{
			C.PlayerReplicationInfo.Kills = 0;
			C.PlayerReplicationInfo.Score	= 0;
			C.PlayerReplicationInfo.Deaths	= 0;

			if ( TeamPlayerReplicationInfo(C.PlayerReplicationInfo) != None )
				TeamPlayerReplicationInfo(C.PlayerReplicationInfo).Suicides = 0;

			if ( ASPlayerReplicationInfo(C.PlayerReplicationInfo) != None )
			{
				ASPlayerReplicationInfo(C.PlayerReplicationInfo).DisabledObjectivesCount = 0;
				ASPlayerReplicationInfo(C.PlayerReplicationInfo).DisabledFinalObjective	= 0;
			}
		}

	bFirstBlood = false;
	Teams[0].Score = 0;
	Teams[1].Score = 0;
	Teams[0].NetUpdateTime = Level.TimeSeconds - 1;
	Teams[1].NetUpdateTime = Level.TimeSeconds - 1;
}

/* Awards points once both teams have attacked, every couple of rounds */
function SetPairOfRoundWinner()
{
	local byte WinningTeam;

	WinningTeam = GetPairOfRoundWinner();
	if ( WinningTeam < 2 )
	{
		Teams[WinningTeam].Score += 1.0;
		Teams[WinningTeam].NetUpdateTime = Level.TimeSeconds - 1;
		TeamScoreEvent(WinningTeam, 1, "pair_of_round_winner");
	}
}

/* Called when both teams have attacked in a row, and returns the winner */
function byte GetPairOfRoundWinner()
{
	// Team who disabled the highest number of objectives
	if ( Teams[0].ObjectivesDisabledCount > Teams[1].ObjectivesDisabledCount )
	{
		ASGameReplicationInfo(GameReplicationInfo).RoundWinner = ERW_RedMoreObjectives;
		return 0;
	}

	if ( Teams[0].ObjectivesDisabledCount < Teams[1].ObjectivesDisabledCount )
	{
		ASGameReplicationInfo(GameReplicationInfo).RoundWinner = ERW_BlueMoreObjectives;
		return 1;
	}

	// If teams completed the same number of objectives, without successfully attacking,
	// winner is the one who got their current objective the closest to completion (when relevant)
	if ( Teams[0].CurrentObjectiveProgress != Teams[1].CurrentObjectiveProgress
		&& Teams[0].CurrentObjectiveProgress > 0.f && Teams[0].CurrentObjectiveProgress < 1.f )
	{
		if ( Teams[0].CurrentObjectiveProgress < Teams[1].CurrentObjectiveProgress )
		{
			ASGameReplicationInfo(GameReplicationInfo).RoundWinner = ERW_RedMoreProgress;
			return 0;
		}
		ASGameReplicationInfo(GameReplicationInfo).RoundWinner = ERW_BlueMoreProgress;
		return 1;
	}

	// Teams disabled the same number of objectives... compare time!
	if ( Teams[0].LastObjectiveTime > Teams[1].LastObjectiveTime )
	{
		ASGameReplicationInfo(GameReplicationInfo).RoundWinner = ERW_BlueGotSameOBJFaster;
		return 1;
	}

	if ( Teams[0].LastObjectiveTime < Teams[1].LastObjectiveTime )
	{
		ASGameReplicationInfo(GameReplicationInfo).RoundWinner = ERW_RedGotSameOBJFaster;
		return 0;
	}

	ASGameReplicationInfo(GameReplicationInfo).RoundWinner = ERW_Draw;
	return 255;
}


function AnnounceScore( int ScoringTeam )
{
	local name			ScoreSound;

	if ( IsAttackingTeam( ScoringTeam ) )
	{
		if ( ScoringTeam == 1 )
			ASGameReplicationInfo(GameReplicationInfo).RoundWinner = ERW_BlueAttacked;
		else
			ASGameReplicationInfo(GameReplicationInfo).RoundWinner = ERW_RedAttacked;
		ScoreSound = AttackerWinRound[ScoringTeam];
	}
	else
	{
		if ( ScoringTeam == 1 )
			ASGameReplicationInfo(GameReplicationInfo).RoundWinner = ERW_BlueDefended;
		else
			ASGameReplicationInfo(GameReplicationInfo).RoundWinner = ERW_RedDefended;
		ScoreSound = DefenderWinRound[ScoringTeam];
	}

	ASGameReplicationInfo(GameReplicationInfo).RoundOverTime = ASGameReplicationInfo(GameReplicationInfo).RoundTimeLimit - ASGameReplicationInfo(GameReplicationInfo).RoundStartTime + RemainingTime;
	QueueAnnouncerSound( ScoreSound, 1, 255 );
}

// directly skip to next round
exec function NewRound()
{
	StartNewRound();
}

// Start new round... reset everything, swap teams...
function StartNewRound()
{
	log("## ASGameInfo::StartNewRound ##");

	CurrentRound++;

	BeginRound();
}

function ResetLevel()
{
	local Controller		C, NextC;
	local Actor				A;

	log("ResetLevel");

	// Force bTeamScoreRounds to avoid having TeamScores reset to 0
	bTeamScoreRounds = true;

	if ( !bDisableReinforcements )
	{
		ASGameReplicationInfo(GameReplicationInfo).ReinforcementCountDown = 0;
		ReinforcementsCount = ReinforcementsFreq;	// Start reinforcements right away
	}

	// Reset ALL controllers first
	C = Level.ControllerList;
	while ( C != None )
	{
		NextC = C.NextController;

		if ( C.PlayerReplicationInfo == None || !C.PlayerReplicationInfo.bOnlySpectator )
		{
			if ( PlayerController(C) != None )
				PlayerController(C).ClientReset();
			C.Reset();
		}

		C = NextC;
	}

	// Reset ALL actors (except controllers)
	foreach AllActors(class'Actor', A)
		if ( !A.IsA('Controller') )
			A.Reset();
}

// Round begins...
function BeginRound()
{
	local Controller		C, NextC;
	local GameObjective	GO;

	log("ASGameInfo::BeginRound");

	// Is Practice Round disabled ?
	if ( IsPracticeRound() && PracticeTimeLimit == 0 && Level.NetMode != NM_StandAlone )
		CurrentRound++;

	if ( IsPracticeRound() )
		PracticeRoundEnded();

	// Set Attacking and Defending teams...
	if ( IsPracticeRound() || CurrentRound % 2 == 1 )
	{
		CurrentAttackingTeam = FirstAttackingTeam;
		BeginNewPairOfRounds();
	}
	else
		CurrentAttackingTeam = 1 - FirstAttackingTeam;

	LastDisabledObjective	= None;
	CurrentObjective		= None;

	ASGameReplicationInfo(GameReplicationInfo).bTeamZeroIsAttacking	= (CurrentAttackingTeam == 0);
	ASGameReplicationInfo(GameReplicationInfo).ObjectiveProgress	= 0;
	ASGameReplicationInfo(GameReplicationInfo).CurrentRound			= CurrentRound;
	ASGameReplicationInfo(GameReplicationInfo).RoundWinner			= ERW_None;
	RoundStartTime													= RemainingTime;	// local round start stamp
	ASGameReplicationInfo(GameReplicationInfo).RoundStartTime		= RemainingTime;	// replicated round start stamp
	GameReplicationInfo.RemainingTime								= RemainingTime;	// for new players joining..
	GameReplicationInfo.RemainingMinute								= RemainingTime;	// re-synch current players
	GameReplicationInfo.NetUpdateTime								= Level.TimeSeconds - 1;

	// Set Round Time Limit
	if ( IsPracticeRound() )
		ASGameReplicationInfo(GameReplicationInfo).RoundTimeLimit = PracticeTimeLimit;			// Practice Round
	else if ( CurrentRound % 2 == 0 && SuccessfulAssaultTimeLimit != 0 )
		ASGameReplicationInfo(GameReplicationInfo).RoundTimeLimit = SuccessfulAssaultTimeLimit;	// First team succeeded => second team must beat this time.
	else
		ASGameReplicationInfo(GameReplicationInfo).RoundTimeLimit = RoundTimeLimit * 60;		// default round time limit

	if ( !bDisableReinforcements )
	{
		ASGameReplicationInfo(GameReplicationInfo).ReinforcementCountDown = 0;
		ReinforcementsCount = ReinforcementsFreq;	// Start reinforcements right away
	}

	ResetLevel();

	// Force objective DefenderTeamIndex
	for ( GO=Teams[0].AI.Objectives; GO!=None; GO=GO.NextObjective )
	{
		GO.DefenderTeamIndex = 1 - CurrentAttackingTeam;
		GO.NetUpdateTime = Level.TimeSeconds - 1;
	}

	if ( bWeakObjectives )
		WeakObjectives();

	HighlightCurrentPhysicalObjectives();

	// re spawn players
	C = Level.ControllerList;
	while ( C != None )
	{
		NextC = C.NextController;

		if ( C.IsA('PlayerController') && C.PlayerReplicationInfo != None && !C.PlayerReplicationInfo.bOnlySpectator )
			RestartPlayer( C );

		C = NextC;
	}

	TriggerEvent('StartRound', Self, None);
	if ( !IsPracticeRound() )
		GameEvent("AS_BeginRound", ""$CurrentRound, None);

	SetGameSpeed( GameSpeed );
}

/* Begin a new pair of rounds (both teams get to attack) */
function BeginNewPairOfRounds()
{
	local GameObjective	GO;

	// Reset Objective tracking to define a pair of round winner
	Teams[0].LastObjectiveTime			= 0;
	Teams[0].ObjectivesDisabledCount	= 0;
	Teams[0].CurrentObjectiveProgress	= 0;
	Teams[1].LastObjectiveTime			= 0;
	Teams[1].ObjectivesDisabledCount	= 0;
	Teams[1].CurrentObjectiveProgress	= 0;

	for ( GO=Teams[0].AI.Objectives; GO!=None; GO=GO.NextObjective )
	{
		GO.ObjectiveDisabledTime	= 0;
		GO.SavedObjectiveProgress	= 0;
	}
}

function bool IsAttackingTeam(int TeamNumber)
{
	return ( TeamNumber == CurrentAttackingTeam );
}

function int GetAttackingTeam()
{
	return CurrentAttackingTeam;
}

function int GetDefenderNum()
{
	return (1 - CurrentAttackingTeam);
}

function GameObjective GetCurrentObjective()
{
	local GameObjective GO;

	// Try to find currently active objective...
	if ( CurrentObjective == None )

		for ( GO=Teams[0].AI.Objectives; GO!=None; GO=GO.NextObjective )
		{
			if ( (ASGameReplicationInfo(GameReplicationInfo).ObjectiveProgress == GO.ObjectivePriority)
				&& GO.IsActive() && ( !GO.bOptionalObjective || CurrentObjective == None ) )
				CurrentObjective = GO;
		}

	return CurrentObjective;
}

function bool IsPlayingIntro()
{
	return false;
}

function bool IsPracticeRound()
{
	return ASGameReplicationInfo(GameReplicationInfo).IsPracticeRound();
}

function bool IsPlaying()
{
	return false;
}

function ScoreObjective( PlayerReplicationInfo Scorer, float Score )
{
	// NOTE: Score awarding hardcoded and moved to ObjectiveDisabled (see below).
	if ( GameRulesModifiers != None )
       GameRulesModifiers.ScoreObjective(Scorer, Score);
}

/* Is objective allowed to be disabled ? */
function bool CanDisableObjective( GameObjective GO )
{
	local ASGameReplicationInfo	ASGRI;

	if ( !IsPlaying() )
		return false;

	if ( GO.bBotOnlyObjective )
		return true;

	ASGRI = ASGamereplicationInfo(GameReplicationInfo);
	if ( GO.ObjectivePriority <= ASGRI.ObjectiveProgress )
		return true;

	return false;
}

function ObjectiveDisabled( GameObjective DisabledObjective )
{
	local int			ForcedScore;
	local int			ObjectiveDisabledTime;
	local Controller	C;

	ObjectiveDisabledTime = RoundStartTime - RemainingTime;
	DisabledObjective.ObjectiveDisabledTime = ObjectiveDisabledTime;
    if ( IsPlaying() && DisabledObjective.DisabledBy != None )
    {
		// Hardcoded score
		if ( DisabledObjective.bOptionalObjective )
			ForcedScore = 5;
		else
			ForcedScore = 10;

		/* AwardAssaultScore can change DisabledBy, to award the Trophy to another player */
		DisabledObjective.AwardAssaultScore( ForcedScore );

		//log("ObjectiveCompleted Trophy given to" @ DisabledObjective.DisabledBy.Owner.GetHumanReadableName() );
		GameEvent("ObjectiveCompleted_Trophy", DisabledObjective.ObjectivePriority @ ObjectiveDisabledTime @ DisabledObjective.Objective_Info_Attacker, DisabledObjective.DisabledBy);
		ASPlayerReplicationInfo(DisabledObjective.DisabledBy).DisabledObjectivesCount++;

		if ( PlayerController(DisabledObjective.DisabledBy.Owner) != None )
		{
			PlayerController(DisabledObjective.DisabledBy.Owner).ReceiveLocalizedMessage(class'Message_Awards', 0);

			for ( C=Level.ControllerList; C!=None; C=C.nextController )
				if ( PlayerController(C) != None && C != DisabledObjective.DisabledBy.Owner )
					PlayerController(C).ReceiveLocalizedMessage(class'Message_Awards', 1, DisabledObjective.DisabledBy);
		}
		//ScoreEvent(DisabledObjective.DisabledBy, ForcedScore, "Objective_Disabled");
    }
	//else if ( DisabledObjective.DisabledBy == None && !IsPlayingIntro() )
	//	log("DisabledObjective.DisabledBy == None" @ DisabledObjective );

	if ( !DisabledObjective.bOptionalObjective )
	{
		Teams[1-DisabledObjective.DefenderTeamIndex].ObjectivesDisabledCount++;
		Teams[1-DisabledObjective.DefenderTeamIndex].LastObjectiveTime = ObjectiveDisabledTime;
	}

	if ( IsPlaying() && DisabledObjective.DisabledBy != None )
	{
		if ( DisabledObjective.Announcer_DisabledObjective == None )
			QueueAnnouncerSound( '', 1, 255 );
		else
			QueueAnnouncerSound( DisabledObjective.Announcer_DisabledObjective.Name, 1, 255 );
	}
	LastDisabledObjective = DisabledObjective;

	super.ObjectiveDisabled( DisabledObjective );
}

function FindNewObjectives(GameObjective DisabledObjective)
{
	if ( !bGameEnded && ResetCountDown < 1 )
		UpdateObjectiveProgression( DisabledObjective ); // Objective has just been disabled, update progress...

	super.FindNewObjectives( DisabledObjective );
}

/*
here we keep track of objective progression through a simple progress index...
This index allows objectives to be shown in order on HUD,
and Briefing screen to show the status of the assault...
*/
function UpdateObjectiveProgression( GameObjective DisabledObjective )
{
	local GameObjective	GO;
	local bool			bIncPriority, bObjPriority;
	local byte			CurrentProgressIndex, BackupProgressIndex;

	CurrentProgressIndex = ASGameReplicationInfo(GameReplicationInfo).ObjectiveProgress;

	BackupProgressIndex = CurrentProgressIndex;
	bIncPriority		= true;

	for ( GO=Teams[0].AI.Objectives; GO!=None; GO=GO.NextObjective )
	{
		// Check objective progression...
		if ( (CurrentProgressIndex == GO.ObjectivePriority) && !GO.bOptionalObjective )
		{
			// Prioritization is relevant, we found at least one objective matching...
			bObjPriority = true;

			if ( GO.IsActive() )
			{
				// There is at least one Objective with current priority left to disable...
				bIncPriority = false;
				break;
			}
		}
	}

	// Objective Prioritization is relevant and all current priority objectives are disabled ?
	// So increase progress index...
	if ( bObjPriority && bIncPriority )
		CurrentProgressIndex++;

	// Update progress...
	if ( CurrentProgressIndex != BackupProgressIndex )
		ASGameReplicationInfo(GameReplicationInfo).ObjectiveProgress++;

	HighlightCurrentPhysicalObjectives();

	// Update Current Objective
	for ( GO=Teams[0].AI.Objectives; GO!=None; GO=GO.NextObjective )
	{
		if ( (ASGameReplicationInfo(GameReplicationInfo).ObjectiveProgress == GO.ObjectivePriority)
			&& !GO.bDisabled && !GO.bOptionalObjective )
		{
			CurrentObjective = GO;

			if ( !DisabledObjective.bAnnounceNextObjective || (CurrentProgressIndex == BackupProgressIndex
				&& GO.Announcer_ObjectiveInfo == DisabledObjective.Announcer_ObjectiveInfo
				&& !DisabledObjective.bOptionalObjective) )
				break;

			// Announce Next Objective...
			if ( IsPlaying() )
				AnnounceNextObjective( GO );
			return;
		}
	}
	if ( CurrentObjective != None && IsPlaying() )
		QueueAnnouncerSound( '', 1, 255,, 200 );
}


function HighlightCurrentPhysicalObjectives()
{
	local GameObjective	GO;

	for ( GO=Teams[0].AI.Objectives; GO!=None; GO=GO.NextObjective )
	{
		if ( (ASGameReplicationInfo(GameReplicationInfo).ObjectiveProgress >= GO.ObjectivePriority) && GO.IsActive() )
			GO.HighlightPhysicalObjective( true );
		else
			GO.HighlightPhysicalObjective( false );
	}
}

function AnnounceNextObjective( GameObjective NewObjective )
{
	if ( !IsPlaying() )
		return;

	// Attackers
	if ( NewObjective.Announcer_ObjectiveInfo == None )
		QueueAnnouncerSound( '', 1, 1 - NewObjective.DefenderTeamIndex, AP_NoDuplicates, 200 );
	else
		QueueAnnouncerSound( NewObjective.Announcer_ObjectiveInfo.Name, 1, 1 - NewObjective.DefenderTeamIndex, AP_NoDuplicates, 200 );

	// Defenders
	if ( NewObjective.Announcer_DefendObjective == None )
		QueueAnnouncerSound( '', 1, NewObjective.DefenderTeamIndex, AP_NoDuplicates, 200 );
	else
		QueueAnnouncerSound( NewObjective.Announcer_DefendObjective.Name, 1, NewObjective.DefenderTeamIndex, AP_NoDuplicates, 200 );
}


function ShowPathTo(PlayerController P, int TeamNum)
{
	local GameObjective			G, Best;
	local class<WillowWhisp>	WWclass;
	local ASGameReplicationInfo	ASGRI;

	ASGRI = ASGamereplicationInfo(GameReplicationInfo);

	Best = GetCurrentObjective();
	if ( Best == None || !Best.IsActive() )
	{
		for ( G=Teams[0].AI.Objectives; G!=None; G=G.NextObjective )
			if ( !G.bOptionalObjective && CheckObjectivePriority( G ) )
			{
				Best = G;
				break;
			}
	}

	if ( Best != None )
	{
		// Spawn Willow Whisp
		if ( P.FindPathToward(Best, false) != None )
		{
			WWclass = class<WillowWhisp>(DynamicLoadObject(PathWhisps[Best.DefenderTeamIndex], class'Class'));
			Spawn(WWclass, P,, P.Pawn.Location);
		}

		if ( TeamNum != 255 && IsPlaying() )
		{
			// Announce objective
			if ( P.GetTeamNum() == 1 - Best.DefenderTeamIndex )
			{
				// Attacker
				if ( Best.Announcer_ObjectiveInfo == None )
					P.QueueAnnouncement( '', 1, AP_NoDuplicates, 201 );
				else
					P.QueueAnnouncement( Best.Announcer_ObjectiveInfo.Name, 1, AP_NoDuplicates, 201 );
			}
			else if ( P.GetTeamNum() == Best.DefenderTeamIndex )
			{
				// Defenders
				if ( Best.Announcer_DefendObjective == None )
					P.QueueAnnouncement( '', 1, AP_NoDuplicates, 201 );
				else
					P.QueueAnnouncement( Best.Announcer_DefendObjective.Name, 1, AP_NoDuplicates, 201 );
			}
			else
				P.QueueAnnouncement( '', 1, AP_NoDuplicates, 201 );
		}
	}
}

/* returns true if Objective is relevant (priority wise) */
function bool	CheckObjectivePriority(GameObjective GO)
{
	local ASGameReplicationInfo	ASGRI;

	ASGRI = ASGamereplicationInfo(GameReplicationInfo);

	if ( ASGRI == None || !GO.IsActive() || GO.bDisabled )
		return false;

	if ( ASGRI.ObjectiveProgress >= GO.ObjectivePriority )
		return true;

	return false;
}


/* new Spawn Area enabled, give the opportunity to that team to teleport there
	Only for currently alive players, of the team who got a new spawn area activated, during 15 seconds */
event NewSpawnAreaEnabled( bool bDefenders )
{
	local Controller		C;
	local PlayerController	PC;

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		PC = PlayerController(C);

		if ( bDefenders && C.GetTeamNum() != GetDefenderNum() )
			continue;

		if ( !bDefenders && C.GetTeamNum() == GetDefenderNum() )
			continue;

		if ( C.IsInState('Dead') || C.Pawn == None || C.Pawn.Health < 1 )
			continue;

		if ( PC != None && (PC.IsDead() || PC.IsSpectating()) )
			continue;

		if ( C.Pawn != None && ASPlayerReplicationInfo(C.PlayerReplicationInfo) != None )
		{
			ASPlayerReplicationInfo(C.PlayerReplicationInfo).bTeleportToSpawnArea = true;
			if ( AIController(C) != None )
				ASPlayerReplicationInfo(C.PlayerReplicationInfo).TeleportTime = Level.TimeSeconds;
			else
				ASPlayerReplicationInfo(C.PlayerReplicationInfo).TeleportTime = ASGameReplicationInfo(GameReplicationInfo).RoundTimeLimit - ASGameReplicationInfo(GameReplicationInfo).RoundStartTime + RemainingTime;

			// NOTE: Bots are forced to teleport in ASPlayerReplicationInfo::Timer()
			// Bots are not teleported instantly because it is very likely that 2 spawn areas exist at the same time
			// (new and old), and bot might be teleported to the old one.
		}
	}
}

/* Teleport Player to new Spawn Location */
event NoTranslocatorKeyPressed( PlayerController PC )
{
	local ASGameReplicationInfo		ASGRI;
	local ASPlayerReplicationInfo	ASPRI;

	if ( PC == None || ASPlayerReplicationInfo(PC.PlayerReplicationInfo) == None )
		return;

	ASPRI = ASPlayerReplicationInfo(PC.PlayerReplicationInfo);
	if ( ASPRI.bTeleportToSpawnArea == false )
		return;

	ASGRI = ASGameReplicationInfo(GameReplicationInfo);
	if ( ASGRI.RoundTimeLimit - ASGRI.RoundStartTime + RemainingTime + ASGRI.MaxTeleportTime < ASPRI.TeleportTime )
		return;

	TeleportPlayerToSpawn( PC );
}

/* Teleport player to current spawn area */
function TeleportPlayerToSpawn( Controller C )
{
	local vector	PrevLocation;

	PrevLocation = C.Pawn.Location;
	ASPlayerReplicationInfo(C.PlayerReplicationInfo).bTeleportToSpawnArea = false;
	RespawnPlayer( C, false );

	if ( C.Pawn.IsA('xPawn') )
		xPawn(C.Pawn).DoTranslocateOut( PrevLocation );
}

function Killed( Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType )
{
	//log("ASGameinfo::Killed Killer:" @ Killer @ "Killed" @ Killed @ "KilledPawn" @ KilledPawn );
	if ( Killed != None && ASPlayerReplicationInfo(Killed.PlayerReplicationInfo) != None )
		ASPlayerReplicationInfo(Killed.PlayerReplicationInfo).bTeleportToSpawnArea = false;

	super.Killed( Killer, Killed, KilledPawn, damageType );
}

function int VehicleScoreKill( Controller Killer, Controller Killed, Vehicle DestroyedVehicle, out string KillInfo )
{
	if ( DestroyedVehicle.bKeyVehicle || DestroyedVehicle.bHighScoreKill )
	{
		if ( Killer == Killed || Killer.GetTeamNum() == DestroyedVehicle.GetTeamNum() )
			return super.VehicleScoreKill( Killer, Killed, DestroyedVehicle, KillInfo );

		// Destroyed vehicles trophys
		if ( ASPlayerReplicationInfo(Killer.PlayerReplicationInfo) != None )
		{
			GameEvent("VehicleDestroyed_Trophy", DestroyedVehicle.VehicleNameString, Killer.PlayerReplicationInfo);
			ASPlayerReplicationInfo(Killer.PlayerReplicationInfo).DestroyedVehicles++;

			// Wrecker! announcer
			if ( PlayerController(Killer) != None && ASPlayerReplicationInfo(Killer.PlayerReplicationInfo).DestroyedVehicles > 2 )
				PlayerController(Killer).ReceiveLocalizedMessage(class'Message_ASKillMessages', 1);
		}
	}

	return super.VehicleScoreKill( Killer, Killed, DestroyedVehicle, KillInfo );
}

function bool CriticalPlayer(Controller Other)
{
	local GameObjective	GO;

	if ( Other.Pawn == None || Other.PlayerReplicationInfo == None || !IsAttackingTeam(Other.GetTeamNum()) )
		return super.CriticalPlayer( Other );

	for ( GO=Teams[0].AI.Objectives; GO!=None; GO=GO.NextObjective )
	{
		if ( !GO.IsActive() || !GO.IsCritical() || (ASGameReplicationInfo(GameReplicationInfo).ObjectiveProgress < GO.ObjectivePriority) )
			continue;

		if ( GO.MyBaseVolume != None && GO.MyBaseVolume.Encompasses( Other.Pawn ) )
			return true;
	}

	return super.CriticalPlayer( Other );
}

function SpecialEvent(PlayerReplicationInfo Who, string Desc)
{
	if ( !IsPracticeRound() )
		super.SpecialEvent( Who, Desc );
}

function KillEvent(string Killtype, PlayerReplicationInfo Killer, PlayerReplicationInfo Victim, class<DamageType> Damage)
{
	if ( !IsPracticeRound() )
		super.KillEvent(KillType, Killer, Victim, Damage);
}

function ScoreEvent(PlayerReplicationInfo Who, float Points, string Desc)
{
	if ( !IsPracticeRound() )
		super.ScoreEvent( Who, Points, Desc);
}

function TeamScoreEvent(int Team, float Points, string Desc)
{
	if ( !IsPracticeRound() )
		super.TeamScoreEvent( Team, Points, Desc);
}

function RestartPlayer( Controller aPlayer )
{
	local String	PawnOverrideClass;

	super.RestartPlayer( aPlayer );

	if ( aPlayer != None && aPlayer.PlayerReplicationInfo != None )
	{
		PawnOverrideClass = ASPlayerReplicationInfo(aPlayer.PlayerReplicationInfo).PawnOverrideClass;
		if ( PawnOverrideClass != "" )
		{
			SpawnAndPossessPawn(aPlayer, PawnOverrideClass);
			ASPlayerReplicationInfo(aPlayer.PlayerReplicationInfo).PawnOverrideClass = "";
		}
	}
	if ( PlayerController(aPlayer) != None )
		BroadCast_AssaultRole_Message( PlayerController(aPlayer) );
}


function RespawnPlayer( Controller C, optional bool bClearSpecials )
{
	local String	PawnOverrideClass;
	local vehicle	DrivenVehicle;

	if ( C.Pawn != None )
	{
		DrivenVehicle = Vehicle(C.Pawn);
		if ( DrivenVehicle != None )
			DrivenVehicle.KDriverLeave( true ); // Force the driver out of the car
	}

	C.StartSpot = FindPlayerStart(C, C.PlayerReplicationInfo.Team.TeamIndex);

	PawnOverrideClass = ASPlayerReplicationInfo(C.PlayerReplicationInfo).PawnOverrideClass;
	if ( PawnOverrideClass != "" )
	{
		SpawnAndPossessPawn(C, PawnOverrideClass);
		ASPlayerReplicationInfo(C.PlayerReplicationInfo).PawnOverrideClass = "";
	}

	if ( C.StartSpot != None )
	{
		C.SetLocation( C.StartSpot.Location );
		C.SetRotation( C.StartSpot.Rotation );
	}

	if ( C.Pawn != None )
	{
		if ( bClearSpecials && xPawn(C.Pawn) != None )
		{
			if (xPawn(C.Pawn).CurrentCombo != None)
			{
				C.Adrenaline = 0;
				xPawn(C.Pawn).CurrentCombo.Destroy();
			}
			if ( xPawn(C.Pawn).UDamageTimer != None )
			{
				xPawn(C.Pawn).UDamageTimer.Destroy();
				xPawn(C.Pawn).DisableUDamage();
			}
		}
		if ( C.Pawn.Weapon == None )
		{
			AddDefaultInventory( C.Pawn );
		}

		SetPlayerDefaults( C.Pawn );
		C.Pawn.SetLocation( C.StartSpot.Location );
		C.Pawn.SetRotation( C.StartSpot.Rotation );
		C.Pawn.Velocity = vect(0,0,0);
		C.Pawn.PlayTeleportEffect(false, true);
		if ( (Bot(C) != None) && (PawnOverrideClass == "") )
			Bot(C).Squad.ReTask(Bot(C));
	}

	if ( C.StartSpot != None )
		C.ClientSetLocation(C.StartSpot.Location, C.StartSpot.Rotation);
}


function AddDefaultInventory( pawn PlayerPawn )
{
	if ( ASPlayerReplicationInfo(PlayerPawn.Controller.PlayerReplicationInfo).PawnOverrideClass == "" )
	{
		if ( UnrealPawn(PlayerPawn) != None )
			UnrealPawn(PlayerPawn).AddDefaultInventory();
		else if ( ASVehicle(PlayerPawn) != None )
			ASVehicle(PlayerPawn).AddDefaultInventory();
	}

	SetPlayerDefaults(PlayerPawn);
}


function class<Pawn> GetDefaultPlayerClass(Controller C)
{
    local String PawnClassName;
    local class<Pawn> PawnClass;

	if ( C != None )
    {
		// Laurent -- returns Engine.Pawn which is abstract = player dies right away
        // PawnClassName = PC.GetDefaultURL( "Class" );
		PawnClassName = String(C.default.PawnClass);
        PawnClass = class<Pawn>( DynamicLoadObject( PawnClassName, class'Class') );

        if ( PawnClass != None )
            return( PawnClass );
    }

    return( class<Pawn>( DynamicLoadObject( DefaultPlayerClassName, class'Class' ) ) );
}


// Force a specific PawnClass to be used when (re)spawning
function bool SpawnAndPossessPawn(Controller C, String PawnClassName)
{
	local class<Pawn>		PawnClass;
	local Pawn				P;

	PawnClass = class<Pawn>(DynamicLoadObject(PawnClassName, class'Class'));

	if ( PawnClass == None )
	{
		log("ASGameInfo::SpawnAndPossessPawn - PawnClass == None. PawnClassName:"@PawnClassName);
		return false;
	}

	// Override Controller.PawnClass
	if ( C.Pawn == None ) // Controller doesn't have a Pawn yet...
	{
		log("ASGameInfo::SpawnAndPossessPawn - Pawn == None. PawnClassName:"@PawnClassName);
		return false;
	}

	// Spawn Pawn and possess..
	P = Spawn(PawnClass, C,, C.Pawn.LastStartSpot.Location, C.Pawn.LastStartSpot.Rotation);
	if ( P == None ) // make sure it never fails...
	{
		P = Spawn(PawnClass, C,, C.Location, C.Rotation);
		if ( P == None )
		{
			P = Spawn(PawnClass, C);
			if ( P == None )
			{
				P = C.Pawn;
				C.UnPossess();
				P.Controller = None;
				P.Destroy();
				C.PawnClass = PawnClass;
				return false;
			}
		}
	}

	P.Anchor			= C.Pawn.LastStartSpot;
	P.LastStartSpot		= C.Pawn.LastStartSpot;
	P.LastStartTime		= Level.TimeSeconds;
	C.PreviousPawnClass = C.Pawn.Class;

	PossessPawn( C, P );

	return true;
}


function PossessPawn( Controller C, Pawn P )
{
	local Vehicle			V;
	local Pawn				OldPawn;
	local PlayerController	PC;

	PC = PlayerController(C);

	// vehicle specifics
	V = Vehicle(P);
	if ( V != None )
	{
		V.TryToDrive( C.Pawn );
		return;
	}

	OldPawn = C.Pawn;
	C.UnPossess();
	OldPawn.Controller = None;
	OldPawn.Destroy();

	C.Possess( P );

	if ( PC != None )
	{
		PC.ClientSetRotation( C.Pawn.Rotation );
		PC.bBehindView = PC.Pawn.PointOfView();
		PC.ClientSetBehindView( PC.bBehindView );
	}

	AddDefaultInventory( C.Pawn );
}

function NavigationPoint FindPlayerStart( Controller Player, optional byte InTeam, optional string incomingName )
{
	local NavigationPoint	N, BestStart;
	local int				i;
	local string			PawnOverrideClass;
	local byte				Team, T;
	local float				BestRating, NewRating;
	local Teleporter		Tel;

	// Fix for InTeam not working correctly in GameInfo
    if ( (Player != None) && (Player.PlayerReplicationInfo != None) && Player.PlayerReplicationInfo.Team != None )
		Team = Player.PlayerReplicationInfo.Team.TeamIndex;
    else
        Team = InTeam;

	if ( Player != None )
		Player.StartSpot = None;

	 if ( GameRulesModifiers != None )
    {
        N = GameRulesModifiers.FindPlayerStart(Player,InTeam,incomingName);
        if ( N != None )
            return N;
    }

	// if incoming start is specified, then just use it
    if ( incomingName!="" )
        foreach AllActors( class 'Teleporter', Tel )
            if ( string(Tel.Tag)~=incomingName )
                return Tel;

    for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
    {
        NewRating = RatePlayerStart(N, Team, Player);
        if ( NewRating > BestRating )
        {
            BestRating = NewRating;
            BestStart = N;
        }
    }

    if ( PlayerStart(BestStart) == None )
    {
        log("Warning - PATHS NOT DEFINED or NO PLAYERSTART with positive rating");
		log(" Player:" @ Player.GetHumanReadableName() @ "Team:" @ Team @ "Player.Event:" @ Player.Event );
		DebugShowSpawnAreas();
		BestRating = -100000000;
        ForEach AllActors( class 'NavigationPoint', N )	// consider all playerstarts...
        {
			if ( PlayerStart(N) != None )
				T = PlayerStart(N).TeamNumber;
			else
				T = Team;
            NewRating = RatePlayerStart(N, T, Player);
            if ( InventorySpot(N) != None )
				NewRating -= 50;
			NewRating += 20 * FRand();
            if ( NewRating > BestRating )
            {
                BestRating = NewRating;
                BestStart = N;
            }
        }
		//Assert(true);
    }

	// Checking if PlayerStart requires controller to spawn with a forced Pawn class
	if ( SpawnManagers.Length > 0 )
		for (i=0; i<SpawnManagers.Length; i++)
		{
			PawnOverrideClass = SpawnManagers[i].PawnClassOverride(Player, PlayerStart(BestStart), Team);

			if ( PawnOverrideClass != "" )
			{
				ASPlayerReplicationInfo(Player.PlayerReplicationInfo).PawnOverrideClass = PawnOverrideClass;
				break;
			}
		}

	// Ugly Hack to force player to use a specific Spawning area
	if ( Player != None )
		Player.Event = '';

	return BestStart;
}

/* Rate whether player should choose this NavigationPoint as its start */
function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
	local PlayerStart			P;
	local int					i;

	P = PlayerStart(N);
	if ( P == None )
		return -10000000;

	if ( SpawnManagers.Length > 0 )
	{
		for (i=0; i<SpawnManagers.Length; i++)
		{
			if ( SpawnManagers[i].ApprovePlayerStart(P, Team, Player) )
				return super(DeathMatch).RatePlayerStart(N, Team, Player); // Ignore TeamGame RatePlayerStart, since we don't want PRI.Team to match with PlayerStart.TeamNumber
		}
	}

	return -9000000;
}

function DebugShowSpawnAreas()
{
	local NavigationPoint		N;
	local PlayerStart			PS;
	local PlayerSpawnManager	PSM;
	local int					i;

	log("==============");
	log("ShowSpawnAreas");
	log("==============");

	// Log PlayerSpawnManagers
	if ( SpawnManagers.Length > 0 )
		for (i=0; i<SpawnManagers.Length; i++)
		{
			PSM = SpawnManagers[i];
			log("PlayerSpawnManager:" @ PSM @ "bEnabled:" @ PSM.bEnabled @ "Tag:" @ PSM.Tag );

			// log PlayerStarts
			if ( PSM.bEnabled )
				for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
				{
					PS = PlayerStart(N);
					if ( PS == None ) continue;

					if ( PS.TeamNumber == PSM.PlayerStartTeam )
						log( " " @ PS @ "Enabled:" @ PS.bEnabled);
				}
		}

	log("==============");
	log("End...........");
	log("==============");
}

function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
	if ( (instigatedBy == injured) && (class<WeaponDamageType>(DamageType) != None) )
 		Momentum *= 0.3;

	return Super.ReduceDamage(Damage,injured,instigatedby,hitlocation,momentum,damagetype);
}

function int AdjustDestroyObjectiveDamage( int Damage, Controller InstigatedBy, GameObjective GO )
{
	local PlayerController	LocalPlayer;
	if ( AIController(InstigatedBy) == None || InstigatedBy.PlayerReplicationInfo == None )
		return Damage;

	LocalPlayer = Level.GetLocalPlayerController();
	if ( (Level.NetMode == NM_StandAlone || bPlayersVsBots)
		&& (LocalPlayer == None || LocalPlayer.GetTeamNum() != InstigatedBy.GetTeamNum()) )
		return Damage * GO.BotDamageScaling;
	return Damage;
}

//
// Cheats
//

function WeakObjectives()
{
	super.WeakObjectives();
	bWeakObjectives = true;
}

/*
// remove me
exec function function CompleteObjective()
{
	DisableNextObjective();
}

exec function WinRound()
{
	EndRound(ERER_AttackersWin, None, "consolecommand");
}

exec function FinishRound()
{
	EndRound(ERER_AttackersLose, None, "consolecommand");
}
*/

function DisableNextObjective()
{
	local GameObjective GO;

	for ( GO=Teams[0].AI.Objectives; GO!=None; GO=GO.NextObjective )
		if ( CheckObjectivePriority( GO ) )
		{
			GO.CompleteObjective( None );
			break;
		}
}

function QueueAnnouncerSound( name ASound, byte AnnouncementLevel, byte Team,
							 optional AnnouncerQueueManager.EAPriority Priority, optional byte Switch )
{
	local Controller C;

	if ( !IsPlayingIntro() && (ASound != '') )
	{
		for ( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			if ( C.IsA('PlayerController') && ((Team==255) || (C.GetTeamNum()==Team)) )
				PlayerController(C).QueueAnnouncement( ASound, AnnouncementLevel, Priority, Switch );
		}
	}
}

static function PrecacheGameAnnouncements(AnnouncerVoice V, bool bRewardSounds)
{
	Super.PrecacheGameAnnouncements(V,bRewardSounds);
	if ( !bRewardSounds )
	{
		V.PrecacheSound('Draw_Game');
		V.PrecacheSound('New_assault_in');
		V.PrecacheSound('You_are_attacking');
		V.PrecacheSound('You_are_defending');
		V.PrecacheSound('Red_team_attacked');
		V.PrecacheSound('Blue_team_attacked');
		V.PrecacheSound('Red_team_defended');
		V.PrecacheSound('Blue_team_defended');
	}
}
/* OBSOLETE UpdateAnnouncements() - preload all announcer phrases used by this actor */
simulated function UpdateAnnouncements() {}

function GetServerDetails(out ServerResponseLine ServerState)
{
	super.GetServerDetails( ServerState );
	AddServerDetail( ServerState, "RoundLimit",  RoundLimit);
	AddServerDetail( ServerState, "RoundTimeLimit", RoundTimeLimit );
	AddServerDetail( ServerState, "ResetTimeDelay",  ResetTimeDelay);
	AddServerDetail( ServerState, "ReinforcementsFreq", ReinforcementsFreq );
	AddServerDetail( ServerState, "PracticeTimeLimit",  PracticeTimeLimit);
}

static event bool AcceptPlayInfoProperty(string PropertyName)
{
	if ( InStr(PropertyName, "bAllowTrans") != -1 )
		return false;

	if ( PropertyName ~= "TimeLimit" )
		return false;

	if ( InStr(PropertyName, "GoalScore") != -1 )
		return false;

	return Super.AcceptPlayInfoProperty(PropertyName);
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	local int i;

	super.FillPlayInfo( PlayInfo );  // Always begin with calling parent
 	PlayInfo.AddSetting(default.GameGroup,  "RoundLimit",			default.ASPropsDisplayText[i++], 0, 1,  "Text", "3;1:999");
 	PlayInfo.AddSetting(default.GameGroup,  "RoundTimeLimit",		default.ASPropsDisplayText[i++], 0, 1,  "Text", "3;0:999");
 	PlayInfo.AddSetting(default.GameGroup,  "ResetTimeDelay",		default.ASPropsDisplayText[i++], 0, 1,  "Text", "3;0:999",,    ,True);
	PlayInfo.AddSetting(default.GameGroup,  "ReinforcementsFreq",	default.ASPropsDisplayText[i++], 0, 1,  "Text", "3;0:999",,    ,True);
	PlayInfo.AddSetting(default.GameGroup,	 "PracticeTimeLimit",	default.ASPropsDisplayText[i++], 0, 1,  "Text", "3;0:999",,	   ,True);
}

static event string GetDescriptionText(string PropName)
{
	switch( PropName )
	{
		case "RoundLimit":			return default.ASPropDescText[0];
		case "RoundTimeLimit":		return default.ASPropDescText[1];
		case "ResetTimeDelay":		return default.ASPropDescText[2];
		case "ReinforcementsFreq":	return default.ASPropDescText[3];
		case "PracticeTimeLimit":	return default.ASPropDescText[4];
	}

	return super.GetDescriptionText( PropName );
}

static function bool AllowMutator( string MutatorClassName )
{
	if ( MutatorClassName == "" )
		return false;

	if ( static.IsVehicleMutator(MutatorClassName) )
		return false;
	if ( MutatorClassName ~= "UnrealGame.MutLowGrav" )
		return false;
	if ( MutatorClassName ~= "xGame.MutQuadJump" )
		return false;
	if ( MutatorClassName ~= "xGame.MutInstagib" )
		return false;
	if ( MutatorClassName ~= "xGame.MutZoomInstagib" )
		return false;

	return super.AllowMutator(MutatorClassName);
}

static function array<string> GetAllLoadHints(optional bool bThisClassOnly)
{
	local int i;
	local array<string> Hints;

	if ( !bThisClassOnly || default.ASHints.Length == 0 )
		Hints = Super.GetAllLoadHints();

	for ( i = 0; i < default.ASHints.Length; i++ )
		Hints[Hints.Length] = default.ASHints[i];

	return Hints;
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     RoundLimit=1
     RoundTimeLimit=10
     PracticeTimeLimit=60
     ReinforcementsFreq=7
     ReinforcementsValidTime=3
     ASPropsDisplayText(0)="Pair of Rounds"
     ASPropsDisplayText(1)="Round Time Limit"
     ASPropsDisplayText(2)="Reset Countdown"
     ASPropsDisplayText(3)="Reinforcements Time"
     ASPropsDisplayText(4)="Practice Time"
     ASPropDescText(0)="Number of pair of rounds (Attack and defense) for this match."
     ASPropDescText(1)="Specifies how long each round lasts."
     ASPropDescText(2)="Specifies how much time there is between each round."
     ASPropDescText(3)="Specifies time between reinforcements spawning."
     ASPropDescText(4)="Specifies how much time lasts the online practice round. (In seconds)"
     ASHints(0)="A waypoint on the HUD indicates the location of an objective."
     ASHints(1)="Be on the look out for HUD warnings and alarm sounds when an objective is in danger."
     ASHints(2)="When a new spawn area has been enabled, Press %SWITCHWEAPON 10% to teleport to it instantly."
     ASHints(3)="Press %BASEPATH 0% or %BASEPATH 1% to highlight the current objective, show a path to it, and slide out the objective list."
     ASHints(4)="Monitor the respawn countdown to know when to expect backups."
     ASHints(5)="Some weapons are better at destroying enemy Spider Mines than others."
     ASHints(6)="You can be hurt or killed by vehicles exploding near you."
     ASHints(7)="You can heal a friendly vehicle with the Link Gun alt-fire."
     ASHints(8)="If you die, any Spider Mines or Grenades you fired will explode."
     ASHints(9)="The green light on top of the weapon lockers indicates that additional ammo is available at that locker."
     ASHints(10)="All turrets can zoom in by pressing %MOVEFORWARD% and zoom out by pressing %MOVEBACKWARD%."
     ASHints(11)="Link turrets have the same properties as the Link Gun."
     ASHints(12)="The Ion Cannon and Ion Plasma Tank, while charging up, indicate their target with a laser beam."
     ASHints(13)="You can switch between remote controlled turrets by pressing %NEXTWEAPON% and %PREVWEAPON%."
     ASHints(14)="In a SpaceFighter, you can cycle through targets by pressing %NEXTWEAPON% and %PREVWEAPON%."
     ASHints(15)="Various trophies can be obtained by destroying a key vehicle (or turret), completing an objective, or successfully attacking."
     ASHints(16)="A trophy is given to the player completing an objective, but the points reward is shared between all contributors."
     ASHints(17)="Press %TOGGLEBEHINDVIEW% to switch between 1st and 3rd person view in vehicles."
     NewRoundSound="New_assault_in"
     AttackerWinRound(0)="Red_team_attacked"
     AttackerWinRound(1)="Blue_team_attacked"
     DefenderWinRound(0)="Red_team_defended"
     DefenderWinRound(1)="Blue_team_defended"
     DrawGameSound="Draw_Game"
     bScoreTeamKills=False
     bSpawnInTeamArea=True
     TeammateBoost=0.250000
     TeamAIType(0)=Class'UT2k4Assault.ASTeamAI'
     TeamAIType(1)=Class'UT2k4Assault.ASTeamAI'
     NetWait=15
     bSkipPlaySound=True
     SpawnProtectionTime=3.000000
     ADR_Kill=2.000000
     bTeamScoreRounds=True
     bAllowVehicles=True
     DefaultPlayerClassName="xGame.xPawn"
     ScoreBoardType="UT2k4Assault.ScoreBoard_Assault"
     HUDSettingsMenu="GUI2K4.CustomHUDMenuAssault"
     HUDType="UT2k4Assault.HUD_Assault"
     MapListType="UT2k4Assault.ASMapList"
     MapPrefix="AS"
     BeaconName="AS"
     ResetTimeDelay=8
     GoalScore=0
     MutatorClass="UT2K4Assault.ASMutator"
     GameReplicationInfoClass=Class'UT2k4Assault.ASGameReplicationInfo'
     GameName="Assault"
     Description="In each round, one team takes the role of the attacker, while the other team defends, in recreations of famous (or infamous) scenarios. After a pair of rounds, the most successful attacking team scores a point."
     ScreenShotName="UT2004Thumbnails.AssaultShots"
     Acronym="AS"
}
