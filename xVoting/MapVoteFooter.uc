//==============================================================================
//  Created on: 01/02/2004
//  Contains controls for participating in chat while mapvote menus are open
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class MapVoteFooter extends GUIFooter;

var() noexport array<string> RecallQueue;
var() noexport int RecallIdx;
var() noexport int idxLastChatMsg;
var() noexport float LastMsgTime;

var automated GUISectionBackground sb_Background;
var automated GUIScrollTextBox lb_Chat;
var automated moEditBox        ed_Chat;
var automated GUIButton        b_Accept, b_Submit, b_Close;

delegate OnSubmit();
delegate OnAccept();
delegate bool OnSendChat( string Text )
{
	if ( Text != "" )
	{
		if ( RecallQueue.Length == 0 || RecallQueue[RecallQueue.Length - 1] != Text )
		{
			RecallIdx = RecallQueue.Length;
			RecallQueue[RecallIdx] = Text;
		}

		if ( Left(Text,4) ~= "cmd " )
			PlayerOwner().ConsoleCommand( Mid(Text, 4) );
		else
		{
			if ( Left(Text,1) == "." )
				PlayerOwner().TeamSay( Mid(Text,1) );
			else PlayerOwner().Say( Text );
		}
	}

	return true;
}

function InitComponent(GUIController InController, GUIComponent InOwner)
{
	local string str;
	local ExtendedConsole C;

	Super.InitComponent(InController, InOwner);

	lb_Chat.MyScrollText.SetContent("");
	lb_Chat.MyScrollText.FontScale=FNS_Small;

	C = ExtendedConsole(Controller.ViewportOwner.Console);
	if ( C != None )
	{
		C.OnChatMessage = ReceiveChat;
		if ( C.bTyping )
		{
			str = C.TypedStr;
			C.TypingClose();

			if ( Left(str,4) ~= "say " )
				str = Mid(str, 4);

			else if ( Left(str,8) ~= "teamsay " )
				str = Mid(str, 8);

			ed_Chat.SetText(str);
		}
	}

	sb_Background.Managecomponent(lb_Chat);


	OnDraw=MyOnDraw;

}

function bool MyOnDraw(canvas C)
{
	local float l,t,w,xl,yl;
	local eFontScale fs;
	// Reposition everything

	t = sb_Background.ActualTop() + sb_Background.ActualHeight();
	l = sb_Background.ActualLeft() + sb_Background.ActualWidth() - sb_Background.ImageOffset[3];

	b_Close.Style.TextSize(C,MSAT_Blurry,b_Close.Caption, XL,YL,FS);
	w = XL;
	b_Submit.Style.TextSize(C,MSAT_Blurry,b_Close.Caption, XL,YL,FS);
	if (XL>w)
		w = XL;
	b_Accept.Style.TextSize(C,MSAT_Blurry,b_Close.Caption, XL,YL,FS);
	if (XL>w)
		w = XL;

	w = w*3;
	w = ActualWidth(w);

	l -= w;
	b_Close.WinWidth = w;
	b_Close.WinTop = t;
	b_Close.WinLeft = l;

	l -= w;
	b_Submit.WinWidth = w;
	b_Submit.WinTop = t;
	b_Submit.WinLeft = l;

	l -= w;
	b_Accept.WinWidth = w;
	b_Accept.WinTop = t;
	b_Accept.WinLeft = l;


	ed_Chat.WinLeft   = sb_Background.ActualLeft() + sb_Background.ImageOffset[0];
	ed_Chat.WinWidth  = L - ed_Chat.WinLeft;
	ed_Chat.WinHeight = 25;
	ed_Chat.WinTop    = t;

 	return false;
}

function ReceiveChat(string Msg)
{
	lb_Chat.AddText(Msg);
	lb_Chat.MyScrollText.End();

	// remove top messages from list if there are more than 10
	if( lb_Chat.MyScrollText.ItemCount > 10 )
		lb_Chat.MyScrollText.Remove(0,lb_Chat.MyScrollText.ItemCount - 10);
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	if ( State == 3 && Key == 0x0D ) // enter
	{
		if ( OnSendChat(ed_Chat.GetText()) )
			ed_Chat.SetComponentValue("", True);

		return true;
	}

	else if ( State == 1 && RecallQueue.Length > 0 )
	{
		if ( Key == 0x26 ) // up
		{
			ed_Chat.SetText(RecallQueue[RecallIdx]);
			RecallIdx = Max(0, RecallIdx - 1);
			return true;
		}
		else if ( Key == 0x28 ) // down
		{
			ed_Chat.SetText(RecallQueue[RecallIdx]);
			RecallIdx = Min(RecallQueue.Length - 1, RecallIdx + 1);
			return true;
		}
	}

	return false;
}

function bool InternalOnClick(GUIComponent Sender)
{
	if (Sender == b_Close )
	{
		Controller.CloseMenu(true);
		return true;
	}

	if ( Sender == b_Submit )
	{
		OnSubmit();
		return true;
	}

	if ( Sender == b_Accept )
	{
		OnAccept();
		return true;
	}
}

defaultproperties
{
     Begin Object Class=AltSectionBackground Name=MapvoteFooterBackground
         bFillClient=True
         Caption="Chat"
         LeftPadding=0.010000
         RightPadding=0.010000
         WinHeight=0.820000
         bBoundToParent=True
         bScaleToParent=True
         OnPreDraw=MapvoteFooterBackground.InternalPreDraw
     End Object
     sb_Background=AltSectionBackground'xVoting.MapVoteFooter.MapvoteFooterBackground'

     Begin Object Class=GUIScrollTextBox Name=ChatScrollBox
         bNoTeletype=True
         CharDelay=0.002500
         EOLDelay=0.000000
         bVisibleWhenEmpty=True
         OnCreateComponent=ChatScrollBox.InternalOnCreateComponent
         StyleName="ServerBrowserGrid"
         WinTop=0.223580
         WinLeft=0.043845
         WinWidth=0.918970
         WinHeight=0.582534
         TabOrder=2
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     lb_Chat=GUIScrollTextBox'xVoting.MapVoteFooter.ChatScrollBox'

     Begin Object Class=moEditBox Name=ChatEditbox
         CaptionWidth=0.150000
         Caption="Say"
         OnCreateComponent=ChatEditbox.InternalOnCreateComponent
         WinTop=0.868598
         WinLeft=0.007235
         WinWidth=0.700243
         WinHeight=0.106609
         TabOrder=0
         OnKeyEvent=MapVoteFooter.InternalOnKeyEvent
     End Object
     ed_Chat=moEditBox'xVoting.MapVoteFooter.ChatEditbox'

     Begin Object Class=GUIButton Name=AcceptButton
         Caption="Accept"
         Hint="Click once you are satisfied with all settings and wish to offer no further modifications"
         WinTop=0.906173
         WinLeft=0.562577
         WinWidth=0.191554
         WinHeight=0.071145
         TabOrder=1
         bVisible=False
         bStandardized=True
         OnClick=MapVoteFooter.InternalOnClick
         OnKeyEvent=AcceptButton.InternalOnKeyEvent
     End Object
     b_Accept=GUIButton'xVoting.MapVoteFooter.AcceptButton'

     Begin Object Class=GUIButton Name=SubmitButton
         Caption="Submit"
         WinTop=0.849625
         WinLeft=0.704931
         WinWidth=0.160075
         WinHeight=0.165403
         TabOrder=1
         bStandardized=True
         OnClick=MapVoteFooter.InternalOnClick
         OnKeyEvent=SubmitButton.InternalOnKeyEvent
     End Object
     b_Submit=GUIButton'xVoting.MapVoteFooter.SubmitButton'

     Begin Object Class=GUIButton Name=CloseButton
         Caption="Close"
         WinTop=0.849625
         WinLeft=0.861895
         WinWidth=0.137744
         WinHeight=0.165403
         TabOrder=1
         bStandardized=True
         OnClick=MapVoteFooter.InternalOnClick
         OnKeyEvent=CloseButton.InternalOnKeyEvent
     End Object
     b_Close=GUIButton'xVoting.MapVoteFooter.CloseButton'

     StyleName="BindBox"
     bNeverFocus=False
}
