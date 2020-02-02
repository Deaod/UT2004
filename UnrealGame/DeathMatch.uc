//=============================================================================
// DeathMatch
//=============================================================================
class DeathMatch extends UnrealMPGameInfo
	HideDropDown
	CacheExempt
    config;

#exec OBJ LOAD FILE=TeamSymbols_UT2003.utx
#exec OBJ LOAD FILE=TeamSymbols.utx				// needed right now for Link symbols, etc.

var config int 	NetWait;       // time to wait for players in netgames w/ bWaitForNetPlayers (typically team games)
var globalconfig int	MinNetPlayers; // how many players must join before net game will start
var globalconfig int	RestartWait;
var globalconfig bool	bTournament;  // number of players must equal maxplayers for game to start

var globalconfig bool	bAutoNumBots;	// Match bots to map's recommended bot count
var globalconfig bool	bColoredDMSkins;

var globalconfig bool	bPlayersMustBeReady;// players must confirm ready for game to start
var config bool			bForceRespawn;
var config bool			bAdjustSkill;
var config bool			bAllowTaunts;
var config bool			bAllowTrans;
var bool bDefaultTranslocator;
var bool bOverrideTranslocator;		// for mutators to force translocator on

var globalconfig bool    bWaitForNetPlayers;     // wait until more than MinNetPlayers players have joined before starting match
var bool	bFirstBlood;
var bool	bQuickStart;
var bool	bSkipPlaySound;		// override "play!" sound
var bool	bStartedCountDown;
var bool	bFinalStartup;
var bool	bOverTimeBroadcast;
var bool	bEpicNames;
var bool	bKillBots;
var bool    bCustomBots;
var bool	bReviewingJumpSpots;
var globalconfig bool bAllowPlayerLights;
var bool bForceNoPlayerLights;
var(Menu)        bool   bAlwaysShowLoginMenu;	 //Always show the login menu even to players who have already visited the server

// client game rendering options
var globalconfig bool bForceDefaultCharacter;		// all characters shown using default mesh

var bool bPlayerBecameActive;
var bool bMustHaveMultiplePlayers;

var byte StartupStage;              // what startup message to display
var int NumRounds;

var config float		SpawnProtectionTime;
var int			DefaultMaxLives;
var config int			LateEntryLives;	// defines how many lives in a player can still join

var int RemainingTime, ElapsedTime;
var int CountDown;
var float AdjustedDifficulty;
var int PlayerKills, PlayerDeaths;
var class<SquadAI> DMSquadClass;    // squad class to use for bots in DM games (no team)
var class<LevelGameRules> LevelRulesClass;
var LevelGameRules LevelRules;		// level designer overriding of game settings (hook for mod authors)
var UnrealTeamInfo EnemyRoster;
var string EnemyRosterName;
var string DefaultEnemyRosterClass;

// Bot related info
var     int         RemainingBots;
var     int         InitialBots;

var NavigationPoint LastPlayerStartSpot;    // last place player looking for start spot started from
var NavigationPoint LastStartSpot;          // last place any player started from

var     int         NameNumber;             // append to ensure unique name if duplicate player name change requested

var int             EndMessageWait;         // wait before playing which team won the match
var transient int   EndMessageCounter;      // end message counter
var name			EndGameSoundName[2];
var name			AltEndGameSoundName[2];
var int             SinglePlayerWait;       // single-player wait delay before auto-returning to menus

var globalconfig string NamePrefixes[10];		// for bots with same name
var globalconfig string NameSuffixes[10];		// for bots with same name

var actor EndGameFocus;
var PlayerController StandalonePlayer;

// mc - localized PlayInfo descriptions & extra info
const DMPROPNUM = 14;
var localized string DMPropsDisplayText[DMPROPNUM];
var localized string DMPropDescText[DMPROPNUM];

var	localized string	YouDestroyed, YouDestroyedTrailer;	// vehicle destroy kill message

var() float ADR_Kill;
var() float ADR_MajorKill;
var() float ADR_MinorError;
var() float ADR_MinorBonus;
var() float ADR_KillTeamMate;

var string EpicNames[21];
var string MaleBackupNames[32];
var string FemaleBackupNames[32];
var int EpicOffset, TotalEpic, MaleBackupNameOffset, FemaleBackupNameOffset;

var(Menu) config string LoginMenuClass;	         //Show this menu to players joining the server

var(LoadingHints) private localized array<string> DMHints;

function PostBeginPlay()
{
	NameNumber = Rand(10);
	EpicOffset = Rand(10);
	MaleBackupNameOffset = Rand(32);
	FemaleBackupNameOffset = Rand(32);

    Super.PostBeginPlay();
    GameReplicationInfo.RemainingTime = RemainingTime;
    GameReplicationInfo.bForceTeamSkins = !bTeamGame && bColoredDMSkins;
	GameReplicationInfo.bForceNoPlayerLights = bForceNoPlayerLights;
	if ( bPlayersVsBots || (CurrentGameProfile != None) )
		GameReplicationInfo.bNoTeamChanges = true;
	if ( !bForceNoPlayerLights && (bTeamGame || bColoredDMSkins) )
		GameReplicationInfo.bAllowPlayerLights = Default.bAllowPlayerLights;
    InitTeamSymbols();
    GetBotTeam(InitialBots);
    if ( (CurrentGameProfile == None) || (bCustomBots && (GetBotTeam() != None)) )
		OverrideInitialBots();
	if ( bPlayersVsBots )
		GameReplicationInfo.BotDifficulty = GameDifficulty;
}

function OverrideInitialBots()
{
	InitialBots = GetBotTeam().OverrideInitialBots(InitialBots,None);
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
    Super.Reset();
    ElapsedTime = NetWait - 3;
    bWaitForNetPlayers = ( Level.NetMode != NM_StandAlone );
	bStartedCountDown = false;
	bFinalStartup = false;
    CountDown = Default.Countdown;
    RemainingTime = 60 * TimeLimit;
    GotoState('PendingMatch');
}


function bool JustStarted(float T)
{
	if ( TimeLimit > 0 )
		return (RemainingTime > 60 * TimeLimit - 20);
	return ( Level.TimeSeconds < T );
}

/* CheckReady()
If tournament game, make sure that there is a valid game winning criterion
*/
function CheckReady()
{
    if ( (GoalScore == 0) && (TimeLimit == 0) )
    {
        TimeLimit = 20;
        RemainingTime = 60 * TimeLimit;
    }
}

// Monitor killed messages for fraglimit
function Killed( Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType )
{
	local bool		bEnemyKill;
	local int		Score;
	local string	KillInfo;

	bEnemyKill = ( !bTeamGame || ((Killer != None) && (Killer != Killed) && (Killed != None)
								&& (Killer.PlayerReplicationInfo != None) && (Killed.PlayerReplicationInfo != None)
								&& (Killer.PlayerReplicationInfo.Team != Killed.PlayerReplicationInfo.Team)) );

	if ( KilledPawn != None && KilledPawn.GetSpree() > 4 )
	{
		if ( bEnemyKill && (Killer != None) )
			Killer.AwardAdrenaline(ADR_MajorKill);
		EndSpree(Killer, Killed);
	}
	if ( (Killer != None) && Killer.bIsPlayer && (Killed != None) && Killed.bIsPlayer )
	{
		if ( UnrealPlayer(Killer) != None )
			UnrealPlayer(Killer).LogMultiKills(ADR_MajorKill, bEnemyKill);

		if ( bEnemyKill )
			DamageType.static.ScoreKill(Killer, Killed);

		if ( !bFirstBlood && (Killer != Killed) && bEnemyKill )
		{
			Killer.AwardAdrenaline(ADR_MajorKill);
			bFirstBlood = True;
			if ( TeamPlayerReplicationInfo(Killer.PlayerReplicationInfo) != None )
				TeamPlayerReplicationInfo(Killer.PlayerReplicationInfo).bFirstBlood = true;
			BroadcastLocalizedMessage( class'FirstBloodMessage', 0, Killer.PlayerReplicationInfo );
			SpecialEvent(Killer.PlayerReplicationInfo,"first_blood");
		}
		if ( Killer == Killed )
			Killer.AwardAdrenaline(ADR_MinorError);
		else if ( bTeamGame && (Killed.PlayerReplicationInfo.Team == Killer.PlayerReplicationInfo.Team) )
			Killer.AwardAdrenaline(ADR_KillTeamMate);
		else
		{
			Killer.AwardAdrenaline(ADR_Kill);
			if ( Killer.Pawn != None )
			{
				Killer.Pawn.IncrementSpree();
				if ( Killer.Pawn.GetSpree() > 4 )
					NotifySpree(Killer, Killer.Pawn.GetSpree());
			}
		}
	}

	// Vehicle Score Kill
	if ( Killer != None && Killer.bIsPlayer && Killer.PlayerReplicationInfo != None && Vehicle(KilledPawn) != None
	     && (Killed != None || Vehicle(KilledPawn).bEjectDriver) && Vehicle(KilledPawn).IndependentVehicle() )
	{
		Score = VehicleScoreKill( Killer, Killed, Vehicle(KilledPawn), KillInfo );
		if ( Score > 0 )
		{
			/* if driver(s) have been ejected from vehicle, Killed == None */
			if ( Killed != None )
			{
				if ( !bEnemyKill && Killed.PlayerReplicationInfo != None )
				{
					Score		= -Score;					// substract score if team kill.
					KillInfo	= "TeamKill_" $ KillInfo;
				}
			}

			if ( Score != 0 )
			{
				Killer.PlayerReplicationInfo.Score += Score;
				Killer.PlayerReplicationInfo.NetUpdateTime	= Level.TimeSeconds - 1;
				ScoreEvent(Killer.PlayerReplicationInfo, Score, KillInfo);
			}
		}
	}

    super.Killed(Killer, Killed, KilledPawn, damageType);
}

/* special scorekill function for vehicles
 Note that it is called only once per independant vehicle (ie not for attached turrets subclass)
 If a player is killed inside, normal scorekill will also be applied (so extra points for killed players)
 */
function int VehicleScoreKill( Controller Killer, Controller Killed, Vehicle DestroyedVehicle, out string KillInfo )
{
	//log("VehicleScoreKill Killer:" @ Killer.GetHumanReadableName() @ "Killed:" @ Killed @ "DestroyedVehicle:" @ DestroyedVehicle );

	// Broadcast vehicle kill message if killed no player inside
	if ( Killed == None && PlayerController(Killer) != None )
		PlayerController(Killer).TeamMessage( Killer.PlayerReplicationInfo, YouDestroyed@DestroyedVehicle.VehicleNameString@YouDestroyedTrailer, 'CriticalEvent' );

	if ( KillInfo == "" )
	{
		if ( DestroyedVehicle.bKeyVehicle || DestroyedVehicle.bHighScoreKill )
		{
			KillInfo = "destroyed_key_vehicle";
			return 5;
		}
	}

	return 0;
}


function InitLogging()
{
	Super.InitLogging();
}

static function bool NeverAllowTransloc()
{
	return false;
}

function bool AllowTransloc()
{
	return bAllowTrans || bOverrideTranslocator;
}

function AddGameSpecificInventory(Pawn p)
{
    if ( AllowTransloc() )
        p.CreateInventory("XWeapons.TransLauncher");
    Super.AddGameSpecificInventory(p);
}

// Parse options for this game...
event InitGame( string Options, out string Error )
{
    local string InOpt;
	local int LevelMinPlayers;

    Super.InitGame(Options, Error);

    // find Level's LevelGameRules actor if it exists
    ForEach AllActors(class'LevelGameRules', LevelRules)
        break;
    if ( LevelRules != None )
		LevelRules.UpdateGame(self);

	if ( (CurrentGameProfile == None) && (Left(string(level),3) ~= "TUT") )
	{
		if ( GoalScore != 0 )
			GoalScore = Max(GoalScore, 3);
		if ( (TimeLimit != 0) && (TimeLimit < 10) )
			TimeLimit = 10;
    	RemainingTime = 60 * TimeLimit;
		bTournament = false;
		bQuickStart = true;
		return;
	}

    SetGameSpeed(GameSpeed);
    MaxLives = Max(0,GetIntOption( Options, "MaxLives", MaxLives ));
    if ( MaxLives > 0 )
		bForceRespawn = true;
	else if ( DefaultMaxLives > 0 )
	{
		bForceRespawn = true;
		MaxLives = DefaultMaxLives;
	}
    GoalScore = Max(0,GetIntOption( Options, "GoalScore", GoalScore ));
    TimeLimit = Max(0,GetIntOption( Options, "TimeLimit", TimeLimit ));
	if ( DefaultMaxLives > 0 )
		TimeLimit = 0;
	InOpt = ParseOption( Options, "Translocator");
    // For instant action, use map defaults
    if ( InOpt != "" )
    {
        log("Translocators: "$bool(InOpt));
        bAllowTrans = bool(InOpt);
    }
    InOpt = ParseOption( Options, "bAutoNumBots");
    if ( InOpt != "" )
    {
        log("bAutoNumBots: "$bool(InOpt));
        bAutoNumBots = bool(InOpt);
    }
    if ( bTeamGame && (Level.NetMode != NM_Standalone) )
    {
		InOpt = ParseOption( Options, "VsBots");
		if ( InOpt != "" )
		{
			log("bPlayersVsBots: "$bool(InOpt));
			bPlayersVsBots = bool(InOpt);
		}
		if ( bPlayersVsBots )
			bAutoNumBots = false;
	}
    InOpt = ParseOption( Options, "AutoAdjust");
    if ( InOpt != "" )
    {
        bAdjustSkill = !bTeamGame && bool(InOpt);
        log("Adjust skill "$bAdjustSkill);
    }
    InOpt = ParseOption( Options, "PlayersMustBeReady");
    if ( InOpt != "" )
    {
    	log("PlayerMustBeReady: "$Bool(InOpt));
        bPlayersMustBeReady = bool(InOpt);
    }

	EnemyRosterName = ParseOption( Options, "DMTeam");
	if ( EnemyRosterName != "" )
		bCustomBots = true;

    // SP
    if (CurrentGameProfile != None)
    {
		MaxLives = 0;
		bAllowTrans = default.bDefaultTranslocator;
        bAdjustSkill = false;
    }

    if (HasOption(Options, "NumBots"))
    	bAutoNumBots = false;
    if (bAutoNumBots && Level.NetMode == NM_Standalone)
    {
        LevelMinPlayers = GetMinPlayers();

		if ( bTeamgame && bMustHaveMultiplePlayers )
		{
			if ( LevelMinPlayers < 4 )
				LevelMinPlayers = 4;
			else if ( (LevelMinPlayers & 1) == 1 )
				LevelMinPlayers++;
		}
		else if( LevelMinPlayers < 2 )
            LevelMinPlayers = 2;

        InitialBots = Max(0,LevelMinPlayers - 1);
    }
    else
    {
        MinPlayers = Clamp(GetIntOption( Options, "MinPlayers", MinPlayers ),0,32);
        InitialBots = Clamp(GetIntOption( Options, "NumBots", InitialBots ),0,32);
        if ( bPlayersVsBots )
			MinPlayers = 2;
    }

    RemainingTime = 60 * TimeLimit;

    InOpt = ParseOption( Options, "WeaponStay");
    if ( InOpt != "" )
    {
        log("WeaponStay: "$bool(InOpt));
        bWeaponStay = bool(InOpt);
    }

	if ( bTournament )
		bTournament = (GetIntOption( Options, "Tournament", 1 ) > 0);
	else
		bTournament = (GetIntOption( Options, "Tournament", 0 ) > 0);

    if ( bTournament )
        CheckReady();
    bWaitForNetPlayers = ( Level.NetMode != NM_StandAlone );

    InOpt = ParseOption(Options,"QuickStart");
    if ( InOpt != "" )
		bQuickStart = true;

    AdjustedDifficulty = GameDifficulty;
}

function TweakSkill(Bot B)
{
	if ( !bTeamGame || (Level.NetMode != NM_Standalone) || (CurrentGameProfile == None) )
		return;

	else if ( Level.GetLocalPlayerController().PlayerReplicationInfo.Team != B.PlayerReplicationInfo.Team );
		B.Skill = FMax(B.Skill, AdjustedDifficulty + 0.2);
}

function int GetMinPlayers()
{
    if (CurrentGameProfile == None)
        return Min(12,(Level.IdealPlayerCountMax + Level.IdealPlayerCountMin)/2);

    return Level.SinglePlayerTeamSize*2;
}

/* AcceptInventory()
Examine the passed player's inventory, and accept or discard each item
* AcceptInventory needs to gracefully handle the case of some inventory
being accepted but other inventory not being accepted (such as the default
weapon).  There are several things that can go wrong: A weapon's
AmmoType not being accepted but the weapon being accepted -- the weapon
should be killed off. Or the player's selected inventory item, active
weapon, etc. not being accepted, leaving the player weaponless or leaving
the HUD inventory rendering messed up (AcceptInventory should pick another
applicable weapon/item as current).
*/
function AcceptInventory(pawn PlayerPawn)
{
    while ( PlayerPawn.Inventory != None )
        PlayerPawn.Inventory.Destroy();

    PlayerPawn.Weapon = None;
    PlayerPawn.SelectedItem = None;
    AddDefaultInventory( PlayerPawn );
}

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
    local Controller P, NextController;
    local PlayerController Player;
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

	if ( Winner == None )
	{
		// find winner
		for ( P=Level.ControllerList; P!=None; P=P.nextController )
			if ( P.bIsPlayer && !P.PlayerReplicationInfo.bOutOfLives
				&& ((Winner == None) || (P.PlayerReplicationInfo.Score >= Winner.Score)) )
			{
				Winner = P.PlayerReplicationInfo;
			}
	}

    // check for tie
    if ( !bLastMan )
    {
		for ( P=Level.ControllerList; P!=None; P=P.nextController )
		{
			if ( P.bIsPlayer &&
				(Winner != P.PlayerReplicationInfo) &&
				(P.PlayerReplicationInfo.Score == Winner.Score)
				&& !P.PlayerReplicationInfo.bOutOfLives )
			{
				if ( !bOverTimeBroadcast )
				{
					StartupStage = 7;
					PlayStartupMessage();
					bOverTimeBroadcast = true;
				}
				return false;
			}
		}
	}

    EndTime = Level.TimeSeconds + EndTimeDelay;
    GameReplicationInfo.Winner = Winner;
    if ( CurrentGameProfile != None )
		CurrentGameProfile.bWonMatch = (PlayerController(Winner.Owner) != None);

    EndGameFocus = Controller(Winner.Owner).Pawn;
    if ( EndGameFocus != None )
		EndGameFocus.bAlwaysRelevant = true;
    for ( P=Level.ControllerList; P!=None; P=NextController )
    {
        Player = PlayerController(P);
        if ( Player != None )
        {
			if ( !Player.PlayerReplicationInfo.bOnlySpectator )
	            PlayWinMessage(Player, (Player.PlayerReplicationInfo == Winner));
            Player.ClientSetBehindView(true);
            if ( EndGameFocus != None )
            {
				Player.ClientSetViewTarget(EndGameFocus);
                Player.SetViewTarget(EndGameFocus);
            }
            Player.ClientGameEnded();
        }
        NextController = P.NextController;
        P.GameHasEnded();
    }
    return true;
}

function PlayWinMessage(PlayerController Player, bool bWinner)
{
	if ( UnrealPlayer(Player) != None )
		UnrealPlayer(Player).PlayWinMessage(bWinner);
}

function bool AtCapacity(bool bSpectator)
{
	local Controller C;
	local bool bForcedSpectator;

    if ( Level.NetMode == NM_Standalone )
        return false;

	if ( bPlayersVsBots )
		MaxPlayers = Min(MaxPlayers,16);

    if ( MaxLives <= 0 )
		return Super.AtCapacity(bSpectator);

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if ( (C.PlayerReplicationInfo != None) && (C.PlayerReplicationInfo.NumLives > LateEntryLives) )
		{
			bForcedSpectator = true;
			break;
		}
	}
	if ( !bForcedSpectator )
		return Super.AtCapacity(bSpectator);

	return ( NumPlayers + NumSpectators >= MaxPlayers + MaxSpectators );
}

event PlayerController Login
(
    string Portal,
    string Options,
    out string Error
)
{
    local PlayerController NewPlayer;
	local Controller C;

	if ( MaxLives > 0 )
	{
		// check that game isn't too far along
		for ( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			if ( (C.PlayerReplicationInfo != None) && (C.PlayerReplicationInfo.NumLives > LateEntryLives) )
			{
				Options = "?SpectatorOnly=1"$Options;
				break;
			}
		}
	}

    NewPlayer = Super.Login(Portal,Options,Error);
    if ( bMustJoinBeforeStart && GameReplicationInfo.bMatchHasBegun )
        UnrealPlayer(NewPlayer).bLatecomer = true;

	if ( Level.NetMode == NM_Standalone )
	{
		if( NewPlayer.PlayerReplicationInfo.bOnlySpectator )
		{
			// Compensate for the space left for the player
			if ( !bCustomBots && (bAutoNumBots || (bTeamGame && (InitialBots%2 == 1))) )
				InitialBots++;
		}
		else
			StandalonePlayer = NewPlayer;
	}

    return NewPlayer;
}

event PostLogin( playercontroller NewPlayer )
{
	Super.PostLogin(NewPlayer);

	if (UnrealPlayer(NewPlayer) != None)
	{
		UnrealPlayer(NewPlayer).ClientReceiveLoginMenu(LoginMenuClass, bAlwaysShowLoginMenu);
		UnrealPlayer(NewPlayer).PlayStartUpMessage(StartupStage);
	}
}

function ChangeLoadOut(PlayerController P, string LoadoutName);

function RestartPlayer( Controller aPlayer )
{
    if ( bMustJoinBeforeStart && (UnrealPlayer(aPlayer) != None)
        && UnrealPlayer(aPlayer).bLatecomer )
        return;

    if ( aPlayer.PlayerReplicationInfo.bOutOfLives )
        return;

    if ( aPlayer.IsA('Bot') && TooManyBots(aPlayer) )
    {
        aPlayer.Destroy();
        return;
    }
    Super.RestartPlayer(aPlayer);
}

function bool TooManyBots(Controller botToRemove)
{
	if ( (Level.NetMode != NM_Standalone) && bPlayersVsBots )
		return ( NumBots > Min(16,BotRatio*NumPlayers) );
	if ( bPlayerBecameActive )
	{
		bPlayerBecameActive = false;
		return true;
	}
	return Super.TooManyBots(BotToRemove);
}

function ForceAddBot()
{
    // add bot during gameplay
    if ( Level.NetMode != NM_Standalone )
        MinPlayers = Max(MinPlayers+1, NumPlayers + NumBots + 1);
    AddBot();
}

function bool AddBot(optional string botName)
{
    local Bot NewBot;

    NewBot = SpawnBot(botName);
    if ( NewBot == None )
    {
        warn("Failed to spawn bot.");
        return false;
    }
    // broadcast a welcome message.
    BroadcastLocalizedMessage(GameMessageClass, 1, NewBot.PlayerReplicationInfo);

    NewBot.PlayerReplicationInfo.PlayerID = CurrentID++;
    NumBots++;
    if ( Level.NetMode == NM_Standalone )
		RestartPlayer(NewBot);
	else
		NewBot.GotoState('Dead','MPStart');

    return true;
}

function AddDefaultInventory( pawn PlayerPawn )
{
    if ( UnrealPawn(PlayerPawn) != None )
        UnrealPawn(PlayerPawn).AddDefaultInventory();
    SetPlayerDefaults(PlayerPawn);
}

function bool CanSpectate( PlayerController Viewer, bool bOnlySpectator, actor ViewTarget )
{
    if ( ViewTarget == None )
        return false;
	if ( Controller(ViewTarget) != None )
		return ( (Controller(ViewTarget).PlayerReplicationInfo != None)
				&& !Controller(ViewTarget).PlayerReplicationInfo.bOnlySpectator );
    return ( (Level.NetMode == NM_Standalone) || bOnlySpectator );
}

function bool ShouldRespawn(Pickup Other)
{
    return ( Other.ReSpawnTime!=0.0 );
}

function ChangeName(Controller Other, string S, bool bNameChange)
{
    local Controller APlayer,C, P;

    if ( S == "" )
        return;

	S = StripColor(s);	// Stip out color codes

    if (Other.PlayerReplicationInfo.playername~=S)
        return;

	S = Left(S,20);
    ReplaceText(S, " ", "_");
    ReplaceText(S, "|", "I");

	if ( bEpicNames && (Bot(Other) != None) )
	{
		if ( TotalEpic < 21 )
		{
			S = EpicNames[EpicOffset % 21];
			EpicOffset++;
			TotalEpic++;
		}
		else
		{
			S = NamePrefixes[NameNumber%10]$"CliffyB"$NameSuffixes[NameNumber%10];
			NameNumber++;
		}
	}

    for( APlayer=Level.ControllerList; APlayer!=None; APlayer=APlayer.nextController )
        if ( APlayer.bIsPlayer && (APlayer.PlayerReplicationInfo.playername~=S) )
        {
            if ( Other.IsA('PlayerController') )
            {
                PlayerController(Other).ReceiveLocalizedMessage( GameMessageClass, 8 );
				return;
			}
			else
			{
				if ( Other.PlayerReplicationInfo.bIsFemale )
				{
					S = FemaleBackupNames[FemaleBackupNameOffset%32];
					FemaleBackupNameOffset++;
				}
				else
				{
					S = MaleBackupNames[MaleBackupNameOffset%32];
					MaleBackupNameOffset++;
				}
				for( P=Level.ControllerList; P!=None; P=P.nextController )
					if ( P.bIsPlayer && (P.PlayerReplicationInfo.playername~=S) )
					{
						S = NamePrefixes[NameNumber%10]$S$NameSuffixes[NameNumber%10];
						NameNumber++;
						break;
					}
				break;
			}
            S = NamePrefixes[NameNumber%10]$S$NameSuffixes[NameNumber%10];
            NameNumber++;
            break;
        }

	if( bNameChange )
		GameEvent("NameChange",s,Other.PlayerReplicationInfo);

	if ( S ~= "CliffyB" )
		bEpicNames = true;
    Other.PlayerReplicationInfo.SetPlayerName(S);
    // notify local players
    if  ( bNameChange )
		for ( C=Level.ControllerList; C!=None; C=C.NextController )
			if ( (PlayerController(C) != None) && (Viewport(PlayerController(C).Player) != None) )
				PlayerController(C).ReceiveLocalizedMessage( class'GameMessage', 2, Other.PlayerReplicationInfo );
}

function bool BecomeSpectator(PlayerController P)
{
	if ( !Super.BecomeSpectator(P) )
		return false;

    if ( !bKillBots )
		RemainingBots++;
    if ( !NeedPlayers() || AddBot() )
        RemainingBots--;
	return true;
}

function bool AllowBecomeActivePlayer(PlayerController P)
{
	if ( Super.AllowBecomeActivePlayer(P) )
	{
		if ( (Level.NetMode == NM_Standalone) && (NumBots > InitialBots) )
		{
			RemainingBots--;
			bPlayerBecameActive = true;
		}
		return true;
	}
	return false;
}

function Logout(controller Exiting)
{
    Super.Logout(Exiting);
    if ( Exiting.IsA('Bot') )
        NumBots--;
    if ( !bKillBots )
		RemainingBots++;
    if ( !NeedPlayers() || AddBot() )
        RemainingBots--;
    if ( MaxLives > 0 )
         CheckMaxLives(none);
	//VotingHandler.PlayerExit(Exiting);
}

function bool NeedPlayers()
{
    if ( Level.NetMode == NM_Standalone )
        return ( RemainingBots > 0 );
    if ( bMustJoinBeforeStart )
        return false;
    if ( bPlayersVsBots )
		return ( NumBots < Min(16,BotRatio*NumPlayers) );
    return (NumPlayers + NumBots < MinPlayers);
}

//------------------------------------------------------------------------------
// Game Querying.

function GetServerDetails( out ServerResponseLine ServerState )
{
	Super.GetServerDetails( ServerState );
	AddServerDetail( ServerState, "GoalScore", GoalScore );
	AddServerDetail( ServerState, "TimeLimit", TimeLimit );
	AddServerDetail( ServerState, "Translocator", bAllowTrans );
	AddServerDetail( ServerState, "WeaponStay", bWeaponStay );
	AddServerDetail( ServerState, "ForceRespawn", bForceRespawn );
}

function InitGameReplicationInfo()
{
    Super.InitGameReplicationInfo();
    GameReplicationInfo.GoalScore = GoalScore;
    GameReplicationInfo.TimeLimit = TimeLimit;
    GameReplicationInfo.MinNetPlayers = MinNetPlayers;
}

function InitTeamSymbols()
{
    // default team textures (for banners, etc.)
    if ( GameReplicationInfo.TeamSymbols[0] == None )
		GameReplicationInfo.TeamSymbols[0] = GetRandomTeamSymbol(1);
    if ( GameReplicationInfo.TeamSymbols[1] == None )
		GameReplicationInfo.TeamSymbols[1] = GetRandomTeamSymbol(10);
	GameReplicationInfo.TeamSymbolNotify();
}

//------------------------------------------------------------------------------

function UnrealTeamInfo GetBotTeam(optional int TeamBots)
{
	local class<UnrealTeamInfo> RosterClass;

	if ( EnemyRoster != None )
		return EnemyRoster;
    if ( CurrentGameProfile != None )
	{
		if (CurrentGameProfile.EnemyTeam != "")
		{
			RosterClass = class<UnrealTeamInfo>(DynamicLoadObject(CurrentGameProfile.EnemyTeam,class'Class'));
			if ( RosterClass == None)
				warn("Invalid EnemyTeam class:"@CurrentGameProfile.EnemyTeam@" Expecting subclass of UnrealTeamInfo");
			else
				EnemyRoster = spawn(RosterClass);
		}
		else Log("No EnemyTeam set in CurrentGameProfile, is this correct?");
	}
	else if ( EnemyRosterName != "" )
	{
		RosterClass = class<UnrealTeamInfo>(DynamicLoadObject(EnemyRosterName,class'Class'));
		if ( RosterClass != None)
			EnemyRoster = spawn(RosterClass);
	}
    if ( EnemyRoster == None )
    {
		RosterClass = class<UnrealTeamInfo>(DynamicLoadObject(DefaultEnemyRosterClass,class'Class'));
		if ( RosterClass != None)
			EnemyRoster = spawn(RosterClass);
	}
	EnemyRoster.Initialize(TeamBots);
	return EnemyRoster;
}

function PreLoadNamedBot(string BotName)
{
	EnemyRoster.AddNamedBot(BotName);
}

function PreLoadBot()
{
	EnemyRoster.AddRandomPlayer();
}

/* Spawn and initialize a bot
*/
function Bot SpawnBot(optional string botName)
{
    local Bot NewBot;
    local RosterEntry Chosen;
	local UnrealTeamInfo BotTeam;

	BotTeam = GetBotTeam();
    Chosen = BotTeam.ChooseBotClass(botName);

    if (Chosen.PawnClass == None)
        Chosen.Init(); //amb
    // log("Chose pawn class "$Chosen.PawnClass);
    NewBot = Bot(Spawn(Chosen.PawnClass.default.ControllerClass));

    if ( NewBot != None )
        InitializeBot(NewBot,BotTeam,Chosen);
    return NewBot;
}

/* Initialize bot
*/
function InitializeBot(Bot NewBot, UnrealTeamInfo BotTeam, RosterEntry Chosen)
{
    NewBot.InitializeSkill(AdjustedDifficulty);
 	Chosen.InitBot(NewBot);
    BotTeam.AddToTeam(NewBot);
    if ( Chosen.ModifiedPlayerName != "" )
 		ChangeName(NewBot, Chosen.ModifiedPlayerName, false);
    else
		ChangeName(NewBot, Chosen.PlayerName, false);
	if ( bEpicNames && (NewBot.PlayerReplicationInfo.PlayerName ~= "The_Reaper") )
	{
		NewBot.Accuracy = 1;
		NewBot.StrafingAbility = 1;
		NewBot.Tactics = 1;
		NewBot.InitializeSkill(AdjustedDifficulty+2);
	}
	BotTeam.SetBotOrders(NewBot,Chosen);
}

/* initialize a bot which is associated with a pawn placed in the level
*/
function InitPlacedBot(Controller C, RosterEntry R)
{
    local UnrealTeamInfo BotTeam;

	log("Init placed bot "$C);

    BotTeam = FindTeamFor(C);
    if ( Bot(C) != None )
    {
		Bot(C).InitializeSkill(AdjustedDifficulty);
		if ( R != None )
			R.InitBot(Bot(C));
	}
	BotTeam.AddToTeam(C);
	if ( R != None )
		ChangeName(C, R.PlayerName, false);
}

function UnrealTeamInfo FindTeamFor(Controller C)
{
    return GetBotTeam();
}
//------------------------------------------------------------------------------
// Game States

function StartMatch()
{
    local bool bTemp;
	local int Num;

    GotoState('MatchInProgress');
    if ( Level.NetMode == NM_Standalone )
        RemainingBots = InitialBots;
    else
        RemainingBots = 0;
    GameReplicationInfo.RemainingMinute = RemainingTime;
    Super.StartMatch();
    bTemp = bMustJoinBeforeStart;
    bMustJoinBeforeStart = false;
    while ( NeedPlayers() && (Num<16) )
    {
		if ( AddBot() )
			RemainingBots--;
		Num++;
    }
    bMustJoinBeforeStart = bTemp;
    log("START MATCH");
}

function EndGame(PlayerReplicationInfo Winner, string Reason )
{
    if ( (Reason ~= "triggered") ||
         (Reason ~= "LastMan")   ||
         (Reason ~= "TimeLimit") ||
         (Reason ~= "FragLimit") ||
         (Reason ~= "TeamScoreLimit") )
    {
        Super.EndGame(Winner,Reason);
        if ( bGameEnded )
            GotoState('MatchOver');
    }
}

/* FindPlayerStart()
returns the 'best' player start for this player to start from.
*/
function NavigationPoint FindPlayerStart(Controller Player, optional byte InTeam, optional string incomingName)
{
    local NavigationPoint Best;

    if ( (Player != None) && (Player.StartSpot != None) )
        LastPlayerStartSpot = Player.StartSpot;

    Best = Super.FindPlayerStart(Player, InTeam, incomingName );
    if ( Best != None )
        LastStartSpot = Best;
    return Best;
}

function PlayEndOfMatchMessage()
{
	local controller C;

    if ( (PlayerReplicationInfo(GameReplicationInfo.Winner).Deaths == 0)
		&& (PlayerReplicationInfo(GameReplicationInfo.Winner).Score >= 5) )
    {
		for ( C = Level.ControllerList; C != None; C = C.NextController )
		{
			if ( C.IsA('PlayerController') )
			{
				if ( (C.PlayerReplicationInfo == GameReplicationInfo.Winner) || C.PlayerReplicationInfo.bOnlySpectator )
					PlayerController(C).PlayStatusAnnouncement(AltEndGameSoundName[0],1,true);
				else
					PlayerController(C).PlayStatusAnnouncement(AltEndGameSoundName[1],1,true);
			}
		}
	}
    else
    {
		for ( C = Level.ControllerList; C != None; C = C.NextController )
		{
			if ( C.IsA('PlayerController') && !C.PlayerReplicationInfo.bOnlySpectator )
			{
				if (C.PlayerReplicationInfo == GameReplicationInfo.Winner)
					PlayerController(C).PlayStatusAnnouncement(EndGameSoundName[0],1,true);
				else
					PlayerController(C).PlayStatusAnnouncement(EndGameSoundName[1],1,true);
			}
		}
	}
}

function PlayStartupMessage()
{
	local Controller P;

    // keep message displayed for waiting players
    for (P=Level.ControllerList; P!=None; P=P.NextController )
        if ( UnrealPlayer(P) != None )
            UnrealPlayer(P).PlayStartUpMessage(StartupStage);
}

auto State PendingMatch
{
	function RestartPlayer( Controller aPlayer )
	{
		if ( CountDown <= 0 )
			Super.RestartPlayer(aPlayer);
	}

    function bool AddBot(optional string botName)
    {
        if ( Level.NetMode == NM_Standalone )
            InitialBots++;
        if ( botName != "" )
			PreLoadNamedBot(botName);
		else
			PreLoadBot();
        return true;
    }

    function Timer()
    {
        local Controller P;
        local bool bReady;

        Global.Timer();

        // first check if there are enough net players, and enough time has elapsed to give people
        // a chance to join
        if ( NumPlayers == 0 )
			bWaitForNetPlayers = true;

        if ( bWaitForNetPlayers && (Level.NetMode != NM_Standalone) )
        {
             if ( NumPlayers >= MinNetPlayers )
                ElapsedTime++;
            else
                ElapsedTime = 0;
            if ( (NumPlayers == MaxPlayers) || (ElapsedTime > NetWait) )
            {
                bWaitForNetPlayers = false;
                CountDown = Default.CountDown;
            }
        }

        if ( (Level.NetMode != NM_Standalone) && (bWaitForNetPlayers || (bTournament && (NumPlayers < MaxPlayers))) )
        {
       		PlayStartupMessage();
            return;
		}

		// check if players are ready
        bReady = true;
        StartupStage = 1;
        if ( !bStartedCountDown && (bTournament || bPlayersMustBeReady || (Level.NetMode == NM_Standalone)) )
        {
            for (P=Level.ControllerList; P!=None; P=P.NextController )
                if ( P.IsA('PlayerController') && (P.PlayerReplicationInfo != None)
                    && P.bIsPlayer && P.PlayerReplicationInfo.bWaitingPlayer
                    && !P.PlayerReplicationInfo.bReadyToPlay )
                    bReady = false;
        }
        if ( bReady && !bReviewingJumpspots )
        {
			bStartedCountDown = true;
            CountDown--;
            if ( CountDown <= 0 )
                StartMatch();
            else
                StartupStage = 5 - CountDown;
        }
		PlayStartupMessage();
    }

    function beginstate()
    {
		bWaitingToStartMatch = true;
        StartupStage = 0;
        if ( IsA('xLastManStandingGame') )
			NetWait = Max(NetWait,10);
    }

Begin:
	if ( bQuickStart )
		StartMatch();
}

State MatchInProgress
{
    function Timer()
    {
        local Controller P;

        Global.Timer();
		if ( !bFinalStartup )
		{
			bFinalStartup = true;
			PlayStartupMessage();
		}
        if ( bForceRespawn )
            For ( P=Level.ControllerList; P!=None; P=P.NextController )
            {
                if ( (P.Pawn == None) && P.IsA('PlayerController') && !P.PlayerReplicationInfo.bOnlySpectator )
                    PlayerController(P).ServerReStartPlayer();
            }
        if ( NeedPlayers() && AddBot() && (RemainingBots > 0) )
			RemainingBots--;

        if ( bOverTime )
			EndGame(None,"TimeLimit");
        else if ( TimeLimit > 0 )
        {
            GameReplicationInfo.bStopCountDown = false;
            RemainingTime--;
            GameReplicationInfo.RemainingTime = RemainingTime;
            if ( RemainingTime % 60 == 0 )
                GameReplicationInfo.RemainingMinute = RemainingTime;
            if ( RemainingTime <= 0 )
                EndGame(None,"TimeLimit");
        }
        else if ( (MaxLives > 0) && (NumPlayers + NumBots != 1) )
			CheckMaxLives(none);

        ElapsedTime++;
        GameReplicationInfo.ElapsedTime = ElapsedTime;
    }

    function beginstate()
    {
		local PlayerReplicationInfo PRI;

		ForEach DynamicActors(class'PlayerReplicationInfo',PRI)
			PRI.StartTime = 0;
		ElapsedTime = 0;
		bWaitingToStartMatch = false;
        StartupStage = 5;
        PlayStartupMessage();
        StartupStage = 6;
    }
}

State MatchOver
{
	function RestartPlayer( Controller aPlayer ) {}
	function ScoreKill(Controller Killer, Controller Other) {}
	function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
	{
		return 0;
	}

	function bool ChangeTeam(Controller Other, int num, bool bNewTeam)
	{
		return false;
	}

    function Timer()
    {
		local Controller C;
		local PlayerController P;

        Global.Timer();

        if ( !bGameRestarted && (Level.TimeSeconds > EndTime + RestartWait) )
            RestartGame();

		if ( EndGameFocus != None )
		{
			EndGameFocus.bAlwaysRelevant = true;
			for ( C = Level.ControllerList; C != None; C = C.NextController )
				if ( PlayerController(C) != None )
					PlayerController(C).ClientSetViewtarget(EndGameFocus);
		}

         // play end-of-match message for winner/losers (for single and muli-player)
        EndMessageCounter++;
        if ( EndMessageCounter == EndMessageWait )
	         PlayEndOfMatchMessage();

		if ( (Level.TimeSeconds > EndTime + (RestartWait/2)) && (CurrentGameProfile != None) )
        {
			for ( c=Level.ControllerList; c!=None; c=c.NextController )
			{
				P = PlayerController(C);
				if ( P != None )
					break;
			}
			P.myHUD.bShowLocalStats=true;
        }
	}


    function bool NeedPlayers()
    {
        return false;
    }

    function BeginState()
    {
		local Controller C;
		local PlayerController P;

		GameReplicationInfo.bStopCountDown = true;
        if ( CurrentGameProfile != None )
        {
			EndTime = Level.TimeSeconds + SinglePlayerWait;
			for ( c=Level.ControllerList; c!=None; c=c.NextController )
			{
				P = PlayerController(C);
				if ( P != None )
					break;
			}
			P.myHUD.bShowScoreboard=true;
			CurrentGameProfile.RegisterGame(self,P.PlayerReplicationInfo);
            SavePackage(CurrentGameProfile.PackageName);
        }
	}
}

/* Rate whether player should choose this NavigationPoint as its start
*/
function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
    local PlayerStart P;
    local float Score, NextDist;
    local Controller OtherPlayer;

    P = PlayerStart(N);

    if ( (P == None) || !P.bEnabled || P.PhysicsVolume.bWaterVolume )
        return -10000000;

    //assess candidate
    if ( P.bPrimaryStart )
		Score = 10000000;
	else
		Score = 5000000;
    if ( (N == LastStartSpot) || (N == LastPlayerStartSpot) )
        Score -= 10000.0;
    else
        Score += 3000 * FRand(); //randomize

    for ( OtherPlayer=Level.ControllerList; OtherPlayer!=None; OtherPlayer=OtherPlayer.NextController)
        if ( OtherPlayer.bIsPlayer && (OtherPlayer.Pawn != None) )
        {
            if ( OtherPlayer.Pawn.Region.Zone == N.Region.Zone )
                Score -= 1500;
            NextDist = VSize(OtherPlayer.Pawn.Location - N.Location);
            if ( NextDist < OtherPlayer.Pawn.CollisionRadius + OtherPlayer.Pawn.CollisionHeight )
                Score -= 1000000.0;
            else if ( (NextDist < 3000) && FastTrace(N.Location, OtherPlayer.Pawn.Location) )
                Score -= (10000.0 - NextDist);
            else if ( NumPlayers + NumBots == 2 )
            {
                Score += 2 * VSize(OtherPlayer.Pawn.Location - N.Location);
                if ( FastTrace(N.Location, OtherPlayer.Pawn.Location) )
                    Score -= 10000;
            }
        }
    return FMax(Score, 5);
}

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
				else if (C.PlayerReplicationInfo != Living)
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

/* CheckScore()
see if this score means the game ends
*/
function CheckScore(PlayerReplicationInfo Scorer)
{
	local controller C;

	if ( CheckMaxLives(Scorer) )
		return;

    if ( (GameRulesModifiers != None) && GameRulesModifiers.CheckScore(Scorer) )
        return;

	if ( Scorer != None )
	{
		if ( (GoalScore > 0) && (Scorer.Score >= GoalScore) )
			EndGame(Scorer,"fraglimit");
		else if ( bOverTime )
		{
			// end game only if scorer has highest score
			for ( C=Level.ControllerList; C!=None; C=C.NextController )
				if ( (C.PlayerReplicationInfo != None)
					&& (C.PlayerReplicationInfo != Scorer)
					&& (C.PlayerReplicationInfo.Score >= Scorer.Score) )
					return;
			EndGame(Scorer,"fraglimit");
		}
	}
}

function ScoreObjective(PlayerReplicationInfo Scorer, float Score)
{
    if ( Scorer != None )
    {
        Scorer.Score += Score;
		ScoreEvent(Scorer,Score,"ObjectiveScore");
    }

    if ( GameRulesModifiers != None )
        GameRulesModifiers.ScoreObjective(Scorer,Score);
    CheckScore(Scorer);
}

function ScoreKill(Controller Killer, Controller Other)
{
	local PlayerReplicationInfo OtherPRI;

	OtherPRI = Other.PlayerReplicationInfo;
    if ( OtherPRI != None )
    {
        OtherPRI.NumLives++;
        if ( (MaxLives > 0) && (OtherPRI.NumLives >=MaxLives) )
            OtherPRI.bOutOfLives = true;
    }

	if ( bAllowTaunts && (Killer != None) && (Killer != Other) && Killer.AutoTaunt()
		&& (Killer.PlayerReplicationInfo != None) && (Killer.PlayerReplicationInfo.VoiceType != None) )
	{
		if( Killer.IsA('PlayerController') )
			Killer.SendMessage(OtherPRI, 'AUTOTAUNT', Killer.PlayerReplicationInfo.VoiceType.static.PickRandomTauntFor(Killer, false, false), 10, 'GLOBAL');
		else
			Killer.SendMessage(OtherPRI, 'AUTOTAUNT', Killer.PlayerReplicationInfo.VoiceType.static.PickRandomTauntFor(Killer, false, true), 10, 'GLOBAL');
	}
    Super.ScoreKill(Killer,Other);

    if ( (killer == None) || (Other == None) )
        return;

    if ( bAdjustSkill && (killer.IsA('PlayerController') || Other.IsA('PlayerController')) )
    {
        if ( killer.IsA('AIController') )
            AdjustSkill(AIController(killer), PlayerController(Other),true);
        if ( Other.IsA('AIController') )
            AdjustSkill(AIController(Other), PlayerController(Killer),false);
    }
}

function AdjustSkill(AIController B, PlayerController P, bool bWinner)
{
    if ( bWinner )
    {
        PlayerKills += 1;
        AdjustedDifficulty = FMax(0, AdjustedDifficulty - 2.0/FMin(PlayerKills, 10.0));
        if ( B.Skill > AdjustedDifficulty )
        {
            B.Skill = AdjustedDifficulty;
            Bot(B).ResetSkill();
        }
    }
    else
    {
        PlayerDeaths += 1;
        AdjustedDifficulty = FMin(7.0,AdjustedDifficulty + 2.0/FMin(PlayerDeaths, 10.0));
        if ( B.Skill < AdjustedDifficulty )
            B.Skill = AdjustedDifficulty;
    }
    if ( abs(AdjustedDifficulty - GameDifficulty) >= 1 )
    {
        GameDifficulty = AdjustedDifficulty;
        SaveConfig();
    }
}

function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
    local float InstigatorSkill;

	if ( (instigatedBy != None) && (InstigatedBy != Injured) && (Level.TimeSeconds - injured.SpawnTime < SpawnProtectionTime)
		&& (class<WeaponDamageType>(DamageType) != None || class<VehicleDamageType>(DamageType) != None) )
		return 0;

    Damage = Super.ReduceDamage( Damage, injured, InstigatedBy, HitLocation, Momentum, DamageType );

    if ( instigatedBy == None)
        return Damage;

    if ( Level.Game.GameDifficulty <= 3 )
    {
        if ( injured.IsPlayerPawn() && (injured == instigatedby) && (Level.NetMode == NM_Standalone) )
            Damage *= 0.5;

        //skill level modification
        if ( (AIController(instigatedBy.Controller) != None)
			&& ((Level.NetMode == NM_Standalone) || (TurretController(InstigatedBy.Controller) != None)) )
        {
            InstigatorSkill = AIController(instigatedBy.Controller).Skill;
            if ( (InstigatorSkill <= 3) && injured.IsHumanControlled() )
			{
				if ( ((instigatedBy.Weapon != None) && instigatedBy.Weapon.bMeleeWeapon)
					|| ((injured.Weapon != None) && injured.Weapon.bMeleeWeapon && (VSize(injured.location - instigatedBy.Location) < 600)) )
						Damage = Damage * (0.76 + 0.08 * InstigatorSkill);
				else
						Damage = Damage * (0.25 + 0.15 * InstigatorSkill);
            }
        }
    }
    return (Damage * instigatedBy.DamageScaling);
}

// Add one or num bots
exec function AddNamedBot(string botname)
{
    if (Level.NetMode != NM_Standalone)
        MinPlayers = Max(MinPlayers + 1, NumPlayers + NumBots + 1);
    AddBot(botName);
}

exec function AddBots(int num)
{
    num = Clamp(num, 0, 32 - (NumPlayers + NumBots));

    while (--num >= 0)
    {
        if ( Level.NetMode != NM_Standalone )
            MinPlayers = Max(MinPlayers + 1, NumPlayers + NumBots + 1);
        AddBot();
    }
}

// Kill all or num bots
exec function KillBots(int num)
{
    local Controller c, nextC;

	bPlayersVsBots = false;

    if (num == 0)
        num = NumBots;

    c = Level.ControllerList;
    if ( Level.NetMode != NM_Standalone )
		MinPlayers = 0;
    bKillBots = true;
    while (c != None && num > 0)
    {
        nextC = c.NextController;
        if (KillBot(c))
            --num;
        c = nextC;
    }
    bKillBots = false;
}

function bool KillBot(Controller c)
{
    local Bot b;

    b = Bot(c);
    if (b != None)
    {
        if (Level.NetMode != NM_Standalone)
            MinPlayers = Max(MinPlayers - 1, NumPlayers + NumBots - 1);

		if ( (Vehicle(b.Pawn) != None) && (Vehicle(b.Pawn).Driver != None) )
			Vehicle(b.Pawn).Driver.KilledBy(Vehicle(b.Pawn).Driver);
		else if (b.Pawn != None)
            b.Pawn.KilledBy( b.Pawn );
		if (b != None)
			b.Destroy();
        return true;
    }
    return false;
}

function ReviewJumpSpots(name TestLabel)
{
	local NavigationPoint StartSpot;
	local controller C;
	local Pawn P;
	local Bot B;
	local class<Pawn> PawnClass;

	bReviewingJumpSpots = true;
	B = spawn(class'Bot');
	B.Squad = spawn(class'DMSquad');
    startSpot = FindPlayerStart(B, 0);
    PawnClass = class<Pawn>( DynamicLoadObject(DefaultPlayerClassName, class'Class') );
    P = Spawn(PawnClass,,,StartSpot.Location,StartSpot.Rotation);
	if ( P == None )
	{
		log("Failed to spawn pawn to reviewjumpspots");
		return;
	}
	B.Possess(P);
	B.GoalString = "TRANSLOCATING";

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
		if ( PlayerController(C) != None )
		{
			PlayerController(C).bBehindView = true;
			PlayerController(C).SetViewTarget(P);
			UnrealPlayer(C).ShowAI();
			break;
		}

	// first, check translocation
    p.GiveWeapon("XWeapons.TransLauncher");
    if ( TestLabel == '' )
		TestLabel = 'Begin';
	else
		B.bSingleTestSection = true;
	B.GotoState('Testing',TestLabel);
}

static event bool AcceptPlayInfoProperty(string PropertyName)
{
	if ( (Default.MaxLives <= 0) && (InStr(PropertyName, "LateEntryLives") != -1) )
		return false;

	if ( ((!Default.bColoredDMSkins && !Default.bTeamGame) || Default.bForceNoPlayerLights) && (InStr(PropertyName, "bAllowPlayerLights") != -1) )
		return false;
	return Super.AcceptPlayInfoProperty(PropertyName);
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);  // Always begin with calling parent

	if ( !Default.bTeamGame )
		PlayInfo.AddSetting(default.BotsGroup,   "bAdjustSkill",        GetDisplayText("bAdjustSkill"),        0,    2, "Check",             ,,    ,True);

	PlayInfo.AddSetting(default.GameGroup,   "SpawnProtectionTime", GetDisplayText("SpawnProtectionTime"), 2,    1,  "Text", "8;0.0:30.0",,    ,True);
	PlayInfo.AddSetting(default.GameGroup,   "LateEntryLives",      GetDisplayText("LateEntryLives"),     50,    1,  "Text",          "3",,True,True);
	PlayInfo.AddSetting(default.GameGroup,   "bColoredDMSkins",     GetDisplayText("bColoredDMSkins"),     1,    1, "Check",             ,,    ,True);
	PlayInfo.AddSetting(default.GameGroup,   "bAllowPlayerLights",  GetDisplayText("bAllowPlayerLights"),  1,    1, "Check",             ,,    ,True);

	PlayInfo.AddSetting(default.RulesGroup,  "bAllowTrans",         GetDisplayText("bAllowTrans"),         0,    1, "Check",             ,,    ,True);
	PlayInfo.AddSetting(default.RulesGroup,  "bAllowTaunts",        GetDisplayText("bAllowTaunts"),        1,    1, "Check",             ,,    ,True);
	PlayInfo.AddSetting(default.RulesGroup,  "bForceRespawn",       GetDisplayText("bForceRespawn"),       0,    1, "Check",             ,,True,True);
	PlayInfo.AddSetting(default.RulesGroup,  "bPlayersMustBeReady", GetDisplayText("bPlayersMustBeReady"), 1,    1, "Check",             ,,True,True);

	PlayInfo.AddSetting(default.ServerGroup, "MinNetPlayers",       GetDisplayText("MinNetPlayers"),       100,  1,  "Text",     "3;0:32",,True,True);
	PlayInfo.AddSetting(default.ServerGroup, "NetWait",             GetDisplayText("NetWait"),             200,  1,  "Text",     "3;0:60",,True,True);
	PlayInfo.AddSetting(default.ServerGroup, "RestartWait",         GetDisplayText("RestartWait"),         200,  1,  "Text",     "3;0:60",,True,True);
	class'MasterServerUplink'.static.FillPlayInfo(PlayInfo);
	PlayInfo.PopClass();
}

static function string GetDisplayText(string PropName)
{
	switch (PropName)
	{
		case "NetWait":            return default.DMPropsDisplayText[0];
		case "MinNetPlayers":      return default.DMPropsDisplayText[1];
		case "RestartWait":        return default.DMPropsDisplayText[2];
		case "bTournament":        return default.DMPropsDisplayText[3];
		case "bPlayersMustBeReady":return default.DMPropsDisplayText[4];
		case "bForceRespawn":      return default.DMPropsDisplayText[5];
		case "bAdjustSkill":       return default.DMPropsDisplayText[6];
		case "bAllowTaunts":       return default.DMPropsDisplayText[7];
		case "SpawnProtectionTime":return default.DMPropsDisplayText[8];
		case "bAllowTrans":        return default.DMPropsDisplayText[9];
		case "bColoredDMSkins":    return default.DMPropsDisplayText[10];
		case "LateEntryLives":     return default.DMPropsDisplayText[12];
		case "bAllowPlayerLights": return default.DMPropsDisplayText[13];
	}

	return Super.GetDisplayText(PropName);
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "NetWait":            return default.DMPropDescText[0];
		case "MinNetPlayers":      return default.DMPropDescText[1];
		case "RestartWait":        return default.DMPropDescText[2];
		case "bTournament":        return default.DMPropDescText[3];
		case "bPlayersMustBeReady":return default.DMPropDescText[4];
		case "bForceRespawn":      return default.DMPropDescText[5];
		case "bAdjustSkill":       return default.DMPropDescText[6];
		case "bAllowTaunts":       return default.DMPropDescText[7];
		case "SpawnProtectionTime":return default.DMPropDescText[8];
		case "bAllowTrans":        return default.DMPropDescText[9];
		case "bColoredDMSkins":    return default.DMPropDescText[10];
		case "bAutoNumBots":       return default.DMPropDescText[11];
		case "LateEntryLives":     return default.DMPropDescText[12];
		case "bAllowPlayerLights": return default.DMPropDescText[13];
	}

	return Super.GetDescriptionText(PropName);
}

function NotifySpree(Controller Other, int num)
{
	local Controller C;

	if ( num == 5 )
		num = 0;
	else if ( num == 10 )
		num = 1;
	else if ( num == 15 )
		num = 2;
	else if ( num == 20 )
		num = 3;
	else if ( num == 25 )
		num = 4;
	else if ( num == 30 )
		num = 5;
	else
		return;

	SpecialEvent(Other.PlayerReplicationInfo,"spree_"$(num+1));
	if ( TeamPlayerReplicationInfo(Other.PlayerReplicationInfo) != None )
	{
		TeamPlayerReplicationInfo(Other.PlayerReplicationInfo).Spree[num] += 1;
		if ( num > 0 )
			TeamPlayerReplicationInfo(Other.PlayerReplicationInfo).Spree[num-1] -= 1;
	}
	Other.AwardAdrenaline( ADR_MajorKill );

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
		if ( PlayerController(C) != None )
			PlayerController(C).ReceiveLocalizedMessage( class'KillingSpreeMessage', Num, Other.PlayerReplicationInfo );
}

function EndSpree(Controller Killer, Controller Other)
{
	local Controller C;

	if ( (Other == None) || !Other.bIsPlayer )
		return;
	for ( C=Level.ControllerList; C!=None; C=C.NextController )
		if ( PlayerController(C) != None )
		{
			if ( (Killer == Other) || (Killer == None) || !Killer.bIsPlayer )
				PlayerController(C).ReceiveLocalizedMessage( class'KillingSpreeMessage', 1, None, Other.PlayerReplicationInfo );
			else
				PlayerController(C).ReceiveLocalizedMessage( class'KillingSpreeMessage', 0, Other.PlayerReplicationInfo, Killer.PlayerReplicationInfo );
		}
}

function bool WantsPickups(bot B)
{
	return true;
}

static function PrecacheGameAnnouncements(AnnouncerVoice V, bool bRewardSounds)
{
	Super.PrecacheGameAnnouncements(V,bRewardSounds);
	if ( !bRewardSounds )
	{
		V.PrecacheSound(Default.EndGameSoundName[0]);
		V.PrecacheSound(Default.EndGameSoundName[1]);
		V.PrecacheSound(Default.AltEndGameSoundName[0]);
		V.PrecacheSound(Default.AltEndGameSoundName[1]);
		V.PrecacheSound('Last_Second_Save');
		V.PrecacheSound('Play');
	}
}

event SetGrammar()
{
	// No bots to command in DeathMatch
}

static function string GetNextLoadHint( string MapName )
{
	local array<string> Hints;

	// Higher chance that we'll pull a loading hint from our own gametype
	if ( Rand(100) < 75 )
		Hints = GetAllLoadHints(true);
	else Hints = GetAllLoadHints();

	if ( Hints.Length > 0 )
		return Hints[Rand(Hints.Length)];

	return "";
}

static function array<string> GetAllLoadHints(optional bool bThisClassOnly)
{
	local int i;
	local array<string> Hints;

	if ( !bThisClassOnly || default.DMHints.Length == 0 )
		Hints = Super.GetAllLoadHints();

	for ( i = 0; i < default.DMHints.Length; i++ )
		Hints[Hints.Length] = default.DMHints[i];

	return Hints;
}

defaultproperties
{
     NetWait=5
     MinNetPlayers=1
     RestartWait=30
     bAutoNumBots=True
     bAllowTaunts=True
     bWaitForNetPlayers=True
     NumRounds=1
     SpawnProtectionTime=2.000000
     LateEntryLives=1
     CountDown=4
     DMSquadClass=Class'UnrealGame.DMSquad'
     EndMessageWait=2
     EndGameSoundName(0)="You_Have_Won_the_Match"
     EndGameSoundName(1)="You_Have_Lost_the_Match"
     AltEndGameSoundName(0)="Flawless_victory"
     AltEndGameSoundName(1)="Humiliating_defeat"
     NamePrefixes(0)="Mr_"
     NamePrefixes(2)="The_Real_"
     NamePrefixes(3)="Evil_"
     NamePrefixes(5)="Owns_"
     NamePrefixes(7)="Evil_"
     NameSuffixes(1)="_is_lame"
     NameSuffixes(4)="_sucks"
     NameSuffixes(6)="_OwnsYou"
     NameSuffixes(8)="_jr"
     NameSuffixes(9)="'s_clone"
     DMPropsDisplayText(0)="Net Start Delay"
     DMPropsDisplayText(1)="Min. Net Players"
     DMPropsDisplayText(2)="Restart Delay"
     DMPropsDisplayText(3)="Tournament Game"
     DMPropsDisplayText(4)="Players Must Be Ready"
     DMPropsDisplayText(5)="Force Respawn"
     DMPropsDisplayText(6)="Auto Adjust Bots Skill"
     DMPropsDisplayText(7)="Allow Taunts"
     DMPropsDisplayText(8)="Spawn Protection Time"
     DMPropsDisplayText(9)="Allow Translocator"
     DMPropsDisplayText(10)="Use Team Skins"
     DMPropsDisplayText(11)="Use Map Defaults"
     DMPropsDisplayText(12)="Late Entry Cutoff"
     DMPropsDisplayText(13)="Enable Player Highlighting"
     DMPropDescText(0)="Delay before game starts to allow other players to join."
     DMPropDescText(1)="How many players must join before net game will start."
     DMPropDescText(2)="How long the server waits after the end of a game before loading the next map."
     DMPropDescText(3)="Tournament Game"
     DMPropDescText(4)="If enabled, players must click ready before the game starts."
     DMPropDescText(5)="Players are forced to respawn immediately after dying."
     DMPropDescText(6)="Bot skill adjusts automatically based on how they are doing against you."
     DMPropDescText(7)="Enables players to use the recorded taunts."
     DMPropDescText(8)="Specifies how long players are invulnerable after they spawn (unless they fire)."
     DMPropDescText(9)="If enabled, players will start with a translocator."
     DMPropDescText(10)="If checked, players will have brighter red or blue skins."
     DMPropDescText(11)="Use default number of bots specified by the map."
     DMPropDescText(12)="Specifies the maximum number of lives a player can have lost before new players can no longer enter the game."
     DMPropDescText(13)="At a distance, players have a team colored glow."
     YouDestroyed="You destroyed a"
     ADR_Kill=5.000000
     ADR_MajorKill=10.000000
     ADR_MinorError=-2.000000
     ADR_MinorBonus=5.000000
     ADR_KillTeamMate=-5.000000
     EpicNames(0)="Eepers"
     EpicNames(1)="Bellheimer"
     EpicNames(2)="Shanesta"
     EpicNames(3)="EpicBoy"
     EpicNames(4)="Turtle"
     EpicNames(5)="Talisman"
     EpicNames(6)="BigSquid"
     EpicNames(7)="Ced"
     EpicNames(8)="Andrew"
     EpicNames(9)="DrSin"
     EpicNames(10)="The_Reaper"
     EpicNames(11)="ProfessorDeath"
     EpicNames(12)="DarkByte"
     EpicNames(13)="Jack"
     EpicNames(14)="Lankii"
     EpicNames(15)="MarkRein"
     EpicNames(16)="Perninator"
     EpicNames(17)="SteveG"
     EpicNames(18)="Cpt.Pinhead"
     EpicNames(19)="Christoph"
     EpicNames(20)="Tim"
     MaleBackupNames(0)="Shiva"
     MaleBackupNames(1)="Ares"
     MaleBackupNames(2)="Reaper"
     MaleBackupNames(3)="Samurai"
     MaleBackupNames(4)="Loki"
     MaleBackupNames(5)="Cuchulain"
     MaleBackupNames(6)="Thor"
     MaleBackupNames(7)="Talisman"
     MaleBackupNames(8)="Paladin"
     MaleBackupNames(9)="Scythe"
     MaleBackupNames(10)="Jugular"
     MaleBackupNames(11)="Slash"
     MaleBackupNames(12)="Chisel"
     MaleBackupNames(13)="Chief"
     MaleBackupNames(14)="Prime"
     MaleBackupNames(15)="Oligarch"
     MaleBackupNames(16)="Caliph"
     MaleBackupNames(17)="Duce"
     MaleBackupNames(18)="Kruger"
     MaleBackupNames(19)="Saladin"
     MaleBackupNames(20)="Patriarch"
     MaleBackupNames(21)="Wyrm"
     MaleBackupNames(22)="Praetorian"
     MaleBackupNames(23)="Moghul"
     MaleBackupNames(24)="Assassin"
     MaleBackupNames(25)="Bane"
     MaleBackupNames(26)="Svengali"
     MaleBackupNames(27)="Oblivion"
     MaleBackupNames(28)="Magnate"
     MaleBackupNames(29)="Hadrian"
     MaleBackupNames(30)="Dirge"
     MaleBackupNames(31)="Rajah"
     FemaleBackupNames(0)="Shonna"
     FemaleBackupNames(1)="Athena"
     FemaleBackupNames(2)="Charm"
     FemaleBackupNames(3)="Voodoo"
     FemaleBackupNames(4)="Noranna"
     FemaleBackupNames(5)="Ranu"
     FemaleBackupNames(6)="Chasm"
     FemaleBackupNames(7)="Lynx"
     FemaleBackupNames(8)="Elyss"
     FemaleBackupNames(9)="Malice"
     FemaleBackupNames(10)="Verdict"
     FemaleBackupNames(11)="Kismet"
     FemaleBackupNames(12)="Wyrd"
     FemaleBackupNames(13)="Qira"
     FemaleBackupNames(14)="Exodus"
     FemaleBackupNames(15)="Grimm"
     FemaleBackupNames(16)="Brutality"
     FemaleBackupNames(17)="Adamant"
     FemaleBackupNames(18)="Ruin"
     FemaleBackupNames(19)="Moshica"
     FemaleBackupNames(20)="Demise"
     FemaleBackupNames(21)="Shara"
     FemaleBackupNames(22)="Pestilence"
     FemaleBackupNames(23)="Quark"
     FemaleBackupNames(24)="Fiona"
     FemaleBackupNames(25)="Ulanna"
     FemaleBackupNames(26)="Kara"
     FemaleBackupNames(27)="Scourge"
     FemaleBackupNames(28)="Minerva"
     FemaleBackupNames(29)="Woe"
     FemaleBackupNames(30)="Coral"
     FemaleBackupNames(31)="Torment"
     LoginMenuClass="GUI2K4.UT2K4PlayerLoginMenu"
     DMHints(0)="Every weapon has two firing modes, a regular fire mode when you press %FIRE% and an alternate fire mode when you press %ALTFIRE%."
     DMHints(1)="Press jump again at the peak of a jump to get an extra boost."
     DMHints(2)="Pressing a movement key twice in rapid succession will make your character dodge in that direction."
     DMHints(3)="You can also dodge off walls while in the air."
     DMHints(4)="You can change weapons by pressing the associated weapon number, or scroll through your weapons using %NEXTWEAPON% and %PREVWEAPON%."
     DMHints(5)="The shock combo is a powerful explosion created with a shock rifle by shooting a shock ball with a shock beam."
     DMHints(6)="When loading up rockets using the rocket launcher alt fire, press the regular fire button before releasing the rockets to fire them in a tight spiral."
     DMHints(7)="You can toggle the scoreboard display on or off at any time by pressing %SHOWSCORES%."
     DMHints(8)="You receive adrenaline for killing enemies and other accomplishments.  Once your adrenaline reaches 100, you can start an adrenaline combo by using the correct movement key combination."
     DMHints(9)="%SHOWSTATS% will bring up a personal stats display."
     DMHints(10)="You can shoot down enemy Redeemer missiles with a well placed shot."
     DMHints(11)="Press %TALK% and type your message to send text messages to other players."
     DMHints(12)="You can play taunts or other voice messages through the voice menu by pressing %SPEECHMENUTOGGLE%."
     DMHints(13)="While crouching (by holding down %DUCK%), you cannot fall off a ledge."
     bRestartLevel=False
     bPauseable=False
     bWeaponStay=True
     bLoggingGame=True
     AutoAim=1.000000
     DefaultPlayerClassName="XGame.xPawn"
     ScoreBoardType="XInterface.ScoreBoardDeathMatch"
     HUDType="XInterface.HudCDeathMatch"
     MapListType="XInterface.MapListDeathMatch"
     MapPrefix="DM"
     BeaconName="DM"
     GoalScore=25
     TimeLimit=20
     MutatorClass="UnrealGame.DMMutator"
     PlayerControllerClassName="XGame.XPlayer"
     Description="Free-for-all kill or be killed.  The player with the most frags wins."
}
