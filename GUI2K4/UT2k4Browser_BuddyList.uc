class UT2K4Browser_BuddyList extends ServerBrowserMCList;

function MyOnDrawItem(Canvas Canvas, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local float CellLeft, CellWidth;

    if( bSelected )
        SelectedStyle.Draw(Canvas, MSAT_Pressed, X, Y-2, W, H+2 );

    GetCellLeftWidth( 0, CellLeft, CellWidth );
    Style.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, UT2K4Browser_ServerListPageBuddy(tp_MyPage).Buddies[i], FontScale );
}

function string GetSortString(int i)
{
    if (i < UT2K4Browser_ServerListPageBuddy(tp_MyPage).Buddies.Length)
        return Caps(UT2K4Browser_ServerListPageBuddy(tp_MyPage).Buddies[i]);

    return "";
}

defaultproperties
{
     ColumnHeadings(0)="Buddy Name"
     InitColumnPerc(0)=1.000000
     ExpandLastColumn=True
}
