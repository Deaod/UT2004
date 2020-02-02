// ====================================================================
//  Class:  xVoting.MapVoteCountMultiColumnList
//
//	Multi-Column list box used to display maps and game types.
//
//  Written by Bruce Bickar
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class MapVoteCountMultiColumnList extends GUIMultiColumnList;

var VotingReplicationInfo VRI;
var int PrevSortColumn;
//------------------------------------------------------------------------------------------------
function LoadList(VotingReplicationInfo LoadVRI)
{
	local int i;

	VRI = LoadVRI;

	for( i=0; i<VRI.MapVoteCount.Length; i++)
		AddedItem();

	OnDrawItem = DrawItem;
}
//------------------------------------------------------------------------------------------------
function UpdatedVoteCount(int UpdatedIndex, bool bRemoved)
{
	if( bRemoved )
		RemovedItem(UpdatedIndex);
	else
	{
		if( UpdatedIndex >= ItemCount )
			AddedItem();
		else
			UpdatedItem(UpdatedIndex);

	}
	OnSortChanged();
}
//------------------------------------------------------------------------------------------------
// TODO: move up to GUIMultiColumnList
/*
function RemovedItem(int RemovedIndex)
{
	local int i;

	if( RemovedIndex >= 0 )
	{
		for( i=0; i<SortData.Length; i++ )
		{
			if( SortData[i].SortItem == RemovedIndex )
			{
				SortData.Remove(i,1);
				break;
			}
		}
		for( i=0; i<InvSortData.Length; i++ )
		{
			if( InvSortData[i] == RemovedIndex )
			{
				InvSortData.Remove(i,1);
				break;
			}
		}
		ItemCount--;
		// Force updating of sort data
		OnSortChanged();
		if( Index == RemovedIndex )
			Index = -1;
	}
}
*/
//------------------------------------------------------------------------------------------------
function int GetSelectedMapIndex()
{
	return VRI.MapVoteCount[SortData[Index].SortItem].MapIndex;
}
//------------------------------------------------------------------------------------------------
function int GetSelectedGameConfigIndex()
{
	return VRI.MapVoteCount[SortData[Index].SortItem].GameConfigIndex;
}
//------------------------------------------------------------------------------------------------
function string GetSelectedMapName()
{
    if( Index > -1 )
		return VRI.MapList[VRI.MapVoteCount[SortData[Index].SortItem].MapIndex].MapName;
	else
		return "";
}
//------------------------------------------------------------------------------------------------
function DrawItem(Canvas Canvas, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local float CellLeft, CellWidth;
    local GUIStyles DrawStyle;

    if( VRI == none )
    	return;

    // Draw the selection border
    if( bSelected )
    {
        SelectedStyle.Draw(Canvas,MenuState, X, Y-2, W, H+2 );
        DrawStyle = SelectedStyle;
    }
    else
        DrawStyle = Style;

    GetCellLeftWidth( 0, CellLeft, CellWidth );
    DrawStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left,
		VRI.GameConfig[VRI.MapVoteCount[SortData[i].SortItem].GameConfigIndex].GameName, FontScale );

    GetCellLeftWidth( 1, CellLeft, CellWidth );
    DrawStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left,
		VRI.MapList[VRI.MapVoteCount[SortData[i].SortItem].MapIndex].MapName, FontScale );

    GetCellLeftWidth( 2, CellLeft, CellWidth );
    DrawStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left,
		string(VRI.MapVoteCount[SortData[i].SortItem].VoteCount), FontScale );
}
//------------------------------------------------------------------------------------------------
function string GetSortString( int i )
{
	local string ColumnData[5];

	ColumnData[0] = left(Caps(VRI.GameConfig[VRI.MapVoteCount[i].GameConfigIndex].GameName),15);
	ColumnData[1] = left(Caps(VRI.MapList[VRI.MapVoteCount[i].MapIndex].MapName),20);
	ColumnData[2] = right("0000" $ VRI.MapVoteCount[i].VoteCount,4);

	return ColumnData[SortColumn] $ ColumnData[PrevSortColumn];
}
//------------------------------------------------------------------------------------------------
event OnSortChanged()
{
	Super.OnSortChanged();
	PrevSortColumn = SortColumn;
}
//------------------------------------------------------------------------------------------------
function Free()
{
	VRI = none;
	super.Free();
}
//------------------------------------------------------------------------------------------------
function bool InternalOnDragDrop(GUIComponent Sender)
{
	return true;
}
//------------------------------------------------------------------------------------------------

defaultproperties
{
     ColumnHeadings(0)="GameType"
     ColumnHeadings(1)="MapName"
     ColumnHeadings(2)="Votes"
     InitColumnPerc(0)=0.300000
     InitColumnPerc(1)=0.400000
     InitColumnPerc(2)=0.300000
     ColumnHeadingHints(0)="Game Type"
     ColumnHeadingHints(1)="Map Name"
     ColumnHeadingHints(2)="Number of votes registered for this map."
     SortColumn=2
     SortDescending=True
     SelectedStyleName="BrowserListSelection"
     StyleName="ServerBrowserGrid"
}
