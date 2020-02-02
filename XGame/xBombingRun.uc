//=============================================================================
// xBombingRun.
//=============================================================================
class xBombingRun extends TeamGame
	config;

#exec OBJ LOAD FILE=E_Pickups.usx

var globalconfig bool 	bBallDrainsTransloc;

var localized string BRPropText,BRPropText2;
var localized string BRDescText,BRDescText2;

var transient int TeamSpawnCount[2];
var xBombFlag Bomb;

var sound NewRoundSound;  // OBSOLETE
var float OldScore;

var(LoadingHints) private localized array<string> BRHints;


static function array<string> GetAllLoadHints(optional bool bThisClassOnly)
{
	local int i;
	local array<string> Hints;

	if ( !bThisClassOnly || default.BRHints.Length == 0 )
		Hints = Super.GetAllLoadHints();

	for ( i = 0; i < default.BRHints.Length; i++ )
		Hints[Hints.Length] = default.BRHints[i];

	return Hints;
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

	// associate flags with teams
	ForEach DynamicActors(Class'xBombFlag',Bomb)
	{
		BombingRunTeamAI(Teams[0].AI).Bomb = Bomb;
		BombingRunTeamAI(Teams[1].AI).Bomb = Bomb;
		Bomb.bBallDrainsTransloc = bBallDrainsTransloc;
    }
	SetTeamBases();
}

function bool NearGoal(Controller C)
{
	return ( (VSize(C.Pawn.Location - BombingRunTeamAI(Teams[C.PlayerReplicationInfo.Team.TeamIndex].AI).EnemyBase.Location) < 1000) );
}

static function PrecacheGameAnnouncements(AnnouncerVoice V, bool bRewardSounds)
{
	Super.PrecacheGameAnnouncements(V,bRewardSounds);
	if ( !bRewardSounds )
	{
		V.PrecacheSound('NewRoundIn');
		V.PrecacheSound('BallReset');
		V.PrecacheSound('Red_Pass_Fumbled');
		V.PrecacheSound('Blue_Pass_Fumbled');
		V.PrecacheSound('Red_Team_on_Offence');
		V.PrecacheSound('Blue_Team_on_Offence');
		V.PrecacheSound('Last_Second_Save');
	}
}

/* OBSOLETE UpdateAnnouncements() - preload all announcer phrases used by this actor */
simulated function UpdateAnnouncements() {}

static function int OrderToIndex(int Order)
{
	if(Order == 2)
		return 14;

	return Order;
}

//------------------------------------------------------------------------------
// Game Querying.
function GetServerDetails( out ServerResponseLine ServerState )
{
	Super.GetServerDetails( ServerState );
	AddServerDetail( ServerState, "BallDrainsTranslocator", bBallDrainsTransloc );
}

static function PrecacheGameTextures(LevelInfo myLevel)
{
	class'xTeamGame'.static.PrecacheGameTextures(myLevel);

	myLevel.AddPrecacheMaterial(Material'WeaponSkins.BallLauncherTex0');
	myLevel.AddPrecacheMaterial(Material'WeaponSkins.BallLauncherEnergy');
	myLevel.AddPrecacheMaterial(Material'WeaponSkins.BallLauncherLine');

	myLevel.AddPrecacheMaterial(Material'XEffects.RedMarker_T');
	myLevel.AddPrecacheMaterial(Material'XEffects.BlueMarker_T');
	myLevel.AddPrecacheMaterial(Material'XGameShaders.BombIconBlue');
	myLevel.AddPrecacheMaterial(Material'XGameShaders.BombIconRed');
	myLevel.AddPrecacheMaterial(Material'XGameShaders.BombIconYELLOW');
	myLevel.AddPrecacheMaterial(Material'XGameShaders.BRBall');
	myLevel.AddPrecacheMaterial(Material'XGameTextures.BombDeliveryTex');
}

static function PrecacheGameStaticMeshes(LevelInfo myLevel)
{
	class'xDeathMatch'.static.PrecacheGameStaticMeshes(myLevel);

	myLevel.AddPrecacheStaticMesh(StaticMesh'XGame_rc.BombSpawnMesh');
	myLevel.AddPrecacheStaticMesh(StaticMesh'XGame_rc.BombEffectMesh');
	myLevel.AddPrecacheStaticMesh(StaticMesh'E_Pickups.FullBomb');
}

function SetTeamBases()	// Important for tracking
{
	local xBombDelivery B;

	// associate flags with teams
	ForEach AllActors(Class'xBombDelivery',B)
	{
		Teams[B.Team].HomeBase = B;
	}
}

function GameObject GetGameObject( Name GameObjectName )
{
	// temp - sanity check
	assert(bomb != None && bomb.IsA(GameObjectName));

	if ( Bomb.IsA(GameObjectName) )
		return Bomb;

	return Super.GetGameObject(GameObjectName);
}

function Logout(Controller Exiting)
{
	if ( xBombFlag(Exiting.PlayerReplicationInfo.HasFlag) != None )
		xBombFlag(Exiting.PlayerReplicationInfo.HasFlag).Drop(vect(0,0,0));
	Super.Logout(Exiting);
}

function DiscardInventory( Pawn Other )
{
	if ( (Other.PlayerReplicationInfo != None) && (Other.PlayerReplicationInfo.HasFlag != None) )
        xBombFlag(Other.PlayerReplicationInfo.HasFlag).Drop(0.5 * Other.Velocity);
	Super.DiscardInventory(Other);
}

function ScoreGameObject( Controller C, GameObject GO )
{
	Super.ScoreGameObject(C,GO);
	if ( GO.IsA('xBombFlag') )
		ScoreBomb(C, xBombFlag(GO));
}

function ScoreBomb(Controller Scorer, xBombFlag theFlag)
{
    local bool ThrowingScore;
	local int i;
	local float ppp,numtouch,maxpoints,maxper;
	local controller C;

    Bomb = theFlag;

    if( ResetCountDown > 0 )
    {
        //log("Ignoring score during reset countdown.",'BombingRun');
        theFlag.SendHome();
        return;
    }

	// blow up all redeemer guided warheads
	for ( C=Level.ControllerList; C!=None; C=C.NextController )
		if ( (C.Pawn != None) && C.Pawn.IsA('RedeemerWarhead') )
			C.Pawn.Fire(0);

    // are we dealing with a throwing score?
    if (Scorer.PlayerReplicationInfo.HasFlag == None)
        ThrowingScore = true;
    if ( (Scorer.Pawn != None) && Scorer.Pawn.Weapon.IsA('BallLauncher') )
		Scorer.ClientSwitchToBestWeapon();

	theFlag.Instigator = none;	// jmw - need this to stop the reentering of ScoreBomb due to touch with the base

    // awards for scoring
	IncrementGoalsScored(Scorer.PlayerReplicationInfo);
	OldScore = Scorer.PlayerReplicationInfo.Team.Score;
    if (ThrowingScore)
	{
        Scorer.PlayerReplicationInfo.Team.Score += 3.0;
		Scorer.PlayerReplicationInfo.Team.NetUpdateTime = Level.TimeSeconds - 1;
		TeamScoreEvent(Scorer.PlayerReplicationInfo.Team.TeamIndex,3,"ball_tossed");

		// Individual points

		Scorer.PlayerReplicationInfo.Score += 2; // Just for scoring
		MaxPoints=10;
		MaxPer=2;
		ScoreEvent(Scorer.PlayerReplicationInfo,5,"ball_thrown_final");
	}
    else
	{
  		Scorer.PlayerReplicationInfo.Team.Score += 7.0;
		Scorer.PlayerReplicationInfo.Team.NetUpdateTime = Level.TimeSeconds - 1;
		TeamScoreEvent(Scorer.PlayerReplicationInfo.Team.TeamIndex,7,"ball_carried");

		// Individual points

		Scorer.PlayerReplicationInfo.Score += 5; // Just for scoring
		MaxPoints=20;
		MaxPer=5;
		ScoreEvent(Scorer.PlayerReplicationInfo,5,"ball_cap_final");
	}
	Scorer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;

	// Each player gets MaxPoints/x but it's guarenteed to be at least 1 point but no more than MaxPer points
	numtouch=0;
	for (i=0;i<TheFlag.Assists.length;i++)
	{
		if ( (TheFlag.Assists[i]!=None) && (TheFlag.Assists[i].PlayerReplicationInfo.Team == Scorer.PlayerReplicationInfo.Team) )
			numtouch = numtouch + 1.0;
	}

	ppp = MaxPoints / numtouch;
	if (ppp<1.0)
		ppp = 1.0;

	if (ppp>MaxPer)
		ppp = MaxPer;

	for (i=0;i<TheFlag.Assists.length;i++)
	{
		if ( (TheFlag.Assists[i]!=None) && (TheFlag.Assists[i].PlayerReplicationInfo.Team == Scorer.PlayerReplicationInfo.Team) )
		{
			ScoreEvent(TheFlag.Assists[i].PlayerReplicationInfo,ppp,"ball_score_assist");
			TheFlag.Assists[i].PlayerReplicationInfo.Score += int(ppp);
		}
	}

    Scorer.AwardAdrenaline(ADR_Goal);
	BroadcastLocalizedMessage( class'xBombMessage', 0, Scorer.PlayerReplicationInfo, None, None );
	AnnounceScore(Scorer.PlayerReplicationInfo.Team.TeamIndex);

    if ( (bOverTime || (GoalScore != 0)) && (Teams[Scorer.PlayerReplicationInfo.Team.TeamIndex].Score >= GoalScore) )
		EndGame(Scorer.PlayerReplicationInfo,"teamscorelimit");
	else if ( bOverTime )
		EndGame(Scorer.PlayerReplicationInfo,"timelimit");

    ResetCountDown = ResetTimeDelay+1;
    if ( bGameEnded )
        theFlag.Score();
    else
        theFlag.SendHomeDisabled(ResetTimeDelay);
}

State MatchInProgress
{
	function Timer()
	{
        local Controller C;
        local Projectile Proj;
		local Inventory Inv;

        Super.Timer();

        if (ResetCountDown > 0)
        {
            ResetCountDown--;
            if ( ResetCountDown < 3 )
            {
				// blow up all redeemer guided warheads
				for ( C=Level.ControllerList; C!=None; C=C.NextController )
					if ( (C.Pawn != None) && C.Pawn.IsA('RedeemerWarhead') )
						C.Pawn.Fire(1);
			}
            if ( ResetCountDown == 8 )
            {
                for ( C = Level.ControllerList; C != None; C = C.NextController )
                    if ( PlayerController(C) != None )
						PlayerController(C).PlayStatusAnnouncement('NewRoundIn',1,true);
			}
	        else if ( (ResetCountDown > 1) && (ResetCountDown < 7) )
				BroadcastLocalizedMessage(class'TimerMessage', ResetCountDown-1);
            else if (ResetCountDown == 1)
            {
				// reset all bot enemies
				Teams[0].AI.ClearEnemies();
				Teams[1].AI.ClearEnemies();

                // reset all players position and rotation on the field for the next round
                for ( C = Level.ControllerList; C != None; C = C.NextController )
					if ( (C.PlayerReplicationInfo != None) && !C.PlayerReplicationInfo.bOnlySpectator )
    				{
   						C.StartSpot = FindPlayerStart(C, C.PlayerReplicationInfo.Team.TeamIndex);
    					if ( C.StartSpot != None )
    					{
							C.SetLocation(C.StartSpot.Location);
							C.SetRotation(C.StartSpot.Rotation);
						}
						if ( C.Pawn != None )
						{
							if ( xPawn(C.Pawn) != None )
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
							C.Pawn.Health = Max(C.Pawn.Health,C.Pawn.HealthMax);
							SetPlayerDefaults(C.Pawn);
							C.Pawn.SetLocation(C.StartSpot.Location);
							C.Pawn.SetRotation(C.StartSpot.Rotation);
							C.Pawn.Velocity = vect(0,0,0);
							C.Pawn.PlayTeleportEffect(false, true);
							for ( Inv=C.Pawn.Inventory; Inv!=None; Inv=Inv.Inventory )
								if ( Inv.IsA('TransLauncher') )
									Weapon(Inv).GiveAmmo(0, None, false);
						}
    					if ( C.StartSpot != None )
							C.ClientSetLocation(C.StartSpot.Location,C.StartSpot.Rotation);
     				}

               // destroy projectiles
                foreach DynamicActors(class'Projectile', Proj)
                    Proj.Destroy();

                Bomb.SendHome();
                ResetCountDown = 0;
           }
        }
        else
        {
			if ( Bomb == None )
				ForEach DynamicActors(class'xBombFlag',Bomb)
					break;
			if ( Bomb != None )
				GameReplicationInfo.FlagPos = Bomb.Position().Location;
		}
    }
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

	if ( OldScore <= Teams[OtherTeam].Score )
	{
		if ( Teams[ScoringTeam].Score > Teams[OtherTeam].Score )
			ScoreSound = TakeLeadName[ScoringTeam];
		else
			ScoreSound = CaptureSoundName[ScoringTeam];
	}
	else
	{
		if ( OldScore <= Teams[OtherTeam].Score + 3 )
			ScoreSound = IncreaseLeadName[ScoringTeam];
		else
			ScoreSound = CaptureSoundName[ScoringTeam];
	}

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if ( C.IsA('PlayerController') )
			PlayerController(C).PlayStatusAnnouncement(ScoreSound,1,true);
	}
}

function actor FindSpecGoalFor(PlayerReplicationInfo PRI, int TeamIndex)
{
	local XPlayer PC;
    local Controller C;
    local xBombFlag b;

    PC = XPlayer(PRI.Owner);
    if (PC==None)
    	return none;

    // Look for a Player holding the flag
    for (C=Level.ControllerList;C!=None;C=C.NextController)
    {
    	if ( (C.PlayerReplicationInfo != None) && (C.PlayerReplicationInfo.HasFlag!=None) )
        	return C.Pawn;
    }

	foreach AllActors(class'xBombFlag',b)
    	return b;

    return none;
}

static function FillPlayInfo(PlayInfo PI)
{
	Super.FillPlayInfo(PI);

	PI.AddSetting(default.RulesGroup,  "bBallDrainsTransloc", default.BRPropText2, 40, 0, "Check",,,,True);
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "bBallDrainsTransloc": return default.BRDescText2;
	}

	return Super.GetDescriptionText(PropName);
}

function int BallCarrierMessage()
{
	return 15;
}

event SetGrammar()
{
	LoadSRGrammar("BR");
}

defaultproperties
{
     bBallDrainsTransloc=True
     BRPropText="Delay ball contact"
     BRPropText2="BallLauncher drains Translocator"
     BRDescText="If checked, a player must wait a few seconds after throwing the ball before picking it up again."
     BRDescText2="If checked, a player must wait a few seconds after throwing the ball before being able to translocate (or until someone else catches or picks up the ball)."
     BRHints(0)="You can use %BASEPATH 0% to see the path to the Red Team base and %BASEPATH 1% to see the path to the Blue Team base."
     BRHints(1)="Firing the translocator sends out your translocator beacon.  Pressing %FIRE% again returns the beacon, while pressing %A:TFIRE% teleports you instantly to the beacon's location (if you fit)."
     BRHints(2)="While carrying the ball, you can target teammates by pressing %ALTFIRE%.  Pressing %FIRE% will pass the ball to the targeted teammate."
     BRHints(3)="Pressing %SWITCHWEAPON 10% after tossing the Translocator allows you to view from its internal camera."
     BRHints(4)="Pressing %FIRE% while your %ALTFIRE% is still held down after teleporting with the translocator will switch you back to your previous weapon."
     bScoreTeamKills=False
     bSpawnInTeamArea=True
     TeamAIType(0)=Class'UnrealGame.BombingRunTeamAI'
     TeamAIType(1)=Class'UnrealGame.BombingRunTeamAI'
     bAllowTrans=True
     bDefaultTranslocator=True
     bMustHaveMultiplePlayers=False
     DefaultEnemyRosterClass="xGame.xTeamRoster"
     ADR_Kill=2.000000
     HUDType="XInterface.HudCBombingRun"
     MapListType="XInterface.MapListBombingRun"
     MapPrefix="BR"
     BeaconName="BR"
     ResetTimeDelay=11
     GoalScore=15
     DeathMessageClass=Class'XGame.xDeathMessage'
     OtherMesgGroup="BombingRun"
     GameName="Bombing Run"
     Description="Each level has a ball that starts in the middle of the playing field.  Your team scores by getting the ball through the enemy team's hoop.  You score 7 points for jumping through the hoop while holding the ball, and 3 points for tossing the ball through the hoop.  The ball can be passed to teammates, and is dropped if the player carrying it is killed."
     ScreenShotName="UT2004Thumbnails.BRShots"
     DecoTextName="XGame.BombingRun"
     Acronym="BR"
}
