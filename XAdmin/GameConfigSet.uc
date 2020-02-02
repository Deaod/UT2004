// ====================================================================
//  Class:  XAdmin.GameConfigSet
//  Parent: XAdmin.xAdminConfigBase
//
//  This class is responsible for handling changes to a Game default
//  Behavior like Map List,Mutators and Ini Settings.
// ====================================================================

class GameConfigSet extends Object;

var LevelInfo	Level;			// Need access to Level function

var protected class<GameInfo>	GameClass;		// Which game class is being edited
var protected int				GameIndex;		// Index of GameClass
var protected PlayInfo			Settings;		// Game Setting Defaults
var int 						CurrentMapList;	// Index of maplist we're editing

var protected array<int>		UsedMutators;	// List of Mutators in use
var protected array<int>		UsedMaps;		// Index of maps within active maplist

// Maintaining Global Lists
var protected string			AllMapsPrefix;	// Which map prefix is currently loaded
var protected array<string>		AllMapLists;	// List of all maplists for the specified gametype
var protected array<string>		AllMaps;		// List of all Maps for the specified gametype.
var protected array<string>		AllMutators;	// List of all available mutators
var protected array< class<GameInfo> >	AllGameTypes;

var string NextMutators;						// What mutators were set during this session
var protected bool bEdit;						// We are currently editing something

function bool StartEdit(optional string GameType)
{
	if (Level == None || bEdit)
		return false;

	// Load all Game Types, unless already loaded
	if (AllGameTypes.Length == 0)
		LoadGameTypes();

	// Load All Mutators (Unless already loaded)
	if (AllMutators.Length == 0)
		LoadAllMutators();

	// If no GameType Specified, use currently loaded one.
	if (GameType == "")
		GameType = String(Level.Game.Class);

	// When editing allow for many ways to find the good game class
	// Try with Acronym, Class, Alternate class, etc
	GameClass = FindGameType(GameType);

	log("GameClass is"@GameClass);

	if (GameClass == None)
		return false;

	LoadAllMaps();
	GameIndex = Level.Game.MaplistHandler.GetGameIndex(string(GameClass));
	CurrentMapList = GetActiveList();
	AllMapLists = GetLists();

	// Load Game Setting
	LoadSettings(GameClass);

	// Fill in Used Mutators
	SetUsedMutators();
	NextMutators = "";

	bEdit = true;
	return true;
}

function bool EndEdit(bool bSave)
{
local int i;

	if (Level == None || !bEdit)
		return false;

	// Save all data where it belongs
	if (bSave)
	{
//		Log("GCS.EndEdit is now Saving All the Data");
		// Commit to PlayInfo
		Settings.SaveSettings();
		NextMutators = "";
		if (UsedMutators.Length > 0)
		{
            NextMutators = AllMutators[UsedMutators[0]];
			for (i=1; i<UsedMutators.Length; i++)
				NextMutators = NextMutators$","$AllMutators[UsedMutators[i]];
		}
//		Log("CGS.NextMutators="@NextMutators);
		Level.Game.MaplistHandler.SaveGame(GameIndex);
	}

	else Level.Game.MaplistHandler.ResetGame(GameIndex);

	bEdit = false;
	return true;
}

function bool CanEdit()
{
	return !bEdit;
}

// Settings Functions
function string GetParam(int idx)
{
	if (idx < 0 || idx >= Settings.Settings.Length)
		return "";

	return Settings.Settings[idx].Value;
}

function string GetNamedParam(string Parameter)
{
local int i;
local string SettingName;

	for (i = 0; i < Settings.Settings.Length; i++)
	{
		SettingName = Settings.Settings[i].SettingName;
		if (SettingName ~= Parameter || Right(SettingName, Len(Parameter) + 1) ~= ("."$Parameter))
			return Settings.Settings[i].Value;
	}
	return "";
}

function array<string> GetMaskedParams(string ParamMask)
{
local array<string> FoundParams;
local array<string> FoundMasks;
local string SettingName, ShortName;
local int i, j, p;

	Split(ParamMask, " ", FoundMasks);
	if (FoundMasks.Length > 0)
	{
		for (i = 0; i<Settings.Settings.Length; i++)
		{
			SettingName = Settings.Settings[i].SettingName;

			ShortName = SettingName;
			j = Instr(ShortName, ".");
			while (j != -1)
			{
				ShortName = Mid(ShortName, p+1);
				j = Instr(ShortName, ".");
			}

			for (j = 0; j<FoundMasks.Length; j++)
			{
				if (MaskedCompare(ShortName, FoundMasks[j]) || MaskedCompare(SettingName, FoundMasks[j]))
				{
					FoundParams[FoundParams.Length] = SettingName;
					FoundParams[FoundParams.Length] = Settings.Settings[i].Value;
					break;
				}
			}
		}
	}
	return FoundParams;
}

function bool SetParam(int idx, string Value)
{
	if (idx < 0 || idx >= Settings.Settings.Length)
		return false;

	return Settings.StoreSetting(idx, Value);
}

// Settings Commands Processing
function bool SetNamedParam(string Parameter, string Value)
{
local int i;
local string SettingName;

	for (i = 0; i < Settings.Settings.Length; i++)
	{
		SettingName = Settings.Settings[i].SettingName;
		if (SettingName ~= Parameter || Right(SettingName, Len(Parameter) + 1) ~= ("."$Parameter))
			return Settings.StoreSetting(i, Value);
	}
	// Parameter not found
	return false;
}

// MapList Functions
function array<string> GetLists()
{
	local array<string> Names;

	Names = Level.Game.MaplistHandler.GetMapListNames(GameIndex);
	return Names;
}

function int GetActiveList()
{
	return Level.Game.MaplistHandler.GetActiveList(GameIndex);
}

//function bool SetActiveList(int Index)
//{
//	if (Index < 0 || Index > AllMapLists.Length || !bEdit)
//		return false;
//
//	CurrentMapList = Index;
//	return true;
//}

function array<string> GetMaps()
{
	return Level.Game.MaplistHandler.GetMapList(GameIndex, CurrentMapList);
}

function array<string> AddMaps(string MapMask)
{
local array<string> FoundMasks, AddedMaps, CurrentMaps;
local int i, j, k;
local bool bFound;

	Split(MapMask, " ",FoundMasks);
	if (FoundMasks.Length > 0)
	{
		CurrentMaps = GetMaps();
		for (i = 0; i<AllMaps.Length; i++)
		{
			for (j = 0; j<FoundMasks.Length; j++)
			{
				if (MaskedCompare(AllMaps[i], FoundMasks[j]))
				{
					// Found a matching map, see if its already in the Used Maps list
					bFound = false;
					for (k = 0; k<CurrentMaps.Length; k++)
					{
						if (CurrentMaps[k] == AllMaps[i])
						{
							bFound = true;
							break;
						}
					}

					if (!bFound)
					{
						Level.Game.MaplistHandler.AddMap(GameIndex, CurrentMapList, AllMaps[i]);
						AddedMaps[AddedMaps.Length] = AllMaps[i];
						break;
					}
				}
			}
		}
	}
	return AddedMaps;
}

function array<string> RemoveMaps(string MapMask)
{
local array<string> FoundMasks, DelMaps, CurrentMaps;
local int i, j;

	Split(MapMask, " ", FoundMasks);
	if (FoundMasks.Length > 0)
	{
		CurrentMaps = GetMaps();
		for (i=0; i<CurrentMaps.Length; i++)
		{
			for (j=0; j<FoundMasks.Length; j++)
			{
				if (MaskedCompare(CurrentMaps[i], FoundMasks[j]))
				{
					DelMaps[DelMaps.Length] = CurrentMaps[i];
					Level.Game.MaplistHandler.RemoveMap(GameIndex, CurrentMapList, CurrentMaps[i]);
					i--;
					break;
				}
			}
		}
	}
	return DelMaps;
}

function array<string> FindMaps(string MapMask)
{
local array<string> FoundMasks, FoundMaps, CurrentMaps;
local int i, j, k;
local bool bFound;

	Split(MapMask, " ", FoundMasks);
	if (FoundMasks.Length > 0)
	{
		CurrentMaps = GetMaps();
		for (i = 0; i<AllMaps.Length; i++)
		{
			for (j = 0; j<FoundMasks.Length; j++)
			{
				if (MaskedCompare(AllMaps[i], FoundMasks[j]))
				{
					// Found a matching map, see if its already in the Used Maps list
					bFound = false;
					for (k = 0; k<CurrentMaps.Length; k++)
					{
						if (CurrentMaps[k] ~= AllMaps[i])
						{
//							Log("Found the map");
							bFound = true;
							break;
						}
					}

					if (bFound)
						FoundMaps[FoundMaps.Length] = "+"$AllMaps[i];
					else
						FoundMaps[FoundMaps.Length] = AllMaps[i];

					break;
				}
			}
		}
	}
	return FoundMaps;
}

// Mutator list functions
function array<string> GetUsedMutators()
{
local array<string>	Strings;
local int i;

	for (i = 0; i<UsedMutators.Length; i++)
		Strings[Strings.Length] = AllMutators[UsedMutators[i]];

	return Strings;
}

function array<string> GetUnusedMutators()
{
local array<string> Strings;
local int i;

	Strings.Length = AllMutators.Length;
	for (i = 0; i<AllMutators.Length; i++)
		Strings[i] = AllMutators[i];

	// Tag all used mutators
	for (i = 0; i<UsedMutators.Length; i++)
		Strings[UsedMutators[i]] = "";

	for (i = 0; i<Strings.Length; i++)
	{
		if (Strings[i] == "")
		{
			Strings.Remove(i, 1);
			i--;
		}
	}
	return Strings;
}

function bool AddMutator(string MutatorName)
{
local int i, j;
local string Str;

	// First make sure it isnt in the list
	for (i = 0; i<AllMutators.Length; i++)
	{
		Str = AllMutators[i];
		if (Str ~= MutatorName || Right(Str, Len(MutatorName) + 1) ~= ("."$MutatorName))
		{
			for (j=0; j<UsedMutators.Length; j++)
				if (UsedMutators[j] == i)
					return false;

			UsedMutators[UsedMutators.Length] = i;
			return true;
		}
	}
	return false;
}

function bool DelMutator(string MutatorName)
{
local int i;
local string Str;

	// First make sure it isnt in the list
	for (i = 0; i<UsedMutators.Length; i++)
	{
		Str = AllMutators[UsedMutators[i]];
		if (Str ~= MutatorName || Right(Str, Len(MutatorName) + 1) ~= ("."$MutatorName))
		{
			UsedMutators.Remove(i, 1);
			return true;
		}
	}
	return false;
}

////////////////////////////////
// Public Information
////////////////////////////////

function string GetEditedClass()
{
	if (GameClass != None)
		return String(GameClass);

	return "";
}

function string GetGameAcronym()
{
	if (GameClass != None)
		return GameClass.default.Acronym;

	return "";
}

////////////////////////////////
// Protected Helping functions
////////////////////////////////

protected function LoadGameTypes()
{
local class<GameInfo>	TempClass;
local String 			NextGame;
local int				i;

	// Compile a list of all gametypes.
	i = 0;
	NextGame = Level.GetNextInt("Engine.GameInfo", 0);
	while (NextGame != "")
	{
		TempClass = class<GameInfo>(DynamicLoadObject(NextGame, class'Class'));
		if (TempClass != None)
			AllGameTypes[AllGameTypes.Length] = TempClass;

		NextGame = Level.GetNextInt("Engine.GameInfo", ++i);
	}
}

protected function class<GameInfo> FindGameType(string GameType)
{
local class<GameInfo> TempClass;
local int i;

	TempClass = None;
	for (i=0; i<AllGameTypes.Length; i++)
	{
		TempClass = AllGameTypes[i];
		if (GameType ~= string(TempClass))				break;
		if (GameType ~= TempClass.default.Acronym)		break;
		if (GameType ~= TempClass.default.DecoTextName)	break;
		if (Right(string(TempClass), Len(GameType)+1) ~= ("."$GameType))			break;
		if (Right(TempClass.default.DecoTextName, Len(GameType)+1) ~= ("."$GameType))	break;
	}
	return TempClass;
}

protected function LoadAllMutators()
{
local string NextMutator, NextDesc;
local int	 Cnt;

	Level.GetNextIntDesc("Engine.Mutator", 0, NextMutator, NextDesc);

	Cnt = 0;
	AllMutators.Length = 0;
	while(NextMutator != "")
	{
		AllMutators[AllMutators.Length] = NextMutator;
		Cnt++;
		Level.GetNextIntDesc("Engine.Mutator", Cnt, NextMutator, NextDesc);
	}
}

protected function SetUsedMutators()
{
local Mutator M;
local int i;

	for (M = Level.Game.BaseMutator.NextMutator; M != None; M = M.NextMutator)
	{
		if (M.bUserAdded)
		{
			for (i=0; i<AllMutators.Length; i++)
				if (string(M.Class) ~= AllMutators[i])
					break;

			if (i == AllMutators.Length)
			{
				// Since this mutator had no .int entry, but it was added on the command line
				// lets just add it to the list.
				AllMutators[AllMutators.Length] = string(M.Class);
				log("Unknown Mutator in use: "@String(M.Class));
			}

			UsedMutators[UsedMutators.Length] = i;
		}
	}
}

// Always reload settings at StartEdit()
protected function string LoadSettings(class<GameInfo> GameClass)
{
	if (Settings == None)
		Settings = new(None) class'PlayInfo';

	Settings.Clear();
	GameClass.static.FillPlayInfo(Settings);
	return string(GameClass);
}

// TODO: Have a "native array<string> LoadAllMapNames(string MapPrefix)" somewhere ?
protected function LoadAllMaps(optional bool bForceLoad)
{
local string MapPrefix;

	if (GameClass == None)
		return;

	MapPrefix = GameClass.Default.MapPrefix;

	if(MapPrefix != "" && (MapPrefix != AllMapsPrefix || bForceLoad))
	{
		GameClass.static.LoadMapList(MapPrefix, AllMaps);
		AllMapsPrefix = MapPrefix;
	}
}

////////////////////////////////////////////////////////////
// TODO: Find Centralized place for the following functions
////////////////////////////////////////////////////////////

// Mask can be *|*Name|Name*|*Name*|Name
protected function bool MaskedCompare(string SettingName, string Mask)
{
local bool bMaskLeft, bMaskRight;
local int MaskLen;

	if (Mask == "*" || Mask == "**")
		return true;

	MaskLen = Len(Mask);
	bMaskLeft = Left(Mask, 1) == "*";
	bMaskRight = Right(Mask, 1) == "*";

	if (bMaskLeft && bMaskRight)
		return Instr(Caps(SettingName), Mid(Caps(Mask), 1, MaskLen-2)) >= 0;

	if (bMaskLeft)
		return Left(SettingName, MaskLen -1) ~= Left(Mask, MaskLen - 1);

	if (bMaskRight)
		return Right(SettingName, MaskLen -1) ~= Right(Mask, MaskLen - 1);

	return SettingName ~= Mask;
}

defaultproperties
{
}
