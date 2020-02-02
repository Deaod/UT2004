// ====================================================================
//  Class:  xVoting.MapVoteCountMultiColumnListBox
//
//	Multi-Column list box used to display maps with vote counts.
//
//  Written by Bruce Bickar
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class MapVoteCountMultiColumnListBox extends GUIMultiColumnListBox;

var string MapInfoPage;
//------------------------------------------------------------------------------------------------
function InternalOnClick(GUIContextMenu Sender, int Index)
{
	local string MapName;

    if (Sender != None)
    {
    	if ( NotifyContextSelect(Sender, Index) )
    		return;

        switch (Index)
        {
            case 0:
                if( MapVotingPage(MenuOwner) != none )
                	MapVotingPage(MenuOwner).SendVote(self);
                break;

            case 1:
            	MapName = MapVoteCountMultiColumnList(List).GetSelectedMapName();
            	Controller.OpenMenu( MapInfoPage, MapName );
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
     MapInfoPage="xVoting.MapInfoPage"
     DefaultListClass="xVoting.MapVoteCountMultiColumnList"
     Begin Object Class=GUIContextMenu Name=RCMenu
         ContextItems(0)="Vote for this Map"
         ContextItems(1)="View Screenshot and Description"
         OnSelect=MapVoteCountMultiColumnListBox.InternalOnClick
         StyleName="ServerListContextMenu"
     End Object
     ContextMenu=GUIContextMenu'xVoting.MapVoteCountMultiColumnListBox.RCMenu'

     OnRightClick=MapVoteCountMultiColumnListBox.InternalOnRightClick
}
