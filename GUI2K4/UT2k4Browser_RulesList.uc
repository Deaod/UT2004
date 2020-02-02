class UT2K4Browser_RulesList extends ServerBrowserMCList;

var array<GameInfo.KeyValuePair>    Rules;

// Move to PlayInfo???  Perhaps make use of Localize()?
var localized string TrueString;
var localized string FalseString;
var localized string ServerModeString;
var localized string DedicatedString;
var localized string NonDedicatedString;
var localized string AdminNameString;
var localized string AdminEmailString;
var localized string PasswordString;
var localized string GameStatsString;
var localized string GameSpeedString;
var localized string MutatorString;
var localized string BalanceTeamsString;
var localized string PlayersBalanceTeamsString;
var localized string FriendlyFireString;
var localized string GoalScoreString;
var localized string TimeLimitString;
var localized string MinPlayersString;
var localized string TranslocatorString;
var localized string WeaponStayString;
var localized string MapVotingString;
var localized string KickVotingString;

function MyOnDrawItem(Canvas Canvas, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local float CellLeft, CellWidth;
    local GUIStyles DrawStyle;

    if (bSelected)
    {
        SelectedStyle.Draw(Canvas, MSAT_Pressed, X, Y-2, W, H+2);
        DrawStyle = SelectedStyle;
    }
    else DrawStyle = Style;

    GetCellLeftWidth( 0, CellLeft, CellWidth );
    DrawStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, LocalizeRules(Rules[SortData[i].SortItem].Key), FontScale );

    GetCellLeftWidth( 1, CellLeft, CellWidth );
    DrawStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, LocalizeRules(Rules[SortData[i].SortItem].Value), FontScale );
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if( Super.InternalOnKeyEvent(Key, State, delta) )
        return true;

    if( State==3 )
    {
        switch( EInputKey(Key) )
        {
        case IK_Enter:
            tp_MyPage.li_Server.Connect(false);
            return true;

        case IK_F5: //IK_F5
            tp_MyPage.RefreshList();
            return true;
        }
    }
    return false;
}

function string LocalizeRules( string code )
{
    switch( caps(code) )
    {
    case "TRUE":                return TrueString;
    case "FALSE":               return FalseString;
    case "SERVERMODE":          return ServerModeString;
    case "DEDICATED":           return DedicatedString;
    case "NON-DEDICATED":       return NonDedicatedString;
    case "ADMINNAME":           return AdminNameString;
    case "ADMINEMAIL":          return AdminEmailString;
    case "PASSWORD":            return PasswordString;
    case "GAMESTATS":           return GameStatsString;
    case "GAMESPEED":           return GameSpeedString;
    case "MUTATOR":             return MutatorString;
    case "BALANCETEAMS":        return BalanceTeamsString;
    case "PLAYERSBALANCETEAMS": return PlayersBalanceTeamsString;
    case "FRIENDLYFIRE":        return FriendlyFireString;
    case "GOALSCORE":           return GoalScoreString;
    case "TIMELIMIT":           return TimeLimitString;
    case "MINPLAYERS":          return MinPlayersString;
    case "TRANSLOCATOR":        return TranslocatorString;
    case "WEAPONSTAY":          return WeaponStayString;
    case "MAPVOTING":           return MapVotingString;
    case "KICKVOTING":          return KickVotingString;
    }
    return code;
}

function AddNewRule(GameInfo.KeyValuePair NewRule)
{
    Rules[Rules.Length] = NewRule;
    AddedItem();
}

function Clear()
{
    ItemCount = 0;
    Rules.Remove(0, Rules.Length);
    Super.Clear();
}

function string GetSortString( int i )
{
    local string S;

    if (SortColumn == 1)
    {
        S = LocalizeRules(Rules[i].Value);
        S = Left(S, 10);
    }

    else
    {
        S = LocalizeRules(Rules[i].Key);
        S = Left(S, 10);
    }

    return S;
}

defaultproperties
{
     TrueString="Enabled"
     FalseString="Disabled"
     ServerModeString="Server Mode"
     DedicatedString="Dedicated"
     NonDedicatedString="Non-Dedicated"
     AdminNameString="Server Admin"
     AdminEmailString="Admin Email"
     PasswordString="Requires Password"
     GameStatsString="UT2004 Stats"
     GameSpeedString="Game Speed"
     MutatorString="Mutator"
     BalanceTeamsString="Bots Balance Teams"
     PlayersBalanceTeamsString="Balance Teams"
     FriendlyFireString="Friendly Fire"
     GoalScoreString="Goal Score"
     TimeLimitString="Time Limit"
     MinPlayersString="Minimum Players (bots)"
     TranslocatorString="Translocator"
     WeaponStayString="Weapons Stay"
     MapVotingString="Map Voting"
     KickVotingString="Kick Voting"
     ColumnHeadings(0)="Setting"
     ColumnHeadings(1)="Value"
     InitColumnPerc(0)=0.500000
     InitColumnPerc(1)=0.500000
     ExpandLastColumn=True
}
