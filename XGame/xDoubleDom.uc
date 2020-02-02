//=============================================================================
// xDoubleDom
//=============================================================================
class xDoubleDom extends TeamGame
	config;

// todo: doesn't handle the case where controllingpawn leaves the game or is killed (when it awards score, could be dangling...)
var() config int TimeToScore;               // duration both points must be controlled for to score a point

// TODO (rjp) update this class to use new time tracking vars that were merged from Onslaught/Assault/BombingRun
var() config int TimeDisabled;              // duration both points are disabled for after a point is scored

var   xDomPoint xDomPoints[2];              // the two domination points in the level
var   int ScoreCountDown;                   // count down until a point is scored
var   transient int DisabledCountDown;      // count down until points are re-enabled after a point is scored
var() Sound ControlSounds[2];               // OBSOLETE control sounds
var() Sound ScoreSounds[2];                 // OBSOLETE score sounds
var() Sound AvertedSounds[4];               // OBSOLETE score averted sounds
var() name ControlSoundNames[2];               // control sounds
var() name ScoreSoundNames[2];                 // score sounds
var() name AvertedSoundNames[4];               // score averted sounds
var sound NewRoundSound;  // OBSOLETE

// mc - localized PlayInfo descriptions & extra info
const DDPROPNUM = 2;
var localized string DDomPropsDisplayText[DDPROPNUM];
var localized string DDomPropDescText[DDPROPNUM];

static function PrecacheGameTextures(LevelInfo myLevel)
{
	class'xTeamGame'.static.PrecacheGameTextures(myLevel);

	myLevel.AddPrecacheMaterial(Material'XGameTextures.DOMpointGREY');
	myLevel.AddPrecacheMaterial(Material'XGameTextures.DOMpointLINESg');
	myLevel.AddPrecacheMaterial(Material'XGameTextures.DOMPointABg');
	myLevel.AddPrecacheMaterial(Material'XGameTextures.DOMPointABr');
	myLevel.AddPrecacheMaterial(Material'XGameTextures.DOMpointLINESr');
	myLevel.AddPrecacheMaterial(Material'XGameTextures.DOMpointRED');
	myLevel.AddPrecacheMaterial(Material'XGameTextures.RedScreenA');
	myLevel.AddPrecacheMaterial(Material'XGameTextures.DOMPointABb');
	myLevel.AddPrecacheMaterial(Material'XGameTextures.DOMpointLINESb');
	myLevel.AddPrecacheMaterial(Material'XGameTextures.DOMpointBLUE');
	myLevel.AddPrecacheMaterial(Material'XEffects.RedMarker_T');
	myLevel.AddPrecacheMaterial(Material'XEffects.BlueMarker_T');
}

static function PrecacheGameAnnouncements(AnnouncerVoice V, bool bRewardSounds)
{
	Super.PrecacheGameAnnouncements(V,bRewardSounds);
	if ( !bRewardSounds )
	{
		V.PrecacheSound(Default.ControlSoundNames[0]);
		V.PrecacheSound(Default.ControlSoundNames[1]);
		V.PrecacheSound(Default.ScoreSoundNames[0]);
		V.PrecacheSound(Default.ScoreSoundNames[1]);
		V.PrecacheSound(Default.AvertedSoundNames[1]);
		V.PrecacheSound(Default.AvertedSoundNames[3]);
		V.PrecacheSound('NewRoundIn');
	}
}

/* OBSOLETE UpdateAnnouncements() - preload all announcer phrases used by this actor */
simulated function UpdateAnnouncements() {}

// FIXME DDOM- 16 is alpha secure, 17 is bravo secure

function int GetStatus(PlayerController Sender, Bot B)
{
	local name BotOrders;

	BotOrders = B.GetOrders();
	if ( B.Pawn == None )
	{
		if ( (BotOrders == 'DEFEND') && (B.Squad.Size == 1) )
			return 0;
	}
	else if ( (B.Enemy == None) && (B.Squad.SquadObjective != None) && (B.Squad.SquadObjective.DefenderTeamIndex == B.Squad.Team.TeamIndex)
				&& B.LineOfSightTo(B.Squad.SquadObjective) )
	{
		if ( DominationPoint(B.Squad.SquadObjective).PrimaryTeam == 0 )
			return 16;
		else
			return 17;
	}
	else
		return super.GetStatus(Sender, B);

}
static function int OrderToIndex(int Order)
{
	if(Order == 0)
		return 12;

	if(Order == 2)
		return 13;

	return Order;
}

static function PrecacheGameStaticMeshes(LevelInfo myLevel)
{
	class'xDeathMatch'.static.PrecacheGameStaticMeshes(myLevel);

	myLevel.AddPrecacheStaticMesh(StaticMesh'XGame_rc.DomRing');
	myLevel.AddPrecacheStaticMesh(StaticMesh'XGame_rc.DomAMesh');
	myLevel.AddPrecacheStaticMesh(StaticMesh'XGame_rc.DomBMesh');
}

function PostBeginPlay()
{
	local NavigationPoint N;
	local int i;

	Super.PostBeginPlay();

    // find the first two domination points in the level
	i = 0;
	for(N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
	{
		if (N.IsA('xDomPoint'))
		{
			xDomPoints[i] = xDomPoint(N);
			xDomPoints[i].ResetCount = ResetCount;
			i++;
			if (i == 2) break;
		}
	}

    if (i != 2)
    {
        // there were not enough domination points in the level!
		log("xDoubleDom: Level has wrong number of Domination Points!",'Error');
	}
}

State MatchInProgress
{
	function Timer()
	{
		local Controller TeamMate;
		local int i;

		Super.Timer();

		if (bGameEnded || xDomPoints[0] == None || xDomPoints[1] == None)
			return;

		// are both points currently disabled?
		if (DisabledCountDown > 0)
		{
			DisabledCountDown--;
            if ( DisabledCountDown == 7 )
            {
                for ( TeamMate = Level.ControllerList; TeamMate != None; TeamMate = TeamMate.NextController )
                    if ( PlayerController(TeamMate) != None )
						PlayerController(TeamMate).PlayStatusAnnouncement('NewRoundIn',1,true);
			}
	        else if ( (DisabledCountDown > 0) && (DisabledCountDown < 6) )
				BroadcastLocalizedMessage(class'TimerMessage', DisabledCountDown);

			if (DisabledCountDown == 0)
			{
				xDomPoints[0].ResetPoint(true);
				xDomPoints[1].ResetPoint(true);
			}

		}

        // nothing more to do unless the same team controls both points
        if ( (xDomPoints[0].ControllingTeam != xDomPoints[1].ControllingTeam) || (xDomPoints[0].ControllingTeam == None) )
            return;

		if (ScoreCountDown == TimeToScore)
		{
		    for (TeamMate = Level.ControllerList; TeamMate != None; TeamMate = TeamMate.NextController)
            {
			    if (TeamMate.IsA('PlayerController'))
				    PlayerController(TeamMate).PlayStatusAnnouncement(ControlSoundNames[xDomPoints[0].ControllingTeam.TeamIndex],1,true);
        	}
		}

		if (ScoreCountDown > 0 && ScoreCountDown < 9)
		    BroadcastLocalizedMessage(class'TimerMessage', ScoreCountDown );

		if (ScoreCountDown > 0)
        {
            // decrement the time remaining until a point is scored
	        ScoreCountDown--;
            return;
        }

		for (TeamMate = Level.ControllerList; TeamMate != None; TeamMate = TeamMate.NextController)
        {
			if (TeamMate.IsA('PlayerController'))
			{
				PlayerController(TeamMate).PlayStatusAnnouncement(ScoreSoundNames[xDomPoints[0].ControllingTeam.TeamIndex],1,true);
				PlayerController(TeamMate).ClientPlaySound(class'CTFMessage'.Default.Riffs[Rand(3)]);
			}
        }

		// controlling team has scored!
        xDomPoints[0].ControllingTeam.Score += 1.0;
		xDomPoints[0].ControllingTeam.NetUpdateTime = Level.TimeSeconds - 1;

		TeamScoreEvent(xDomPoints[0].ControllingTeam.TeamIndex,1,"dom_teamscore");
        // award scoring players some Adrenaline and increase their score
		if ( (xDomPoints[0].ControllingPawn != None) && (xDomPoints[0].ControllingPawn.Controller != None) )
        {
            xDomPoints[0].ControllingPawn.Controller.PlayerReplicationInfo.Score += 5.0;
			xDomPoints[0].ControllingPawn.Controller.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
		    xDomPoints[0].ControllingPawn.Controller.AwardAdrenaline(ADR_Goal);
			ScoreEvent(xDomPoints[0].ControllingPawn.Controller.PlayerReplicationInfo,5,"dom_score");
        }

		if ( (xDomPoints[1].ControllingPawn != None) && (xDomPoints[1].ControllingPawn.Controller != None) )
        {
            xDomPoints[1].ControllingPawn.Controller.PlayerReplicationInfo.Score += 5.0;
			xDomPoints[1].ControllingPawn.Controller.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
		    xDomPoints[1].ControllingPawn.Controller.AwardAdrenaline(ADR_Goal);
			ScoreEvent(xDomPoints[1].ControllingPawn.Controller.PlayerReplicationInfo,5,"dom_score");

        }

		// reset count
        ScoreCountDown = TimeToScore;

		// make all control points be untouchable for a short period
		DisabledCountDown = TimeDisabled;

		// reset both domination points and disable them
		xDomPoints[0].ResetPoint(false);
		xDomPoints[1].ResetPoint(false);

        // check if the game is over because either team has achieved the goal limit
        if ( GoalScore > 0 )
        {
		    for (i = 0; i < 2; i++ )
            {
			    if ( Teams[i].Score >= GoalScore )
                {
				    EndGame(None,"teamscorelimit");
                }
            }
        }
    }
}

function ClearControl(Controller Other)
{
    local Controller P;
	local PlayerController Player;
    local Pawn Pick;

	if ( (PlayerController(Other) == None) || (Other.PlayerReplicationInfo.Team.TeamIndex == 255) )
		return;

	if ( (xDomPoints[0].ControllingPawn != Other) && (xDomPoints[1].ControllingPawn != Other) )
        return;

    // find a suitable teammate
	for( P=Level.ControllerList; P!=None; P=P.nextController )
	{
		Player = PlayerController(P);

		if ( (Player != None) && (Player != Other) && (Player.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team) )
		{
			Pick = Player.Pawn;
            break;
		}
	}

    // update both control points with the new controlling pawn, since the other one is leaving (if no other suitable
    // teammate was found, then the point will return to neutral)
    if (xDomPoints[0].ControllingPawn == Other)
	{
		xDomPoints[0].ControllingPawn = Pick;
		xDomPoints[0].UpdateStatus();
	}

	if (xDomPoints[1].ControllingPawn == Other)
	{
		xDomPoints[1].ControllingPawn = Pick;
		xDomPoints[1].UpdateStatus();
	}
}

function Logout( Controller Exiting )
{
    ClearControl(Exiting);
    Super.Logout(Exiting);
}

function ResetCount()
{
    local name Aversion;
	local Controller TeamMate;

    if ( ScoreCountDown < TimeToScore )
    {
        Aversion = AvertedSoundNames[1];
        if (TimeToScore - ScoreCountDown > (TimeToScore/2))
        {
            if (TimeToScore - ScoreCountDown >= (TimeToScore-1))
            {
                // within one second of a score
                Aversion = AvertedSoundNames[3];
            }
            else
            {
                // halfway to a score
                Aversion = AvertedSoundNames[2];
            }
        }
        else if ( TimeToScore - ScoreCountDown < 2 )
        {
			for (TeamMate = Level.ControllerList; TeamMate != None; TeamMate = TeamMate.NextController)
			{
				if (TeamMate.IsA('PlayerController'))
					PlayerController(TeamMate).PlayAnnouncement(Sound'GameSounds.DDAverted',2,true);
			}
		    ScoreCountDown = TimeToScore;
			return;
		}

        for (TeamMate = Level.ControllerList; TeamMate != None; TeamMate = TeamMate.NextController)
        {
			if (TeamMate.IsA('PlayerController'))
                PlayerController(TeamMate).PlayStatusAnnouncement(Aversion,2,true);
        }
    }

    ScoreCountDown = TimeToScore;
}

function bool CriticalPlayer(Controller Other)
{
	// In DOM, critical players are anyone within 1024 units of the dom point
	// who have los to it.

	if ( (vsize(Other.Pawn.Location - xDomPoints[0].Location) <=1024) ||
	     (vsize(Other.Pawn.Location - xDomPoints[1].Location) <=1024) )
		return true;

	return Super.CriticalPlayer(Other);
}

function Killed( Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType )
{
	if ( (Killer != None) && Killer.bIsPlayer && Killed.bIsPlayer &&
         (Killer.PlayerReplicationInfo.Team != Killed.PlayerReplicationInfo.Team)
         && (xPawn(Killer.Pawn) != None) && (DisabledCountDown > 0))
    {
        Killer.AwardAdrenaline(ADR_MinorBonus);
    }

	Super.Killed(Killer, Killed, KilledPawn, damageType);
}

function GetServerDetails(out ServerResponseLine ServerState)
{
	Super.GetServerDetails(ServerState);
	AddServerDetail( ServerState, "TimeToScore", TimeToScore );
	AddServerDetail( ServerState, "TimeDisabled", TimeDisabled );
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	local int i;

	Super.FillPlayInfo(PlayInfo);  // Always begin with calling parent

	PlayInfo.AddSetting("Game", "TimeToScore",  default.DDomPropsDisplayText[i++], 40, 1, "Text", "3;0:60",,,True);
	PlayInfo.AddSetting("Game", "TimeDisabled", default.DDomPropsDisplayText[i++], 40, 1, "Text", "3;0:60",,,True);
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "TimeToScore":	return default.DDomPropDescText[0];
		case "TImeDisabled": return default.DDomPropDescText[1];
	}

	return Super.GetDescriptionText(PropName);
}

function actor FindSpecGoalFor(PlayerReplicationInfo PRI, int TeamIndex)
{
	local XPlayer PC;
    local xDomLetter Dom[2],d;

    PC = XPlayer(PRI.Owner);
    if (PC==None)
    	return none;

	foreach AllActors(class'xDomLetter',d)
    	if (xDomA(d)!=None)
        	Dom[0]=d;
        else
        	Dom[1]=d;

    if ( vsize(PC.Location - Dom[0].Location) < vsize(PC.Location - Dom[1].Location) )
    	return Dom[1];
    else
    	return Dom[0];

    return none;

}

event SetGrammar()
{
	LoadSRGrammar("DOM");
}

event Destroyed()
{
	local int i;

	for ( i = 0; i < 2; i++ )
	{
		if ( xDomPoints[i] != None )
			xDomPoints[i].ResetCount = None;
	}
	Super.Destroyed();
}

defaultproperties
{
     TimeToScore=10
     TimeDisabled=10
     ScoreCountDown=10
     ControlSoundNames(0)="red_team_dominating"
     ControlSoundNames(1)="blue_team_dominating"
     ScoreSoundNames(0)="Red_Team_Scores"
     ScoreSoundNames(1)="Blue_Team_Scores"
     AvertedSoundNames(1)="Narrowly_Averted"
     AvertedSoundNames(2)="Narrowly_Averted"
     AvertedSoundNames(3)="Last_Second_Save"
     DDomPropsDisplayText(0)="Time To Score"
     DDomPropsDisplayText(1)="Time Disabled"
     DDomPropDescText(0)="Specifies how long domination points must be held to score a point."
     DDomPropDescText(1)="Specifies how long domination points are disabled after a point is scored."
     bScoreTeamKills=False
     bSpawnInTeamArea=True
     TeamAIType(0)=Class'UnrealGame.DOMTeamAI'
     TeamAIType(1)=Class'UnrealGame.DOMTeamAI'
     bMustHaveMultiplePlayers=False
     DefaultEnemyRosterClass="xGame.xTeamRoster"
     ADR_Kill=2.000000
     HUDType="XInterface.HudCDoubleDomination"
     MapListType="XInterface.MapListDoubleDomination"
     MapPrefix="DOM"
     BeaconName="DOM"
     GoalScore=3
     DeathMessageClass=Class'XGame.xDeathMessage'
     OtherMesgGroup="DoubleDom"
     GameName="Double Domination"
     Description="Your team scores by capturing and holding both Control Points for ten seconds.  Control Points are captured by touching them.  After scoring, the Control Points reset to neutral."
     ScreenShotName="UT2004Thumbnails.DOMShots"
     DecoTextName="XGame.DoubleDom"
     Acronym="DOM2"
}
