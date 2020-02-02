//====================================================================
//  Browser page for stored favorites.
//
//  Written by Ron Prestenback (based on Browser_ServerListPageFavorites)
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class UT2K4Browser_ServerListPageFavorites extends UT2K4Browser_ServerListPageBase;

var() localized string AddFavoriteCaption;
var() localized string RemoveFavoriteCaption;

var() localized string RemoveFavoriteText;
var() localized string EditFavoriteText;

var() int EditIndex;	// Track which server is being edited

var array<ExtendedConsole.ServerFavorite> Servers;

var array<string> ContextItems;

// add ip, remove favorite
var protected ServerQueryClient SQC;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;
	Super.InitComponent(MyController, MyOwner);

	GetQueryClient();
	lb_Server.OnRightClick = ListBoxRightClick;
	ContextItems = lb_Server.ContextItems;
	ContextItems[ContextItems.Length - 1] = EditFavoriteText;
	ContextItems[ContextItems.Length] = RemoveFavoriteText;

	// Remove the filter options from our list of context items
	for ( i = 0; i < ContextItems.Length; i++ )
	{
		if ( ContextItems[i] == lb_Server.ContextItems[lb_Server.FILTERIDX] )
		{
			ContextItems.Remove(i, 4);
			break;
		}
	}
}

function InitPanel()
{
	Super.InitPanel();

	InitServerList();
	Browser.OnAddFavorite = AddFavorite;
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

function ShowPanel(bool bShow)
{
	Super.ShowPanel(bShow);
	if ( bShow )
		bInit = False;
}

function InitServerList()
{
	Super.InitServerList();
	if (li_Server.Servers.Length > 0)
		li_Server.Clear();
	InitFavorites();
}

function InitFavorites()
{
	local int i;
	local GameInfo.ServerResponseLine Server;

	class'ExtendedConsole'.static.GetFavorites(Servers);
	for( i = 0; i < Servers.Length && i < 10000; i++ )
	{
		ConvertFavoriteToServer( Servers[i], Server );
		li_Server.MyOnReceivedServer( Server );
	}
}

function Refresh()
{
	Super.Refresh();
	InitFavorites();
	RefreshList();
}

function RefreshList()
{
	GetQueryClient();
	ResetQueryClient(SQC);
	CancelPings();
	Super.RefreshList();
}

function CancelPings()
{
	if ( SQC != None )
		SQC.CancelPings();
}

function PingServer( int listid, ServerQueryClient.EPingCause PingCause, GameInfo.ServerResponseLine s )
{
	GetQueryClient();
	if( PingCause == PC_Clicked )
		SQC.PingServer( listid, PingCause, s.IP, s.QueryPort, QI_RulesAndPlayers, s );
	else
		SQC.PingServer( listid, PingCause, s.IP, s.QueryPort, QI_Ping, s );
}

static function ConvertFavoriteToServer( ExtendedConsole.ServerFavorite Fav, out GameInfo.ServerResponseLine Server )
{
	Server.ServerID		= Fav.ServerID;
	Server.IP			= Fav.IP;
	Server.Port			= Fav.Port;
	Server.QueryPort	= Fav.QueryPort;
	Server.ServerName	= Fav.ServerName;
}

static function ConvertServerToFavorite( GameInfo.ServerResponseLine Server, out ExtendedConsole.ServerFavorite Fav )
{
	Fav.ServerID    = Server.ServerID;
	Fav.IP          = Server.IP;
	Fav.Port        = Server.Port;
	Fav.QueryPort   = Server.QueryPort;
	Fav.ServerName  = Server.ServerName;
}

function AddFavorite( GameInfo.ServerResponseLine Server )
{
	local ExtendedConsole.ServerFavorite Fav;

	ConvertServerToFavorite( Server, Fav );
	if ( class'ExtendedConsole'.static.AddFavorite( Fav ) )
	{
		Servers[Servers.Length] = Fav;
		li_Server.MyOnReceivedServer( Server );
	}
}

function RemoveFavorite( GameInfo.ServerResponseLine Server )
{
	local int i;

	i = li_Server.FindIndex( Server.IP, string(Server.Port) );
	i = li_Server.RemoveServerAt(i);
	if ( i >= 0 && class'ExtendedConsole'.static.RemoveFavorite(Server.IP, Server.Port, Server.QueryPort) )
		Servers.Remove(i,1);
}

function SaveFavorites()
{
	class'ExtendedConsole'.static.SaveFavorites();
}

function ReceivedPingInfo( int ServerID, ServerQueryClient.EPingCause PingCause, GameInfo.ServerResponseLine s )
{
	local ExtendedConsole.ServerFavorite Fav;
	local int i;

	Super.ReceivedPingInfo( ServerID, PingCause, S);

	for ( i = 0; i < Servers.Length; i++ )
	{
		if ( Servers[i].IP == s.IP && Servers[i].Port == S.Port )
		{
			// Update the stored entry if the names aren't the same
			if ( !(Servers[i].ServerName ~= s.ServerName) )
			{
				ConvertServerToFavorite(s, Fav);
				class'ExtendedConsole'.static.AddFavorite(Fav);
			}
		}
	}
	li_Server.MyReceivedPingInfo(ServerID, PingCause, s);
	if(PingCause == PC_AutoPing)
		UpdateStatusPingCount();
}

function ReceivedPingTimeout( int listid, ServerQueryClient.EPingCause PingCause  )
{
	li_Server.MyPingTimeout(listid, PingCause);

	if(PingCause == PC_AutoPing)
		UpdateStatusPingCount();
}

function ServerQueryClient GetQueryClient()
{
	local int i;

	if ( SQC == None )
	{
		SQC = PlayerOwner().Spawn( class'ServerQueryClient' );

		if ( SQC != None && SQC.NetworkError() )
		{
			// Handle network error
			do
			{
				log(Name@"- Network error in query client - retrying  "$i);
				SQC.Destroy();
				SQC = PlayerOwner().Spawn( class'ServerQueryClient' );
			} until ( !SQC.NetworkError() || ++i < 10 )

			if ( i >= 10 )
			{
				// Unresolvable network error
				ShowNetworkError();
				return None;
			}
		}

		SQC.OnReceivedPingInfo = ReceivedPingInfo;
		SQC.OnPingTimeout = ReceivedPingTimeout;

		log(Name@"Spawned new ServerQueryClient '"$SQC$"'");
	}

	return SQC;
}

protected function ClearQueryClient()
{
	if ( SQC != None )
	{
		log(Name@"Destroying ServerQueryClient '"$SQC.Name$"'");
		SaveFavorites();
		CancelPings();
		SQC.Destroy();
		SQC = None;
	}
}

// =====================================================================================================================
// =====================================================================================================================
//  Context Menu
// =====================================================================================================================
// =====================================================================================================================

// Override the listbox's context menu
function bool ListBoxRightClick( GUIComponent Sender )
{
	return False;
}

function bool ContextMenuOpened(GUIContextMenu Sender)
{
	Sender.ContextItems.Remove(0, Sender.ContextItems.Length);
	if ( li_Server.IsValid() )
		Sender.ContextItems = ContextItems;
	else
	{
		Sender.ContextItems[0] = lb_Server.ContextItems[lb_Server.ADDFAVIDX];
		Sender.ContextItems[1] = lb_Server.ContextItems[lb_Server.OPENIPIDX];
	}

	return True;
}

function ContextSelect(GUIContextMenu Menu, int Index)
{
	local int i;
	local GameInfo.ServerResponseLine S;

	if ( NotifyContextSelect(Menu, Index) )
		return;

	if ( Menu.ContextItems[Index] == lb_Server.ContextItems[lb_Server.ADDFAVIDX] )
	{
		if ( Controller.OpenMenu( Controller.EditFavoriteMenu ) )
			Controller.ActivePage.OnClose = AddPageClosed;
		return;
	}

	if ( Menu.ContextItems[Index] == RemoveFavoriteText && li_Server.GetCurrent(s) )
	{
		RemoveFavorite( S );
		return;
	}

	if ( Menu.ContextItems[Index] ~= EditFavoriteText && li_Server.IsValid() )
	{
		i = li_Server.CurrentListId();
		if ( Controller.OpenMenu( Controller.EditFavoriteMenu, li_Server.Servers[i].IP $ ":" $ li_Server.Servers[i].Port, li_Server.Servers[i].ServerName ) )
			Controller.ActivePage.OnClose = EditPageClosed;

		return;
	}

	lb_Server.InternalOnClick(Menu,Index);
}

// =====================================================================================================================
// =====================================================================================================================
//  Subpages
// =====================================================================================================================
// =====================================================================================================================
function AddPageClosed( bool bCancelled )
{
	if ( !bCancelled )
	{
		AddFavorite(EditFavoritePage(Controller.ActivePage).Server);
		Refresh();
	}
}

function EditPageClosed(bool bCancelled)
{
	if ( !bCancelled )
	{
		RemoveFavorite(li_Server.Servers[li_Server.CurrentListId()]);
		AddFavorite(EditFavoritePage(Controller.ActivePage).Server);
		Refresh();
	}
}

function NetworkErrorClosed( bool bCancelled )
{
	if ( !bCancelled )
		GetQueryClient();
}

defaultproperties
{
     AddFavoriteCaption="ADD FAVORITE"
     RemoveFavoriteCaption="REMOVE FAVORITE"
     RemoveFavoriteText="Remove Favorite"
     EditFavoriteText="Edit IP Address"
     PanelCaption="Server Browser : Favorites"
     Begin Object Class=GUIContextMenu Name=FavoritesContextMenu
         OnOpen=UT2k4Browser_ServerListPageFavorites.ContextMenuOpened
         OnSelect=UT2k4Browser_ServerListPageFavorites.ContextSelect
     End Object
     ContextMenu=GUIContextMenu'GUI2K4.UT2k4Browser_ServerListPageFavorites.FavoritesContextMenu'

}
