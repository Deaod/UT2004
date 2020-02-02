// ====================================================================
//  Class:  Engine.AdminBase
//  Parent: Core.Object
//
//  <Enter a description here>
// ====================================================================

class AdminBase extends Object Within PlayerController
	abstract native;

var bool bAdmin;
var AccessControl Manager;

var localized string Msg_PlayerList;
var localized string Msg_AllGameMaps;
var localized string Msg_AllMapLists;
var localized string Msg_MapRotationList;
var localized string Msg_NoMapsAdded;
var localized string Msg_AddedMapToList;
var localized string Msg_NoMapsRemoved;
var localized string Msg_RemovedFromList;
var localized string Msg_PlayerBanned;
var localized string Msg_SessionBanned;
var localized string Msg_PlayerKicked;
var localized string Msg_NextMapNotFound;
var localized string Msg_ChangingMapTo;
var localized string Msg_NoMapInRotation;
var localized string Msg_NoMapsFound;
var localized string Msg_MapIsInRotation;
var localized string Msg_MapNotInRotation;
var localized string Msg_UnknownParam;
var localized string Msg_NoParamsFound;
var localized string Msg_ParamModified;
var localized string Msg_ParamNotModified;
var localized string Msg_MapListAdded;
var localized string Msg_MapListRemoved;
var localized string Msg_MapIsNotInRotation;
var localized string Msg_EditingMapList;


function Created()
{
	if (Level.Game.AccessControl != None)
		Manager = Level.Game.AccessControl;
}

function DoLogin( string UserName, string Password );
function DoLogout();
function DoSwitch( string URL)
{
	Level.ServerTravel( URL, false );
}

function GoToNextMap()
{
	if (bAdmin)
    {
		Level.Game.bChangeLevels=true;
        Level.Game.bAlreadyChanged=false;
		Level.Game.RestartGame();
    }
}

function ShowCurrentMapList()
{
	local int i, c;
	local array<string> Ar;

	i = MapHandler.GetGameIndex(string(Level.Game.Class));
	c = MapHandler.GetActiveList(i);

	Ar = MapHandler.GetCacheMapList( Level.Game.Acronym );
	SendComplexMsg(Ar, Msg_AllGameMaps@MapHandler.GetMapListTitle(i,c));
}

function array<string> GetMapListNames(string GameType)
{
	local int i;
	local array<string> Ar;

	i = MapHandler.GetGameIndex(GameType);
	Ar = MapHandler.GetMapListNames(i);
	return Ar;
}

function MaplistCommand( string Cmd, string Extra )
{
local array<string> Values;
local string Str;
local int i, c;

	if (CanPerform("Ml"))
	{
		Cmd = Caps(Cmd);
		i = MapHandler.GetGameIndex(string(Level.Game.Class));

		switch (Cmd)
		{
		case "LIST":
			Values = MapHandler.GetMapListNames(i);
			SendComplexMsg(Values, Repl(Msg_AllMapLists, "%gametype%", string(Level.Game.Class)));
			break;

		case "USED":
			if (Extra == "")
				c = MapHandler.GetActiveList(i);
			else c = int(Extra);
			Str = MapHandler.GetMapListTitle(i, c);

			Values = MapHandler.GetMapList(i, c);
			SendComplexMsg(Values, Repl(Msg_MapRotationList, "%maplist%", Str));
			break;

		case "SWITCH":
			if (Extra == "")
				c = MapHandler.GetActiveList(i);
			else c = int(Extra);
			Str = MapHandler.GetMapListTitle(i, c);

		case "ADD":
			c = MapHandler.GetActiveList(i);
			Split(Extra, ",", Values);
			if (Values.Length == 0)
				ClientMessage( Repl(Msg_NoMapsAdded, "%maplist%", MapHandler.GetMapListTitle(i,c)) );
			else
			{
				for ( i = Values.Length - 1; i >= 0; i-- )
				{
					if ( !MapHandler.AddMap(i,c,Values[i]) )
						Values.Remove(i,1);
				}

				SendComplexMsg(Values, Msg_AddedMapToList @ MapHandler.GetMapListTitle(i, c));
			}
			break;

		case "DEL":
			c = MapHandler.GetActiveList(i);
			Split(Extra, ",", Values);
			if ( Values.Length == 0 )
				ClientMessage( Repl(Msg_NoMapsRemoved, "%maplist%", MapHandler.GetMaplistTitle(i,c)) );
			else
			{
				for ( i = Values.Length - 1; i >= 0; i-- )
				{
					if ( !MapHandler.RemoveMap(i,c,Values[i]) )
						Values.Remove(i,1);
				}

				SendComplexMsg(Values, Msg_RemovedFromList @ MapHandler.GetMapListTitle(i, c));
			}

			break;
		}
	}
}

function RestartCurrentMap()
{
	Level.ServerTravel("?restart",false);
}

// =====================================================================================================================
// =====================================================================================================================
//  Console Commands
// =====================================================================================================================
// =====================================================================================================================

exec function PlayerList()
{
	local PlayerReplicationInfo PRI;

	if ( CanPerform("Xp") )
	{
		log(Msg_PlayerList);
		ForEach DynamicActors(class'PlayerReplicationInfo', PRI)
			log(PRI.PlayerName@"( ping"@PRI.Ping$")");
	}
}

exec function Kick( string Cmd, string Extra )
{
local array<string> Params;
local array<PlayerReplicationInfo> AllPRI;
local Controller	C, NextC;
local int i;

	if (CanPerform("Kp") || CanPerform("Kb"))		// Kp = Kick Players, Kb = Kick/Ban
	{
		if (Cmd ~= "List")
		{
			// Get the list of players to kick by showing their PlayerID
			// TODO: Display Fixed Playername (no garbage chars in name)?
			// TODO: Display Sorted ?
			Level.Game.GameReplicationInfo.GetPRIArray(AllPRI);
			for (i = 0; i<AllPRI.Length; i++)
				ClientMessage(Right("   "$AllPRI[i].PlayerID, 3)$")"@AllPRI[i].PlayerName);
			return;
		}

		if (Cmd ~= "Ban" || Cmd ~= "Session")
		   Params = SplitParams(Extra);

		else if (Extra != "")
		   Params = SplitParams(Cmd@Extra);

		else
        	Params = SplitParams(Cmd);

		// go thru all Players
		for (C = Level.ControllerList; C != None; C = NextC)
		{
			NextC = C.NextController;
			// Allow to kick bots too, for now i dont
			// What about Spectators ?? hummm ...
			if (C != Owner && PlayerController(C) != None && C.PlayerReplicationInfo != None)
			{
				for (i = 0; i<Params.Length; i++)
				{
					if ((IsNumeric(Params[i]) && C.PlayerReplicationInfo.PlayerID == int(Params[i]))
							|| MaskedCompare(C.PlayerReplicationInfo.PlayerName, Params[i]))
					{
						// Kick that player
						if (Cmd ~= "Ban")
						{
							ClientMessage(Repl(Msg_PlayerBanned, "%Player%", C.PlayerReplicationInfo.PlayerName));
							Manager.BanPlayer(PlayerController(C));
						}
						else if (Cmd ~= "Session")
						{
							ClientMessage(Repl(Msg_SessionBanned, "%Player%", C.PlayerReplicationInfo.PlayerName));
							Manager.BanPlayer(PlayerController(C), true);
						}
						else
						{
							Manager.KickPlayer(PlayerController(C));
							ClientMessage(Repl(Msg_PlayerKicked, "%Player%", C.PlayerReplicationInfo.PlayerName));
						}
						break;
					}
				}
			}
		}
	}
}

exec function KickBan(string s)
{
	Kick("ban", s);
}

exec function RestartMap()
{
	RestartCurrentMap();
}

exec function NextMap()
{
	GotoNextMap();
}

exec function Map( string Cmd )
{
	if (Cmd ~= "Restart")
	{
		ConsoleCommand("RestartMap");
	}
	else if (Cmd ~= "Next")
	{
		GotoNextMap();
	}
	else if (Cmd ~= "List")
	{
		ShowCurrentMapList();
	}
	else
	{
		DoSwitch(Cmd);
	}
}

exec function Maplist( string Cmd, string Extra )
{
	MaplistCommand( Cmd, Extra );
}

exec function Switch( string URL )
{
	DoSwitch(URL);
}

// =====================================================================================================================
// =====================================================================================================================
//  Utility functions
// =====================================================================================================================
// =====================================================================================================================

protected function bool CanPerform(string priv)
{
  return Manager.CanPerform(Outer, Priv);
}

protected function string FindGameType(string GameType)
{
	local int i;
	local array<CacheManager.GameRecord> Records;

	class'CacheManager'.static.GetGameTypeList(Records);

	for ( i = 0; i < Records.Length; i++ )
	{
		if (GameType ~= Records[i].ClassName)				break;
		if (GameType ~= Records[i].GameAcronym)		break;
		if (GameType ~= Records[i].TextName)	break;
		if (Right(Records[i].ClassName, Len(GameType)+1) ~= ("."$GameType))			break;
		if (Right(Records[i].TextName, Len(GameType)+1) ~= ("."$GameType))	break;
	}

	if ( i < Records.Length )
		return Records[i].ClassName;

	return "";
}

protected function SendComplexMsg(array<string> Arr, string Title)
{
	local int 		i, Longest;
	local string 	Line, Border;
	local string	Prefix, Suffix;



	for (i = 0; i < Arr.Length; i++)
		if ( Len(Arr[i]) > Longest )
			Longest = Len(Arr[i]);

// Account for borders
	Longest += 8;
	for (Border = ""; Len(Border) < Longest; Border = Border $ "-");

	ClientMessage(Title);
	ClientMessage(Border);

	for (i = 0; i < Arr.Length; i++)
	{
		Prefix = Right("[] "$i, 4)$")";
		Suffix = " []";
		Line = Prefix $ Arr[i] $ Suffix;
		while (Len(Line) < Longest)
		{
			Suffix = " " $ Suffix;
			Line = Prefix $ Arr[i] $ Suffix;
		}
		ClientMessage(Line);
	}
	ClientMessage(Border);
}

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

// TODO: Add support for bPositiveOnly
function bool IsNumeric(string Param, optional bool bPositiveOnly)
{
local int p;

	p=0;
	while (Mid(Param, p, 1) == " ") p++;
	while (Mid(Param, p, 1) >= "0" && Mid(Param, p, 1) <= "9") p++;
	while (Mid(Param, p, 1) == " ") p++;

	if (Mid(Param, p) != "")
		return false;

	return true;
}

function array<string> SplitParams(string Params)
{
local array<string> Splitted;
local string Delim;
local int p, start;

	while (Params != "")
	{
		p = 0;
		while (Mid(Params, p, 1) == " ") p++;
		if (Mid(Params, p) == "")
			break;

		// Special case: Delimited string
		start = p;
		if (Mid(Params, p, 1) == "\"")
		{
			p++;
			start++;
			while (Mid(Params, p, 1) != "" && Mid(Params, p, 1) != "\"")
				p++;

			// Do not accept unfinished quoted strings
			if (Mid(Params, p, 1) == "\"")
			{
				Splitted[Splitted.Length] = Mid(Params, start, p-start);
				p++;
			}
		}
		else
		{
			while (Mid(Params, p, 1) != "" && Mid(Params, p, 1) != Delim)
				p++;
			Splitted[Splitted.Length] = Mid(Params, start, p-start);
		}
		Params = Mid(Params, p);
	}
	return Splitted;
}

defaultproperties
{
     Msg_PlayerList="Player List:"
     Msg_AllGameMaps="Maps that are valid (can be added) to"
     Msg_AllMapLists="Available maplists for %gametype%."
     Msg_MapRotationList="Active maps for maplist %maplist%."
     Msg_NoMapsAdded="No maps added to the maplist %maplist%."
     Msg_AddedMapToList="Maps successfully added to maplist"
     Msg_NoMapsRemoved="No maps were removed from the maplist %maplist%."
     Msg_RemovedFromList="Maps successfully removed from maplist"
     Msg_PlayerBanned="%Player% has been banned from this server"
     Msg_SessionBanned="%Player% has been banned for this match"
     Msg_PlayerKicked="%Player% has been kicked"
     Msg_NextMapNotFound="Next map not found; Restarting same map"
     Msg_ChangingMapTo="Changing Map to %NextMap%"
     Msg_NoMapInRotation="No maps configured for %maplist%."
     Msg_NoMapsFound="No matching maps in maplist %maplist% were found."
     Msg_MapIsInRotation="Matching %maplist% maps"
     Msg_MapNotInRotation="Matching maps which are not members of %maplist%."
     Msg_UnknownParam="Unknown Parameter : %Value%"
     Msg_NoParamsFound="No Parameters found!"
     Msg_ParamModified="Modification Successful"
     Msg_ParamNotModified="Could not Modify Parameter"
     Msg_MapListAdded="Maplist %listname% successfully added for gametype"
     Msg_MapListRemoved="Maplist %listname% successfully removed from gametype"
     Msg_EditingMapList="Now editing maplist"
}
