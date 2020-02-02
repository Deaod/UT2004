// ====================================================================
//  Class:  xVoting.PlayerInfoMultiColumnList
//
//	Multi-Column list box used to display player info.
//
//  Written by Bruce Bickar
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class PlayerInfoMultiColumnList extends GUIMultiColumnList;

struct PlayerInfoData
{
	var string Label;
	var string Value;
};

var array<PlayerInfoData> ListData;
//------------------------------------------------------------------------------------------------
function Add(string Label, string Value)
{
	ListData.Insert(ListData.Length,1);
	ListData[ListData.Length-1].Label = Label;
	ListData[ListData.Length-1].Value = Value;
	AddedItem();
}
//------------------------------------------------------------------------------------------------
function DrawItem(Canvas Canvas, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local float CellLeft, CellWidth;

	if( i >= SortData.Length || SortData[i].SortItem >= ListData.Length )
		return;

    GetCellLeftWidth( 0, CellLeft, CellWidth );
    Style.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left,
		ListData[SortData[i].SortItem].Label, FontScale );

    GetCellLeftWidth( 1, CellLeft, CellWidth );
    Style.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left,
		ListData[SortData[i].SortItem].Value, FontScale );
}
//------------------------------------------------------------------------------------------------
function string GetSortString( int i )
{
	return ListData[0].Label;
}
//------------------------------------------------------------------------------------------------

defaultproperties
{
     ColumnHeadings(0)="-"
     ColumnHeadings(1)="-"
     InitColumnPerc(0)=0.350000
     InitColumnPerc(1)=0.650000
     SortDescending=True
     SelectedStyleName="BrowserListSelection"
     OnDrawItem=PlayerInfoMultiColumnList.DrawItem
     StyleName="ServerBrowserGrid"
}
