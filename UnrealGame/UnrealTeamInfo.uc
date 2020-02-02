//=============================================================================
// UnrealTeamInfo.
// includes list of bots on team for multiplayer games
// 
//=============================================================================

class UnrealTeamInfo extends TeamInfo;

var() RosterEntry DefaultRosterEntry;
var() export editinline array<RosterEntry> Roster;
var() class<UnrealPawn> AllowedTeamMembers[32];
var() byte TeamAlliance;
var int DesiredTeamSize;
var TeamAI AI;
var Color HudTeamColor;
var string TeamSymbolName;

var array<string> RosterNames;  // promoted from Team/DM rosters

// Assault
var float	CurrentObjectiveProgress;	// If team didn't beat all the objective, keep the progress of the current one
var	int		LastObjectiveTime;				// Time when last objective was disabled
var int		ObjectivesDisabledCount;		// Number of objectives disabled


/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();
	if ( !UnrealMPGameInfo(Level.Game).bTeamScoreRounds )
		Score = 0;
}

function int OverrideInitialBots(int N, UnrealTeamInfo T)
{
	return N;
}
	
function bool AllBotsSpawned()
{
	return false;
}

function Initialize(int TeamBots);

function FillPlayerTeam(GameProfile G);

simulated function class<Pawn> NextLoadOut(class<Pawn> CurrentLoadout)
{
	local int i;
	local class<Pawn> Result;

	Result = AllowedTeamMembers[0];

	for ( i=0; i<ArrayCount(AllowedTeamMembers) - 1; i++ )
	{
		if ( AllowedTeamMembers[i] == CurrentLoadout )
		{
			if ( AllowedTeamMembers[i+1] != None )
				Result = AllowedTeamMembers[i+1];
			break;
		}
		else if ( AllowedTeamMembers[i] == None )
			break;
	}

	return Result;
}

function bool NeedsBotMoreThan(UnrealTeamInfo T)
{
	return ( (DesiredTeamSize - Size) > (T.DesiredTeamSize - T.Size) );
}

function RosterEntry ChooseBotClass(optional string botName)
{
    if (botName == "")
        return GetNextBot();

    return GetNamedBot(botName);
}

function RosterEntry GetRandomPlayer();

function bool AlreadyExistsEntry(string CharacterName, bool bNoRecursion)
{
	return false;
}

function AddRandomPlayer()
{
	local int j;

	j = Roster.Length;
	Roster.Length = Roster.Length + 1;
	Roster[j] = GetRandomPlayer();
	Roster[j].PrecacheRosterFor(self);
}

function AddNamedBot(string BotName)
{
	local int j;

	j = Roster.Length;
	Roster.Length = Roster.Length + 1;
	Roster[j] = GetNamedBot(BotName);
	Roster[j].PrecacheRosterFor(self);
}

function RosterEntry GetNextBot()
{
	local int i;
	
	for ( i=0; i<Roster.Length; i++ )
		if ( !Roster[i].bTaken )
		{
			Roster[i].bTaken = true;
			return Roster[i];
		}
	i = Roster.Length;
	Roster.Length = Roster.Length + 1;
	Roster[i] = GetRandomPlayer();
	Roster[i].bTaken = true;
	return Roster[i];
}

function RosterEntry GetNamedBot(string botName)
{
    return GetNextBot();
}

function bool AddToTeam( Controller Other )
{
	local bool bResult;

	bResult = Super.AddToTeam(Other);

	if ( bResult && (Other.PawnClass != None) && !BelongsOnTeam(Other.PawnClass) )
		Other.PawnClass = DefaultPlayerClass;

	return bResult;
}

/* BelongsOnTeam()
returns true if PawnClass is allowed to be on this team
*/
function bool BelongsOnTeam(class<Pawn> PawnClass)
{
	local int i;

	for ( i=0; i<ArrayCount(AllowedTeamMembers); i++ )
		if ( PawnClass == AllowedTeamMembers[i] )
			return true;

	return false;
}

function SetBotOrders(Bot NewBot, RosterEntry R) 
{
    if( AI != None ) 
	    AI.SetBotOrders( NewBot, R );
}

function RemoveFromTeam(Controller Other)
{
	Super.RemoveFromTeam(Other);
	if ( AI != None )
		AI.RemoveFromTeam(Other);
/*
	for ( i=0; i<Roster.Length; i++ )
	FIXME- clear bTaken for the roster entry
*/	
}

defaultproperties
{
     DesiredTeamSize=8
     HudTeamColor=(B=255,G=255,R=255,A=255)
}
