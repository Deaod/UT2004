// ====================================================================
//  Written by Ron Prestenback (based on XInterface.ServerBrowser)
//  (c) 2002, 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class UT2K4ServerBrowser extends UT2K4MainPage
    config;

#exec OBJ LOAD FILE=InterfaceContent.utx

var() globalconfig bool         bStandardServersOnly;
var() config    string          CurrentGameType;
var   config    bool            bPlayerVerified;
var             string          InternetSettingsPage;

var automated   moComboBox      co_GameType;
var private MasterServerClient  MSC;
var BrowserFilters              FilterMaster;
var PlayInfo                    FilterInfo;
var UT2K4Browser_Footer         f_Browser;
var transient   bool            Verified;

// Number of open network connections
var int ThreadCount;

var array<CacheManager.GameRecord>      Records;
var UT2K4Browser_Page tp_Active;

var localized string InternetOptionsText;

var bool bHideNetworkMessage;

var string OfficialSubnets[2];

struct eServerCacheInfo
{
	var	string GameType;
	var int	SubnetIndex;
	var GameInfo.ServerResponseLine SRL;
};

var() globalconfig array<eServerCacheInfo> ServerCache;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    f_Browser = UT2K4Browser_Footer(t_Footer);

    f_Browser.p_Anchor = Self;
    f_Browser.ch_Standard.OnChange = StandardOptionChanged;
    f_Browser.ch_Standard.SetComponentValue(bStandardServersOnly, True);

    if (FilterMaster == None)
    {
        FilterMaster = new(Self) class'GUI2K4.BrowserFilters';
        FilterMaster.InitCustomFilters();
    }

    if (FilterInfo == None)
        FilterInfo = new(None) class'Engine.PlayInfo';

    Background=MyController.DefaultPens[0];

    InitializeGameTypeCombo();
    co_GameType.MyComboBox.Edit.bCaptureMouse = True;
    CreateTabs();
}

function MasterServerClient Uplink()
{
	if ( MSC == None && PlayerOwner() != None )
		MSC = PlayerOwner().Spawn( class'MasterServerClient' );

	return MSC;
}

event Opened(GUIComponent Sender)
{
	Super.Opened(Sender);

	bHideNetworkMessage = false;

	if ( tp_Active != None )
		UT2K4Browser_Footer(t_Footer).UpdateActiveButtons( tp_Active );
}

event Closed(GUIComponent Sender, bool bCancelled)
{
	Super.Closed(Sender,bCancelled);
	if ( MSC != None )
		MSC.CancelPings();

	SaveConfig();

}


function bool ComboOnPreDraw(Canvas Canvas)
{
	co_GameType.WinTop = co_GameType.RelativeTop(t_Header.ActualTop() + t_Header.ActualHeight() + float(Controller.ResY) / 480.0);
	co_GameType.WinLeft = co_GameType.RelativeLeft((c_Tabs.ActualLeft() + c_Tabs.ActualWidth()) - (co_GameType.ActualWidth() + 3));
    return false;
}

function InitializeGameTypeCombo(optional bool ClearFirst)
{
    local int i, j;
    local UT2K4Browser_ServersList  ListObj;
    local array<CacheManager.MapRecord> Maps;

	co_GameType.MyComboBox.MaxVisibleItems = 10;
    PopulateGameTypes();
    if (ClearFirst)
        co_GameType.MyComboBox.List.Clear();

    j = -1;

    // Create a seperate list for each gametype, and store the lists in the combo box
    for (i = 0; i < Records.Length; i++)
    {
    	class'CacheManager'.static.GetMapList( Maps, Records[i].MapPrefix );
//    	if ( Maps.Length == 0 )
//    		continue;

        ListObj = new(None) class'GUI2K4.UT2K4Browser_ServersList';
        co_GameType.AddItem(Records[i].GameName, ListObj, Records[i].ClassName);
//        if (Records[i].ClassName ~= CurrentGameType)
//            j = i;
    }

	j = co_GameType.FindIndex(CurrentGameType,true,true);
    if (j != -1)
    {
	    co_GameType.SetIndex(j);
	    SetFilterInfo();
    }
}

function BrowserOpened()
{
    if ( !bPlayerVerified )
 	   CheckPlayerOptions();
}

function MOTDVerified(bool bMSVerified)
{
    EnableMSTabs();
    Verified = bMSVerified;
}

function CheckPlayerOptions()
{
	local PlayerController PC;
	local string CurrentName;

	PC = PlayerOwner();
	if ( PC.PlayerReplicationInfo != None )
		CurrentName = PC.PlayerReplicationInfo.PlayerName;
	else CurrentName = PC.GetURLOption( "Name" );

	if ( CurrentName ~= "Player" || class'Player'.default.ConfiguredInternetSpeed == 9636 )
	{
		if ( Controller.OpenMenu( Controller.QuestionMenuClass ) )
		{
			GUIQuestionPage(Controller.ActivePage).SetupQuestion(InternetOptionsText, QBTN_YesNoCancel);
			GUIQuestionPage(Controller.ActivePage).NewOnButtonClick = InternetOptionsConfirm;
		}
	}

	else
	{
		bPlayerVerified = True;
		SaveConfig();
	}
}

function bool InternetOptionsConfirm( byte ButtonMask )
{
	local GUIQuestionPage pg;

	if ( bool(ButtonMask & QBTN_No) )
		return true;

	if ( bool(ButtonMask & QBTN_Cancel) )
	{
		bPlayerVerified = True;
		SaveConfig();
		return true;
	}

	pg = GUIQuestionPage(Controller.ActivePage);
	if ( pg == None )
		return true;

	if ( bool(ButtonMask & QBTN_Yes) )
	{
		if ( Controller.ReplaceMenu( InternetSettingsPage ) )
			Controller.ActivePage.OnClose = InternetOptionsClosed;

		return True;
	}

	return false;
}

function InternetOptionsClosed( bool bCancelled )
{
	bPlayerVerified = True;
	SaveConfig();
}

function CreateTabs()
{
	local int i;

	for ( i = 0; i < PanelCaption.Length && i < PanelClass.Length && i < PanelHint.Length; i++ )
	{
		if ( PanelClass[i] != "" )
			AddTab(PanelCaption[i], PanelClass[i], PanelHint[i]);
	}

	DisableMSTabs();


	// Must perform the first refresh manually, since the RefreshFooter delegate won't be assigned
	// when the first tab panel receives the first call to ShowPanel()
	RefreshFooter( UT2K4Browser_Page(c_Tabs.ActiveTab.MyPanel),"false" );
}

function EnableMSTabs()
{
	local UT2K4Browser_ServerListPageBuddy BuddyPanel;
	local int i;

	i = c_Tabs.TabIndex( PanelCaption[4] );
	if ( i != -1 )
	{
		EnableComponent(c_Tabs.TabStack[i]);
		BuddyPanel = UT2K4Browser_ServerListPageBuddy(c_Tabs.TabStack[i].MyPanel);
	}

	i = c_Tabs.TabIndex( PanelCaption[5] );
	if ( i != -1 )
		EnableComponent(c_Tabs.TabStack[i]);

	if ( BuddyPanel == None )
		return;

    // All players lists need a reference to the buddy page
    for (i = 0; i < c_Tabs.TabStack.Length; i++)
    {
        if (UT2K4Browser_ServerListPageBase(c_Tabs.TabStack[i].MyPanel) != None)
        {
            if (UT2K4Browser_ServerListPageBase(c_Tabs.TabStack[i].MyPanel).lb_Players != None)
                UT2K4Browser_ServerListPageBase(c_Tabs.TabStack[i].MyPanel).lb_Players.tp_Buddy = BuddyPanel;
        }
    }
}

function DisableMSTabs()
{
	local int i;

	Verified = False;
	i = c_Tabs.TabIndex( PanelCaption[4] );
	if ( i != -1 )
		DisableComponent(c_Tabs.TabStack[i]);

	i = c_Tabs.TabIndex( PanelCaption[5] );
	if ( i != -1 )
		DisableComponent(c_Tabs.TabStack[i]);

	for ( i = 0; i < c_Tabs.TabStack.Length; i++ )
	{
		if ( UT2K4Browser_ServerListPageBase(c_Tabs.TabStack[i].MyPanel) != None )
        {
            if (UT2K4Browser_ServerListPageBase(c_Tabs.TabStack[i].MyPanel).lb_Players != None)
                UT2K4Browser_ServerListPageBase(c_Tabs.TabStack[i].MyPanel).lb_Players.tp_Buddy = None;
        }
    }
}

function UT2K4Browser_Page AddTab( string TabCaption, string PanelClassName, string TabHint )
{
	local UT2K4Browser_Page Tab;

	if ( TabCaption != "" && PanelClassName != "" && TabHint != "" )
	{
		Tab = UT2K4Browser_Page(c_Tabs.AddTab(TabCaption, PanelClassName,, TabHint));
		if ( Tab != None )
		{
			Tab.RefreshFooter = RefreshFooter;
			Tab.OnOpenConnection = ConnectionOpened;
			Tab.OnCloseConnection = ConnectionClosed;
		}
	}

	return Tab;
}

delegate OnAddFavorite( GameInfo.ServerResponseLine Server );

// Server browser must remain persistent across level changes, in order for the IRC client to function properly
event bool NotifyLevelChange()
{
	if ( MSC != None )
	{
		MSC.Stop();
		MSC.Destroy();
	}

	MSC = None;
	LevelChanged();
	return false;
}

function InternalOnChange(GUIComponent Sender)
{
	local bool bShowGameType;

    if ( GUITabButton(Sender) != None )
    {
        // Update gametype combo box visibility
        bShowGameType = tp_Active != None && tp_Active.ShouldDisplayGameType();
        if ( co_GameType.bVisible != bShowGameType )
        	co_GameType.SetVisibility(bShowGameType);
    }
}

function StandardOptionChanged( GUIComponent Sender )
{
	SetStandardServersOption( moCheckBox(Sender).IsChecked() );
}

function SetStandardServersOption( bool bOnlyStandard )
{
	if ( bOnlyStandard != bStandardServersOnly )
	{
		bStandardServersOnly = bOnlyStandard;
		SaveConfig();

		Refresh();
	}
}

function RefreshFooter( optional UT2K4Browser_Page NewActive, optional string bPerButtonSizes )
{
	if ( NewActive != None )
	{
		tp_Active = NewActive;
		if ( UT2K4Browser_Footer(t_Footer) != None )
			UT2K4Browser_Footer(t_Footer).UpdateActiveButtons(tp_Active);
	}

	if ( t_Footer != None )
		t_Footer.SetupButtons(bPerButtonSizes);
}

function InternalOnLoadIni(GUIComponent Sender, string s)
{
    local int i;

    if (Sender == co_GameType)
    {
        if (CurrentGameType == "")
        {
            CurrentGameType = S;
            SaveConfig();

            i = co_GameType.FindExtra(CurrentGameType);
            if (i != -1)
            {
            	Log("#### - Load INI setting Index to: "@i);
                co_GameType.SetIndex(i);
            }

            SetFilterInfo();
        }
    }
}

function PopulateGameTypes()
{
    local array<CacheManager.GameRecord> Games;
    local int i, j;

    if (Records.Length > 0)
        Records.Remove(0, Records.Length);

    class'CacheManager'.static.GetGameTypeList(Games);
    for (i = 0; i < Games.Length; i++)
    {
        for (j = 0; j < Records.Length; j++)
        {
            if ((Games[i].GameName <= Records[j].GameName) || (Games[i].GameTypeGroup <= Records[j].GameTypeGroup))
            {
                if (Games[i].GameTypeGroup <= Records[j].GameTypeGroup)
                    continue;
                else break;
            }
        }

        Records.Insert(j, 1);
        Records[j] = Games[i];
    }
}

function string GetDesc(string Desc)
{
    local int i;

    i = InStr(Desc, "|");
    if (i >= 0)
        Desc = Mid(Desc, i+1);

    i = InStr(Desc, "|");
    if (i >= 0)
        Desc = Left(Desc, i);

    return Desc;
}

function SetFilterInfo(optional string NewGameType)
{
    local class<GameInfo>       GI;
    local class<AccessControl>  AC;
    local class<Mutator>        Mut;    // Only add basemutator playinfo settings for now

	return;

    Assert(FilterInfo != None);
    FilterInfo.Clear();

    if (NewGameType == "")
        NewGameType = CurrentGameType;

    GI = class<GameInfo>(DynamicLoadObject(NewGameType, class'Class'));
    if (GI != None)
    {
        GI.static.FillPlayInfo(FilterInfo);
        FilterInfo.PopClass();

        AC = class<AccessControl>(DynamicLoadObject(GI.default.AccessControlClass, class'Class'));
        if (AC != None)
        {
            AC.static.FillPlayInfo(FilterInfo);
            FilterInfo.PopClass();
        }

        Mut = class<Mutator>(DynamicLoadObject(GI.default.MutatorClass, class'Class'));
        if (Mut != None)
        {
            Mut.static.FillPlayInfo(FilterInfo);
            FilterInfo.PopClass();
        }
    }
}

function JoinClicked()
{
	if ( tp_Active != None )
		tp_Active.JoinClicked();
}

function SpectateClicked()
{
	if ( tp_Active != None )
		tp_Active.SpectateClicked();
}

function RefreshClicked()
{
	if ( tp_Active != None )
		tp_Active.RefreshClicked();
}

function FilterClicked()
{
	if ( tp_Active != None )
		tp_Active.FilterClicked();
}

function Refresh()
{
	local int i;
	local string dummy;

	if ( c_Tabs == None )
		return;

	for ( i = 0; i < c_Tabs.TabStack.Length; i++ )
	{
		if ( c_Tabs.TabStack[i].MenuState != MSAT_Disabled &&
		     UT2K4Browser_Page(c_Tabs.TabStack[i].MyPanel) != None &&
			 UT2K4Browser_Page(c_Tabs.TabStack[i].MyPanel).IsFilterAvailable(dummy) )
			c_Tabs.TabStack[i].MyPanel.Refresh();
	}
}

static function int CalculateMaxConnections()
{
	local int i;

	if ( class'GUIController'.default.MaxSimultaneousPings < 1 )
	{
		i = class'Player'.default.ConfiguredInternetSpeed;

		if ( i <= 2600 )
			return 10;

		if ( i <= 5000 )
			return 15;

		if ( i <= 10000 )
			return 20;

		if ( i <= 20000 )
			return 35;
	}

	return Min( class'GUIController'.default.MaxSimultaneousPings, 35 );
}

// Returns the maximum number of concurrent UDP connections we're allowed to open
// Specify bCurrentlyAvailable = True to get the difference from the number of connections currently open
function int GetMaxConnections(optional bool bCurrentlyAvailable)
{
	local int Max;

	Max = CalculateMaxConnections();
	if ( bCurrentlyAvailable )
		return Max - ThreadCount;

	return Max;
}

function ConnectionOpened(optional int Num)
{
	if ( Num <= 0 )
		Num = 1;

	ThreadCount += Num;
}

function ConnectionClosed(optional int Num)
{
	if ( Num <= 0 )
		Num = 1;

	ThreadCount -= Num;
	if ( ThreadCount < 0 )
		ThreadCount = 0;
}

/*

struct eServerCacheInfo
{
	var	string GameType;
	var GameInfo.ServerResponseLine SRL;
}

var() globalconfig bool ServerCache;


*/

function ClearServerCache()
{
	local int i;

	i = 0;
	while (i<ServerCache.Length)
	{
		if (ServerCache[i].GameType ~= CurrentGameType)
			ServerCache.Remove(i,1);
		else
			i++;
	}

}

function string FixString(string s)
{
	local string t;
	local int i;

	if (len(s)>200)
		t = left(s,200);
	else
		t = s;

	s = "";
	for (i=0;i<len(t);i++)
	{
		if ( Asc(mid(t,i,1))==34 )
			s = s$"`";

		else if ( Asc(mid(t,i,1))>=32 )
			s = s$mid(t,i,1);
	}

	return s;
}

function AddToServerCache(GameInfo.ServerResponseLine Entry)
{
	ServerCache.Insert(0,1);
	ServerCache[0].GameType 	= CurrentGameType;

	ServerCache[0].SRL.IP 			= Entry.IP;
	ServerCache[0].SRL.ServerName 	= FixString(Entry.ServerName);
	ServerCache[0].SRL.QueryPort    = Entry.QueryPort;
	ServerCache[0].SRL.GameType		= FixString(Entry.GameType);
	ServerCache[0].SRL.Flags		= Entry.Flags;
}

function GetFromServerCache(UT2K4Browser_ServersList List)
{
	local int i;
	local GameInfo.ServerResponseLine SRL;
	for (i=0;i<ServerCache.Length;i++)
	{
		if (ServerCache[i].GameType ~= CurrentGameType)
		{
			SRL = ServerCache[i].SRL;
			SRL.Ip = ServerCache[i].SRL.IP;
			SRL.MapName = "Unknown";
    		List.MyOnReceivedServer( SRL );
    	}
    }
}

defaultproperties
{
     CurrentGameType="XGame.xCTFGame"
     bPlayerVerified=True
     InternetSettingsPage="GUI2K4.UT2K4InternetSettingsPage"
     Begin Object Class=moComboBox Name=GameTypeCombo
         bReadOnly=True
         CaptionWidth=0.100000
         Caption="Game Type"
         OnCreateComponent=GameTypeCombo.InternalOnCreateComponent
         IniOption="@INTERNAL"
         Hint="Choose the gametype to query"
         WinTop=0.050160
         WinLeft=0.638878
         WinWidth=0.358680
         WinHeight=0.035000
         RenderWeight=1.000000
         TabOrder=0
         OnPreDraw=UT2k4ServerBrowser.ComboOnPreDraw
         OnLoadINI=UT2k4ServerBrowser.InternalOnLoadINI
     End Object
     co_GameType=moComboBox'GUI2K4.UT2k4ServerBrowser.GameTypeCombo'

     InternetOptionsText="You have not fully configured your internet play options.  It is recommended that you configure a unique player name and review your netspeed setting before joining a multiplayer game.|Would you like to do this now?"
     OfficialSubnets(0)="69.25.22."
     OfficialSubnets(1)="64.74.139."
     ServerCache(0)=(GameType="XGame.xCTFGame",SRL=(IP="81.30.148.30",QueryPort=33001,ServerName="€€€Fair-ø€@Gamers °°øUT2004 iCTF Server #30",GameType="xCTFGame",Flags=22))
     ServerCache(1)=(GameType="XGame.xCTFGame",SRL=(IP="81.30.148.30",QueryPort=33001,ServerName="€€€Fair-ø€@Gamers °°øUT2004 iCTF Server #30",GameType="xCTFGame",Flags=22))
     ServerCache(2)=(GameType="XGame.xCTFGame",SRL=(IP="81.30.148.30",QueryPort=33001,ServerName="€€€Fair-ø€@Gamers °°øUT2004 iCTF Server #30",GameType="xCTFGame",Flags=22))
     ServerCache(3)=(GameType="XGame.xCTFGame",SRL=(IP="81.30.148.30",QueryPort=33001,ServerName="€€€Fair-ø€@Gamers °°øUT2004 iCTF Server #30",GameType="xCTFGame",Flags=22))
     ServerCache(4)=(GameType="XGame.xCTFGame",SRL=(IP="81.30.148.30",QueryPort=33001,ServerName="€€€Fair-ø€@Gamers °°øUT2004 iCTF Server #30",GameType="xCTFGame",Flags=22))
     ServerCache(5)=(GameType="XGame.xCTFGame",SRL=(IP="81.30.148.30",QueryPort=33001,ServerName="€€€Fair-ø€@Gamers °°øUT2004 iCTF Server #30",GameType="xCTFGame",Flags=22))
     ServerCache(6)=(GameType="XGame.xCTFGame",SRL=(IP="81.30.148.30",QueryPort=33001,ServerName="€€€Fair-ø€@Gamers °°øUT2004 iCTF Server #30",GameType="xCTFGame",Flags=22))
     ServerCache(7)=(GameType="XGame.xCTFGame",SRL=(IP="81.30.148.30",QueryPort=33001,ServerName="€€€Fair-ø€@Gamers °°øUT2004 iCTF Server #30",GameType="xCTFGame",Flags=22))
     ServerCache(8)=(GameType="XGame.xCTFGame",SRL=(IP="195.181.242.143",QueryPort=9778,ServerName="ø€@Koffees ø¢@CTF øàÀPUG øðàcServer |Lithuania",GameType="xCTFGame",Flags=4))
     ServerCache(9)=(GameType="XGame.xCTFGame",SRL=(IP="195.181.242.143",QueryPort=9778,ServerName="ø€@Koffees ø¢@CTF øàÀPUG øðàcServer |Lithuania",GameType="xCTFGame",Flags=4))
     ServerCache(10)=(GameType="XGame.xCTFGame",SRL=(IP="195.181.242.143",QueryPort=9778,ServerName="ø€@Koffees ø¢@CTF øàÀPUG øðàcServer |Lithuania",GameType="xCTFGame",Flags=4))
     ServerCache(11)=(GameType="XGame.xCTFGame",SRL=(IP="195.181.242.143",QueryPort=9778,ServerName="ø€@Koffees ø¢@CTF øàÀPUG øðàcServer |Lithuania",GameType="xCTFGame",Flags=4))
     ServerCache(12)=(GameType="XGame.xCTFGame",SRL=(IP="195.181.242.143",QueryPort=9778,ServerName="ø€@Koffees ø¢@CTF øàÀPUG øðàcServer |Lithuania",GameType="xCTFGame",Flags=4))
     ServerCache(13)=(GameType="XGame.xCTFGame",SRL=(IP="195.181.242.143",QueryPort=9778,ServerName="ø€@Koffees ø¢@CTF øàÀPUG øðàcServer |Lithuania",GameType="xCTFGame",Flags=4))
     ServerCache(14)=(GameType="XGame.xCTFGame",SRL=(IP="195.181.242.143",QueryPort=9778,ServerName="ø€@Koffees ø¢@CTF øàÀPUG øðàcServer |Lithuania",GameType="xCTFGame",Flags=4))
     ServerCache(15)=(GameType="XGame.xCTFGame",SRL=(IP="195.181.242.143",QueryPort=9778,ServerName="ø€@Koffees ø¢@CTF øàÀPUG øðàcServer |Lithuania",GameType="xCTFGame",Flags=4))
     ServerCache(16)=(GameType="XGame.xCTFGame",SRL=(IP="195.181.242.143",QueryPort=9778,ServerName="ø€@Koffees ø¢@CTF øàÀPUG øðàcServer |Lithuania",GameType="xCTFGame",Flags=4))
     ServerCache(17)=(GameType="XGame.xCTFGame",SRL=(IP="195.181.242.143",QueryPort=9778,ServerName="ø€@Koffees ø¢@CTF øàÀPUG øðàcServer |Lithuania",GameType="xCTFGame",Flags=4))
     ServerCache(18)=(GameType="XGame.xCTFGame",SRL=(IP="195.181.242.143",QueryPort=9778,ServerName="ø€@Koffees ø¢@CTF øàÀPUG øðàcServer |Lithuania",GameType="xCTFGame",Flags=4))
     ServerCache(19)=(GameType="XGame.xCTFGame",SRL=(IP="195.181.242.143",QueryPort=9778,ServerName="ø€@Koffees ø¢@CTF øàÀPUG øðàcServer |Lithuania",GameType="xCTFGame",Flags=4))
     ServerCache(20)=(GameType="XGame.xCTFGame",SRL=(IP="199.195.252.18",QueryPort=7778,ServerName="Zak's UT2004 Server [New York]",GameType="xCTFGame",Flags=5))
     ServerCache(21)=(GameType="XGame.xCTFGame",SRL=(IP="199.195.252.18",QueryPort=7778,ServerName="Zak's UT2004 Server [New York]",GameType="xCTFGame",Flags=5))
     ServerCache(22)=(GameType="XGame.xCTFGame",SRL=(IP="199.195.252.18",QueryPort=7778,ServerName="Zak's UT2004 Server [New York]",GameType="xCTFGame",Flags=5))
     ServerCache(23)=(GameType="XGame.xCTFGame",SRL=(IP="91.121.168.34",QueryPort=27316,ServerName="UT2004 Server",GameType="xCTFGame",Flags=32))
     ServerCache(24)=(GameType="XGame.xCTFGame",SRL=(IP="91.121.168.34",QueryPort=27316,ServerName="UT2004 Server",GameType="xCTFGame",Flags=32))
     ServerCache(25)=(GameType="XGame.xCTFGame",SRL=(IP="54.37.16.59",QueryPort=7778,ServerName="UT2004 Server",GameType="xCTFGame",Flags=32))
     ServerCache(26)=(GameType="XGame.xCTFGame",SRL=(IP="54.37.16.59",QueryPort=7778,ServerName="UT2004 Server",GameType="xCTFGame",Flags=32))
     ServerCache(27)=(GameType="XGame.xCTFGame",SRL=(IP="80.127.236.69",QueryPort=7978,ServerName="Na Pali CTF server",GameType="xCTFGame",Flags=36))
     ServerCache(28)=(GameType="XGame.xCTFGame",SRL=(IP="80.127.236.69",QueryPort=7978,ServerName="Na Pali CTF server",GameType="xCTFGame",Flags=36))
     ServerCache(29)=(GameType="XGame.xCTFGame",SRL=(IP="80.127.236.69",QueryPort=7978,ServerName="Na Pali CTF server",GameType="xCTFGame",Flags=36))
     ServerCache(30)=(GameType="XGame.xCTFGame",SRL=(IP="71.83.51.18",QueryPort=7778,ServerName="Johnny'sÂ UT2K4Â Server",GameType="xCTFGame",Flags=36))
     ServerCache(31)=(GameType="XGame.xCTFGame",SRL=(IP="95.179.198.193",QueryPort=7778,ServerName="electronoob test",GameType="xCTFGame",Flags=36))
     ServerCache(32)=(GameType="XGame.xCTFGame",SRL=(IP="95.179.198.193",QueryPort=7778,ServerName="electronoob test",GameType="xCTFGame",Flags=36))
     ServerCache(33)=(GameType="XGame.xCTFGame",SRL=(IP="69.195.145.202",QueryPort=4445,ServerName="[ A2K4.COM ] UT2004 CTF Server",GameType="xCTFGame",Flags=38))
     ServerCache(34)=(GameType="XGame.xCTFGame",SRL=(IP="69.195.145.202",QueryPort=4445,ServerName="[ A2K4.COM ] UT2004 CTF Server",GameType="xCTFGame",Flags=38))
     ServerCache(35)=(GameType="XGame.xCTFGame",SRL=(IP="188.40.254.109",QueryPort=4445,ServerName="[YAF] CTF-Turnierserver 1",GameType="xCTFGame",Flags=7))
     ServerCache(36)=(GameType="XGame.xCTFGame",SRL=(IP="188.40.254.109",QueryPort=4445,ServerName="[YAF] CTF-Turnierserver 1",GameType="xCTFGame",Flags=7))
     ServerCache(37)=(GameType="XGame.xCTFGame",SRL=(IP="188.40.254.109",QueryPort=4445,ServerName="[YAF] CTF-Turnierserver 1",GameType="xCTFGame",Flags=7))
     ServerCache(38)=(GameType="XGame.xCTFGame",SRL=(IP="188.40.254.109",QueryPort=4445,ServerName="[YAF] CTF-Turnierserver 1",GameType="xCTFGame",Flags=7))
     ServerCache(39)=(GameType="XGame.xCTFGame",SRL=(IP="66.55.137.102",QueryPort=7778,ServerName="72.5.102.229:7777",GameType="xCTFGame",Flags=5))
     ServerCache(40)=(GameType="XGame.xCTFGame",SRL=(IP="66.55.137.102",QueryPort=7778,ServerName="72.5.102.229:7777",GameType="xCTFGame",Flags=5))
     ServerCache(41)=(GameType="XGame.xCTFGame",SRL=(IP="74.91.124.251",QueryPort=7655,ServerName="*FTB*~Fast Sniper Multiverse [ftbclan.net]~",GameType="xCTFGame",Flags=2))
     ServerCache(42)=(GameType="XGame.xCTFGame",SRL=(IP="74.91.124.251",QueryPort=7655,ServerName="*FTB*~Fast Sniper Multiverse [ftbclan.net]~",GameType="xCTFGame",Flags=2))
     ServerCache(43)=(GameType="XGame.xCTFGame",SRL=(IP="74.91.124.251",QueryPort=7655,ServerName="*FTB*~Fast Sniper Multiverse [ftbclan.net]~",GameType="xCTFGame",Flags=2))
     ServerCache(44)=(GameType="XGame.xCTFGame",SRL=(IP="74.91.124.251",QueryPort=7655,ServerName="*FTB*~Fast Sniper Multiverse [ftbclan.net]~",GameType="xCTFGame",Flags=2))
     ServerCache(45)=(GameType="XGame.xCTFGame",SRL=(IP="159.69.223.132",QueryPort=6778,ServerName="*** ut-X.net CTF Face ***",GameType="xCTFGame",Flags=6))
     ServerCache(46)=(GameType="XGame.xCTFGame",SRL=(IP="159.69.223.132",QueryPort=6778,ServerName="*** ut-X.net CTF Face ***",GameType="xCTFGame",Flags=6))
     ServerCache(47)=(GameType="XGame.xCTFGame",SRL=(IP="159.69.223.132",QueryPort=6778,ServerName="*** ut-X.net CTF Face ***",GameType="xCTFGame",Flags=6))
     ServerCache(48)=(GameType="XGame.xCTFGame",SRL=(IP="159.69.223.132",QueryPort=6778,ServerName="*** ut-X.net CTF Face ***",GameType="xCTFGame",Flags=6))
     ServerCache(49)=(GameType="XGame.xCTFGame",SRL=(IP="116.202.112.178",QueryPort=10000,ServerName="***  @@@UTø@@zoneøø@.de  *** iCTF | by Donzi.TV",GameType="xCTFGame",Flags=22))
     ServerCache(50)=(GameType="XGame.xCTFGame",SRL=(IP="116.202.112.178",QueryPort=10000,ServerName="***  @@@UTø@@zoneøø@.de  *** iCTF | by Donzi.TV",GameType="xCTFGame",Flags=22))
     ServerCache(51)=(GameType="XGame.xCTFGame",SRL=(IP="116.202.112.178",QueryPort=10000,ServerName="***  @@@UTø@@zoneøø@.de  *** iCTF | by Donzi.TV",GameType="xCTFGame",Flags=22))
     ServerCache(52)=(GameType="XGame.xCTFGame",SRL=(IP="199.195.252.18",QueryPort=7778,ServerName="Zak's UT2004 Server [New York]",GameType="xCTFGame",Flags=5))
     ServerCache(53)=(GameType="XGame.xCTFGame",SRL=(IP="74.91.124.251",QueryPort=7655,ServerName="*FTB*~Fast Sniper Multiverse [ftbclan.net]~",GameType="xCTFGame",Flags=2))
     ServerCache(54)=(GameType="XGame.xCTFGame",SRL=(IP="74.91.122.9",QueryPort=7778,ServerName="Ð@Ð|PIG|@ø@LockDown's Prison",GameType="xCTFGame",Flags=22))
     ServerCache(55)=(GameType="XGame.xCTFGame",SRL=(IP="68.232.172.11",QueryPort=7778,ServerName="@ø@=sKm= Supreme Killing Machines @øøLGI CTF 1.35 øø@/ ø@@IG BR 1.35 °°ø-- Chicago --",GameType="xCTFGame",Flags=22))
     ServerCache(56)=(GameType="XGame.xCTFGame",SRL=(IP="69.195.145.202",QueryPort=4445,ServerName="[ A2K4.COM ] UT2004 CTF Server",GameType="xCTFGame",Flags=38))
     ServerCache(57)=(GameType="XGame.xCTFGame",SRL=(IP="71.83.51.18",QueryPort=7778,ServerName="Johnny'sÂ UT2K4Â Server",GameType="xCTFGame",Flags=36))
     ServerCache(58)=(GameType="XGame.xCTFGame",SRL=(IP="66.55.137.102",QueryPort=7778,ServerName="72.5.102.229:7777",GameType="xCTFGame",Flags=5))
     ServerCache(59)=(GameType="XGame.xCTFGame",SRL=(IP="195.181.242.143",QueryPort=9778,ServerName="ø€@Koffees ø¢@CTF øàÀPUG øðàcServer |Lithuania",GameType="xCTFGame",Flags=4))
     ServerCache(60)=(GameType="XGame.xCTFGame",SRL=(IP="74.91.115.67",QueryPort=7778,ServerName="222-A.AeQ*Q`a&a.q`q €€In  s°°t¿¿aÏÏGßßIïïB  ÿÿÿ[ÿÿÿiÿîÿCÿÝÿTÿÌÿFÿ»ÿ ÿÿÿ|þ©þ ÿ™ÿiþ‡þDÿvÿMÿeÿ ÿÿÿ|ÿTÿ ÿCÿiÿ2ÿTÿ!ÿDÿÿM ÿÿÿ] ÿFëa'×'C:Ä:eÿÿÿ/N°NBbœbo",GameType="xCTFGame",Flags=2))
     ServerCache(61)=(GameType="XGame.xCTFGame",SRL=(IP="188.40.254.109",QueryPort=4445,ServerName="[YAF] CTF-Turnierserver 1",GameType="xCTFGame",Flags=7))
     ServerCache(62)=(GameType="XGame.xCTFGame",SRL=(IP="54.37.16.59",QueryPort=7778,ServerName="UT2004 Server",GameType="xCTFGame",Flags=32))
     ServerCache(63)=(GameType="XGame.xCTFGame",SRL=(IP="116.202.112.178",QueryPort=10000,ServerName="***  @@@UTø@@zoneøø@.de  *** iCTF | by Donzi.TV",GameType="xCTFGame",Flags=22))
     ServerCache(64)=(GameType="XGame.xCTFGame",SRL=(IP="116.202.112.178",QueryPort=5556,ServerName="***  @@@UTø@@zoneøø@.de  *** LowGrav iCTF | by Donzi.TV",GameType="xCTFGame",Flags=22))
     ServerCache(65)=(GameType="XGame.xCTFGame",SRL=(IP="159.69.223.132",QueryPort=6778,ServerName="*** ut-X.net CTF Face ***",GameType="xCTFGame",Flags=6))
     ServerCache(66)=(GameType="XGame.xCTFGame",SRL=(IP="81.30.148.29",QueryPort=31301,ServerName="€€€Fair-ø€@Gamers °°øUT2004 »Multi[2|4]TEAMS« CTF&iCTF Server #13",GameType="xCTFGame",Flags=6))
     ServerCache(67)=(GameType="XGame.xCTFGame",SRL=(IP="95.179.198.193",QueryPort=7778,ServerName="electronoob test",GameType="xCTFGame",Flags=36))
     ServerCache(68)=(GameType="XGame.xCTFGame",SRL=(IP="81.30.148.30",QueryPort=33001,ServerName="€€€Fair-ø€@Gamers °°øUT2004 iCTF Server #30",GameType="xCTFGame",Flags=22))
     ServerCache(69)=(GameType="XGame.xCTFGame",SRL=(IP="81.30.148.29",QueryPort=32301,ServerName="€€€Fair-ø€@Gamers °°øUT2004 CB-Match iCTF Server #23",GameType="xCTFGame",Flags=23))
     ServerCache(70)=(GameType="XGame.xCTFGame",SRL=(IP="81.30.148.30",QueryPort=32001,ServerName="€€€Fair-ø€@Gamers °°øUT2004 CTF »BridgeOfFate&FaceClassic« Server #20",GameType="xCTFGame",Flags=32))
     ServerCache(71)=(GameType="XGame.xCTFGame",SRL=(IP="91.121.168.34",QueryPort=27316,ServerName="UT2004 Server",GameType="xCTFGame",Flags=32))
     ServerCache(72)=(GameType="XGame.xCTFGame",SRL=(IP="80.127.236.69",QueryPort=7978,ServerName="Na Pali CTF server",GameType="xCTFGame",Flags=36))
     ServerCache(73)=(GameType="XGame.xCTFGame",SRL=(IP="81.30.148.30",QueryPort=32401,ServerName="€€€Fair-ø€@Gamers °°øUT2004 CB-Match iCTF Server #24",GameType="xCTFGame",Flags=23))
     ServerCache(74)=(GameType="XGame.xCTFGame",SRL=(IP="81.30.148.29",QueryPort=30901,ServerName="€€€Fair-ø€@Gamers °°øUT2004 iCTF Server #9",GameType="xCTFGame",Flags=22))
     ServerCache(75)=(GameType="XGame.InstagibCTF",SRL=(IP="134.255.253.93",QueryPort=8138,ServerName="Bloxeh Battleground by DNW",GameType="xCTFGame",Flags=22))
     ServerCache(76)=(GameType="XGame.InstagibCTF",SRL=(IP="134.255.253.93",QueryPort=8138,ServerName="Bloxeh Battleground by DNW",GameType="xCTFGame",Flags=22))
     ServerCache(77)=(GameType="XGame.InstagibCTF",SRL=(IP="134.255.253.93",QueryPort=8138,ServerName="Bloxeh Battleground by DNW",GameType="xCTFGame",Flags=22))
     ServerCache(78)=(GameType="XGame.InstagibCTF",SRL=(IP="134.255.253.93",QueryPort=8138,ServerName="Bloxeh Battleground by DNW",GameType="xCTFGame",Flags=22))
     ServerCache(79)=(GameType="XGame.InstagibCTF",SRL=(IP="134.255.253.93",QueryPort=8138,ServerName="Bloxeh Battleground by DNW",GameType="xCTFGame",Flags=22))
     ServerCache(80)=(GameType="XGame.InstagibCTF",SRL=(IP="134.255.253.93",QueryPort=8138,ServerName="Bloxeh Battleground by DNW",GameType="xCTFGame",Flags=22))
     ServerCache(81)=(GameType="XGame.InstagibCTF",SRL=(IP="134.255.253.93",QueryPort=8138,ServerName="Bloxeh Battleground by DNW",GameType="xCTFGame",Flags=22))
     ServerCache(82)=(GameType="XGame.InstagibCTF",SRL=(IP="134.255.253.93",QueryPort=8138,ServerName="Bloxeh Battleground by DNW",GameType="xCTFGame",Flags=22))
     ServerCache(83)=(GameType="XGame.InstagibCTF",SRL=(IP="134.255.253.93",QueryPort=8138,ServerName="Bloxeh Battleground by DNW",GameType="xCTFGame",Flags=22))
     ServerCache(84)=(GameType="XGame.InstagibCTF",SRL=(IP="134.255.253.93",QueryPort=8138,ServerName="Bloxeh Battleground by DNW",GameType="xCTFGame",Flags=22))
     ServerCache(85)=(GameType="XGame.InstagibCTF",SRL=(IP="134.255.253.93",QueryPort=8138,ServerName="Bloxeh Battleground by DNW",GameType="xCTFGame",Flags=22))
     ServerCache(86)=(GameType="XGame.InstagibCTF",SRL=(IP="134.255.253.93",QueryPort=8138,ServerName="Bloxeh Battleground by DNW",GameType="xCTFGame",Flags=22))
     ServerCache(87)=(GameType="XGame.InstagibCTF",SRL=(IP="173.54.142.17",QueryPort=7778,ServerName="SlottedPig's UT2004",GameType="xCTFGame",Flags=20))
     ServerCache(88)=(GameType="XGame.InstagibCTF",SRL=(IP="72.5.102.65",QueryPort=7778,ServerName="ø@@Froz3n F0015ø@@øø@,øø@ø@@ B0mBing Runnersø@@øø@ andøø@ ø@@Flag 5natcher5ø@@",GameType="xCTFGame",Flags=22))
     ServerCache(89)=(GameType="XGame.InstagibCTF",SRL=(IP="74.91.122.9",QueryPort=7778,ServerName="|PIG|LockDown's Instagib Prison",GameType="xCTFGame",Flags=22))
     ServerCache(90)=(GameType="XGame.InstagibCTF",SRL=(IP="74.91.115.67",QueryPort=7778,ServerName="222-A.AeQ*Q`a&a.q`q €€In  s°°t¿¿aÏÏGßßIïïB  ÿÿÿ[ÿiîC`ÝT3ÌFD» ÿÿÿ|U© f™iw‡DˆvM™e ÿÿÿ|ªT »CiÌ2TÝ!DîM ÿÿÿ] ÿFÿa'ÿC:ÿeÿÿÿ/NÿBbÿo",GameType="xCTFGame",Flags=2))
     ServerCache(91)=(GameType="XGame.InstagibCTF",SRL=(IP="82.76.117.248",QueryPort=7778,ServerName="Andy",GameType="InstagibCTF",Flags=29))
     ServerCache(92)=(GameType="XGame.InstagibCTF",SRL=(IP="85.25.35.29",QueryPort=7778,ServerName="ZoomInstagibÂ CTF/DM/BR/DOMÂ w/Bots",GameType="xCTFGame",Flags=20))
     ServerCache(93)=(GameType="XGame.InstagibCTF",SRL=(IP="134.255.253.90",QueryPort=10000,ServerName="***  @@@UTø@@zoneøø@.de  *** iCTF | by DNW",GameType="xCTFGame",Flags=22))
     ServerCache(94)=(GameType="XGame.InstagibCTF",SRL=(IP="134.255.253.93",QueryPort=8138,ServerName="Bloxeh Battleground by DNW",GameType="xCTFGame",Flags=22))
     ServerCache(95)=(GameType="XGame.InstagibCTF",SRL=(IP="81.30.148.30",QueryPort=32401,ServerName="€€€Fair-ø€@Gamers °°øUT2004 CB-Match iCTF Server #24",GameType="xCTFGame",Flags=23))
     ServerCache(96)=(GameType="XGame.InstagibCTF",SRL=(IP="81.30.148.30",QueryPort=33001,ServerName="€€€Fair-ø€@Gamers °°øUT2004 iCTF Server #30",GameType="xCTFGame",Flags=22))
     ServerCache(97)=(GameType="XGame.InstagibCTF",SRL=(IP="81.30.148.29",QueryPort=32301,ServerName="€€€Fair-ø€@Gamers °°øUT2004 CB-Match iCTF Server #23",GameType="xCTFGame",Flags=23))
     ServerCache(98)=(GameType="XGame.InstagibCTF",SRL=(IP="134.255.253.90",QueryPort=16001,ServerName="***  @@@UTø@@zoneøø@.de  *** War ONE | by DNW",GameType="InstagibCTF",Flags=23))
     ServerCache(99)=(GameType="XGame.InstagibCTF",SRL=(IP="81.30.148.29",QueryPort=30901,ServerName="€€€Fair-ø€@Gamers °°øUT2004 iCTF Server #9",GameType="xCTFGame",Flags=22))
     ServerCache(100)=(GameType="XGame.InstagibCTF",SRL=(IP="81.30.148.29",QueryPort=31901,ServerName="€€€Fair-ø€@Gamers °°øUT2004 iCTF LGI »BridgeOfFate&FaceClassic« Server #19",GameType="InstagibCTF",Flags=16))
     ServerCache(101)=(GameType="XGame.InstagibCTF",SRL=(IP="31.186.251.20",QueryPort=7778,ServerName="ooo-øøø*ÿ3[`ÿRezQÿ3]øøø*ooo- 222I088C.??T-FFF +MM| )TT[([[W&aaa$hhr#oon!vvi}}n„„gŠŠ: ‘‘M˜˜aŸŸy ¦¦c­­o³³nººtÁÁaÈÈiÏÏn ÖÖNÜÜuããtêêzññ!øø]",GameType="xCTFGame",Flags=22))
     ServerCache(102)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=30501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 Freon,TAM,AM @°@[PRIVATE] °°øServer #5",GameType="TeamArenaMaster",Flags=7))
     ServerCache(103)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=30501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 Freon,TAM,AM @°@[PRIVATE] °°øServer #5",GameType="TeamArenaMaster",Flags=7))
     ServerCache(104)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=30501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 Freon,TAM,AM @°@[PRIVATE] °°øServer #5",GameType="TeamArenaMaster",Flags=7))
     ServerCache(105)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=30501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 Freon,TAM,AM @°@[PRIVATE] °°øServer #5",GameType="TeamArenaMaster",Flags=7))
     ServerCache(106)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=30501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 Freon,TAM,AM @°@[PRIVATE] °°øServer #5",GameType="TeamArenaMaster",Flags=7))
     ServerCache(107)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=30501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 Freon,TAM,AM @°@[PRIVATE] °°øServer #5",GameType="TeamArenaMaster",Flags=7))
     ServerCache(108)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=30501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 Freon,TAM,AM @°@[PRIVATE] °°øServer #5",GameType="TeamArenaMaster",Flags=7))
     ServerCache(109)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=30501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 Freon,TAM,AM @°@[PRIVATE] °°øServer #5",GameType="TeamArenaMaster",Flags=7))
     ServerCache(110)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=30501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 Freon,TAM,AM @°@[PRIVATE] °°øServer #5",GameType="TeamArenaMaster",Flags=7))
     ServerCache(111)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=30501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 Freon,TAM,AM @°@[PRIVATE] °°øServer #5",GameType="TeamArenaMaster",Flags=7))
     ServerCache(112)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=30501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 Freon,TAM,AM @°@[PRIVATE] °°øServer #5",GameType="TeamArenaMaster",Flags=7))
     ServerCache(113)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=30501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 Freon,TAM,AM @°@[PRIVATE] °°øServer #5",GameType="TeamArenaMaster",Flags=7))
     ServerCache(114)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=30501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 Freon,TAM,AM @°@[PRIVATE] °°øServer #5",GameType="TeamArenaMaster",Flags=7))
     ServerCache(115)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=30501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 Freon,TAM,AM @°@[PRIVATE] °°øServer #5",GameType="TeamArenaMaster",Flags=7))
     ServerCache(116)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=30501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 Freon,TAM,AM @°@[PRIVATE] °°øServer #5",GameType="TeamArenaMaster",Flags=7))
     ServerCache(117)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=30501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 Freon,TAM,AM @°@[PRIVATE] °°øServer #5",GameType="TeamArenaMaster",Flags=7))
     ServerCache(118)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.30",QueryPort=31401,ServerName="€€€Fair-ø€@Gamers °°øUT2004 CB-Match TAM Server #14",GameType="TeamArenaMaster",Flags=7))
     ServerCache(119)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.30",QueryPort=31401,ServerName="€€€Fair-ø€@Gamers °°øUT2004 CB-Match TAM Server #14",GameType="TeamArenaMaster",Flags=7))
     ServerCache(120)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.30",QueryPort=31401,ServerName="€€€Fair-ø€@Gamers °°øUT2004 CB-Match TAM Server #14",GameType="TeamArenaMaster",Flags=7))
     ServerCache(121)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.30",QueryPort=31401,ServerName="€€€Fair-ø€@Gamers °°øUT2004 CB-Match TAM Server #14",GameType="TeamArenaMaster",Flags=7))
     ServerCache(122)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=31501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 CB-Match TAM Server #15",GameType="TeamArenaMaster",Flags=7))
     ServerCache(123)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=31501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 CB-Match TAM Server #15",GameType="TeamArenaMaster",Flags=7))
     ServerCache(124)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=31501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 CB-Match TAM Server #15",GameType="TeamArenaMaster",Flags=7))
     ServerCache(125)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=31501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 CB-Match TAM Server #15",GameType="TeamArenaMaster",Flags=7))
     ServerCache(126)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.30",QueryPort=31401,ServerName="€€€Fair-ø€@Gamers °°øUT2004 CB-Match TAM Server #14",GameType="TeamArenaMaster",Flags=7))
     ServerCache(127)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.30",QueryPort=31401,ServerName="€€€Fair-ø€@Gamers °°øUT2004 CB-Match TAM Server #14",GameType="TeamArenaMaster",Flags=7))
     ServerCache(128)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.30",QueryPort=31401,ServerName="€€€Fair-ø€@Gamers °°øUT2004 CB-Match TAM Server #14",GameType="TeamArenaMaster",Flags=7))
     ServerCache(129)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.30",QueryPort=31401,ServerName="€€€Fair-ø€@Gamers °°øUT2004 CB-Match TAM Server #14",GameType="TeamArenaMaster",Flags=7))
     ServerCache(130)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=30501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 Freon,TAM,AM @°@[PRIVATE] °°øServer #5",GameType="TeamArenaMaster",Flags=7))
     ServerCache(131)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=30501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 Freon,TAM,AM @°@[PRIVATE] °°øServer #5",GameType="TeamArenaMaster",Flags=7))
     ServerCache(132)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=30501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 Freon,TAM,AM @°@[PRIVATE] °°øServer #5",GameType="TeamArenaMaster",Flags=7))
     ServerCache(133)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=30501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 Freon,TAM,AM @°@[PRIVATE] °°øServer #5",GameType="TeamArenaMaster",Flags=7))
     ServerCache(134)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.30",QueryPort=31401,ServerName="€€€Fair-ø€@Gamers °°øUT2004 CB-Match TAM Server #14",GameType="TeamArenaMaster",Flags=7))
     ServerCache(135)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.30",QueryPort=31401,ServerName="€€€Fair-ø€@Gamers °°øUT2004 CB-Match TAM Server #14",GameType="TeamArenaMaster",Flags=7))
     ServerCache(136)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.30",QueryPort=31401,ServerName="€€€Fair-ø€@Gamers °°øUT2004 CB-Match TAM Server #14",GameType="TeamArenaMaster",Flags=7))
     ServerCache(137)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.30",QueryPort=31401,ServerName="€€€Fair-ø€@Gamers °°øUT2004 CB-Match TAM Server #14",GameType="TeamArenaMaster",Flags=7))
     ServerCache(138)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=30501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 Freon,TAM,AM @°@[PRIVATE] °°øServer #5",GameType="TeamArenaMaster",Flags=7))
     ServerCache(139)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=30501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 Freon,TAM,AM @°@[PRIVATE] °°øServer #5",GameType="TeamArenaMaster",Flags=7))
     ServerCache(140)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=30501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 Freon,TAM,AM @°@[PRIVATE] °°øServer #5",GameType="TeamArenaMaster",Flags=7))
     ServerCache(141)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=30501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 Freon,TAM,AM @°@[PRIVATE] °°øServer #5",GameType="TeamArenaMaster",Flags=7))
     ServerCache(142)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=30501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 Freon,TAM,AM @°@[PRIVATE] °°øServer #5",GameType="TeamArenaMaster",Flags=7))
     ServerCache(143)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.30",QueryPort=31401,ServerName="€€€Fair-ø€@Gamers °°øUT2004 CB-Match TAM Server #14",GameType="TeamArenaMaster",Flags=7))
     ServerCache(144)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.30",QueryPort=31401,ServerName="€€€Fair-ø€@Gamers °°øUT2004 CB-Match TAM Server #14",GameType="TeamArenaMaster",Flags=7))
     ServerCache(145)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.30",QueryPort=31401,ServerName="€€€Fair-ø€@Gamers °°øUT2004 CB-Match TAM Server #14",GameType="TeamArenaMaster",Flags=7))
     ServerCache(146)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.30",QueryPort=31401,ServerName="€€€Fair-ø€@Gamers °°øUT2004 CB-Match TAM Server #14",GameType="TeamArenaMaster",Flags=7))
     ServerCache(147)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.30",QueryPort=31401,ServerName="€€€Fair-ø€@Gamers °°øUT2004 CB-Match TAM Server #14",GameType="TeamArenaMaster",Flags=7))
     ServerCache(148)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="81.30.148.29",QueryPort=31501,ServerName="€€€Fair-ø€@Gamers °°øUT2004 CB-Match TAM Server #15",GameType="TeamArenaMaster",Flags=7))
     ServerCache(149)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="5.39.66.97",QueryPort=7828,ServerName="=F.F.M=Clan-TAM-Server",GameType="TeamArenaMaster",Flags=6))
     ServerCache(150)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="5.39.66.97",QueryPort=7828,ServerName="=F.F.M=Clan-TAM-Server",GameType="TeamArenaMaster",Flags=6))
     ServerCache(151)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="5.39.66.97",QueryPort=7828,ServerName="=F.F.M=Clan-TAM-Server",GameType="TeamArenaMaster",Flags=6))
     ServerCache(152)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="5.39.66.97",QueryPort=7828,ServerName="=F.F.M=Clan-TAM-Server",GameType="TeamArenaMaster",Flags=6))
     ServerCache(153)=(GameType="3SPNv3141.TeamArenaMaster",SRL=(IP="5.39.66.97",QueryPort=7828,ServerName="=F.F.M=Clan-TAM-Server",GameType="TeamArenaMaster",Flags=6))
     ServerCache(154)=(GameType="XGame.xDeathMatch",SRL=(IP="107.191.50.234",QueryPort=7778,ServerName="@ø@{IK}*LAIR øf PAIN* -2017-FRAGFEST- @øøALL CUSTOM WEAPONRY / Pro-Zark Elite IK-2017",GameType="xDeathMatch",Flags=6))
     ServerCache(155)=(GameType="XGame.xDeathMatch",SRL=(IP="107.191.50.234",QueryPort=7778,ServerName="@ø@{IK}*LAIR øf PAIN* -2017-FRAGFEST- @øøALL CUSTOM WEAPONRY / Pro-Zark Elite IK-2017",GameType="xDeathMatch",Flags=6))
     ServerCache(156)=(GameType="XGame.xDeathMatch",SRL=(IP="107.191.50.234",QueryPort=7778,ServerName="@ø@{IK}*LAIR øf PAIN* -2017-FRAGFEST- @øøALL CUSTOM WEAPONRY / Pro-Zark Elite IK-2017",GameType="xDeathMatch",Flags=6))
     ServerCache(157)=(GameType="XGame.xDeathMatch",SRL=(IP="107.191.50.234",QueryPort=7778,ServerName="@ø@{IK}*LAIR øf PAIN* -2017-FRAGFEST- @øøALL CUSTOM WEAPONRY / Pro-Zark Elite IK-2017",GameType="xDeathMatch",Flags=6))
     ServerCache(158)=(GameType="XGame.xDeathMatch",SRL=(IP="107.191.50.234",QueryPort=7778,ServerName="@ø@{IK}*LAIR øf PAIN* -2017-FRAGFEST- @øøALL CUSTOM WEAPONRY / Pro-Zark Elite IK-2017",GameType="xDeathMatch",Flags=6))
     ServerCache(159)=(GameType="XGame.xDeathMatch",SRL=(IP="107.191.50.234",QueryPort=7778,ServerName="@ø@{IK}*LAIR øf PAIN* -2017-FRAGFEST- @øøALL CUSTOM WEAPONRY / Pro-Zark Elite IK-2017",GameType="xDeathMatch",Flags=6))
     ServerCache(160)=(GameType="XGame.xDeathMatch",SRL=(IP="107.191.50.234",QueryPort=7778,ServerName="@ø@{IK}*LAIR øf PAIN* -2017-FRAGFEST- @øøALL CUSTOM WEAPONRY / Pro-Zark Elite IK-2017",GameType="xDeathMatch",Flags=6))
     ServerCache(161)=(GameType="XGame.xDeathMatch",SRL=(IP="199.175.53.150",QueryPort=7778,ServerName="ø@@Old Dudes/Dames @@øSniper - øø@Campers Only",GameType="xDeathMatch",Flags=4))
     ServerCache(162)=(GameType="XGame.xDeathMatch",SRL=(IP="199.175.53.150",QueryPort=7778,ServerName="ø@@Old Dudes/Dames @@øSniper - øø@Campers Only",GameType="xDeathMatch",Flags=4))
     ServerCache(163)=(GameType="XGame.xDeathMatch",SRL=(IP="199.175.53.150",QueryPort=7778,ServerName="ø@@Old Dudes/Dames @@øSniper - øø@Campers Only",GameType="xDeathMatch",Flags=4))
     ServerCache(164)=(GameType="XGame.xDeathMatch",SRL=(IP="199.175.53.150",QueryPort=7778,ServerName="ø@@Old Dudes/Dames @@øSniper - øø@Campers Only",GameType="xDeathMatch",Flags=4))
     ServerCache(165)=(GameType="XGame.xDeathMatch",SRL=(IP="199.175.53.150",QueryPort=7778,ServerName="ø@@Old Dudes/Dames @@øSniper - øø@Campers Only",GameType="xDeathMatch",Flags=4))
     ServerCache(166)=(GameType="XGame.xDeathMatch",SRL=(IP="31.186.250.42",QueryPort=7778,ServerName="ÿ{TR} ***NO.1 TEAM ARENA MASTER SERVER***",GameType="xDeathMatch",Flags=6))
     ServerCache(167)=(GameType="XGame.xDeathMatch",SRL=(IP="31.186.250.42",QueryPort=7778,ServerName="ÿ{TR} ***NO.1 TEAM ARENA MASTER SERVER***",GameType="xDeathMatch",Flags=6))
     ServerCache(168)=(GameType="XGame.xDeathMatch",SRL=(IP="31.186.250.42",QueryPort=7778,ServerName="ÿ{TR} ***NO.1 TEAM ARENA MASTER SERVER***",GameType="xDeathMatch",Flags=6))
     ServerCache(169)=(GameType="XGame.xDeathMatch",SRL=(IP="31.186.250.42",QueryPort=7778,ServerName="ÿ{TR} ***NO.1 TEAM ARENA MASTER SERVER***",GameType="xDeathMatch",Flags=6))
     ServerCache(170)=(GameType="XGame.xDeathMatch",SRL=(IP="31.186.250.42",QueryPort=7778,ServerName="ÿ{TR} ***NO.1 TEAM ARENA MASTER SERVER***",GameType="xDeathMatch",Flags=6))
     ServerCache(171)=(GameType="XGame.xDeathMatch",SRL=(IP="31.186.250.42",QueryPort=7778,ServerName="ÿ{TR} ***NO.1 TEAM ARENA MASTER SERVER***",GameType="xDeathMatch",Flags=6))
     ServerCache(172)=(GameType="XGame.xDeathMatch",SRL=(IP="31.186.250.42",QueryPort=7778,ServerName="ÿ{TR} ***NO.1 TEAM ARENA MASTER SERVER***",GameType="xDeathMatch",Flags=6))
     ServerCache(173)=(GameType="XGame.xDeathMatch",SRL=(IP="31.186.250.42",QueryPort=7778,ServerName="ÿ{TR} ***NO.1 TEAM ARENA MASTER SERVER***",GameType="xDeathMatch",Flags=6))
     ServerCache(174)=(GameType="XGame.xDeathMatch",SRL=(IP="31.186.250.42",QueryPort=7778,ServerName="ÿ{TR} ***NO.1 TEAM ARENA MASTER SERVER***",GameType="xDeathMatch",Flags=6))
     ServerCache(175)=(GameType="XGame.xDeathMatch",SRL=(IP="31.186.250.42",QueryPort=7778,ServerName="ÿ{TR} ***NO.1 TEAM ARENA MASTER SERVER***",GameType="xDeathMatch",Flags=6))
     ServerCache(176)=(GameType="XGame.xDeathMatch",SRL=(IP="31.186.250.42",QueryPort=7778,ServerName="ÿ{TR} ***NO.1 TEAM ARENA MASTER SERVER***",GameType="xDeathMatch",Flags=6))
     ServerCache(177)=(GameType="XGame.xDeathMatch",SRL=(IP="31.186.250.42",QueryPort=7778,ServerName="ÿ{TR} ***NO.1 TEAM ARENA MASTER SERVER***",GameType="xDeathMatch",Flags=6))
     ServerCache(178)=(GameType="XGame.xDeathMatch",SRL=(IP="199.175.53.150",QueryPort=7778,ServerName="ø@@Old Dudes/Dames @@øSniper - øø@Campers Only",GameType="xDeathMatch",Flags=4))
     ServerCache(179)=(GameType="XGame.xDeathMatch",SRL=(IP="199.175.53.150",QueryPort=7778,ServerName="ø@@Old Dudes/Dames @@øSniper - øø@Campers Only",GameType="xDeathMatch",Flags=4))
     ServerCache(180)=(GameType="XGame.xDeathMatch",SRL=(IP="199.175.53.150",QueryPort=7778,ServerName="ø@@Old Dudes/Dames @@øSniper - øø@Campers Only",GameType="xDeathMatch",Flags=4))
     ServerCache(181)=(GameType="XGame.xDeathMatch",SRL=(IP="199.175.53.150",QueryPort=7778,ServerName="ø@@Old Dudes/Dames @@øSniper - øø@Campers Only",GameType="xDeathMatch",Flags=4))
     ServerCache(182)=(GameType="XGame.xDeathMatch",SRL=(IP="199.175.53.150",QueryPort=7778,ServerName="ø@@Old Dudes/Dames @@øSniper - øø@Campers Only",GameType="xDeathMatch",Flags=4))
     ServerCache(183)=(GameType="XGame.xDeathMatch",SRL=(IP="107.191.50.234",QueryPort=7778,ServerName="@ø@{IK}*LAIR øf PAIN* -2017-FRAGFEST- @øøALL CUSTOM WEAPONRY / Pro-Zark Elite IK-2017",GameType="xDeathMatch",Flags=6))
     ServerCache(184)=(GameType="XGame.xDeathMatch",SRL=(IP="107.191.50.234",QueryPort=7778,ServerName="@ø@{IK}*LAIR øf PAIN* -2017-FRAGFEST- @øøALL CUSTOM WEAPONRY / Pro-Zark Elite IK-2017",GameType="xDeathMatch",Flags=6))
     ServerCache(185)=(GameType="XGame.xDeathMatch",SRL=(IP="107.191.50.234",QueryPort=7778,ServerName="@ø@{IK}*LAIR øf PAIN* -2017-FRAGFEST- @øøALL CUSTOM WEAPONRY / Pro-Zark Elite IK-2017",GameType="xDeathMatch",Flags=6))
     ServerCache(186)=(GameType="XGame.xDeathMatch",SRL=(IP="68.232.181.37",QueryPort=7778,ServerName="@ø@IK-Plåygrøúnd øf Légénds @@ø(@øøFreeStyle-ZARK/SNIPER@@ø) Ð@Ð*NEW* Stealth Rifle",GameType="xDeathMatch",Flags=6))
     ServerCache(187)=(GameType="XGame.xDeathMatch",SRL=(IP="68.232.181.37",QueryPort=7778,ServerName="@ø@IK-Plåygrøúnd øf Légénds @@ø(@øøFreeStyle-ZARK/SNIPER@@ø) Ð@Ð*NEW* Stealth Rifle",GameType="xDeathMatch",Flags=6))
     ServerCache(188)=(GameType="XGame.xDeathMatch",SRL=(IP="68.232.181.37",QueryPort=7778,ServerName="@ø@IK-Plåygrøúnd øf Légénds @@ø(@øøFreeStyle-ZARK/SNIPER@@ø) Ð@Ð*NEW* Stealth Rifle",GameType="xDeathMatch",Flags=6))
     ServerCache(189)=(GameType="XGame.xDeathMatch",SRL=(IP="68.232.181.37",QueryPort=7778,ServerName="@ø@IK-Plåygrøúnd øf Légénds @@ø(@øøFreeStyle-ZARK/SNIPER@@ø) Ð@Ð*NEW* Stealth Rifle",GameType="xDeathMatch",Flags=6))
     ServerCache(190)=(GameType="XGame.xDeathMatch",SRL=(IP="68.232.181.37",QueryPort=7778,ServerName="@ø@IK-Plåygrøúnd øf Légénds @@ø(@øøFreeStyle-ZARK/SNIPER@@ø) Ð@Ð*NEW* Stealth Rifle",GameType="xDeathMatch",Flags=6))
     ServerCache(191)=(GameType="XGame.xDeathMatch",SRL=(IP="68.232.181.37",QueryPort=7778,ServerName="@ø@IK-Plåygrøúnd øf Légénds @@ø(@øøFreeStyle-ZARK/SNIPER@@ø) Ð@Ð*NEW* Stealth Rifle",GameType="xDeathMatch",Flags=6))
     ServerCache(192)=(GameType="XGame.xDeathMatch",SRL=(IP="68.232.181.37",QueryPort=7778,ServerName="@ø@IK-Plåygrøúnd øf Légénds @@ø(@øøFreeStyle-ZARK/SNIPER@@ø) Ð@Ð*NEW* Stealth Rifle",GameType="xDeathMatch",Flags=6))
     ServerCache(193)=(GameType="XGame.xDeathMatch",SRL=(IP="68.232.181.37",QueryPort=7778,ServerName="@ø@IK-Plåygrøúnd øf Légénds @@ø(@øøFreeStyle-ZARK/SNIPER@@ø) Ð@Ð*NEW* Stealth Rifle",GameType="xDeathMatch",Flags=6))
     ServerCache(194)=(GameType="XGame.xDeathMatch",SRL=(IP="81.30.148.30",QueryPort=32801,ServerName="€€€Fair-ø€@Gamers °°øUT2004 DM »Rankin-only« Server #28",GameType="xDeathMatch",Flags=32))
     ServerCache(195)=(GameType="XGame.xDeathMatch",SRL=(IP="81.30.148.30",QueryPort=32801,ServerName="€€€Fair-ø€@Gamers °°øUT2004 DM »Rankin-only« Server #28",GameType="xDeathMatch",Flags=32))
     ServerCache(196)=(GameType="XGame.xDeathMatch",SRL=(IP="81.30.148.30",QueryPort=32801,ServerName="€€€Fair-ø€@Gamers °°øUT2004 DM »Rankin-only« Server #28",GameType="xDeathMatch",Flags=32))
     ServerCache(197)=(GameType="XGame.xDeathMatch",SRL=(IP="75.138.188.88",QueryPort=7778,ServerName="ø@@***** @@øHAPPY SERVER ø@@***** ø@@Kill À@@them €@@all @ø@!!!",GameType="xDeathMatch",Flags=4))
     ServerCache(198)=(GameType="XGame.xDeathMatch",SRL=(IP="75.138.188.88",QueryPort=7778,ServerName="ø@@***** @@øHAPPY SERVER ø@@***** ø@@Kill À@@them €@@all @ø@!!!",GameType="xDeathMatch",Flags=4))
     ServerCache(199)=(GameType="XGame.xDeathMatch",SRL=(IP="75.138.188.88",QueryPort=7778,ServerName="ø@@***** @@øHAPPY SERVER ø@@***** ø@@Kill À@@them €@@all @ø@!!!",GameType="xDeathMatch",Flags=4))
     ServerCache(200)=(GameType="XGame.xDeathMatch",SRL=(IP="178.218.212.82",QueryPort=7778,ServerName="ÿ‚‚TÿllyÿSSkÿ>>iÿ``TÿaôkáiÊ.·r®u #1",GameType="xDeathMatch",Flags=4))
     ServerCache(201)=(GameType="XGame.xDeathMatch",SRL=(IP="178.218.212.82",QueryPort=7778,ServerName="ÿ‚‚TÿllyÿSSkÿ>>iÿ``TÿaôkáiÊ.·r®u #1",GameType="xDeathMatch",Flags=4))
     ServerCache(202)=(GameType="XGame.xDeathMatch",SRL=(IP="178.218.212.82",QueryPort=7778,ServerName="ÿ‚‚TÿllyÿSSkÿ>>iÿ``TÿaôkáiÊ.·r®u #1",GameType="xDeathMatch",Flags=4))
     ServerCache(203)=(GameType="XGame.xDeathMatch",SRL=(IP="178.218.212.82",QueryPort=7778,ServerName="ÿ‚‚TÿllyÿSSkÿ>>iÿ``TÿaôkáiÊ.·r®u #1",GameType="xDeathMatch",Flags=4))
     ServerCache(204)=(GameType="XGame.xDeathMatch",SRL=(IP="8.3.6.15",QueryPort=7778,ServerName="ø@@*HoE*ø@øHouse of Evil*@øøBallistics From Hell*",GameType="xDeathMatch",Flags=6))
     ServerCache(205)=(GameType="XGame.xDeathMatch",SRL=(IP="91.19.55.178",QueryPort=7778,ServerName="vogel",GameType="xDeathMatch",Flags=13))
     ServerCache(206)=(GameType="XGame.xDeathMatch",SRL=(IP="149.210.146.142",QueryPort=8719,ServerName="ø¢@[€€€Coreø¢@] øÈ-=øøøFreonøÈ =-        ø@@[€€€NLø@@] ø@@Amsterdam        €€€www.corenation.com",GameType="xDeathMatch",Flags=6))
     ServerCache(207)=(GameType="XGame.xDeathMatch",SRL=(IP="87.153.52.227",QueryPort=7778,ServerName="ESH-2(Erftstädter Sterbehilfe)>www.esh-ut.de<",GameType="xDeathMatch",Flags=6))
     ServerCache(208)=(GameType="XGame.xDeathMatch",SRL=(IP="87.153.52.227",QueryPort=7778,ServerName="ESH-2(Erftstädter Sterbehilfe)>www.esh-ut.de<",GameType="xDeathMatch",Flags=6))
     ServerCache(209)=(GameType="XGame.xDeathMatch",SRL=(IP="87.153.52.227",QueryPort=7778,ServerName="ESH-2(Erftstädter Sterbehilfe)>www.esh-ut.de<",GameType="xDeathMatch",Flags=6))
     ServerCache(210)=(GameType="XGame.xDeathMatch",SRL=(IP="87.153.52.227",QueryPort=7778,ServerName="ESH-2(Erftstädter Sterbehilfe)>www.esh-ut.de<",GameType="xDeathMatch",Flags=6))
     ServerCache(211)=(GameType="XGame.xDeathMatch",SRL=(IP="87.153.52.227",QueryPort=7778,ServerName="ESH-2(Erftstädter Sterbehilfe)>www.esh-ut.de<",GameType="xDeathMatch",Flags=6))
     ServerCache(212)=(GameType="XGame.xDeathMatch",SRL=(IP="178.218.212.82",QueryPort=7778,ServerName="ÿ‚‚TÿllyÿSSkÿ>>iÿ``TÿaôkáiÊ.·r®u #1",GameType="xDeathMatch",Flags=4))
     ServerCache(213)=(GameType="XGame.xDeathMatch",SRL=(IP="75.138.188.88",QueryPort=7778,ServerName="ø@@***** @@øHAPPY SERVER ø@@***** ø@@Kill À@@them €@@all @ø@!!!",GameType="xDeathMatch",Flags=4))
     ServerCache(214)=(GameType="XGame.xDeathMatch",SRL=(IP="81.30.148.30",QueryPort=32801,ServerName="€€€Fair-ø€@Gamers °°øUT2004 DM »Rankin-only« Server #28",GameType="xDeathMatch",Flags=32))
     ServerCache(215)=(GameType="XGame.xDeathMatch",SRL=(IP="81.30.148.30",QueryPort=32801,ServerName="€€€Fair-ø€@Gamers °°øUT2004 DM »Rankin-only« Server #28",GameType="xDeathMatch",Flags=32))
     ServerCache(216)=(GameType="XGame.xDeathMatch",SRL=(IP="81.30.148.30",QueryPort=32801,ServerName="€€€Fair-ø€@Gamers °°øUT2004 DM »Rankin-only« Server #28",GameType="xDeathMatch",Flags=32))
     ServerCache(217)=(GameType="XGame.xDeathMatch",SRL=(IP="81.30.148.30",QueryPort=32801,ServerName="€€€Fair-ø€@Gamers °°øUT2004 DM »Rankin-only« Server #28",GameType="xDeathMatch",Flags=32))
     ServerCache(218)=(GameType="XGame.xDeathMatch",SRL=(IP="68.232.181.37",QueryPort=7778,ServerName="@ø@IK-Plåygrøúnd øf Légénds @@ø(@øøFreeStyle-ZARK/SNIPER@@ø) Ð@Ð*NEW* Stealth Rifle",GameType="xDeathMatch",Flags=6))
     ServerCache(219)=(GameType="XGame.xDeathMatch",SRL=(IP="107.191.50.234",QueryPort=7778,ServerName="@ø@{IK}*LAIR øf PAIN* -2017-FRAGFEST- @øøALL CUSTOM WEAPONRY / Pro-Zark Elite IK-2017",GameType="xDeathMatch",Flags=6))
     ServerCache(220)=(GameType="XGame.xDeathMatch",SRL=(IP="199.175.53.150",QueryPort=7778,ServerName="ø@@Old Dudes/Dames @@øSniper - øø@Campers Only",GameType="xDeathMatch",Flags=4))
     ServerCache(221)=(GameType="XGame.xDeathMatch",SRL=(IP="31.186.250.42",QueryPort=7778,ServerName="ÿ{TR} ***NO.1 TEAM ARENA MASTER SERVER***",GameType="xDeathMatch",Flags=6))
     ServerCache(222)=(GameType="Onslaught.ONSOnslaughtGame",SRL=(IP="64.94.100.39",QueryPort=7778,ServerName="Dedicated Torlan Server",GameType="ONSOnslaughtGame",Flags=34))
     ServerCache(223)=(GameType="Onslaught.ONSOnslaughtGame",SRL=(IP="176.185.2.11",QueryPort=7778,ServerName="TRUQUE",GameType="ONSOnslaughtGame",Flags=32))
     ServerCache(224)=(GameType="Onslaught.ONSOnslaughtGame",SRL=(IP="86.86.46.47",QueryPort=7778,ServerName="[ZipCity.nl] dedicated Unreal Tournament 2004 Onslaught serv",GameType="ONSOnslaughtGame",Flags=32))
     ServerCache(225)=(GameType="Onslaught.ONSOnslaughtGame",SRL=(IP="88.159.122.5",QueryPort=7778,ServerName="Veldhoven[nl]Â server",GameType="ONSOnslaughtGame",Flags=38))
     ServerCache(226)=(GameType="Onslaught.ONSOnslaughtGame",SRL=(IP="81.30.148.29",QueryPort=30301,ServerName="€€€Fair-ø€@Gamers °°øUT2004 ONS »BEST default&custom MAPS« Server #3",GameType="ONSOnslaughtGame",Flags=36))
     ServerCache(227)=(GameType="Onslaught.ONSOnslaughtGame",SRL=(IP="208.100.49.221",QueryPort=7778,ServerName="Death Warrant: Spam Vikings",GameType="ONSOnslaughtGame",Flags=38))
     ServerCache(228)=(GameType="Onslaught.ONSOnslaughtGame",SRL=(IP="81.30.148.30",QueryPort=30201,ServerName="€€€Fair-ø€@Gamers °°øUT2004 ONS »Torlan-only« Server #2",GameType="ONSOnslaughtGame",Flags=32))
     ServerCache(229)=(GameType="Onslaught.ONSOnslaughtGame",SRL=(IP="81.30.148.29",QueryPort=30101,ServerName="€€€Fair-ø€@Gamers °°øUT2004 ONS »Torlan-only« Server #1",GameType="ONSOnslaughtGame",Flags=32))
     ServerCache(230)=(GameType="Onslaught.ONSOnslaughtGame",SRL=(IP="50.164.106.138",QueryPort=7778,ServerName="A2K4.COM ONS UT2004 Server",GameType="ONSOnslaughtGame",Flags=38))
     ServerCache(231)=(GameType="Onslaught.ONSOnslaughtGame",SRL=(IP="176.57.143.200",QueryPort=7778,ServerName="@@ÀCEøø@ONS@@ÀS",GameType="ONSOnslaughtGame",Flags=38))
     ServerCache(232)=(GameType="Onslaught.ONSOnslaughtGame",SRL=(IP="208.79.234.80",QueryPort=9001,ServerName="[UTAN] Omnip)o(tentS Onslaught",GameType="ONSOnslaughtGame",Flags=38))
     ServerCache(233)=(GameType="Onslaught.ONSOnslaughtGame",SRL=(IP="162.248.95.126",QueryPort=7988,ServerName="[un]RealMassDestruction",GameType="ONSOnslaughtGame",Flags=38))
     ServerCache(234)=(GameType="Onslaught.ONSOnslaughtGame",SRL=(IP="71.185.188.116",QueryPort=7778,ServerName="Al Gore's Nobel Prize Winning Throbbin House O' Pain",GameType="ONSOnslaughtGame",Flags=32))
     ServerCache(235)=(GameType="Onslaught.ONSOnslaughtGame",SRL=(IP="69.46.6.241",QueryPort=7778,ServerName="UT2004 Server",GameType="ONSOnslaughtGame",Flags=36))
     ServerCache(236)=(GameType="Onslaught.ONSOnslaughtGame",SRL=(IP="195.13.246.182",QueryPort=7782,ServerName="ÿRembo's ÿONS ÿDemo Server",GameType="ONSOnslaughtGame",Flags=34))
     ServerCache(237)=(GameType="Onslaught.ONSOnslaughtGame",SRL=(IP="45.55.35.197",QueryPort=7778,ServerName="UT2004 Server",GameType="ONSOnslaughtGame",Flags=36))
     ServerCache(238)=(GameType="Onslaught.ONSOnslaughtGame",SRL=(IP="46.105.112.91",QueryPort=8041,ServerName="!!![@ø@LDG!!!] @øøBallistic Weapons V2.5 Pro #1: Freon @@ø[FR]",GameType="ONSOnslaughtGame",Flags=38))
     ServerCache(239)=(GameType="Onslaught.ONSOnslaughtGame",SRL=(IP="46.105.112.91",QueryPort=7778,ServerName="!!![@ø@LDG!!!] @øøRacing / Assault - Current: Racing @@ø[FR]",GameType="ONSOnslaughtGame",Flags=38))
     ServerCache(240)=(GameType="Onslaught.ONSOnslaughtGame",SRL=(IP="31.186.250.19",QueryPort=7778,ServerName="@@@[ÿMåi3ÌA@@@] L²Wf™A€€R™eF²LAÌ2RåE @@@| ÿmåiÌ3a²Ls™fm€€ae™.L²o2Ìråg",GameType="ONSOnslaughtGame",Flags=32))
     ServerCache(241)=(GameType="Onslaught.ONSOnslaughtGame",SRL=(IP="88.152.198.76",QueryPort=7178,ServerName="!!!øø@[ÿÿTÿåBÿÌHøø@]  åÿåDÌÿÌE²ÿ²M€ÿ€O €ÿ€3@°@33@€@4 ™ÿO²ÿN@øøS ÿ² =ÿ™ Tÿ€HÿeEÿL Bÿ2LOOÿ  DÿLÿeY ÿ ™HÿåEÿåLÿåLÿÿ€@€ =",GameType="ONSOnslaughtGame",Flags=34))
     ServerCache(242)=(GameType="Onslaught.ONSOnslaughtGame",SRL=(IP="89.163.196.96",QueryPort=7778,ServerName="*AfK*|UT2004|Onslaught",GameType="ONSOnslaughtGame",Flags=38))
     Begin Object Class=GUIHeader Name=ServerBrowserHeader
         bUseTextHeight=True
         Caption="Server Browser"
     End Object
     t_Header=GUIHeader'GUI2K4.UT2k4ServerBrowser.ServerBrowserHeader'

     Begin Object Class=UT2k4Browser_Footer Name=FooterPanel
         WinTop=0.917943
         TabOrder=4
         OnPreDraw=FooterPanel.InternalOnPreDraw
     End Object
     t_Footer=UT2k4Browser_Footer'GUI2K4.UT2k4ServerBrowser.FooterPanel'

     PanelClass(0)="GUI2K4.UT2K4Browser_MOTD"
     PanelClass(1)="GUI2K4.UT2K4Browser_IRC"
     PanelClass(2)="GUI2K4.UT2K4Browser_ServerListPageFavorites"
     PanelClass(3)="GUI2K4.UT2K4Browser_ServerListPageLAN"
     PanelClass(4)="GUI2K4.UT2K4Browser_ServerListPageBuddy"
     PanelClass(5)="GUI2K4.UT2K4Browser_ServerListPageInternet"
     PanelCaption(0)="News"
     PanelCaption(1)="Chat"
     PanelCaption(2)="Favorites"
     PanelCaption(3)="LAN"
     PanelCaption(4)="Buddies"
     PanelCaption(5)="Internet"
     PanelHint(0)="Get the latest news from Epic"
     PanelHint(1)="UT2004 integrated IRC client"
     PanelHint(2)="Choose a server to join from among your favorites"
     PanelHint(3)="View all UT2004 servers currently running on your LAN"
     PanelHint(4)="See where your buddies are currently playing, or join them in the game"
     PanelHint(5)="Choose from hundreds of UT2004 servers across the world"
     bCheckResolution=True
     OnOpen=UT2k4ServerBrowser.BrowserOpened
     bDrawFocusedLast=False
}
