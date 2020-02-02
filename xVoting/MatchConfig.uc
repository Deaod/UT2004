// ====================================================================
//  Class:  xVoting.MatchConfig
//
//  MatchConfig is used to store/save the default server configuration
//  settings. When the Match is over this is used to restore the original
//  server settings.
//
//  Written by Bruce Bickar (Uses some code from Ron Prestenback's Ladder mod)
//  (c) 2003 Epic Games, Inc.  All Rights Reserved
// ====================================================================
class MatchConfig extends Object
	Config(MatchConfig)
	PerObjectConfig;

// used to save configuration settings from PlayInfo
struct ProfileSetting
{
	var string SettingName;
	var string SettingValue;
};

// config
var config array<ProfileSetting> Settings;
var config string DefaultGameClassString;
var config string DefaultMutatorsString;
var config string DefaultParameters;
var config bool   DefaultTournamentMode;
var config string DefaultDemoRecFileName;

var string GameClassString;
var string MapIndexList;
var string MutatorIndexList;
var string Parameters;
var bool bTournamentMode;
var string DemoRecFileName;

var MaplistManager MapHandler;
var PlayInfo PInfo;
var LevelInfo Level;
var array<CacheManager.GameRecord> GameTypes;
var array<CacheManager.MapRecord> Maps;
var array<CacheManager.MutatorRecord> Mutators;

var transient int GameIndex, RecordIndex;

// Localization
var localized string lmsgLoadingMatchProfile, lmsgRestoringDefaultProfile, lmsgDefaultNotAvailable;
//------------------------------------------------------------------------------------------------
function Init(LevelInfo Lv)
{
	if (Lv==None)
		return;

	Level = Lv;
	PInfo = new(None) class'Engine.PlayInfo';
	MapHandler = MaplistManager(Level.Game.MaplistHandler);

	class'CacheManager'.static.GetGameTypeList(GameTypes);
	class'CacheManager'.static.GetMutatorList(Mutators);

	LoadDefaults();
}

function LoadDefaults()
{
	// hack for defaults
	SetGameClassString(DefaultGameClassString);
	Parameters = DefaultParameters;
	bTournamentMode = DefaultTournamentMode;
	DemoRecFileName = DefaultDemoRecFileName;

	LoadDefaultMutators();
	LoadDefaultMaps();
}

function LoadDefaultMutators()
{
	local array<string> Classes;
	local int i, idx;

	MutatorIndexList = "";

	if ( Mutators.Length == 0 )
		class'CacheManager'.static.GetMutatorList(Mutators);

	Split(DefaultMutatorsString, ",", Classes);
	for ( i = 0; i < Classes.Length; i++ )
	{
		idx = GetMutatorCacheIndex(Classes[i]);
		if ( idx != -1 )
		{
			if ( MutatorIndexList != "" )
				MutatorIndexList $= ",";

			MutatorIndexList $= idx;
		}
	}
}

function LoadCurrentMutators()
{
	local int idx;
	local Mutator M;

	MutatorIndexList = "";

	if ( Mutators.Length == 0 )
		class'CacheManager'.static.GetMutatorList(Mutators);

	for(M = Level.Game.BaseMutator.NextMutator; M != None; M = M.NextMutator)
	{
		idx = GetMutatorCacheIndex(M.Class);
		if ( idx != -1 )
		{
			if ( MutatorIndexList != "" )
				MutatorIndexList $= ",";

			MutatorIndexList $= idx;
		}
	}
}

function LoadDefaultMaps()
{
	local int i, MapIndex;
	local array<string> MapArr;

	MapIndexList = "";
	UpdateRecordIndex();
	if ( RecordIndex != -1 )
	{
		MapArr = MapHandler.GetMapList( GameIndex, RecordIndex );
		for ( i = 0; i < MapArr.Length; i++ )
		{
			MapIndex = GetMapCacheIndex(MapArr[i]);
			if ( MapIndex != -1 )
			{
				if ( MapIndexList != "" )
					MapIndexList $= ",";

				MapIndexList $= MapIndex;
			}
		}
	}
}

function SetGameClassString( string NewString )
{
	local int idx;

	if ( NewString == "" )
		return;

	idx = MapHandler.GetGameIndex(NewString);
	if ( idx != -1 )
	{
		GameClassString = NewString;
		GameIndex = idx;
		UpdateRecordIndex();
	}
}

//------------------------------------------------------------------------------------------------
function LoadCurrentSettings()
{
	local array<string> ParamArray;
	local string URL,LeftPart,RightPart;
	local int x;

	SetGameClassString(string(Level.Game.Class));

	LoadCurrentMutators();
	URL = Caps(Level.GetLocalURL());
	//Log("URL = " $ URL, 'MapVoteDebug');
	// 0.0.0.0/DM-Morpheus3?Name=BDB?Class=Engine.Pawn?Character=Ophelia?team=255?Game=XGame.xDeathMatch?
	// ADMINNAME=BDB?ADMINPASSWORD=XXXX?mutator=?TOURNAMENT=1
	Split(URL, "?", ParamArray);
	Parameters="";
	for( x=1; x<ParamArray.Length; x++)
	{
		if ( !Divide(ParamArray[x],"=",LeftPart,RightPart) )
			LeftPart = ParamArray[x];

		if ( LeftPart ~= "Tournament" )
			bTournamentMode = bool(RightPart);

		else if ( LeftPart ~= "DemoRec" )
			DemoRecFileName = RightPart;

		else if ( IncludeParam(LeftPart) )
		{
			if ( Parameters != "" )
				Parameters $= ";";

			Parameters $= ParamArray[x];
		}
	}

	LoadPlayInfo();
	LoadMapList();
}

function bool IncludeParam( string ParamName )
{
	switch ( Caps(ParamName) )
	{
	case "NAME":
	case "CHARACTER":
	case "TEAM":
	case "GAME":
	case "ADMINNAME":
	case "ADMINPASSWORD":
	case "MUTATOR":
	case "CLASS":
	case "TOURNAMENT":
	case "NUMBOTS":
	case "BAUTONUMBOTS":
	case "DEMOREC":
		return false;
	}

	return true;
}

//------------------------------------------------------------------------------------------------
function LoadPlayInfo()  // copied from UT2K4MultiPlayerHostPage and modified
{
	local int i,j;
	local class<GameInfo>	GameClass;
	local class<AccessControl> ACClass;
	local array<class<Info> >	PIClasses;
	local class<Mutator> MutClass;
	local array<string> MutClassNames;

	PInfo.Clear();
	GameClass = class<GameInfo>(DynamicLoadObject( GameClassString, class'Class'));
	if(GameClass != None)
	{
		PIClasses[i++] = GameClass;
		ACClass = class<AccessControl>(DynamicLoadObject(GameClass.default.AccessControlClass, class'Class'));
		if (ACClass != None)
			PIClasses[i++] = ACClass;

		MutClassNames = GetCurrentMutatorArray();
		MutClassNames.Insert(0,1);
		MutClassNames[0] = GameClass.default.MutatorClass;

		for (j = 0; j < MutClassNames.Length; j++)
		{
			if ( MutClassNames[j] != "" )
				MutClass = class<Mutator>(DynamicLoadObject(MutClassNames[j], class'Class'));

			if (MutClass != None)
				PIClasses[i++] = MutClass;
		}

		PInfo.Init(PIClasses);
	}
}
//------------------------------------------------------------------------------------------------
function LoadMapList()
{
	local int i, MapIndex;
	local array<string> MapArr;

	MapIndexList = "";
	UpdateRecordIndex();

	if ( RecordIndex != -1 )
	{
		MapArr = MapHandler.GetMapList( GameIndex, RecordIndex );

		for ( i = 0; i < MapArr.Length; i++ )
		{
			MapIndex = GetMapCacheIndex(MapArr[i]);
			if ( MapIndexList != "" )
				MapIndexList $= ",";

			MapIndexList $= MapIndex;
		}
	}
}
//------------------------------------------------------------------------------------------------
function bool ChangeSetting(string SettingName, string NewValue)
{
	local xVotingHandler VH;
	local int i;
	local bool bFound;

	log("____ChangeSetting(" $ SettingName $ ", " $ NewValue $ ")",'MapVoteDebug');

	VH = xVotingHandler(Level.Game.VotingHandler);

	switch( SettingName )
	{
		case class'VotingReplicationInfo'.default.GameTypeID:
			if( !(NewValue ~= GameClassString) )
			{
				// validate new GameType
				bFound = false;
				for (i = 0; i < GameTypes.Length; i++)
				{
					if( GameTypes[i].ClassName ~= NewValue )
					{
						bFound = true;
						break;
					}
				}
				if( !bFound )
					return false;

				SetGameClassString(NewValue);

				// Reload all since gametype changed
				ReLoad(true);
				VH.ReloadMatchConfig(true,false);
			}
			return true;

		case class'VotingReplicationInfo'.default.MapID:
			MapIndexList = NewValue;
			return true;

		case class'VotingReplicationInfo'.default.MutatorID:
			if( MutatorIndexList != NewValue )
			{
				MutatorIndexList = NewValue;

				// Reload to pick up any new mutator settings
				ReLoad(false);
				VH.ReloadMatchConfig(false,false);
			}
			return true;

		case class'VotingReplicationInfo'.default.OptionID:
			Parameters = NewValue;
			return true;

		case class'VotingReplicationInfo'.default.TournamentID:
			bTournamentMode = bool(NewValue);
			return true;

		case class'VotingReplicationInfo'.default.DemoRecID:
			DemoRecFileName = NewValue;
			return true;

		default:
			i = PInfo.FindIndex(SettingName);
			if( i > -1 )
			{
				PInfo.StoreSetting(i, NewValue);
				return true;
			}
	}

	return false;
}
//------------------------------------------------------------------------------------------------
function ReLoad(bool bReloadMapList) // call when GameClassString has been changed.
{
	LoadPlayInfo();
	if( bReloadMapList )
		LoadMapList();
}
//------------------------------------------------------------------------------------------------
function SaveDefault()
{
	local int i;

	Log("Saving Default settings to MatchConfig.ini - [" $ Name $ "]");

    DefaultGameClassString = GameClassString;
    DefaultMutatorsString = ConvertMutatorIndexes();
	DefaultParameters = Parameters;
	DefaultTournamentMode = bTournamentMode;
	DefaultDemoRecFileName = DemoRecFileName;
//	log("DefaultMapNameList = " $ DefaultMapNameList, 'MapVoteDebug');

	// copy all the PlayInfo setting to the Config Settings array
	// so that they can be saved to the ini file.
	Settings.Length = PInfo.Settings.Length;
	for(i = 0; i < PInfo.Settings.Length; i++)
	{
		if(ArrayProperty(PInfo.Settings[i].ThisProp) == None)
		{
			Settings[i].SettingName = PInfo.Settings[i].SettingName;
			Settings[i].SettingValue = PInfo.Settings[i].Value;
		}
	}

	SaveMaplist();
	SaveConfig();
}
//------------------------------------------------------------------------------------------------
function RestoreDefault(Actor Requestor)
{
	local int i,j;
	local xVotingHandler VH;

	log("___RestoreDefault()", 'MapVoteDebug');

	if( PlayerController(Requestor) == none )
		return;

	LoadDefaults();

	log("MapIndexList = " $ MapIndexList, 'MapVoteDebug');
	if( GameClassString == "" || MapIndexList == "" )
	{
		PlayerController(Requestor).ClientMessage(lmsgDefaultNotAvailable);
		return;
	}

	LoadPlayInfo();
	for(i = 0; i < Settings.Length; i++)
	{
		for(j = 0; j < PInfo.Settings.Length; j++)
		{
			if(ArrayProperty(PInfo.Settings[i].ThisProp) == None)
			{
				if(Settings[i].SettingName ~= PInfo.Settings[j].SettingName)
				{
					PInfo.StoreSetting(j, Settings[i].SettingValue);
					break;
				}
			}
		}
	}
	//PInfo.SaveSettings();
	Level.Game.Broadcast(Level.Game.VotingHandler,lmsgRestoringDefaultProfile);

	// force all match setup users to reload settings
	VH = xVotingHandler(Level.Game.VotingHandler);
	if ( VH != None )
		VH.ReloadMatchConfig(true,true);
}
//------------------------------------------------------------------------------------------------
function StartMatch()
{
	local string ServerTravelString, mutstring;
	local class<GameInfo> GameClass;
	local int i;

	SaveDefault();

	PInfo.SaveSettings();
	Level.Game.Broadcast(Level.Game.VotingHandler,lmsgLoadingMatchProfile);
	xVotingHandler(Level.Game.VotingHandler).CloseAllVoteWindows();

	mutstring = ConvertMutatorIndexes();
	if ( mutstring != "" )
		mutstring = "?mutator=" $ mutstring;

	ServerTravelString = MapHandler.GetActiveMapName(GameIndex,RecordIndex) $ "?Game=" $ GameClassString $ mutstring;
	ServerTravelString $= "?" $ Eval(bTournamentMode, "TOURNAMENT=1", "TOURNAMENT=0");
	if( DemoRecFileName != "" )
		ServerTravelString $= "?DemoRec=" $ DemoRecFileName;
	if( Parameters != "" )
		ServerTravelString $= "?" $ Repl(Repl(Parameters,",","?")," ","");

    // Append bot options
	// Note: this doesn't work anymore because bot options were disabled on servers. :(
    switch (class'UnrealMPGameInfo'.default.BotMode)
    {
        case 0:
        	i = PInfo.FindIndex("MinPlayers");
        	if ( i >= 0 )
        		ServerTravelString $= "?NumBots="$PInfo.Settings[i].Value;
        	break;

        case 1:
			ServerTravelString $= "?bAutoNumBots=True";
			break;

        case 2:
			if( GameClass.default.bTeamGame )
			{
				if( class'XGame.TeamRedConfigured'.default.Characters.Length > 0 )
					ServerTravelString $= "?RedTeam=XGame.TeamRedConfigured";

				if( class'XGame.TeamBlueConfigured'.default.Characters.Length > 0 )
					ServerTravelString $= "?BlueTeam=XGame.TeamBlueConfigured";
			}
			else
			{
				if( class'XGame.DMRosterConfigured'.default.Characters.Length > 0 )
					ServerTravelString $= "?DMTeam=XGame.DMRosterConfigured";
			}
        	break;
    }
	Level.ServerTravel(ServerTravelString, false);    // change the map
}

function SaveMaplist()
{
	local int i;
	local array<string> OldMaps, NewMaps;

	if ( MapHandler != None )
	{
		OldMaps = MapHandler.GetMapList(GameIndex, RecordIndex);
		NewMaps = GetCurrentMapArray();

		for ( i = 0; i < OldMaps.Length; i++ )
			MapHandler.RemoveMap(GameIndex, RecordIndex, OldMaps[i]);

		for ( i = 0; i < NewMaps.Length; i++ )
			MapHandler.AddMap(GameIndex, RecordIndex, NewMaps[i]);

		MapHandler.ApplyMapList(GameIndex, RecordIndex);
	}
}

//------------------------------------------------------------------------------------------------

function UpdateRecordIndex()
{
	local array<string> Dummy;

	if ( Level == None || Level.Game == None || MapHandler == None )
		return;

	if ( GameIndex != -1 )
	{
		RecordIndex = MapHandler.GetRecordIndex(GameIndex, string(Name));
		if ( RecordIndex == -1 )
			RecordIndex = MapHandler.AddList(GameClassString, string(Name), Dummy);
	}
}

function int GetGameCacheIndex( coerce string ClassName )
{
	local int i;

	if ( ClassName == "" )
		return -1;

	if ( GameTypes.Length == 0 )
		class'CacheManager'.static.GetGameTypeList(GameTypes);

	for ( i = 0; i < GameTypes.Length; i++ )
	{
		if ( GameTypes[i].ClassName ~= ClassName )
			return i;
	}

	log(Name@"GetGameCacheIndex() didn't find index for game class '"$ClassName$"'",'MapVoteDebug');
	return -1;
}

function int GetMutatorCacheIndex( coerce string ClassName )
{
	local int i;

	if ( ClassName == "" )
		return -1;

	if ( Mutators.Length == 0 )
		class'CacheManager'.static.GetMutatorList(Mutators);

	for ( i = 0; i < Mutators.Length; i++ )
	{
		if ( Mutators[i].ClassName ~= ClassName )
			return i;
	}

	log(Name@"GetMutatorCacheIndex() didn't find index for mutator class '"$ClassName$"'",'MapVoteDebug');
	return -1;
}

function int GetMapCacheIndex(string MapName)
{
	local int i;

	if ( MapName == "" )
		return -1;

	if ( Maps.Length == 0 )
		class'CacheManager'.static.GetMaplist( Maps, GetPrefix() );

	i = InStr(MapName, "?");
	if ( i != -1 )
		MapName = Left(MapName,i);

	for ( i = 0; i < Maps.Length; i++ )
	{
		if ( MapName ~= Maps[i].MapName )
			return i;
	}

	log(Name@"GetMapCacheIndex() didn't find index for map '"$MapName$"'",'MapVoteDebug');
	return -1;
}

function string GetPrefix()
{
	local int i;

	if ( GameClassString == "" )
		SetGameClassString(string(Level.Game.Class));

	i = GetGameCacheIndex(GameClassString);
	if ( i != -1 )
		return GameTypes[i].MapPrefix;

	return "";
}

function array<string> GetCurrentMutatorArray()
{
	local string s;
	local array<string> Arr;

	s = ConvertMutatorIndexes();
	Split(s, ",", Arr);
	return Arr;
}

function array<string> GetCurrentMapArray()
{
	local string s;
	local array<string> Arr;

	s = ConvertMapIndexes();
	Split(s, ",", Arr);
	return Arr;
}

function string ConvertMutatorIndexes()
{
	local int i, idx;
	local string str;
	local array<string> Indexes;

	Split(MutatorIndexList, ",", Indexes);
	for ( i = 0; i < Indexes.Length; i++ )
	{
		idx = int(Indexes[i]);
		if ( idx >= 0 && idx < Mutators.Length )
		{
			if ( str != "" )
				str $= ",";

			str $= Mutators[idx].ClassName;
		}
	}

	return str;
}

// translate the comma separated string of map indexes into a comma separated string of mapnames for storing
function string ConvertMapIndexes()
{
	local int i, idx;
	local string str;
	local array<string> Indexes;

	Split(MapIndexList, ",", Indexes);
	for ( i = 0; i < Indexes.Length; i++ )
	{
		idx = int(Indexes[i]);
		if ( idx >= 0 && idx < Maps.Length )
		{
			if ( str != "" )
				str $= ",";

			str $= Maps[idx].MapName;
		}
	}

	return str;
}

defaultproperties
{
     lmsgLoadingMatchProfile="Match settings are being loaded now."
     lmsgRestoringDefaultProfile="Restoring default server profile."
     lmsgDefaultNotAvailable="Default Profile Not available."
}
