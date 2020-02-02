class Browser_BuddyList extends GUIMultiColumnList;

var Browser_ServerListPageBuddy MyBuddyPage;
var GUIStyles SelStyle;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    OnDrawItem = MyOnDrawItem;

    SelStyle = Controller.GetStyle("SquareButton",FontScale);
}


function MyOnDrawItem(Canvas Canvas, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local float CellLeft, CellWidth;

    if( bSelected )
        SelStyle.Draw(Canvas, MSAT_Pressed, X, Y-2, W, H+2 );

    GetCellLeftWidth( 0, CellLeft, CellWidth );
    Style.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, MyBuddyPage.Buddies[i], FontScale );
}

defaultproperties
{
     ColumnHeadings(0)="Buddy Name"
     InitColumnPerc(0)=1.000000
     ExpandLastColumn=True
}
