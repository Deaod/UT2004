//==============================================================================
//  List of all PlayInfo settings and their values.
//
//  Created by Ron Prestenback
//  © 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class PlayInfoList extends GUIMultiColumnList;

var PlayInfo GamePI;

// GamePI has been replaced, so reinit data
function Refresh()
{
    local int i;

    Clear();
    for (i = 0; i < GamePI.Settings.Length; i++)
        AddedItem();
}

function InternalOnDrawItem(Canvas Canvas, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local float CellLeft, CellWidth;

    GetCellLeftWidth( 0, CellLeft, CellWidth );
    Style.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, GamePI.Settings[SortData[i].SortItem].DisplayName, FontScale );

    GetCellLeftWidth( 1, CellLeft, CellWidth );
    Style.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, GamePI.Settings[SortData[i].SortItem].Value, FontScale );
}

event string GetSortString(int ItemIndex)
{
    if (SortColumn == 0)
        return GamePI.Settings[SortData[ItemIndex].SortItem].DisplayName;
    return GamePI.Settings[SortData[ItemIndex].SortItem].Value;
}

defaultproperties
{
     ColumnHeadings(0)="Setting Name"
     ColumnHeadings(1)="Value"
     ExpandLastColumn=True
     OnDrawItem=PlayInfoList.InternalOnDrawItem
     IniOption="@Internal"
}
