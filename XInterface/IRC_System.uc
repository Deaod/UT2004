class IRC_System extends IRC_Page;

var Browser_IRC			  IRCPage;

var IRCLink Link;

var array<IRC_Channel>	  Channels;

//var string Server;
//var string DefaultChannel;

var string TestIRCString;

var config string	NickName;
var config string	FullName;
var config string	OldPlayerName;
var config string	UserIdent;

var config array<string>	ServerHistory;
var config array<string>	ChannelHistory;
var localized array<string> DefaultChannels;

var bool bConnected;
var bool bAway;
var bool bSysInitialised;

var localized string NotInAChannelText;
var localized string KickedFromText;
var localized string ByText;
var localized string IsAwayText;

var localized string ConnectText;
var localized string DisconnectText;

// Server/channel selection
var GUILabel		 ServerLabel;
var GUIButton		 ConnectButton;
var GUIComboBox		 ServerCombo;
var GUIButton		 RemoveServerButton;

var GUILabel		 ChannelLabel;
var GUIButton		 JoinChannelButton;
var GUIComboBox		 ChannelCombo;
var GUIButton		 RemoveChannelButton;


var int CurChannel;
var int PrevChannel;

//function RefreshUI()
//{
//    IRCMain.RefreshData(GetActivePage());
//}

function UpdateConnectCaption()
{
	if(bConnected)
		ConnectButton.Caption = DisconnectText;
	else
		ConnectButton.Caption = ConnectText;
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local GUIPanel UtilPanel;
	local int i, j;

	if(!bSysInitialised)
	{
		GUISplitter(Controls[1]).bDrawSplitter = false; // Dont draw this splitter

		// Plug button into util panel
		UtilPanel = GUIPanel( GUISplitter(Controls[1]).Controls[1] );

		UtilPanel.Controls.Length = 8;

		UtilPanel.Controls[0] = ConnectButton;
		UtilPanel.Controls[1] = ServerCombo;
		UtilPanel.Controls[2] = RemoveServerButton;
		UtilPanel.Controls[3] = ServerLabel;

		UtilPanel.Controls[4] = JoinChannelButton;
		UtilPanel.Controls[5] = ChannelCombo;
		UtilPanel.Controls[6] = RemoveChannelButton;
		UtilPanel.Controls[7] = ChannelLabel;
	}

	Super.Initcomponent(MyController, MyOwner);

	if(!bSysInitialised)
	{
		SetTimer(1.0, true);

		UpdateConnectCaption();

		// Load server and channel history into combo's
		Log(ServerHistory.Length$" Servers "$ChannelHistory.Length$" Channels");
		for(i=0; i<ServerHistory.Length; i++)
		{
			ServerCombo.AddItem(ServerHistory[i]);
		}

		if(ServerHistory.Length > 0)
			ServerCombo.SetText(ServerHistory[0]);

		// load localized channel defaults if needed.
		if( ChannelHistory.Length == 0 )
		{
			for( i=0;i<DefaultChannels.Length;i++ )
			{
				j = ChannelHistory.Length + 1;
				ChannelHistory.Length = j;
				ChannelHistory[j - 1] = DefaultChannels[i];
			}
		}

		for(i=0; i<ChannelHistory.Length; i++)
		{
			ChannelCombo.AddItem(ChannelHistory[i]);
		}

		if(ChannelHistory.Length > 0)
			ChannelCombo.SetText(ChannelHistory[0]);

		bSysInitialised=true;
	}
}

function int FindServerHistoryIndex( string ServerName )
{
	local int ix, i;
	ix = -1;

	for(i=0; i<ServerHistory.Length && ix == -1; i++)
	{
		if( ServerHistory[i] ~= ServerName )
			ix = i;
	}
	return ix;
}

function int FindChannelHistoryIndex( string ChannelName )
{
	local int ix, i;
	ix = -1;

	for(i=0; i<ChannelHistory.Length && ix == -1; i++)
	{
		if( ChannelHistory[i] ~= ChannelName )
			ix = i;
	}
	return ix;
}

function bool ConnectClick(GUIComponent Sender)
{
	local int i;
	local string ServerName;

	if( Sender != ConnectButton )
		return true;

	if(bConnected)
		Disconnect();
	else
	{
		Connect();

		if(bConnected)
		{
			// If we are now connected, see if the server is in our history. If not, add it.
			ServerName = ServerCombo.Edit.GetText();
			i = FindServerHistoryIndex(ServerName);

			// Add it
			if(i == -1)
			{
				i = ServerHistory.Length + 1;
				ServerHistory.Length = i;
				ServerHistory[i - 1] = ServerName;
				SaveConfig();

				ServerCombo.AddItem( ServerName );
				ServerCombo.SetText( ServerName );

				ServerCombo.List.Top = 0; // HACK - not sure why I need to do this
			}
		}
	}

	return true;
}

function bool JoinChannelClick(GUIComponent Sender)
{
	local int i;
	local string ChannelName;

	if( Sender != JoinChannelButton || !bConnected )
		return true;

	JoinChannel( ChannelCombo.Edit.GetText() );

	// Add channel name to history (if not already there)
	ChannelName = ChannelCombo.Edit.GetText();
	i = FindChannelHistoryIndex(ChannelName);

	if(i == -1)
	{
		i = ChannelHistory.Length + 1;
		ChannelHistory.Length = i;
		ChannelHistory[i - 1] = ChannelName;
		SaveConfig();

		ChannelCombo.AddItem( ChannelName );
		ChannelCombo.SetText( ChannelName );

		ChannelCombo.List.Top = 0;
	}

	return true;
}

function bool RemoveServerClick(GUIComponent Sender)
{
	local string ServerName;
	local int i;

	ServerName = ServerCombo.Edit.GetText();
	i = FindServerHistoryIndex(ServerName);

	if(i != -1)
	{
		ServerHistory.Remove(i,1);
		SaveConfig();

		ServerCombo.RemoveItem(i,1);

		if(ServerHistory.Length > 0)
			ServerCombo.SetText(ServerHistory[0]);
	}

	return true;
}

function bool RemoveChannelClick(GUIComponent Sender)
{
	local string ChannelName;
	local int i;

	ChannelName = ChannelCombo.Edit.GetText();
	i = FindChannelHistoryIndex(ChannelName);

	if(i != -1)
	{
		ChannelHistory.Remove(i,1);
		SaveConfig();

		ChannelCombo.RemoveItem(i,1);

		if(ChannelHistory.Length > 0)
			ChannelCombo.SetText(ChannelHistory[0]);
	}

	return true;
}

// Timer function keeps nick up to date with player name if it changes
event Timer()
{
	if(bConnected && PlayerOwner() != None && PlayerOwner().PlayerReplicationInfo != None && PlayerOwner().PlayerReplicationInfo.PlayerName != OldPlayerName)
	{
		OldPlayerName = PlayerOwner().PlayerReplicationInfo.PlayerName;
		Link.SetNick(OldPlayerName);
		SystemText("SetNick: "$OldPlayerName);
	}
}

function SetCurrentChannelPage( IRC_Channel ChannelPage )
{
	local int i;

	for(i=0; i<Channels.Length; i++)
	{
		if(Channels[i] == ChannelPage)
		{
			SetCurrentChannel(i);
			return;
		}
	}
}

function SetCurrentChannel( int idx )
{
    if( idx < -1 || idx > Channels.Length-1 || idx==CurChannel)
    {
        return;
    }

    PrevChannel = CurChannel;
    CurChannel = idx;

	// Make the current channel the active tab (if its not already).
	if(CurChannel == -1)
	{
		if( IRCPage.ChannelTabs.ActiveTab != MyButton )
			IRCPage.ChannelTabs.ActivateTab( MyButton, true );
	}
	else
	{
		if( IRCPage.ChannelTabs.ActiveTab != Channels[CurChannel].MyButton )
			IRCPage.ChannelTabs.ActivateTab( Channels[CurChannel].MyButton, true );
	}

    //RefreshUI();
}

function IRC_Page GetActivePage()
{
    if( CurChannel != -1 )
    {
        return Channels[CurChannel];
    }
    return self;
}

function ProcessInput(string Text)
{
    if( CurChannel > -1 )
    {
        Channels[CurChannel].ProcessInput(Text);
    }
    else
    {
	    if(Left(Text, 1) != "/")
        {
		    SystemText("*** "$NotInAChannelText);
        }
	    else
        {
		    Link.SendCommandText(Mid(Text, 1));
        }
    }
    //RefreshUI();
}

function IRC_Channel FindChannelWindow(string Channel)
{
    local int i;

    for( i=0; i<Channels.Length; i++ )
    {
        if( Channels[i].IsPrivate == true )
            continue;
        if( Channels[i].ChannelName ~= Channel )
            return Channels[i];
    }
	return None;
}

function int FindChannelIndex(string Channel)
{
    local int i;

    for( i=0; i<Channels.Length; i++ )
    {
        if( Channels[i].IsPrivate == true )
            continue;
        if( Channels[i].ChannelName ~= Channel )
            return i;
    }
	return -1;
}

function IRC_Private FindPrivateWindow(string Nick)
{
    local int i;

    for( i=0; i<Channels.Length; i++ )
    {
        if( Channels[i].IsPrivate == false )
            continue;
        if( Channels[i].ChannelName ~= Nick )
            return IRC_Private(Channels[i]);
    }

	return CreatePrivChannel(Nick);
}

function Connect()
{
	local int i;
	local PlayerController PC;

	if(Link != None)
		Disconnect();

    PC = PlayerOwner();
    assert( PC != None );

    if( PC.PlayerReplicationInfo != None )
    {
	    if( PC.PlayerReplicationInfo.PlayerName != OldPlayerName)
	    {
		    NickName = PC.PlayerReplicationInfo.PlayerName;
		    OldPlayerName = NickName;
		    if(FullName == "")
			    FullName = NickName;
		    SaveConfig();
	    }
    }
    else
    {
        NickName = PlayerOwner().GetUrlOption( "Name" );
		OldPlayerName = NickName;
		if(FullName == "")
			FullName = NickName;
		SaveConfig();
    }

	if(UserIdent == "")
	{
		UserIdent = "u";
		for(i=0;i<7;i++)
			UserIdent = UserIdent $ Chr((Rand(10)+48));

		Log("Created new UserIdent: "$UserIdent);
		SaveConfig();
	}

	Link = PlayerOwner().GetEntryLevel().Spawn(class'IRCLink');
	//Link.Connect(Self, ServerCombo.GetText(), NickName, UserIdent, FullName, ChannelCombo.GetText());
	Link.Connect(Self, ServerCombo.Edit.GetText(), NickName, UserIdent, FullName, "");

	bConnected = True;

	UpdateConnectCaption();
}

function JoinChannel(string ChannelName)
{
	local IRC_Channel P;

	P = FindChannelWindow(ChannelName);

	if(P == None)
		Link.JoinChannel(ChannelName);
	else
        SetCurrentChannel(FindChannelIndex(ChannelName));
}

// Leave the currently active channel
function PartCurrentChannel()
{
	if(CurChannel == -1)
		return;

	// If its a private channel, just close the window
	if( Channels[CurChannel].IsA('IRC_Private') )
	{
		IRCPage.ChannelTabs.RemoveTab( Channels[CurChannel].MyButton.Caption );
		Channels.Remove(CurChannel, 1);
		SetCurrentChannel(-1);
	}
	else // Otherwise, send leave channel request.
	{
		PartChannel( Channels[CurChannel].ChannelName );
	}
}

function PartChannel(string ChannelName)
{
	local IRC_Channel P;

	P = FindChannelWindow(ChannelName);
	if(P != None)
		Link.PartChannel(ChannelName);
}

function Disconnect()
{
    local int i;

	if(Link != None)
	{
		// don't localize - sent to other clients
		Link.DisconnectReason = "Disconnected";
		Link.DestroyLink();
	}
	Link = None;


    for( i=0; i<Channels.Length; i++ )
    {
		IRCPage.ChannelTabs.RemoveTab( Channels[i].MyButton.Caption ); // Remove tab from tab control
        //Channels[i].Destroy();
    }

    Channels.Length = 0;
    CurChannel = -1;

	SystemText( "Server disconnected" );
	bConnected = False;

	// Make system tab active (if not already)
	if( IRCPage.ChannelTabs.ActiveTab != self.MyButton )
		IRCPage.ChannelTabs.ActivateTab( self.MyButton, true );
	//RefreshUI();

	UpdateConnectCaption();
}

function NotifyQuitUnreal() // !! todo hook this up?
{
	//Super.NotifyQuitUnreal();
	if(Link != None)
	{
		// don't localize - sent to other clients
		Link.DisconnectReason = "Exit Game";
		Link.DestroyLink();
	}
}

function SystemText(string Text)
{
	// FIXME!! should do something better with this
	if(Text != "You have been marked as being away" && Text != "You are no longer marked as being away")
	{
        TextDisplay.AddText( MakeColorCode(IRCTextColor)$ColorizeLinks(Text) );

		if(!MyButton.bActive)
			MyButton.bForceFlash = true;
	}
}

function ChannelText(string Channel, string Nick, string Text)
{
    //log("ChannelText"$Text,'IRC');
    //TestIRCString = Nick$":"$Text;

	local IRC_Channel P;

	P = FindChannelWindow(Channel);
	if(P != None)
		P.ChannelText(Nick, Text);
}

function PrivateText(string Nick, string Text)
{
    FindPrivateWindow(Nick).PrivateText(Nick, Text);
}

function IRC_Private CreatePrivChannel(string Nick, optional bool bMakeActive)
{
    local IRC_Private priv;

	priv = IRC_Private( IRCPage.ChannelTabs.AddTab(Nick, "xinterface.IRC_Private") );
    //priv = Spawn(class'IRCPrivPage',self);

    Channels[Channels.Length] = priv;
    priv.SystemPage = self;
    priv.IsPrivate = true;
    priv.ChannelName = Nick;

	// Make new channel active
	if(bMakeActive)
		SetCurrentChannel(Channels.Length-1);

    return priv;
}

function ChannelAction(string Channel, string Nick, string Text)
{
	local IRC_Channel P;

	P = FindChannelWindow(Channel);
	if(P != None)
		P.ChannelAction(Nick, Text);
}

function PrivateAction(string Nick, string Text)
{
    FindPrivateWindow(Nick).PrivateAction(Nick, Text);
}

function JoinedChannel(string Channel, optional string Nick)
{
	local IRC_Channel NewCh;
	local IRC_Channel W;

    log("JoinedChannel "$Channel,'IRC');

	if(Nick == "")
	{
		NewCh = IRC_Channel( IRCPage.ChannelTabs.AddTab(Channel, "xinterface.IRC_Channel") );
        //NewCh = Spawn(class'IRC_Channel',self);

        Channels[Channels.Length] = NewCh;
        NewCh.SystemPage = self;
        //NewCh.TextBuffer.WrapText = TextBuffer.WrapText;
        NewCh.IsPrivate = false;
        NewCh.ChannelName = Channel;

        SetCurrentChannel(Channels.Length-1);
	}

	if(Nick == "")
		Nick = NickName;

	W = FindChannelWindow(Channel);
	if(W != None)
		W.JoinedChannel(Nick);
}

function RemoveChannel( string Channel )
{
    local int i;

	// Find channel in channel array
    for( i=0; i<Channels.Length; i++ )
    {
        if( Channels[i].IsPrivate == true )
            continue;
        if( Channels[i].ChannelName ~= Channel )
            break;
    }

    if( i<Channels.Length )
    {
		IRCPage.ChannelTabs.RemoveTab( Channels[i].MyButton.Caption ); // Remove tab from tab control
        Channels.Remove(i,1); // remove from channels list
        //SetCurrentChannel(PrevChannel);// Set current channel to previous channel
        SetCurrentChannel(-1);// Set current channel to previous channel
    }
}

function KickUser(string Channel, string KickedNick, string Kicker, string Reason)
{
	local IRC_Channel W;

	W = FindChannelWindow(Channel);

	if(KickedNick == NickName)
	{
        RemoveChannel(Channel);
		SystemText("*** "$KickedFromText@Channel@ByText@Kicker$" ("$Reason$")");
	}
	else
	{
		if(W != None)
			W.KickUser(KickedNick, Kicker, Reason);
	}
}

function UserInChannel(string Channel, string Nick)
{
	local IRC_Channel W;
	W = FindChannelWindow(Channel);
	if(W != None)
		W.UserInChannel(Nick);
}

function PartedChannel(string Channel, optional string Nick)
{
	local IRC_Channel W;

	W = FindChannelWindow(Channel);

	if(Nick == "")
	{
        RemoveChannel(Channel);
	}
	else
	{
		if(W != None)
			W.PartedChannel(Nick);
	}
}

function ChangedNick(string OldNick, string NewNick)
{
    local int i;

	if(OldNick == NickName)
	{
		NickName = NewNick;
		Link.NickName = NewNick;
		SaveConfig();
	}

    for( i=0; i<Channels.Length; i++ )
    {
        if( Channels[i].FindNick(OldNick) || Channels[i].ChannelName ~= OldNick)
        {
            Channels[i].ChangedNick(OldNick, NewNick);
        }
    }
}

function UserQuit(string Nick, string Reason)
{
    local int i;

    for( i=0; i<Channels.Length; i++ )
    {
        if( Channels[i].FindNick(Nick) )
        {
            Channels[i].UserQuit(Nick, Reason);
        }
    }
}

function UserNotice(string Nick, string Text)
{
    local int i;

    for( i=0; i<Channels.Length; i++ )
    {
        if( Channels[i].FindNick(Nick) )
        {
            Channels[i].UserNotice(Nick, Text);
        }
    }
}

function ChangeMode(string Channel, string Nick, string Mode)
{
	local IRC_Channel W;
	W = FindChannelWindow(Channel);
	if(W != None)
		W.ChangeMode(Nick, Mode);
}

function ChangeOp(string Channel, string Nick, bool bOp)
{
	local IRC_Channel W;
	W = FindChannelWindow(Channel);
	if(W != None)
		W.ChangeOp(Nick, bOp);
}

function ChangeHalfOp(string Channel, string Nick, bool bHalfOp)
{
	local IRC_Channel W;
	W = FindChannelWindow(Channel);
	if(W != None)
		W.ChangeHalfOp(Nick, bHalfOp);
}

function ChangeVoice(string Channel, string Nick, bool bVoice)
{
	local IRC_Channel W;
	W = FindChannelWindow(Channel);
	if(W != None)
		W.ChangeVoice(Nick, bVoice);
}

function ChangeTopic(string Channel, string NewTopic)
{
	local IRC_Channel W;
	W = FindChannelWindow(Channel);
	if(W != None)
	{
		Log("Topic (Channel: "$Channel$") : "$NewTopic);
		W.ChangeTopic(NewTopic);
	}
}

function IsAway(string Nick, string Message)
{
	local IRC_Private W;

	W = FindPrivateWindow(Nick);

	if(W != None)
		W.IsAway(Nick, Message);
	else
		SystemText(Nick@IsAwayText$": "$Message);
}

function IRCVisible()
{
	if(bAway)
	{
		if(bConnected)
			Link.SetAway("");
		bAway = False;
	}
}

function IRCClosed()
{
	CheckAway();
}

function NotifyAfterLevelChange()
{
	//Super.NotifyAfterLevelChange();
	CheckAway();
}

function bool InGame()
{
	// if there are no menus up, we are 'in game'
	if(!Controller.bActive)
	{
		//Log("InGame");
		return true;
	}
	else
	{
		//Log("Not InGame");
		return false;
	}
}

// Update the clients 'away' string
function UpdateAway()
{
	local string URL, AwayString;

	if( bConnected )
	{
		if( !InGame() )
		{
			//Log("Not Away!");
			Link.SetAway("");
			bAway = False;
		}
		else
		{
			URL = PlayerOwner().Level.GetAddressURL();

			if(InStr(URL, ":") > 0)
				AwayString = PlayerOwner().GetURLProtocol()$"://"$URL;
			else
				AwayString = "local game";

			Link.SetAway(AwayString);

			//Log("Away: "$AwayString);

			bAway = True;
		}
	}
}

function CheckAway()
{
	local string URL;

	if( bConnected )
	{
		bAway = True;

		URL = PlayerOwner().Level.GetAddressURL();
		if(InStr(URL, ":") > 0)
			Link.SetAway(PlayerOwner().GetURLProtocol()$"://"$URL);
		else if( InGame() )
			Link.SetAway("local game");
		else
			Link.SetAway("in menus");
	}
}

function CTCP(string Channel, string Nick, string Message)
{
	if(Channel == "" || Channel == NickName)
		SystemText("["$Nick$": "$Message$"]");
	else
		SystemText("["$Nick$":"$Channel$" "$Message$"]");
}

defaultproperties
{
     NotInAChannelText="Not in a channel!"
     KickedFromText="You were kicked from"
     ByText="by"
     IsAwayText="is away"
     ConnectText="CONNECT"
     DisconnectText="DISCONNECT"
     Begin Object Class=GUILabel Name=MyServerLabel
         Caption="Server"
         TextColor=(B=255,G=255,R=255)
         StyleName="TextLabel"
         WinTop=0.100000
         WinLeft=0.030000
         WinWidth=0.200000
         WinHeight=0.300000
     End Object
     ServerLabel=GUILabel'XInterface.IRC_System.MyServerLabel'

     Begin Object Class=GUIButton Name=MyConnectButton
         WinTop=0.100000
         WinLeft=0.560000
         WinWidth=0.200000
         WinHeight=0.300000
         OnClick=IRC_System.ConnectClick
         OnKeyEvent=MyConnectButton.InternalOnKeyEvent
     End Object
     ConnectButton=GUIButton'XInterface.IRC_System.MyConnectButton'

     Begin Object Class=GUIComboBox Name=MyServerCombo
         WinTop=0.100000
         WinLeft=0.150000
         WinWidth=0.400000
         WinHeight=0.300000
         OnKeyEvent=MyServerCombo.InternalOnKeyEvent
     End Object
     ServerCombo=GUIComboBox'XInterface.IRC_System.MyServerCombo'

     Begin Object Class=GUIButton Name=MyRemoveServerButton
         Caption="REMOVE SERVER"
         WinTop=0.100000
         WinLeft=0.770000
         WinWidth=0.200000
         WinHeight=0.300000
         OnClick=IRC_System.RemoveServerClick
         OnKeyEvent=MyRemoveServerButton.InternalOnKeyEvent
     End Object
     RemoveServerButton=GUIButton'XInterface.IRC_System.MyRemoveServerButton'

     Begin Object Class=GUILabel Name=MyChannelLabel
         Caption="Channel"
         TextColor=(B=255,G=255,R=255)
         StyleName="TextLabel"
         WinTop=0.500000
         WinLeft=0.030000
         WinWidth=0.200000
         WinHeight=0.300000
     End Object
     ChannelLabel=GUILabel'XInterface.IRC_System.MyChannelLabel'

     Begin Object Class=GUIButton Name=MyJoinChannelButton
         Caption="JOIN CHANNEL"
         WinTop=0.500000
         WinLeft=0.560000
         WinWidth=0.200000
         WinHeight=0.300000
         OnClick=IRC_System.JoinChannelClick
         OnKeyEvent=MyJoinChannelButton.InternalOnKeyEvent
     End Object
     JoinChannelButton=GUIButton'XInterface.IRC_System.MyJoinChannelButton'

     Begin Object Class=GUIComboBox Name=MyChannelCombo
         WinTop=0.500000
         WinLeft=0.150000
         WinWidth=0.400000
         WinHeight=0.300000
         OnKeyEvent=MyChannelCombo.InternalOnKeyEvent
     End Object
     ChannelCombo=GUIComboBox'XInterface.IRC_System.MyChannelCombo'

     Begin Object Class=GUIButton Name=MyRemoveChannelButton
         Caption="REMOVE CHANNEL"
         WinTop=0.500000
         WinLeft=0.770000
         WinWidth=0.200000
         WinHeight=0.300000
         OnClick=IRC_System.RemoveChannelClick
         OnKeyEvent=MyRemoveChannelButton.InternalOnKeyEvent
     End Object
     RemoveChannelButton=GUIButton'XInterface.IRC_System.MyRemoveChannelButton'

     CurChannel=-1
     PrevChannel=-1
}
