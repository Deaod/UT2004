//==============================================================================
// Single Player Main Menu
//
// Written by Michiel Hendriks
// (c) 2003, 2004, Epic Games, Inc. All Rights Reserved
//==============================================================================
class UT2K4SP_Main extends UT2K4MainPage;

// Automated Controls
var automated GUIButton	btnBack, btnPlay, btnDetails;

// debug controlls
var automated GUIButton btnDebugExec;
var automated GUIEditBox edDebugExec;

// localized strings
var localized string PageCaption;
var localized string LoadedPageCaption; // used when a profile is loaded
var localized String LadderCompleteMsg;
var localized string msgFullTeamRequired;
/** random donation message */
var localized array<string> DonationMsg;

/** prefix for profile names */
var string ProfilePrefix;

var UT2K4SPTab_Profile tpProfile;
var UT2K4SPTab_Tutorials tpTutorials;
var UT2K4SPTab_Qualification tpQualification;
var UT2K4SPTab_TeamQualification tpTeamQualification;
var UT2K4SPTab_Ladder tpLadder;
var UT2K4SPTab_TeamManagement tpTeamManagement;


var UT2K4GameProfile GP;

/** various menu pages to open */
var string DetailsPage, InjuryPage, MessagePage, PictureMessagePage, HighScorePage;

/** the map to open when the game has been completed */
var string EndGameMap;

/** the pending active tab, will be activated after all tabs are added */
var GUITabPanel SetActiveTab;

/**
	the ladder with the currently selected match
	used for the "play" button in the team management window
*/
var UT2K4SPTab_LadderBase LastLadderPage;

var config bool bEnableTC;

// FIXME: set to false before shipping !!!
const SPDEBUGMODE = false;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
	t_Header.SetCaption(PageCaption);
	tpProfile = UT2K4SPTab_Profile(addTab(0, True));
	tpTutorials = UT2K4SPTab_Tutorials(addTab(2, False));
}

event HandleParameters(string Param1, string Param2)
{
	UpdateTabs();
	HandleGameProfile();
	if (SetActiveTab != none) c_Tabs.ActivateTab(SetActiveTab.MyButton, true);
}

function HandleGameProfile()
{
	local bool bDonation;
	bDonation = false;
	if (GP != none)
	{
		// we don't have a game-over state
		// sponsor will always invest up to 50 credits (entry fee of the first match)
		if (GP.Balance < GP.MinBalance)
		{
			GP.Balance = GP.MinBalance;
			if (InStr(GP.SpecialEvent, ";DONATION") < 0)
			{
				bDonation = true;
			}
		}

		if (GP.bInLadderGame && GP.bShowDetails && GP.lmdFreshInfo) // intro work-around
		{
			Controller.OpenMenu(DetailsPage);
		}
		if (GP.SpecialEvent != "" && GP.bInLadderGame)
		{
			HandleSpecialEvent(GP.SpecialEvent);
		}
		if (GP.LastInjured != -1)
		{
			Controller.OpenMenu(InjuryPage, string(GP.LastInjured));
			GP.LastInjured = -1;
		}
		GP.bInLadderGame = false;
		GP.bIsChallenge = false;
		if (bDonation) reportDonation();
	}
}

function bool InternalOnPreDraw(Canvas Canvas)
{
	local float XL,YL;
	if (btnDetails.bVisible) btnDetails.Style.TextSize(Canvas, btnDetails.MenuState, btnDetails.Caption, XL, YL, btnDetails.FontScale);
		else btnPlay.Style.TextSize(Canvas, btnPlay.MenuState, btnPlay.Caption, XL, YL, btnPlay.FontScale);

	// Automatically size the buttons based on the size of their captions
	btnBack.WinWidth = XL+32;
	btnBack.WinLeft = Canvas.ClipX-btnBack.WinWidth;

	btnPlay.WinWidth = XL+32;
	btnPlay.WinLeft = btnBack.WinLeft-btnPlay.WinWidth;

	btnDetails.WinWidth = XL+32;
	btnDetails.WinLeft = btnPlay.WinLeft-btnDetails.WinWidth;

	return false;
}

/** BACK button clicked, ask what to do  */
function bool btnBackOnClick(GUIComponent Sender)
{
	if (c_Tabs.ActiveTab  != none)
	{
		if (UT2K4SPTab_Base(c_Tabs.ActiveTab.MyPanel) != none)
		{
			if (UT2K4SPTab_Base(c_Tabs.ActiveTab.MyPanel).onBackClick()) return true;
		}
	}
	if (OnCanClose(true)) Controller.CloseMenu(true);
	return true;
}

/** PLAY button clicked, ask what to do  */
function bool btnPlayOnClick(GUIComponent Sender)
{
	if (c_Tabs.ActiveTab == none) return false;
	if (UT2K4SPTab_Base(c_Tabs.ActiveTab.MyPanel) != none)
	{
		return UT2K4SPTab_Base(c_Tabs.ActiveTab.MyPanel).onPlayClick();
	}
	return false;
}

function bool btnDetailsOnClick(GUIComponent Sender)
{
	return Controller.OpenMenu(DetailsPage);
}

/**
	Clicked a TabButton
*/
function InternalOnChange(GUIComponent Sender)
{
	if (GUITabButton(Sender)==none)	return;
	if (GP == none) t_Header.SetCaption(PageCaption@"|"@GUITabButton(Sender).Caption);
		else t_Header.SetCaption(GP.PlayerName$LoadedPageCaption@"|"@GUITabButton(Sender).Caption);
}

/**
	Update tabs when a gameprofile is loaded
*/
function UpdateTabs(optional bool bPurge, optional bool bSetActive)
{
	local GUITabPanel tmp;
	// most of the time this function is called when a new GP has been loaded
	GP = UT2K4GameProfile(PlayerOwner().Level.Game.CurrentGameProfile);
	if ((GP == none) || (bPurge))
	{
		removeTab(tpQualification);
		removeTab(tpTeamQualification);
		removeTab(tpLadder);
		removeTab(tpTeamManagement);
		btnDetails.bVisible = false;
	}
	if (GP != none)
	{
		btnDetails.bVisible = (GP.lmdGameType != "");
		tmp = addTab(3, true);
		if (tmp != none) tpQualification = UT2K4SPTab_Qualification(tmp);
		// Team Qualification
		if (GP.LadderProgress[GP.UT2K4GameLadder.default.LID_TDM] != -1)
		{
			tmp = addTab(4, (GP.Balance > GP.MinBalance));
			if (tmp != none) tpTeamQualification = UT2K4SPTab_TeamQualification(tmp);
		}
		else {
			removeTab(tpTeamQualification);
		}
		// Main ladder
		if (GP.completedLadder(GP.UT2K4GameLadder.default.LID_TDM))
		{
			tmp = addTab(5, (GP.Balance > GP.MinBalance));
			if (tmp != none) tpLadder = UT2K4SPTab_Ladder(tmp);
		}
		else {
			removeTab(tpLadder);
		}
		// Team management
		if (GP.LadderProgress[GP.UT2K4GameLadder.default.LID_TDM] != -1)
		{
			tmp = addTab(6, false);
			if (tmp != none) tpTeamManagement = UT2K4SPTab_TeamManagement(tmp);
			if (!GP.completedLadder(GP.UT2K4GameLadder.default.LID_TDM))
			{
				if (tpTeamManagement != none) tpTeamManagement.LockManagementTools();
			}
		}
		else {
			if (tpTeamManagement != none)
			{
				if (!tpTeamManagement.bInitialDraft) removeTab(tpTeamManagement);
			}
			else removeTab(tpTeamManagement);
		}

		if (GP.bCompleted)
		{
			if (GP.UT2K4GameLadder.default.AdditionalLadders.length > 0) addTab(7, false);
		}
		else c_Tabs.RemoveTab(PanelCaption[7]);
	}
	if (SetActiveTab != none && bSetActive) c_Tabs.ActivateTab(SetActiveTab.MyButton, true);
}

/**
	Add a preconfigured tab
*/
function GUITabPanel addTab(int index, optional bool bActive)
{
	local GUITabPanel res;
	local int x;
	x = c_tabs.TabIndex(PanelCaption[index]);
	if (x > -1)
	{
		if (bActive) SetActiveTab = c_tabs.TabStack[x].MyPanel;
		return none;
	}
	res = c_Tabs.AddTab(PanelCaption[index], PanelClass[index], , PanelHint[index], false);
	if (bActive) SetActiveTab = res;
	if (UT2K4SPTab_Base(res) != none) UT2K4SPTab_Base(res).MainWindow = self;
	return res;
}

/**
	Replace an existing tab
*/
function GUITabPanel replaceTab(int index, GUITabPanel previousPage, optional bool bActive)
{
	local GUITabPanel res;
	res = c_Tabs.ReplaceTab(previousPage.MyButton, PanelCaption[index], PanelClass[index], , PanelHint[index], false);
	if (bActive) SetActiveTab = res;
	if (UT2K4SPTab_Base(res) != none) UT2K4SPTab_Base(res).MainWindow = self;
	return res;
}

/**
	Shorthand to remove a tab
*/
function removeTab(GUITabPanel tab)
{
	if (tab != none)
	{
		if (SetActiveTab == tab) SetActiveTab = none;
		c_Tabs.RemoveTab(, tab.MyButton);
		tab = none;
	}
}

/** handle special events, delimited by semi-colons */
function HandleSpecialEvent(string SpecialEvent)
{
	local array<string> Events, CurEvent;
	local int i, j;
	local array<ChallengeGame.TriString> ChalPages;

	if (GP == none) return;

	split(SpecialEvent, ";", Events);
	for (i = 0; i < Events.length; i++)
	{
		if (Events[i] == "") continue;
		split(Events[i], " ", CurEvent);
		if (CurEvent.length == 0) continue;
		if (SPDEBUGMODE) log("HandleSpecialEvent("@Events[i]@")", GP.LogPrefix);
		if (CurEvent[0] == "WELCOME")
		{
			Controller.OpenMenu(MessagePage, "0");
		}
		else if (CurEvent[0] == "DRAFT")
		{
			// check if we already have a team
			for (j = 0; j < GP.GetMaxTeamSize(); j++)
			{
				if (GP.PlayerTeam[j] == "") break;
			}
			// show team management window in draft mode;
			if (j != GP.GetMaxTeamSize())
			{
				tpTeamManagement = UT2K4SPTab_TeamManagement(replaceTab(6, tpQualification, true));
				tpTeamManagement.bInitialDraft = true;
				Controller.OpenMenu(MessagePage, "1");
			}
		}
		else if (CurEvent[0] == "QUALIFIED")
		{
			if (CurEvent[1] == "SINGLE")
			{
				Controller.OpenMenu(MessagePage, "2");
			}
			else if (CurEvent[1] == "TEAM")
			{
				Controller.OpenMenu(MessagePage, "3");
				class'UT2K4SPTab_Tutorials'.static.unlockButton("TDM");
				// won all matches up till now, add the secret Epic Phantom Team
				if (GP.Matches == GP.Wins) GP.GetTeamPosition("xGame.PhantomEpic", true);
			}
		}
		else if (CurEvent[0] == "OPEN") // open a ladder
		{
			j = -1;
			if (CurEvent[1] == "TDM") GP.enableLadder(GP.UT2K4GameLadder.default.LID_TDM);
			else if (CurEvent[1] == "CTF")
			{
				GP.enableLadder(GP.UT2K4GameLadder.default.LID_CTF);
				j = 4;
			}
			else if (CurEvent[1] == "BR")
			{
				GP.enableLadder(GP.UT2K4GameLadder.default.LID_BR);
				j = 5;
			}
			else if (CurEvent[1] == "DOM") GP.enableLadder(GP.UT2K4GameLadder.default.LID_DOM);
			else if (CurEvent[1] == "AS")
			{
				GP.enableLadder(GP.UT2K4GameLadder.default.LID_AS);
				j = 6;
			}
			else if (CurEvent[1] == "CHAMP")
			{
				GP.enableLadder(GP.UT2K4GameLadder.default.LID_CHAMP);
				// note: this will set the final team
				CurEvent[1] = GP.GetEnemyTeamName(GP.GetMatchInfo(GP.UT2K4GameLadder.default.LID_CHAMP, 0).EnemyTeamName);
				if (CurEvent[1] ~= "xGame.TeamThundercrash") j = 8;
				else if (CurEvent[1] ~= "xGame.TeamIronSkull") j = 7;
				else if (CurEvent[1] ~= "xGame.TeamCorrupt") j = 9;
			}
			else if (CurEvent[1] == "ALL") GP.enableLadder(-1); // all except championship
			UpdateTabs(true, true);
			if (j > -1) Controller.OpenMenu(MessagePage, string(j));
		}
		else if (CurEvent[0] == "COMPLETED") // open a ladder
		{
			class'UT2K4SPTab_Tutorials'.static.unlockButton(CurEvent[1]);
			if (CurEvent[1] == "CHAMP")
			{
				// What's up with this Mr.Crow crazyness
				if (GP.PlayerCharacter ~= "Mr.Crow")
				{
					bEnableTC = true;
					SaveConfig();
				}

				GP.bInLadderGame = true;  // return to display hiscore
				if (!GP.bCompleted)
				{
					GP.SpecialEvent = "SHOWSCORE"@string(DoHighScore());
				}
				GP.bCompleted = true;
				PlayerOwner().Level.Game.SavePackage(GP.PackageName);
				if (EndGameMap != "")
				{
					Log("Starting endgame movie", GP.LogPrefix);
					bAllowedAsLast = true; // workaround, or else the main window will pop up
					Console(Controller.Master.Console).DelayedConsoleCommand("START "$EndGameMap$"?quickstart=true?TeamScreen=false?savegame="$GP.PackageName);
					//PlayerOwner().ConsoleCommand("START "$EndGameMap$"?quickstart=true?TeamScreen=false?savegame="$GP.PackageName, true);
					Controller.CloseAll(false,true);
					return;
				}
				else {
					Controller.OpenMenu(MessagePage, "10");
				}
			}
			else {
				/*
				if (CurEvent[1] == "CTF")
					Controller.OpenMenu(PictureMessagePage, GP.GetLadderDescription(GP.UT2K4GameLadder.default.LID_CTF)@LadderCompleteMsg, "LadderShots.CTFMoneyShot");
				else if (CurEvent[1] == "BR")
					Controller.OpenMenu(PictureMessagePage, GP.GetLadderDescription(GP.UT2K4GameLadder.default.LID_BR)@LadderCompleteMsg, "LadderShots.BRMoneyShot");
				else if (CurEvent[1] == "DOM")
					Controller.OpenMenu(PictureMessagePage, GP.GetLadderDescription(GP.UT2K4GameLadder.default.LID_DOM)@LadderCompleteMsg, "LadderShots.DOMMoneyShot");
				else if (CurEvent[1] == "AS") // TODO: Assult image
					Controller.OpenMenu(PictureMessagePage, GP.GetLadderDescription(GP.UT2K4GameLadder.default.LID_AS)@LadderCompleteMsg, "LadderShots.TeamDMMoneyShot");
				*/

				if (GP.openChampionshipLadder())
				{
					Log("Opening championship ladder", GP.LogPrefix);
					HandleSpecialEvent("OPEN CHAMP");
				}
			}
		}
		else if (CurEvent[0] == "BALANCE") // update balance
		{
			GP.Balance += int(CurEvent[1]);
		}
		else if (CurEvent[0] == "UPDATETEAMS") // find "free agent" teams
		{
			UpdateFreeAgentTeams();
		}
		else if (CurEvent[0] == "SHOWSCORE")
		{
			Controller.OpenMenu(HighScorePage, CurEvent[1]);
		}
		// challenge team game
		else if (CurEvent[0] == "CHALLENGE")
		{
			Controller.OpenMenu(GP.GetChallengeGame(CurEvent[2]).default.ChallengeMenu, CurEvent[1], "true");
		}
		else if (CurEvent[0] == "DONATION")
		{
			reportDonation();
		}


		// debug commands --
		else if (CurEvent[0] == "DEBUG" && SPDEBUGMODE)
		{
			if (CurEvent[1] == "UPDATETABS") UpdateTabs(true);
			else if (CurEvent[1] == "SETLADDER") GP.LadderProgress[int(CurEvent[2])] = int(CurEvent[3]);
			else if (CurEvent[1] == "INLADDERGAME") GP.bInLadderGame = true;
			else if (CurEvent[1] == "INJURY") Controller.OpenMenu("GUI2K4.UT2K4SP_Injury", CurEvent[2]);
			else if (CurEvent[1] == "HEALTH") GP.BotStats[int(CurEvent[2])].Health = byte(CurEvent[3]);
			else if (CurEvent[1] == "ALTPATH")
			{
				if (CurEvent.length <= 2) GP.AltPath = rand(MaxInt); else GP.AltPath = int(CurEvent[2]);
			}
			else if (CurEvent[1] == "DUMP")
			{
				if (CurEvent[2]== "BOTSTATS")
				{
					for (j = 0; j < GP.BotStats.Length; j++)
					{
						Log("::"@j@GP.BotStats[j].Name@GP.BotStats[j].Price@GP.BotStats[j].Health@GP.BotStats[j].FreeAgent@GP.BotStats[j].TeamId, GP.LogPrefix);
					}
				}
				else if (CurEvent[2]== "TEAMSTATS")
				{
					for (j = 0; j < GP.TeamStats.Length; j++)
					{
						Log("::"@j@GP.TeamStats[j].Name@GP.TeamStats[j].Level@GP.TeamStats[j].Matches@GP.TeamStats[j].Won@GP.TeamStats[j].Rating);
					}
				}
			}
			else if (CurEvent[1] == "MESG") Controller.OpenMenu(MessagePage, CurEvent[2]);
			else if (CurEvent[1] == "NCOMPL")
			{
				GP.bCompleted = false;
				GP.LadderProgress[6] = 1;
			}
			else if (CurEvent[1] == "ON") GP.bDebug = true;
			else if (CurEvent[1] == "OFF") GP.bDebug = false;
		}
		// -- debug commands
		else if (GP.lmdbChallengeGame && GP.ChallengeGameClass != none)
		{
			ChalPages.length = 0;
			GP.ChallengeGameClass.static.HandleSpecialEvent(GP, CurEvent, ChalPages);
			for (j = 0; j < ChalPages.length; j++)
			{
				Controller.OpenMenu(ChalPages[j].GUIPage, ChalPages[j].Param1, ChalPages[j].Param2);
			}
		}
		else if (GP.LastCustomCladder != none)
		{
			ChalPages.length = 0;
			GP.LastCustomCladder.static.HandleSpecialEvent(GP, CurEvent, ChalPages);
			for (j = 0; j < ChalPages.length; j++)
			{
				Controller.OpenMenu(ChalPages[j].GUIPage, ChalPages[j].Param1, ChalPages[j].Param2);
			}
		}
		else Log("Unknown special event: '"$Events[i]$"'", GP.LogPrefix);
	}
}

/** parse match requirement string, returns false when a single requirement is not met */
function bool HandleRequirements(string reqstring)
{
	local array<string> reqs, curreq;
	local int i, j;
	local array<ChallengeGame.TriString> ChalPages;
	local bool tempres;

	if (GP == none) return false;
	if (reqstring == "") return true;
	split(reqstring, ";", reqs);
	for (i = 0; i < reqs.length; i++)
	{
		if (split(reqs[i], " ", curreq) == 0) continue;
		if (curreq[0] == "FULLTEAM")
		{
			if (!GP.HasFullTeam())
			{
				Log("Failed requirement: FULLTEAM", GP.LogPrefix);
				if (GP.completedLadder(GP.UT2K4GameLadder.default.LID_DM))
				{
					if (c_Tabs.ActiveTab != tpTeamManagement.MyButton)
						c_Tabs.ActivateTab(tpTeamManagement.MyButton, true);
				}
				else {
					if (c_Tabs.ActiveTab.MyPanel != tpTeamManagement)
					{
						tpTeamManagement = UT2K4SPTab_TeamManagement(replaceTab(6, tpQualification, true));
						tpTeamManagement.bInitialDraft = true;
						c_Tabs.ActivateTab(tpTeamManagement.MyButton, true);
					}
				}
				Controller.ShowQuestionDialog(msgFullTeamRequired);
				return false;
			}
		}


		// we assume that these vars have been set before this method is called
		else if (GP.ChallengeGameClass != none)
		{
			ChalPages.length = 0;
			tempres = GP.ChallengeGameClass.static.HandleRequirements(GP, curreq, ChalPages);
			for (j = 0; j < ChalPages.length; j++)
			{
				Controller.OpenMenu(ChalPages[j].GUIPage, ChalPages[j].Param1, ChalPages[j].Param2);
			}
			if (!tempres)
			{
				Log("Failed requirement:"@curreq[0], GP.LogPrefix);
				return false;
			}
		}
		else if (GP.LastCustomCladder != none)
		{
			ChalPages.length = 0;
			tempres = GP.LastCustomCladder.static.HandleRequirements(GP, curreq, ChalPages);
			for (j = 0; j < ChalPages.length; j++)
			{
				Controller.OpenMenu(ChalPages[j].GUIPage, ChalPages[j].Param1, ChalPages[j].Param2);
			}
			if (!tempres)
			{
				Log("Failed requirement:"@curreq[0], GP.LogPrefix);
				return false;
			}
		}
		else Log("Unknown special event:"@reqs[i], GP.LogPrefix);
	}
	return true;
}

function bool btnDebugExecOnClick(GUIComponent Sender)
{
	if (!SPDEBUGMODE) return false;
	HandleSpecialEvent(Caps(edDebugExec.GetText()));
	edDebugExec.SetText("");
	return true;
}

/** calculate which bots are available to be hired */
function UpdateFreeAgentTeams()
{
	local array<string> groups, teams, tmp;
	local array<int> freegroups, freeteams;
	local class<UT2K4RosterGroup> rgp;
	local int i, j, k, teamid;

	// gather groups and team;
	for (i = GP.UT2K4GameLadder.default.LID_TDM; i < GP.UT2K4GameLadder.default.LID_CHAMP; i++)
	{
		for (j = 0; j < GP.LengthOfLadder(i); j++)
		{
			Split(GP.GetMatchInfo(i, j).EnemyTeamName, ";", tmp);
			if (tmp.length > 1)
			{
				for (k = 0; k < groups.length; k++)
				{
					if (groups[k] ~= tmp[1]) break;
				}
				if (k == groups.length)
				{
					groups.length = k+1;
					groups[k] = tmp[1];
					freegroups.length = k+1;
					freegroups[k] = 1;
				}
				if (GP.LadderProgress[i] <= j)
				{
					freegroups[k] = 0;
				}
			}
			else {
				for (k = 0; k < teams.length; k++)
				{
					if (teams[k] ~= tmp[0]) break;
				}
				if (k == teams.length)
				{
					teams.length = k+1;
					teams[k] = tmp[0];
					freeteams.length = k+1;
					freeteams[k] = 1;
				}
				if (GP.LadderProgress[i] <= j)
				{
					freeteams[k] = 0;
				}
			}
		}
	}
	// merge groups with teams
	for (i = 0; i < groups.length; i++)
	{
		if (freegroups[i] > 0)
		{
			rgp = class<UT2K4RosterGroup>(DynamicLoadObject(groups[i], class'Class'));
			if (rgp == none) continue;
			for (j = 0; j < rgp.default.Rosters.length; j++)
			{
				for (k = 0; k < teams.length; k++)
				{
					if (teams[k] ~= rgp.default.Rosters[j]) break;
				}
				if (k == teams.length)
				{
					teams.length = k+1;
					teams[k] = rgp.default.Rosters[j];
					freeteams.length = k+1;
					freeteams[k] = 1;
				}
			}
		}
	}
	// we now have all free teams, flag all bots
	for (i = 0; i < teams.length; i++)
	{
		teamid = GP.GetTeamPosition(teams[i]);
		if (teamid != -1)
		{
			for (j = 0; j < GP.BotStats.length; j++)
			{
				if (GP.BotStats[j].TeamId == teamid) GP.BotStats[j].FreeAgent = (freeteams[i] > 0) && (!GP.IsTeammate(GP.BotStats[j].Name));
			}
		}
	}
}

/** Add the current profile to the highscore */
function int DoHighScore()
{
	local SPHighScore HS;
	local int res;

	if (GP == none)
	{
		Warn("GP == none");
		return -1;
	}
	HS = PlayerOwner().Level.Game.LoadDataObject(class'GUI2K4.SPHighScore', "SPHighScore", HighScoreFile);
	if (HS == none)
	{
		Log("UT2K4SP_Main - UT2004HighScores doesn't exist, creating...", GP.LogPrefix);
		HS = PlayerOwner().Level.Game.CreateDataObject(class'GUI2K4.SPHighScore', "SPHighScore", HighScoreFile);
	}
	res = HS.AddHighScore(GP);

	HS.CharUnlocked = ProfileUnlockChar;

	// unlock chars, only when the player made the highscores
	if ((res > -1) && !GP.isCheater() && !GP.isLocked() || SPDEBUGMODE)
	{
		if (GP.FinalEnemyTeam ~= "xGame.TeamThundercrash") HS.UnlockChar("MALCOLM", PlayerOwner().GetPlayerIDHash());
		else if (GP.FinalEnemyTeam ~= "xGame.TeamIronSkull") HS.UnlockChar("CLANLORD", PlayerOwner().GetPlayerIDHash());
		else if (GP.FinalEnemyTeam ~= "xGame.TeamCorrupt") HS.UnlockChar("XAN", PlayerOwner().GetPlayerIDHash());
		else Log("Unknown final team:"@GP.FinalEnemyTeam, GP.LogPrefix);
	}
	HS.CharUnlocked = none;
	PlayerOwner().Level.Game.SavePackage(HighScoreFile);
	return res;
}

function bool InternalOnCanClose(optional Bool bCancelled)
{
	local int i;
	for (i = 0; i < c_Tabs.TabStack.length; i ++)
	{
		if (UT2K4SPTab_Base(c_Tabs.TabStack[i].MyPanel) != none)
		{
			if (!UT2K4SPTab_Base(c_Tabs.TabStack[i].MyPanel).CanClose(bCancelled)) return false;
		}
	}
	return true;
}

function ProfileUnlockChar( string Char )
{
	if ( Char == "" )
		return;

	UnlockCharacter(Char);
}

function thisOnReOpen()
{
	if (LastLadderPage != none)
	{
		if (c_Tabs.ActiveTab.MyPanel != LastLadderPage) return;
		LastLadderPage.UpdateBalance();
		if (LastLadderPage.SelectedMatch != none)
			LastLadderPage.showMatchDetails(LastLadderPage.SelectedMatch.MatchInfo);
	}
}

function reportDonation()
{
	Controller.ShowQuestionDialog(DonationMsg[rand(DonationMsg.length)]);
}

defaultproperties
{
     Begin Object Class=GUIButton Name=SPbtnBack
         Caption="BACK"
         StyleName="FooterButton"
         Hint="Return to Previous Menu"
         WinTop=0.959479
         WinWidth=0.120000
         WinHeight=0.040703
         RenderWeight=1.000000
         TabOrder=2
         bBoundToParent=True
         OnClick=UT2K4SP_Main.btnBackOnClick
         OnKeyEvent=SPbtnBack.InternalOnKeyEvent
     End Object
     btnBack=GUIButton'GUI2K4.UT2K4SP_Main.SPbtnBack'

     Begin Object Class=GUIButton Name=SPbtnPlay
         Caption="PLAY"
         StyleName="FooterButton"
         Hint="Continue this tournament"
         WinTop=0.959479
         WinLeft=0.880000
         WinWidth=0.120000
         WinHeight=0.040703
         RenderWeight=1.000000
         TabOrder=1
         bBoundToParent=True
         OnClick=UT2K4SP_Main.btnPlayOnClick
         OnKeyEvent=SPbtnPlay.InternalOnKeyEvent
     End Object
     btnPlay=GUIButton'GUI2K4.UT2K4SP_Main.SPbtnPlay'

     Begin Object Class=GUIButton Name=SPbtnDetails
         Caption="DETAILS"
         StyleName="FooterButton"
         Hint="Show profile details"
         WinTop=0.959479
         WinLeft=0.760000
         WinWidth=0.120000
         WinHeight=0.040703
         RenderWeight=1.000000
         TabOrder=0
         bBoundToParent=True
         bVisible=False
         OnClick=UT2K4SP_Main.btnDetailsOnClick
         OnKeyEvent=SPbtnDetails.InternalOnKeyEvent
     End Object
     btnDetails=GUIButton'GUI2K4.UT2K4SP_Main.SPbtnDetails'

     Begin Object Class=GUIButton Name=SPbtnDebugExec
         Caption="EXEC"
         Hint="Execute special event"
         WinTop=0.959479
         WinLeft=0.300000
         WinWidth=0.120000
         WinHeight=0.033203
         RenderWeight=1.000000
         TabOrder=4
         bVisible=False
         OnClick=UT2K4SP_Main.btnDebugExecOnClick
         OnKeyEvent=SPbtnDebugExec.InternalOnKeyEvent
     End Object
     btnDebugExec=GUIButton'GUI2K4.UT2K4SP_Main.SPbtnDebugExec'

     Begin Object Class=GUIEditBox Name=SPedDebugExec
         WinTop=0.966146
         WinWidth=0.300000
         WinHeight=0.033203
         RenderWeight=1.000000
         TabOrder=3
         bVisible=False
         OnActivate=SPedDebugExec.InternalActivate
         OnDeActivate=SPedDebugExec.InternalDeactivate
         OnKeyType=SPedDebugExec.InternalOnKeyType
         OnKeyEvent=SPedDebugExec.InternalOnKeyEvent
     End Object
     edDebugExec=GUIEditBox'GUI2K4.UT2K4SP_Main.SPedDebugExec'

     PageCaption="Tournament"
     LoadedPageCaption="'s Tournament"
     LadderCompleteMsg="completed"
     msgFullTeamRequired="A full team is required to play this match."
     DonationMsg(0)="You were almost broke, but an anonymous benefactor donated some credits so you can continue your tournament."
     DonationMsg(1)="A fan saved you from going bankrupt, you can now continue with the tournament."
     ProfilePrefix="SP_"
     DetailsPage="GUI2K4.UT2K4SP_Details"
     InjuryPage="GUI2K4.UT2K4SP_Injury"
     MessagePage="GUI2K4.UT2K4SP_Message"
     PictureMessagePage="GUI2K4.UT2K4SP_PictureMessage"
     HighScorePage="GUI2K4.UT2K4SP_HighScores"
     EndGameMap="endgame"
     Begin Object Class=GUIHeader Name=SPhdrHeader
         RenderWeight=0.100000
     End Object
     t_Header=GUIHeader'GUI2K4.UT2K4SP_Main.SPhdrHeader'

     Begin Object Class=ButtonFooter Name=SPftrFooter
         RenderWeight=0.100000
         OnPreDraw=SPftrFooter.InternalOnPreDraw
     End Object
     t_Footer=ButtonFooter'GUI2K4.UT2K4SP_Main.SPftrFooter'

     PanelClass(0)="GUI2K4.UT2K4SPTab_Profile"
     PanelClass(1)="GUI2K4.UT2K4SPTab_ProfileNew"
     PanelClass(2)="GUI2K4.UT2K4SPTab_Tutorials"
     PanelClass(3)="GUI2K4.UT2K4SPTab_Qualification"
     PanelClass(4)="GUI2K4.UT2K4SPTab_TeamQualification"
     PanelClass(5)="GUI2K4.UT2K4SPTab_Ladder"
     PanelClass(6)="GUI2K4.UT2K4SPTab_TeamManagement"
     PanelClass(7)="GUI2K4.UT2K4SPTab_ExtraLadder"
     PanelCaption(0)="Profile"
     PanelCaption(1)="New profile"
     PanelCaption(2)="Tutorials"
     PanelCaption(3)="Qualification"
     PanelCaption(4)="Team Qualification"
     PanelCaption(5)="Ladder"
     PanelCaption(6)="Team Management"
     PanelCaption(7)="Additional"
     PanelHint(0)="Manage your profiles"
     PanelHint(1)="Create a new profile"
     PanelHint(2)="Gametype tutorials"
     PanelHint(3)="Qualify to enter the tournament"
     PanelHint(4)="Qualify your team to enter the tournament"
     PanelHint(5)="The tournament ladder"
     PanelHint(6)="Manage your team"
     PanelHint(7)="Additional ladders"
     bPersistent=False
     OnReOpen=UT2K4SP_Main.thisOnReOpen
     OnCanClose=UT2K4SP_Main.InternalOnCanClose
     bDrawFocusedLast=False
     OnPreDraw=UT2K4SP_Main.InternalOnPreDraw
}
