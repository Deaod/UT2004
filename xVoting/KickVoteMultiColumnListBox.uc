// ====================================================================
//  Class:  xVoting.KickVoteMultiColumnListBox
//
//	Multi-Column list box used to display Players.
//
//  Written by Bruce Bickar
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class KickVoteMultiColumnListBox extends GUIMultiColumnListBox;

var string KickInfoPage;
//------------------------------------------------------------------------------------------------
function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	super.InitComponent(MyController, MyOwner);
	if( !PlayerOwner().PlayerReplicationInfo.bAdmin )
    	ContextMenu.ContextItems.Remove(2,2);
}
//------------------------------------------------------------------------------------------------
function InternalOnClick(GUIContextMenu Sender, int Index)
{
	local string PlayerName;

    if (Sender != None)
    {
    	if ( NotifyContextSelect(Sender, Index) )
    		return;

        switch (Index)
        {
            case 0:
                if( KickVotingPage(MenuOwner) != none )
                	KickVotingPage(MenuOwner).SendKickVote();
                break;

            case 1:
            	PlayerName = KickVoteMultiColumnList(List).GetSelectedPlayerName();
            	Controller.OpenMenu( KickInfoPage, PlayerName );
				if( PlayerOwner().PlayerReplicationInfo.bAdmin )
					KickVoteMultiColumnList(List).VRI.RequestPlayerIP( PlayerName );
                break;

            case 2:
            	if( PlayerOwner().PlayerReplicationInfo.bAdmin )
            	{
            		PlayerName = KickVoteMultiColumnList(List).GetSelectedPlayerName();
            		PlayerOwner().ConsoleCommand("ADMIN KICK " $ PlayerName);
            	}
                break;

            case 3:
            	if( PlayerOwner().PlayerReplicationInfo.bAdmin )
            	{
            		PlayerName = KickVoteMultiColumnList(List).GetSelectedPlayerName();
            		PlayerOwner().ConsoleCommand("ADMIN KICKBAN " $ PlayerName);
            		PlayerOwner().ConsoleCommand("ADMIN KICK BAN " $ PlayerName);
            	}
                break;
        }
    }
}
//------------------------------------------------------------------------------------------------
function bool InternalOnRightClick(GUIComponent Sender)
{
	local int NewIndex;

	NewIndex = List.Top + ( (Controller.MouseY - List.ClientBounds[1]) / List.ItemHeight);
	if( NewIndex >= List.ItemCount )
		NewIndex = List.ItemCount - 1;
	List.SetIndex(NewIndex);
    return true;
}
//------------------------------------------------------------------------------------------------

defaultproperties
{
     KickInfoPage="xVoting.KickInfoPage"
     DefaultListClass="xVoting.KickVoteMultiColumnList"
     Begin Object Class=GUIContextMenu Name=RCMenu
         ContextItems(0)="Vote to Kick this Player"
         ContextItems(1)="View Player Details"
         ContextItems(2)="[Admin] Kick from Server"
         ContextItems(3)="[Admin] Ban from Server"
         OnSelect=KickVoteMultiColumnListBox.InternalOnClick
         StyleName="ServerListContextMenu"
     End Object
     ContextMenu=GUIContextMenu'xVoting.KickVoteMultiColumnListBox.RCMenu'

     OnRightClick=KickVoteMultiColumnListBox.InternalOnRightClick
}
