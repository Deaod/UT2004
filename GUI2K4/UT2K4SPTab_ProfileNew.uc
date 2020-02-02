//==============================================================================
// Create a new single player profile
//
// Written by Michiel Hendriks
// (c) 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4SPTab_ProfileNew extends UT2K4SPTab_Base;

var automated GUISectionBackground sbEditBg, sbPortraitBack, sbSponsorBack;
var automated GUIButton btnPrevSkin, btnNextSkin, btnPrevSponsor, btnNextSponsor;
var automated moEditBox edName, edTeam;
var automated moComboBox cbDifficulty;
var automated GUICharacterListTeam clPlayerSkins;
var automated GUIImageList ilSponsor;

var	localized string DefaultTeamName;
var string DefaultCharacter, TeamSponsorPrefix;
var int DefaultDifficulty, DefaultTeamSponsor;

/** more agents to add to the free agent pool */
var array<string> InitialFreeAgents;

/**
	The URL to visit after a profile has been created, the profile name will be appended to the end
*/
var string GameIntroURL;

var localized string ErrorProfileExists, ErrorCantCreateProfile;
var() localized string    DifficultyLevels[8];

function InitComponent(GUIController pMyController, GUIComponent MyOwner)
{
	local int i;
	Super.Initcomponent(pMyController, MyOwner);
	edName.MyEditBox.MaxWidth=16;  // as per polge, check UT2K4Tab_PlayerSettings if you change this
	edName.MyEditBox.AllowedCharSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_";

	clPlayerSkins.InitListInclusive("SP");

	for(i = 0; i < 8; i++)
		cbDifficulty.AddItem(DifficultyLevels[i]);

	LoadSponsorSymbols();
	ResetValues();
}

function ShowPanel(bool bShow)
{
	Super.ShowPanel(bShow);
	if (bShow)
	{
		MainWindow.btnPlay.Caption = CaptionCreate;
		MainWindow.btnBack.Caption = CaptionCancel;

		btnPlayEnabled(true);
	}
	else {
		MainWindow.btnPlay.Caption = CaptionPlay;
		MainWindow.btnBack.Caption = CaptionBack;
	}
}

/**
	Create the profile and load it
*/
function bool onPlayClick()
{
	local array<string> ExistingProfiles;
	local string ProfileName;
	local int i;
	local GUIQuestionPage QPage;

	ProfileName = MainWindow.ProfilePrefix$edName.GetText();
	// test for existing record
	Controller.GetProfileList(MainWindow.ProfilePrefix, ExistingProfiles);
	for (i = 0; i < ExistingProfiles.length; i++)
	{
		if (ExistingProfiles[i] ~= ProfileName)
		{
			if (Controller.OpenMenu(Controller.QuestionMenuClass))
			{
				QPage = GUIQuestionPage(Controller.ActivePage);
				QPage.SetupQuestion(QPage.Replace(ErrorProfileExists, "profile", edName.GetText()), QBTN_Ok, QBTN_Ok); // no prefix
			}
			SetFocus(edName);
			return true;
		}
	}
	GP = PlayerOwner().Level.Game.CreateDataObject(ProfileClass, "GameProfile", ProfileName);
	if ( GP != none )
	{
		GP.CreateProfile(PlayerOwner());
		GP.PlayerName = edName.GetText();
		GP.TeamName = edTeam.GetText();
		GP.TeamSymbolName = String(ilSponsor.Image);
		GP.PlayerCharacter = clPlayerSkins.GetName();
		AddDefaultBots(GP);
		AddDefaultTeams(GP);
		GP.BaseDifficulty = cbDifficulty.GetIndex();
		// set difficulty variables
		GP.InjuryChance = GP.InjuryChance+(GP.BaseDifficulty/30);
		GP.ChallengeChance = GP.ChallengeChance+(GP.BaseDifficulty/30);
		GP.FeeIncrease = GP.FeeIncrease+(GP.BaseDifficulty/300);
		GP.TeamPercentage = GP.TeamPercentage+(GP.BaseDifficulty/30);
		GP.MatchBonus = GP.MatchBonus+(GP.TeamPercentage/10);
		GP.InjuryTreatment = GP.InjuryTreatment+(GP.BaseDifficulty / 50);
		GP.MapChallengeCost = GP.MapChallengeCost+(GP.BaseDifficulty / 100);
		GP.AltPath = rand(MaxInt);
		PlayerOwner().Level.Game.CurrentGameProfile = GP;
		GP.Initialize(PlayerOwner().Level.Game, ProfileName);
		GP.SpecialEvent = "WELCOME";
		PlayerOwner().Level.Game.CurrentGameProfile.bInLadderGame = true;  // so it'll reload into SP menus
		if (!PlayerOwner().Level.Game.SavePackage(ProfileName))
		{
			Warn("Couldn't save profile package");
		}

		// launch the game introduction
		PlayerOwner().ConsoleCommand("START"@GameIntroUrl$profilename);
		if (MainWindow != none) MainWindow.bAllowedAsLast = true; // workaround, or else the main window will pop up
		Controller.CloseAll(false,true);
	}
	else
	{
		Warn("Error creating profile");
		if (Controller.OpenMenu(Controller.QuestionMenuClass))
		{
			QPage = GUIQuestionPage(Controller.ActivePage);
			QPage.SetupQuestion(ErrorCantCreateProfile, QBTN_Ok, QBTN_Ok);
		}
		// restore old tab
		MainWindow.c_Tabs.ReplaceTab(MyButton, MainWindow.PanelCaption[0], MainWindow.PanelClass[0], , MainWindow.PanelHint[0], true);
		MainWindow.UpdateTabs();
		return true;
	}

	return true;
}

/**
	Go back to the main menu when there are not proflies
*/
function bool onBackClick()
{
	local array<string> profilenames;
	MainWindow.btnBack.Caption = CaptionBack;
	Controller.GetProfileList(MainWindow.ProfilePrefix, profilenames);
	if ( profilenames.Length == 0 )	Controller.CloseMenu();
	else MainWindow.c_Tabs.ReplaceTab(MyButton, MainWindow.PanelCaption[0], MainWindow.PanelClass[0], , MainWindow.PanelHint[0], true);
	return true;
}

/**
	Clear the input box when it has the default name
*/
function OnNameActivate()
{
	if (edName.GetText() == clPlayerSkins.GetName()) edName.SetText("");
}

/**
	Clear the input box when it has the default team name
*/
function OnTeamActivate()
{
	if (edTeam.GetText() == DefaultTeamName) edTeam.SetText("");
}

/**
	Check to see if we have an empty name
*/
function OnNameDeActivate()
{
	if ( edName.GetText() == "") edName.SetText(repl(clPlayerSkins.GetName(), ".", "_"));
	if ( edTeam.GetText() == "") edTeam.SetText(DefaultTeamName);
}

/**
	Disable "create" button when names are empty
*/
function onNameChange( GUIComponent Sender)
{
	btnPlayEnabled((edName.GetText() != "") && (edTeam.GetText() != ""));
}

/**
	Change the selected skin
*/
function bool onSelectSkin(GUIComponent Sender)
{
	local string prev;
	prev = repl(clPlayerSkins.GetName(), ".", "_");
	if ( Sender == btnPrevSkin )
	{
		clPlayerSkins.ScrollLeft();
	}
	else if ( Sender == btnNextSkin )
	{
		clPlayerSkins.ScrollRight();
	}
	if (edName.GetText() == prev) edName.SetText(repl(clPlayerSkins.GetName(), ".", "_"));
	return Super.OnClick(Sender);
}

/**
	Change the selected sponsor
*/
function bool onSelectSponsor(GUIComponent Sender)
{
	if ( Sender == btnPrevSponsor )
	{
		ilSponsor.PrevImage();
	}
	else if ( Sender == btnNextSponsor )
	{
		ilSponsor.NextImage();
	}
	return Super.OnClick(Sender);
}

/**
	Will reset all the settings to their initial value
*/
function ResetValues()
{
	local int i;
	edTeam.SetText(DefaultTeamName);
	cbDifficulty.SetIndex(DefaultDifficulty);
	clPlayerSkins.Find(DefaultCharacter);
	edName.SetText(clPlayerSkins.GetName());
	for (i = 0; i < ilSponsor.MatNames.Length; i++)
	{
		if (ilSponsor.MatNames[i] ~= "TeamSymbols_UT2004.Design1")
		{
			ilSponsor.SetIndex(i);
			break;
		}
	}
}

/**
	Add the default bots to the free agent list
*/
function AddDefaultBots(UT2K4GameProfile GP)
{
	local array<xUtil.PlayerRecord> FreeAgents;
	local int i;

	GP.BotStats.length = 0;
	class'xUtil'.static.GetPlayerList(FreeAgents);
	for (i = 0; i < FreeAgents.Length; i++)
	{
		if ((FreeAgents[i].Menu ~= "SP") &&
				((FreeAgents[i].species == class'xGame.SPECIES_Egypt') || (FreeAgents[i].species == class'xGame.SPECIES_Merc')))
		{
			if (FreeAgents[i].DefaultName ~= GP.PlayerCharacter) continue;
			GP.GetBotPosition(FreeAgents[i].DefaultName, true);
		}
	}
	for (i = 0; i < InitialFreeAgents.length; i++)
	{
		GP.GetBotPosition(InitialFreeAgents[i], true);
	}
}

/**
	Add the default teams to the list (the Phantom teams)
*/
function AddDefaultTeams(UT2K4GameProfile GP)
{
	local class<UT2K4RosterGroup> RGclass;
	local int i;

	RGclass = class<UT2K4RosterGroup>(DynamicLoadObject("xGame.UT2K4TeamRosterPhantom", class'Class'));
	for (i = 0; i < RGclass.default.Rosters.length; i++)
	{
		GP.GetTeamPosition(RGclass.default.Rosters[i], true);
	}
}

/**
	Loads all Sponsor symbols
*/
function LoadSponsorSymbols()
{
	local int i;
	local Material M;
	local array<string> SymbolNames;

	Controller.GetTeamSymbolList(SymbolNames, true);  // get all usable team symbols

	for (i = 0; i < SymbolNames.Length; i++)
	{
		M = Material(DynamicLoadObject(SymbolNames[i], class'Material'));
		ilSponsor.AddMaterial(SymbolNames[i], M);
	}
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=SPNimgEditBg
         Caption="Profile"
         WinTop=0.101463
         WinLeft=0.536263
         WinWidth=0.425171
         WinHeight=0.770000
         bBoundToParent=True
         OnPreDraw=SPNimgEditBg.InternalPreDraw
     End Object
     sbEditBg=GUISectionBackground'GUI2K4.UT2K4SPTab_ProfileNew.SPNimgEditBg'

     Begin Object Class=GUISectionBackground Name=SPNimgPortraitBack
         Caption="Portrait"
         WinTop=0.101463
         WinLeft=0.030428
         WinWidth=0.234133
         WinHeight=0.770000
         bBoundToParent=True
         OnPreDraw=SPNimgPortraitBack.InternalPreDraw
     End Object
     sbPortraitBack=GUISectionBackground'GUI2K4.UT2K4SPTab_ProfileNew.SPNimgPortraitBack'

     Begin Object Class=GUISectionBackground Name=SPNimgSponsorBack
         Caption="Team symbol"
         WinTop=0.101463
         WinLeft=0.273865
         WinWidth=0.253265
         WinHeight=0.770000
         bBoundToParent=True
         OnPreDraw=SPNimgSponsorBack.InternalPreDraw
     End Object
     sbSponsorBack=GUISectionBackground'GUI2K4.UT2K4SPTab_ProfileNew.SPNimgSponsorBack'

     Begin Object Class=GUIButton Name=SPNbtnPrevSkin
         StyleName="ArrowLeft"
         Hint="Selects a new appearance for your character"
         WinTop=0.733722
         WinLeft=0.060867
         WinWidth=0.048750
         WinHeight=0.080000
         TabOrder=5
         bBoundToParent=True
         bNeverFocus=True
         bRepeatClick=True
         OnClickSound=CS_Down
         OnClick=UT2K4SPTab_ProfileNew.onSelectSkin
         OnKeyEvent=SPNbtnPrevSkin.InternalOnKeyEvent
     End Object
     btnPrevSkin=GUIButton'GUI2K4.UT2K4SPTab_ProfileNew.SPNbtnPrevSkin'

     Begin Object Class=GUIButton Name=SPNbtnNextSkin
         StyleName="ArrowRight"
         Hint="Selects a new appearance for your character"
         WinTop=0.733722
         WinLeft=0.178054
         WinWidth=0.048750
         WinHeight=0.080000
         TabOrder=6
         bBoundToParent=True
         bNeverFocus=True
         bRepeatClick=True
         OnClickSound=CS_Up
         OnClick=UT2K4SPTab_ProfileNew.onSelectSkin
         OnKeyEvent=SPNbtnNextSkin.InternalOnKeyEvent
     End Object
     btnNextSkin=GUIButton'GUI2K4.UT2K4SPTab_ProfileNew.SPNbtnNextSkin'

     Begin Object Class=GUIButton Name=SPNbtnPrevSponsor
         StyleName="ArrowLeft"
         Hint="Selects a new symbol for your team"
         WinTop=0.733722
         WinLeft=0.311505
         WinWidth=0.048750
         WinHeight=0.080000
         TabOrder=8
         bBoundToParent=True
         bNeverFocus=True
         bRepeatClick=True
         OnClickSound=CS_Down
         OnClick=UT2K4SPTab_ProfileNew.onSelectSponsor
         OnKeyEvent=SPNbtnPrevSponsor.InternalOnKeyEvent
     End Object
     btnPrevSponsor=GUIButton'GUI2K4.UT2K4SPTab_ProfileNew.SPNbtnPrevSponsor'

     Begin Object Class=GUIButton Name=SPNbtnNextSponsor
         StyleName="ArrowRight"
         Hint="Selects a new symbol for your team"
         WinTop=0.733722
         WinLeft=0.433380
         WinWidth=0.055000
         WinHeight=0.080000
         TabOrder=9
         bBoundToParent=True
         bNeverFocus=True
         bRepeatClick=True
         OnClickSound=CS_Up
         OnClick=UT2K4SPTab_ProfileNew.onSelectSponsor
         OnKeyEvent=SPNbtnNextSponsor.InternalOnKeyEvent
     End Object
     btnNextSponsor=GUIButton'GUI2K4.UT2K4SPTab_ProfileNew.SPNbtnNextSponsor'

     Begin Object Class=moEditBox Name=SPNmeName
         bVerticalLayout=True
         Caption="Player Name: "
         OnCreateComponent=SPNmeName.InternalOnCreateComponent
         Hint="Your character's name"
         WinTop=0.286087
         WinLeft=0.572258
         WinWidth=0.345000
         WinHeight=0.122500
         TabOrder=1
         bBoundToParent=True
         OnActivate=UT2K4SPTab_ProfileNew.OnNameActivate
         OnDeActivate=UT2K4SPTab_ProfileNew.OnNameDeActivate
         OnChange=UT2K4SPTab_ProfileNew.onNameChange
     End Object
     edName=moEditBox'GUI2K4.UT2K4SPTab_ProfileNew.SPNmeName'

     Begin Object Class=moEditBox Name=SPNmeTeam
         bVerticalLayout=True
         Caption="Team Name: "
         OnCreateComponent=SPNmeTeam.InternalOnCreateComponent
         Hint="The name of your team"
         WinTop=0.428007
         WinLeft=0.572258
         WinWidth=0.345000
         WinHeight=0.122500
         TabOrder=2
         bBoundToParent=True
         OnActivate=UT2K4SPTab_ProfileNew.OnTeamActivate
         OnDeActivate=UT2K4SPTab_ProfileNew.OnNameDeActivate
         OnChange=UT2K4SPTab_ProfileNew.onNameChange
     End Object
     edTeam=moEditBox'GUI2K4.UT2K4SPTab_ProfileNew.SPNmeTeam'

     Begin Object Class=moComboBox Name=SPNmcDifficulty
         bReadOnly=True
         bVerticalLayout=True
         Caption="Difficulty: "
         OnCreateComponent=SPNmcDifficulty.InternalOnCreateComponent
         Hint="Customize your challenge"
         WinTop=0.568803
         WinLeft=0.572258
         WinWidth=0.345000
         WinHeight=0.068311
         TabOrder=3
         bBoundToParent=True
     End Object
     cbDifficulty=moComboBox'GUI2K4.UT2K4SPTab_ProfileNew.SPNmcDifficulty'

     Begin Object Class=GUICharacterListTeam Name=SPNclPlayerSkins
         FixedItemsPerPage=1
         StyleName="CharButton"
         Hint="Your character's appearance, use arrow keys to change"
         WinTop=0.191921
         WinLeft=0.048207
         WinWidth=0.199566
         WinHeight=0.500000
         TabOrder=0
         bBoundToParent=True
         OnClick=SPNclPlayerSkins.InternalOnClick
         OnRightClick=SPNclPlayerSkins.InternalOnRightClick
         OnMousePressed=SPNclPlayerSkins.InternalOnMousePressed
         OnMouseRelease=SPNclPlayerSkins.InternalOnMouseRelease
         OnKeyEvent=SPNclPlayerSkins.InternalOnKeyEvent
         OnBeginDrag=SPNclPlayerSkins.InternalOnBeginDrag
         OnEndDrag=SPNclPlayerSkins.InternalOnEndDrag
         OnDragDrop=SPNclPlayerSkins.InternalOnDragDrop
         OnDragEnter=SPNclPlayerSkins.InternalOnDragEnter
         OnDragLeave=SPNclPlayerSkins.InternalOnDragLeave
         OnDragOver=SPNclPlayerSkins.InternalOnDragOver
     End Object
     clPlayerSkins=GUICharacterListTeam'GUI2K4.UT2K4SPTab_ProfileNew.SPNclPlayerSkins'

     Begin Object Class=GUIImageList Name=SPNilSponsor
         bWrap=True
         ImageStyle=ISTY_Justified
         ImageRenderStyle=MSTY_Normal
         ImageAlign=IMGA_Center
         Hint="Your team's sponsor, use arrow keys to change"
         WinTop=0.189296
         WinLeft=0.304401
         WinWidth=0.185561
         WinHeight=0.506378
         TabOrder=7
         bBoundToParent=True
     End Object
     ilSponsor=GUIImageList'GUI2K4.UT2K4SPTab_ProfileNew.SPNilSponsor'

     DefaultTeamName="Team"
     DefaultCharacter="Jakob"
     TeamSponsorPrefix="TeamSymbols_UT2003.sym"
     DefaultDifficulty=2
     DefaultTeamSponsor=1
     InitialFreeAgents(0)="Hathor"
     InitialFreeAgents(1)="Huntress"
     InitialFreeAgents(2)="Sunspear"
     InitialFreeAgents(3)="Cipher"
     InitialFreeAgents(4)="Medusa"
     InitialFreeAgents(5)="Jackhammer"
     InitialFreeAgents(6)="Avarice"
     InitialFreeAgents(7)="Darkling"
     GameIntroURL="MOV-UT2004-Intro?quickstart=true?TeamScreen=False?savegame="
     ErrorProfileExists="Profile with name '%profile%' already exists!"
     ErrorCantCreateProfile="Profile creation failed."
     DifficultyLevels(0)="Novice"
     DifficultyLevels(1)="Average"
     DifficultyLevels(2)="Experienced"
     DifficultyLevels(3)="Skilled"
     DifficultyLevels(4)="Adept"
     DifficultyLevels(5)="Masterful"
     DifficultyLevels(6)="Inhuman"
     DifficultyLevels(7)="Godlike"
     PanelCaption="New profile"
}
