// ====================================================================
//  Class:  xVoting.DefaultMapListLoader
//
//	The DefaultMapListLoader is used by the VotingHandler to
//  load the list of map names.
//
//  Written by Bruce Bickar
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class DefaultMapListLoader extends MapListLoader;

var() config bool bUseMapList;
var() config array<string> MapListTypeList;
var() config string MapNamePrefixes;

var localized string UseMapListPropsDisplayText;
var localized string UserMapListPropDescription;

//------------------------------------------------------------------------------------------------
function LoadMapList(xVotingHandler VotingHandler)
{
	local int p, i;
	local array<string> PrefixList;
	local class<GameInfo> GameClass;

	if(bUseMapList)
	{
		log("Loading Maps from the following MapLists",'MapVote');
		if(MapListTypeList.Length == 0)
		{
			// Use default MapLists from each of MapVotes GameConfig settings
			for(i=0; i < VotingHandler.GameConfig.Length; i++)
			{
				GameClass = class<GameInfo>(DynamicLoadObject(VotingHandler.GameConfig[i].GameClass, class'Class'));
				if(GameClass != none)
				{
					log(GameClass.default.MapListType,'MapVote');
					LoadFromMapList(GameClass.default.MapListType, VotingHandler);
				}
			}
		}
		else
		{
			// Use the listed MapList classes
			for(i=0; i<MapListTypeList.Length; i++)
			{
				log(MapListTypeList[i],'MapVote');
				LoadFromMapList(MapListTypeList[i], VotingHandler);
			}
		}
	}
	else
	{
		log("Loading Maps from Maps dir. " $ MapNamePrefixes,'MapVote');

		// Use the MapNamePrefixes to load all maps in maps directory
		if( MapNamePrefixes == "" ) // get map prefixes from GameConfig
		{
			for(i=0; i < VotingHandler.GameConfig.Length; i++)
			{
				MapNamePrefixes $= VotingHandler.GameConfig[i].Prefix;
				if( i < VotingHandler.GameConfig.Length - 1 )
					MapNamePrefixes $= ",";
			}
		}

		PrefixList.Length = 0;
		p = Split(MapNamePrefixes, ",", PrefixList);
		if(p > 0)
		{
			for(i=0; i < PrefixList.Length; i++)
				LoadFromPrefix(PrefixList[i],VotingHandler);
		}
	}
}
//------------------------------------------------------------------------------------------------
function LoadFromPreFix(string Prefix, xVotingHandler VotingHandler)
{
   local string FirstMap,NextMap,MapName,TestMap;
   local int z;

   FirstMap = Level.GetMapName(PreFix, "", 0);
   NextMap = FirstMap;
   while(!(FirstMap ~= TestMap))
   {
      MapName = NextMap;
      z = InStr(Caps(MapName), ".UT2");
      if(z != -1)
         MapName = Left(MapName, z);  // remove ".UT2"

      VotingHandler.AddMap(MapName, "", "");

      NextMap = Level.GetMapName(PreFix, NextMap, 1);
      TestMap = NextMap;
   }
}
//------------------------------------------------------------------------------------------------
function LoadFromMapList(string MapListType, xVotingHandler VotingHandler)
{
   local string Mutators,GameOptions;
   local class<MapList> MapListClass;
   local string MapName;
   local array<string> Parts;
   local array<string> Maps;
   local int z,x,p,i;

   MapListClass = class<MapList>(DynamicLoadObject(MapListType, class'Class'));
   if(MapListClass == none)
   {
      Log("___Couldn't load maplist type:"$MaplistType,'MapVote');
      return;
   }

   Maps = MapListClass.static.StaticGetMaps();
   for(i=0;i<Maps.Length;i++)
   {
      Mutators = "";
      GameOptions = "";

      MapName = Maps[i];

      // Parse map string incase there are mutator and game options in it
      // DOM-Aztec?Game=XGame.xDoubleDom?mutator=XGame.MutVampire,UTSecure.MutUTSecure?WeaponStay=True?Translocator=True?TimeLimit=15
      // p0       | p1                  | p2                                          | p3            | p4              | p5
      Parts.Length = 0;
      p = Split(MapName, "?", Parts);
      if(p > 1)
      {
         MapName = Parts[0];
         for(x=1;x<Parts.Length;x++)
         {
            if(left(Parts[x],8) ~= "mutator=")
            {
               Mutators = Mid(Parts[x],8);
            }
            else
            {
               // ignore the "game" option but add all others to GameOptions
               if(!(left(Parts[x],5) ~= "Game="))
               {
                  if(GameOptions == "")
                     GameOptions = Parts[x];
                  else
                     GameOptions = GameOptions $ "?" $ Parts[x];
               }
            }
         }
      }

      z = InStr(Caps(MapName), ".UT2");
      if(z != -1)
         MapName = Left(MapName, z);  // remove ".UT2"

      VotingHandler.AddMap(MapName, Mutators, GameOptions);
   }
}
//================================================================================================
//                                    Configuration
//================================================================================================
static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting(default.MapVoteGroup,"bUseMapList",default.UseMapListPropsDisplayText,0,1,"Check",,,True,True);
}
//------------------------------------------------------------------------------------------------
static event bool AcceptPlayInfoProperty(string PropertyName)
{
	if ( class'LevelInfo'.static.IsDemoBuild() )
		return false;

	switch ( PropertyName )
	{
		case "bUserMapList":
			return true;
	}
	return Super.AcceptPlayInfoProperty(PropertyName);
}
//------------------------------------------------------------------------------------------------
static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "bUseMapList":
			return default.UserMapListPropDescription;
	}
	return "";
}
//------------------------------------------------------------------------------------------------

defaultproperties
{
     UseMapListPropsDisplayText="Use MapLists"
     UserMapListPropDescription="If enabled, the map lists are used instead of showing all map names."
}
