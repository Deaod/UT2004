// ====================================================================
//  Class:  XAdmin.AdminIni
//  Parent: Engine.Admin
//
//  TODO: Implement <cmd> help for inline help text ?
// ====================================================================

class AdminIni extends AdminBase;

var AccessControlIni    xManager;
var xAdminUser			AdminUser;
var GameConfigSet		ConfigSet;

var protected string	NextMutators;
var protected string	NextGameType;

// Localization
var localized string Msg_FinishGameEditFirst;
var localized string Msg_FinishGameRestart;
var localized string Msg_MutNeedGameEdit;
var localized string Msg_NoMutatorInUse;
var localized string Msg_NoUnusedMuts;
var localized string Msg_AddedMutator;
var localized string Msg_ErrAddingMutator;
var localized string Msg_RemovedMutator;
var localized string Msg_ErrRemovingMutator;
var localized string Msg_MapListNeedGameEdit;
var localized string Msg_MustEndGameEdit;
var localized string Msg_EditingClass;
var localized string Msg_EditFailed;
var localized string Msg_AlreadyEdited;
var localized string Msg_NotEditing;
var localized string Msg_EditingCompleted;
var localized string Msg_EditingCancelled;
var localized string Msg_NoBotGameFull;
var localized string Msg_NoAddNamedBot;
var localized string Msg_NoBotsPlaying;
var localized string Msg_GameNoSupportBots;
var localized string Msg_StatsNoBots;
var localized string Msg_SetBotNeedVal;

event Created()
{
	Super.Created();
	xManager = AccessControlIni(Manager);
}

// Execute an administrative console command on the server.
function DoLogin( string Username, string Password )
{
	if (AdminUser == None && xManager.AdminLogin(Outer, Username, Password))
	{
		bAdmin = true;
		AdminUser = xManager.GetLoggedAdmin(Outer);
		xManager.AdminEntered(Outer, Username);
	}
}

function DoLogout()
{
	if (xManager.AdminLogout(Outer))
	{
		xManager.ReleaseConfigSet(ConfigSet, Self);
		xManager.AdminExited(Outer);
		bAdmin=false;
	}
}

function RestartCurrentMap()
{
	if (CanPerform("Mr") || CanPerform("Mc"))	  // Mr = MapRestart, Mc = Map Change
	{
		if (ConfigSet == None)
			DoSwitch("?restart");
		else
			ClientMessage(Msg_FinishGameEditFirst);
	}
}

function DoSwitch( string URL)
{
	if (CanPerform("Mc"))
	{
		if (ConfigSet == None)
		{
			// Rebuild the URL based on edited game settings
			if (NextGameType != "" && Level.Game.ParseOption(URL, "Game") == "")
				URL=URL$"?Game="$NextGameType;

			if (NextMutators != "" && Level.Game.ParseOption(URL, "Mutator") == "")
				URL=URL$"?Mutator="$NextMutators;

			Level.ServerTravel( URL, false );
		}
		else
			ClientMessage(Msg_FinishGameRestart);
	}
}

function GotoNextMap()
{
local string NextMap;
local MapList MyList;
local GameInfo G;

	if (CanPerform("Mc"))
	{
		if (ConfigSet == None)
		{

			G = Level.Game;
			if ( G.bChangeLevels && !G.bAlreadyChanged && (G.MapListType != "") )
			{
				// open a the nextmap actor for this game type and get the next map
				G.bAlreadyChanged = true;
				MyList = G.GetMapList(G.MapListType);
				if (MyList != None)
				{
					NextMap = MyList.GetNextMap();
					MyList.Destroy();
				}
				if ( NextMap == "" )
					NextMap = GetMapName(G.MapPrefix, NextMap,1);

				if ( NextMap != "" )
				{
					DoSwitch(NextMap);
					ClientMessage(Repl(Msg_ChangingMapTo, "%NextMap%", NextMap));
					return;
				}
			}
			ClientMessage(Msg_NextMapNotFound);
			Level.ServerTravel( "?Restart", false );
		}
		else
			ClientMessage(Msg_FinishGameEditFirst);
	}
}

exec function User( string Cmd, string Extra)
{
	if (Cmd ~= "List")	// Admin User List *mask*
	{
		SendUserList(Extra);
	}
	else if (Cmd ~= "Del")	// Admin User Del *mask*
	{
		// TODO: Later .. need to make sure its acceptable to do so
	}
	else if (Cmd ~= "Logged") // List of currently logged admins
	{
		SendLoggedList();
	}
}

// TODO: Mutators Logic should be separate from GameConfigSet since
//       they are not associated to a game type.
exec function Mutators( string Cmd, string Extra)
{
local array<string> Values;
local int i;

	if (CanPerform("Mu"))
	{
		// TODO: Separate Mutator stuff from ConfigSet ?
		if  (ConfigSet == None)
		{
			ClientMessage(Msg_MutNeedGameEdit);
			return;
		}

		if (Cmd ~= "Used")
		{
			// List Used Mutators
			Values = ConfigSet.GetUsedMutators();
			for (i = 0; i<Values.Length; i++)
				ClientMessage(i$")"@Values[i]);
			if (i == 0)
				ClientMessage(Msg_NoMutatorInUse);
		}
		else if (Cmd ~= "Unused")
		{
			Values = ConfigSet.GetUnusedMutators();
			for (i = 0; i<Values.Length; i++)
				ClientMessage(i$")"@Values[i]);
			if (i == 0)
				ClientMessage(Msg_NoUnusedMuts);
		}
		else if (Cmd ~= "Add")
		{
			Split(Extra, " ", Values);
			for (i = 0; i<Values.Length; i++)
			{
				if (ConfigSet.AddMutator(Values[i]))
					ClientMessage(Repl(Msg_AddedMutator, "%Mutator%", Values[i]));
				else
					ClientMessage(Repl(Msg_ErrAddingMutator, "%Mutator%", Values[i]));
			}
		}
		else if (Cmd ~= "Del")
		{
			Split(Extra, " ", Values);
			for (i = 0; i<Values.Length; i++)
			{
				if (ConfigSet.DelMutator(Values[i]))
					ClientMessage(Repl(Msg_RemovedMutator, "%Mutator%", Values[i]));
				else
					ClientMessage(Repl(Msg_ErrRemovingMutator, "%Mutator%", Values[i]));
			}
		}
	}
}

function MapListCommand( string Cmd, string Extra )
{
local array<string> Values, Tmp;
local string Str;
local int i, c;

	if (CanPerform("Ml"))
	{
		Cmd = Caps(Cmd);
		if (ConfigSet == None)
		{
			i = MapHandler.GetGameIndex(string(Level.Game.Class));
			if (Extra == "")
				c = MapHandler.GetActiveList(i);
			else c = int(Extra);
			Str = MapHandler.GetMapListTitle(i, c);

			switch (Cmd)
			{
			case "LIST":
				Values = MapHandler.GetMapListNames(i);
				SendComplexMsg(Values, Repl(Msg_AllMapLists, "%gametype%", string(Level.Game.Class)));
				break;

			case "USED":
				Values = MapHandler.GetMapList(i, c);
				SendComplexMsg(Values, Repl(Msg_MapRotationList, "%maplist%", Str));
				break;

			case "SWITCH":
				MapHandler.ApplyMapList(i, c);
				break;

			default:
				ClientMessage(Msg_MapListNeedGameEdit);
				break;
			}
		}
		else
		{
			i = MapHandler.GetGameIndex(ConfigSet.GetEditedClass());

			switch (Cmd)
			{
			case "LIST":
				if (Extra == "")
				{
					Values = ConfigSet.GetLists();
					SendComplexMsg(Values, "MapLists for"@ConfigSet.GetEditedClass());
				}
				else
				{
					Values = ConfigSet.GetMaps();
					Str = MapHandler.GetMapListTitle(i, int(Extra));
					SendComplexMsg(Values, Repl(Msg_MapRotationList,"%maplist%",Str));
				}
				break;

			case "USED":
				Str = Repl(Msg_MapRotationList, "%maplist%", MapHandler.GetMapListTitle(i, ConfigSet.CurrentMapList));
				Values = ConfigSet.GetMaps();
				if (Values.Length > 0)
					SendComplexMsg(Values, Str);
				else ClientMessage(Msg_NoMapInRotation);
				break;

			case "SWITCH":
				ClientMessage(Msg_MustEndGameEdit);
				break;

			case "EDIT":
				if (Extra == "") Extra = string(ConfigSet.GetActiveList());
				ConfigSet.CurrentMapList = int(extra);
				ClientMessage(Repl(Msg_EditingMapList, "%List%", MapHandler.GetMapListTitle(i, ConfigSet.CurrentMapList)));
				break;

			case "ENDEDIT":
				ConfigSet.EndEdit(bool(Extra));
				break;

			case "NEW":
				Str = ConfigSet.GetEditedClass();
				MapHandler.AddList(Str, Extra, Values);
				ClientMessage(Repl(Msg_MapListAdded, "%listname%", Extra)@Str$".");
				break;

			case "REMOVE":
				Str = MapHandler.GetMapListTitle(i, ConfigSet.CurrentMapList);
				MapHandler.RemoveList(i, ConfigSet.CurrentMapList);
				ClientMessage(Repl(Msg_MapListRemoved, "%listname%", Str)@ConfigSet.GetEditedClass()$".");
				break;

			case "ADD":
				Values = ConfigSet.AddMaps(Extra);
				if (Values.Length == 0)
					ClientMessage(Msg_NoMapsAdded@Str$".");
				else SendComplexMsg(Values, Msg_AddedMapToList @ MapHandler.GetMapListTitle(i, ConfigSet.CurrentMapList));
				break;

			case "DEL":
				Str = MapHandler.GetMapListTitle(i, ConfigSet.CurrentMapList);
				Values = ConfigSet.RemoveMaps(Extra);
				if (Values.Length == 0)
					ClientMessage(Msg_NoMapsRemoved@Str$".");
				else SendComplexMsg(Values, Msg_RemovedFromList @ MapHandler.GetMapListTitle(i, ConfigSet.CurrentMapList));
				break;

			case "FIND":
				Str = MapHandler.GetMapListTitle(i, ConfigSet.CurrentMapList);
				Values = ConfigSet.FindMaps(Extra);
				for (i = 0; i<Values.Length; i++)
				{
					if (Left(Values[i], 1) != "+")
					{
						Tmp[Tmp.Length] = Values[i];
						Values.Remove(i--,1);
					}

					else Values[i] = Mid(Values[i],1);
				}
				if (Values.Length > 0)
					SendComplexMsg(Values, Repl(Msg_MapIsInRotation,"%maplist%",Str));
				else ClientMessage(Repl(Msg_NoMapsFound, "%maplist%", Str));

				if (Tmp.Length > 0)
					SendComplexMsg(Tmp, Repl(Msg_MapIsNotInRotation,"%maplist%",Str));
				break;
			}

		}
	}
}

exec function Game( string Cmd, string Extra )
{
local array<string> Params;
local string LastParam, LastValue;
local int p;

	if (Cmd ~= "ChangeTo")	// Admin Game ChangeTo <gameclass>
	{
		if (CanPerform("Mt"))
		{
			if (ConfigSet != None)
			{
				ClientMessage(Msg_MustEndGameEdit);
				return;
			}
			NextGameType = FindGameType(Extra);
		}
		return;
	}

	if (!CanPerform("Ms"))
		return;

	if (Cmd ~= "Edit")	// Admin Game Edit [CTF]
	{
		if (xManager.LockConfigSet(ConfigSet, Self))
		{
			if (ConfigSet.StartEdit(Extra))
				ClientMessage(Repl(Msg_EditingClass, "%Class%", ConfigSet.GetEditedClass()));
			else
			{
				ClientMessage(Msg_EditFailed);
				xManager.ReleaseConfigSet(ConfigSet, Self);
			}
		}
		else
			ClientMessage(Msg_AlreadyEdited);
		return;
	}

	if  (ConfigSet == None)
	{
		ClientMessage(Msg_NotEditing);
		return;
	}

	if (Cmd ~= "EndEdit")
	{
		ConfigSet.EndEdit(true);
		NextMutators = ConfigSet.NextMutators;
		xManager.ReleaseConfigSet(ConfigSet, Self);
		ClientMessage(Msg_EditingCompleted);
	}
	else if (Cmd ~= "CancelEdit")
	{
		ConfigSet.EndEdit(false);
		xManager.ReleaseConfigSet(ConfigSet, Self);
		ClientMessage(Msg_EditingCancelled);
	}
	else if (Cmd ~= "Get")
	{
		if (Instr(Extra, "*") == -1 && Instr(Extra, " ") == -1)
		{
			LastValue = ConfigSet.GetNamedParam(Extra);
			if (LastValue == "")
				ClientMessage(Repl(Msg_UnknownParam,"%Value%", Extra));
			else
				ClientMessage(Extra@"="@LastValue);
		}
		else
		{
			Params = ConfigSet.GetMaskedParams(Extra);
			if (Params.Length == 0)
				ClientMessage(Msg_NoParamsFound);
			else
				for (p = 0; p<Params.Length; p+=2)
					ClientMessage(Params[p]@"="@Params[p+1]);
		}
	}
	else if (Cmd ~= "Set")
	{
		p = Instr(Extra, " ");
		if (p >= 0)
		{
			LastParam = Left(Extra, p);
			LastValue = Mid(Extra, p+1);
			if (ConfigSet.SetNamedParam(LastParam, LastValue))
			{
				ClientMessage(Msg_ParamModified);
				return;
			}
		}
		ClientMessage(Msg_ParamNotModified);
	}
}

protected function bool CanPerform(string priv)
{
  return AdminUser != None && AdminUser.HasPrivilege(priv);
}

protected function SendUserList(string mask)	// Todo: Mask Feature
{
local xAdminUserList	uList;
local int i;

	uList = AdminUser.GetManagedUsers(xManager.Groups);
	for (i=0; i<uList.Count(); i++)
		ClientMessage(string(i)$uList.Get(i).UserName);
}

/// TODO: Check if should send ALL logged admins or only
protected function SendLoggedList()
{
local xAdminUserList	uList;
local int i;

	uList = AdminUser.GetManagedUsers(xManager.Groups);
	for (i=0; i<uList.Count(); i++)
		if (xManager.IsLogged(uList.Get(i)))
			ClientMessage(string(i)$uList.Get(i).UserName);
}

// All Bots functions are not Persistent unless Level.Game.SaveConfig()
exec function Bots( string Cmd, string Extra)
{
local int MinV, i, j;
local array<string> Params;
local array<XUtil.PlayerRecord>	BotList, BotsToAdd;
local DeathMatch	Game;
local Controller	C, NextC;
local xBot			Bot;

	if (CanPerform("Mb"))
	{
		Game = DeathMatch(Level.Game);
		if (Game == None)
		{
			ClientMessage(Msg_GameNoSupportBots);
			return;
		}

		if (Game.GameStats != None)
		{
			ClientMessage(Msg_StatsNoBots);
			return;
		}

		Params = SplitParams(Extra);
		if (Cmd ~= "Add")
		{
			MinV = Game.MinPlayers;
			if (MinV == 32)
			{
				ClientMessage(Msg_NoBotGameFull);
				return;
			}

			if (Params.Length == 0)
			{
				Game.ForceAddBot();
			}
			else if (Params.Length == 1 && IsNumeric(Params[0]))
			{
				MinV = Min(32, MinV + int(Params[0]));
				while (Game.MinPlayers < MinV)
					Game.ForceAddBot();
			}
			else	// Else add named bots
			{
				if (!Game.IsInState('MatchInProgress'))
				{
					ClientMessage(Msg_NoAddNamedBot);
					return;
				}
				MakeBotsList(BotList);
				// First Build a list of Bots to add
				for (i = 0; i<BotList.Length; i++)
				{
					for (j = 0; j<Params.Length; j++)
					{
						if (MaskedCompare(BotList[i].DefaultName, Params[j]))
						{
							BotsToAdd[BotsToAdd.Length] = BotList[i];
							BotList.Remove(i, 1);
							i--;
						}
					}
				}
				MinV = Min(32, MinV + BotsToAdd.Length);
				while (Game.MinPlayers<MinV)
				{
					if (!Game.AddBot(BotsToAdd[0].DefaultName))
						break;
					BotsToAdd.Remove(0, 1);
				}
			}
		}
		else if (Cmd ~= "Kill")
		{
			if (Game.MinPlayers == 0 || Game.NumBots == 0)
			{
				ClientMessage(Msg_NoBotsPlaying);
				return;
			}

			if (Params.Length == 0) // Kill 1 random bot
			{
				Game.KillBots(1);
			}
			else if (Params.Length == 1 && IsNumeric(Params[0])) // Kill a Number of Bots
			{
				Game.KillBots(int(Params[0]));
			}
			else	// Kill Named Bots
			{
				// TODO: Rework Loop ?
				for (C = Level.ControllerList; C != None; C = NextC)
				{
					Bot = xBot(C);
					NextC = C.NextController;
					if (Bot != None && Bot.PlayerReplicationInfo != None)
					{
						for (i = 0; i<Params.Length; i++)
						{
							if (MaskedCompare(Bot.PlayerReplicationInfo.PlayerName, Params[i]))
							{
								Game.KillBot(C);
								break;
							}
						}
					}
				}
			}
		}
		else if (Cmd ~= "Set")	// Minimum number of Players
		{
			if (Params.Length == 1 && IsNumeric(Params[0]) && int(Params[0]) < 33)
			{
				Game.MinPlayers=int(Params[0]);
			}
			else
				ClientMessage(Msg_SetBotNeedVal);
		}
	}
}

function MakeBotsList(out array<XUtil.PlayerRecord> BotList)
{
local xBot Bot;
local int i;
local Controller C;

	// Get Full Bot List
	class'XUtil'.static.GetPlayerList(BotList);
	// Filter out Playing Bots
	for (C = Level.ControllerList; C != None; C = C.NextController)
	{
		Bot = xBot(C);
		if (Bot != None && Bot.PlayerReplicationInfo != None)
		{
			for (i = 0; i<BotList.Length; i++)
			{
				if (Bot.PlayerReplicationInfo.CharacterName == BotList[i].DefaultName)
				{
					BotList.Remove(i,1);
					break;
				}
			}
		}
	}
}

defaultproperties
{
     Msg_FinishGameEditFirst="You must finish your Game Edit before restarting the map"
     Msg_FinishGameRestart="You must finish your Game Edit before changing or restarting the map"
     Msg_MutNeedGameEdit="You must use 'Game Edit' command before 'Mutators' commands"
     Msg_NoMutatorInUse="No Mutators in use"
     Msg_NoUnusedMuts="Found no unused mutators"
     Msg_AddedMutator="Added '%Mutator%' to used mutator list."
     Msg_ErrAddingMutator="Error Adding '%Mutator%'To Used Mutator List"
     Msg_RemovedMutator="Removed '%Mutator%' From Used Mutator List"
     Msg_ErrRemovingMutator="Error Removing '%Mutator%' from used mutator List"
     Msg_MapListNeedGameEdit="You must use 'Game Edit' command before 'MapList' command"
     Msg_MustEndGameEdit="You must end your Game Edit first"
     Msg_EditingClass="Editing %Class%"
     Msg_EditFailed="Failed Starting To Edit"
     Msg_AlreadyEdited="Game Already being edited by Someone Else"
     Msg_NotEditing="You are not editing Game Settings, use 'Game Edit' first"
     Msg_EditingCompleted="Editing Completed"
     Msg_EditingCancelled="Editing Cancelled"
     Msg_NoBotGameFull="Cannot add a bot, game is full."
     Msg_NoAddNamedBot="Can only add named bots once the match has started"
     Msg_NoBotsPlaying="No bots are currently playing"
     Msg_GameNoSupportBots="The current Game Type does not support Bots"
     Msg_StatsNoBots="Cannot control bots when Worlds Stats are enabled"
     Msg_SetBotNeedVal="This command requires a numeric value between 0 and 32"
}
