//====================================================================
//  IRC_Channel's handle all communication between the IRC_Link and
//  an IRC channel
//
//  Updated by Ron Prestenback
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class UT2K4IRC_Channel extends UT2K4IRC_Page;

var UT2K4IRC_System tp_System;
var string      ChannelName, ChannelTopic, DefaultListClass;

var localized string OpUserText, HelpUserText, VoiceUserText, ReasonText, MessageUserText, WhoisUserText,
                     DeopUserText, DehelpUserText, DevoiceUserText, KickUserText;

var bool    IsPrivate; // ChannelName will ~= Remote's Nick in this case

var GUIListBox  lb_User;

// =====================================================================================================================
//  Commands
// =====================================================================================================================

function ProcessInput(string Text)
{
    if(Left(Text, 4) ~= "/me ")
    {
        ChannelAction(tp_System.NickName, Mid(Text, 4));
        tp_System.Link.SendChannelAction(ChannelName, Mid(Text, 4));
    }
    else if(Left(Text, 1) == "/")
    {
        tp_System.Link.SendCommandText(Mid(Text, 1));
    }
    else
    {
        if(Text != "")
        {
            ChannelText(tp_System.NickName, Text);

            if ( Left(ChannelName,1) != "#" )
            	ChannelName = "#" $ ChannelName;

            tp_System.Link.SendChannelText(ChannelName, Text);
        }
    }
}

function Whois( string Nick )
{
	if ( tp_System == None )
		return;

	tp_System.Whois(Nick);
}

function Op( string Nick )
{
	if ( tp_System == None )
		return;

	tp_System.Op(Nick, ChannelName);
}

function Deop( string Nick )
{
	if ( tp_System == None )
		return;

	tp_System.Deop(Nick, ChannelName);
}

function Voice( string Nick )
{
	if ( tp_System == None )
		return;

	tp_System.Voice(Nick, ChannelName);
}

function DeVoice( string Nick )
{
	if ( tp_System == None )
		return;
	tp_System.DeVoice(Nick, ChannelName);
}

function Help( string Nick )
{
	if ( tp_System == None )
		return;
	tp_System.Help(Nick, ChannelName);
}

function DeHelp( string Nick )
{
	if ( tp_System == None )
		return;
	tp_System.DeHelp(Nick, ChannelName);
}

function Kick( string Nick, optional string Reason )
{
	if ( tp_System == None )
		return;

	tp_System.Kick(Nick, ChannelName, Reason);
}

function Ban( string Nick, optional string Reason )
{
	if ( tp_System == None )
		return;

	tp_System.Ban(Nick, ChannelName, Reason);
}

function Unban( string Nick )
{
	if ( tp_System == None )
		return;

	tp_System.Unban(Nick, ChannelName);
}


// =====================================================================================================================
//  Events
// =====================================================================================================================

function UserInChannel(string Nick)
{
    AddUser(Nick);
}

function AddUser( string Nick )
{
    local int i;

    i = GetUser(Nick);
    if( i > -1 )
        return; // already in user list

    lb_User.List.Add(Nick);
}

function RemoveUser( string Nick )
{
    local int i;

    i = GetUser(Nick);
    if( i < 0 )
        return; // not in list

    lb_User.List.RemoveItem(Nick);
}

function ChangeOp( string Nick, bool NewOp )
{
    local int i;

    i = GetUser(Nick);
    if( i < 0 )
        return;

    UserSetFlag(i, "o", NewOp);
    lb_User.List.Sort();
}

function ChangeHalfOp( string Nick, bool NewHalfOp )
{
    local int i;

    i = GetUser(Nick);
    if( i < 0 )
        return;

    UserSetFlag(i, "h", NewHalfOp);
    lb_User.List.Sort();
}

function ChangeVoice( string Nick, bool NewVoice )
{
    local int i;

    i = GetUser(Nick);
    if( i < 0 )
        return;
    UserSetFlag(i, "v", NewVoice);
    lb_User.List.Sort();
}

function ChangedNick(string OldNick, string NewNick)
{
	local string S;

	S = MakeColorCode(IRCInfoColor);
	S $= Repl( NowKnownAsText, "%OldName%", OldNick );
	S = Repl( S, "%NewName%", NewNick );

    lb_TextDisplay.AddText( S );
    ChangeNick(OldNick, NewNick);

    if(!MyButton.bActive)
        MyButton.bForceFlash = true;
}

function ChangeTopic( string NewTopic )
{
    ChannelTopic = NewTopic;

	InterpretColorCodes(NewTopic);
    lb_TextDisplay.AddText( MakeColorCode(IRCInfoColor)$"*** "$NewTopicText$": "$NewTopic);

    if(!MyButton.bActive)
        MyButton.bForceFlash = true;
}

function ChannelText(string Nick, string Text)
{
	if(MyButton.bActive && bIRCTextToSpeechEnabled)
		PlayerOwner().TextToSpeech( StripColorCodes(Text), 1 );

	InterpretColorCodes(Text);
    lb_TextDisplay.AddText( MakeColorCode(IRCNickColor)$"<"$Nick$"> "$MakeColorCode(IRCTextColor)$ColorizeLinks(Text) );

    if(!MyButton.bActive)
        MyButton.bForceFlash = true;
}

function ChannelAction(string Nick, string Text)
{
	InterpretColorCodes(Text);
    lb_TextDisplay.AddText( MakeColorCode(IRCActionColor)$"* "$Nick$" "$Text );

    if(!MyButton.bActive)
        MyButton.bForceFlash = true;
}

function UserNotice(string Nick, string Text)
{
	InterpretColorCodes(Text);
    lb_TextDisplay.AddText(MakeColorCode(IRCActionColor)$"-"$Nick$"- "$Text);

    if(!MyButton.bActive)
        MyButton.bForceFlash = true;
}

function JoinedChannel(string Nick)
{
	local string S;

	S = MakeColorCode(IRCInfoColor);
	S $= Repl( HasJoinedText, "%Name%", Nick );
	S = Repl( S, "%Chan%", ChannelName );

	InterpretColorCodes(Nick);
	lb_TextDisplay.AddText( S );
    AddUser(Nick);

    if(!MyButton.bActive)
        MyButton.bForceFlash = true;
}

function PartedChannel(string Nick)
{
	local string S;

	S = MakeColorCode(IRCInfoColor);
	S $= Repl( HasLeftText, "%Name%", Nick );
	S = Repl( S, "%Chan%", ChannelName );

	InterpretColorCodes(Nick);
    lb_TextDisplay.AddText(S);
    RemoveUser(Nick);

    if(!MyButton.bActive)
        MyButton.bForceFlash = true;
}

function KickUser(string KickedNick, string Kicker, string Reason)
{
	local string S;

	S = MakeColorCode(IRCInfoColor);
	S $= Repl( WasKickedByText, "%Kicked%", KickedNick );
	S = Repl( S, "%Kicker%", Kicker );
	S = Repl( S, "%Reason%", Reason );

	InterpretColorCodes(Reason);
    lb_TextDisplay.AddText( S );
    RemoveUser(KickedNick);

    if(!MyButton.bActive)
        MyButton.bForceFlash = true;
}

function UserQuit(string Nick, string Reason)
{
	local string S;

	S = MakeColorCode(IRCInfoColor);
	S $= Repl( QuitText, "%Name%", Nick );
	S = Repl( S, "%Reason%", Reason );

	InterpretColorCodes(Reason);
    lb_TextDisplay.AddText( S );
    RemoveUser(Nick);

    if(!MyButton.bActive)
        MyButton.bForceFlash = true;
}

function ChangeMode(string Nick, string Mode)
{
  	local string S;

	S = MakeColorCode(IRCInfoColor);
	S $= Repl( SetsModeText, "%Name%", Nick );
	S = Repl( S, "%Mode%", Mode );

    lb_TextDisplay.AddText( S );

    if(!MyButton.bActive)
        MyButton.bForceFlash = true;
}

// =====================================================================================================================
//  Query / Utility / Internal
// =====================================================================================================================

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    if (lb_User != None)
    {
        // Set delegates for user list box
        lb_User.List.bSorted = True;
        lb_User.List.OnDrawItem=MyOnDrawItem;
        lb_User.List.CompareItem=MyCompareItem;
        lb_User.List.OnDblClick=MyListDblClick;
    }
}

function ShowPanel(bool bShow)
{
    Super.ShowPanel(bShow);

    if (bShow && bInit)
    {
        sp_Main.SplitterUpdatePositions();
        bInit=False;
    }
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
    if (GUIListBox(NewComp) != None)
    {
        lb_User = GUIListBox(NewComp);
        lb_User.FillOwner();
    }

    else Super.InternalOnCreateComponent(NewComp, Sender);
}

function InternalOnLoadIni(GUIComponent Sender, string S)
{
    if (Sender == sp_Main)
        sp_Main.SplitPosition = MainSplitterPosition;
}

function InternalOnReleaseSplitter(GUIComponent Sender, float NewPos)
{
    if (Sender == sp_Main)
    {
        MainSplitterPosition = NewPos;
        SaveConfig();
    }
}

function bool MyListDblClick(GUIComponent Sender)
{
    local string UserName;
    UserName = lb_User.List.Get();

    if(UserName == "")
        return true;

	 // Make new channel active in this case
	tp_System.AddChannel(UserName, True, True);
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
    local GUIStyles S;

	if ( lb_User.List.Style == None )
		return;

    NickName = lb_User.List.GetItemAtIndex(i);
    Flags = lb_User.List.GetExtraAtIndex(i);

    if( InStr(Flags,"o") != -1)
        DrawName = "@"$NickName;
    else if( InStr(Flags,"h") != -1)
        DrawName = "%"$NickName;
    else if( InStr(Flags,"v") != -1)
        DrawName = "+"$NickName;
    else
        DrawName = NickName;

	if ( bSelected && lb_User.List.SelectedStyle != None )
	{
		S = lb_User.List.SelectedStyle;
		S.Draw( Canvas, lb_User.List.MenuState, X, Y, W, H );
	}
	else S = lb_User.List.Style;

    S.DrawText( Canvas, MSAT_Blurry, X, Y, W, H, TXTA_Left, DrawName, lb_User.FontScale );
}

function int GetUser( string Nick )
{
	return lb_User.List.FindIndex(Nick);
}

function string GetFlags( string NickName )
{
	local int i;

	i = GetUser(NickName);
	if ( i != -1 )
		return lb_User.List.GetExtraAtIndex(i);

	return "";
}

function bool FindNick( string Nick )
{
    if( GetUser(Nick) > -1 )
        return true;
    return false;
}

function bool UserIsOp( string NickName )
{
	return InStr(GetFlags(NickName), "o") != -1;
}

function bool UserIsHelper( string NickName )
{
	return InStr(GetFlags(NickName), "h") != -1;
}

function bool UserIsVoice( string NickName )
{
	return InStr(GetFlags(NickName), "v") != -1;
}

function ChangeNick( string OldNick, string NewNick)
{
    local int i;

    i = GetUser(OldNick);
    if( i < 0 )
        return;

    lb_User.List.SetItemAtIndex(i, NewNick);
    lb_User.List.Sort();
}

function UserSetFlag(int i, string flag, bool bSet)
{
    local string flags, s;
    local int flagPos;

    flags = lb_User.List.GetExtraAtIndex(i);

	for ( s = Left(flag,1); s != ""; s = Mid(s,1) )
	{
	    if(bSet) // TURN FLAG ON
	    {
	        // If user already has flag set, do nothing.
	        if( InStr(flags, s) != -1 )
	            return;

	        // Add to end of existing flags.
	        lb_User.List.SetExtraAtIndex(i, flags$s);
	    }
	    else // TURN FLAG OFF
	    {
	        flagPos = InStr(flags, s);

	        // If flag not in flag list, do nothing;
	        if(flagPos == -1)
	            return;

	        // Remove flags from string
	        flags = Repl(flags, s, "");

	        lb_User.List.SetExtraAtIndex(i, flags);
	    }
	}
}

// =====================================================================================================================
//  Context Menu
// =====================================================================================================================

function bool ContextMenuOpen(GUIContextMenu Sender)
{
	local string SelectedNick;

	if ( Sender.ContextItems.Length > 0 )
		Sender.ContextItems.Remove(0, Sender.ContextItems.Length);

	// TODO Add code to modify items in list based on context of user's position in channel
	if ( Controller == None || Controller.ActiveControl != lb_User.List )
		return false;

	SelectedNick = lb_User.List.Get();
	if ( tp_System.IsMe(SelectedNick) )
		return false;

	AddUserContextOptions( Sender, SelectedNick );
	AddControlContextOptions( Sender, SelectedNick );

	return true;
}

function AddUserContextOptions( GUIContextMenu Menu, string Nick )
{
	Menu.AddItem( MessageUserText );
	Menu.AddItem( WhoisUserText );
}

function AddControlContextOptions( GUIContextMenu Menu, string Nick )
{
	if ( Menu == None || tp_System == None || !UserIsOp(tp_System.NickName) )
		return;

	Menu.AddItem("-");

	if ( UserIsOp(Nick) )
		Menu.AddItem(DeopUserText);
	else Menu.AddItem(OpUserText);

	if ( UserIsHelper(Nick) )
		Menu.AddItem(DehelpUserText);
	else Menu.AddItem(HelpUserText);

	if ( UserIsVoice(Nick) )
		Menu.AddItem(DevoiceUserText);
	else Menu.AddItem(VoiceUserText);

	Menu.AddItem( "-" );
	Menu.AddItem( KickUserText );
	Menu.AddItem( KickUserText $ "..." );
}

function ContextMenuClick(GUIContextMenu Sender, int ClickIndex)
{
	local int AbsIndex;
	local string Nick;

	Nick = lb_User.List.Get();

	AbsIndex = GetAbsoluteIndex(Sender, ClickIndex);
	switch ( AbsIndex )
	{
	case 0: // Msg
		tp_System.AddChannel(Nick, True, True);
		break;

	case 1:	// Whois
		Whois(Nick);
		break;

	case 2: // Op
		Op(Nick);
		break;

	case 3: // Deop
		Deop(Nick);
		break;

	case 4: // Help
		Help(Nick);
		break;

	case 5: // Dehelp
		Dehelp(Nick);
		break;

	case 6: // Voice
		Voice(Nick);
		break;

	case 7: // Devoice
		Devoice(Nick);
		break;

	case 8: // Kick
		Kick(Nick);
		break;

	case 9:	// Kick with reason
		if ( Controller.OpenMenu(Controller.RequestDataMenu, "", ReasonText) )
			Controller.ActivePage.OnClose = KickReasonClose;
		break;
	}
}

function int GetAbsoluteIndex( GUIContextMenu Menu, int Index )
{
	if ( Menu == None || Index < 0 || Index >= Menu.ContextItems.Length )
		return -1;

	if ( Index == 0 || Index == 1 )
		return Index;

	if ( Menu.ContextItems[Index] == "-" )
		Index++;

	switch ( Menu.ContextItems[Index] )
	{
		case MessageUserText: return 0;
		case WhoisUserText:   return 1;
		case OpUserText:      return 2;
		case DeopUserText:    return 3;
		case HelpUserText:    return 4;
		case DehelpUserText:  return 5;
		case VoiceUserText:   return 6;
		case DevoiceUserText: return 7;
		case KickUserText:    return 8;
		case KickUserText $ "...": return 9;

		default:              return 1;
	}
}

function KickReasonClose( bool bCancelled )
{
	if ( !bCancelled )
		Kick(lb_User.List.Get(), Controller.ActivePage.GetDataString());
}

defaultproperties
{
     OpUserText="Make Op"
     HelpUserText="Make Helper"
     VoiceUserText="Make Voice"
     ReasonText="Reason: "
     MessageUserText="Open Query"
     WhoisUserText="Whois"
     DeopUserText="Remove Op"
     DehelpUserText="Remove Helper"
     DevoiceUserText="Remove Voice"
     KickUserText="Kick User"
     Begin Object Class=GUISplitter Name=SplitterA
         SplitOrientation=SPLIT_Horizontal
         SplitPosition=0.750000
         DefaultPanels(0)="XInterface.GUIScrollTextBox"
         DefaultPanels(1)="XInterface.GUIListBox"
         OnReleaseSplitter=UT2k4IRC_Channel.InternalOnReleaseSplitter
         OnCreateComponent=UT2k4IRC_Channel.InternalOnCreateComponent
         IniOption="@Internal"
         WinHeight=0.950000
         OnLoadINI=UT2k4IRC_Channel.InternalOnLoadINI
     End Object
     sp_Main=GUISplitter'GUI2K4.UT2k4IRC_Channel.SplitterA'

     MainSplitterPosition=0.750000
     Begin Object Class=GUIContextMenu Name=RCMenu
         OnOpen=UT2k4IRC_Channel.ContextMenuOpen
         OnSelect=UT2k4IRC_Channel.ContextMenuClick
     End Object
     ContextMenu=GUIContextMenu'GUI2K4.UT2k4IRC_Channel.RCMenu'

}
