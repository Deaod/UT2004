//====================================================================
//  Specialized utility panel for use on the IRC status page.
//  Contains combo boxes for servers & channels, buttons for join, leave, remove, etc.
//
//  Written by Ron Prestenback
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class UT2K4IRC_Panel extends GUIPanel;


var UT2K4IRC_System          tp_System;

// Server/channel selection
var automated	moComboBox	co_Server, co_Channel;
var automated	GUIButton	b_Connect, b_RemServer, b_JoinChannel, b_RemChannel;

var GUIButton SizingButton;
var() globalconfig array<string> ServerHistory, ChannelHistory;

var localized string 			ConnectText;
var localized string 			DisconnectText;

var localized string			LocalChannel;

var() noexport transient bool bDirty;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local GUIComponent C;

	Super.InitComponent(MyController, MyOwner);

	for ( C = MenuOwner; C != None; C = C.MenuOwner )
	{
		if ( UT2K4IRC_System(C) != None )
		{
			tp_System = UT2K4IRC_System(C);
			break;
		}
	}

	Assert(tp_System != None);
	GetSizingButton();

	// Load server and channel history into combo's
	Log(ServerHistory.Length$" Servers "$ChannelHistory.Length$" Channels",'IRC');

	LoadServerHistory();
	LoadChannelHistory();

}

function LoadServerHistory()
{
	local int i;

	if ( ServerHistory.Length == 0 )
		ResetConfig("ServerHistory");

	co_Server.MyComboBox.List.Clear();
	for ( i = 0; i < ServerHistory.Length; i++ )
		co_Server.AddItem(ServerHistory[i]);
}

function LoadChannelHistory()
{
	local int i;

	if ( ChannelHistory.Length == 0 )
		ResetConfig("ChannelHistory");

	co_Channel.MyComboBox.List.Clear();
	co_Channel.AddItem(LocalChannel);

	for ( i = 0; i < ChannelHistory.Length; i++ )
		if ( caps(ChannelHistory[i]) != caps(LocalChannel) )
			co_Channel.AddItem(ChannelHistory[i]);
}

function GetSizingButton()
{
	local int i;

	for ( i = 0; i < Components.Length; i++ )
	{
		if ( GUIButton(Components[i]) == None )
			continue;

		if ( SizingButton == None || Len(GUIButton(Components[i]).Caption) > Len(SizingButton.Caption) )
			SizingButton = GUIButton(Components[i]);
	}
}

function bool PositionButtons( Canvas C )
{
	local float X;
	local float XL, YL;

	SizingButton.Style.TextSize( C, SizingButton.MenuState, SizingButton.Caption, XL, YL, SizingButton.FontScale );

	XL += 14;
	X = b_Connect.ActualLeft();

	b_Connect.WinWidth = b_Connect.RelativeWidth(XL);
	b_JoinChannel.WinWidth = b_JoinChannel.RelativeWidth(XL);

	b_RemServer.WinLeft = b_RemServer.RelativeLeft( X + XL + (XL * 0.1) );
	b_RemServer.WinWidth = b_RemServer.RelativeWidth( XL );

	b_RemChannel.WinLeft = b_RemChannel.RelativeLeft( X + XL + (XL * 0.1) );
	b_RemChannel.WinWidth = b_RemChannel.RelativeWidth( XL );

	return false;
}

function InternalOnChange(GUIComponent Sender)
{
	if ( Sender == co_Server )
		UpdateConnectionStatus(IsCurrentServer(co_Server.GetText()));
}

function bool InternalOnClick(GUIComponent Sender)
{
	local string Str;

	switch ( Sender )
	{
	case b_Connect:
		if( IsCurrentServer(co_Server.GetText()) )
			tp_System.Disconnect();

		else
		{
			tp_System.Connect( co_Server.GetText() );
			if( tp_System.IsConnected() )
			{
				Str = co_Server.GetText();

				// Place server at the most recent position in history
				AddServerToHistory(str);
			}
		}
		break;

	case b_JoinChannel:
		if ( !tp_System.IsConnected() )
			return false;

		Str = co_Channel.GetText();
		if (Str != "")
		{
			tp_System.JoinChannel( Str );

			// place channel name at most recent position in history
			AddChannelToHistory(str);
		}
		break;

	case b_RemServer:
		RemoveServerFromHistory(co_Server.GetText());

		break;

	case b_RemChannel:
		RemoveChannelFromHistory(co_Channel.GetText());
		break;

	}

	return true;
}


function UpdateConnectionStatus( bool NowConnected )
{
	if( NowConnected )
		b_Connect.Caption = DisconnectText;
	else
		b_Connect.Caption = ConnectText;
}

function bool AddChannelToHistory( string NewChannelName, optional int Position )
{
	if ( NewChannelName == "" )
		return false;

	if ( Left(NewChannelName,1) != "#" )
		NewChannelName = "#" $ NewChannelName;

	RemoveChannelFromHistory(NewChannelName);
	if ( Position < 0 || Position >= ChannelHistory.Length )
		Position = ChannelHistory.Length;

	ChannelHistory.Insert(Position,1);
	ChannelHistory[Position] = NewChannelName;

	co_Channel.MyComboBox.List.Insert(Position,NewChannelName);
	co_Channel.Find(NewChannelName);

	bDirty = True;
	return true;
}

function bool RemoveChannelFromHistory( string ChannelName )
{
	local int i;

	if ( Left(ChannelName,1) != "#" )
		ChannelName = "#" $ ChannelName;

	i = FindChannelHistoryIndex(ChannelName);
	if ( i != -1 )
	{
		ChannelHistory.Remove(i,1);
		co_Channel.RemoveItem(i,1);
		bDirty = True;
		return true;
	}

	return false;
}

function bool AddServerToHistory( string NewServerName, optional int Position )
{
	if ( NewServerName == "" )
		return false;

	RemoveServerFromHistory(NewServerName);
	if ( Position < 0 || Position >= ServerHistory.Length )
		Position = ServerHistory.Length;

	ServerHistory.Insert(Position,1);
	ServerHistory[Position] = NewServerName;

	co_Server.MyComboBox.List.Insert(Position,NewServerName);
	co_Server.Find(NewServerName);

	bDirty = True;
	return true;
}

function bool RemoveServerFromHistory( string ServerName )
{
	local int i;

	if ( ServerName == "" )
		return false;

	i = FindServerHistoryIndex(ServerName);
	if ( i != -1 )
	{
		ServerHistory.Remove(i,1);
		co_Server.RemoveItem(i,1);
		bDirty = true;
		return true;
	}

	return false;
}

// =====================================================================================================================
//  Utility functions
// =====================================================================================================================
function int FindServerHistoryIndex( string ServerName )
{
	local int i;

	for(i=0; i<ServerHistory.Length; i++)
		if( ServerHistory[i] ~= ServerName )
			return i;

	return -1;
}

function int FindChannelHistoryIndex( string ChannelName )
{
	local int i;

	for(i=0; i<ChannelHistory.Length; i++)
		if( ChannelHistory[i] ~= ChannelName )
			return i;

	return -1;
}

function bool IsCurrentServer( string ServerAddress )
{
	if ( tp_System == None || !tp_System.IsConnected() ||
		 tp_System.Link == None || tp_System.Link.ServerAddress == "" ||
		 ServerAddress == "" )
		return False;

	return InStr(ServerAddress, tp_System.Link.ServerAddress) != -1;
}

event Free()
{
	Super.Free();
	if ( bDirty )
		SaveConfig();
}

defaultproperties
{
     Begin Object Class=moComboBox Name=MyServerCombo
         CaptionWidth=0.250000
         Caption="Server"
         OnCreateComponent=MyServerCombo.InternalOnCreateComponent
         WinTop=0.102967
         WinLeft=0.150000
         WinWidth=0.400000
         WinHeight=0.300000
         RenderWeight=3.000000
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         OnChange=UT2k4IRC_Panel.InternalOnChange
     End Object
     co_Server=moComboBox'GUI2K4.UT2k4IRC_Panel.MyServerCombo'

     Begin Object Class=moComboBox Name=MyChannelCombo
         CaptionWidth=0.250000
         Caption="Channel"
         OnCreateComponent=MyChannelCombo.InternalOnCreateComponent
         WinTop=0.500000
         WinLeft=0.150000
         WinWidth=0.400000
         WinHeight=0.300000
         RenderWeight=3.000000
         TabOrder=1
         bBoundToParent=True
         bScaleToParent=True
     End Object
     co_Channel=moComboBox'GUI2K4.UT2k4IRC_Panel.MyChannelCombo'

     Begin Object Class=GUIButton Name=MyConnectButton
         Caption="CONNECT"
         WinTop=0.100000
         WinLeft=0.560000
         WinWidth=0.200000
         WinHeight=0.300000
         RenderWeight=3.000000
         TabOrder=2
         bBoundToParent=True
         bScaleToParent=True
         OnClick=UT2k4IRC_Panel.InternalOnClick
         OnKeyEvent=MyConnectButton.InternalOnKeyEvent
     End Object
     b_Connect=GUIButton'GUI2K4.UT2k4IRC_Panel.MyConnectButton'

     Begin Object Class=GUIButton Name=MyRemoveServerButton
         Caption="REMOVE"
         WinTop=0.100000
         WinLeft=0.770000
         WinWidth=0.200000
         WinHeight=0.300000
         RenderWeight=3.000000
         TabOrder=4
         bBoundToParent=True
         bScaleToParent=True
         OnClick=UT2k4IRC_Panel.InternalOnClick
         OnKeyEvent=MyRemoveServerButton.InternalOnKeyEvent
     End Object
     b_RemServer=GUIButton'GUI2K4.UT2k4IRC_Panel.MyRemoveServerButton'

     Begin Object Class=GUIButton Name=MyJoinChannelButton
         Caption="JOIN"
         WinTop=0.500000
         WinLeft=0.560000
         WinWidth=0.200000
         WinHeight=0.300000
         RenderWeight=3.000000
         TabOrder=3
         bBoundToParent=True
         bScaleToParent=True
         OnClick=UT2k4IRC_Panel.InternalOnClick
         OnKeyEvent=MyJoinChannelButton.InternalOnKeyEvent
     End Object
     b_JoinChannel=GUIButton'GUI2K4.UT2k4IRC_Panel.MyJoinChannelButton'

     Begin Object Class=GUIButton Name=MyRemoveChannelButton
         Caption="REMOVE"
         WinTop=0.500000
         WinLeft=0.770000
         WinWidth=0.200000
         WinHeight=0.300000
         RenderWeight=3.000000
         TabOrder=5
         bBoundToParent=True
         bScaleToParent=True
         OnClick=UT2k4IRC_Panel.InternalOnClick
         OnKeyEvent=MyRemoveChannelButton.InternalOnKeyEvent
     End Object
     b_RemChannel=GUIButton'GUI2K4.UT2k4IRC_Panel.MyRemoveChannelButton'

     ServerHistory(0)="irc.enterthegame.com"
     ServerHistory(1)="irc.utchat.com"
     ConnectText="CONNECT"
     DisconnectText="DISCONNECT"
     LocalChannel="#ut"
     OnPreDraw=UT2k4IRC_Panel.PositionButtons
}
