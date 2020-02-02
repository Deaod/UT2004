class DMRosterConfigured extends xDMRoster;

/* this class used for configured instant action or multiplayer games with bots
*/
var config array<string> Characters;

function Initialize(int TeamBots)
{
	local int i;

	for ( i=0; i<Roster.Length; i++ )
		Roster[i].PrecacheRosterFor(self);
}

function int OverrideInitialBots(int N, UnrealTeamInfo T)
{
	return Roster.Length;
}

function bool AllBotsSpawned()
{
	local int i;

	for ( i=0; i<Roster.Length; i++ )
		if ( !Roster[i].bTaken )
			return false;
	return true;
}

function PostBeginPlay()
{
	local int i;

	for ( i=0; i<Characters.Length; i++ )
		RosterNames[i] = Characters[i];
	Super.PostBeginPlay();
}

static function SetCharacters(array<string> Chars)
{
	default.Characters = Chars;
}

static function AddCharacter(string CharName)
{
	local int i;

	i = FindCharIndex(CharName);
	if ( i == -1 )
		default.Characters[default.Characters.Length] = CharName;
}

static function RemoveCharacter(int Index, int Count)
{
	if ( Index < 0 || Index >= default.Characters.Length )
		return;

	if ( Count < 0 )
		Count = default.Characters.Length;

	default.Characters.Remove(Index, Min(Count, default.Characters.Length - Index));
}

static function int FindCharIndex(string CharName)
{
	local int i;

	for ( i = 0; i < default.Characters.Length; i++ )
		if ( default.Characters[i] ~= CharName )
			return i;

	return -1;
}

static function GetAllCharacters(out array<string> Chars)
{
	Chars = default.Characters;
}

defaultproperties
{
}
