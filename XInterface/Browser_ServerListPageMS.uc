class Browser_ServerListPageMS extends Browser_ServerListPageBase;

var() string GameType;
var() MasterServerClient	MSC;
var() bool bStarted;

var localized string QueryFinHead;
var localized string QueryFinTail;
var localized string PingRecvString;
var localized string MustUpgradeString;
var localized string RefreshFinHead, RefreshFinMid, RefreshFinTail;
var localized string RePingServersCaption;
var localized string RefreshCaption;


function AddQueryTerm(string Key, string GameType, MasterServerClient.EQueryType QueryType)
{
	local MasterServerClient.QueryData QD;
	local int i;

	//Log("["$Key$"] ["$GameType$"] ["$QueryType$"]");

	QD.Key			= Key;
	QD.Value		= GameType;
	QD.QueryType	= QueryType;

	i = MSC.Query.Length;
	MSC.Query.Length = i + 1;
	MSC.Query[i] = QD;
}

function RefreshList()
{
	local int dotPos;
	local string TmpString;

	MyServersList.Clear();

	// Build query
	MSC.Query.Length = 0;
	AddQueryTerm("gametype", GameType, QT_Equals);

	// Add any extra filtering to the query
	if(Browser.bOnlyShowStandard)
		AddQueryTerm("standard", "true", QT_Equals);

	if(Browser.bOnlyShowNonPassword)
		AddQueryTerm("password", "false", QT_Equals);

	if(Browser.bDontShowFull)
		AddQueryTerm("freespace", "0", QT_GreaterThan);

	if(Browser.bDontShowEmpty)
		AddQueryTerm("currentplayers", "0", QT_GreaterThan);

	if(Browser.StatsServerView == SSV_OnlyStatsEnabled)
		AddQueryTerm("stats", "true", QT_Equals);
	else if(Browser.StatsServerView == SSV_NoStatsEnabled)
		AddQueryTerm("stats", "false", QT_Equals);


	// MUTATOR 1
	// Send only the stuff to the right of the dot...
	dotPos = InStr(Browser.DesiredMutator, ".");

	if(dotPos < 0)
		TmpString = Browser.DesiredMutator;
	else
		TmpString = Mid(Browser.DesiredMutator, dotPos + 1);

	if(Browser.ViewMutatorMode == VMM_NoMutators)
		AddQueryTerm("mutator", "", QT_Equals); // Empty string indicates 'no mutators please'
	else if(Browser.ViewMutatorMode == VMM_ThisMutator && TmpString != "")
		AddQueryTerm("mutator", TmpString, QT_Equals);
	else if(Browser.ViewMutatorMode == VMM_NotThisMutator && TmpString != "")
		AddQueryTerm("mutator", TmpString, QT_NotEquals);

	// MUTATOR2
	dotPos = InStr(Browser.DesiredMutator2, ".");

	if(dotPos < 0)
		TmpString = Browser.DesiredMutator2;
	else
		TmpString = Mid(Browser.DesiredMutator2, dotPos + 1);

	if( Browser.ViewMutatorMode != VMM_AnyMutators )
	{
		if(Browser.ViewMutator2Mode == VMM_ThisMutator && TmpString != "")
			AddQueryTerm("mutator", TmpString, QT_Equals);
		else if(Browser.ViewMutator2Mode == VMM_NotThisMutator && TmpString != "")
			AddQueryTerm("mutator", TmpString, QT_NotEquals);
	}

	if(Browser.bDontShowWithBots)
		AddQueryTerm("nobots", "true", QT_Equals);

	if(Browser.WeaponStayServerView == WSSV_OnlyWeaponStay)
		AddQueryTerm("weaponstay", "true", QT_Equals);
	else if(Browser.WeaponStayServerView == WSSV_NoWeaponStay)
		AddQueryTerm("weaponstay", "false", QT_Equals);

	if(Browser.TranslocServerView == TSV_OnlyTransloc)
		AddQueryTerm("transloc", "true", QT_Equals);
	else if(Browser.TranslocServerView == TSV_NoTransloc)
		AddQueryTerm("transloc", "false", QT_Equals);

	// If not entire range (and valid), add game speed query
	if( (Browser.MinGamespeed != 0 || Browser.MaxGamespeed != 200) && Browser.MaxGamespeed >= Browser.MinGamespeed )
	{
		// Master Server stores game speed as 1 = 100% etc
		AddQueryTerm("gamespeed", string(float(Browser.MinGamespeed)/100.0), QT_GreaterThanEquals);
		AddQueryTerm("gamespeed", string(float(Browser.MaxGamespeed)/100.0), QT_LessThanEquals);
	}

	if(Browser.CustomQuery != "")
	{
		TmpString = Left(Browser.CustomQuery, 32); // Only send 32 chars max
		AddQueryTerm("custom", TmpString, QT_Equals);
	}

	MSC.StartQuery(CTM_Query);

	StatusBar.SetCaption(StartQueryString);
}

function ShowPanel(bool bShow)
{
	Super.ShowPanel(bShow);
	if( bShow )
	{
		if( !bStarted )
		{
			Log(MyButton.Caption$": Initial refresh");
			RefreshList();
			bStarted = True;
		}
		else
		{
			// Resume pings
			Log(MyButton.Caption$": Resuming pings");
			MyServersList.AutoPingServers();
		}
	}
	else
	{
		// Pause pings
		Log(MyButton.Caption$": Cancelling pings");
		MyServersList.StopPings();
	}
}

function OnCloseBrowser()
{
	if( MSC != None )
	{
		MSC.CancelPings();
		MSC.Destroy();
		MSC = None;
	}
}

function PingServer( int listid, ServerQueryClient.EPingCause PingCause, GameInfo.ServerResponseLine s )
{
	if( PingCause == PC_Clicked )
		MSC.PingServer( listid, PingCause, s.IP, s.QueryPort, QI_RulesAndPlayers, s );
	else
		MSC.PingServer( listid, PingCause, s.IP, s.QueryPort, QI_Ping, s );
}

function CancelPings()
{
	MSC.CancelPings();
}

// Caught for status bar updating

function UpdateStatusPingCount()
{
	if(MyServersList.NumReceivedPings < MyServersList.Servers.Length)
	{
		StatusBar.SetCaption(PingRecvString@"("$MyServersList.NumReceivedPings$"/"$MyServersList.Servers.Length$")");
	}
	else
	{
		StatusBar.SetCaption(RefreshFinHead@MyServersList.Servers.Length@RefreshFinMid@MyServersList.NumPlayers@RefreshFinTail);
	}
}

function MyReceivedPingInfo( int ServerID, ServerQueryClient.EPingCause PingCause, GameInfo.ServerResponseLine s )
{
	MyServersList.MyReceivedPingInfo(ServerID, PingCause, s);

	if(PingCause == PC_AutoPing)
		UpdateStatusPingCount();
}

function MyPingTimeout( int listid, ServerQueryClient.EPingCause PingCause  )
{
	MyServersList.MyPingTimeout(listid, PingCause);

	if(PingCause == PC_AutoPing)
		UpdateStatusPingCount();
}

// We have list of servers from master server and are going to start pinging
function MyQueryFinished( MasterServerClient.EResponseInfo ResponseInfo, int Info )
{
	MyServersList.MyQueryFinished(ResponseInfo, Info);

	switch( ResponseInfo )
	{
	case RI_Success:
		StatusBar.SetCaption(QueryFinHead$MSC.ResultCount$QueryFinTail);
		break;
	case RI_AuthenticationFailed:
		StatusBar.SetCaption(AuthFailString);
		break;
	case RI_ConnectionFailed:
		StatusBar.SetCaption(ConnFailString);
		break;
	case RI_ConnectionTimeout:
		StatusBar.SetCaption(ConnTimeoutString);
		break;
	case RI_MustUpgrade:
		StatusBar.SetCaption(MustUpgradeString);
		break;
	}
}

function bool MyRePing(GUIComponent Sender)
{
	MyServersList.RePingServers();
	return true;
}

function bool MyRefreshClick(GUIComponent Sender)
{
	Super.RefreshClick(Sender);
	return true;
}

function InitComponent(GUIController C, GUIComponent O)
{
	Super.InitComponent(C, O);

	if( MSC == None )
	{
		MSC = PlayerOwner().Level.Spawn( class'MasterServerClient' );
		MSC.OnReceivedServer	= MyServersList.MyOnReceivedServer;
		MSC.OnQueryFinished		= MyQueryFinished;
		MSC.OnReceivedPingInfo	= MyReceivedPingInfo;
		MSC.OnPingTimeout		= MyPingTimeout;
	}

	StatusBar.WinWidth = 0.8;

	GUIButton(GUIPanel(Controls[1]).Controls[6]).bVisible = false;

	GUIButton(GUIPanel(Controls[1]).Controls[1]).Caption = RePingServersCaption;
	GUIButton(GUIPanel(Controls[1]).Controls[1]).OnClick = MyRePing;

	// Set up REFRESH button
	GUIButton(GUIPanel(Controls[1]).Controls[7]).Caption = RefreshCaption;
	GUIButton(GUIPanel(Controls[1]).Controls[7]).OnClick = MyRefreshClick;
}

defaultproperties
{
     QueryFinHead="Query Complete! Received: "
     QueryFinTail=" Servers"
     PingRecvString="Pinging Servers"
     MustUpgradeString="Upgrade available. Please refresh the News page."
     RefreshFinHead="Pinging Complete! "
     RefreshFinMid=" Servers, "
     RefreshFinTail=" Players"
     RePingServersCaption="RE-PING LIST"
     RefreshCaption="REFRESH LIST"
}
