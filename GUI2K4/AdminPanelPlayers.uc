//==============================================================================
//  Created on: 11/12/2003
//  Contains controls for administering players on the server (kick/ban)
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class AdminPanelPlayers extends AdminPanelBase;

var  automated GUIMultiColumnListbox lb_Players;
var            AdminPlayerList       li_Players;
var automated GUIButton              b_Kick, b_Ban;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController,MyOwner);

	li_Players = AdminPlayerList(lb_Players.List);
}

function ProcessPlayer(string PlayerInfo)
{
	if (PlayerInfo=="Done")
    	XPlayer(PlayerOwner()).ProcessRule = None;
	else li_Players.Add(PlayerInfo);
}

function ReloadList()
{
	local xPlayer PC;

	PC = xPlayer(PlayerOwner());
	if ( PC == None )
		return;

	li_Players.Clear();
    PC.ProcessRule = ProcessPlayer;
   	PC.ServerRequestPlayerInfo();
}

function bool InternalOnClick(GUIComponent Sender)
{
	switch ( Sender )
	{
	case b_Kick:
		if ( bAdvancedAdmin )
			AdminCommand( "kick"@li_Players.MyPlayers[li_Players.Index].PlayerID );
		else AdminCommand( "kick"@li_Players.MyPlayers[li_Players.Index].PlayerName );

		ReloadList();
		return true;

	case b_Ban:
		if ( bAdvancedAdmin )
			AdminCommand( "kick ban"@li_Players.MyPlayers[li_Players.Index].PlayerID );
		else AdminCommand( "kickban"@li_Players.MyPlayers[li_Players.Index].PlayerName);

		ReloadList();
		return true;
	}
}

defaultproperties
{
     Begin Object Class=GUIMultiColumnListBox Name=AdminPlayersListBox
         DefaultListClass="XInterface.AdminPlayerList"
         bVisibleWhenEmpty=True
         OnCreateComponent=AdminPlayersListBox.InternalOnCreateComponent
         StyleName="ServerBrowserGrid"
         WinHeight=0.878127
         bBoundToParent=True
         bScaleToParent=True
     End Object
     lb_Players=GUIMultiColumnListBox'GUI2K4.AdminPanelPlayers.AdminPlayersListBox'

     Begin Object Class=GUIButton Name=KickButton
         Caption="Kick"
         Hint="Kick this Player"
         WinTop=0.900000
         WinLeft=0.743750
         WinWidth=0.120000
         WinHeight=0.070625
         bBoundToParent=True
         bScaleToParent=True
         OnClick=AdminPanelPlayers.InternalOnClick
         OnKeyEvent=KickButton.InternalOnKeyEvent
     End Object
     b_Kick=GUIButton'GUI2K4.AdminPanelPlayers.KickButton'

     Begin Object Class=GUIButton Name=BanButton
         Caption="Ban"
         Hint="Ban this player"
         WinTop=0.900000
         WinLeft=0.868750
         WinWidth=0.120000
         WinHeight=0.070625
         bBoundToParent=True
         bScaleToParent=True
         OnClick=AdminPanelPlayers.InternalOnClick
         OnKeyEvent=BanButton.InternalOnKeyEvent
     End Object
     b_Ban=GUIButton'GUI2K4.AdminPanelPlayers.BanButton'

     PanelCaption="Players"
     WinTop=0.000000
     WinHeight=0.625003
}
