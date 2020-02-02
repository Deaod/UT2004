// ====================================================================
//  Class:  Engine.GameStats
//  Parent: Engine.Info
//
//  the GameStats object is used to send individual stat events to the
//  stats server.  Each game should spawn a GameStats object if it
//  wishes to have stat logging.
//
// ====================================================================

class GameStats extends Info
		Native Config;

var FileLog TempLog;
var GameReplicationInfo GRI;
var bool bShowBots;

var string Tab;

/** create local stat logs */
var globalconfig bool bLocalLog;
/** filename to use, check GetLogFilename() for replacements */
var globalconfig string LogFileName;

native final function string GetStatsIdentifier( Controller C );
native final function string GetMapFileName();	// Returns the name of the current map

/////////////////////////////////////
// GameStats interface

function Init()
{
	if (bLocalLog)
	{
		TempLog = spawn(class 'FileLog');
		if (TempLog != None)
		{
			TempLog.OpenLog(GetLogFilename());
		}
		else {
			Warn("Could not create output file");
		}
	}
}
function Shutdown()
{
	if (TempLog!=None)
		TempLog.Destroy();
}
function Logf(string LogString)
{
	if (TempLog!=None)
		TempLog.Logf(LogString);
}

/////////////////////////////////////
// Internals

event PostBeginPlay()
{
	Super.PostBeginPlay();

	Tab = Chr(9);
	Init();
}

event Destroyed()
{
	Shutdown();
	Super.Destroyed();
}

function string TimeStamp()
{
	local string seconds;
	seconds = string(Level.TimeSeconds);

	// Remove the centiseconds
	if( InStr(seconds,".") != -1 )
		seconds = Left( seconds, InStr(seconds,".") );

	return seconds;
}

function string Header()
{
	return TimeStamp()$Tab;
}

function String FullTimeDate()		// Date/Time in MYSQL format
{
	return Level.Year$"-"$Level.Month$"-"$Level.Day$" "$Level.Hour$":"$Level.Minute$":"$Level.Second;
}

function String TimeZone()			// Timezone (offset) of game server's local time to GTM, e.g. -4 or +5
{
	return "0";						// FIXME Jack - currently pretending GMT
}

function String MapName()
{
	local string mapname;

	mapname = GetMapFileName();

	// Remove the file name extention .ut2
	if( InStr(mapname,".ut2") != -1 )
		mapname = Left( mapname, InStr(mapname,".ut2") );

	ReplaceText(mapname, tab, "_");

	return mapname;
}


// Stat Logging functions
function NewGame()
{
	local string out, tmp;
	local string ngTitle, ngAuthor, ngGameGameName;
	local int i;
	local mutator MyMutie;
	local GameRules MyRules;

	ngTitle			= Level.Title;			// Making local copies
	ngAuthor		= Level.Author;
	ngGameGameName	= Level.Game.GameName;
	ReplaceText(ngTitle,		tab, "_");	// Replacing tabs with _
	ReplaceText(ngAuthor,		tab, "_");
	ReplaceText(ngGameGameName, tab, "_");

	GRI = Level.Game.GameReplicationInfo;
	out = Header()$"NG"$Tab;				// "NewGame"
	out $= FullTimeDate()$Tab;		// Game server's local time
	out $= TimeZone()$Tab;			// Game server's time zone (offset to GMT)
	out $= MapName()$Tab;				// Map file name without map extention .ut2
	out $= ngTitle$Tab;
	out $= ngAuthor$Tab;
	out $= Level.Game.Class$Tab;
	out $= ngGameGameName;

	tmp = "";
	i = 0;
	foreach AllActors(class'Mutator',MyMutie)
	{
		if (tmp != "")
			tmp $= "|" $ MyMutie.Class;
		else
	 		tmp $= MyMutie.Class;

		i++;
	}
	foreach AllActors(class'GameRules',MyRules)
	{
		if (tmp!="")
			tmp $= "|"$MyRules.Class;
		else
			tmp $= MyRules.Class;

		i++;
	}

	if (i>0)
	{
		ReplaceText(tmp, tab, "_");
		out $= Tab $ "Mutators=" $ tmp;
	}
	Logf(out);
}

function ServerInfo()
{
	local string out, flags;
	local string siServerName, siAdminName, siAdminEmail;
	local GameInfo.ServerResponseLine ServerState;
	local int i;

	siServerName	= GRI.ServerName;	// Making local copies
	siAdminName		= GRI.AdminName;
	siAdminEmail	= GRI.AdminEmail;
	ReplaceText(siServerName,	tab, "_");
	ReplaceText(siAdminName,	tab, "_");
	ReplaceText(siAdminEmail,	tab, "_");

	out = Header() $ "SI" $ Tab;	// "SeverInfo"
	out  $= siServerName $ Tab;		// Server name
	out $= TimeZone()$Tab;			// Timezone
	out $= siAdminName$Tab;			// Admin name
	out $= siAdminEmail$Tab;		// Admin email
	out $= Tab;						// IP:port (filled in by Master Server)

	flags = "";							// Server flag / key combos
	Level.Game.GetServerDetails( ServerState );
	for( i=0;i<ServerState.ServerInfo.Length;i++ )
		flags $= "\\"$ServerState.ServerInfo[i].Key$"\\"$ServerState.ServerInfo[i].Value;

	ReplaceText(flags, tab, "_");
	out	$= flags;
	Logf(out);
}

function StartGame()
{
	Logf( Header()$"SG" );			// "StartGame"
}


// Send stats for the end of the game
function EndGame(string Reason)
{
	local string out;
	local int i,j;
	local array<PlayerReplicationInfo> PRIs;
	local PlayerReplicationInfo PRI,t;

	out = Header()$"EG"$Tab$Reason;	// "EndGame"

	// Quick cascade sort.
	for (i=0;i<GRI.PRIArray.Length;i++)
	{
		PRI = GRI.PRIArray[i];
		if ( !PRI.bOnlySpectator && !PRI.bBot )
		{
			PRIs.Length = PRIs.Length+1;
			for (j=0;j<Pris.Length-1;j++)
			{
				if (PRIs[j].Score < PRI.Score ||
				   (PRIs[j].Score == PRI.Score && PRIs[j].Deaths > PRI.Deaths) )
				{
					t = PRIs[j];
					PRIs[j] = PRI;
					PRI = t;
				}
			}
			PRIs[j] = PRI;
		}
	}

	// Minimal scoreboard, shows Playernumbers in order of Score
	for (i=0;i<PRIs.Length;i++)
		out $= Tab$Controller(PRIs[i].Owner).PlayerNum;

	Logf(out);
}


// Connect Events get fired every time a player connects to a server
function ConnectEvent(PlayerReplicationInfo Who)
{
	local string out;
	if ( Who.bBot || Who.bOnlySpectator )			// Spectators should never show up in stats!
		return;

	// C	0	11d8944d9e138a5aa688d503e0e4c3e0
	out = Header()$"C"$Tab$Controller(Who.Owner).PlayerNum$Tab;

	// Login identifier
	out $= GetStatsIdentifier(Controller(Who.Owner));

	Logf(out);
}

// Connect Events get fired every time a player connects or leaves from a server
function DisconnectEvent(PlayerReplicationInfo Who)
{
	local string out;
	if ( Who.bBot || Who.bOnlySpectator )			// Spectators should never show up in stats!
		return;

	// D	0
	out = Header()$"D"$Tab$Controller(Who.Owner).PlayerNum;	//"Disconnect"

	Logf(out);
}


// Scoring Events occur when a player's score changes
function ScoreEvent(PlayerReplicationInfo Who, float Points, string Desc)
{
	if ( Who.bBot || Who.bOnlySpectator )			// Just to be totally safe Spectators sends nothing
		return;
	Logf( Header()$"S"$Tab$Controller(Who.Owner).PlayerNum$Tab$Points$Tab$Desc );	//"Score"
}


function TeamScoreEvent(int Team, float Points, string Desc)
{
	Logf( Header()$"T"$Tab$Team$Tab$Points$Tab$Desc );	//"TeamScore"
}


// KillEvents occur when a player kills, is killed, suicides
function KillEvent(string Killtype, PlayerReplicationInfo Killer, PlayerReplicationInfo Victim, class<DamageType> Damage)
{
	local string out;

	if ( Victim.bBot || Victim.bOnlySpectator || ((Killer != None) && Killer.bBot) )
		return;

	out = Header()$Killtype$Tab;

	// KillerNumber and KillerDamagetype
	if (Killer!=None)
	{
		out $= Controller(Killer.Owner).PlayerNum$Tab;
		// KillerWeapon no longer used, using damagetype
		out $= GetItemName(string(Damage))$Tab;
	}
	else
		out $= "-1"$Tab$GetItemName(string(Damage))$Tab;	// No PlayerNum -> -1, Environment "deaths"

	// VictimNumber and VictimWeapon
	out $= Controller(Victim.Owner).PlayerNum$Tab$GetItemName(string(Controller(Victim.Owner).GetLastWeapon()));

	// Type killers tracked as player event (redundant Typing, removed from kill line)
	if ( PlayerController(Victim.Owner)!= None && PlayerController(Victim.Owner).bIsTyping)
	{
		if ( PlayerController(Killer.Owner) != PlayerController(Victim.Owner) )
			SpecialEvent(Killer, "type_kill");						// Killer killed typing victim
	}

	Logf(out);
}


// Special Events are everything else regarding the player
function SpecialEvent(PlayerReplicationInfo Who, string Desc)
{
	local string out;
	if (Who != None)
	{
		if ( Who.bBot || Who.bOnlySpectator )		// Avoid spectator suicide on console "type_kill"
			return;
		out = string(Controller(Who.Owner).PlayerNum);
	}
	else
		out = "-1";

	Logf( Header()$"P"$Tab$out$Tab$Desc );					//"PSpecial"
}


// Special events regarding the game
function GameEvent(string GEvent, string Desc, PlayerReplicationInfo Who)
{
	local string out, geDesc;

	if (Who != None)
	{
		if ( Who.bBot || Who.bOnlySpectator )		// Specator could cause NameChange, TeamChange! No longer.
			return;
		out = string(Controller(Who.Owner).PlayerNum);
	}
	else
		out = "-1";

	geDesc	= Desc;
	ReplaceText(geDesc, tab, "_");									// geDesc, can be the nickname!

	Logf( Header()$"G"$Tab$GEvent$Tab$out$Tab$geDesc );	//"GSpecial"
}

/**
	return the filename to use for the log file. The following formatting rules are accepted:
	%P		server port
	%Y		year
	%M		month
	%D		day
	%H		hour
	%I		minute
	%S		second
	%W		day of the week
*/
function string GetLogFilename()
{
  local string result;
  result = LogFileName;
  ReplaceText(result, "%P", string(Level.Game.GetServerPort()));
  ReplaceText(result, "%N", Level.Game.GameReplicationInfo.ServerName);
  ReplaceText(result, "%Y", Right("0000"$string(Level.Year), 4));
  ReplaceText(result, "%M", Right("00"$string(Level.Month), 2));
  ReplaceText(result, "%D", Right("00"$string(Level.Day), 2));
  ReplaceText(result, "%H", Right("00"$string(Level.Hour), 2));
  ReplaceText(result, "%I", Right("00"$string(Level.Minute), 2));
  ReplaceText(result, "%W", Right("0"$string(Level.DayOfWeek), 1));
  ReplaceText(result, "%S", Right("00"$string(Level.Second), 2));
  return result;
}

defaultproperties
{
     LogFileName="Stats_%P_%Y_%M_%D_%H_%I_%S"
}
