class UT2K4Browser_PlayersList extends ServerBrowserMCList;

var array<GameInfo.PlayerResponseLine>  Players;

function MyOnDrawItem(Canvas Canvas, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local float CellLeft, CellWidth;
    local GUIStyles DrawStyle;
    local color TempColor;
    local int Team, PlayerStat;

    if (bSelected)
    {
        DrawStyle = SelectedStyle;
        DrawStyle.Draw(Canvas,MSAT_Pressed, X, Y-2, W, H+2 );
    }

    else DrawStyle = Style;

    TempColor = DrawStyle.FontColors[MenuState];

    // Find out if we have a team number
    PlayerStat = Players[SortData[i].SortItem].StatsID;
    Team = (PlayerStat >> 29) - 1;

    // Clear the extra bits
    PlayerStat = PlayerStat & 268435456;    // 1 << 28
    if (Team == 0 || Team == 1)
        DrawStyle.FontColors[MenuState] = SetColor(Team);


    GetCellLeftWidth( 0, CellLeft, CellWidth );
    DrawStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, Players[SortData[i].SortItem].PlayerName, FontScale);

    GetCellLeftWidth( 1, CellLeft, CellWidth );
    DrawStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, string(Players[SortData[i].SortItem].Score), FontScale );

    if( Players[SortData[i].SortItem].StatsID != 0 )
    {
        GetCellLeftWidth( 2, CellLeft, CellWidth );
        DrawStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, string(PlayerStat), FontScale );
    }

    GetCellLeftWidth( 3, CellLeft, CellWidth );
    DrawStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, string(Players[SortData[i].SortItem].Ping), FontScale );

    DrawStyle.FontColors[MenuState] = TempColor;
}

function color SetColor(int TeamNum)
{
    local color Col;

    if (TeamNum == 0)
    {
        Col.R = 255;
        Col.B = 0;
        Col.G = 0;
        Col.A = 255;
    }

    else
    {
        Col.R = 128;
        Col.B = 255;
        Col.G = 192;
        Col.A = 255;
    }

    return col;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if( Super.InternalOnKeyEvent(Key, State, delta) )
        return true;

    if( State==3 )
    {
        switch(EInputKey(Key))
        {
        case IK_Enter: //IK_Enter
            tp_MyPage.li_Server.Connect(false);
            return true;

        case IK_F5: //IK_F5
            tp_MyPage.RefreshList();
            return true;
        }
    }
    return false;
}

function AddNewPlayer(GameInfo.PlayerResponseLine NewPlayer)
{
    Players[Players.Length] = NewPlayer;
    AddedItem();
}

function Clear()
{
    ItemCount = 0;
    Players.Remove(0, Players.Length);
    Super.Clear();
}

function string GetSortString( int i )
{
    local string S;

    switch (SortColumn)
    {
        case 0:
            S = Left(Caps(Players[i].PlayerName), 8);
            break;

        case 1:
            S = string(Players[i].Score);
            PadLeft(S, 4, "0");
            break;

        case 2:
            S = string(Players[i].StatsID & 268435456);
            PadLeft(S, 9, "0");
            break;

        default:
            S = string(Players[i].Ping);
            PadLeft(S, 5, "0");
    }

    return S;
}

defaultproperties
{
     ColumnHeadings(0)="Name"
     ColumnHeadings(1)="Score"
     ColumnHeadings(2)="Rank"
     ColumnHeadings(3)="Ping"
     InitColumnPerc(0)=0.340000
     InitColumnPerc(1)=0.220000
     InitColumnPerc(2)=0.220000
     InitColumnPerc(3)=0.220000
     ExpandLastColumn=True
}
