//====================================================================
//  Updated by Ron Prestenback
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class UT2K4Browser_ServerListPageBase extends UT2K4Browser_Page;

var automated GUISplitter   sp_Main;
var GUISplitter             sp_Detail;

var() config string         RulesListBoxClass,
                            PlayersListBoxClass;

var() config float          MainSplitterPosition, DetailSplitterPosition;

struct HeaderColumnPos
{
    var() array<float> ColumnSizes;
};

var() config array<HeaderColumnPos> HeaderColumnSizes;

var floatbox GameTypePos;

// Internal
var Ut2K4Browser_ServerListBox  lb_Server;
var Ut2K4Browser_RulesListBox   lb_Rules;
var Ut2K4Browser_PlayersListBox lb_Players;

var Ut2K4Browser_ServersList    li_Server;
var Ut2K4Browser_RulesList      li_Rules;
var Ut2K4Browser_PlayersList    li_Players;
var BrowserFilters              FilterMaster;

var bool bAllowUpdates; // do not perform updates while mouse button is held down
var bool ConnectLAN;    // Whether this is the LAN tab

var localized string PingingText, PingCompleteText;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    FilterMaster = UT2K4ServerBrowser(Controller.TopPage()).FilterMaster;

    li_Rules    = UT2K4Browser_RulesList(lb_Rules.List);
    li_Players  = UT2K4Browser_PlayersList(lb_Players.List);

    lb_Rules.SetAnchor(Self);
    lb_Players.SetAnchor(Self);

    if (HeaderColumnSizes.Length < 3)
        ResetConfig("HeaderColumnSizes");

    lb_Server.HeaderColumnPerc = HeaderColumnSizes[0].ColumnSizes;
    lb_Rules.HeaderColumnPerc = HeaderColumnSizes[1].ColumnSizes;
    lb_Players.HeaderColumnPerc = HeaderColumnSizes[2].ColumnSizes;

    lb_Server.TabOrder = 0;
    lb_Rules.TabOrder = 1;
    lb_Players.TabOrder = 2;
}

event Opened(GUIComponent Sender)
{
	Super.Opened(Sender);
	if ( !bInit && Controller.bAutoRefreshBrowser )
		Refresh();
}

function ShowPanel(bool bShow)
{
    Super.ShowPanel(bShow);

    if (bShow)
    {
        if (bInit)
        {
            sp_Main.SplitterUpdatePositions();
            sp_Detail.SplitterUpdatePositions();
            Refresh();
        }
		else li_Server.AutoPingServers();
    }
    else if ( !bInit )
    {
    	// Remove all outstanding pings so that they will be repinged when this panel is made active again
    	// Otherwise, we'll get stuck if the new active tab is using the same masterserveruplink
		li_Server.OutstandingPings.Remove(0, li_Server.OutstandingPings.Length);
	}
}

function Refresh()
{
    Super.Refresh();

    if (li_Server == None)
        InitServerList();

    // Start over
    li_Server.Clear();
}

function InitServerList()
{
	if ( li_Server == None )
	    li_Server = new(None) class'GUI2K4.UT2K4Browser_ServersList';

    // Switch out the list
    lb_Server.InitBaseList(li_Server);
    li_Server.OnChange = ServerListChanged;
    lb_Server.SetAnchor(Self);
}

function RefreshList()  // should be subclassed - used for refreshing the server list
{
    li_Server.RepingServers();
}

function JoinClicked()
{
	li_Server.Connect(False);
}

function SpectateClicked()
{
	li_Server.Connect(True);
}

// should be subclassed
function UpdateStatusPingCount()
{
	local string StatusText;

    CheckJoinButton(li_Server.IsValid());
    CheckSpectateButton(li_Server.IsValid());

	if ( li_Server == None )
		return;

	if ( li_Server.NumReceivedPings < li_Server.Servers.Length )
	{
		StatusText = Repl( PingingText, "%NumRec%", li_Server.NumReceivedPings );
		StatusText = Repl( StatusText, "%TotalNum%", li_Server.Servers.Length );
	}

	else
	{
		StatusText = Repl( QueryCompleteString, "%NumServers%", li_Server.Servers.Length );
		StatusText = Repl( StatusText, "%NumPlayers%", li_Server.NumPlayers );
	}

	SetFooterCaption(StatusText);
}

function CancelPings()
{
    Browser.Uplink().CancelPings();
    SetFooterCaption(ReadyString);
}

function PingServer( int listid, ServerQueryClient.EPingCause PingCause, GameInfo.ServerResponseLine s )
{
    if( PingCause == PC_Clicked )
        Browser.Uplink().PingServer( listid, PingCause, s.IP, s.QueryPort, QI_RulesAndPlayers, s );
    else
        Browser.Uplink().PingServer( listid, PingCause, s.IP, s.QueryPort, QI_Ping, s );
}

function MousePressed(GUIComponent Sender, bool bRepeat)
{
    bAllowUpdates = False;
    if ( GUIVertScrollBar(Sender.MenuOwner) != None )
    	GUIVertScrollBar(Sender.MenuOwner).GripPressed(Sender, bRepeat);
}

function MouseReleased(GUIComponent Sender)
{
    bAllowUpdates = True;
}

function RefreshCurrentServer()
{
	local int i, j;

	if ( Controller.ContextMenu != None )
		return;

	CheckSpectateButton(li_Server.IsValid());
	CheckJoinButton(li_Server.IsValid());

	i = li_Server.CurrentListId();
	if ( i < 0 )
		return;

	PingServer(i,PC_Clicked,li_Server.Servers[i]);
	li_Players.Clear();

    for (j = 0; j < li_Server.Servers[i].PlayerInfo.Length; j++)
        li_Players.AddNewPlayer(li_Server.Servers[i].PlayerInfo[j]);

	li_Players.SortList();
}

function ServerListChanged(GUIComponent Sender)
{
    local int i, j;

    if (!bAllowUpdates || Controller.ContextMenu != None)
        return;

    li_Rules.Clear();
    li_Players.Clear();

	CheckSpectateButton(li_Server.IsValid());
	CheckJoinButton(li_Server.IsValid());

    i = li_Server.CurrentListId();
    if ( i < 0 )
		return;

    // when changing selected servers, get their rules
    if (Sender != None)
        PingServer( i, PC_Clicked, li_Server.Servers[i]);

    for (j = 0; j < li_Server.Servers[i].ServerInfo.Length; j++)
        li_Rules.AddNewRule(li_Server.Servers[i].ServerInfo[j]);

    for (j = 0; j < li_Server.Servers[i].PlayerInfo.Length; j++)
        li_Players.AddNewPlayer(li_Server.Servers[i].PlayerInfo[j]);

    li_Players.SortList();
    li_Rules.SortList();
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
    if (UT2K4Browser_ServerListBox(NewComp) != None)
        lb_Server = UT2K4Browser_ServerListBox(NewComp);

    else if (UT2K4Browser_RulesListBox(NewComp) != None)
        lb_Rules = UT2K4Browser_RulesListBox(NewComp);

    else if (UT2K4Browser_PlayersListBox(NewComp) != None)
        lb_Players = UT2K4Browser_PlayersListBox(NewComp);

    else if (GUISplitter(NewComp) != None)
    {
        sp_Detail = GUISplitter(NewComp);
        sp_Detail.DefaultPanels[0] = RulesListBoxClass;
        sp_Detail.DefaultPanels[1] = PlayersListBoxClass;
        sp_Detail.WinTop=0;
        sp_Detail.WinLeft=0;
        sp_Detail.WinWidth=1.0;
        sp_Detail.WinHeight=1.0;
        sp_Detail.bNeverFocus=True;
        sp_Detail.bAcceptsInput=True;
        sp_Detail.SplitOrientation=SPLIT_Horizontal;
        sp_Detail.IniOption="@Internal";
        sp_Detail.OnCreateComponent = InternalOnCreateComponent;
        sp_Detail.OnLoadIni=InternalOnLoadIni;
        sp_Detail.OnReleaseSplitter=InternalReleaseSplitter;
    }
}

function InternalOnLoadIni(GUIComponent Sender, string S)
{
    if (Sender == sp_Main)
        sp_Main.SplitPosition = MainSplitterPosition;

    else if (Sender == sp_Detail)
        sp_Detail.SplitPosition = DetailSplitterPosition;
}

function InternalReleaseSplitter(GUIComponent Sender, float NewPos)
{
    if (Sender == sp_Main)
    {
        MainSplitterPosition = NewPos;
        SaveConfig();
    }

    else if (Sender == sp_Detail)
    {
        DetailSplitterPosition = NewPos;
        SaveConfig();
    }
}

function string InternalOnSaveINI(GUIComponent Sender)
{
    HeaderColumnSizes[0].ColumnSizes = lb_Server.HeaderColumnPerc;
    HeaderColumnSizes[1].ColumnSizes = lb_Rules.HeaderColumnPerc;
    HeaderColumnSizes[2].ColumnSizes = lb_Players.HeaderColumnPerc;

    SaveConfig();
    return "";
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

	if ( li_Server != None && li_Server.IsValid() )
		return true;

	return false;
}

// Returns whether the join button should be available for this panel - also gives chance to modify caption, if necessary
function bool IsJoinAvailable( out string ButtonCaption )
{
	ButtonCaption = JoinCaption;
	if ( li_Server != None && li_Server.IsValid() )
		return true;

	return false;
}

defaultproperties
{
     Begin Object Class=GUISplitter Name=HorzSplitter
         DefaultPanels(0)="GUI2K4.UT2K4Browser_ServerListBox"
         DefaultPanels(1)="XInterface.GUISplitter"
         MaxPercentage=0.900000
         OnReleaseSplitter=UT2k4Browser_ServerListPageBase.InternalReleaseSplitter
         OnCreateComponent=UT2k4Browser_ServerListPageBase.InternalOnCreateComponent
         IniOption="@Internal"
         WinHeight=1.000000
         RenderWeight=1.000000
         OnLoadINI=UT2k4Browser_ServerListPageBase.InternalOnLoadINI
     End Object
     sp_Main=GUISplitter'GUI2K4.UT2k4Browser_ServerListPageBase.HorzSplitter'

     RulesListBoxClass="GUI2K4.UT2K4Browser_RulesListBox"
     PlayersListBoxClass="GUI2K4.UT2K4Browser_PlayersListBox"
     MainSplitterPosition=0.665672
     DetailSplitterPosition=0.460938
     HeaderColumnSizes(0)=(ColumnSizes=(0.096562,0.446875,0.292812,0.110625,0.150000))
     HeaderColumnSizes(1)=(ColumnSizes=(0.564287,0.500000))
     HeaderColumnSizes(2)=(ColumnSizes=(0.340000,0.220000,0.286591,0.220000))
     bAllowUpdates=True
     PingingText="Pinging Servers ( %NumRec% / %TotalNum% )"
     PingCompleteText="Pinging Complete! %NumServers% Servers, %NumPlayers% Players"
     QueryCompleteString="Query Complete! Received: %NumServers% Servers"
     PanelCaption="Server Browser"
     bFillHeight=False
     IniOption="@Internal"
     WinHeight=0.792969
     OnSaveINI=UT2k4Browser_ServerListPageBase.InternalOnSaveINI
}
