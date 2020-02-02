// ====================================================================
//  Class:  XInterface.UT2SinglePlayerMain
//  Parent: XInterface.GUIPage
//
//  <Enter a description here>
// ====================================================================

class UT2SinglePlayerMain extends UT2K3GUIPage;

#exec OBJ LOAD FILE=InterfaceContent.utx
#exec OBJ LOAD FILE=GameSounds.uax

var Tab_SPPanelBase TP_Profile, TP_Tutorials, TP_Qual, TP_Ladder, TP_Roster, TP_Play;

var GUIButton ButtonMenu, ButtonPlay;

var GUITabControl TabC;

var localized string	MessageLadderAvailable, MessageLadderComplete, MessageCreateProfileFirst;
var localized string	TabNameProfileNew, TabNameProfileLoad, TabNameQualification, TabNameLadder, TabNameRoster, TabNameTutorials;
var localized string	TabHintProfileNew, TabHintProfileLoad, TabHintQualification, TabHintLadder, TabHintRoster, TabHintTutorials;

var bool bFinishedPanels;		// to avoid creating roster at wrong time

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

	TabC = GUITabControl(Controls[0]);
	ButtonMenu = GUIButton(Controls[2]);
	ButtonPlay = GUIButton(Controls[3]);
	//ButtonPlay.MenuState = MSAT_Disabled;  // hide the play button until a profile is loaded

	GUITitleBar(Controls[4]).DockedTabs = TabC;

	TP_Profile = Tab_SPPanelBase(TabC.AddTab(TabNameProfileLoad,"xinterface.Tab_SPProfileLoad",,"",true));
	//TP_Profile.MyButton.Hint = TabHintProfileLoad;
	TP_Tutorials = Tab_SPPanelBase(TabC.AddTab(TabNameTutorials,"xinterface.Tab_SPTutorials",,""));
	TP_Tutorials.MyButton.Hint = TabHintTutorials;
	TP_Qual = Tab_SPPanelBase(TabC.AddTab(TabNameQualification,"xinterface.Tab_SPLadderQualify",,""));
	TP_Qual.MyButton.Hint = TabHintQualification;
	TP_Ladder = Tab_SPPanelBase(TabC.AddTab(TabNameLadder,"xinterface.Tab_SPLadderTeam",,""));
	TP_Ladder.MyButton.Hint = TabHintLadder;

	bFinishedPanels=true;
	ProfileUpdated();

	TabC.bDockPanels=true;

	TP_Qual.bAcceptsInput = false;
	TP_Ladder.bAcceptsInput = false;
	//TP_Roster.bAcceptsInput = false;
}

event HandleParameters(string Param1, string Param2)
{
	local GameProfile GP;

	Super.HandleParameters(Param1, Param2);

	GP = PlayerOwner().Level.Game.CurrentGameProfile;
	if ( GP != none )
	{
		TP_Qual.bAcceptsInput = true;  // anyone can access this menu
		if ( GP.LadderRung[1] >= 0 )
		{
			TP_Ladder.bAcceptsInput = true;
			//TP_Roster.bAcceptsInput = true;
			TabC.ActivateTab(TP_Ladder.MyButton, true);		// return to correct ladder
		}
		else
		{
			TabC.ActivateTab(TP_Qual.MyButton, true);	// return to correct ladder
		}

		if ( GP.SpecialEvent != "" )
		{
			HandleSpecialEvent(GP.SpecialEvent);
		}
	}

/*	mocombobox(Controls[5]).AddItem("DRAFT");
	mocombobox(Controls[5]).AddItem("TRADE Widowmaker");
	mocombobox(Controls[5]).AddItem("TRADE Syzygy");
	mocombobox(Controls[5]).AddItem("DM COMPLETE");
	mocombobox(Controls[5]).AddItem("TDM COMPLETE");
	mocombobox(Controls[5]).AddItem("CTF COMPLETE");
	mocombobox(Controls[5]).AddItem("DOM COMPLETE");
	mocombobox(Controls[5]).AddItem("BR COMPLETE");
	mocombobox(Controls[5]).AddItem("CHAMPIONSHIP COMPLETE");
	mocombobox(Controls[5]).AddItem("TDM OPENED");
	mocombobox(Controls[5]).AddItem("CTF OPENED");
	mocombobox(Controls[5]).AddItem("DOM OPENED");
	mocombobox(Controls[5]).AddItem("BR OPENED");
	mocombobox(Controls[5]).AddItem("CHAMPIONSHIP OPENED");
	mocombobox(Controls[5]).AddItem("TRADE 1");
	mocombobox(Controls[5]).OnChange=BoxChange;
	moComboBox(Controls[5]).ReadOnly(true);
	*/
}

function PopupButton(byte yButton) {
	PlayerOwner().Level.Game.CurrentGameProfile.SpecialEvent = "";
}


function HandleSpecialEvent(string SpecialEvent)
{
	local UT2SP_LadderEventPage LPage;
	local UT2SP_PlayerTradePage TPage;
	local string tmp;

	// handle special events
	Log("SINGLEPLAYER  UT2SinglePlayerMain detected special event of "$SpecialEvent);

	// clear this event from the gameprofile, if there is one
	if ( PlayerOwner().Level.Game.CurrentGameProfile != none )
	{
		PlayerOwner().Level.Game.CurrentGameProfile.SpecialEvent = "";
		PlayerOwner().Level.Game.SavePackage(PlayerOwner().Level.Game.CurrentGameProfile.PackageName);
	}

	//Messages are of the following form:
	//"DRAFT"  -- go to the draft menu
	//"XX COMPLETE" "XX OPENED"   -- open or complete a ladder

	if ( SpecialEvent == "DRAFT" )
	{
		//TabC.ActivateTab(TP_Roster.MyButton, true);  // so it'll be waiting for them
		Controller.OpenMenu("XInterface.UT2SP_DraftEventPage");
		LPage = UT2SP_LadderEventPage(Controller.ActivePage);
		LPage.gImage.Image = Material(DynamicLoadObject("Laddershots.TeamDMShot", class'Material', true));
	}
	else if ( InStr (SpecialEvent, "TRADE") >= 0 )
	{
		tmp = Mid ( SpecialEvent, 6, Len(SpecialEvent) );
		Controller.OpenMenu("XInterface.UT2SP_PlayerTradePage");
		TPage = UT2SP_PlayerTradePage(Controller.ActivePage);
		TPage.Initialize(tmp);
	}
	else if ( InStr (SpecialEvent, "COMPLETE") >= 0 )
	{
		if ( Left (SpecialEvent, 5) != "CHAMP" )
		{
			Controller.OpenMenu("XInterface.UT2SP_LadderEventPage");
			LPage = UT2SP_LadderEventPage(Controller.ActivePage);

			if ( Left (SpecialEvent, 3) == "TDM" )
			{
				class'Tab_SPTutorials'.default.bTDMUnlocked = true;
				class'Tab_SPTutorials'.static.StaticSaveConfig();
				LPage.lblCaption.Caption = class'xGame.xTeamgame'.default.GameName@MessageLadderComplete;
				LPage.gImage.Image = Material(DynamicLoadObject("Laddershots.TeamDMMoneyShot", class'Material', true));
				PlayerOwner().ClientPlaySound(Sound'GameSounds.OtherFanfares.LadderClosed',,,SLOT_Talk);
			}
			else if ( Left (SpecialEvent, 3) == "CTF" )
			{
				class'Tab_SPTutorials'.default.bCTFUnlocked = true;
				class'Tab_SPTutorials'.static.StaticSaveConfig();
				LPage.lblCaption.Caption = class'xGame.xCTFGame'.default.GameName@MessageLadderComplete;
				LPage.gImage.Image = Material(DynamicLoadObject("Laddershots.CTFMoneyShot", class'Material', true));
				PlayerOwner().ClientPlaySound(Sound'GameSounds.OtherFanfares.LadderClosed',,,SLOT_Talk);
			}
			else if ( Left (SpecialEvent, 3) == "DOM" )
			{
				class'Tab_SPTutorials'.default.bDOMUnlocked = true;
				class'Tab_SPTutorials'.static.StaticSaveConfig();
				LPage.lblCaption.Caption = class'xGame.xDoubleDom'.default.GameName@MessageLadderComplete;
				LPage.gImage.Image = Material(DynamicLoadObject("Laddershots.DOMMoneyShot", class'Material', true));
				PlayerOwner().ClientPlaySound(Sound'GameSounds.OtherFanfares.LadderClosed',,,SLOT_Talk);
			}
			else if ( Left (SpecialEvent, 2) == "BR" )
			{
				class'Tab_SPTutorials'.default.bBRUnlocked = true;
				class'Tab_SPTutorials'.static.StaticSaveConfig();
				LPage.lblCaption.Caption = class'xGame.xBombingRun'.default.GameName@MessageLadderComplete;
				LPage.gImage.Image = Material(DynamicLoadObject("Laddershots.BRMoneyShot", class'Material', true));
				PlayerOwner().ClientPlaySound(Sound'GameSounds.OtherFanfares.LadderClosed',,,SLOT_Talk);
			}
		}
		else //  if ( Left (SpecialEvent, 5) == "CHAMP" )
		{
			class'Tab_PlayerSettings'.default.bUnlocked = true;
			class'Tab_PlayerSettings'.static.StaticSaveConfig();
			bAllowedAsLast=true;
			PlayerOwner().Level.Game.CurrentGameProfile.bInLadderGame=false;  // don't want it to reload into SP menus
			PlayerOwner().ConsoleCommand ("START endgame.ut2?quickstart=true?TeamScreen=false?savegame="$PlayerOwner().Level.Game.CurrentGameProfile.PackageName);
			Controller.CloseAll(false);
		}
	}
	else if ( InStr (SpecialEvent, "OPENED") >= 0 )
	{

		Controller.OpenMenu("XInterface.UT2SP_LadderEventPage");
		LPage = UT2SP_LadderEventPage(Controller.ActivePage);
		PlayerOwner().ClientPlaySound(Sound'GameSounds.OtherFanfares.LadderOpened',,,SLOT_Talk);

		if ( Left (SpecialEvent, 3) == "TDM" )
		{
			LPage.lblCaption.Caption = class'xGame.xTeamgame'.default.GameName@MessageLadderAvailable;
			LPage.gImage.Image = Material(DynamicLoadObject("Laddershots.TeamDMShot", class'Material', true));
		}
		else if ( Left (SpecialEvent, 3) == "CTF" )
		{
			LPage.lblCaption.Caption = class'xGame.xCTFGame'.default.GameName@MessageLadderAvailable;
			LPage.SetTutorialName("TUT-CTF");
			LPage.gImage.Image = Material(DynamicLoadObject("Laddershots.CTFShot", class'Material', true));
		}
		else if ( Left (SpecialEvent, 3) == "DOM" )
		{
			LPage.lblCaption.Caption = class'xGame.xDoubleDom'.default.GameName@MessageLadderAvailable;
			LPage.SetTutorialName("TUT-DOM");
			LPage.gImage.Image = Material(DynamicLoadObject("Laddershots.DOMShot", class'Material', true));
		}
		else if ( Left (SpecialEvent, 2) == "BR" )
		{
			LPage.lblCaption.Caption = class'xGame.xBombingRun'.default.GameName@MessageLadderAvailable;
			LPage.SetTutorialName("TUT-BR");
			LPage.gImage.Image = Material(DynamicLoadObject("Laddershots.BRShot", class'Material', true));
		}
		else if ( Left (SpecialEvent, 5) == "CHAMP" )
		{
			LPage.lblCaption.Caption = class'xGame.BossDM'.default.GameName@MessageLadderAvailable;
			LPage.gImage.Image = Material(DynamicLoadObject("Laddershots.ChampionshipShot", class'Material', true));
		}
	}
}

event ChangeHint(string NewHint)
{
	GUITitleBar(Controls[1]).SetCaption(NewHint);
}

function bool ButtonClick(GUIComponent Sender) {
	local GameProfile GP;
	local LevelInfo myLevel;
	local GUIQuestionPage GPage;

	if ( Sender == ButtonMenu ) {
		Controller.CloseMenu();
	} else if ( Sender == ButtonPlay ) {
		GP = PlayerOwner().Level.Game.CurrentGameProfile;
		if ( GP != none ) {
			PlayerOwner().Level.Game.SavePackage(GP.PackageName);

			// check to see if player was supposed to have drafted a team, but was
			// somehow interrupted
			if (  ( GP.CurrentLadder > 0 || (GP.CurrentLadder == 0 && GP.CurrentMenuRung == 5) ) &&
				  ( GP.PlayerTeam[0] == "" ) )
			{
				HandleSpecialEvent("DRAFT");
				return true;
			}

			myLevel = PlayerOwner().Level;
			TabC.ActivateTab(TP_Ladder.MyButton, true);	// return to ladder
			Controller.CloseAll(false);
			GP.StartNewMatch ( GP.CurrentLadder, myLevel );
		} else {
			if (Controller.OpenMenu("XInterface.GUIQuestionPage"))
			{
				GPage=GUIQuestionPage(Controller.TopPage());
				GPage.SetupQuestion(MessageCreateProfileFirst, QBTN_Ok, QBTN_Ok);
			}
		}
	}
	return true;
}

function TabChange(GUIComponent Sender)
{
	if (GUITabButton(Sender)==none)
		return;

	ResetTitleBar(GUITabButton(Sender));

}

// called by Tab_SPPanelBase.ProfileUpdated()
function ResetTitleBar(GUITabButton TB)
{
	if ( PlayerOwner().Level.Game.CurrentGameProfile != none )
	{
		GUITitleBar(Controls[4]).SetCaption(GUITitleBar(default.Controls[4]).GetCaption()@"|"@
		PlayerOwner().Level.Game.CurrentGameProfile.PlayerName@"|"@TB.Caption);
	}
	else
		GUITitleBar(Controls[4]).SetCaption(GUITitleBar(default.Controls[4]).GetCaption()@"|"@TB.Caption);
}

function BoxChange(GUIComponent Sender)
{
	HandleSpecialEvent(mocombobox(Sender).GetText());
}

function PassThroughProfileUpdated()
{
	TP_Qual.ProfileUpdated();  // this will pass the call to all children
}

function ProfileUpdated()
{
	local GameProfile GP;
	local bool bRosterOn;

	if (TabC != none && TabC.ActiveTab != none)
		ResetTitleBar(TabC.ActiveTab);

	// make sure we don't accidentally create the Roster menu first and get it out of order
	if ( !bFinishedPanels )
	{
		return;
	}

	GP = PlayerOwner().Level.Game.CurrentGameProfile;

	if ( GP == none )
	{
		bRosterOn = false;
	}
	else
	{
		bRosterOn = ( GP.PlayerTeam[0] != "" );
	}

	if ( bRosterOn )
	{
		if ( TP_Roster == none )
		{
			TP_Roster = Tab_SPPanelBase(TabC.AddTab(TabNameRoster,"xinterface.Tab_SPRoster",,""));
			TP_Roster.MyButton.Hint = TabHintRoster;
		}
	}
	else
	{
		if ( TP_Roster != none )
		{
			TabC.RemoveTab(TabNameRoster);
			TP_Roster = none;
		}
	}
}

defaultproperties
{
     MessageLadderAvailable="ladder is now available."
     MessageLadderComplete="ladder completed."
     MessageCreateProfileFirst="You must create or load a profile before playing."
     TabNameProfileNew="Create Profile"
     TabNameProfileLoad="Manage Profiles"
     TabNameQualification="Qualification"
     TabNameLadder="Ladder"
     TabNameRoster="Roster"
     TabNameTutorials="Tutorials"
     TabHintProfileNew="Create a new single player campaign"
     TabHintProfileLoad="Manage your existing single player campaigns"
     TabHintQualification="Individual competition to qualify for the Unreal Tournament"
     TabHintLadder="Team competition in the Unreal Tournament"
     TabHintRoster="Manage your lineup for the next match"
     TabHintTutorials="View tutorials for each game type"
     Background=Texture'InterfaceContent.Backgrounds.bg11'
     Begin Object Class=GUITabControl Name=SPTabs
         bFillSpace=True
         TabHeight=0.040000
         WinTop=0.250000
         WinHeight=48.000000
         bAcceptsInput=True
         OnActivate=SPTabs.InternalOnActivate
         OnChange=UT2SinglePlayerMain.TabChange
     End Object
     Controls(0)=GUITabControl'XInterface.UT2SinglePlayerMain.SPTabs'

     Begin Object Class=GUITitleBar Name=SPHints
         bUseTextHeight=False
         StyleName="Footer"
         WinTop=0.930000
         WinLeft=0.120000
         WinWidth=0.760000
         WinHeight=0.055000
     End Object
     Controls(1)=GUITitleBar'XInterface.UT2SinglePlayerMain.SPHints'

     Begin Object Class=GUIButton Name=SPBack
         Caption="MENU"
         StyleName="SquareMenuButton"
         Hint="Return to main menu"
         WinTop=0.930000
         WinWidth=0.120000
         WinHeight=0.055000
         bFocusOnWatch=True
         OnClick=UT2SinglePlayerMain.ButtonClick
         OnKeyEvent=SPBack.InternalOnKeyEvent
     End Object
     Controls(2)=GUIButton'XInterface.UT2SinglePlayerMain.SPBack'

     Begin Object Class=GUIButton Name=SPPlay
         Caption="PLAY"
         StyleName="SquareMenuButton"
         Hint="Play the selected match"
         WinTop=0.930000
         WinLeft=0.880000
         WinWidth=0.120000
         WinHeight=0.055000
         bFocusOnWatch=True
         OnClick=UT2SinglePlayerMain.ButtonClick
         OnKeyEvent=SPPlay.InternalOnKeyEvent
     End Object
     Controls(3)=GUIButton'XInterface.UT2SinglePlayerMain.SPPlay'

     Begin Object Class=GUITitleBar Name=SPPageHeader
         Effect=FinalBlend'InterfaceContent.Menu.CO_Final'
         Caption="Single Player"
         StyleName="Header"
         WinTop=0.036406
         WinHeight=46.000000
     End Object
     Controls(4)=GUITitleBar'XInterface.UT2SinglePlayerMain.SPPageHeader'

     WinHeight=1.000000
}
