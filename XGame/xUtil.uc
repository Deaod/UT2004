class xUtil extends Object
    native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var() protected const string SectionName;
var() protected const string FileExtension;

struct native init PlayerRecord
{
    var() String                    DefaultName;            // Character's name, also used as selection tag
    var() class<SpeciesType>        Species;                // Species
    var() String                    MeshName;               // Mesh type
    var() String                    BodySkinName;           // Body texture name
    var() String                    FaceSkinName;           // Face texture name
    var() Material                  Portrait;               // Menu picture
    var() String                    TextName;               // Decotext reference
    var() String                    VoiceClassName;         // voice pack class name - overrides species default
    var   string					Sex;
    var   string					Accuracy;
    var	  string					Aggressiveness;
    var   string					StrafingAbility;
    var	  string					CombatStyle;
    var	  string					Tactics;
    var	  string					ReactionTime;
    var   string					Jumpiness;
    var   string					Race;
    var	  string					FavoriteWeapon;
    var	  string					Menu;					// info for menu displaying characters
    var   string					Skeleton;				// skeleton mesh, if it differs from the species default
    var() const int                 RecordIndex;
	var	  string				    Ragdoll;
	var	  byte						BotUse;					// weighting for use by bots
	var	  bool						UseSpecular;
	var   bool						TeamFace;
	var	  bool						ZeroWeaponOffsets;
};

struct MutatorRecord
{
    var() const class<Mutator>  mutClass;
    var() const     string      ClassName;
    var() const     string      FriendlyName;
    var() const     string      Description;
    var() const     string      IconMaterialName;
    var() const     string      ConfigMenuClassName;
    var() const     string      GroupName;
    var() const     int         RecordIndex;
    var   const     byte        bActivated;
};

var() private const transient CachePlayers		CachedPlayerList;

var localized string NoPreference, FavoriteWeapon;
var localized string AgilityString,TacticsString,AccuracyString,AggressivenessString;

native(562) final simulated static function GetPlayerList(out array<PlayerRecord> PlayerRecords);
native(563) final simulated static function PlayerRecord GetPlayerRecord(int index);
native(564) final simulated static function PlayerRecord FindUPLPlayerRecord(string charName);
native		final			static function DecoText LoadDecoText(string PackageName, string DecoTextName, optional int ColumnCount);

// Deprecated - use CacheManager.GetMutatorList instead.
final static function GetMutatorList( array<MutatorRecord> MutatorRecords )
{
}

final simulated static function PlayerRecord FindPlayerRecord(string charName)
{
	local PlayerRecord PRE;
	local class<PlayerRecordClass> PRClass;

	PRE = FindUPLPlayerRecord(charName);
	if ( PRE.DefaultName != charName )
	{
		// try to dynamic load downloaded character class object
		PRClass = class<PlayerRecordClass>(DynamicLoadObject(charname$"mod."$charName,class'Class',true));
		if ( PRClass != None )
		{
			PRE = PRClass.Static.FillPlayerRecord();
			PRE.DefaultName = charname;
		}
	}
	return PRE;
}

final simulated static function int GetSalaryFor(PlayerRecord PRE)
{
	local float Salary;

	Salary = 500;

	if ( PRE.FavoriteWeapon == "" )
		Salary += 5;

	Salary += 30 * float(PRE.Jumpiness);

	Salary += 150 * float(PRE.Accuracy);
	if ( float(PRE.Accuracy) > 0.3 )
		Salary += 250 * (float(PRE.Accuracy) - 0.3);
	Salary += 70 * float(PRE.Tactics);
	if ( float(PRE.Tactics) > 0.5 )
		Salary += 100 * (float(PRE.Tactics) - 0.5);
	Salary += 100 * float(PRE.StrafingAbility);
	if ( float(PRE.StrafingAbility) > 0.5 )
		Salary += 100 * (float(PRE.StrafingAbility) - 0.5);
	Salary -= 5 * Abs(float(PRE.Aggressiveness));
	Salary -= 5 * Abs(float(PRE.CombatStyle));
	return int(Salary);
}

// returns human-readable version of the favorite weapon, or 'no preference'
final simulated static function string GetFavoriteWeaponFor(PlayerRecord PRE)
{
local class<Weapon> WeaponClass;

	if ( PRE.FavoriteWeapon != "" )
	{
		WeaponClass = class<Weapon>(DynamicLoadObject(PRE.FavoriteWeapon, class'Class'));
		if (WeaponClass != None)
			return Default.FavoriteWeapon@WeaponClass.default.ItemName;
	}

	return Default.NoPreference;
}

final simulated static function int RatingModifier(string CharacterName)
{
	local int Hash;

	Hash = Asc(CharacterName);
	if ( Hash == 2 )
		Hash = 1;
	return ( Hash%5 - 2);
}

final simulated static function int AccuracyRating(PlayerRecord PRE)
{
	if ( 2 * float(PRE.Accuracy) < -1 )
		return ( 55 + 8 * FMax(-7,2 * float(PRE.Accuracy)) );
	if ( 2 * float(PRE.Accuracy) == 0 )
		return ( 75 - RatingModifier(PRE.DefaultName) );
	if ( 2 * float(PRE.Accuracy) < 1 )
		return ( 75 + 20 * 2 * float(PRE.Accuracy) - 0.5 * RatingModifier(PRE.DefaultName) );
	return Min(100, 95 + 2 * float(PRE.Accuracy) );
}

final simulated static function int AgilityRating(PlayerRecord PRE)
{
	local float Add;

	Add = 3 * float(PRE.Jumpiness);
	if ( float(PRE.StrafingAbility) < -1 )
		return ( Add + 58 + 8 * FMax(-7,float(PRE.StrafingAbility)) );
	if ( (Add == 0) && (float(PRE.StrafingAbility) == 0) )
		return ( 75 + 0.5 * RatingModifier(PRE.DefaultName) );
	if ( float(PRE.StrafingAbility) < 1 )
		return ( Add + 75 + 17 * float(PRE.StrafingAbility) - 0.5 * RatingModifier(PRE.DefaultName) );
	return Min(100, Add + 92 + float(PRE.StrafingAbility) );
}

final simulated static function int TacticsRating(PlayerRecord PRE)
{
	if ( float(PRE.Tactics) < -1 )
		return ( 55 + 8 * FMax(-7,float(PRE.Tactics)) );
	if ( float(PRE.Tactics) == 0 )
		return ( 75 + RatingModifier(PRE.DefaultName) );
	if ( float(PRE.Tactics) < 1 )
		return ( 75 + 20 * float(PRE.Tactics) + 0.5 * RatingModifier(PRE.DefaultName) );
	return Min(100, 95 + float(PRE.Tactics) );
}

final simulated static function int AggressivenessRating(PlayerRecord PRE)
{
	return Clamp(73 + 25 * (float(PRE.Aggressiveness) + float(PRE.CombatStyle)) + 0.5 * RatingModifier(PRE.DefaultName),0,100);
}
///////////////////// TEAM EVALUATION FUNCTIONS /////////////////////
// These functions used to provide average values for team, or just lineup
// if optional bool is set
final simulated static function int TeamAccuracyRating ( GameProfile GP, optional int lineupsize) {
	local int retval;
	local float count;
	local int i;
	local PlayerRecord PR;
	local int numchars;

	numchars = Max(GP.LINEUP_SIZE, lineupsize);
	count = 0; retval = 0;
	for ( i=0; i < numchars; i++ ) {
		count+=1.0;
		retval += AccuracyRating(FindPlayerRecord(GP.PlayerTeam[i]));
	}

	if ( count > 0 ) {
		retval = retval / count;
	} else {
		retval = AccuracyRating(PR);	// purposefully uninitialized
	}

	return retval;
}
final simulated static function int TeamInfoAccuracyRating ( UnrealTeamInfo UT, optional int lineupsize) {
	local int retval;
	local float count;
	local int i;
	local PlayerRecord PR;
	local int numchars;

	numchars = Max(UT.RosterNames.Length, lineupsize);
	count = 0; retval = 0;
	for ( i=0; i < numchars; i++ ) {
		count+=1.0;
		retval += AccuracyRating(FindPlayerRecord(UT.RosterNames[i]));
	}

	if ( count > 0 ) {
		retval = retval / count;
	} else {
		retval = AccuracyRating(PR);	// purposefully uninitialized
	}

	return retval;
}
final simulated static function int TeamArrayAccuracyRating ( array<string> Players ) {
	local int retval;
	local float count;
	local int i;
	local PlayerRecord PR;

	count = 0; retval = 0;
	for ( i=0; i < Players.length; i++ ) {
		count+=1.0;
		retval += AccuracyRating(FindPlayerRecord(Players[i]));
	}

	if ( count > 0 ) {
		retval = retval / count;
	} else {
		retval = AccuracyRating(PR);	// purposefully uninitialized
	}

	return retval;
}
final simulated static function int TeamAggressivenessRating ( GameProfile GP, optional int lineupsize ) {
	local int retval;
	local float count;
	local int i;
	local PlayerRecord PR;
	local int numchars;

	numchars = Max(GP.LINEUP_SIZE, lineupsize);
	count = 0; retval = 0;
	for ( i=0; i < numchars; i++ ) {
		count+=1.0;
		retval += AggressivenessRating(FindPlayerRecord(GP.PlayerTeam[i]));
	}

	if ( count > 0 ) {
		retval = retval / count;
	} else {
		retval = AggressivenessRating(PR);	// purposefully uninitialized
	}

	return retval;
}
final simulated static function int TeamInfoAggressivenessRating ( UnrealTeamInfo UT, optional int lineupsize ) {
	local int retval;
	local float count;
	local int i;
	local PlayerRecord PR;
	local int numchars;

	numchars = Max(UT.RosterNames.Length, lineupsize);
	count = 0; retval = 0;
	for ( i=0; i < numchars; i++ ) {
		count+=1.0;
		retval += AggressivenessRating(FindPlayerRecord(UT.RosterNames[i]));
	}

	if ( count > 0 ) {
		retval = retval / count;
	} else {
		retval = AggressivenessRating(PR);	// purposefully uninitialized
	}

	return retval;
}
final simulated static function int TeamArrayAggressivenessRating ( array<string> Players ) {
	local int retval;
	local float count;
	local int i;
	local PlayerRecord PR;

	count = 0; retval = 0;
	for ( i=0; i < Players.length; i++ ) {
		count+=1.0;
		retval += AggressivenessRating(FindPlayerRecord(Players[i]));
	}

	if ( count > 0 ) {
		retval = retval / count;
	} else {
		retval = AggressivenessRating(PR);	// purposefully uninitialized
	}

	return retval;
}
final simulated static function int TeamAgilityRating ( GameProfile GP, optional int lineupsize ) {
	local int retval;
	local float count;
	local int i;
	local PlayerRecord PR;
	local int numchars;

	numchars = Max(GP.LINEUP_SIZE, lineupsize);
	count = 0; retval = 0;
	for ( i=0; i < numchars; i++ ) {
		count+=1.0;
		retval += AgilityRating(FindPlayerRecord(GP.PlayerTeam[i]));
	}

	if ( count > 0 ) {
		retval = retval / count;
	} else {
		retval = AgilityRating(PR);	// purposefully uninitialized
	}

	return retval;
}
final simulated static function int TeamInfoAgilityRating ( UnrealTeamInfo UT, optional int lineupsize ) {
	local int retval;
	local float count;
	local int i;
	local PlayerRecord PR;
	local int numchars;

	numchars = Max(UT.RosterNames.Length, lineupsize);
	count = 0; retval = 0;
	for ( i=0; i < numchars; i++ ) {
		count+=1.0;
		retval += AgilityRating(FindPlayerRecord(UT.RosterNames[i]));
	}

	if ( count > 0 ) {
		retval = retval / count;
	} else {
		retval = AgilityRating(PR);	// purposefully uninitialized
	}

	return retval;
}
final simulated static function int TeamArrayAgilityRating ( array<string> Players ) {
	local int retval;
	local float count;
	local int i;
	local PlayerRecord PR;

	count = 0; retval = 0;
	for ( i=0; i < Players.length; i++ ) {
		count+=1.0;
		retval += AgilityRating(FindPlayerRecord(Players[i]));
	}

	if ( count > 0 ) {
		retval = retval / count;
	} else {
		retval = AgilityRating(PR);	// purposefully uninitialized
	}

	return retval;
}
final simulated static function int TeamTacticsRating ( GameProfile GP, optional int lineupsize ) {
	local int retval;
	local float count;
	local int i;
	local PlayerRecord PR;
	local int numchars;

	numchars = Max(GP.LINEUP_SIZE, lineupsize);
	count = 0; retval = 0;
	for ( i=0; i < numchars; i++ ) {
		count+=1.0;
		retval += TacticsRating(FindPlayerRecord(GP.PlayerTeam[i]));
	}

	if ( count > 0 ) {
		retval = retval / count;
	} else {
		retval = TacticsRating(PR);	// purposefully uninitialized
	}

	return retval;
}
final simulated static function int TeamInfoTacticsRating ( UnrealTeamInfo UT, optional int lineupsize ) {
	local int retval;
	local float count;
	local int i;
	local PlayerRecord PR;
	local int numchars;

	numchars = Max(UT.RosterNames.Length, lineupsize);
	count = 0; retval = 0;
	for ( i=0; i < numchars; i++ ) {
		count+=1.0;
		retval += TacticsRating(FindPlayerRecord(UT.RosterNames[i]));
	}

	if ( count > 0 ) {
		retval = retval / count;
	} else {
		retval = TacticsRating(PR);	// purposefully uninitialized
	}

	return retval;
}
final simulated static function int TeamArrayTacticsRating ( array<string> Players ) {
	local int retval;
	local float count;
	local int i;
	local PlayerRecord PR;

	count = 0; retval = 0;
	for ( i=0; i < Players.length; i++ ) {
		count+=1.0;
		retval += TacticsRating(FindPlayerRecord(Players[i]));
	}

	if ( count > 0 ) {
		retval = retval / count;
	} else {
		retval = TacticsRating(PR);	// purposefully uninitialized
	}

	return retval;
}
final simulated static function int GetTeamSalaryFor ( GameProfile GP, optional int lineupsize ) {
	local int retval;
	local int i;
	local int numchars;

	numchars = Max(GP.LINEUP_SIZE, lineupsize);
	retval = 0;
	for ( i=0; i < numchars; i++ ) {
		retval += GetSalaryFor(FindPlayerRecord(GP.PlayerTeam[i]));
	}

	return retval;
}
final simulated static function int GetTeamInfoSalaryFor ( UnrealTeamInfo UT, optional int lineupsize ) {
	local int retval;
	local int i;
	local int numchars;

	numchars = Max(UT.RosterNames.Length, lineupsize);
	retval = 0;
	for ( i=0; i < numchars; i++ ) {
		retval += GetSalaryFor(FindPlayerRecord(UT.RosterNames[i]));
	}
	return retval;
}

simulated static function array<class<Mutator> > GetMutatorClasses(optional array<string> MutClassNames)
{
	local int i, j;
	local array<class<Mutator> > Arr;
	local array<CacheManager.MutatorRecord> LocalRecords;

	class'CacheManager'.static.GetMutatorList(LocalRecords);

	if (MutClassNames.Length == 0)
		Arr.Length = LocalRecords.Length;

	for (i = 0; i < LocalRecords.Length; i++)
	{
		if (MutClassNames.Length == 0)
		{
			Arr[i] = class<Mutator>(DynamicLoadObject(LocalRecords[i].ClassName, class'Class'));
			continue;
		}

		for (j = 0; j < MutClassNames.Length; j++)
		{
			if (MutClassNames[j] ~= LocalRecords[i].ClassName)
			{
				Arr[Arr.Length] = class<Mutator>(DynamicLoadObject(LocalRecords[i].ClassName, class'Class'));
				break;
			}
		}
	}

	return Arr;
}

defaultproperties
{
     NoPreference="No Weapon Preference"
     FavoriteWeapon="Favorite Weapon:"
     AgilityString="Agility:"
     TacticsString="Team Tactics:"
     AccuracyString="Accuracy:"
     AggressivenessString="Aggression:"
}
