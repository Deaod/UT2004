//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MaplistManagerBase extends Info
	abstract
	notplaceable
	native;

function bool ValidGameType(string GameType)
{
	return false;
}

function bool ValidName(string S)
{
	return false;
}

function bool ValidCacheGameIndex(int i)
{
	return false;
}

function bool ValidGameIndex(int i)
{
	return false;
}

function int AddList(string GameType, string NewName, array<string> Maps)
{
	return -1;
}

function int RemoveList(int GameIndex, int RecordIndex)
{
	return -1;
}

function ResetGame(int GameIndex);
function ResetList(int GameIndex, int RecordIndex);
function int RenameList(int GameIndex, int RecordIndex, string NewName)
{
	return -1;
}

function bool ClearList(int GameIndex, int RecordIndex)
{
	return true;
}

function bool AddMap(int GameIndex, int RecordIndex, string MapName)
{
	return false;
}

function bool RemoveMap(int GameIndex, int MapIndex, string MapName)
{
	return false;
}

function int GetGameIndex(coerce string GameType)
{
	return -1;
}

function int GetMapIndex(int GameIndex, int RecordIndex, string MapName)
{
	return -1;
}

function int GetRecordIndex(int GameIndex, string MapListName)
{
	return -1;
}

function string GetMapListTitle(int GameIndex, int RecordIndex)
{
	return "";
}

function array<string> GetMapListNames(int GameIndex);
function array<string> GetCurrentMapRotation();
function array<string> GetMapList(int GameIndex, int RecordIndex);
function int GetActiveList(int GameIndex)
{
	return -1;
}

function bool SetActiveList(int GameIndex, int NewActive)
{
	return true;
}

function int GetActiveMap(int GameIndex, int RecordIndex)
{
	return -1;
}

function bool ApplyMapList(int GameIndex, int RecordIndex)
{
	return false;
}

function MapChange(string NewMapName);

// Apply or cancel changes - used only by GameConfigSet
function bool SaveGame(int GameIndex)
{
	return True;
}

// Save a maplist
function bool SaveMapList(int GameIndex, int RecordIndex)
{
	return true;
}

// Adapted from xWebAdmin.StringArray
function ShiftMap(int GameIndex, int RecordIndex, string MapName, int Count);
function int FindCacheGameIndex(coerce string GameType)
{
	return -1;
}

function array<string> GetCacheMapList(string Acronym);

defaultproperties
{
}
