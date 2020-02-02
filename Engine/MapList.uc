//=============================================================================
// MapList.
//
// contains a list of maps to cycle through
//
//=============================================================================
class MapList extends Info
	abstract;

var array<CacheManager.MapRecord> CachedMaps;
var(Maps) protected config array<string> Maps;
var protected config int MapNum;

// When Spawned, removed any list entry that are empty
event PreBeginPlay()
{
	Super.PreBeginPlay();

	class'CacheManager'.static.GetMapList( CachedMaps );
	if ( HasInvalidMaps() )
	{
		MapNum=0;
		SaveConfig();
		Log("MapList had invalid entries!");
	}
}

event PostBeginPlay()
{
	if ( Maps.Length == 0 )
		Warn(Name@"has no maps configured!");

	Super.PostBeginPlay();
}

/*
function GetAllMaps(out string s) // sjs
{
    local int i;

    s = "";
    for( i=0; i<Maps.Length; i++ )
    {
        if( Maps[i] ~= "Entry" )
            continue;
        if( Maps[i] == "" )
            continue;
        if ( s != "" )
        	s $= ",";
        s $= Maps[i];
    }
}
*/
function string GetNextMap()
{
	local MaplistRecord.MapItem Item;
	local array<MaplistRecord.MapItem> ArItem;
	local string CurrentMap;
	local int i;

	CurrentMap = GetURLMap(true);
	if ( CurrentMap == "" )
		i = MapNum;
	else
	{
		// first, try the easy way
		for ( i = 0; i < Maps.Length; i++ )
			if ( CurrentMap ~= Maps[i] )
				break;

		if ( i == Maps.Length )
		{
			// Next check entries that would be the same except for options that have been reversed
			class'MaplistRecord'.static.CreateMapItem( CurrentMap, Item );
			class'MaplistRecord'.static.CreateMapItemList(Maps, ArItem);

			for ( i=0; i<ArItem.Length; i++ )
				if ( class'MaplistRecord'.static.CompareItems(Item,ArItem[i]) )
					break;

			if ( i == ArItem.Length )
			{
//				log("No maplist entries could be found that matched current command line '"$CurrentMap$"' (strict search).  Attempting loose search...",'MaplistManager');

				// Next attempt a really slow comparison
				for ( i = 0; i < ArItem.Length; i++ )
					if ( class'MaplistRecord'.static.CompareItemsSlow(Item,ArItem[i]) )
					{
//						log("Found probable match (loose search): '"$ArItem[i].FullURL$"'",'MaplistManager');
						break;
					}

				// TODO - write a 'find best match' algo
				if ( i == ArItem.Length )
				{
//					log("No maplist entries found matching the current command line (loose search).  Attempting mapname search...",'MaplistManager');

					// Now just attempt to find map names that match
					for ( i = 0; i < ArItem.Length; i++ )
						if ( Item.MapName ~= ArItem[i].MapName )
						{
//							log("Found possible match (mapname search): '"$ArItem[i].FullURL$"'",'MaplistManager');
							break;
						}


					// If no matches were found, prevent the maplist from always looping back the first map
					if ( i == ArItem.Length )
					{
						log("No maplist entries found matching the current command line (mapname search).  Performing blind switch to index "$MapNum + 1@"of current maplist",'MaplistManager');
						return UpdateMapNum(MapNum + 1);
					}
				}
			}
		}
	}

	// search vs. w/ or w/out .unr extension
	return UpdateMapNum(i + 1);
}

function string UpdateMapNum(int NewMapNum)
{
	if ( Maps.Length == 0 )
	{
		Warn("No maps configured for game maplist! Unable to change maps!");
		return "";
	}

	while (true)
	{
		if ( NewMapNum < 0 || NewMapNum >= Maps.Length )
			NewMapNum = 0;

		if ( NewMapNum == MapNum || MapNum < 0 || MapNum >= Maps.Length )
			break;

		if ( FindCacheIndex( Maps[NewMapNum] ) != -1 )
			break;

		NewMapNum++;
	}

	MapNum = NewMapNum;

	// Notify MaplistHandler of the change in current map
	if ( Level.Game.MaplistHandler != None )
		Level.Game.MaplistHandler.MapChange(Maps[MapNum]);

	SaveConfig();
	return Maps[MapNum];
}

function int FindCacheIndex(string MapName)
{
	local int i;
	local string Tmp;

	Tmp = class'MaplistRecord'.static.GetBaseMapName(MapName);
	for ( i = 0; i < CachedMaps.Length; i++ )
		if ( CachedMaps[i].MapName ~= Tmp )
			return i;

	return -1;
}

function string GetMap( int MapIndex )
{
	if ( MapIndex < 0 || MapIndex >= Maps.Length )
		return "";

	return Maps[MapIndex];
}

function array<string> GetMaps()
{
	if ( HasInvalidMaps() )
	{
		MapNum = 0;
		SaveConfig();
	}

	return Maps;
}

static function array<string> StaticGetMaps()
{
	if ( StaticHasInvalidMaps() )
	{
		default.MapNum = 0;
		StaticSaveConfig();
	}

	return default.Maps;

}

function bool HasInvalidMaps(optional bool bReadOnly)
{
	local int i;
	local bool bInvalid;

	for ( i = Maps.Length - 1; i >= 0; i-- )
	{
		if ( Maps[i] == "" )
		{
			bInvalid = True;
			if ( !bReadOnly )
				Maps.Remove(i,1);
		}

		else if ( FindCacheIndex(Maps[i]) == -1 )
		{
			bInvalid = True;
			if ( !bReadOnly )
				Maps.Remove(i,1);
		}
	}

	return bInvalid;
}

static function bool StaticHasInvalidMaps(optional bool bReadOnly)
{
	local int i, j;
	local bool bInvalid;
	local array<CacheManager.MapRecord> Recs;
	local string URL, MapName;

	class'CacheManager'.static.GetMapList(Recs);

	for ( i = default.Maps.Length - 1; i >= 0; i-- )
	{
		if ( default.Maps[i] == "" )
		{
			bInvalid = True;
			if ( !bReadOnly )
				default.Maps.Remove(i,1);
		}

		else
		{
			URL = default.Maps[i];
			MapName = class'MaplistRecord'.static.GetBaseMapName(URL);
			for ( j = 0; j < Recs.Length; j++ )
				if ( Recs[j].MapName ~= MapName )
					break;

			if ( j == Recs.Length )
			{
				bInvalid = True;
				if ( !bReadOnly )
					default.Maps.Remove(i,1);
			}
		}
	}

	return bInvalid;
}

static function bool SetMaplist( int CurrentNum, array<string> NewMaps )
{
	if ( CurrentNum >= NewMaps.Length )
		CurrentNum = 0;

	default.MapNum = CurrentNum;
	default.Maps   = NewMaps;

	StaticSaveConfig();
	return True;
}

defaultproperties
{
}
