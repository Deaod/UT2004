class Browser_ServerListPageLAN extends Browser_ServerListPageBase;

var LANQueryClient LQC;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

	GUIButton(GUIPanel(Controls[1]).Controls[6]).bVisible = false;
	GUIButton(GUIPanel(Controls[1]).Controls[7]).bVisible = false;
	StatusBar.WinWidth=1.0;

	if( LQC == None )
	{
		LQC = PlayerOwner().Level.Spawn( class'LANQueryClient' );
		LQC.OnReceivedPingInfo = MyReceivedPingInfo;
		LQC.OnPingTimeout      = MyServersList.MyPingTimeout;
	}

	// Change server list spacing a bit (no icons)
	MyServersList.InitColumnPerc[0]=0.0;
	MyServersList.InitColumnPerc[1]=0.47;
	MyServersList.InitColumnPerc[2]=0.25;
	MyServersList.InitColumnPerc[3]=0.13;
	MyServersList.InitColumnPerc[4]=0.15;

	RefreshList();
}

function OnCloseBrowser()
{
	if( LQC != None )
	{
		LQC.Destroy();
		LQC = None;
	}
}

function MyReceivedPingInfo( int ServerID, ServerQueryClient.EPingCause PingCause, GameInfo.ServerResponseLine s )
{
	local int i;
	if( ServerID < 0 )
	{
		for( i=0;i<MyServersList.Servers.Length;i++ )
		{
			// dupe
			if( MyServersList.Servers[i].IP==s.IP && MyServersList.Servers[i].Port==s.Port )
				return;
		}

		MyServersList.MyOnReceivedServer( s );
	}
	else
	{
		MyServersList.MyReceivedPingInfo( ServerID, PingCause, s );
	}
}

function PingServer( int listid, ServerQueryClient.EPingCause PingCause, GameInfo.ServerResponseLine s )
{
	LQC.PingServer( listid, PingCause, s.IP, s.QueryPort, QI_RulesAndPlayers, s );
}

function CancelPings()
{
	LQC.CancelPings();
}

function RefreshList()
{
	MyServersList.Clear();
	CancelPings();
	LQC.BroadcastPingRequest();
}

defaultproperties
{
     ConnectLAN=True
}
