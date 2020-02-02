//=============================================================================
// ASGameReplicationInfo.
//=============================================================================

class ASGameReplicationInfo extends GameReplicationInfo;

var int		RoundTimeLimit;		// in seconds, unlike ASGameInfo.RoundTimeLimit which is in minutes
var int		RoundStartTime, CurrentRound, MaxRounds, ReinforcementCountDown, PracticeTimeLimit;
var	bool	bTeamZeroIsAttacking;					// true when Red Team is Attacking
var	int		RoundOverTime;	// time set when round is over (so all clients show the same time)
var int		MaxTeleportTime;

// Objective Progress
// Shown on HUD, and on briefing screen...
var	byte	ObjectiveProgress, MaxObjectivePriority;

var GameObjective	Objectives;
var GameObject		GameObject;

enum ERoundWinner
{
	ERW_None,
	ERW_PracticeRoundEnded,
	ERW_RedAttacked,
	ERW_BlueAttacked,
	ERW_RedDefended,
	ERW_BlueDefended,
	ERW_RedMoreObjectives,
	ERW_BlueMoreObjectives,
	ERW_RedMoreProgress,
	ERW_BlueMoreProgress,
	ERW_RedGotSameOBJFaster,
	ERW_BlueGotSameOBJFaster,
	ERW_Draw,
};

var ERoundWinner RoundWinner;

var localized String ERW_PracticeRoundEndedStr, ERW_RedAttackedStr, ERW_BlueAttackedStr, ERW_RedDefendedStr, ERW_BlueDefendedStr;
var localized String ERW_DefendersStr, ERW_AttackersStr, ERW_RedMoreObjectivesStr, ERW_BlueMoreObjectivesStr; 
var localized String ERW_RedMoreProgressStr, ERW_BlueMoreProgressStr, ERW_RedGotSameOBJFasterStr, ERW_BlueGotSameOBJFasterStr;
var localized String ERW_DrawStr;

replication
{
	reliable if ( bNetDirty && (Role == ROLE_Authority) )
		RoundStartTime, CurrentRound, bTeamZeroIsAttacking, ObjectiveProgress,
		ReinforcementCountDown, RoundWinner, GameObject, RoundTimeLimit, RoundOverTime;

	reliable if ( bNetInitial && (Role==ROLE_Authority) )
		MaxRounds; 
}

simulated function PreBeginPlay()
{
	super.PreBeginPlay();
	SecondCount = Level.TimeSeconds;
	SetTimer(1, true);
}

simulated function PostNetBeginPlay()
{
	super.PostNetBeginPlay();
	SetupAssaultObjectivePriority();
}

/*
Converts default objective DefensePriority ordering (downwards)
to ordered upwards (without gaps) for easier handling
0 is the first objective, 1 the second and so on...
*/
simulated function SetupAssaultObjectivePriority()
{
	local GameObjective			GO, BestGO, NextBestGO;
	local byte					CurrentPriority;

	log("## ASGRI::SetupAssaultObjectivePriority");

	// Caching GameObjectives
	foreach AllActors(class'GameObjective', GO)
	{
		if ( GO.bBotOnlyObjective )	// ignore bot only objectives
		{
			GO.ObjectivePriority = 255;
			continue;
		}
		if ( BestGO == None || GO.DefensePriority > BestGO.DefensePriority )
			BestGO = GO;
	}

	if ( BestGO == None )
		return;

	// Building Assault Priority Order...
	do
	{
		NextBestGO = None;
		foreach AllActors(class'GameObjective', GO)
		{	
			if ( GO.bBotOnlyObjective )	// ignore bot only objectives
				continue;

			// Current Assault Priority: Assign
			if ( GO.DefensePriority == BestGO.DefensePriority )
			{
				log( "  Assault Priority:" @ CurrentPriority @ "DefensePriority:" @ GO.DefensePriority 
					@ "Info:" @ GO.Objective_Info_Attacker @ "Destruction:" @ GO.DestructionMessage );
				GO.ObjectivePriority = CurrentPriority;
			}
			else if ( (GO.DefensePriority < BestGO.DefensePriority)
				&& ( NextBestGO == None || GO.DefensePriority > NextBestGO.DefensePriority ) )
			{
				NextBestGO = GO;	// Next Assault priority ( for next cycle )
			}
		}
		
		BestGO = NextBestGO;
		CurrentPriority++;
	}
	until ( NextBestGO == None )

	MaxObjectivePriority = CurrentPriority - 1;
}


simulated function Timer()
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( Level.TimeSeconds - SecondCount >= Level.TimeDilation )
		{
			if ( ReinforcementCountDown > 0 ) // Reinforcements countdown..
				ReinforcementCountDown--;
		}
	}
	super.Timer();
}

/* round 0 is either practice round (in network) or intro cinematic (standalone only) */
simulated function bool IsPracticeRound()
{
	return ( CurrentRound == 0 );
}

simulated function bool IsDefender( byte Team )
{
	return ( Team == byte(bTeamZeroIsAttacking) );
}

simulated function String	GetRoundWinnerString()
{
	switch ( RoundWinner )
	{
		case ERW_None						: return "";
		case ERW_PracticeRoundEnded			: return ERW_PracticeRoundEndedStr;
		case ERW_RedAttacked				: return ERW_RedAttackedStr;
		case ERW_BlueAttacked				: return ERW_BlueAttackedStr;
		case ERW_RedDefended				: return ERW_RedDefendedStr;
		case ERW_BlueDefended				: return ERW_BlueDefendedStr;
		case ERW_RedMoreObjectives			: return ERW_RedMoreObjectivesStr;
		case ERW_BlueMoreObjectives			: return ERW_BlueMoreObjectivesStr;
		case ERW_RedMoreProgress			: return ERW_RedMoreProgressStr;
		case ERW_BlueMoreProgress			: return ERW_BlueMoreProgressStr;
		case ERW_RedGotSameOBJFaster		: return ERW_RedGotSameOBJFasterStr;
		case ERW_BlueGotSameOBJFaster		: return ERW_BlueGotSameOBJFasterStr;
		case ERW_Draw						: return ERW_DrawStr;
	}
}

defaultproperties
{
     MaxTeleportTime=7
     ERW_PracticeRoundEndedStr="Practice round over. Get ready!"
     ERW_RedAttackedStr="Red team successfully attacked!"
     ERW_BlueAttackedStr="Blue team successfully attacked!"
     ERW_RedDefendedStr="Red team successfully defended!"
     ERW_BlueDefendedStr="Blue team successfully defended!"
     ERW_RedMoreObjectivesStr="Red team scored (more objectives)."
     ERW_BlueMoreObjectivesStr="Blue team scored (more objectives)."
     ERW_RedMoreProgressStr="Red team scored (closer to completion)."
     ERW_BlueMoreProgressStr="Blue team scored (closer to completion)."
     ERW_RedGotSameOBJFasterStr="Red team scored (fastest)."
     ERW_BlueGotSameOBJFasterStr="Blue team scored (fastest)."
     ERW_DrawStr="Draw game."
}
