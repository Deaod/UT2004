//====================================================================
//  This page shows LAN-based online servers.
//
//  Updated by Ron Prestenback
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class UT2K4Browser_ServerListPageLAN extends UT2K4Browser_ServerListPageBase;

var() private LANQueryClient LQC;
var() string StoredIP, StoredPort;

event Opened( GUIComponent Sender )
{
	Super.Opened(Sender);

	if ( !bInit && bVisible )
		SetTimer(10.0,True);
}

function ShowPanel(bool bShow)
{
	Super.ShowPanel(bShow);
	if ( bShow )
	{
		SetTimer(10.0, True);
		bInit = False;
	}
	else KillTimer();
}

function Timer()
{
	Super.Timer();
	RefreshList();
}

function Refresh()
{
	Super.Refresh();

	ResetQueryClient(GetClient());
	RefreshList();
}

function RefreshList()
{
	local string s;

	CancelPings();

	// If we had a server selected, save the ip and port so that we can reselect the server when the query for the server is received
	s = li_Server.Get();
	if ( s == "" || !Divide( s, ":", StoredIP, StoredPort ) )
	{
		StoredIP = "";
		StoredPort = "";
	}

	li_Server.Clear();
	GetClient().BroadcastPingRequest();
}

function ReceivedPingInfo( int ServerID, ServerQueryClient.EPingCause PingCause, GameInfo.ServerResponseLine s )
{
	local int i;
	if( ServerID < 0 )
	{
		for( i=0;i<li_Server.Servers.Length;i++ )
		{
			// dupe
			if( li_Server.Servers[i].IP==s.IP && li_Server.Servers[i].Port==s.Port )
				return;
		}

		li_Server.MyOnReceivedServer( s );

		// If we have a stored IP and port, it means we had a server selected when the browser was refreshed - reselect the server now
		if ( StoredIP == s.ip && StoredPort == string(s.port) )
		{
			li_Server.SetIndex( li_Server.FindIndex(StoredIP, StoredPort) );
			StoredIP = "";
			StoredPort = "";
		}
	}
	else
	{
		li_Server.MyReceivedPingInfo( ServerID, PingCause, s );
		if ( StoredIP == s.ip && StoredPort == string(s.port) )
		{
			li_Server.bNotify = False;
			li_Server.SetIndex( li_Server.FindIndex(StoredIP, StoredPort) );
			li_Server.bNotify = True;
			StoredIP = "";
			StoredPort = "";
		}
	}
}

function CancelPings()
{
	if ( HasClient() )
		LQC.CancelPings();
}

function PingServer( int listid, ServerQueryClient.EPingCause PingCause, GameInfo.ServerResponseLine s )
{
	GetClient().PingServer( listid, PingCause, s.IP, s.QueryPort, QI_RulesAndPlayers, s );
}

function UpdateStatusPingCount()
{
}

function bool HasClient()
{
	return LQC != None;
}

function LANQueryClient GetClient()
{
	local int i;

	if( LQC == None )
	{
		LQC = PlayerOwner().Level.Spawn( class'LANQueryClient' );
		log(Name@"Spawning new LAN query client '"$LQC$"'");
		if ( LQC != None && LQC.NetworkError() )
		{
			// Handle network error
			do
			{
				log(Name@"- Network error in query client - retrying  "$i);
				LQC.Destroy();
				LQC = PlayerOwner().Spawn( class'LANQueryClient' );
			} until ( !LQC.NetworkError() || ++i < 10 )

			if ( i >= 10 )
			{
				// Unresolvable network error
				ShowNetworkError();
				return None;
			}
		}
	}

	return LQC;
}

function OnDestroyPanel(optional bool bCancelled)
{
	Super.OnDestroyPanel(bCancelled);
	ClearQueryClient();
}

function LevelChanged()
{
	Super.LevelChanged();
	ClearQueryClient();
}

function Free()
{
	Super.Free();
	ClearQueryClient();
}

protected function ClearQueryClient()
{
	if ( LQC != None )
	{
		log(Name@"Destroying LAN query client '"$LQC$"'");
		LQC.CancelPings();
		LQC.Destroy();
		LQC = None;
	}
}

function NetworkErrorClosed( bool bCancelled )
{
	if ( !bCancelled )
		GetClient();
}

defaultproperties
{
     ConnectLAN=True
     PanelCaption="Server Browser : LAN"
}
