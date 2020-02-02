//=============================================================================
// CTFGame.
//=============================================================================
class CTFGame extends TeamGame
	CacheExempt
	config;

var(LoadingHints) private localized array<string> CTFHints;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTeamFlags();
}

function RegisterVehicle(Vehicle V)
{
	Super.RegisterVehicle(V);
	//V.bTeamLocked = false;
}

static function PrecacheGameAnnouncements(AnnouncerVoice V, bool bRewardSounds)
{
	Super.PrecacheGameAnnouncements(V,bRewardSounds);
	if ( !bRewardSounds )
	{
		V.PrecacheSound('Red_Flag_Returned');
		V.PrecacheSound('Blue_Flag_Returned');
		V.PrecacheSound('Red_Flag_Dropped');
		V.PrecacheSound('Blue_Flag_Dropped');
		V.PrecacheSound('Red_Flag_Taken');
		V.PrecacheSound('Blue_Flag_Taken');
	}
	else
			V.PrecacheSound('Denied');
}

/* OBSOLETE UpdateAnnouncements() - preload all announcer phrases used by this actor */
simulated function UpdateAnnouncements() {}

function bool NearGoal(Controller C)
{
	local PlayerReplicationInfo P;

	P = C.PlayerReplicationInfo;
	return ( CTFBase(P.Team.HomeBase).myFlag.bHome && (VSize(C.Pawn.Location - P.Team.HomeBase.Location) < 1000) );
}

static function int OrderToIndex(int Order)
{
	if(Order == 2)
		return 10;

	if(Order == 0)
		return 11;

	return Order;
}

function float SpawnWait(AIController B)
{
	if ( B.PlayerReplicationInfo.bOutOfLives )
		return 999;
	if ( Level.NetMode == NM_Standalone )
	{
		if ( NumBots < 4 )
			return 0;
		if ( !CTFSquadAI(Bot(B).Squad).FriendlyFlag.bHome && (Numbots <= 16) )
			return FRand();
		return ( 0.5 * FMax(2,NumBots-4) * FRand() );
	}
	return FRand();
}

function SetTeamFlags()
{
	local CTFFlag F;

	// associate flags with teams
	ForEach AllActors(Class'CTFFlag',F)
	{
		F.Team = Teams[F.TeamNum];
		F.Team.HomeBase = F.HomeBase;
		CTFTeamAI(F.Team.AI).FriendlyFlag = F;
		if ( F.TeamNum == 0 )
			CTFTeamAI(Teams[1].AI).EnemyFlag = F;
		else
			CTFTeamAI(Teams[0].AI).EnemyFlag = F;
	}
}

function GameObject GetGameObject( Name GameObjectName )
{
	local int i;

	for ( i = 0; i < ArrayCount(Teams); i++ )
	{
		if ( CTFTeamAI(Teams[i].AI).FriendlyFlag.IsA(GameObjectName) )
			return CTFTeamAI(Teams[i].AI).FriendlyFlag;
	}

	return Super.GetGameObject(GameObjectName);
}

function Logout(Controller Exiting)
{
	if ( Exiting.PlayerReplicationInfo.HasFlag != None )
		CTFFlag(Exiting.PlayerReplicationInfo.HasFlag).Drop(vect(0,0,0));
	Super.Logout(Exiting);
}

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	local CTFFlag BestFlag;
	local Controller P;
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

	if ( (GameRulesModifiers != None) && !GameRulesModifiers.CheckEndGame(Winner, Reason) )
		return false;

	if ( bLastMan )
		GameReplicationInfo.Winner = Winner.Team;
	else
	{
		if ( Teams[1].Score == Teams[0].Score )
		{
			if ( !bOverTimeBroadcast )
			{
				StartupStage = 7;
				PlayStartupMessage();
				bOverTimeBroadcast = true;
			}
			return false;
		}
		if ( Teams[1].Score > Teams[0].Score )
			GameReplicationInfo.Winner = Teams[1];
		else
			GameReplicationInfo.Winner = Teams[0];
	}

	BestFlag = CTFTeamAI(UnrealTeamInfo(GameReplicationInfo.Winner).AI).FriendlyFlag;
	EndGameFocus = BestFlag.HomeBase;
	EndGameFocus.bHidden = false;

	EndTime = Level.TimeSeconds + EndTimeDelay;
	for ( P=Level.ControllerList; P!=None; P=P.nextController )
	{
		P.GameHasEnded();
		Player = PlayerController(P);
		if ( Player != None )
		{
			Player.ClientSetBehindView(true);
			Player.ClientSetViewTarget(EndGameFocus);
			Player.SetViewTarget(EndGameFocus);
			if ( !Player.PlayerReplicationInfo.bOnlySpectator )
				PlayWinMessage(Player, (Player.PlayerReplicationInfo.Team == GameReplicationInfo.Winner));
			Player.ClientGameEnded();
			if ( CurrentGameProfile != None )
				CurrentGameProfile.bWonMatch = (Player.PlayerReplicationInfo.Team == GameReplicationInfo.Winner);
		}
	}
	BestFlag.HomeBase.bHidden = false;
	BestFlag.bHidden = true;
	return true;
}

function ScoreGameObject( Controller C, GameObject GO )
{
	Super.ScoreGameObject(C,GO);
	if ( GO.IsA('CTFFlag') )
		ScoreFlag(C, CTFFlag(GO));
}

function ScoreFlag(Controller Scorer, CTFFlag theFlag)
{
	local float Dist,oppDist;
	local int i;
	local float ppp,numtouch;
	local vector FlagLoc;

	if ( Scorer.PlayerReplicationInfo.Team == theFlag.Team )
	{
		Scorer.AwardAdrenaline(ADR_Return);
		FlagLoc = TheFlag.Position().Location;
		Dist = vsize(FlagLoc - TheFlag.HomeBase.Location);

		if (TheFlag.TeamNum==0)
			oppDist = vsize(FlagLoc - Teams[1].HomeBase.Location);
		else
  			oppDist = vsize(FlagLoc - Teams[0].HomeBase.Location);

		GameEvent("flag_returned",""$theFlag.Team.TeamIndex,Scorer.PlayerReplicationInfo);
		BroadcastLocalizedMessage( class'CTFMessage', 1, Scorer.PlayerReplicationInfo, None, TheFlag.Team );

		if (Dist>1024)
		{
			// figure out who's closer
			if (Dist<=oppDist)	// In your team's zone
			{
				Scorer.PlayerReplicationInfo.Score += 3;
				ScoreEvent(Scorer.PlayerReplicationInfo,3,"flag_ret_friendly");
			}
			else
			{
				Scorer.PlayerReplicationInfo.Score += 5;
				ScoreEvent(Scorer.PlayerReplicationInfo,5,"flag_ret_enemy");

				if (oppDist<=1024)	// Denial
				{
  					Scorer.PlayerReplicationInfo.Score += 7;
					ScoreEvent(Scorer.PlayerReplicationInfo,7,"flag_denial");
				}

			}
		}
		return;
	}

	// Figure out Team based scoring.
	if (TheFlag.FirstTouch!=None)	// Original Player to Touch it gets 5
	{
		ScoreEvent(TheFlag.FirstTouch.PlayerReplicationInfo,5,"flag_cap_1st_touch");
		TheFlag.FirstTouch.PlayerReplicationInfo.Score += 5;
		TheFlag.FirstTouch.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
	}

	// Guy who caps gets 5
	Scorer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
	Scorer.PlayerReplicationInfo.Score += 5;
	IncrementGoalsScored(Scorer.PlayerReplicationInfo);
    Scorer.AwardAdrenaline(ADR_Goal);

	// Each player gets 20/x but it's guarenteed to be at least 1 point but no more than 5 points
	numtouch=0;
	for (i=0;i<TheFlag.Assists.length;i++)
	{
		if (TheFlag.Assists[i]!=None)
			numtouch = numtouch + 1.0;
	}

	ppp = FClamp(20/numtouch,1,5);

	for (i=0;i<TheFlag.Assists.length;i++)
	{
		if (TheFlag.Assists[i]!=None)
		{
			ScoreEvent(TheFlag.Assists[i].PlayerReplicationInfo,ppp,"flag_cap_assist");
			TheFlag.Assists[i].PlayerReplicationInfo.Score += int(ppp);
		}
	}

	// Apply the team score
	Scorer.PlayerReplicationInfo.Team.Score += 1.0;
	Scorer.PlayerReplicationInfo.Team.NetUpdateTime = Level.TimeSeconds - 1;
	ScoreEvent(Scorer.PlayerReplicationInfo,5,"flag_cap_final");
	TeamScoreEvent(Scorer.PlayerReplicationInfo.Team.TeamIndex,1,"flag_cap");
	GameEvent("flag_captured",""$theflag.Team.TeamIndex,Scorer.PlayerReplicationInfo);

	BroadcastLocalizedMessage( class'CTFMessage', 0, Scorer.PlayerReplicationInfo, None, TheFlag.Team );
	AnnounceScore(Scorer.PlayerReplicationInfo.Team.TeamIndex);
	CheckScore(Scorer.PlayerReplicationInfo);

    if ( bOverTime )
    {
		EndGame(Scorer.PlayerReplicationInfo,"timelimit");
    }
}

function DiscardInventory( Pawn Other )
{
	if ( (Other.PlayerReplicationInfo != None) && (Other.PlayerReplicationInfo.HasFlag != None) )
		CTFFlag(Other.PlayerReplicationInfo.HasFlag).Drop(0.5 * Other.Velocity);

	Super.DiscardInventory(Other);

}

static function array<string> GetAllLoadHints(optional bool bThisClassOnly)
{
	local int i;
	local array<string> Hints;

	if ( !bThisClassOnly || default.CTFHints.Length == 0 )
		Hints = Super.GetAllLoadHints();

	for ( i = 0; i < default.CTFHints.Length; i++ )
		Hints[Hints.Length] = default.CTFHints[i];

	return Hints;
}

State MatchOver
{
	function ScoreFlag(Controller Scorer, CTFFlag theFlag)
	{
	}
}

defaultproperties
{
     CTFHints(0)="You can use %BASEPATH 0% to see the path to the Red Team base and %BASEPATH 1% to see the path to the Blue Team base."
     CTFHints(1)="Firing the translocator sends out your translocator beacon.  Pressing %FIRE% again returns the beacon, while pressing %A:TFIRE% teleports you instantly to the beacon's location (if you fit)."
     CTFHints(2)="Using the translocator to teleport while carrying the flag will cause you to drop the flag."
     CTFHints(3)="Pressing %SWITCHWEAPON 10% after tossing the Translocator allows you to view from its internal camera."
     CTFHints(4)="Pressing %FIRE% while your %ALTFIRE% is still held down after teleporting with the translocator will switch you back to your previous weapon."
     bScoreTeamKills=False
     bSpawnInTeamArea=True
     bScoreVictimsTarget=True
     TeamAIType(0)=Class'UnrealGame.CTFTeamAI'
     TeamAIType(1)=Class'UnrealGame.CTFTeamAI'
     bAllowTrans=True
     bDefaultTranslocator=True
     bMustHaveMultiplePlayers=False
     ADR_Kill=2.000000
     MapPrefix="CTF"
     BeaconName="CTF"
     GoalScore=3
     Description="Your team must score flag captures by taking the enemy flag from the enemy base and returning it to their own flag.  If the flag carrier is killed, the flag drops to the ground for anyone to pick up.  If your team's flag is taken, it must be returned (by touching it after it is dropped) before your team can score a flag capture."
}
