class Browser_ServerListPageFavorites extends Browser_ServerListPageBase;

struct FavoritesServerInfo
{
	var() config int ServerID;
	var() config string IP;
	var() config int Port;
	var() config int QueryPort;
	var() config string ServerName;
};

var() config array<FavoritesServerInfo> Favorites;
var localized string RemoveFavoriteCaption;
var localized string AddIPCaption;
var localized string RePingCaption;
var ServerQueryClient SQC;

var GUIButton MyAddIPButton;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;
	local GameInfo.ServerResponseLine Server;

	Super.Initcomponent(MyController, MyOwner);
	Browser.OnAddFavorite = MyAddFavorite;

	if( SQC == None )
	{
		SQC = PlayerOwner().Level.Spawn( class'ServerQueryClient' );
		SQC.OnReceivedPingInfo	= MyServersList.MyReceivedPingInfo;
		SQC.OnPingTimeout		= MyServersList.MyPingTimeout;
	}

	MyServersList.Clear();
	for( i=0;i<default.Favorites.Length;i++ )
	{
		FavoriteToServer( i, Server );
		MyServersList.MyOnReceivedServer( Server );
	}

	GUIButton(GUIPanel(Controls[1]).Controls[1]).Caption=RePingCaption;

	// take over the "Add Favorite" button.
	GUIButton(GUIPanel(Controls[1]).Controls[4]).OnClick=RemoveFavoriteClick;
	GUIButton(GUIPanel(Controls[1]).Controls[4]).Caption=RemoveFavoriteCaption;

	// 'Add IP' button
	GUIButton(GUIPanel(Controls[1]).Controls[7]).OnClick=AddIPClick;
	GUIButton(GUIPanel(Controls[1]).Controls[7]).Caption=AddIPCaption;	

	GUIButton(GUIPanel(Controls[1]).Controls[6]).bVisible=false;
	StatusBar.WinWidth=0.8;

	// Change server list spacing a bit (no icons)
	MyServersList.InitColumnPerc[0]=0.0;
	MyServersList.InitColumnPerc[1]=0.47;
	MyServersList.InitColumnPerc[2]=0.25;
	MyServersList.InitColumnPerc[3]=0.13;
	MyServersList.InitColumnPerc[4]=0.15;
}

function bool AddIPClick(GUIComponent Sender)
{
	if ( Controller.OpenMenu("xinterface.Browser_OpenIP") )
		Browser_OpenIP(Controller.TopPage()).MyFavoritesPage = self;

	return true;
}

function RefreshList()
{
	MyServersList.InvalidatePings();
	MyServersList.AutoPingServers();
}

function ShowPanel(bool bShow)
{
	Super.ShowPanel(bShow);
	if( bShow )
	{
		// Resume pings
		Log(MyButton.Caption$": Resuming pings");
		MyServersList.AutoPingServers();
	}
	else
	{
		// Pause pings
		Log(MyButton.Caption$": Cancelling pings");
		MyServersList.StopPings();
	}
}

function CancelPings()
{
	SQC.CancelPings();
}

function OnCloseBrowser()
{
	if( SQC != None )
	{
		SaveFavorites();
		SQC.CancelPings();
		SQC.Destroy();
		SQC = None;
	}
}

function PingServer( int listid, ServerQueryClient.EPingCause PingCause, GameInfo.ServerResponseLine s )
{
	if( PingCause == PC_Clicked )
		SQC.PingServer( listid, PingCause, s.IP, s.QueryPort, QI_RulesAndPlayers, s );
	else
		SQC.PingServer( listid, PingCause, s.IP, s.QueryPort, QI_Ping, s );
}


// Called by the Remove Favorite button
function bool RemoveFavoriteClick(GUIComponent Sender)
{
	local int i;
	i = MyServersList.RemoveCurrentServer();
	if( i >= 0 )
	{
		default.Favorites.Remove(i,1);
		SaveFavorites();
	}
	return true;
}

function SaveFavorites()
{
    local int i;
	default.Favorites.Length = MyServersList.Servers.Length;

	for( i=0;i<MyServersList.Servers.Length;i++ )
	{
		default.Favorites[i].ServerID	= MyServersList.Servers[i].ServerID;
		default.Favorites[i].IP			= MyServersList.Servers[i].IP;
		default.Favorites[i].Port		= MyServersList.Servers[i].Port;
		default.Favorites[i].QueryPort	= MyServersList.Servers[i].QueryPort;
		default.Favorites[i].ServerName	= MyServersList.Servers[i].ServerName;
	}

	StaticSaveConfig();
}

function FavoriteToServer( int i, out GameInfo.ServerResponseLine Server )
{
	Server.ServerID		= default.Favorites[i].ServerID;
	Server.IP			= default.Favorites[i].IP;
	Server.Port			= default.Favorites[i].Port;
	Server.QueryPort	= default.Favorites[i].QueryPort;
	Server.ServerName	= default.Favorites[i].ServerName;
}

function MyAddFavorite( GameInfo.ServerResponseLine Server )
{
	local int i;
	for( i=0;i<default.Favorites.Length;i++ )
		if( default.Favorites[i].IP==Server.IP && default.Favorites[i].Port==Server.Port )
			return;

	MyServersList.MyOnReceivedServer( Server );
	SaveFavorites();
}

// Add a favorite from anywhere
static function StaticAddFavorite(String IPString, int port, int queryPort)
{
	local int numFavorites;

	Log("StaticAddFavorite:"@IPString@port@queryPort);

	numFavorites = default.Favorites.Length;
	default.Favorites.Length = numFavorites + 1;

	default.Favorites[numFavorites].IP = IPString;
	default.Favorites[numFavorites].Port = port;
	default.Favorites[numFavorites].QueryPort = queryPort;
	default.Favorites[numFavorites].ServerName = "Unknown";

	StaticSaveConfig();
}

defaultproperties
{
     RemoveFavoriteCaption="REMOVE FAVORITE"
     AddIPCaption="ADD IP"
     RePingCaption="RE-PING LIST"
}
