// ====================================================================
//  Class:  XInterface.UT2InstantActionPage
//  Parent: XInterface.GUIPage
//
//  <Enter a description here>
// ====================================================================

class UT2InstantActionPage extends UT2K3GUIPage;

#exec OBJ LOAD FILE=InterfaceContent.utx

var Tab_InstantActionMain 		pMain;
var Tab_InstantActionBaseRules 	pRules;
var Tab_InstantActionMutators	pMutators;
var Tab_InstantActionMapList	pMapList;
var Tab_InstantActionBotConfig	pBotConfig;
var Tab_PlayerSettings			pPlayerSetup;

var GUITabControl				MyTabs;

var localized string			MainTabLabel,
								MainTabHint,
								RulesTabLabel,
								RulesTabHint,
								MutatorTabLabel,
								MutatorTabHint,
								MapListTabLabel,
								MapListTabHint,
								BotConfigTabLabel,
								BotConfigTabHint,
								PlayerTabLabel,
								PlayerTabHint;

var bool bSpectate;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local string RulesClass;
	Super.Initcomponent(MyController, MyOwner);

	MyTabs = GUITabControl(Controls[1]);
	GUITitleBar(Controls[0]).DockedTabs = MyTabs;

	pMain 		 = Tab_InstantActionMain(MyTabs.AddTab(MainTabLabel,"xinterface.Tab_InstantActionMain",,MainTabHint,true) );
	pMain.OnChangeGameType = ChangeGameType;
	pMain.OnChangeCustomBots = ChangeCustomBots;
	RulesClass = pMain.GetRulesClass();

	pRules		 = Tab_InstantActionBaseRules(MyTabs.AddTab(RulesTabLabel,RulesClass,,RulesTabHint));
	pMutators	 = Tab_InstantActionMutators(MyTabs.AddTab(MutatorTabLabel,"xinterface.Tab_InstantActionMutators",,MutatorTabHint));
	pMapList	 = Tab_InstantActionMapList(MyTabs.AddTab(MapListTabLabel,"xinterface.Tab_InstantActionMapList",,MapListTabHint));
	pBotConfig	 = Tab_InstantActionBotConfig(MyTabs.AddTab(BotConfigTabLabel,"xinterface.Tab_InstantActionBotConfig",,BotConfigTabHint));
	pPlayerSetup = Tab_PlayerSettings(MyTabs.AddTab(PlayerTabLabel,"xinterface.Tab_PlayerSettings",,PlayerTabHint));

	if (pBotConfig!=None)
		pBotConfig.SetupBotLists(pMain.GetIsTeamGame());

	pMapList.ReadMapList(pMain.GetMapPrefix(), pMain.GetMapListClass());
	MyTabs.bDockPanels=true;

	ChangeCustomBots();
    bSpectate = false;
}

function bool BackButtonClick(GUIComponent Sender)
{
	pPlayerSetup.InternalApply(none);
	Controller.CloseMenu(true);
	return true;
}

function bool PlayButtonClick(GUIComponent Sender)
{
	local string FullURL, GameURL, FirstMap, GameType;

	pPlayerSetup.InternalApply(none);

	GameURL = pMain.Play();
	GameURL = GameURL$pRules.Play();
	GameURL = GameURL$pMutators.Play();
	GameURL = GameURL$pMapList.Play();

	if(pMain.LastUseCustomBots)
		GameURL = GameURL$pBotConfig.Play();

	FirstMap = pMain.MyMapList.List.Get();
	GameType = "?Game="$pMain.GetGameClass();

    if (bSpectate)
    	GameType = GameType$"?spectatoronly=1";

	FullURL = FirstMap$GameType$GameURL;

	log("UT2InstantActionPage::PlayButtonClick - Sending [open"@FUllURL$"] to the console");
	Console(Controller.Master.Console).DelayedConsoleCommand("start"@FullURL);
	Controller.CloseAll(false);
	return true;
}

function bool SpecButtonClick(GUIComponent Sender)
{
	bSpectate = true;
    PlayButtonClick(sender);
    return true;
}


function TabChange(GUIComponent Sender)
{
	if (GUITabButton(Sender)==none)
		return;

	GUITitleBar(Controls[0]).SetCaption(GUITitleBar(default.Controls[0]).GetCaption()@"|"@GUITabButton(Sender).Caption);
}

event ChangeHint(string NewHint)
{
	GUITitleBar(Controls[2]).SetCaption(NewHint);
}


function InternalOnReOpen()
{
}

function ChangeGameType()
{
	local string RulesClass;

	if (pMapList!=None)
		pMapList.ReadMapList(pMain.GetMapPrefix(),pMain.GetMapListClass());

	RulesClass = pMain.GetRulesClass();
	pRules = Tab_InstantActionBaseRules(MyTabs.ReplaceTab(pRules.MyButton,RulesTabLabel,RulesClass,,RulesTabHint));

	if (pBotConfig!=None)
		pBotConfig.SetupBotLists(pMain.GetIsTeamGame());
}

function ChangeCustomBots()
{
	MyTabs.RemoveTab(BotConfigTabLabel);

	if(pMain.LastUseCustomBots)
		MyTabs.AddTab(BotConfigTabLabel,"xinterface.Tab_InstantActionBotConfig",pBotConfig,BotConfigTabHint);
}

function InternalOnClose(optional Bool bCanceled)
{
	// Destroy spinning player model actor
	if(pPlayerSetup.SpinnyDude != None)
		pPlayerSetup.SpinnyDude.Destroy();

	Super.OnClose(bCanceled);
}

defaultproperties
{
     MainTabLabel="Select Map"
     MainTabHint="Choose the starting map and game type to play..."
     RulesTabLabel="Game Rules"
     RulesTabHint="Configure the current game type..."
     MutatorTabLabel="Mutators"
     MutatorTabHint="Select and configure any mutators to use..."
     MapListTabLabel="Map List"
     MapListTabHint="Configure the list of maps to play..."
     BotConfigTabLabel="Bot Config"
     BotConfigTabHint="Configure any bots that will be in the session..."
     PlayerTabLabel="Player"
     PlayerTabHint="Configure your UT2003 Avatar..."
     Background=Texture'InterfaceContent.Backgrounds.bg09'
     OnReOpen=UT2InstantActionPage.InternalOnReOpen
     OnClose=UT2InstantActionPage.InternalOnClose
     Begin Object Class=GUITitleBar Name=IAPageHeader
         Effect=FinalBlend'InterfaceContent.Menu.CO_Final'
         Caption="Instant Action"
         StyleName="Header"
         WinTop=0.036406
         WinHeight=46.000000
     End Object
     Controls(0)=GUITitleBar'XInterface.UT2InstantActionPage.IAPageHeader'

     Begin Object Class=GUITabControl Name=IAPageTabs
         TabHeight=0.040000
         WinTop=0.250000
         WinHeight=48.000000
         bAcceptsInput=True
         OnActivate=IAPageTabs.InternalOnActivate
         OnChange=UT2InstantActionPage.TabChange
     End Object
     Controls(1)=GUITabControl'XInterface.UT2InstantActionPage.IAPageTabs'

     Begin Object Class=GUITitleBar Name=IAPageFooter
         bUseTextHeight=False
         StyleName="Footer"
         WinTop=0.930000
         WinLeft=0.120000
         WinWidth=0.635000
         WinHeight=0.055000
     End Object
     Controls(2)=GUITitleBar'XInterface.UT2InstantActionPage.IAPageFooter'

     Begin Object Class=GUIButton Name=IAPagePlayButton
         Caption="PLAY"
         StyleName="SquareMenuButton"
         Hint="Start a Match With These Settings"
         WinTop=0.930000
         WinLeft=0.880000
         WinWidth=0.120000
         WinHeight=0.055000
         OnClick=UT2InstantActionPage.PlayButtonClick
         OnKeyEvent=IAPagePlayButton.InternalOnKeyEvent
     End Object
     Controls(3)=GUIButton'XInterface.UT2InstantActionPage.IAPagePlayButton'

     Begin Object Class=GUIButton Name=IAPageBackButton
         Caption="BACK"
         StyleName="SquareMenuButton"
         Hint="Return to Previous Menu"
         WinTop=0.930000
         WinWidth=0.120000
         WinHeight=0.055000
         OnClick=UT2InstantActionPage.BackButtonClick
         OnKeyEvent=IAPageBackButton.InternalOnKeyEvent
     End Object
     Controls(4)=GUIButton'XInterface.UT2InstantActionPage.IAPageBackButton'

     Begin Object Class=GUIButton Name=IAPageSpecButton
         Caption="SPECTATE"
         StyleName="SquareMenuButton"
         Hint="Spectate a Match With These Settings"
         WinTop=0.930000
         WinLeft=0.758125
         WinWidth=0.120000
         WinHeight=0.055000
         OnClick=UT2InstantActionPage.SpecButtonClick
         OnKeyEvent=IAPageSpecButton.InternalOnKeyEvent
     End Object
     Controls(5)=GUIButton'XInterface.UT2InstantActionPage.IAPageSpecButton'

     WinHeight=1.000000
}
