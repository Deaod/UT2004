//==============================================================================
//	Created on: 09/10/2003
//	Choose a difficulty level and gametype, and the player will be automatically
//  connected to the server with the best ping in that category.
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UT2K4QuickPlay extends LargeWindow;

var automated GUIImage		i_Border;
var automated GUILabel      l_Status, l_ServerCount;
var automated moComboBox    co_Game,        co_Difficulty;
var automated GUIButton     b_QuickConnect, b_lClose;

var MasterServerClient MSC;

var localized array<string> DifficultyOptions;

// Whether we are currently conducting a search for a good server
var bool bPendingSearch;

// Number of concurrent ping requests currently active - used to make sure we don't surpass MaxSimultaneousPing
var int ThreadCount;
var array<int> PingQueue;                        // Indexes of servers still waiting to be pinged
var int QuickConnectSeconds;                     // Number of seconds since we began pinging for quick connect
var config int MaxWaitSeconds;                   // Maximum number of seconds to wait for pinging to be completed

// List of servers received from the Master Server
var array<GameInfo.ServerResponseLine> Servers;

// Quick Connect properties
var localized string PlayText, SearchingText, ReadyText, ConnectText, CancelText, ConnectHint, CancelHint;

// Localized status text
var localized string BeginningSearchText;
var localized string AuthFailedText;
var localized string ServerCountText;
var localized string SearchCancelledText;
var localized string ConnectionFailedText;
var localized string TimedOutText;
var localized string NoServersReceivedText;
var localized string NoValidText;

delegate OnOpenConnection();
delegate OnCloseConnection();

function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
	local int i;

	Super.InitComponent(MyController, MyComponent);

	for ( i = 0; i < DifficultyOptions.Length; i++ )
		co_Difficulty.AddItem(DifficultyOptions[i]);

	StatusTimer(None);
	ChangeQuickPlayStatus(False);
}

event Opened(GUIComponent Sender)
{
	local int i;
	local array<CacheManager.GameRecord> Records;

	Super.Opened(Sender);
	class'CacheManager'.static.GetGameTypeList(Records);
	for ( i = 0; i < Records.Length; i++ )
		co_Game.AddItem(Records[i].GameName,,Records[i].ClassName);
}

event Closed(GUIComponent Sender, bool bCancelled)
{
	Super.Closed(Sender, bCancelled);
	CloseMSConnection();
}

event Free()
{
	Super.Free();
	CloseMSConnection();
}

function bool NotifyLevelChange()
{
	CloseMSConnection();
	return Super.NotifyLevelChange();
}

function CloseMSConnection()
{
	KillTimer();
	if ( MSC != None )
	{
		MSC.CancelPings();
	    MSC.Stop();
	}

	MSC = None;
}

// Master Server Methods
function AddQueryTerm(coerce string Key, coerce string Value, MasterServerClient.EQueryType QueryType)
{
	local MasterServerClient.QueryData QD;
	local int i;

	for ( i = 0; i < MSC.Query.Length; i++ )
	{
		QD = MSC.Query[i];
		if ( QD.Key ~= Key && QD.Value ~= Value && QD.QueryType == QueryType )
			return;
	}

	QD.Key			= Key;
	QD.Value		= Value;
	QD.QueryType	= QueryType;

	MSC.Query[i] = QD;
}

function HandleObject( Object Obj, optional Object OptionalObj_1, optional Object OptionalObj_2 )
{
	MSC = MasterServerClient(Obj);
}

event Timer()
{
	if ( Playerowner() != None && PlayerOwner().Level.TimeSeconds - QuickConnectSeconds > MaxWaitSeconds )
	{
		SetStatusCaption( NoValidText );
		CancelQuickPlay();
	}

	UpdateQueue();
}

function bool InternalOnClick(GUIComponent Sender)
{
	if ( Sender == b_QuickConnect )
	{
		if ( QuickConnectPending() )
		{
			CancelQuickPlay();
			SetStatusCaption(SearchCancelledText);
		}
		else
		{
			SetStatusCaption( BeginningSearchText @ co_Game.GetText() );
			CreateQuickPlayQuery( co_Game.GetExtra(), co_Difficulty.GetIndex() );
		}
		return true;
	}

	if ( Sender == b_lClose )
	{
		Controller.CloseMenu(false);
		return true;
	}

	return false;
}

function CreateQuickPlayQuery( string GameType, int Index )
{
	local int Pos;

	// Reset any browser query in progress.
	ResetQueryClient(MSC);

	// Add all query parameters
	ChangeQuickPlayStatus(True);

	// Remove the package name, if it exists
	Pos = InStr(GameType, ".");
	if ( Pos != -1 )
		GameType = Mid(GameType, Pos + 1);

	// Desired GameType
	AddQueryTerm( "gametype", GameType, QT_Equals );

	// Desired Difficulty
	AddQueryTerm( "category", Index, QT_Equals );

	// Must be standard server
	AddQueryTerm( "standard", "true", QT_Equals );

	// Must not be passworded
	AddQueryTerm( "password", "false", QT_Equals );

	// Cannot be empty or full
	AddQueryTerm( "currentplayers", "0", QT_GreaterThan );
	AddQueryTerm( "freespace", "0", QT_GreaterThan );

	// begin searching for an appropriate server (too bad objects don't support states)
	QuickConnectSeconds = PlayerOwner().Level.TimeSeconds;
	MSC.StartQuery( CTM_Query );
}

function QueryComplete( MasterServerClient.EResponseInfo ResponseInfo, int Info )
{
	switch ( ResponseInfo )
	{
	case RI_Success:
		SetTimer(0.1, True);
		break;

	case RI_AuthenticationFailed:
		SetStatusCaption( AuthFailedText );
		CancelQuickPlay();
		break;

	case RI_ConnectionFailed:
		SetStatusCaption( ConnectionFailedText );
		CancelQuickPlay();
		break;

	case RI_ConnectionTimeout:
		SetStatusCaption( TimedOutText );
		CancelQuickPlay();
		break;
	}
}

function CancelQuickPlay()
{
	// Cancel pings
	MSC.CancelPings();

	ChangeQuickPlayStatus(False);
}

function ChangeQuickPlayStatus(bool bIsSearching)
{
	bPendingSearch = bIsSearching;
	if ( QuickConnectPending() )
	{
		// Set the button text
		SetStatusCaption(SearchingText);
		b_QuickConnect.Caption = CancelText;
		b_QuickConnect.SetHint(CancelHint);
	}

	else
	{
		KillTimer();
		l_Status.SetTimer(2.5, False);
		b_QuickConnect.Caption = ConnectText;
		b_QuickConnect.SetHint(ConnectHint);
	}
}

function ResetQueryClient(ServerQueryClient Client)
{
	if ( Client == None )
		return;

	ThreadCount = 0;
	if ( PingQueue.Length > 0 )
		PingQueue.Remove(0, PingQueue.Length);

	if ( Servers.Length > 0 )
		Servers.Remove(0, Servers.Length);

	UpdateServerCount();
	Client.OnReceivedPingInfo = ReceivedPingInfo;
	Client.OnPingTimeout      = ReceivedPingTimeout;
	if ( MasterServerClient(Client) == None )
		return;

	MasterServerClient(Client).OnReceivedServer   = ReceivedNewServer;
	MasterServerClient(Client).OnQueryFinished    = QueryComplete;
	MasterServerClient(Client).Query.Length       = 0;
}

function ReceivedNewServer( GameInfo.ServerResponseLine NewServer )
{
	local int i;

//	log("ReceivedNewServer:"$NewServer.ServerName@"IP:"$NewServer.IP);
	// Just add this entry
	i = Servers.Length;
	Servers[i] = NewServer;

	// If the response packet didn't include the ping, set it to the highest value
	if ( Servers[i].Ping == 0 )
		Servers[i].Ping = 9999;

	AddServerToPingQueue(i);
}

function AddServerToPingQueue(int ServerIndex)
{
	local int i;

//	log("AddServerToPingQueue ServerIndex:"$ServerIndex);
	i = PingQueue.Length;
	PingQueue[i] = ServerIndex;

	UpdateServerCount();
	if ( ThreadCount < class'UT2K4ServerBrowser'.static.CalculateMaxConnections() )
		PingServer(i);
}

// go through our list of server received from the master server, and ping each one
// this search will only ping servers for which we have not received pings from
// this allows the ping to be stopped and restarted (such as when switching tabs)
function UpdateQueue()
{
	local int maxcount;

	maxcount = class'UT2K4ServerBrowser'.static.CalculateMaxConnections();

//	log("UpdateQueue cnt:"$maxcount@"ThreadCount:"$ThreadCount@"PingQueue.Length:"$PingQueue.Length);
	while ( ThreadCount < maxcount && PingQueue.Length > 0 )
		PingServer(0);

	UpdateServerCount();
	if ( PingQueue.Length ==  0 && ThreadCount <= 0 )
		PingingComplete();
}

function PingServer(int QueueIndex)
{
	local int i;

	if ( QueueIndex < 0 || QueueIndex >= PingQueue.Length )
		return;

	i = PingQueue[QueueIndex];
	PingQueue.Remove(QueueIndex, 1);

	ThreadCount++;

	MSC.PingServer( i, PC_AutoPing, Servers[i].IP, Servers[i].QueryPort, QI_Ping, Servers[i] );
	OnOpenConnection();
}

function ReceivedPingInfo( int ServerIndex, ServerQueryClient.EPingCause PingCause, GameInfo.ServerResponseLine ServerInfo )
{
//	log("ReceivedPingInfo ServerIndex:"$ServerIndex@"EPingCause:"$GetEnum(enum'EPingCause', PingCause));
	// Validation
	if ( ServerIndex < 0 || ServerIndex >= Servers.Length )
		return;

	// Replace my copy with this copy
	OnCloseConnection();
	ThreadCount--;
	Servers[ServerIndex] = ServerInfo;
	UpdateServerCount();
}

function ReceivedPingTimeout( int ServerIndex, ServerQueryClient.EPingCause PingCause )
{
//	log("ReceivedPingTimeout ServerIndex:"$ServerIndex@"Servers.Length:"$Servers.Length);
	// Validation
	if ( ServerIndex < 0 || ServerIndex >= Servers.Length )
		return;

	OnCloseConnection();
	ThreadCount--;
	UpdateServerCount();
}

function PingingComplete()
{
	local int i, Best;
	local string URL;
	local PlayerController PC;

//	log("PingingComplete Servers.Length:"$Servers.Length);

	if ( Servers.Length == 0 )
	{
		SetStatusCaption(NoServersReceivedText);
		ChangeQuickPlayStatus(False);
		return;
	}

	Best = -1;
	for ( i = 0; i < Servers.Length; i++ )
	{
		if ( Best == -1 )
		{
			if ( Servers[i].Ping < 9999 )
				Best = i;
		}

		else if ( Servers[i].Ping <= Servers[Best].Ping )
		{
			if ( Servers[i].Ping < Servers[Best].Ping )
			{
				Best = i;
				continue;
			}

			if ( Servers[i].CurrentPlayers > Servers[Best].CurrentPlayers )
			{
				Best = i;
				continue;
			}
		}
	}

	// No valid servers found!!!!!
	if ( Best == -1 )
	{
		SetStatusCaption(NoValidText);
		ChangeQuickPlayStatus(False);
		return;
	}

	PC = PlayerOwner();

	// TODO: Possibly display chosen server, and offer to accept or reject choice
	URL = PC.GetURLProtocol() $ "://" $ Servers[Best].IP $ ":" $ Servers[Best].Port;

	log("Performing ClientTravel URL:"$URL);
	KillTimer();

	CloseMSConnection();
	Controller.CloseAll(False,True);
	PC.ClientTravel( URL, TRAVEL_Relative, False );
}

function bool QuickConnectPending()
{
	return bPendingSearch;
}

function StatusTimer(GUIComponent Sender)
{
	SetStatusCaption(ReadyText);
}

function SetStatusCaption(string StatusMessage)
{
	l_Status.Caption = StatusMessage;
}

function UpdateServerCount()
{
	local string s;

	s = Repl(ServerCountText, "%NumReceived%", Servers.Length - PingQueue.Length);
	s = Repl(s, "%TotalServers%", Servers.Length);

	l_ServerCount.Caption = s;
}

defaultproperties
{
     Begin Object Class=GUIImage Name=IBorder
         Image=Texture'2K4Menus.NewControls.Display99'
         ImageStyle=ISTY_Stretched
         WinTop=0.300283
         WinLeft=0.060258
         WinWidth=0.878815
         WinHeight=0.460699
         RenderWeight=0.001000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     i_Border=GUIImage'GUI2K4.UT2K4QuickPlay.IBorder'

     Begin Object Class=GUILabel Name=ConnectionStatus
         TextAlign=TXTA_Center
         StyleName="TextLabel"
         WinTop=0.323438
         WinLeft=0.073594
         WinWidth=0.849415
         WinHeight=0.411678
         RenderWeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
         OnTimer=UT2K4QuickPlay.StatusTimer
     End Object
     l_Status=GUILabel'GUI2K4.UT2K4QuickPlay.ConnectionStatus'

     Begin Object Class=GUILabel Name=ServerCount
         TextAlign=TXTA_Center
         FontScale=FNS_Small
         StyleName="TextLabel"
         WinTop=0.604924
         WinLeft=0.120469
         WinWidth=0.761916
         WinHeight=0.130428
         RenderWeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     l_ServerCount=GUILabel'GUI2K4.UT2K4QuickPlay.ServerCount'

     Begin Object Class=moComboBox Name=GameType
         bReadOnly=True
         CaptionWidth=0.300000
         Caption="Game Type"
         OnCreateComponent=GameType.InternalOnCreateComponent
         Hint="Select the game type you would like to play."
         WinTop=0.204219
         WinLeft=0.059751
         WinWidth=0.488417
         WinHeight=0.087720
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
     End Object
     co_Game=moComboBox'GUI2K4.UT2K4QuickPlay.GameType'

     Begin Object Class=moComboBox Name=DifficultyLevel
         bReadOnly=True
         CaptionWidth=0.300000
         Caption="Difficulty"
         OnCreateComponent=DifficultyLevel.InternalOnCreateComponent
         Hint="Select the desired game difficulty level to search for.  If you are new to UT2004, it is recommended that you choose the "Beginner" setting."
         WinTop=0.200564
         WinLeft=0.571664
         WinWidth=0.367167
         WinHeight=0.087720
         TabOrder=1
         bBoundToParent=True
         bScaleToParent=True
     End Object
     co_Difficulty=moComboBox'GUI2K4.UT2K4QuickPlay.DifficultyLevel'

     Begin Object Class=GUIButton Name=QuickPlaySearch
         WinTop=0.767551
         WinLeft=0.307992
         WinWidth=0.120347
         WinHeight=0.109137
         TabOrder=2
         bBoundToParent=True
         bScaleToParent=True
         bStandardized=True
         OnClick=UT2K4QuickPlay.InternalOnClick
         OnKeyEvent=QuickPlaySearch.InternalOnKeyEvent
     End Object
     b_QuickConnect=GUIButton'GUI2K4.UT2K4QuickPlay.QuickPlaySearch'

     Begin Object Class=GUIButton Name=QuickPlayClose
         Caption="CLOSE"
         Hint="Close this window"
         WinTop=0.767551
         WinLeft=0.600883
         WinWidth=0.125690
         WinHeight=0.109137
         TabOrder=4
         bBoundToParent=True
         bScaleToParent=True
         bStandardized=True
         OnClick=UT2K4QuickPlay.InternalOnClick
         OnKeyEvent=QuickPlayClose.InternalOnKeyEvent
     End Object
     b_lClose=GUIButton'GUI2K4.UT2K4QuickPlay.QuickPlayClose'

     DifficultyOptions(0)="Beginner"
     DifficultyOptions(1)="Experienced"
     DifficultyOptions(2)="Expert"
     MaxWaitSeconds=20
     SearchingText="SEARCHING..."
     ReadyText="Ready"
     ConnectText="SEARCH"
     CancelText="CANCEL"
     ConnectHint="Once you've selected a gametype and difficulty level, click "Search" to begin searching for a server in the category that has the lowest ping"
     CancelHint="Cancel the current "Quick Join" search"
     BeginningSearchText="Please wait...requesting servers for gametype:"
     AuthFailedText="Authentication failed!  Please try again later..."
     ServerCountText="Received/Total - %NumReceived%/%TotalServers%"
     SearchCancelledText="Search cancelled!"
     ConnectionFailedText="Connection failed - unable to contact the master server.  Please check your network connection and try again!"
     TimedOutText="Master server took too long to respond to query.  Please try again later."
     NoServersReceivedText="Sorry, no valid servers found for this gametype!"
     NoValidText="Unknown error encountered while pinging servers! Please retry query..."
     WindowName="Quick Play"
     WinTop=0.250000
     WinLeft=0.000000
     WinWidth=1.000000
     WinHeight=0.370059
}
