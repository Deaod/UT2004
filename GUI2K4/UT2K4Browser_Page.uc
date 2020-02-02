//====================================================================
//  Base class for all Server Browser tab panels
//
//  Updated by Ron Prestenback
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class UT2K4Browser_Page extends UT2K4TabPanel;

var() UT2K4ServerBrowser Browser;
var() UT2K4Browser_Footer t_Footer;	// For quick access

var() localized string MustUpgradeString;
var() localized string QueryCompleteString;
var() localized string StartQueryString;
var() localized string AuthFailString;
var() localized string ConnFailString;
var() localized string ConnTimeoutString;
var() localized string RetryString;
var() localized string ReadyString;

var() localized string BackCaption;
var() localized string RefreshCaption;
var() localized string JoinCaption;
var() localized string SpectateCaption;
var() localized string FilterCaption;
var() localized string UnspecifiedNetworkError;
var() string CurrentFooterCaption;

var() bool bCommonButtonWidth;

delegate OnOpenConnection(optional int Count);
delegate OnCloseConnection(optional int Count);

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	if (UT2K4ServerBrowser(MyOwner.MenuOwner) != None)
	{
		Browser 	= UT2K4ServerBrowser(MyOwner.MenuOwner);
		t_Footer 	= UT2K4Browser_Footer(Browser.t_Footer);
	}
	Super.InitComponent(MyController, MyOwner);
    CurrentFooterCaption = ReadyString;
}

event Opened(GUIComponent Sender)
{
	// This should never occur, but is here to catch any weird problems
	if ((Browser == None || t_Footer == None) && UT2K4ServerBrowser(Sender) != None)
	{
		Browser 	= UT2K4ServerBrowser(Sender);
		t_Footer	= UT2K4Browser_Footer(Browser.t_Footer);
	}

	Super.Opened(Sender);
}

function ShowPanel(bool bShow)
{
	Super.ShowPanel(bShow);

	if (bShow)
	{
		Browser.t_Header.SetCaption(PanelCaption);
		RefreshFooter(Self,string(!bCommonButtonWidth));
    	SetFooterCaption(CurrentFooterCaption);
	}
}

function bool InternalOnRightClick(GUIComponent Sender)
{
	return false;
}

function bool ShouldDisplayGameType()
{
	return false;
}

// Should be subclassed
function QueryComplete( MasterServerClient.EResponseInfo ResponseInfo, int Info );
function ReceivedPingInfo( int ServerID, ServerQueryClient.EPingCause PingCause, GameInfo.ServerResponseLine s );
function ReceivedPingTimeout( int listid, ServerQueryClient.EPingCause PingCause  );

// Master Server Methods
function AddQueryTerm(coerce string Key, coerce string Value, MasterServerClient.EQueryType QueryType)
{
	local MasterServerClient.QueryData QD;
	local int i;

//	log("AddQueryTerm Key:"$Key@"Value:"$Value@"QueryType:"$GetEnum(enum'EQueryType',QueryType));
	for ( i = 0; i < Browser.Uplink().Query.Length; i++ )
	{
		QD = Browser.Uplink().Query[i];
		if ( QD.Key ~= Key && QD.Value ~= Value && QD.QueryType == QueryType )
			return;
	}

	QD.Key			= Key;
	QD.Value		= Value;
	QD.QueryType	= QueryType;

	Browser.Uplink().Query[i] = QD;
}

function ResetQueryClient( ServerQueryClient Client )
{
	if ( Client == None )
		return;

	Client.CancelPings();

	BindQueryClient(Client);

	SetFooterCaption(ReadyString);
}

function BindQueryClient( ServerQueryClient Client )
{
	if ( Client == None )
		return;

	Client.OnReceivedPingInfo	= ReceivedPingInfo;
	Client.OnPingTimeout		= ReceivedPingTimeout;
}

function CloseMSConnection()
{
	if ( Browser != None )
	{
		Browser.Uplink().CancelPings();
	    Browser.Uplink().Stop();
	}
}

// this is called after panels change button captions - it forces the footer to re-initialize its button widths
delegate RefreshFooter( optional UT2K4Browser_Page Page, optional string bPerButtonSizes );

function SetFooterCaption(string NewCaption, optional bool bAppend)
{
	local GUITabControl TC;

	// Don't allow a non-active panel to update the footer caption
	TC = GUITabControl(MenuOwner);
	if ( TC.PendingTab != None )
	{
		if ( TC.PendingTab != MyButton )
			return;
	}
	else if ( TC.ActiveTab != MyButton )
		return;

	if ( t_Footer == None )
		t_Footer = UT2K4Browser_Footer(Browser.t_Footer);

	if ( bAppend )
		NewCaption = t_Footer.t_StatusBar.GetCaption() $ NewCaption;
   
	t_Footer.t_StatusBar.SetCaption(NewCaption);
	CurrentFooterCaption = t_Footer.t_StatusBar.Caption;
}

function SetJoinCaption(string NewCaption, optional bool bAppend)
{
	if ( t_Footer == None || t_Footer.b_Join == None )
		return;

	if ( bAppend )
		NewCaption = t_Footer.b_Join.Caption $ NewCaption;

	t_Footer.b_Join.Caption = NewCaption;
}

function SetSpectateCaption(string NewCaption, optional bool bAppend)
{
	if ( t_Footer == None || t_Footer.b_Spectate == None )
		return;

	if ( bAppend )
		NewCaption = t_Footer.b_Spectate.Caption $ NewCaption;

	t_Footer.b_Spectate.Caption = NewCaption;
}

function SetRefreshCaption(string NewCaption, optional bool bAppend)
{
	if ( t_Footer == None || t_Footer.b_Refresh == None )
		return;

	if ( bAppend )
		NewCaption = t_Footer.b_Refresh.Caption $ NewCaption;

	t_Footer.b_Refresh.Caption = NewCaption;
}


function CheckJoinButton(bool Available)
{
	if ( t_Footer == None || t_Footer.b_Join == None )
		return;

	if ( Available )
		EnableComponent(t_Footer.b_Join);
	else DisableComponent(t_Footer.b_Join);
}

function CheckSpectateButton(bool Available)
{
	if ( t_Footer == None || t_Footer.b_Spectate == None )
		return;

	if ( Available )
		EnableComponent(t_Footer.b_Spectate);
	else DisableComponent(t_Footer.b_Spectate);
}

function CheckRefreshButton(bool Available)
{
	if ( t_Footer == None || t_Footer.b_Refresh == None )
		return;

	if ( Available )
		EnableComponent(t_Footer.b_Refresh);
	else DisableComponent(t_Footer.b_Refresh);
}

function JoinClicked();
function SpectateClicked();
function FilterClicked();
function RefreshClicked()
{
	Refresh();
}

// Returns whether the refresh button should be available for this panel - also gives chance to modify caption, if necessary
function bool IsRefreshAvailable( out string ButtonCaption )
{
	ButtonCaption = RefreshCaption;
	return true;
}

// Returns whether the spectate button should be available for this panel - also gives chance to modify caption, if necessary
function bool IsSpectateAvailable( out string ButtonCaption )
{
	ButtonCaption = SpectateCaption;
	return true;
}

// Returns whether the join button should be available for this panel - also gives chance to modify caption, if necessary
function bool IsJoinAvailable( out string ButtonCaption )
{
	ButtonCaption = JoinCaption;
	return true;
}

// Returns whether the filter button should be available for this panel - also gives chance to modify caption, if necessary
function bool IsFilterAvailable( out string ButtonCaption )
{
	ButtonCaption = FilterCaption;
	return false;
}

function ShowNetworkError( optional string ErrorMsg )
{
	local GUIPage Page;

	if ( ErrorMsg == "" )
		ErrorMsg = UnspecifiedNetworkError;

	Page = Controller.ShowQuestionDialog( ErrorMsg, QBTN_AbortRetry, QBTN_Abort );
	if ( Page != None )
		Page.OnClose = NetworkErrorClosed;
}

function NetworkErrorClosed( bool bCancelled )
{
}

defaultproperties
{
     MustUpgradeString="Upgrade available. Please refresh the News page."
     QueryCompleteString="Query Complete!"
     StartQueryString="Querying Master Server"
     AuthFailString="Authentication Failed"
     ConnFailString="Connection Failed"
     ConnTimeoutString="Connection Timed Out"
     RetryString=" - Retrying"
     ReadyString="Ready"
     BackCaption="BACK"
     RefreshCaption="REFRESH"
     JoinCaption="JOIN"
     SpectateCaption="SPECTATE"
     FilterCaption="FILTERS"
     UnspecifiedNetworkError="There was an unknown error while attempting to connect to the network."
     bCommonButtonWidth=True
     bFillHeight=True
     FadeInTime=0.250000
     WinHeight=1.000000
}
