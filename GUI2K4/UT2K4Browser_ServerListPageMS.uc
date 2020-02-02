//====================================================================
//
//  Base class for all browser pages that must communicate with the
//	master server.  Only shown once CD-key has been verified by Epic.
//
//  Updated by Ron Prestenback
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class UT2K4Browser_ServerListPageMS extends UT2K4Browser_ServerListPageBase;

function ShowPanel( bool bShow )
{
	Super.ShowPanel(bShow);

	if ( bShow && !bInit )
		BindQueryClient(Browser.Uplink());
}

function Refresh()
{

    if (UT2K4ServerBrowser(PageOwner).Verified)
    	UT2K4ServerBrowser(PageOwner).ClearServerCache();

	Super.Refresh();

	ResetQueryClient(Browser.Uplink());
}

function ResetQueryClient( ServerQueryClient Client )
{
	Super.ResetQueryClient(Client);

	if ( MasterServerClient(Client) != None )
		MasterServerClient(Client).Query.Length = 0;
}

function BindQueryClient( ServerQueryClient Client )
{
	Super.BindQueryClient(Client);
	if ( MasterServerClient(Client) != None )
	{
		MasterServerClient(Client).OnQueryFinished     = QueryComplete;
		MasterServerClient(Client).OnReceivedServer    = li_Server.MyOnReceivedServer;
	}
}

// We have list of servers from master server and are going to start pinging
function QueryComplete( MasterServerClient.EResponseInfo ResponseInfo, int Info )
{
	li_Server.MyQueryFinished(ResponseInfo, Info);

	switch( ResponseInfo )
	{
	case RI_Success:
		SetFooterCaption( Repl(QueryCompleteString, "%NumServers%", Browser.Uplink().ResultCount) );
		break;

	case RI_AuthenticationFailed:
		SetFooterCaption(AuthFailString);
		break;

	case RI_ConnectionFailed:
    	UT2K4ServerBrowser(PageOwner).GetFromServerCache(li_Server);
    	li_Server.FakeFinished();
		SetFooterCaption(ConnFailString);
		break;

	case RI_ConnectionTimeout:
    	UT2K4ServerBrowser(PageOwner).GetFromServerCache(li_Server);
    	li_Server.FakeFinished();
		SetFooterCaption(ConnTimeoutString);
		break;

	case RI_MustUpgrade:
		SetFooterCaption(MustUpgradeString);
		break;
	}
}

function ReceivedPingInfo( int ServerID, ServerQueryClient.EPingCause PingCause, GameInfo.ServerResponseLine s )
{
	Super.ReceivedPingInfo(ServerID, PingCause, S);
	li_Server.MyReceivedPingInfo(ServerID, PingCause, s);

	// If we are still pinging the list received from the master server
	if (PingCause == PC_AutoPing)
		UpdateStatusPingCount();
}

function ReceivedPingTimeout( int listid, ServerQueryClient.EPingCause PingCause  )
{
	Super.ReceivedPingTimeout(listid,PingCause);
	li_Server.MyPingTimeout(listid, PingCause);

	// If we are still pinging the list received from the master server
	if (PingCause == PC_AutoPing)
		UpdateStatusPingCount();
}

defaultproperties
{
     PanelCaption="Server Browser : Internet"
}
