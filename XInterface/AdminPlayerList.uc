// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class AdminPlayerList extends GUIMultiColumnList;

struct PlayerInfo
{
    var string  PlayerName;
    var string  PlayerID;
    var string  PlayerIP;
};

var array<PlayerInfo> MyPlayers;
var GUIStyles SelStyle;

function Clear()
{
    MyPlayers.Remove(0,MyPlayers.Length);
    Super.Clear();
}

function Add(string PlayerInfo)
{
    local string s;
    local int i,idx;

    idx = MyPlayers.Length;
    MyPlayers.Length = MyPlayers.Length+1;

    i = instr(PlayerInfo,chr(27));
    s = left(PlayerInfo,i);
    MyPlayers[idx].PlayerName=s;
    PlayerInfo = right(PlayerInfo,Len(PlayerInfo)-i-1);

    i = instr(PlayerInfo,chr(27));
    s = left(PlayerInfo,i);
    MyPlayers[idx].PlayerID=s;
    PlayerInfo = right(PlayerInfo,Len(PlayerInfo)-i-1);

    MyPlayers[idx].PlayerIP = PlayerInfo;
    ItemCount++;
    AddedItem();

}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    OnDrawItem  = MyOnDrawItem;
    OnKeyEvent  = InternalOnKeyEvent;
    Super.Initcomponent(MyController, MyOwner);

    SelStyle = Controller.GetStyle("SquareButton",FontScale);

}

function MyOnDrawItem(Canvas Canvas, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local float CellLeft, CellWidth;

    if( bSelected )
    {
        Canvas.SetDrawColor(128,8,8,255);
        Canvas.SetPos(x,y-2);
        Canvas.DrawTile(Controller.DefaultPens[0],w,h+2,0,0,1,1);
        Canvas.SetDrawColor(255,255,255,255);
    }

    GetCellLeftWidth( 0, CellLeft, CellWidth );
    Style.DrawText( Canvas, MenuState, X+CellLeft, Y, CellWidth, H, TXTA_Left, MyPlayers[i].PlayerName, FontScale);

    GetCellLeftWidth( 1, CellLeft, CellWidth );
    Style.DrawText( Canvas, MenuState, X+CellLeft, Y, CellWidth, H, TXTA_Left, MyPlayers[i].PlayerID, FontScale);

    GetCellLeftWidth( 2, CellLeft, CellWidth );
    Style.DrawText( Canvas, MenuState, X+CellLeft, Y, CellWidth, H, TXTA_Left, MyPlayers[i].PlayerIP, FontScale);
}

defaultproperties
{
     ColumnHeadings(0)="Player Name"
     ColumnHeadings(1)="Unique ID"
     ColumnHeadings(2)="IP"
     InitColumnPerc(0)=0.300000
     InitColumnPerc(1)=0.400000
     InitColumnPerc(2)=0.300000
     SortColumn=-1
     WinHeight=1.000000
}
