//==============================================================================
//	Created on: 09/04/2003
//	MaplistManager adds multiple maplist support to UT2004.  To ensure backwards compatibility,
//  it does not change the way the maplist system current works - instead, it enhances this
//  system by serving as the intermediary between the interface and the maplist used by the
//  game.
//  The only contact that MaplistManager has with the standard maplists are when
//    a) Creating the default list for a new gametype - it uses the value of the Maps array for
//       that gametype's maplist
//    b) When the user decides to "Use" or apply the maplist.  The maps in the custom maplist are
//       copied to the gametype's maplist class.
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class MaplistManager extends MaplistManagerBase
	DependsOn(CacheManager)
	DependsOn(MaplistRecord)
	notplaceable;

struct GameRecordGroup
{
	var() string GameType;
	var() string ActiveMaplist;
};

struct MaplistRecordGroup
{
	var string GameType;
	var int    Active;
	var int    LastActive;  // used for cancelling changes

	var array<MaplistRecord.MapItem> AllMaps;
	var array<MaplistRecord> Records;
};

var protected config array<GameRecordGroup>  Games;
var protected array<string> MaplistRecordNames;

var array<CacheManager.GameRecord> 	CachedGames;
var protected array<MaplistRecordGroup> Groups;
var() localized string DefaultListName;
var() localized string InvalidGameType;
var() localized string ReallyInvalidGameType;
var() localized string DefaultListExists;
var   bool bDirty;	// Indicates that we need to save


event PreBeginPlay()
{
	local int i, idx;

	Super.PreBeginPlay();

	// Get list of gametypes
	class'CacheManager'.static.GetGameTypeList(CachedGames);


	// Create records for all record names stored in the ini.
	InitializeMaplistRecords();

	// Initialize all groups
	for (i = 0; i < CachedGames.Length; i++)
	{
		idx = AddGroup(CachedGames[i].ClassName);

		// If this group does not have any records, create a default maplist
		if ( Groups[idx].Records.Length <= 0 )
			CreateDefaultList(i);
	}

	// Set the active list for all groups according to the value in the ini
	InitializeActiveLists();

	// Save if any config values were changed.
	if ( bDirty )
		Save();
}

event Destroyed()
{
	// Make sure we are not destroyed while changes pending
	if ( bDirty )
		Save();

	Super.Destroyed();
}

protected function CreateDefaultList(int i)
{
	local string ListName;
	local array<string> Arr;

	if ( !ValidCacheGameIndex(i) )
		return;

	ListName = DefaultListName @ CachedGames[i].GameAcronym;
	if ( GetDefaultMaps(CachedGames[i].MaplistClassName, Arr)/* && Arr.Length > 0*/ )
		AddList(CachedGames[i].ClassName, ListName, Arr);
}

// returns whether Maplist class was loaded successfully
function bool GetDefaultMaps( string MaplistClassName, out array<string> Maps )
{
	local class<Maplist> List;

	if ( MaplistClassName == "" )
		return false;

	List = class<Maplist>(DynamicLoadObject( MaplistClassName, class'Class', True ));
	if ( List == None )
		return false;

	Maps = List.static.StaticGetMaps();
	return true;
}

protected function InitializeMaplistRecords()
{
	local int i, cnt;
	local MaplistRecord Rec;

	MaplistRecordNames = GetPerObjectNames("System", "MaplistRecord");
	cnt = MaplistRecordNames.Length;

	// First, flush any existing records from all groups (this should never actually happen)
	for ( i = 0; i < Groups.Length; i++ )
		if ( Groups[i].Records.Length > 0 )
			Groups[i].Records.Remove(0, Groups[i].Records.Length);

	for ( i = 0; i < cnt && i < MaplistRecordNames.Length; i++ )
	{
		if ( MaplistRecordNames[i] == "" )
			continue;

		Rec = CreateRecord(MaplistRecordNames[i]);

		// GameType referenced by this MaplistRecord no longer exists, or this name references a non-existent record
		if ( !ValidGameType(Rec.GetGameType()) )
		{
			// Remove the object from the .ini
			Rec.ClearConfig();
			continue;
		}

		AddMaplistRecord(Rec);
	}
}

protected function InitializeActiveLists()
{
	local int i, RecordIndex, idx;

	for ( i = Games.Length - 1; i >= 0; i-- )
	{
		if ( Games[i].GameType == "" )
		{
			RemoveGame(i);
			continue;
		}

		idx = GetGameIndex(Games[i].GameType);
		if ( idx == -1 )
			continue;

		RecordIndex = GetRecordIndex(idx, Games[i].ActiveMaplist);
		if ( RecordIndex < 0 || RecordIndex >= Groups[idx].Records.Length )
			RecordIndex = 0;

		SetActiveList(idx, RecordIndex);
		Groups[idx].LastActive = Groups[idx].Active;
	}
}

protected function int AddMaplistRecord(MaplistRecord Rec)
{
	local int i, j;

	if ( Rec == None || Rec.GetGameType() == "" )
		return -1;

	i = AddGroup(Rec.GetGameType());
	j = Groups[i].Records.Length;
	Rec.SetCacheMaps(Groups[i].AllMaps);
	Groups[i].Records[j] = Rec;

	return j;
}

// Add a group safely - built in protection against duplicates
protected function int AddGroup(string GameType)
{
	local int i;

	if ( GameType == "" )
		return -1;

	i = GetGameIndex(GameType);
	if ( i == -1 )
	{
		i = Groups.Length;
		Groups.Length = i + 1;
		Groups[i].GameType = GameType;

		GenerateGroupMaplist( i );
	}

	AddGameType(GameType);

	return i;
}

// Add a gametype safely - built in protection against duplicates
protected function int AddGameType(coerce string NewGameType)
{
	local int i;

	i = GetStoredGameIndex(NewGameType);
	if ( i == -1 )
	{
		i = Games.Length;
		Games.Length = i + 1;
		Games[i].GameType = NewGameType;
		bDirty = True;
	}
	return i;
}

protected function GenerateGroupMaplist( int GroupIndex )
{
	local int i, j;
	local array<CacheManager.MapRecord> Records;
	local MaplistRecord.MapItem  Item;
	local GameInfo.KeyValuePair Option;
	local string OptionName, OptionValueString;
	local array<string> Options;

	if ( !ValidGameIndex(GroupIndex) )
		return;

	i = GetCacheGameIndex(Groups[GroupIndex].GameType);
	if ( i == -1 )
		return;

	class'CacheManager'.static.GetMapList(Records, CachedGames[i].MapPrefix);
	for ( i = 0; i < Records.Length; i++ )
	{
		class'MaplistRecord'.static.CreateMapItem(Records[i].MapName, Item);
		if ( Records[i].ExtraInfo != "" )
		{
			if ( Divide(Records[i].ExtraInfo, "=", OptionName, OptionValueString) )
			{
				if ( OptionName == "LinkSetups" )
					OptionName = "LinkSetup";

				Split(OptionValueString, ";", Options);
				for ( j = 0; j < Options.Length; j++ )
				{
					Option.Key = OptionName;
					Option.Value = Options[j];

					Item.Options[Item.Options.Length] = Option;
				}
			}
		}

		Groups[GroupIndex].AllMaps[Groups[GroupIndex].AllMaps.Length] = Item;
	}

}

protected function bool RemoveGame(int i)
{
	if ( i < 0 || i >= Games.Length )
		return false;

	Games.Remove(i, 1);
	bDirty = True;
	return true;
}

protected function int RemoveRecord(int GameIndex, int RecordIndex)
{
	if ( !ValidRecordIndex(GameIndex, RecordIndex) )
		return -1;

	Groups[GameIndex].Records[RecordIndex].ClearConfig();
	Groups[GameIndex].Records.Remove(RecordIndex, 1);
	if ( !ValidRecordIndex(GameIndex, RecordIndex) )
		RecordIndex = 0;

	return RecordIndex;
}

protected function int GetStoredGameIndex(coerce string GameType)
{
	local int i;

	if ( GameType == "" )
		return -1;

	for ( i = 0; i < Games.Length; i++ )
	{
		if ( Games[i].GameType ~= GameType )
			return i;
	}

	return -1;
}

protected function Save()
{
	if ( bDirty )
	{
		SaveConfig();
		bDirty = False;
	}
}

protected function MaplistRecord CreateRecord(string RecordName)
{
	if ( RecordName == "" )
		return None;

	return new(None, Repl(RecordName, " ", Chr(27))) class'MaplistRecord';
}

protected function bool IsNewGameType(string GameClassName)
{
	return GetStoredGameIndex(GameClassName) == -1;
}

// Never allow direct access to my records
protected function array<MaplistRecord> GetRecords(int GameIndex)
{
	if ( ValidGameIndex(GameIndex) )
		return Groups[GameIndex].Records;
}

protected function bool ValidRecordIndex(int GameIndex, int MapListIndex)
{
	return ValidGameIndex(GameIndex) && MaplistIndex >= 0 && MaplistIndex < Groups[GameIndex].Records.Length && Groups[GameIndex].Records[MapListIndex] != None;
}
/*
protected function bool ValidRecordNameIndex(int Index)
{
	return Index >= 0 && Index < MaplistRecordNames.Length;
}
*/
///////////////////////////////////////////////////////////////////
// Public Modifier Methods
//
//

// Called by maplist when the map changes
function MapChange(string NewMap)
{
	local int i, GameIndex, RecordIndex;

	GameIndex = AddGroup(string(Level.Game.Class));
	if ( ValidRecordIndex(GameIndex, Groups[GameIndex].Active) )
	{
		RecordIndex = Groups[GameIndex].Active;
		i = Groups[GameIndex].Records[RecordIndex].GetMapIndex(NewMap);

		// Uh oh!  The active maplist doesn't contain this map - should we ignore or attempt to find a maplist containing this map?
		if ( i == -1 )
		{
			// Attempt to find and activate a custom maplist containing this map
			RecordIndex = FindMaplistContaining(GameIndex, NewMap);
			if ( SetActiveList(GameIndex, RecordIndex) )
				i = Groups[GameIndex].Records[RecordIndex].GetMapIndex(NewMap);
		}
	}
	else
	{
		RecordIndex = FindMaplistContaining(GameIndex, NewMap);
		if ( SetActiveList(GameIndex, RecordIndex) )
			i = Groups[GameIndex].Records[RecordIndex].GetMapIndex(NewMap);
	}

	if ( i != -1 && ValidRecordIndex(GameIndex, RecordIndex) )
	{
		Groups[GameIndex].Records[RecordIndex].SetActiveMap(i);
		SaveMaplist(GameIndex, RecordIndex);
	}
}

// Add a new maplist
function int AddList(string GameType, string NewName, array<string> Maps)
{
	local int i;
	local MaplistRecord NewRecord;
	local string DesiredName;

	if ( !ValidGameType(GameType) )
		return -1;

	//check that we aren't using this name already
	// If so, generate a unique name
	DesiredName = NewName;
	while ( ValidName(NewName) )
		NewName = DesiredName $ string(i++);

	// Clamp the length of the name to a reasonable value
	if ( Len(NewName) > 512 )
		return -1;

	NewRecord = CreateRecord(NewName);
	if ( NewRecord == None )
		return -1;

	NewRecord.SetGameType(GameType);
	NewRecord.SetTitle(NewName);

	i = AddMaplistRecord(NewRecord);

	// Make sure new maplist always has maps
	if (Maps.Length == 0)
		NewRecord.Clear(true);
	else NewRecord.SetMapList(Maps);

	NewRecord.Save();
	if ( bDirty )
		Save();

	return i;
}
// Since the lists are PerObjectConfig, and the section of the ini is determined by the object's name,
// it is impossible to "rename" a list.  Instead, I must destroy this list, and create a new one with the
// desired name.
function int RenameList(int GameIndex, int RecordIndex, string NewName)
{
	local MaplistRecord OldRecord;
	local bool IsActive;

	if (!ValidRecordIndex(GameIndex, RecordIndex))
		return -1;

	if ( NewName == "" )
		return -1;

	IsActive = GetActiveList(GameIndex) == RecordIndex;
	OldRecord = Groups[GameIndex].Records[RecordIndex];
	RemoveRecord(GameIndex, RecordIndex);

	// Copy everything from the old list to the new list.
	RecordIndex = AddList(OldRecord.GetGameType(), NewName, OldRecord.GetAllMapURL());
	if ( ValidRecordIndex(GameIndex, RecordIndex) )
	{
		Groups[GameIndex].Records[RecordIndex].SetActiveMap(OldRecord.GetActiveMapIndex());

		if ( IsActive && !SetActiveList(GameIndex, RecordIndex) )
			RecordIndex = GetActiveList(GameIndex);
	}

	return RecordIndex;
}
function int RemoveList(int GameIndex, int RecordIndex)
{
	local int i, idx;

	if (!ValidRecordIndex(GameIndex, RecordIndex))
		return GetActiveList(GameIndex);

	idx = RemoveRecord(GameIndex, RecordIndex);

	// If this was the gametype's last record, regenerate a default maplist
	if ( Groups[GameIndex].Records.Length == 0 )
	{
		i = GetCacheGameIndex(Groups[GameIndex].GameType);
		CreateDefaultList(i);
	}

	// If this was the gametype's active list, reset active to the first list.
	if ( Groups[GameIndex].Active < 0 ||
	     Groups[GameIndex].Active == RecordIndex ||
		 Groups[GameIndex].Active >= Groups[GameIndex].Records.Length )
	{
		SetActiveList(GameIndex, 0);
		ApplyMaplist(GameIndex, 0);
	}

	// If we created a new list or had to change the active list
	if ( bDirty )
		Save();

	return idx;
}
// Save a maplist
function bool SaveMapList(int GameIndex, int RecordIndex)
{
	if (!ValidRecordIndex(GameIndex,RecordIndex))
		return false;

	Save();
	Groups[GameIndex].Records[RecordIndex].Save();
	return true;
}
function bool ClearList(int GameIndex, int RecordIndex)
{
	if (!ValidRecordIndex(GameIndex, RecordIndex))
		return false;

	Groups[GameIndex].Records[RecordIndex].Clear();
	return true;
}
function ResetList(int GameIndex, int RecordIndex)
{
	if (!ValidRecordIndex(GameIndex, RecordIndex))
		return;

	Groups[GameIndex].Records[RecordIndex].CancelChanges();
}

// Apply or cancel changes
function bool SaveGame(int GameIndex)
{
	local int i, Active;

	if (!ValidGameIndex(GameIndex))
		return false;

	Groups[GameIndex].LastActive = Groups[GameIndex].Active;

	i = AddGameType(Groups[GameIndex].GameType);

	Active = GetActiveList(GameIndex);
	if ( !ValidRecordIndex(GameIndex, Active) )
		SetActiveList(GameIndex, 0);

	for ( i = 0; i < Groups[GameIndex].Records.Length; i++ )
		SaveMaplist(GameIndex, i);

	Save();
	return True;
}
function ResetGame(int GameIndex)
{
	local int i;
	local int RecordIndex;

	if ( !ValidGameIndex(GameIndex) )
		return;

	// Reset all lists for this gametype.
	for ( i = 0; i < Groups[GameIndex].Records.Length; i++ )
		ResetList(GameIndex, i);

	i = GetStoredGameIndex(Groups[GameIndex].GameType);

	// Reset the gametype's active maplist
	RecordIndex = GetRecordIndex(GameIndex, Games[i].ActiveMaplist);
	if ( !ValidRecordIndex(GameIndex, RecordIndex) )
		RecordIndex = 0;

	SetActiveList(GameIndex, RecordIndex);
}

function bool ApplyMapList(int GameIndex, int RecordIndex)
{
	local class<MapList> ListClass;
	local int i;

	if (ValidRecordIndex(GameIndex, RecordIndex))
	{
		SetActiveList(GameIndex, RecordIndex);
		SaveGame(GameIndex);
		i = GetCacheGameIndex(Groups[GameIndex].GameType);
		if (i == -1)
		{
			Warn("Error applying maplist:"@Groups[GameIndex].GameType);
			return false;
		}

		ListClass = class<MapList>(DynamicLoadObject(CachedGames[i].MapListClassName,Class'Class'));
		if ( ListClass == None )
		{
			log("Invalid maplist class:"@CachedGames[i].MaplistClassName@"for gametype"@Cachedgames[i].ClassName);
			return false;
		}

		ListClass.static.SetMaplist( GetActiveMap(GameIndex,RecordIndex), GetMaplist(GameIndex,RecordIndex) );
 		return true;
	}
	else log("Invalid maplist index");

	return false;
}
function bool SetActiveList(int GameIndex, int NewActive)
{
	local int i;

	if (!ValidRecordIndex(GameIndex, NewActive))
		return false;

	i = AddGameType(Groups[GameIndex].GameType);

	Games[i].ActiveMaplist = Groups[GameIndex].Records[NewActive].GetTitle();
	Groups[GameIndex].Active = NewActive;
	bDirty = True;

	return true;
}


// Add a new map to the current maplist
function bool AddMap(int GameIndex, int RecordIndex, string MapName)
{
	if (ValidRecordIndex(GameIndex, RecordIndex))
		return Groups[GameIndex].Records[RecordIndex].AddMap(MapName);

	return false;
}
function bool InsertMap(int GameIndex, int RecordIndex, string MapName, int ListIndex)
{
	if ( ValidRecordIndex(GameIndex, RecordIndex) )
		return Groups[GameIndex].Records[RecordIndex].InsertMap(MapName, ListIndex);

	return false;
}

function bool RemoveMap(int GameIndex, int RecordIndex, string MapName)
{
	if (ValidRecordIndex(GameIndex, RecordIndex))
		return Groups[GameIndex].Records[RecordIndex].RemoveMap(MapName);

	return false;
}
// Adapted from xWebAdmin.StringArray
function ShiftMap(int GameIndex, int RecordIndex, string MapName, int Count)
{
	local int i;
	local array<MaplistRecord.MapItem> Maps;

	if (!ValidRecordIndex(GameIndex, RecordIndex))
		return;

	if ( Count == 0 )
		return;

	i = Groups[GameIndex].Records[RecordIndex].GetMapIndex( MapName );
	if ( i == -1 )
		return;

	Maps = Groups[GameIndex].Records[RecordIndex].GetMaps();
	if (Count < 0)
	{
		// Move items toward 0
		if (i + Count < 0)
			Count = -i;
		Maps.Insert(i + Count, 1);
		Maps[i+Count] = Maps[i+1];
		Maps.Remove( i + 1, 1 );
	}
	else
	{
		if ((i + Count + 1) >= Maps.Length)
			Count = Maps.Length - i - 1;

		Maps.Insert(i + Count + 1, 1);
		Maps[i + Count + 1] = Maps[i];
		Maps.Remove(i, 1);
	}

	Groups[GameIndex].Records[RecordIndex].SetMapItemList( Maps );
}
function int SetActiveMap(int GameIndex, int RecordIndex, int MapIndex)
{
	if ( !ValidRecordIndex(GameIndex, RecordIndex) )
		return -1;

	return Groups[GameIndex].Records[RecordIndex].SetActiveMap(MapIndex);
}

///////////////////////////////////////////////////////////////////
// Public Accessor Methods
//
//
function int GetGameIndex(coerce string GameType)
{
	local int i;

	if ( GameType == "" )
		return -1;

	for(i = 0; i < Groups.Length; i++)
		if (Groups[i].GameType ~= GameType)
			return i;

	return -1;
}
function int GetCacheGameIndex(string GameType)
{
	local int i;

	for (i = 0; i < CachedGames.Length; i++)
		if (CachedGames[i].ClassName ~= GameType)
			return i;

	return -1;
}


function array<string> GetMapListNames(int GameIndex)
{
	local int i, idx;
	local array<MaplistRecord> Records;
	local array<string> Arr;

	if (ValidGameIndex(GameIndex))
	{
		Records = GetRecords(GameIndex);
		if ( Records.Length == 0 )
		{
			idx = GetCacheGameIndex(Groups[GameIndex].GameType);
			CreateDefaultList(idx);
			Records = GetRecords(GameIndex);
		}
		Arr.Length = Records.Length;

		for (i = 0; i < Records.Length; i++)
			Arr[i] = Records[i].GetTitle();
	}

	return Arr;
}

function array<string> GetCurrentMapRotation()
{
	local int GameIndex, RecordIndex, CurrentMap, i;
	local array<string> Ar;

	if ( Level.Game == None )
		return Ar;

	GameIndex = GetGameIndex(Level.Game.Class);
	RecordIndex = GetActiveList(GameIndex);
	CurrentMap = GetActiveMap(GameIndex, RecordIndex);

	Ar = GetMaplist(GameIndex, RecordIndex);
	while (i < CurrentMap)
		Ar[Ar.Length] = Ar[i++];

	if ( i > 0 && Ar.Length > 0 )
		Ar.Remove(0, i);

	return Ar;
}

function string GetActiveMapName( int GameIndex, int RecordIndex )
{
	if ( ValidRecordIndex(GameIndex, RecordIndex) )
		return Groups[GameIndex].Records[RecordIndex].GetActiveMapName();
}

function string GetMapTitle( int GameIndex, int RecordIndex, int MapIndex )
{
	if ( ValidRecordIndex(GameIndex, RecordIndex) )
		return Groups[GameIndex].Records[RecordIndex].GetMapName(MapIndex);
}

function string GetMapURL( int GameIndex, int RecordIndex, int MapIndex )
{
	if ( ValidRecordIndex(GameIndex, RecordIndex) )
		return Groups[GameIndex].Records[RecordIndex].GetMapURL(MapIndex);
}

function array<string> GetMapList(int GameIndex, int RecordIndex)
{
	local array<string> Maps;

	if (ValidRecordIndex(GameIndex, RecordIndex))
		Maps = Groups[GameIndex].Records[RecordIndex].GetAllMapURL();

	return Maps;
}

function bool GetAvailableMaps( int GameIndex, out array<MaplistRecord.MapItem> Ar )
{
	if ( !ValidGameIndex(GameIndex) )
		return False;

	Ar = Groups[GameIndex].AllMaps;
	return True;
}

function array<string> GetCacheMapList(string Acronym)
{
	local int i, j;
	local array<CacheManager.MapRecord> TempRecords;
	local array<string> Arr;

	class'CacheManager'.static.GetMapList(TempRecords, Acronym);

	Arr.Length = TempRecords.Length;
	for (i = TempRecords.Length - 1; i >= 0; i--)
		Arr[j++] = TempRecords[i].MapName;

	return Arr;
}
function int FindMaplistContaining(int GameIndex, string Mapname)
{
	local int i, idx;

	if ( ValidGameIndex(GameIndex) )
	{
		for ( i = 0; i < Groups[GameIndex].Records.Length; i++ )
		{
			idx = Groups[GameIndex].Records[i].GetMapIndex(MapName);
			if ( idx != -1 )
				return i;
		}
	}

	return -1;
}
function int GetMapIndex(int GameIndex, int RecordIndex, string MapName)
{
	if ( ValidRecordIndex(GameIndex, RecordIndex) )
		return Groups[GameIndex].Records[RecordIndex].GetMapIndex(MapName);

	return -1;
}
function int GetRecordIndex(int GameIndex, string MapListName)
{
	local int i;
	local array<MaplistRecord> Records;


	if ( ValidGameIndex(GameIndex) )
	{
		if ( MaplistName == "" )
			return GetActiveList(GameIndex);

		Records = GetRecords(GameIndex);
		for ( i = 0; i < Records.Length; i++ )
			if ( Records[i] != None && Records[i].GetTitle() ~= MaplistName )
				return i;
	}

	return -1;
}
function string GetMapListTitle(int GameIndex, int RecordIndex)
{
	if (ValidRecordIndex(GameIndex, RecordIndex))
		return Groups[GameIndex].Records[RecordIndex].GetTitle();

	return "";
}


function int GetActiveList(int GameIndex)
{
	if (ValidGameIndex(GameIndex))
		return Groups[GameIndex].Active;

	return -1;
}
function int GetActiveMap(int GameIndex, int RecordIndex)
{
	if ( !ValidRecordIndex(GameIndex,RecordIndex) )
		return -1;

	return Groups[GameIndex].Records[RecordIndex].GetActiveMapIndex();
}

function bool ValidCacheGameIndex(int i)
{
	return i >= 0 && i < CachedGames.Length;
}

function bool ValidGameIndex(int i)
{
	return i >= 0 && i < Groups.Length;
}

function bool ValidGameType(string GameType)
{
	local int i;

	for (i = 0; i < CachedGames.Length; i++)
	{
		if (GameType ~= CachedGames[i].ClassName)
			return true;
	}

	return false;
}
function bool ValidName(string S)
{
	local int i, j;

	if ( S == "" )
		return false;

	for ( i = 0; i < Groups.Length; i++ )
	{
		for ( j = 0; j < Groups[i].Records.Length; j++ )
			if ( Groups[i].Records[j] != None && Groups[i].Records[j].GetTitle() ~= S )
				return true;
	}

	return false;
}

function bool MaplistDirty(int GameIndex, int RecordIndex)
{
	if ( ValidRecordIndex(GameIndex, RecordIndex) )
		return Groups[GameIndex].Records[RecordIndex].IsDirty() || bDirty;

	return bDirty;
}

defaultproperties
{
     Games(0)=(GameType="BonusPack.xLastManStandingGame",ActiveMaplist="Default LMS")
     Games(1)=(GameType="BonusPack.xMutantGame",ActiveMaplist="Default MUT")
     Games(2)=(GameType="Onslaught.ONSOnslaughtGame",ActiveMaplist="Default ONS")
     Games(3)=(GameType="SkaarjPack.Invasion",ActiveMaplist="Default INV")
     Games(4)=(GameType="UT2k4Assault.ASGameInfo",ActiveMaplist="Default AS")
     Games(5)=(GameType="XGame.xBombingRun",ActiveMaplist="Default BR")
     Games(6)=(GameType="XGame.xCTFGame",ActiveMaplist="Default CTF")
     Games(7)=(GameType="XGame.xDeathMatch",ActiveMaplist="Default DM")
     Games(8)=(GameType="XGame.xDoubleDom",ActiveMaplist="Default DOM2")
     Games(9)=(GameType="XGame.xTeamGame",ActiveMaplist="Default TDM")
     Games(10)=(GameType="XGame.xVehicleCTFGame")
     DefaultListName="Default"
     InvalidGameType="could not be loaded.  Normally, this means an .u file has been deleted, but the .int file has not."
     ReallyInvalidGameType="The requested gametype '%gametype%' could not be loaded."
     DefaultListExists="Gametype already has a default list!"
}
