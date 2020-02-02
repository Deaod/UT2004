// ====================================================================
//  Written by Jack Porter
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class ServerBrowser extends UT2K3GUIPage;

#exec OBJ LOAD FILE=InterfaceContent.utx

var Browser_Page MOTDPage;

var Browser_Page DMServerListPage;
var Browser_Page TDMServerListPage;
var Browser_Page CTFServerListPage;
var Browser_Page BRServerListPage;
var Browser_Page DomServerListPage;
var Browser_Page CustomServerListPage;

var Browser_Page FavoritesPage;
var Browser_Page LANPage;
var Browser_Page PrefsPage;
var Browser_Page BuddiesPage;
var Browser_Page IRCPage;

var bool bCreatedQueryTabs;
var bool bCreatedStandardTabs;

var localized string MutantTypeName, InvasionTypeName, LMSTypeName;
var localized string MutantType, InvasionType, LMSType;

// Filtering options
var() config bool bOnlyShowStandard;
var() config bool bOnlyShowNonPassword;
var() config bool bDontShowFull;
var() config bool bDontShowEmpty;
var() config bool bDontShowWithBots;
var() config string DesiredMutator;
var() config string DesiredMutator2;
var() config string CustomQuery;
var() config int	MinGamespeed, MaxGamespeed;

var() config enum EViewMutatorMode
{
	VMM_AnyMutators,
	VMM_NoMutators,
	VMM_ThisMutator,
	VMM_NotThisMutator
} ViewMutatorMode, ViewMutator2Mode;

var() config enum EStatsServerView
{
	SSV_Any,
    SSV_OnlyStatsEnabled,
    SSV_NoStatsEnabled,
} StatsServerView;

var() config enum EWeaponStayServerView
{
	WSSV_Any,
    WSSV_OnlyWeaponStay,
    WSSV_NoWeaponStay,
} WeaponStayServerView;

var() config enum ETranslocServerView
{
	TSV_Any,
    TSV_OnlyTransloc,
    TSV_NoTransloc,
} TranslocServerView;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	GUITitleBar(Controls[0]).DockedTabs = GUITabControl(Controls[1]);

	// delegates
	OnClose = InternalOnClose;

	// Add pages
	if(!bCreatedStandardTabs)
	{
		AddBrowserPage(MOTDPage);
		AddBrowserPage(PrefsPage);
		AddBrowserPage(IRCPage);
		AddBrowserPage(LANPage);
		AddBrowserPage(FavoritesPage);

		bCreatedStandardTabs=true;
	}
}

// Do we have the bonus pack installed?
function bool HaveBonusPack()
{
	local Object Test;

	Test = DynamicLoadObject("BonusPack.xMutantGame", class'Class');
	if(Test == None)
		return false;

	Test = DynamicLoadObject("SkaarjPack.Invasion", class'Class');
	if(Test == None)
		return false;

	return true;
}

// See if we have any custom game types (is this too slow?)
function bool HaveCustomGameTypes()
{
	local string Entry, Desc;
	local int Index;

	// Find other game types from .int files, and create tabs
	Index = 0;
	PlayerOwner().GetNextIntDesc("GameInfo",Index,Entry,Desc);
	while (Entry != "")
	{
		Desc = Entry$"|"$Desc;

		// If its not a standard game type, we have a custom one.
		if ( !class'Browser_ServerListPageMSCustom'.static.IsStandardGameType(Desc) )
			return true;

		Index++;
		PlayerOwner().GetNextIntDesc("GameInfo", Index, Entry, Desc);
	}

	// No custom game types found
	return false;
}

function MOTDVerified(bool bMSVerified)
{
	local Browser_ServerListPageMS NewPage;

	if( bCreatedQueryTabs )
		return;

	bCreatedQueryTabs = true;

	AddBrowserPage(BuddiesPage);

	// Create tabs for 'standard' game types
	AddBrowserPage(DMServerListPage);
	AddBrowserPage(TDMServerListPage);
	if(!PlayerOwner().Level.IsDemoBuild())
		AddBrowserPage(DomServerListPage);
	AddBrowserPage(CTFServerListPage);
	AddBrowserPage(BRServerListPage);

	if( HaveBonusPack() )
	{
		NewPage = new(None) class'Browser_ServerListPageMS';
		NewPage.GameType = InvasionType;
		NewPage.PageCaption = InvasionTypeName;
		AddBrowserPage(NewPage);

		NewPage = new(None) class'Browser_ServerListPageMS';
		NewPage.GameType = LMSType;
		NewPage.PageCaption = LMSTypeName;
		AddBrowserPage(NewPage);

		NewPage = new(None) class'Browser_ServerListPageMS';
		NewPage.GameType = MutantType;
		NewPage.PageCaption = MutantTypeName;
		AddBrowserPage(NewPage);
	}

	if( HaveCustomGameTypes() )
		AddBrowserPage(CustomServerListPage);
}

function AddBrowserPage( Browser_Page NewPage )
{
	local GUITabControl TabC;

	NewPage.Browser = Self;
	TabC = GUITabControl(Controls[1]);
	TabC.AddTab(NewPage.PageCaption,"", NewPage);
}

delegate OnAddFavorite( GameInfo.ServerResponseLine Server );

function InternalOnClose(optional Bool bCanceled)
{
	local int i;
	local GUITabControl TabC;

	TabC = GUITabControl(Controls[1]);

	for( i=0;i<TabC.TabStack.Length;i++ )
		Browser_Page(TabC.TabStack[i].MyPanel).OnCloseBrowser();

	Super.OnClose(bCanceled);
}

defaultproperties
{
     Begin Object Class=Browser_MOTD Name=MyMOTDPage
         PageCaption="News"
     End Object
     MOTDPage=Browser_MOTD'XInterface.ServerBrowser.MyMOTDPage'

     Begin Object Class=Browser_ServerListPageMS Name=MyDMServerListPage
         GameType="xDeathMatch"
         PageCaption="DM"
     End Object
     DMServerListPage=Browser_ServerListPageMS'XInterface.ServerBrowser.MyDMServerListPage'

     Begin Object Class=Browser_ServerListPageMS Name=MyTDMServerListPage
         GameType="xTeamGame"
         PageCaption="Team DM"
     End Object
     TDMServerListPage=Browser_ServerListPageMS'XInterface.ServerBrowser.MyTDMServerListPage'

     Begin Object Class=Browser_ServerListPageMS Name=MyCTFServerListPage
         GameType="xCTFGame"
         PageCaption="CTF"
     End Object
     CTFServerListPage=Browser_ServerListPageMS'XInterface.ServerBrowser.MyCTFServerListPage'

     Begin Object Class=Browser_ServerListPageMS Name=MyBRServerListPage
         GameType="xBombingRun"
         PageCaption="Bombing Run"
     End Object
     BRServerListPage=Browser_ServerListPageMS'XInterface.ServerBrowser.MyBRServerListPage'

     Begin Object Class=Browser_ServerListPageMS Name=MyDomServerListPage
         GameType="xDoubleDom"
         PageCaption="Double Dom"
     End Object
     DomServerListPage=Browser_ServerListPageMS'XInterface.ServerBrowser.MyDomServerListPage'

     Begin Object Class=Browser_ServerListPageMSCustom Name=MyCustomServerListPage
         PageCaption="Custom"
     End Object
     CustomServerListPage=Browser_ServerListPageMSCustom'XInterface.ServerBrowser.MyCustomServerListPage'

     Begin Object Class=Browser_ServerListPageFavorites Name=MyFavoritesPage
         PageCaption="Favorites"
     End Object
     FavoritesPage=Browser_ServerListPageFavorites'XInterface.ServerBrowser.MyFavoritesPage'

     Begin Object Class=Browser_ServerListPageLAN Name=MyLANPage
         PageCaption="LAN"
     End Object
     LANPage=Browser_ServerListPageLAN'XInterface.ServerBrowser.MyLANPage'

     Begin Object Class=Browser_Prefs Name=MyPrefsPage
         PageCaption="Filter"
     End Object
     PrefsPage=Browser_Prefs'XInterface.ServerBrowser.MyPrefsPage'

     Begin Object Class=Browser_ServerListPageBuddy Name=MyBuddiesPage
         GameType="xBombingRun"
         PageCaption="Buddies"
     End Object
     BuddiesPage=Browser_ServerListPageBuddy'XInterface.ServerBrowser.MyBuddiesPage'

     Begin Object Class=Browser_IRC Name=MyIRCPage
         PageCaption="Chat"
     End Object
     IRCPage=Browser_IRC'XInterface.ServerBrowser.MyIRCPage'

     MutantTypeName="Mutant"
     InvasionTypeName="Invasion"
     LMSTypeName="Last Man Standing"
     MutantType="xMutantGame"
     InvasionType="Invasion"
     LMSType="xLastManStanding"
     MaxGamespeed=200
     bCheckResolution=True
     bPersistent=True
     Background=Texture'InterfaceContent.Backgrounds.bg10'
     Begin Object Class=GUITitleBar Name=ServerBrowserHeader
         Caption="Server Browser"
         StyleName="Header"
         WinTop=0.036406
         WinHeight=46.000000
     End Object
     Controls(0)=GUITitleBar'XInterface.ServerBrowser.ServerBrowserHeader'

     Begin Object Class=GUITabControl Name=ServerBrowserTabs
         bDockPanels=True
         TabHeight=0.040000
         WinTop=0.250000
         WinHeight=48.000000
         bAcceptsInput=True
         OnActivate=ServerBrowserTabs.InternalOnActivate
     End Object
     Controls(1)=GUITabControl'XInterface.ServerBrowser.ServerBrowserTabs'

     WinHeight=1.000000
}
