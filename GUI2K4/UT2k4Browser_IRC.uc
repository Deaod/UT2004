//====================================================================
//  Main IRC page - Contains additional TabControl
//
//  Updated by Ron Prestenback
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class UT2K4Browser_IRC extends UT2K4Browser_Page;

var automated GUITabControl		c_Channel;

var UT2K4IRC_System			tp_System;
var() config  string	SystemPageClass, PublicChannelClass, PrivateChannelClass;

var localized string	SystemLabel;
var localized string	ChooseNewNickText;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	c_Channel.OnChange = TabChange;

	tp_System = UT2K4IRC_System(c_Channel.AddTab(SystemLabel, SystemPageClass, , , True));
	tp_System.OnDisconnect = IRCDisconnected;
	tp_System.NewChannelSelected = SetCurrentChannel;
}

function IRCDisconnected()
{
	local int i;

	for ( i = c_Channel.TabStack.Length - 1; i >= 0; i-- )
		if ( c_Channel.TabStack[i] != None && c_Channel.TabStack[i].MyPanel != tp_System )
			c_Channel.RemoveTab("",c_Channel.TabStack[i]);
}

event Closed(GUIComponent Sender, bool bCancelled)
{
	// TODO: Am I not calling Super.Closed() on purpose here?
	Super.Closed(Sender,bCancelled);
	tp_System.IRCClosed();
}

function ShowPanel(bool bShow)
{
	Super.ShowPanel(bShow);

	if ( bInit && bShow )
	{
		tp_System.SetCurrentChannel(-1); // Initially, System page is shown
		bInit = False;
	}
}

// Called when a new tab is activated
function TabChange(GUIComponent Sender)
{
	local int i;
	local GUITabButton TabButton;

	TabButton = GUITabButton(Sender);

	if ( TabButton == none || !Controller.bCurMenuInitialized)
		return;

	i = tp_System.FindPublicChannelIndex( TabButton.Caption, True );
	UpdateCurrentChannel(i);
}

function SetCurrentChannel( int Index )
{
	local GUITabButton But;
	local int i;

	if( Index == -1 )
		But = tp_System.MyButton;
	else
	{
		i = c_Channel.TabIndex( tp_System.Channels[Index].ChannelName );
		if ( i >= 0 && i < c_Channel.TabStack.Length )
			But = c_Channel.TabStack[i];
	}

	c_Channel.ActivateTab( But, true );
}

function UpdateCurrentChannel( int Index )
{
//	log("UpdateCurrentChannel:"$Index);
	CheckSpectateButton(tp_System.ValidChannelIndex(Index));
/*	if ( tp_System.ValidChannelIndex(Index) )
	{
		Chan = tp_System.Channels[Index];
		if ( Chan == None )
			return;

		// Set the text of the 'close window' button to the channel name
		if ( Chan.IsPrivate )
			SetCloseCaption( Chan.ChannelName );
		else SetCloseCaption();

		// Enable the 'close window' button
		CheckSpectateButton(True);
	}

	else
	{
		SetCloseCaption();

		// Disable the 'close window' button
		CheckSpectateButton(False);
	}
*/
	tp_System.UpdateCurrentChannel(Index);
}

function SetCloseCaption( optional string NewName )
{
	if ( NewName != "" )
		SetSpectateCaption( Repl(class'UT2K4IRC_System'.default.LeavePrivateText, "%ChanName%", NewName) );
	else SetSpectateCaption(class'UT2K4IRC_System'.default.CloseWindowCaption);
	RefreshFooter(None,string(!bCommonButtonWidth));
}

function UT2K4IRC_Channel AddChannel( string ChannelName, optional bool bPrivate )
{
	return UT2K4IRC_Channel( c_Channel.AddTab(ChannelName, Eval( bPrivate, PrivateChannelClass, PublicChannelClass )) );
}

function bool RemoveChannel( string ChannelName )
{
	if ( ChannelName ~= SystemLabel || ChannelName == "" )
		return false;

	c_Channel.RemoveTab(ChannelName);
	return true;
}

//========================================================================================
//========================================================================================
// Server Browser callbacks
//========================================================================================
//========================================================================================

function JoinClicked()
{
	if ( tp_System != None )
		tp_System.ChangeCurrentNick();
}

function SpectateClicked()
{
	if ( tp_System != None )
		tp_System.PartCurrentChannel();
}

function RefreshClicked()
{
	if ( tp_System != None )
		tp_System.Disconnect();
}

// Returns whether the refresh button should be available for this panel - also gives chance to modify caption, if necessary
function bool IsRefreshAvailable( out string ButtonCaption )
{
	return tp_System != None && tp_System.DisconnectAvailable(ButtonCaption);
	return false;
}

// Returns whether the spectate button should be available for this panel - also gives chance to modify caption, if necessary
function bool IsSpectateAvailable( out string ButtonCaption )
{
	return tp_System != None && tp_System.LeaveAvailable(ButtonCaption);
}

// Returns whether the join button should be available for this panel - also gives chance to modify caption, if necessary
function bool IsJoinAvailable( out string ButtonCaption )
{
	return tp_System != None && tp_System.SetNickAvailable(ButtonCaption);
	return true;
}

defaultproperties
{
     Begin Object Class=GUITabControl Name=ChannelTabControl
         bDockPanels=True
         TabHeight=0.040000
         WinHeight=1.000000
         bAcceptsInput=True
         OnActivate=ChannelTabControl.InternalOnActivate
     End Object
     c_Channel=GUITabControl'GUI2K4.UT2k4Browser_IRC.ChannelTabControl'

     SystemPageClass="GUI2K4.UT2K4IRC_System"
     PublicChannelClass="GUI2K4.UT2K4IRC_Channel"
     PrivateChannelClass="GUI2K4.UT2K4IRC_Private"
     SystemLabel="System"
     bCommonButtonWidth=False
     PanelCaption="UT2004 Internet Chat Client"
}
