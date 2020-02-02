// ====================================================================
//  Class:  XInterface.UT2MultiplayerHostPage
//  Parent: XInterface.GUIPage
//
//  <Enter a description here>
// ====================================================================

class UT2MultiplayerHostPage extends UT2K3GUIPage;

#exec OBJ LOAD FILE=InterfaceContent.utx

var Tab_MultiplayerHostMain 			pMain;
var Tab_InstantActionBaseRules 			pRules;
var Tab_InstantActionMutators			pMutators;
var Tab_MultiplayerHostServerSettings	pServer;
var Tab_InstantActionBotConfig			pBotConfig;

var GUITabControl						MyTabs;

var localized string	MainTabLabel,
						MainTabHint,
						RulesTabLabel,
						RulesTabHint,
						MutatorsTabLabel,
						MutatorsTabHint,
						ServerTabLabel,
						ServerTabHint,
						BotTabLabel,
						BotTabHint;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local string RulesClass;

	Super.Initcomponent(MyController, MyOwner);

	MyTabs = GUITabControl(Controls[1]);
	GUITitleBar(Controls[0]).DockedTabs = MyTabs;

	pMain 		 = Tab_MultiplayerHostMain( MyTabs.AddTab(MainTabLabel,"xinterface.Tab_MultiplayerHostMain",,MainTabHint,true) );

	pMain.OnChangeGameType = ChangeGameType;

	RulesClass = pMain.GetRulesClass();

	pRules		 = Tab_InstantActionBaseRules(MyTabs.AddTab(RulesTabLabel,	RulesClass,,RulesTabHint));

	pMutators	 = Tab_InstantActionMutators(MyTabs.AddTab(MutatorsTabLabel,"xinterface.Tab_InstantActionMutators",,MutatorsTabHint));
	pServer		 = Tab_MultiplayerHostServerSettings(MyTabs.AddTab(ServerTabLabel,"xinterface.Tab_MultiplayerHostServerSettings",,ServerTabHint));
	pServer.OnChangeCustomBots = ChangeCustomBots;
	pBotConfig	 = Tab_InstantActionBotConfig(MyTabs.AddTab(BotTabLabel,"xinterface.Tab_InstantActionBotConfig",,BotTabHint));

	if (pBotConfig!=None)
		pBotConfig.SetupBotLists(pMain.GetIsTeamGame());

	MyTabs.bDockPanels=true;

	ChangeCustomBots(!pServer.bUseDefaults && pServer.bUseCustomBots);
}

function bool BackButtonClick(GUIComponent Sender)
{
	Controller.CloseMenu(true);
	return true;
}

function bool PlayButtonClick(GUIComponent Sender)
{
	local string FullURL, GameURL, FirstMap, GameType;

	GameURL = pMain.Play();
	GameURL = GameURL$pRules.Play();
	GameURL = GameURL$pMutators.Play();

	if(pServer.UseCustomBots())
		GameURL = GameURL$pBotConfig.Play();

	GameURL = GameURL$pServer.Play();

	if ( (pMain.MyCurMapList.List.ItemCount==0) || (pMain.MyCurMapList.List.Get() == "") )
	{
 		if ( (pMain.MyCurMapList.List.ItemCount==0) || (pMain.MyCurMapList.List.GetItemAtIndex(0) == ""))
			FirstMap = pMain.MyFullMapList.List.Get();
		else
			FirstMap = pMain.MyCurMapList.List.GetItemAtIndex(0);
	}
	else
		FirstMap = pMain.MyCurMapList.List.Get();

	GameType = "?Game="$pMain.GetGameClass();
	FullURL = FirstMap$GameType$GameURL;

    if( pServer.bDedicated )
        PlayerOwner().ConsoleCommand( "RELAUNCH " $ FullURL $ " -server -log=Server.log" );
    else
        PlayerOwner().ClientTravel( FullURL $"?Listen", TRAVEL_Absolute, false );

	Controller.CloseAll(false);

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

	RulesClass = pMain.GetRulesClass();
	pRules = Tab_InstantActionBaseRules(MyTabs.ReplaceTab(pRules.MyButton,RulesTabLabel,RulesClass,,RulesTabHint));

	if (pBotConfig!=None)
		pBotConfig.SetupBotLists(pMain.GetIsTeamGame());

}

function ChangeCustomBots(bool Enable)
{
	MyTabs.RemoveTab(BotTabLabel);

	if(Enable)
		MyTabs.AddTab(BotTabLabel,"xinterface.Tab_InstantActionBotConfig",pBotConfig,BotTabHint);
}

defaultproperties
{
     MainTabLabel="Game & Map"
     MainTabHint="Choose the starting map and game type to play..."
     RulesTabLabel="Game Rules"
     RulesTabHint="Configure the current game type..."
     MutatorsTabLabel="Mutators"
     MutatorsTabHint="Select and configure any mutators to use..."
     ServerTabLabel="Server"
     ServerTabHint="Configure all server specific settings..."
     BotTabLabel="Bot Config"
     BotTabHint="Configure any bots that will be in the session..."
     Background=Texture'InterfaceContent.Backgrounds.bg11'
     OnReOpen=UT2MultiplayerHostPage.InternalOnReOpen
     Begin Object Class=GUITitleBar Name=HostHeader
         Effect=FinalBlend'InterfaceContent.Menu.CO_Final'
         Caption="Host Multiplayer Game"
         StyleName="Header"
         WinTop=0.036406
         WinHeight=46.000000
     End Object
     Controls(0)=GUITitleBar'XInterface.UT2MultiplayerHostPage.HostHeader'

     Begin Object Class=GUITabControl Name=HostTabs
         TabHeight=0.040000
         WinTop=0.250000
         WinHeight=48.000000
         bAcceptsInput=True
         OnActivate=HostTabs.InternalOnActivate
         OnChange=UT2MultiplayerHostPage.TabChange
     End Object
     Controls(1)=GUITabControl'XInterface.UT2MultiplayerHostPage.HostTabs'

     Begin Object Class=GUITitleBar Name=HostFooter
         bUseTextHeight=False
         StyleName="Footer"
         WinTop=0.930000
         WinLeft=0.120000
         WinWidth=0.760000
         WinHeight=0.055000
     End Object
     Controls(2)=GUITitleBar'XInterface.UT2MultiplayerHostPage.HostFooter'

     Begin Object Class=GUIButton Name=HostPlayButton
         Caption="START"
         StyleName="SquareMenuButton"
         Hint="Start the server"
         WinTop=0.930000
         WinLeft=0.880000
         WinWidth=0.120000
         WinHeight=0.055000
         OnClick=UT2MultiplayerHostPage.PlayButtonClick
         OnKeyEvent=HostPlayButton.InternalOnKeyEvent
     End Object
     Controls(3)=GUIButton'XInterface.UT2MultiplayerHostPage.HostPlayButton'

     Begin Object Class=GUIButton Name=HostBackButton
         Caption="BACK"
         StyleName="SquareMenuButton"
         Hint="Cancel Changes and Return to Previous Menu"
         WinTop=0.930000
         WinWidth=0.120000
         WinHeight=0.055000
         OnClick=UT2MultiplayerHostPage.BackButtonClick
         OnKeyEvent=HostBackButton.InternalOnKeyEvent
     End Object
     Controls(4)=GUIButton'XInterface.UT2MultiplayerHostPage.HostBackButton'

     WinHeight=1.000000
}
