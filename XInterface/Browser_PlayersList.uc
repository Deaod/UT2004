class Browser_PlayersList extends GUIMultiColumnList;

var Browser_ServerListPageBase MyPage;
var Browser_ServersList  MyServersList;
var int listitem;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    OnDrawItem  = MyOnDrawItem;
    OnKeyEvent  = InternalOnKeyEvent;
    Super.Initcomponent(MyController, MyOwner);
}

function MyOnDrawItem(Canvas Canvas, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local float CellLeft, CellWidth;

    GetCellLeftWidth( 0, CellLeft, CellWidth );
    Style.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, MyServersList.Servers[listitem].PlayerInfo[i].PlayerName, FontScale );

    GetCellLeftWidth( 1, CellLeft, CellWidth );
    Style.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, string(MyServersList.Servers[listitem].PlayerInfo[i].Score), FontScale );

    if( MyServersList.Servers[listitem].PlayerInfo[i].StatsID != 0 )
    {
        GetCellLeftWidth( 2, CellLeft, CellWidth );
        Style.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, string(MyServersList.Servers[listitem].PlayerInfo[i].StatsID), FontScale );
    }

    GetCellLeftWidth( 3, CellLeft, CellWidth );
    Style.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, string(MyServersList.Servers[listitem].PlayerInfo[i].Ping), FontScale );
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if( Super.InternalOnKeyEvent(Key, State, delta) )
        return true;

    if( State==1 )
    {
        switch(Key)
        {
        case 0x0D: //IK_Enter
            MyServersList.Connect(false);
            return true;
            break;
        case 0x74: //IK_F5
            MyPage.RefreshList();
            return true;
            break;
        }
    }
    return false;
}

defaultproperties
{
     ColumnHeadings(0)="Player Name"
     ColumnHeadings(1)="Score"
     ColumnHeadings(2)="Stats ID"
     ColumnHeadings(3)="Ping"
     InitColumnPerc(0)=0.170000
     InitColumnPerc(1)=0.110000
     InitColumnPerc(2)=0.110000
     InitColumnPerc(3)=0.110000
}
