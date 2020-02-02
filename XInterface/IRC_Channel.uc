class IRC_Channel extends IRC_Page;

var string      ChannelName;
var IRC_System  SystemPage;
var string      ChannelTopic;

var bool    IsPrivate; // ChannelName will ~= Remote's Nick in this case

//struct IRCUser
//{
//    var string  NickName;
//    var bool    bChOp;
//    var bool    bVoice;
//};
//var array<IRCUser> Users;

var GUIListBox  UserListBox;
var bool        bUsersNeedSorting;

// NB - this assume 'flag' is always a 1-character string

function UserSetFlag(int i, string flag, bool bSet)
{
    local string flags;
    local int flagPos;

    flags = UserListBox.List.GetExtraAtIndex(i);

    if(bSet) // TURN FLAG ON
    {
        // If user already has flag set, do nothing.
        if( InStr(flags, flag) != -1 )
            return;

        // Add to end of existing flags.
        UserListBox.List.SetExtraAtIndex(i, flags$flag);
    }
    else // TURN FLAG OFF
    {
        flagPos = InStr(flags, flag);

        // If flag not in flag list, do nothing;
        if(flagPos == -1)
            return;

        // Remove flags from string
        flags = Left(flags, flagPos)$Mid(flags, flagPos+1);

        UserListBox.List.SetExtraAtIndex(i, flags);
    }
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local GUIPanel UtilPanel;

    // Split horizontally to allow room for user list
    GUISplitter(Controls[1]).SplitOrientation = SPLIT_Horizontal;
    GUISplitter(Controls[1]).SplitPosition = 0.75;
    GUISplitter(Controls[1]).bFixedSplitter = false;

    // Put the user list into the Util panel
    UtilPanel = GUIPanel( GUISplitter(Controls[1]).Controls[1] );
    UtilPanel.Controls[0] = UserListBox;

    Super.Initcomponent(MyController, MyOwner);

    // Set delegates for user list box
    UserListBox.List.OnDrawItem=MyOnDrawItem;
    UserListBox.List.CompareItem=MyCompareItem;
    UserListBox.List.OnDblClick=MyListDblClick;
    UserListBox.OnPreDraw=MyOnPreDraw;
}

// Sort the users list prior to drawing if necessary
function bool MyOnPreDraw(Canvas C)
{
    if(bUsersNeedSorting)
    {
        UserListBox.List.SortList();
        bUsersNeedSorting=false;
    }

    return true;
}

function bool MyListDblClick(GUIComponent Sender)
{
    local string UserName;
    UserName = UserListBox.List.Get();

    if(UserName == "")
        return true;

    SystemPage.CreatePrivChannel(UserName, true); // Make new channel active in this case

    return true;
}

// Sort alphabetically, but with ops first, then voice, then plebs :)
function int MyCompareItem(GUIListElem ElemA, GUIListElem ElemB)
{
    local string s1, s2;

    // Add some extra spaces to the start of the names if they are ops or voice (to rank them towards the top)
    if( InStr(ElemA.ExtraStrData,"o") != -1)
        s1 = "   "$ElemA.item;
    else if( InStr(ElemA.ExtraStrData,"h") != -1)
        s1 = "  "$ElemA.item;
    else if( InStr(ElemA.ExtraStrData,"v") != -1)
        s1 = " "$ElemA.item;
    else
        s1 = ElemA.item;

    if( InStr(ElemB.ExtraStrData,"o") != -1)
        s2 = "   "$ElemB.item;
    else if( InStr(ElemB.ExtraStrData,"h") != -1)
        s2 = "  "$ElemB.item;
    else if( InStr(ElemB.ExtraStrData,"v") != -1)
        s2 = " "$ElemB.item;
    else
        s2 = ElemB.item;

    s1 = Caps(s1);
    s2 = Caps(s2);

    // ugh.. need script strcmp
    if(s1 > s2)
        return 1;
    else if(s1 < s2)
        return -1;
    else
        return 0;
}

function MyOnDrawItem(Canvas Canvas, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local string DrawName, NickName, Flags;

    NickName = UserListBox.List.GetItemAtIndex(i);
    Flags = UserListBox.List.GetExtraAtIndex(i);

    if( InStr(Flags,"o") != -1)
        DrawName = "@"$NickName;
    else if( InStr(Flags,"h") != -1)
        DrawName = "%"$NickName;
    else if( InStr(Flags,"v") != -1)
        DrawName = "+"$NickName;
    else
        DrawName = NickName;

    UserListBox.Style.DrawText( Canvas, MSAT_Blurry, X, Y, W, H, TXTA_Left, DrawName, UserListBox.FontScale );
}

// user funcs ---
function int GetUser( string Nick )
{
    local int i;

    for( i=0; i<UserListBox.List.ItemCount; i++ )
    {
        if ( UserListBox.List.GetItemAtIndex(i) ~= Nick )
            return i;
    }
    return -1;
}

function bool FindNick( string Nick )
{
    if( GetUser(Nick) > -1 )
        return true;
    return false;
}

function AddUser( string Nick )
{
    local int i;

    i = GetUser(Nick);
    if( i > -1 )
        return; // already in user list

    UserListBox.List.Add(Nick);
    bUsersNeedSorting=true;
}

function RemoveUser( string Nick )
{
    local int i;

    i = GetUser(Nick);
    if( i < 0 )
        return; // not in list

    UserListBox.List.RemoveItem(Nick);
    bUsersNeedSorting=true;
}

function ChangeNick( string OldNick, string NewNick)
{
    local int i;

    i = GetUser(OldNick);
    if( i < 0 )
        return;
    UserListBox.List.SetItemAtIndex(i, NewNick);
}

function ChangeOp( string Nick, bool NewOp )
{
    local int i;

    i = GetUser(Nick);
    if( i < 0 )
        return;

    UserSetFlag(i, "o", NewOp);
    bUsersNeedSorting=true;
}

function ChangeHalfOp( string Nick, bool NewHalfOp )
{
    local int i;

    i = GetUser(Nick);
    if( i < 0 )
        return;

    UserSetFlag(i, "h", NewHalfOp);
    bUsersNeedSorting=true;
}

function ChangeVoice( string Nick, bool NewVoice )
{
    local int i;

    i = GetUser(Nick);
    if( i < 0 )
        return;
    UserSetFlag(i, "v", NewVoice);
    bUsersNeedSorting=true;
}

function ChangeTopic( string NewTopic )
{
    ChannelTopic = NewTopic;

    TextDisplay.AddText( MakeColorCode(IRCInfoColor)$"*** "$NewTopicText$": "$NewTopic);

    if(!MyButton.bActive)
        MyButton.bForceFlash = true;
}

// --- user funcs

function ChannelText(string Nick, string Text)
{
    TextDisplay.AddText( MakeColorCode(IRCNickColor)$"<"$Nick$"> "$MakeColorCode(IRCTextColor)$ColorizeLinks(Text) );

    if(!MyButton.bActive)
        MyButton.bForceFlash = true;
}

function ChannelAction(string Nick, string Text)
{
    TextDisplay.AddText( MakeColorCode(IRCActionColor)$"* "$Nick$" "$Text );

    if(!MyButton.bActive)
        MyButton.bForceFlash = true;
}

function UserNotice(string Nick, string Text)
{
    TextDisplay.AddText(MakeColorCode(IRCActionColor)$"-"$Nick$"- "$Text);

    if(!MyButton.bActive)
        MyButton.bForceFlash = true;
}

function ProcessInput(string Text)
{
    if(Left(Text, 4) ~= "/me ")
    {
        ChannelAction(SystemPage.NickName, Mid(Text, 4));
        SystemPage.Link.SendChannelAction(ChannelName, Mid(Text, 4));
    }
    else if(Left(Text, 1) == "/")
    {
        SystemPage.Link.SendCommandText(Mid(Text, 1));
    }
    else
    {
        if(Text != "")
        {
            ChannelText(SystemPage.NickName, Text);
            SystemPage.Link.SendChannelText(ChannelName, Text);
        }
    }
}

function PartedChannel(string Nick)
{
    TextDisplay.AddText( MakeColorCode(IRCInfoColor)$"*** "$Nick@HasLeftText@ChannelName$".");
    RemoveUser(Nick);

    if(!MyButton.bActive)
        MyButton.bForceFlash = true;
}

function JoinedChannel(string Nick)
{
    TextDisplay.AddText( MakeColorCode(IRCInfoColor)$"*** "$Nick@HasJoinedText@ChannelName$".");
    AddUser(Nick);

    if(!MyButton.bActive)
        MyButton.bForceFlash = true;
}

function KickUser(string KickedNick, string Kicker, string Reason)
{
    TextDisplay.AddText( MakeColorCode(IRCInfoColor)$"*** "$KickedNick@WasKickedByText@Kicker$" ("$Reason$")");
    RemoveUser(KickedNick);

    if(!MyButton.bActive)
        MyButton.bForceFlash = true;
}

function UserInChannel(string Nick)
{
    AddUser(Nick);
}

function ChangedNick(string OldNick, string NewNick)
{
    TextDisplay.AddText( MakeColorCode(IRCInfoColor)$"*** "$OldNick@NowKnownAsText@NewNick$".");
    ChangeNick(OldNick, NewNick);

    if(!MyButton.bActive)
        MyButton.bForceFlash = true;
}

function UserQuit(string Nick, string Reason)
{
    TextDisplay.AddText( MakeColorCode(IRCInfoColor)$"*** "$Nick@QuitText@"("$Reason$").");
    RemoveUser(Nick);

    if(!MyButton.bActive)
        MyButton.bForceFlash = true;
}

function ChangeMode(string Nick, string Mode)
{
    TextDisplay.AddText( MakeColorCode(IRCInfoColor)$"*** "$Nick@SetsModeText$": "$Mode);

    if(!MyButton.bActive)
        MyButton.bForceFlash = true;
}

defaultproperties
{
     Begin Object Class=GUIListBox Name=MyUserListBox
         bVisibleWhenEmpty=True
         OnCreateComponent=MyUserListBox.InternalOnCreateComponent
         StyleName="ServerBrowserGrid"
         WinHeight=1.000000
         bScaleToParent=True
     End Object
     UserListBox=GUIListBox'XInterface.IRC_Channel.MyUserListBox'

}
