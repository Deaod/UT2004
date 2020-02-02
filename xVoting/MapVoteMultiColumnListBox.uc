// ====================================================================
//  Class:  xVoting.MapVoteMultiColumnListBox
//
//	Multi-Column list box used to display maps and game types.
//
//  Written by Bruce Bickar
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class MapVoteMultiColumnListBox extends GUIMultiColumnListBox;

var string MapInfoPage;
var array<MapVoteMultiColumnList> ListArray;
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
            	MapName = MapVoteMultiColumnList(List).GetSelectedMapName();
            	Controller.OpenMenu( MapInfoPage, MapName );
                break;
        }
    }
}
//------------------------------------------------------------------------------------------------
function LoadList(VotingReplicationInfo LoadVRI)
{
	local int i,g;

	ListArray.Length = LoadVRI.GameConfig.Length;
	for( i=0; i<LoadVRI.GameConfig.Length; i++)
	{
		ListArray[i] = new class'MapVoteMultiColumnList';
		ListArray[i].LoadList(LoadVRI,i);
		if( LoadVRI.GameConfig[i].GameClass ~= PlayerOwner().GameReplicationInfo.GameClass )
			g = i;
	}
	ChangeGameType(g);
}
//------------------------------------------------------------------------------------------------
function ChangeGameType( int GameTypeIndex )
{
	InitBaseList( ListArray[GameTypeIndex] );
}
//------------------------------------------------------------------------------------------------
function InitBaseList(GUIListBase LocalList)
{
    local GUIMultiColumnList L;

    L = GUIMultiColumnList(LocalList);

    if (L == none)
        return;

    if( List == LocalList )
    {
        Header.MyList = List;
        return;
    }

    if (List != None)
    {
        List.SetTimer(0.0, False);
        RemoveComponent(List,true);
        AppendComponent(L,false);
        List = L;
    }
    else
    {
        List = L;
        AppendComponent(L,false);
    }
    Header.MyList = List;
    Super(GUIListBoxBase).InitBaseList(LocalList);
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
function Free()
{
	local int i;
	for( i=0; i < ListArray.Length; i++ )
		ListArray[i].VRI = none;
	super.Free();
}
//------------------------------------------------------------------------------------------------

defaultproperties
{
     MapInfoPage="xVoting.MapInfoPage"
     DefaultListClass="xVoting.MapVoteMultiColumnList"
     Begin Object Class=GUIContextMenu Name=RCMenu
         ContextItems(0)="Vote for this Map"
         ContextItems(1)="View Screenshot and Description"
         OnSelect=MapVoteMultiColumnListBox.InternalOnClick
     End Object
     ContextMenu=GUIContextMenu'xVoting.MapVoteMultiColumnListBox.RCMenu'

     OnRightClick=MapVoteMultiColumnListBox.InternalOnRightClick
}
