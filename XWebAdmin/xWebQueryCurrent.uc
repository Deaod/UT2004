//==============================================================================
//  WebAdmin handler for activities related to the game currently in
//  progress on the server
//
//  Written by Michael Comeau
//  Revised by Ron Prestenback
//  © 2003,2004 Epic Games, Inc. All Rights Reserved
//==============================================================================

class xWebQueryCurrent extends xWebQueryHandler
	config;

var config string CurrentIndexPage;		// This is the page with the Menu
var config string CurrentPlayersPage;
var config string CurrentGamePage;
var config string CurrentConsolePage;
var config string CurrentConsoleLogPage;
var config string CurrentConsoleSendPage;
var config string CurrentMutatorsPage;
var config string CurrentBotsPage;
var config string CurrentRestartPage;
var config string DefaultSendText;
var config string StatTable;
var config string StatTableRow;

// Custom Skin Support
var config string PlayerListHeader;
var config string PlayerListLinkedHeader;
var config string PlayerListMinPlayers;
var config string ConsoleRefreshTag;
var config string MutatorTablePage;
var config string MutatorGroupTitle;
var config string MutatorGroupMember;


// Localization
// Sections & Titles
var localized string BadGameType;
var localized string CurrentLinks[6];
var localized string NoBotsTitle;

// Labels
var localized string KickButtonText[3];
var localized string NoPlayersConnected;
var localized string SelectedMutators;
var localized string PickMutators;
var localized string GameTypeUnsupported;
var localized string NoBots;
var localized string Added;
var localized string Removed;
var localized string BotStatus;
var localized string SingleBotStatus;
var localized string ConsoleUserlist;

// Help messages
var localized string NoteGamePage;
var localized string NotePlayersPage;
var localized string NoteConsolePage;
var localized string NoteMutatorsPage;
var localized string NoteBotsPage;

var StringArray	SpeciesNames;
var array<StringArray>  BotList;		// Sorted bot list by species

function bool Query(WebRequest Request, WebResponse Response)
{
	if (!CanPerform(NeededPrivs))
		return false;

	switch (Mid(Request.URI, 1))
	{
	case DefaultPage:
		QueryCurrentFrame(Request, Response);
		return true;

	case CurrentIndexPage:
		QueryCurrentMenu(Request, Response);
		return true;

	case CurrentPlayersPage:
		if (!MapIsChanging())
			QueryCurrentPlayers(Request, Response);
		return true;

	case CurrentGamePage:
		if (!MapIsChanging())
			QueryCurrentGame(Request, Response);
		return true;

	case CurrentConsolePage:
		if (!MapIsChanging())
			QueryCurrentConsole(Request, Response);
		return true;

	case CurrentConsoleLogPage:
		if (!MapIsChanging())
			QueryCurrentConsoleLog(Request, Response);
		return true;

	case CurrentConsoleSendPage:
		QueryCurrentConsoleSend(Request, Response);
		return true;

	case CurrentMutatorsPage:
		if (!MapIsChanging())
			QueryCurrentMutators(Request, Response);
		return true;

	case CurrentBotsPage:
		if (!MapIsChanging())
			QueryCurrentBots(Request, Response);
		return true;

	case CurrentRestartPage:
		if (!MapIsChanging())
			QueryRestartPage(Request, Response);
		return true;
	}
	return false;
}

//*****************************************************************************
function QueryCurrentFrame(WebRequest Request, WebResponse Response)
{
local String Page;

	// if no page specified, use the default
	Page = Request.GetVariable("Page", CurrentGamePage);

	Response.Subst("IndexURI", 	CurrentIndexPage$"?Page="$Page);
	Response.Subst("MainURI", 	Page);

	ShowFrame(Response, DefaultPage);
}

function QueryCurrentMenu(WebRequest Request, WebResponse Response)
{
	local String Page;

	Page = Request.GetVariable("Page", CurrentGamePage);

	// set background colors
	Response.Subst("DefaultBG", DefaultBG);	// for unused tabs

	Response.Subst("PlayersBG", DefaultBG);
	Response.Subst("GameBG", 	DefaultBG);
	Response.Subst("ConsoleBG",	DefaultBG);
	Response.Subst("MutatorsBG",DefaultBG);
	Response.Subst("RestartBG", DefaultBG);

	switch(Page)
	{
	case CurrentPlayersPage:
		Response.Subst("PlayersBG",	HighlightedBG);
		break;
	case CurrentGamePage:
		Response.Subst("GameBG", 	HighlightedBG);
		break;
	case CurrentConsolePage:
		Response.Subst("ConsoleBG",	HighlightedBG);
		break;
	case CurrentMutatorsPage:
		Response.Subst("MutatorsBG",HighlightedBG);
		break;
	case CurrentRestartPage:
		Response.Subst("RestartBG", HighlightedBG);
		break;
	}

	// Set URIs
	Response.Subst("PlayersURI", 	DefaultPage$"?Page="$CurrentPlayersPage);
	Response.Subst("GameURI",		DefaultPage$"?Page="$CurrentGamePage);
	Response.Subst("ConsoleURI", 	DefaultPage$"?Page="$CurrentConsolePage);
	Response.Subst("MutatorsURI", 	DefaultPage$"?Page="$CurrentMutatorsPage);
	Response.Subst("BotsURI", 		DefaultPage$"?Page="$CurrentBotsPage);
	Response.Subst("RestartURI", 	DefaultPage$"?Page="$CurrentRestartPage);

	// Set link text
	Response.Subst("GameLink", 		CurrentLinks[0]);
	Response.Subst("PlayerLink", 	CurrentLinks[1]);
	Response.Subst("ConsoleLink",	CurrentLinks[2]);
	Response.Subst("MutatorLink",	CurrentLinks[3]);
	Response.Subst("BotsLink",		CurrentLinks[4]);
	Response.Subst("RestartLink",	CurrentLinks[5]);

	ShowPage(Response, CurrentIndexPage);
}

function QueryCurrentPlayers(WebRequest Request, WebResponse Response)
{
local string Sort, PlayerListSubst, TempStr, TempTag, TempData;
local string TableHeaders, GameType, Reverse, ColorNames[2], Last;
local StringArray	PlayerList;
local Controller P, NextP;
local int i, Cols, mlength;
local string IP, ID;
local bool bCanKick, bCanBan, bCanKickBots;

	Response.Subst("Section", CurrentLinks[1]);
	Response.Subst("PostAction", CurrentPlayersPage);
	ColorNames[0] = class'TeamInfo'.default.ColorNames[0];
	ColorNames[1] = class'TeamInfo'.default.ColorNames[1];
	MLength = int(Eval(Len(ColorNames[0]) > Len(ColorNames[1]), string(Len(ColorNames[0])), string(Len(ColorNames[1]))));

	if (CanPerform("Xp|Kp|Kb|Ko"))
	{
		PlayerList = new(None) class'SortedStringArray';

		Sort = Request.GetVariable("Sort", "Name");
		Last = Request.GetVariable("Last");
		Response.Subst("Sort", Sort);
		Cols = 0;

		bCanKick = CanPerform("Kp");
		bCanBan = CanPerform("Kb");
		bCanKickBots = CanPerform("Ko|Mb");
		if (Last == Sort && Request.GetVariable("ReverseSort") == "")
		{
			PlayerList.ToggleSort();
			Reverse = "?ReverseSort=True";
		}

		else Reverse = "";

		// Count the number of Columns allowed
		if (bCanKick || bCanBan || bCanKickBots)
		{
		// Use 'do-while' to avoid access-none when destroying Controllers within the loop
			P = Level.ControllerList;
			if (P != None)
			{
				do {
					NextP = P.NextController;
					if(		PlayerController(P) != None
						&&	P.PlayerReplicationInfo != None
						&&	NetConnection(PlayerController(P).Player) != None)
					{
						if ( bCanBan && Request.GetVariable("Ban" $ string(P.PlayerReplicationInfo.PlayerID)) != "" )
							Level.Game.AccessControl.KickBanPlayer(PlayerController(P));

						else if ( bCanKick && Request.GetVariable("Kick" $ string(P.PlayerReplicationInfo.PlayerID)) != "" )
							Level.Game.AccessControl.KickPlayer(PlayerController(P));
					}

					else if ( PlayerController(P) == None && bCanKickBots && P.PlayerReplicationInfo != None &&
						  	  Request.GetVariable("Kick" $ string(P.PlayerReplicationInfo.PlayerID)) != "")
					{	// Kick Bots
						P.Destroy();
					}
					P = NextP;
				} until (P == None);
			}

			if (bCanKick || bCanKickBots) Cols += 1;
			if (bCanBan) Cols += 2;
			Response.Subst("KickButton", SubmitButton("Kick", KickButtonText[Cols-1]));

			// Build of valid TableHeaders
			TableHeaders = "";
			if (bCanKick || bCanKickBots)
			{
				Response.Subst("HeadTitle", "Kick");
				TableHeaders $= WebInclude(PlayerListHeader);
			}

			if (bCanBan)
			{
				Response.Subst("HeadTitle", "Ban");
				TableHeaders $= WebInclude(PlayerListHeader);
			}

			if (Sort ~= "Name") Response.Subst("ReverseSort", Reverse);
			else Response.Subst("ReverseSort", "");
			Response.Subst("HeadTitle", "Name");
			TableHeaders $= WebInclude(PlayerListLinkedHeader);

			if (Level.Game.GameReplicationInfo.bTeamGame)
			{
				if (Sort ~= "Team")	Response.Subst("ReverseSort", Reverse);
				else Response.Subst("ReverseSort", "");
				Response.Subst("HeadTitle", "Team");
				TableHeaders $= WebInclude(PlayerListLinkedHeader);
			}

			if (Sort ~= "Ping")	Response.Subst("ReverseSort", Reverse);
			else Response.Subst("ReverseSort", "");
			Response.Subst("HeadTitle", "Ping");
			TableHeaders $= WebInclude(PlayerListLinkedHeader);

			if (Sort ~= "Score") Response.Subst("ReverseSort", Reverse);
			else Response.Subst("ReverseSort", "");
			Response.Subst("HeadTitle", "Score");
			TableHeaders $= WebInclude(PlayerListLinkedHeader);

			Response.Subst("HeadTitle", "IP");
			TableHeaders $= WebInclude(PlayerListHeader);

			// evo ---
			if (Level.Game.AccessControl.bBanbyID)
			{
				Response.Subst("HeadTitle", "Global ID");
				TableHeaders $= WebInclude(PlayerListHeader);
			}
			// --- evo

			Response.Subst("TableHeaders", TableHeaders);
		}

		if (CanPerform("Ms"))
		{
			GameType = Level.GetItemName(SetGamePI(GameType));
			if (GamePI != None && GamePI.Settings[GamePI.FindIndex(GameType$".MinPlayers")].SecLevel <= CurAdmin.MaxSecLevel())
			{
				if ((Request.GetVariable("SetMinPlayers", "") != "") && UnrealMPGameInfo(Level.Game) != None)
				{
					UnrealMPGameInfo(Level.Game).MinPlayers = Min(Max(int(Request.GetVariable("MinPlayers", String(0))), 0), 32);
					Level.Game.SaveConfig();
				}

				Response.Subst("MinPlayers", string(UnrealMPGameInfo(Level.Game).MinPlayers));
				Response.Subst("MinPlayerPart", WebInclude(PlayerListMinPlayers));
			}

			else
			{
				Response.Subst("MinPlayers", "");
				Response.Subst("MinPlayersPart", "");
			}
		}

		for (P=Level.ControllerList; P!=None; P=P.NextController)
		{
			TempData = "";
			if (!P.bDeleteMe && P.bIsPlayer && P.PlayerReplicationInfo != None)
			{
				Response.Subst("Content", CheckBox("Kick" $ string(P.PlayerReplicationInfo.PlayerID), False));
				if (CanPerform("Kp"))
					TempData $= WebInclude(CellCenter);

				if (CanPerform("Kb"))
				{
					if ( PlayerController(P) != None )
						Response.Subst("Content", Checkbox("Ban" $ string(P.PlayerReplicationInfo.PlayerID), False));
					else Response.Subst("Content", "");
					TempData $= WebInclude(CellCenter);
				}

				TempStr = "";
				if (DeathMatch(Level.Game) != None && DeathMatch(Level.Game).bTournament && P.PlayerReplicationInfo.bReadyToPlay)
					TempStr = " (Ready) ";

				else if (P.PlayerReplicationInfo.bIsSpectator)
					TempStr = " (Spectator) ";

				else if (PlayerController(P) == None)
					TempStr = " (Bot) ";

				if( PlayerController(P) != None )
				{
					IP = PlayerController(P).GetPlayerNetworkAddress();
					IP = HtmlEncode(" " $ Left(IP, InStr(IP, ":")));
					// evo ---
					ID = HtmlEncode(" " $ Eval(Level.Game.AccessControl.bBanbyID, PlayerController(P).GetPlayerIDHash(), " "));
					// --- evo
				}

				else
				{
					IP = HtmlEncode("  ");
					ID = HtmlEncode("  ");
				}

				Response.Subst("Content", HtmlEncode(P.PlayerReplicationInfo.PlayerName $ TempStr));
				TempData $= WebInclude(NowrapLeft);

				if (Level.Game.bTeamGame)
				{
					if (P.PlayerReplicationInfo.Team != None && P.PlayerReplicationInfo.Team.TeamIndex < 4)
						Response.Subst("Content", "<span style='background-color: "$class'TeamInfo'.default.ColorNames[P.PlayerReplicationInfo.Team.TeamIndex]$"'>"$HtmlEncode("  ")$"</span>"$HtmlEncode(P.PlayerReplicationInfo.Team.GetHumanReadableName()));

					else if (P.PlayerReplicationInfo.bIsSpectator)
						Response.Subst("Content", HtmlEncode("  "));

					TempData $= WebInclude(NowrapCenter);
				}

				Response.Subst("Content", string(P.PlayerReplicationInfo.Ping*4));
				TempData $= WebInclude(CellCenter);

				Response.Subst("Content", string(int(P.PlayerReplicationInfo.Score)));
				TempData $= WebInclude(CellCenter);

				Response.Subst("Content", IP);
				TempData $= WebInclude(CellCenter);

				if (Level.Game.AccessControl.bBanbyID)
				{
					Response.Subst("Content", ID);
					TempData $= WebInclude(CellCenter);
				}

				switch (Sort)
				{
					case "Name":
						TempTag = P.PlayerReplicationInfo.PlayerName; break;
					case "Team":	// Ordered by Team, then subordered by last selected sort method
						TempTag = PadRight(class'TeamInfo'.default.ColorNames[P.PlayerReplicationInfo.Team.TeamIndex],MLength,"0");
						switch (Last)
						{
							case "Name":
								TempTag $= P.PlayerReplicationInfo.PlayerName; break;
							case "Ping":
								TempTag $= PadLeft(string(P.PlayerReplicationInfo.Ping*4), 5, "0"); break;
							default:
								TempTag $= PadLeft(string(int(P.PlayerReplicationInfo.Score)), 4, "0"); break;
						}
						break;
					case "Ping":
						TempTag = PadLeft(string(P.PlayerReplicationInfo.Ping*4), 5, "0"); break;
					default:
						TempTag = PadLeft(string(int(P.PlayerReplicationInfo.Score)), 4, "0"); break;
				}

				Response.Subst("RowContent", TempData);
				PlayerList.Add( WebInclude(RowLeft), TempTag);
			}
		}

		PlayerListSubst = "";
		if (PlayerList.Count() > 0)
		{
			for ( i=0; i<PlayerList.Count(); i++)
			{
				if (Sort ~= "Score")
					PlayerListSubst = PlayerList.GetItem(i) $ PlayerListSubst;

				else PlayerListSubst $= PlayerList.GetItem(i);
			}
		}

		else
		{
			Response.Subst("SpanContent", NoPlayersConnected);
			Response.Subst("SpanLength", "6");
			Response.Subst("RowContent", WebInclude(CellColSpan));
			PlayerListSubst = WebInclude(RowCenter);
		}

		Response.Subst("PlayerList", PlayerListSubst);
		Response.Subst("MinPlayers", string(UnrealMPGameInfo(Level.Game).MinPlayers));

		Response.Subst("PageHelp", NotePlayersPage);
		MapTitle(Response);
		ShowPage(Response, CurrentPlayersPage);
	}
	else
		AccessDenied(Response);
}

function QueryCurrentGame(WebRequest Request, WebResponse Response)
{
local StringArray	ExcludeMaps, IncludeMaps, MovedMaps;
local class<GameInfo> GameClass;
local string NewGameType, SwitchButtonName, GameState, NewMap;
local bool bMakeChanges;
local Controller C;
local xPlayer XP;
local TeamPlayerReplicationInfo PRI;
local int i, MultiKills, Sprees, GameIndex;

	if (CanPerform("Mt|Mm"))
	{
		if (Request.GetVariable("SwitchGameTypeAndMap", "") != "")
		{
			if (CanPerform("Mt"))
				ServerChangeMap(Request, Response, Request.GetVariable("MapSelect"), Request.GetVariable("GameTypeSelect"));

			else AccessDenied(Response);

			return;
		}

		else if (Request.GetVariable("SwitchMap", "") != "")
		{
			if (CanPerform("Mm|Mt"))
			{
				NewMap = Request.GetVariable("MapSelect");
				Level.ServerTravel(NewMap$"?game="$Level.Game.Class$"?mutator="$UsedMutators(), false);
				ShowMessage(Response, WaitTitle, Repl(MapChangingTo, "%MapName%", NewMap));
			}

			else AccessDenied(Response);

			return;
		}

		bMakeChanges = (Request.GetVariable("ApplySettings", "") != "");
		if (CanPerform("Mt") && (bMakeChanges || Request.GetVariable("SwitchGameType", "") != ""))
		{
			NewGameType = Request.GetVariable("GameTypeSelect");
			GameClass = class<GameInfo>(DynamicLoadObject(NewGameType, class'Class'));
		}
		else GameClass = None;

		if (GameClass == None)
		{
			GameClass = Level.Game.Class;
			NewGameType = String(GameClass);
		}

		GameIndex = Level.Game.MaplistHandler.GetGameIndex(NewGameType);
		ExcludeMaps = ReloadExcludeMaps(NewGameType);
		IncludeMaps = ReloadIncludeMaps(ExcludeMaps, GameIndex, Level.Game.MaplistHandler.GetActiveList(GameIndex));

		GameState = "";
		// Show game status if admin has necessary privs
		if (CanPerform("Ma"))
		{
			if (Level.Game.NumPlayers > 0)
			{
				for (C = Level.ControllerList; C != None; C = C.NextController)
				{
					MultiKills = 0;
					Sprees = 0;
					PRI = None;
					XP = xPlayer(C);
					if (XP != None && !XP.bDeleteMe)
					{
						if (TeamPlayerReplicationInfo(XP.PlayerReplicationInfo) != None)
							PRI = TeamPlayerReplicationInfo(XP.PlayerReplicationInfo);

						if (PRI != None)
						{
							Response.Subst("PlayerName", HtmlEncode(PRI.PlayerName));
							Response.Subst("Kills", string(PRI.Kills));
							Response.Subst("Deaths", string(PRI.Deaths));
							Response.Subst("Suicides",string(PRI.Suicides));
							for (i = 0; i < 7; i++)
								MultiKills += PRI.MultiKills[i];
							Response.Subst("MultiKills", string(MultiKills));
							for (i = 0; i < 6; i++)
								Sprees += PRI.Spree[i];
							Response.Subst("Sprees", string(Sprees));
							GameState $= WebInclude(StatTableRow);
						}
					}
				}
			}

			else GameState = "<tr><td colspan=\"6\" align=\"center\">"@NoPlayersConnected@"</td></tr>";

			Response.Subst("StatRows", GameState);
			Response.Subst("GameState", WebInclude(StatTable));
		}

		if (GameClass == Level.Game.Class)
		{
			SwitchButtonName="SwitchMap";
			MovedMaps = New(None) Class'SortedStringArray';
			MovedMaps.CopyFromId(IncludeMaps, IncludeMaps.FindTagId(Left(string(Level), InStr(string(Level), "."))));
		}
		else SwitchButtonName="SwitchGameTypeAndMap";

		if (CanPerform("Mt"))
		{
			Response.Subst("Content", Select("GameTypeSelect", GenerateGameTypeOptions(NewGameType)));
			Response.Subst("GameTypeButton", SubmitButton("SwitchGameType", SwitchText));
		}
		else Response.Subst("Content", Level.Game.Default.GameName);

		Response.Subst("GameTypeSelect", WebInclude(CellLeft));
		Response.Subst("Content", Select("MapSelect", GenerateMapListSelect(IncludeMaps, MovedMaps)));
		Response.Subst("MapSelect", WebInclude(CellLeft));
		Response.Subst("MapButton", SubmitButton(SwitchButtonName, SwitchText));
		Response.Subst("PostAction", CurrentGamePage);

		Response.Subst("Section", CurrentLinks[0]);
		Response.Subst("PageHelp", NoteGamePage);
		MapTitle(Response);
		ShowPage(Response, CurrentGamePage);
	}
	else AccessDenied(Response);
}

function QueryCurrentConsole(WebRequest Request, WebResponse Response)
{
local String SendStr, OutStr;

	if (CanPerform("Xc"))
	{
		SendStr = Request.GetVariable("SendText", "");
		if (SendStr != "" && !(Left(SendStr, 6) ~= "debug " || SendStr ~= "debug"))
		{
			if (Left(SendStr, 4) ~= "say ")
				Level.Game.Broadcast(Spectator, Mid(SendStr, 4), 'Say');
			else if (SendStr ~= "pause")
			{
				if (Level.Pauser == None)
					Level.Pauser = Spectator.PlayerReplicationInfo;
				else Level.Pauser = None;
			}
			else if (SendStr ~= "dump")
				Spectator.Dump();

			else if ((Left(SendStr, 4) ~= "get " || Left(SendStr,4) ~= "set ") &&
			(InStr(Caps(SendStr), "XADMINCONFIG") != -1 || !CanPerform("Ms")) )
			{
				if ( InStr(Caps(SendStr), "XADMINCONFIG") != -1 )
				{
					StatusError(Response, ConsoleUserlist);
					ShowMessage(Response, Error, "");
					log("User attempted to modify or enumerate admin account information illegally using the webadmin console.  User:"$Request.Username$".",'WebAdmin');
				}

				else if ( !CanPerform("Ms") )
					AccessDenied(Response);
			}
			else
			{
				OutStr = Level.ConsoleCommand(SendStr);
				if (OutStr != "")
					Spectator.AddMessage(None, OutStr, 'Console');
			}
		}

		Response.Subst("LogURI", CurrentConsoleLogPage);
		Response.Subst("SayURI", CurrentConsoleSendPage);
		ShowPage(Response, CurrentConsolePage);
	}
	else
		AccessDenied(Response);
}

function QueryCurrentConsoleLog(WebRequest Request, WebResponse Response)
{
local String LogSubst, LogStr;
local int i;


	if (CanPerform("Xc"))
	{
		Response.Subst("Section", CurrentLinks[2]);
		Response.Subst("SubTitle", Level.Game.GameReplicationInfo.GameName$" in "$Level.Title);

		i = Spectator.LastMessage();
		LogStr = HtmlEncode(Spectator.NextMessage(i));
		while (LogStr  != "")
		{
			LogSubst = LogSubst$"&gt; "$LogStr$"<br>";
			LogStr = HtmlEncode(Spectator.NextMessage(i));
		}

		Response.Subst("RefreshMeta", ConsoleRefreshTag $ CurrentConsoleLogPage $ "#END\">");
		Response.Subst("LogText", LogSubst);
		Response.Subst("PageHelp", NoteConsolePage);
		MapTitle(Response);
		ShowPage(Response, CurrentConsoleLogPage);
	}
	else
		AccessDenied(Response);
}

function QueryCurrentConsoleSend(WebRequest Request, WebResponse Response)
{
	if (CanPerform("Xc"))
	{
		Response.Subst("DefaultSendText", DefaultSendText);
		Response.Subst("PostAction", CurrentConsolePage);
		ShowPage(Response, CurrentConsoleSendPage);
	}
	else
		AccessDenied(Response);
}

function QueryCurrentMutators(WebRequest Request, WebResponse Response)
{
local int i, j, k, z;
local string selectedmutes, lastgroup, nextgroup, thisgroup, Checked, tmp;
local StringArray	GroupedMutators, SoloMutators;

	if (CanPerform("Mu"))
	{
		SoloMutators = new(None) class'SortedStringArray';
		GroupedMutators = new(None) class'StringArray';

		if (Request.GetVariable("SetMutes", "") != "")
		{
			AIncMutators.Reset();
			lastgroup = "";
			for (i = 0; i<AExcMutators.Count(); i++)
			{
				j = int(AExcMutators.GetItem(i));
				if (j < 0) continue;

				thisgroup = AllMutators[j].GroupName;
				if (Request.GetVariable(AExcMutators.GetTag(i), "") != "" || Request.GetVariable(thisgroup) == AllMutators[j].ClassName)
					AIncMutators.Add(AExcMutators.GetItem(i), AllMutators[j].FriendlyName);
			}
		}

		// Make a list sorted by friendly name
		for (i = 0; i<AExcMutators.Count(); i++)
		{
			j = int(AExcMutators.GetItem(i));
			if (j < 0) continue;

			SoloMutators.Add(string(j), AllMutators[j].FriendlyName);
		}

		// First, Display Selected Mutators, 1 per line
		selectedmutes = "";
		for (i = 0; i<AIncMutators.Count(); i++)
		{
			tmp = "";
			j = int(AIncMutators.GetItem(i));
			if (j < 0) continue;

			Response.Subst("Content", HtmlEncode(AllMutators[j].FriendlyName));
			tmp = WebInclude(CellLeft);
			Response.Subst("Content", HtmlEncode(AllMutators[j].Description));
			Response.Subst("RowContent", tmp $ WebInclude(CellLeft));
			selectedmutes $= WebInclude(RowLeft);
		}

		if (selectedmutes != "")
		{
			Response.Subst("TableTitle", SelectedMutators);
			Response.Subst("TableRows", selectedmutes);
			Response.Subst("SelectedTable", WebInclude(MutatorTablePage));
		}

		CreateFullMutatorList(SoloMutators, GroupedMutators);
		lastgroup = ""; selectedmutes = "";

		// First, display all grouped mutators, sorted by friendly name
		for (i = 0; i<GroupedMutators.Count(); i++)
		{
			j = int(GroupedMutators.GetItem(i));
			if (j < 0) continue;

		// If mod author has forgotten to specify a group name for this mutator,
		// then add unique group name, to avoid all mutes without group names from
		// being considered in the same group
			if (AllMutators[j].GroupName=="")
				thisgroup = "Z" $ string(z++);

			else thisgroup = AllMutators[j].GroupName;

			if ( (i + 1) == GroupedMutators.Count())
				nextgroup = "";

			else
			{
				k = int(GroupedMutators.GetItem(i + 1));
				if (k < 0) continue;

				if (AllMutators[k].GroupName=="")
					nextgroup = "Z" $ string(z);

				else nextgroup = AllMutators[k].GroupName;
			}

			Response.Subst("GroupName", thisgroup);
			Response.Subst("MutatorClass", AllMutators[j].ClassName);
			Response.Subst("MutatorName", AllMutators[j].FriendlyName);
			Response.Subst("MutatorDesc", AllMutators[j].Description);

			if (lastgroup != thisgroup && thisgroup == nextgroup) // and the next mut is in the same group as this one
			{
                Response.Subst("Checked", "checked");
				selectedmutes $= WebInclude(MutatorGroupTitle);
			}

			Checked = Eval(AIncMutators.FindItemId(string(j)) >= 0, " checked", "");
			Response.Subst("Checked", Checked);

			selectedmutes $= WebInclude(MutatorGroupMember);
			lastgroup = thisgroup;
		}

		for (i = 0; i < SoloMutators.Count(); i++)
		{
			tmp = "";	// Some sort of bug in WebInclude...must empty this var each time I use it
			j = int(SoloMutators.GetItem(i));

			Response.Subst("Content", CheckBox(AllMutators[j].ClassName, AIncMutators.FindItemId(string(j)) >= 0) $ "&nbsp;" $ AllMutators[j].FriendlyName);
			tmp = WebInclude(NowrapLeft);
			Response.Subst("Content", AllMutators[j].Description);
			Response.Subst("RowContent", tmp $ WebInclude(CellLeft));
			selectedmutes $= WebInclude(RowLeft);
		}

		Response.Subst("TableTitle", PickMutators);
		Response.Subst("TableRows", selectedmutes);
		Response.Subst("ChooseTable", WebInclude(MutatorTablePage));

		MapTitle(Response);
		Response.Subst("Section", CurrentLinks[3]);
		Response.Subst("PageHelp", NoteMutatorsPage);
		Response.Subst("PostAction", CurrentMutatorsPage);
		ShowPage(Response, CurrentMutatorsPage);
	}

	else AccessDenied(Response);
}

function QueryCurrentBots(WebRequest Request, WebResponse Response)
{
local array<xUtil.PlayerRecord> PlayerRecords;
local string OutStr, BotName, LeftTable, RightTable;
local int i, j, BotCount, maxbots, cnt, Col1Count;
local xBot	B;
local bool oldstate, newstate, bInMatch;
local DeathMatch	DM;

	if (!CanPerform("Mb"))
	{
		AccessDenied(Response);
		return;
	}

	DM = DeathMatch(Level.Game);
	if (DM == None)
	{
		ShowMessage(Response, BadGameType, Repl(GameTypeUnsupported, "%GameType%", string(Level.Game.Class)));
		return;
	}

	// Disable any type of Bots controls when stats are on
	if (DM.bEnableStatLogging && DM.NumBots == 0)
	{
		ShowMessage(Response, NoBotsTitle, NoBots);
		return;
	}

	// Make a sorted list of all species and group bots
	if (SpeciesNames == None)
	{
		class'xUtil'.static.GetPlayerList(PlayerRecords);
		SpeciesNames = new(None) class'SortedStringArray';
		for (i = 0; i<PlayerRecords.Length; i++)
			SpeciesNames.Add(PlayerRecords[i].Species.default.SpeciesName, PlayerRecords[i].Species.default.SpeciesName, true);

		BotList.Length = SpeciesNames.Count();	// Preset Bot list size

		for (i = 0; i<PlayerRecords.Length; i++)
		{
			j = SpeciesNames.FindTagId(PlayerRecords[i].Species.default.SpeciesName);
			if (j >= 0 && BotList[j] == None)
				BotList[j] = new(None) class'SortedStringArray';

			// Add the player record to the BotList
			BotList[j].Add(PlayerRecords[i].DefaultName, PlayerRecords[i].DefaultName);
		}
	}

	bInMatch = Level.Game.IsInState('MatchInProgress');

	if (Request.GetVariable("addbotnum", "") != "")
	{
		BotCount = int(Request.GetVariable("addnum", "0"));
		if (Request.GetVariable("BotAction", "") ~= "Add")
		{
			maxbots = 32-(DM.NumPlayers + DM.NumBots);

			BotCount = Clamp(BotCount, 0, maxbots);
			for (i=0;i<BotCount; i++)
				DM.ForceAddBot();

			// Save the change
			if (BotCount == 0)
				StatusError(Response, "0" @ Repl(BotStatus, "%Action%", Added));

			else if (BotCount == 1)
				StatusOk(Response, "1" @ Repl(SingleBotStatus, "%Action%", Added));

			else
				StatusOk(Response, BotCount @ Repl(BotStatus, "%Action%", Added));
		}

		else if (Request.GetVariable("BotAction", "") ~= "Remove")
		{
			BotCount = Clamp(BotCount, 0, DM.NumBots);

			DM.MinPlayers = DM.NumPlayers + DM.NumBots - BotCount;
			if (BotCount == 0)
				StatusError(Response, "0" @ Repl(BotStatus, "%Action%", Removed));

			else if (BotCount == 1)
				StatusOk(Response, "1" @ Repl(SingleBotStatus, "%Action%", Removed));

			else
				StatusOk(Response, BotCount@Repl(BotStatus, "%Action%", Removed));
		}
	}
	else if (Request.GetVariable("selectbots", "") != "" && bInMatch)
	{
		// Read as many bot infos as available
		for (i = 0; i<SpeciesNames.Count(); i++)
		{
			for (j = 0; j<BotList[i].Count(); j++)
			{
				oldstate = Request.GetVariable("BotX"$i$"."$j, "") != "";
				newstate = Request.GetVariable("Bot"$i$"."$j, "") != "";
				BotName = BotList[i].GetItem(j);
				if (oldstate != newstate)
				{
					if (oldstate)	// remove the bot
					{
						B = FindPlayingBot(BotName);
						if (B != None)
						{
							DM.MinPlayers = DM.NumPlayers + DM.NumBots - 1;
							B.Destroy();
						}
					}
					else
					{
						DM.MinPlayers = DM.NumPlayers + DM.NumBots;
						DM.AddNamedBot(BotName);
					}
				}
			}
		}
	}

	// Build our BotList
	if (SpeciesNames != None)
	{
		BotCount = 0;
		for ( i = 0; i < SpeciesNames.Count(); i++ )
			BotCount += BotList[i].Count();

		for (i = 0; i<SpeciesNames.Count(); i++)
		{
			OutStr = "";
			Response.Subst("SpeciesName", SpeciesNames.GetItem(i));
			OutStr = WebInclude(CurrentBotsPage$"_species");
			for (j = 0; j<BotList[i].Count(); j++)
			{
				Response.Subst("BotChecked", "");
				Response.Subst("BotIndex", String(i)$"."$String(j));
				Response.Subst("BotName", BotList[i].GetItem(j));
				B = FindPlayingBot(BotList[i].GetItem(j));

				Response.Subst("DisabledBots", "");
				if (!bInMatch)
					Response.Subst("DisabledBots", " DISABLED");
				// The following are set only if bot is currently in the game
				if (B != None)
				{
					Response.Subst("BotColor", GetTeamColor(B.PlayerReplicationInfo.Team));
					Response.Subst("BotTeamName", GetTeamName(B.PlayerReplicationInfo.Team));
					OutStr $= WebInclude(CurrentBotsPage$"_row_sel");
				}

				else OutStr $= WebInclude(CurrentBotsPage$"_row");

			}

			Response.Subst("BotList", OutStr);

			// Attempt to balance the bot lists
			if ( cnt + BotList[i].Count() < BotCount / 2 )
			{
				// Fill the left list until it has more than half the total number of bots
				Col1Count = cnt + BotList[i].Count();
				LeftTable $= WebInclude(CurrentBotsPage $ "_species_group");
			}
			else
			{
				if ( cnt - Col1Count > Col1Count )
				{
					// Account for any species that contained a large number of bots by adding smaller
					// species to the first column
					Col1Count += Botlist[i].Count();
					LeftTable $= WebInclude(CurrentBotsPage $ "_species_group");
				}
				else RightTable $= WebInclude(CurrentBotsPage $ "_species_group");
			}
			cnt += BotList[i].Count();
		}
	}

	Response.Subst("LeftBotTable", LeftTable);
	Response.Subst("RightBotTable", RightTable);

	// If not in match, make sure that the bots selection button is disabled
	Response.Subst("DisabledBots", "");
	if (!bInMatch)
		Response.Subst("DisabledBots", " DISABLED");
	MapTitle(Response);
	Response.Subst("PageHelp", NoteBotsPage);
	Response.Subst("Section", CurrentLinks[4]);
	ShowPage(Response, CurrentBotsPage);
}

function xBot FindPlayingBot(string BotName) // Returns -1 on failure, or index for team/color
{
local Controller C;
local xBot B;

	for (C = Level.ControllerList; C != None; C = C.NextController)
	{
		B = xBot(C);
		if (B != None)
			if (B.PlayerReplicationInfo.PlayerName == BotName)
				return B;
	}
	return None;
}

function string GetTeamColor(TeamInfo Team)
{
	if (Team == None)
		return "";

	if (Team.TeamIndex < 4)
		return Team.ColorNames[Team.TeamIndex];

	return "#CCCCCC";
}

function string GetTeamName(TeamInfo Team)
{
	if (Team == None)
		return "";

	return Team.GetHumanReadableName();
}

defaultproperties
{
     CurrentIndexPage="current_menu"
     CurrentPlayersPage="current_players"
     CurrentGamePage="current_game"
     CurrentConsolePage="current_console"
     CurrentConsoleLogPage="current_console_log"
     CurrentConsoleSendPage="current_console_send"
     CurrentMutatorsPage="current_mutators"
     CurrentBotsPage="current_bots"
     CurrentRestartPage="current_restart"
     DefaultSendText="say "
     StatTable="current_game_stat_table"
     StatTableRow="current_game_stat_table_row"
     PlayerListHeader="current_players_list_head"
     PlayerListLinkedHeader="current_players_list_head_link"
     PlayerListMinPlayers="current_players_minp"
     ConsoleRefreshTag="<meta http-equiv="refresh" CONTENT="5; URL="
     MutatorTablePage="current_mutators_table"
     MutatorGroupTitle="current_mutators_group"
     MutatorGroupMember="current_mutators_group_row"
     BadGameType="Unsupported Game Type"
     CurrentLinks(0)="Current Game"
     CurrentLinks(1)="Player List"
     CurrentLinks(2)="Server Console"
     CurrentLinks(3)="Mutators"
     CurrentLinks(4)="Bots"
     CurrentLinks(5)="Restart Map"
     NoBotsTitle="Bots unavailable"
     KickButtonText(0)="Kick"
     KickButtonText(1)="Ban"
     KickButtonText(2)="Kick/Ban"
     NoPlayersConnected="** No Players Connected **"
     SelectedMutators="Selected Mutators"
     PickMutators="Select desired mutators"
     GameTypeUnsupported="The Game Type '%GameType%' does not use standard bots."
     NoBots="You cannot add bots while World Stats Logging is enabled."
     Added="added."
     Removed="removed."
     BotStatus="bots were %Action%"
     SingleBotStatus="bot was %Action%"
     ConsoleUserlist="Getting or setting admin accounts and groups is not allowed through the webadmin console.  This action has been logged."
     NoteGamePage="You can view and select maps from other gametypes by using the combo box.  Selecting maps from other gametypes will automatically switch the server to that gametype."
     NotePlayersPage="In order to see the global ID for connected players, change the value for bBanbyID in the [Engine.AccessControl] section of your ini to 'True'.  Bots cannot be banned."
     NoteConsolePage="You may communicate with the players in the game by entering text at the text box and clicking 'Send'.  You can also enter console commands to control the server.  Game messages are shown in the log window, with the exception of team messages."
     NoteMutatorsPage="Select which mutators you want to be used when you hit the Restart Server Link"
     NoteBotsPage="You may only add bots once the game has started.  Adding bots has an adverse effect on the MinPlayers setting, and may cause this value to change.  If stats are enabled, you may only add bots if bots are already in the game."
     DefaultPage="currentframe"
     Title="Current"
     NeededPrivs="X|K|M|Xs|Xc|Xp|Xi|Kp|Kb|Ko|Mb|Mt|Mm|Mu|Ma"
}
