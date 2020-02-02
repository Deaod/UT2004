//==============================================================================
//	Created on: 09/04/2003
//	Stores custom maplists for each gametype.
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class MaplistRecord extends Object
	PerObjectConfig
	DependsOn(GameInfo)
	notplaceable
	transient;

struct MapItem
{
	var() string MapName;
	var() string OptionString;
	var() string FullURL;
	var() array<GameInfo.KeyValuePair> Options;
};

var protected bool bDirty;
var protected string Title;        // Title of this custom maplist
var protected string GameType;     // The gametype associated with this custom maplist
var protected int    Active;       // The index of the currently active map

var protected array<MapItem> Maps;
//var protected array<string> Maps;

// accessing default values of PerObjectConfig objects doesn't work as desired
//  (does not access the default values for that object)
var protected config string DefaultTitle;
var protected config string DefaultGameType;
var protected config int DefaultActive;

var protected config array<string> DefaultMaps;
//var protected config array<string> DefaultMaps;

var protected array<MapItem> CachedMaps;

static final operator(24) bool == ( GameInfo.KeyValuePair A, GameInfo.KeyValuePair B )
{
	return A.Key ~= B.Key && A.Value ~= B.Value;
}

static final operator(24) bool == ( MapItem A, MapItem B )
{
	local int i, j;

	if ( !(A.MapName ~= B.MapName) )
		return False;

	if ( A.Options.Length != B.Options.Length )
		return False;

	for ( i = 0; i < A.Options.Length; i++ )
	{
		for ( j = 0; j < B.Options.Length; j++ )
		{
			if ( A.Options[i] == B.Options[j] )
				break;
		}

		if ( j == B.Options.Length )
			return False;
	}

	return True;
}

static function bool CompareItems(MapItem A, MapItem B)
{
	return A == B;
}

static function bool CompareItemsSlow(MapItem A, MapItem B)
{
	local int i, j, MatchedA, MatchedB;

	if ( A == B )
		return True;

	if ( !(A.MapName ~= B.MapName) )
		return False;

	for ( i = 0; i < A.Options.Length; i++ )
	{
		for ( j = 0; j < B.Options.Length; j++ )
		{
			if ( A.Options[i] == B.Options[j] )
				break;
		}

		if ( j < B.Options.Length )
			MatchedA++;
	}


	for ( i = 0; i < B.Options.Length; i++ )
	{
		for ( j = 0; j < A.Options.Length; j++ )
		{
			if ( B.Options[i] == A.Options[j] )
				break;
		}

		if ( j < A.Options.Length )
			MatchedB++;
	}

	if ( (A.Options.Length > 0 && MatchedA == A.Options.Length) ||
	     (B.Options.Length > 0 && MatchedB == B.Options.Length) )
	    return True;

	return False;
}

// =====================================================================================================================
// =====================================================================================================================
//  Initialization
// =====================================================================================================================
// =====================================================================================================================
event Created()
{
	CancelChanges();
}

function SetCacheMaps(array<MapItem> CacheMaps)
{
	CachedMaps = CacheMaps;
	VerifyMaps();
}

function bool SetTitle(string NewTitle)
{
	if ( NewTitle != "" )
	{
		bDirty = bDirty || !(NewTitle ~= Title);
		Title = NewTitle;
		return true;
	}

	return false;
}

function bool SetGameType(string NewGameType)
{
	if ( NewGameType != "" )
	{
		bDirty = bDirty || !(NewGameType ~= GameType);
		GameType = NewGameType;
		return true;
	}

	return false;
}

function int SetActiveMap(int i)
{
	if ( ValidIndex(i) )
	{
		bDirty = bDirty || Active != i;
		Active = i;
		return Active;
	}

	return -1;
}

function SetMaplist(array<string> NewMaps)
{
	CreateMapItemList( NewMaps, Maps );
	bDirty = True;
}

function SetMapItemList( array<MapItem> NewMaps )
{
	Maps = NewMaps;
	bDirty = True;
}

// =====================================================================================================================
// =====================================================================================================================
//  Internal
// =====================================================================================================================
// =====================================================================================================================

function Save()
{
	local int i;

	if ( bDirty )
	{
		if ( !ValidIndex(Active) )
			Active = 0;

		DefaultTitle = Title;
		DefaultGameType = GameType;
		DefaultActive = Active;

		DefaultMaps.Length = Maps.Length;
		for ( i = 0; i < Maps.Length; i++ )
			DefaultMaps[i] = Maps[i].FullURL;

		SaveConfig();
	}


	bDirty = False;
}

function VerifyMaps()
{
	local int i;

	for ( i = DefaultMaps.Length - 1; i >= 0; i-- )
	{
		// If map wasn't found in list of cached maps - remove it
		if ( GetCacheIndex(DefaultMaps[i]) == -1 )
			DefaultMaps.Remove(i,1);
	}

	for ( i = Maps.Length - 1; i >= 0; i-- )
	{
		if ( GetCacheIndex(Maps[i].FullURL) == -1 )
		{
			Maps.Remove(i,1);
			bDirty = True;
		}
	}
}

function CancelChanges()
{
	Title = DefaultTitle;
	GameType = DefaultGameType;
	Active = DefaultActive;
	CreateMapItemList( DefaultMaps, Maps );
	bDirty = False;
}

// Remove all maps from the maplist
function Clear( optional bool bReset )
{
	Active = -1;
	Maps.Remove(0, Maps.Length);

	if ( bReset )
		Maps = CachedMaps;

	bDirty = True;
}

// =====================================================================================================================
// =====================================================================================================================
//  Single Map Item Initialization
// =====================================================================================================================
// =====================================================================================================================

// Add a new option to a MapItem (as a string)
function bool AddOptionString( int MapIndex, string OptionString )
{
	local GameInfo.KeyValuePair Option;

	if ( OptionString == "" || Left(OptionString, 1) != "?" )
		return False;

	Option = CreateMapOption(OptionString);
	return AddOptionItem(MapIndex, Option);
}

// Add a new option to a MapItem
function bool AddOptionItem( int MapIndex, GameInfo.KeyValuePair Option )
{
	if ( !ValidIndex(MapIndex) )
		return False;

	if ( MapHasOption(MapIndex, Option) )
		return false;

	bDirty = True;
	Maps[MapIndex].Options[Maps[MapIndex].Options.Length] = Option;
	return True;
}

function bool RemoveOptionString( int MapIndex, string OptionString )
{
	local GameInfo.KeyValuePair Pair;

	if ( OptionString == "" || Left(OptionString,1) != "?" )
		return False;

	Pair = CreateMapOption(OptionString);
	return RemoveOptionItem( MapIndex, Pair );
}

function bool RemoveOptionItem( int MapIndex, GameInfo.KeyValuePair Option )
{
	local int i;

	if ( !ValidIndex(MapIndex) )
		return False;

	if ( !MapHasOption(MapIndex,Option) )
		return False;

	i = GetOptionIndex(MapIndex, Option);
	if ( ValidOptionIndex(MapIndex,i) )
	{
		bDirty = True;
		Maps[MapIndex].Options.Remove(i, 1);
		RefreshMapItem(MapIndex);
		return True;
	}

	return False;
}

function RefreshMapItem( int MapIndex )
{
	local string FullMapURL;
	local int i;


	if ( !ValidIndex(MapIndex) )
		return;

	FullMapURL = Maps[MapIndex].MapName;
	for ( i = 0; i < Maps[MapIndex].Options.Length; i++ )
	{
		FullMapURL $= "?" $ Maps[MapIndex].Options[i].Key;
		if ( Maps[MapIndex].Options[i].Value != "" )
			FullMapURL $= "=" $ Maps[MapIndex].Options[i].Value;
	}

	Maps[MapIndex].FullURL = FullMapURL;
	Maps[MapINdex].MapName = GetBaseMapName(FullMapURL);
	Maps[MapIndex].OptionString = FullMapURL;
	bDirty = True;
}

// =====================================================================================================================
// =====================================================================================================================
//  Maplist Manipulation
// =====================================================================================================================
// =====================================================================================================================

// Add a new map by name, which may optionally contain commandline parameters
function bool AddMap(string MapName)
{
	local int CacheIndex;
	local MapItem Item;

	CacheIndex = GetCacheIndex(MapName);
	if ( CacheIndex == -1 )
		return false;

	if ( !CreateMapItem(MapName,Item) )
		return False;

	if ( GetMapItemIndex(Item) != -1 )
		return False;

	Maps[Maps.Length] = Item;
	bDirty = True;
	return true;
}

function bool InsertMap(string MapName, int Index)
{
	local MapItem Item;

	if ( GetCacheIndex(MapName) == -1 )
		return false;

	if ( !CreateMapItem(MapName,Item) )
		return False;

	if ( GetMapItemIndex(Item) != -1 )
		return False;

	Maps.Insert(Index, 1);
	Maps[Index] = Item;
	bDirty = True;
	return true;
}

// Remove a map - returns false if map wasn't found.
function bool RemoveMap(string MapName)
{
	local int i;
	local MapItem Item;

	if ( GetCacheIndex(MapName) == -1 )
		return false;

	if ( !CreateMapItem(MapName,Item) )
		return False;

	i = GetMapItemIndex(Item);
	if ( i == -1 )
		return False;

	Maps.Remove(i,1);
	bDirty = True;
	return true;
}

function bool SetMapOptions( int MapIndex, string OptionString )
{
	local string MapName;

	if ( !ValidIndex(MapIndex) )
		return False;

	MapName = GetBaseMapName(OptionString);
	if ( MapName == "" )
		MapName = Maps[MapIndex].MapName;

	MapName $= OptionString;
	if ( !CreateMapItem(MapName, Maps[MapIndex]) )
		return False;

	bDirty = True;
	return True;
}

// =====================================================================================================================
// =====================================================================================================================
//  String Queries
// =====================================================================================================================
// =====================================================================================================================

function string GetTitle()
{
	return Title;
}

function string GetGameType()
{
	return GameType;
}

function string GetActiveMapName()
{
	return GetMapName(Active);
}

function string GetActiveMapURL()
{
	return GetMapURL( Active );
}

function string GetMapName(int i)
{
	if ( ValidIndex(i) )
		return Maps[i].MapName;

	return "";
}


// Grab the full map url that should be used in the actual maplist
function string GetMapURL( int Index )
{
//	local string str;
//	local int i;

	if ( ValidIndex(Index) )
		return Maps[Index].FullURL;
/*	{
		str = Maps[Index].MapName;
		for ( i = 0; i < Maps[Index].Options.Length; i++ )
		{
			str $= "?" $ Maps[Index].Options[i].Pair.Key;
			if ( Maps[Index].Options[i].Pair.Value != "" )
				str $= "=" $ Maps[Index].Options[i].Pair.Value;
		}
	}
*/
	return "";
}

function array<MapItem> GetMaps()
{
	return Maps;
}

function array<string> GetAllMapURL()
{
	local int i;
	local array<string> Ar;

	for ( i = 0; i < Maps.Length; i++ )
		Ar[i] = Maps[i].FullURL;

	return Ar;
}

function bool IsDirty()
{
	return bDirty;
}

// =====================================================================================================================
// =====================================================================================================================
//  Index Queries
// =====================================================================================================================
// =====================================================================================================================
// Returns the index of the mapname in the CacheManager maprecords array
function int GetCacheIndex(string MapName)
{
	local int i;
	local string str;

	str = GetBaseMapName(MapName);
	for ( i = 0; i < CachedMaps.Length; i++ )
	{
		if ( str ~= CachedMaps[i].MapName )
			return i;
	}

	return -1;
}

// Returns the index of the currently active map
function int GetActiveMapIndex()
{
	return Active;
}

function int GetMapIndex(string MapName)
{
	local MapItem Item;

	if ( CreateMapItem(MapName,Item) )
		return GetMapItemIndex(Item);

	return -1;
}

// Returns the index of a map with the options matching those specified
function int GetMapItemIndex( MapItem Item )
{
	local int i;

	for ( i = 0; i < Maps.Length; i++ )
		if ( Maps[i] == Item )
			return i;

	return -1;
}

// Return the index of the specified option for the specified MapItem
function int GetOptionIndex( int MapIndex, GameInfo.KeyValuePair Option )
{
	local int i;

	if ( !ValidIndex(MapIndex) )
		return -1;

	for ( i = 0; i < Maps[MapIndex].Options.Length; i++ )
		if ( Maps[MapIndex].Options[i] == Option )
			return i;

	return -1;
}

// =====================================================================================================================
// =====================================================================================================================
//  Validation Queries
// =====================================================================================================================
// =====================================================================================================================
function bool ValidMap(string MapName)
{
	return GetMapIndex(MapName) != -1;
}

function bool ValidIndex(int i)
{
	return i >= 0 && i < Maps.Length;
}

function bool ValidOptionIndex(int MapIndex, int OptionIndex)
{
	return ValidIndex(MapIndex) && OptionIndex >= 0 && OptionIndex < Maps[MapIndex].Options.Length;
}

function bool MapHasOption( int MapIndex, GameInfo.KeyValuePair Option )
{
	if ( !ValidIndex(MapIndex) )
		return False;

	return ItemHasOption(Maps[MapIndex], Option);
}

// Determine whether the MapItem contains the Option
static function bool ItemHasOption( MapItem Item, GameInfo.KeyValuePair Option )
{
	local int i;

	for ( i = 0; i < Item.Options.Length; i++ )
		if ( Item.Options[i] == Option )
			return True;

	return False;
}

// =====================================================================================================================
// =====================================================================================================================
//  Conversion Methods
// =====================================================================================================================
// =====================================================================================================================

// Given a full map url, optionally containing parameters, parse and return the mapname, leaving the options in the string
static function string GetBaseMapName( out string FullMapURL )
{
	local int i;
	local string str;

	str = FullMapURL;
	FullMapURL = "";

	i = InStr(str, "?");
	if ( i != -1 )
	{
		FullMapURL = Mid(str, i);
		str = Left(str, i);
	}

	if ( Right(str,4) ~= ".ut2" )
		str = Left(str, Len(str) - 4);

	return str;
}

// Create a map option given the option string (basically just a proxy for GameInfo.GetKeyValue)
static function GameInfo.KeyValuePair CreateMapOption( out string MapOptionString )
{
	local GameInfo.KeyValuePair Pair;
	class'GameInfo'.static.GetKeyValue(MapOptionString, Pair.Key, Pair.Value);
	return Pair;
}

// Given a full map url, optionally containing parameters, create a new MapItem and return the result
static function bool CreateMapItem( string FullMapURL, out MapItem Item )
{
	local GameInfo.KeyValuePair Pair;
	local string str;

	if ( FullMapURL == "" )
		return false;

	Item.FullURL = Repl(FullMapURL, ".ut2", "");
	Item.MapName = GetBaseMapName(FullMapURL);
	Item.OptionString = FullMapURL;
	Item.Options.Remove( 0, Item.Options.Length );

	while ( class'GameInfo'.static.GrabOption(FullMapURL, str) )
	{
		Pair = CreateMapOption(str);
		if ( !ItemHasOption(Item, Pair) )
			Item.Options[Item.Options.Length] = Pair;
	}

	return Item.MapName != "";
}

static function CreateMapItemList( array<string> MapURLs, out array<MapItem> MapItems )
{
	local int i;
	local MapItem Item;

//	stopwatch(false);
//	log("Creating MapItem list: "$MapURLs.Length@"Elements to be created");

	// First, clear the array
	MapItems.Remove( 0, MapItems.Length );
	for ( i = 0; i < MapURLs.Length; i++ )
	{
		if ( CreateMapItem(MapURLs[i], Item) )
			MapItems[MapItems.Length] = Item;
	}

//	log("Completed building MapItem list - "$MapItems.Length@"Elements");
//	stopwatch(true);
}

defaultproperties
{
}
