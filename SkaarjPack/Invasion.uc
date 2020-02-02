class Invasion extends xTeamGame
	config;

#exec OBJ LOAD FILE=SkaarjPackSkins.utx
#exec OBJ LOAD FILE=AnnouncerEvil.uax

var class<Monster> MonsterClass[16];
var class<Monster> WaveMonsterClass[16];
var class<Monster> LastKilledMonsterClass;
var class<Monster> FallbackMonster;

var float NextMonsterTime;
var float WaveEndTime;

var config  string  WaveConfigMenu;
var config 	string	FallbackMonsterClass;
var config	int		InitialWave;
var config	int		FinalWave;

const INVPROPNUM = 8;
var localized string InvasionPropText[INVPROPNUM];
var localized string InvasionDescText[INVPROPNUM];

var int NumMonsters, MaxMonsters;
var int WaveNum;
var int WaveNumClasses;
var int WaveMonsters;
var int SecondBot;
var int WaveCountDown;

var bool bWaveInProgress;

var string InvasionBotNames[9];

var sound NewRoundSound;  // OBSOLETE
var sound InvasionEndSound[6];  // OBSOLETE
var name InvasionEnd[6];

struct WaveInfo
{
	var() int	WaveMask;	// bit fields for which monsterclasses
	var() byte	WaveMaxMonsters;
	var() byte	WaveDuration;
	var() float	WaveDifficulty;
};

var() config WaveInfo Waves[16];	// TODO Add support for structs & arrays to PlayInfo

static function PrecacheGameTextures(LevelInfo myLevel)
{
	class'xTeamGame'.static.PrecacheGameTextures(myLevel);

	myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.jBrute2');
	myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.jBrute1');
	myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.eKrall');
	myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.Skaarjw3');
	myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.Gasbag1');
	myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.Gasbag2');
	myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.Skaarjw2');
	myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.JManta1');
	myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.JFly1');
	myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.Skaarjw1');
	myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.JPupae1');
	myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.JWarlord1');
	myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.jkrall');
}

static function PrecacheGameAnnouncements(AnnouncerVoice V, bool bRewardSounds)
{
	Super.PrecacheGameAnnouncements(V,bRewardSounds);
	if ( bRewardSounds )
	{
		V.PrecacheSound('SKAARJtermination');
		V.PrecacheSound('SKAARJslaughter');
		V.PrecacheSound('SKAARJextermination');
		V.PrecacheSound('SKAARJerradication');
		V.PrecacheSound('SKAARJbloodbath');
		V.PrecacheSound('SKAARJannihilation');
	}
	else
		V.PrecacheSound('Next_wave_in');
}

/* OBSOLETE UpdateAnnouncements() - preload all announcer phrases used by this actor */
simulated function UpdateAnnouncements() {}

event InitGame( string Options, out string Error )
{
	Super.InitGame(Options, Error);

	FallbackMonster = class<Monster>(DynamicLoadObject(FallbackMonsterClass, class'Class'));
	if (FallbackMonster == None)
		FallbackMonster = class'EliteKrall';

    MaxLives = 1;
	bForceRespawn = true;
}

event PreBeginPlay()
{
	Super.PreBeginPlay();
	WaveNum = InitialWave;
	InvasionGameReplicationInfo(GameReplicationInfo).WaveNumber = WaveNum;
	InvasionGameReplicationInfo(GameReplicationInfo).BaseDifficulty = int(GameDifficulty);
	GameReplicationInfo.bNoTeamSkins = true;
	GameReplicationInfo.bForceNoPlayerLights = true;
	GameReplicationInfo.bNoTeamChanges = true;
}

function bool CanSpectate( PlayerController Viewer, bool bOnlySpectator, actor ViewTarget )
{
	if ( (ViewTarget == None) )
		return false;
	if ( Controller(ViewTarget) != None )
	{
		if ( Controller(ViewTarget).Pawn == None )
			return false;
		return ( (Controller(ViewTarget).PlayerReplicationInfo != None) && (ViewTarget != Viewer)
				&& (Controller(ViewTarget).PlayerReplicationInfo.Team == Viewer.PlayerReplicationInfo.Team) );
	}
	return ( (Pawn(ViewTarget) != None) && Pawn(ViewTarget).IsPlayerPawn()
		&& (Pawn(ViewTarget).PlayerReplicationInfo.Team == Viewer.PlayerReplicationInfo.Team) );
}

function OverrideInitialBots()
{
	InitialBots = Min(InitialBots,2);
}

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	local Controller P;
	local PlayerController Player;

	EndTime = Level.TimeSeconds + EndTimeDelay;

	if ( WaveNum >= FinalWave )
		GameReplicationInfo.Winner = Teams[0];

	for ( P=Level.ControllerList; P!=None; P=P.nextController )
	{
		player = PlayerController(P);
		if ( Player != None )
		{
			if ( !Player.PlayerReplicationInfo.bOnlySpectator )
				PlayWinMessage(Player, (Player.PlayerReplicationInfo.Team == GameReplicationInfo.Winner));
			player.ClientSetBehindView(true);
			player.ClientGameEnded();
		}
		P.GameHasEnded();
	}

	if ( CurrentGameProfile != None )
		CurrentGameProfile.bWonMatch = false;
	return true;
}

// check if all other players are out
function bool CheckMaxLives(PlayerReplicationInfo Scorer)
{
    local Controller C;
    local PlayerReplicationInfo Living;
    local bool bNoneLeft;

    if ( MaxLives > 0 )
    {
        bNoneLeft = true;
        for ( C=Level.ControllerList; C!=None; C=C.NextController )
            if ( (C.PlayerReplicationInfo != None) && C.bIsPlayer
                && !C.PlayerReplicationInfo.bOutOfLives
                && !C.PlayerReplicationInfo.bOnlySpectator )
            {
   	        	bNoneLeft = false;
            	break;
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

function ScoreKill(Controller Killer, Controller Other)
{
	local PlayerReplicationInfo OtherPRI;
	local float KillScore;

	OtherPRI = Other.PlayerReplicationInfo;
    if ( OtherPRI != None )
    {
        OtherPRI.NumLives++;
		OtherPRI.Score -= 10;
		OtherPRI.Team.Score -= 10;
		OtherPRI.Team.NetUpdateTime = Level.TimeSeconds - 1;
        OtherPRI.bOutOfLives = true;
        BroadcastLocalizedMessage(class'InvasionMessage', 1, OtherPRI);
        CheckScore(None);
    }

	if ( GameRulesModifiers != None )
		GameRulesModifiers.ScoreKill(Killer, Other);

	if ( MonsterController(Killer) != None )
		return;

    if( (killer == Other) || (killer == None) )
	{
		if ( Other.PlayerReplicationInfo != None )
		{
			Other.PlayerReplicationInfo.Score -= 1;
			Other.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
			Killer.PlayerReplicationInfo.Team.Score -= 1;
			Killer.PlayerReplicationInfo.Team.NetUpdateTime = Level.TimeSeconds - 1;
			ScoreEvent(Other.PlayerReplicationInfo,-1,"self_frag");
		}
	}

	if ( (Killer == None) || !Killer.bIsPlayer || (Killer == Other) )
		return;

	if ( Other.bIsPlayer )
	{
		Killer.PlayerReplicationInfo.Score -= 10;
		Killer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
		Killer.PlayerReplicationInfo.Team.Score -= 10;
		Killer.PlayerReplicationInfo.Team.NetUpdateTime = Level.TimeSeconds - 1;
		ScoreEvent(Killer.PlayerReplicationInfo, -10, "team_frag");
		return;
	}
	if ( LastKilledMonsterClass == None )
		KillScore = 1;
	else
		KillScore = LastKilledMonsterClass.Default.ScoringValue;
	Killer.PlayerReplicationInfo.Kills++;
	Killer.PlayerReplicationInfo.Score += KillScore;
	Killer.PlayerReplicationInfo.Team.Score += KillScore;
	Killer.PlayerReplicationInfo.Team.NetUpdateTime = Level.TimeSeconds - 1;
	Killer.AwardAdrenaline(KillScore);
	Killer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
	TeamScoreEvent(Killer.PlayerReplicationInfo.Team.TeamIndex, 1, "tdm_frag");
}

function NotifyKilled(Controller Killer, Controller Killed, Pawn KilledPawn)
{
    local Controller C;

    for ( C=Level.ControllerList; C!=None; C=C.nextController )
		if ( MonsterController(C) != None )
			C.NotifyKilled(Killer, Killed, KilledPawn);

	Super.NotifyKilled(Killer,Killed,KilledPawn);
}

function RestartPlayer( Controller aPlayer )
{
    if ( aPlayer.PlayerReplicationInfo.bOutOfLives )
        return;

	Super(GameInfo).RestartPlayer(aPlayer);
}

function UnrealTeamInfo GetBotTeam(optional int TeamBots)
{
	return Teams[0];
}

function byte PickTeam(byte num, Controller C)
{
	return 0;
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

	NewPlayer = Super.Login(Portal,Options,Error);

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
		if ( (C.PlayerReplicationInfo != None) && C.PlayerReplicationInfo.bOutOfLives && !C.PlayerReplicationInfo.bOnlySpectator )
		{
			NewPlayer.PlayerReplicationInfo.bOutOfLives = true;
			NewPlayer.PlayerReplicationInfo.NumLives = 1;
			NewPlayer.GotoState('Spectating');
		}
	return NewPlayer;
}

/* Spawn and initialize a bot
*/
function Bot SpawnBot(optional string botName)
{
    local Bot NewBot;
    local RosterEntry Chosen;
	local UnrealTeamInfo BotTeam;
	local array<xUtil.PlayerRecord> PlayerRecords;
	local xUtil.PlayerRecord PR;

	BotTeam = GetBotTeam();
	if ( bCustomBots && (class'DMRosterConfigured'.Default.Characters.Length > NumBots)  )
	{
		class'xUtil'.static.GetPlayerList(PlayerRecords);
		PR = class'xUtil'.static.FindPlayerRecord(class'DMRosterConfigured'.Default.Characters[NumBots]);
		Chosen = class'xRosterEntry'.Static.CreateRosterEntry(PR.RecordIndex);
	}

	if ( Chosen == None )
	{
		if ( SecondBot > 0 )
		{
			BotName = InvasionBotNames[SecondBot + 1];
			SecondBot++;
			if ( SecondBot > 6 )
				SecondBot = 0;
		}
		else
		{
			SecondBot = 1 + 2 * Rand(4);
			BotName = InvasionBotNames[SecondBot];
		}
		Chosen = class'xRosterEntry'.static.CreateRosterEntryCharacter(botName);
	}
	if (Chosen.PawnClass == None)
		Chosen.Init();
    NewBot = Spawn(class'InvasionBot');

    if ( NewBot != None )
    {
		AdjustedDifficulty = AdjustedDifficulty + 2;
        InitializeBot(NewBot,BotTeam,Chosen);
		AdjustedDifficulty = AdjustedDifficulty - 2;
		NewBot.bInitLifeMessage = true;
    }
    return NewBot;
}

function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
	local float InstigatorSkill, result;

	if ( instigatedBy == None )
		return Super.ReduceDamage( Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );

	if ( Monster(Injured) != None )
	{
		if ( Monster(Injured).SameSpeciesAs(InstigatedBy) )
			return 0;
		return Damage;
	}

	if ( MonsterController(InstigatedBy.Controller) != None )
	{
		InstigatorSkill = MonsterController(instigatedBy.Controller).Skill;
		if ( NumPlayers > 4 )
			InstigatorSkill += 1.0;
		if ( (InstigatorSkill < 7) && (Monster(Injured) == None) )
		{
			if ( InstigatorSkill <= 3 )
				Damage = Damage * (0.25 + 0.05 * InstigatorSkill);
			else
				Damage = Damage * (0.4 + 0.1 * (InstigatorSkill - 3));
		}
	}
	else if ( injured == instigatedBy )
		Damage = Damage * 0.5;
	if ( InvasionBot(injured.Controller) != None )
	{
		if ( !InvasionBot(injured.controller).bDamagedMessage && (injured.Health - Damage < 50) )
		{
			InvasionBot(injured.controller).bDamagedMessage = true;
			if ( FRand() < 0.5 )
				injured.Controller.SendMessage(None, 'OTHER', 4, 12, 'TEAM');
			else
				injured.Controller.SendMessage(None, 'OTHER', 13, 12, 'TEAM');
		}
		if ( GameDifficulty <= 3 )
		{
			if ( injured.IsPlayerPawn() && (injured == instigatedby) && (Level.NetMode == NM_Standalone) )
				Damage *= 0.5;

			//skill level modification
			if ( MonsterController(InstigatedBy.Controller) != None )
			{
				if ( InstigatorSkill <= 3 )
					Damage = Damage * (0.25 + 0.15 * InstigatorSkill);
			}
		}
	}
	result = Super.ReduceDamage( Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );
	return result;
}

function Killed( Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType )
{
	local TeamPlayerReplicationInfo TPRI;

	if ( (MonsterController(Killed) != None) || (Monster(KilledPawn) != None) )
	{
		NumMonsters--;
		if ( (Killer != None) && Killer.bIsPlayer )
		{
			TPRI = TeamPlayerReplicationInfo(Killer.PlayerReplicationInfo);
			if ( TPRI != None )
				TPRI.AddWeaponKill(DamageType);
		}
	}

	LastKilledMonsterClass = class<Monster>(KilledPawn.class);
	Super.Killed(Killer,Killed,KilledPawn,DamageType);
}

function AddMonster()
{
	local NavigationPoint StartSpot;
	local Pawn NewMonster;
	local class<Monster> NewMonsterClass;

	StartSpot = FindPlayerStart(None,1);
	if ( StartSpot == None )
		return;

	NewMonsterClass = WaveMonsterClass[Rand(WaveNumClasses)];
	NewMonster = Spawn(NewMonsterClass,,,StartSpot.Location+(NewMonsterClass.Default.CollisionHeight - StartSpot.CollisionHeight) * vect(0,0,1),StartSpot.Rotation);
	if ( NewMonster ==  None )
		NewMonster = Spawn(FallBackMonster,,,StartSpot.Location+(class'EliteKrall'.Default.CollisionHeight - StartSpot.CollisionHeight) * vect(0,0,1),StartSpot.Rotation);
	if ( NewMonster != None )
	{
		WaveMonsters++;
		NumMonsters++;
	}
}

function SetupWave()
{
	local int i,j;
	local float NewMaxMonsters;

	if ( WaveNum > 15 )
	{
		SetupRandomWave();
		return;
	}
	WaveMonsters = 0;
	WaveNumClasses = 0;
	NewMaxMonsters = Waves[WaveNum].WaveMaxMonsters;
	if ( NumPlayers + NumBots <= 2 )
		NewMaxMonsters = NewMaxMonsters * (FMin(GameDifficulty,7) + 3)/10;
	if ( NumPlayers > 4 )
		NewMaxMonsters *= FMin(NumPlayers/4,2);
	MaxMonsters = NewMaxMonsters;
	WaveEndTime = Level.TimeSeconds + Waves[WaveNum].WaveDuration;
	AdjustedDifficulty = GameDifficulty + Waves[WaveNum].WaveDifficulty;

	j = 1;

	for ( i=0; i<16; i++ )
	{
		if ( (j & Waves[WaveNum].WaveMask) != 0 )
		{
			WaveMonsterClass[WaveNumClasses] = MonsterClass[i];
			WaveNumClasses++;
		}
		j *= 2;
	}
}

function SetupRandomWave()
{
	local int i,j, Mask;
	local float NewMaxMonsters;

	NewMaxMonsters = 15;
	if ( NumPlayers > 4 )
		NewMaxMonsters *= FMin(NumPlayers/4,2);
	else
		NewMaxMonsters = NewMaxMonsters * (FMin(GameDifficulty,7) + 3)/10;
	MaxMonsters = NewMaxMonsters + 1;
	WaveEndTime = Level.TimeSeconds + 180;
	AdjustedDifficulty = GameDifficulty + 3;
	GameDifficulty += 0.5;

	WaveNumClasses = 0;
	Mask = 2048 + Rand(2047);
	j = 1;

	for ( i=0; i<16; i++ )
	{
		if ( (j & Mask) != 0 )
		{
			WaveMonsterClass[WaveNumClasses] = MonsterClass[i];
			WaveNumClasses++;
		}
		j *= 2;
	}
}

function PlayEndOfMatchMessage()
{
	local controller C;
	local name EndSound;

	if ( WaveNum >= FinalWave )
		EndSound = EndGameSoundName[0];
	else if ( WaveNum - InitialWave == 0 )
		EndSound = AltEndGameSoundName[1];
	else
		EndSound = InvasionEnd[Min(5,(WaveNum - InitialWave)/3)];
	for ( C = Level.ControllerList; C != None; C = C.NextController )
		if ( C.IsA('PlayerController') )
			PlayerController(C).PlayRewardAnnouncement(EndSound,1,true);
}

/* Rate whether player/monster should choose this NavigationPoint as its start
*/
function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
    local float Score, NextDist;
    local Controller OtherPlayer;

	if ( (Team == 0) || ((Player !=None) && Player.bIsPlayer) )
		return Super.RatePlayerStart(N,Team,Player);

    if ( N.PhysicsVolume.bWaterVolume )
        return -10000000;

    //assess candidate
    if ( (SmallNavigationPoint(N) != None) && (PlayerStart(N) == None) )
		return -1;

	Score = 10000000;

    Score += 3000 * FRand(); //randomize

    for ( OtherPlayer=Level.ControllerList; OtherPlayer!=None; OtherPlayer=OtherPlayer.NextController)
        if ( (PlayerController(OtherPlayer) != None) && (OtherPlayer.Pawn != None) )
        {
            NextDist = VSize(OtherPlayer.Pawn.Location - N.Location);
            if ( NextDist < OtherPlayer.Pawn.CollisionRadius + OtherPlayer.Pawn.CollisionHeight )
                Score -= 1000000.0;
            else if ( NextDist > 5000 )
				Score -= 20000;
            else if ( NextDist < 3000 )
            {
				if ( (NextDist > 1200) && (Vector(OtherPlayer.Rotation) Dot (N.Location - OtherPlayer.Pawn.Location)) <= 0 )
					Score = Score + 5000 - NextDist;
				else if ( FastTrace(N.Location, OtherPlayer.Pawn.Location) )
					Score -= (10000.0 - NextDist);
				if ( (Location.Z > OtherPlayer.Pawn.Location.Z) && (NextDist > 1000) )
					Score += 1000;
			}
        }
    return FMax(Score, 5);
}

function ReplenishWeapons(Pawn P)
{
	local Inventory Inv;

	for (Inv = P.Inventory; Inv != None; Inv = Inv.Inventory)
		if (Weapon(Inv) != None && !Inv.IsA('Painter') && !Inv.IsA('Redeemer'))
		{
			Weapon(Inv).FillToInitialAmmo();
			Inv.NetUpdateTime = Level.TimeSeconds - 1;
		}
}

State MatchInProgress
{
	function Timer()
	{
		local Controller C;
		local bool bOneMessage;
		local Bot B;
		local int PlayerCount;

		Super.Timer();
		if ( bWaveInProgress )
		{
			if ( (WaveEndTime - Level.TimeSeconds < 30) && (MaxMonsters < Waves[WaveNum].WaveMaxMonsters) )
			{
				for ( C = Level.ControllerList; C != None; C = C.NextController )
					if ( C.bIsPlayer && (C.Pawn != None) )
						PlayerCount++;
				if ( PlayerCount > 1 )
					MaxMonsters = Waves[WaveNum].WaveMaxMonsters;
			}
			if ( (Level.TimeSeconds > WaveEndTime) && (WaveMonsters >= 2*MaxMonsters) )
			{
				if ( Level.TimeSeconds > WaveEndTime + 90 )
				{
					for ( C = Level.ControllerList; C != None; C = C.NextController )
						if ( (MonsterController(C) != None) && (Level.TimeSeconds - MonsterController(C).LastSeenTime > 30)
							&& !MonsterController(C).Pawn.PlayerCanSeeMe() )
						{
							C.Pawn.KilledBy( C.Pawn );
							return;
						}
				}
				if ( NumMonsters <= 0 )
				{
					bWaveInProgress = false;
					WaveCountDown = 15;
					WaveNum++;
				}
			}
			else if ( (Level.TimeSeconds > NextMonsterTime) && (NumMonsters < MaxMonsters) )
			{
				AddMonster();
				if ( NumMonsters < 1.5 * (NumPlayers + NumBots) )
					NextMonsterTime = Level.TimeSeconds + 0.2;
				else
					NextMonsterTime = Level.TimeSeconds + 2;
			}
		}
		else if ( NumMonsters <= 0 )
		{
			if ( WaveNum == FinalWave )
			{
				EndGame(None,"TimeLimit");
				return;
			}
			WaveCountDown--;
			if ( WaveCountDown == 14 )
			{
				for ( C = Level.ControllerList; C != None; C = C.NextController )
				{
					if ( C.PlayerReplicationInfo != None )
					{
						C.PlayerReplicationInfo.bOutOfLives = false;
						C.PlayerReplicationInfo.NumLives = 0;
						if ( C.Pawn != None )
							ReplenishWeapons(C.Pawn);
						else if ( !C.PlayerReplicationInfo.bOnlySpectator && (PlayerController(C) != None) )
							C.GotoState('PlayerWaiting');
					}
				}
			}
            if ( WaveCountDown == 13 )
            {
				InvasionGameReplicationInfo(GameReplicationInfo).WaveNumber = WaveNum;
				for ( C = Level.ControllerList; C != None; C = C.NextController )
				{
                    if ( PlayerController(C) != None )
                    {
						PlayerController(C).PlayStatusAnnouncement('Next_wave_in',1,true);
						if ( (C.Pawn == None) && !C.PlayerReplicationInfo.bOnlySpectator )
							PlayerController(C).SetViewTarget(C);
					}
					if ( C.PlayerReplicationInfo != None )
					{
						C.PlayerReplicationInfo.bOutOfLives = false;
						C.PlayerReplicationInfo.NumLives = 0;
						if ( (C.Pawn == None) && !C.PlayerReplicationInfo.bOnlySpectator )
							C.ServerReStartPlayer();
					}
				}
			}
	        else if ( (WaveCountDown > 1) && (WaveCountDown < 12) )
				BroadcastLocalizedMessage(class'TimerMessage', WaveCountDown-1);
			else if ( WaveCountDown <= 1 )
			{
				bWaveInProgress = true;
				SetupWave();
				for ( C = Level.ControllerList; C != None; C = C.NextController )
					if ( PlayerController(C) != None )
						PlayerController(C).LastPlaySpeech = 0;
				for ( C = Level.ControllerList; C != None; C = C.NextController )
					if ( Bot(C) != None )
					{
						B = Bot(C);
						InvasionBot(B).bDamagedMessage = false;
						B.bInitLifeMessage = false;
						if ( !bOneMessage && (FRand() < 0.65) )
						{
							bOneMessage = true;
							if ( (B.Squad.SquadLeader != None) && B.Squad.CloseToLeader(C.Pawn) )
							{
								B.SendMessage(B.Squad.SquadLeader.PlayerReplicationInfo, 'OTHER', B.GetMessageIndex('INPOSITION'), 20, 'TEAM');
								B.bInitLifeMessage = false;
							}
						}
					}
 			}
		}
	}

	function BeginState()
	{
		Super.BeginState();
		WaveNum = InitialWave;
		InvasionGameReplicationInfo(GameReplicationInfo).WaveNumber = WaveNum;
	}
}

function GetServerDetails( out ServerResponseLine ServerState )
{
	Super.GetServerDetails(ServerState);
	AddServerDetail( ServerState, "InitialWave", InitialWave );
	AddServerDetail( ServerState, "FinalWave", FinalWave );
}

static function FillPlayInfo(PlayInfo PI)
{
	Super.FillPlayInfo(PI);

	PI.AddSetting(default.GameGroup,   "InitialWave",  GetDisplayText("InitialWave"), 50,  0,  "Text", "2;0:"$(ArrayCount(default.Waves)-1) );
	PI.AddSetting(default.GameGroup,   "FinalWave",      GetDisplayText("FinalWave"), 50,  0,  "Text", "2;1:"$ArrayCount(default.Waves) );
	PI.AddSetting(default.GameGroup,   "Waves",              GetDisplayText("Waves"), 60,  0,"Custom",      ";;"$default.WaveConfigMenu,,,True);
}

static event string GetDisplayText( string PropName )
{
	switch (PropName)
	{
	case "InitialWave":     return default.InvasionPropText[0];
	case "FinalWave":       return default.InvasionPropText[1];
	case "Waves":           return default.InvasionPropText[2];
	case "Monsters":        return default.InvasionPropText[3];
	case "WaveNo":          return default.InvasionPropText[4];
	case "WaveMaxMonsters": return default.InvasionPropText[5];
	case "WaveDuration":    return default.InvasionPropText[6];
	case "WaveDifficulty":  return default.InvasionPropText[7];
	}

	return Super.GetDisplayText( PropName );
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
	case "InitialWave":     return default.InvasionDescText[0];
	case "FinalWave":       return default.InvasionDescText[1];
	case "Waves":           return default.InvasionDescText[2];
	case "Monsters":        return default.InvasionDescText[3];
	case "WaveNo":          return default.InvasionDescText[4];
	case "WaveMaxMonsters": return default.InvasionDescText[5];
	case "WaveDuration":    return default.InvasionDescText[6];
	case "WaveDifficulty":  return default.InvasionDescText[7];
	}

	return Super.GetDescriptionText(PropName);
}

static event bool AcceptPlayInfoProperty(string PropertyName)
{
	if ( (PropertyName == "bBalanceTeams")
		|| (PropertyName == "bPlayersBalanceTeams")
		|| (PropertyName == "GoalScore") )
		return false;

	return Super.AcceptPlayInfoProperty(PropertyName);
}

defaultproperties
{
     MonsterClass(0)=Class'SkaarjPack.SkaarjPupae'
     MonsterClass(1)=Class'SkaarjPack.Razorfly'
     MonsterClass(2)=Class'SkaarjPack.Manta'
     MonsterClass(3)=Class'SkaarjPack.Krall'
     MonsterClass(4)=Class'SkaarjPack.EliteKrall'
     MonsterClass(5)=Class'SkaarjPack.Gasbag'
     MonsterClass(6)=Class'SkaarjPack.Brute'
     MonsterClass(7)=Class'SkaarjPack.Skaarj'
     MonsterClass(8)=Class'SkaarjPack.Behemoth'
     MonsterClass(9)=Class'SkaarjPack.IceSkaarj'
     MonsterClass(10)=Class'SkaarjPack.FireSkaarj'
     MonsterClass(11)=Class'SkaarjPack.WarLord'
     MonsterClass(12)=Class'SkaarjPack.SkaarjPupae'
     MonsterClass(13)=Class'SkaarjPack.SkaarjPupae'
     MonsterClass(14)=Class'SkaarjPack.Razorfly'
     MonsterClass(15)=Class'SkaarjPack.Razorfly'
     WaveConfigMenu="GUI2K4.UT2K4InvasionWaveConfig"
     FallbackMonsterClass="SkaarjPack.EliteKrall"
     FinalWave=16
     InvasionPropText(0)="Starting Wave"
     InvasionPropText(1)="Final Wave"
     InvasionPropText(2)="Wave Configuration"
     InvasionPropText(3)="Invaders"
     InvasionPropText(4)="Wave Number"
     InvasionPropText(5)="Max Invaders"
     InvasionPropText(6)="Duration"
     InvasionPropText(7)="Difficulty"
     InvasionDescText(0)="Specify the first wave of incoming monsters for a map."
     InvasionDescText(1)="Specify the final wave which must be defeated to complete a map."
     InvasionDescText(2)="Configure the properties for each wave."
     InvasionDescText(3)="Select the wave to configure"
     InvasionDescText(4)="Place a check next to each monster which should be part of this wave."
     InvasionDescText(5)="Maximum amount of monsters that may be in the map at one time."
     InvasionDescText(6)="Length of time (in seconds) the wave should last."
     InvasionDescText(7)="Adjusts the relative intelligence of the invaders"
     WaveCountDown=15
     InvasionBotNames(1)="Gorge"
     InvasionBotNames(2)="Cannonball"
     InvasionBotNames(3)="Annika"
     InvasionBotNames(4)="Riker"
     InvasionBotNames(5)="BlackJack"
     InvasionBotNames(6)="Sapphire"
     InvasionBotNames(7)="Jakob"
     InvasionBotNames(8)="Othello"
     InvasionEnd(0)="SKAARJtermination"
     InvasionEnd(1)="SKAARJslaughter"
     InvasionEnd(2)="SKAARJextermination"
     InvasionEnd(3)="SKAARJerradication"
     InvasionEnd(4)="SKAARJbloodbath"
     InvasionEnd(5)="SKAARJannihilation"
     Waves(0)=(WaveMask=20491,WaveMaxMonsters=16,WaveDuration=90)
     Waves(1)=(WaveMask=60,WaveMaxMonsters=12,WaveDuration=90)
     Waves(2)=(WaveMask=105,WaveMaxMonsters=12,WaveDuration=90)
     Waves(3)=(WaveMask=186,WaveMaxMonsters=12,WaveDuration=90,WaveDifficulty=0.500000)
     Waves(4)=(WaveMask=225,WaveMaxMonsters=12,WaveDuration=90,WaveDifficulty=0.500000)
     Waves(5)=(WaveMask=966,WaveMaxMonsters=12,WaveDuration=90,WaveDifficulty=0.500000)
     Waves(6)=(WaveMask=4771,WaveMaxMonsters=12,WaveDuration=120,WaveDifficulty=1.000000)
     Waves(7)=(WaveMask=917,WaveMaxMonsters=12,WaveDuration=120,WaveDifficulty=1.000000)
     Waves(8)=(WaveMask=1689,WaveMaxMonsters=12,WaveDuration=120,WaveDifficulty=1.000000)
     Waves(9)=(WaveMask=18260,WaveMaxMonsters=12,WaveDuration=120,WaveDifficulty=1.000000)
     Waves(10)=(WaveMask=14340,WaveMaxMonsters=12,WaveDuration=180,WaveDifficulty=1.500000)
     Waves(11)=(WaveMask=4021,WaveMaxMonsters=12,WaveDuration=180,WaveDifficulty=1.500000)
     Waves(12)=(WaveMask=3729,WaveMaxMonsters=12,WaveDuration=180,WaveDifficulty=1.500000)
     Waves(13)=(WaveMask=3972,WaveMaxMonsters=12,WaveDuration=180,WaveDifficulty=2.000000)
     Waves(14)=(WaveMask=3712,WaveMaxMonsters=12,WaveDuration=180,WaveDifficulty=2.000000)
     Waves(15)=(WaveMask=2048,WaveMaxMonsters=8,WaveDuration=255,WaveDifficulty=2.000000)
     TeamAIType(0)=Class'SkaarjPack.InvasionTeamAI'
     TeamAIType(1)=Class'SkaarjPack.InvasionTeamAI'
     bPlayersMustBeReady=True
     bForceNoPlayerLights=True
     DefaultMaxLives=1
     InitialBots=2
     EndGameSoundName(0)="You_Have_Won_the_Match"
     EndGameSoundName(1)="You_Have_Lost_the_Match"
     LoginMenuClass="GUI2K4.UT2K4InvasionLoginMenu"
     SPBotDesc="Specify the number of bots (max 2 for invasion) that should join."
     ScoreBoardType="Skaarjpack.ScoreboardInvasion"
     HUDType="Skaarjpack.HudInvasion"
     MapListType="Skaarjpack.MapListSkaarjInvasion"
     MaxLives=1
     DeathMessageClass=Class'SkaarjPack.InvasionDeathMessage'
     MutatorClass="Skaarjpack.InvasionMutator"
     GameReplicationInfoClass=Class'SkaarjPack.InvasionGameReplicationInfo'
     GameName="Invasion"
     Description="Along side the other players, you must hold out as long as possible against the waves of attacking monsters."
     ScreenShotName="UT2004Thumbnails.InvasionShots"
     Acronym="INV"
     GIPropsDisplayText(0)="Monster Skill"
     GIPropDescText(0)="Set the skill of the invading monsters."
}
