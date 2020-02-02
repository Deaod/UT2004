class Browser_RulesList extends GUIMultiColumnList;

var Browser_ServerListPageBase MyPage;
var Browser_ServersList  MyServersList;
var int listitem;

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
    Style.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, LocalizeRules(MyServersList.Servers[listitem].ServerInfo[i].Key), FontScale );

    GetCellLeftWidth( 1, CellLeft, CellWidth );
    Style.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, LocalizeRules(MyServersList.Servers[listitem].ServerInfo[i].Value), FontScale );
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
    }
    return code;
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
     ColumnHeadings(0)="Setting"
     ColumnHeadings(1)="Value"
     InitColumnPerc(0)=0.250000
     InitColumnPerc(1)=0.250000
     ExpandLastColumn=True
}
