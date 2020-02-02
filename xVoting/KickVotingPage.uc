//====================================================================
//  xVoting.KickVotingPage
//  Kick Voting page.
//
//  Written by Bruce Bickar
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class KickVotingPage extends VotingPage;

var automated GUISectionBackground sb_List;
var automated KickVoteMultiColumnListBox lb_PlayerListBox;
var automated GUILabel         l_PlayerListTitle;
var automated GUIButton         b_Info, b_Kick;

// Localization
var localized string lmsgKickVotingDisabled;


function InitComponent(GUIController InController, GUIComponent InOwner)
{
	Super.InitComponent(InController, InOwner);
	sb_List.ManageComponent(lb_PlayerListBox);
	sb_List.ImageOffset[1]=8;
}

//------------------------------------------------------------------------------------------------
function InternalOnOpen()
{
    if( MVRI == none || (MVRI != none && !MVRI.bKickVote) )
    {
		Controller.OpenMenu("GUI2K4.GUI2K4QuestionPage");
		GUIQuestionPage(Controller.TopPage()).SetupQuestion(lmsgKickVotingDisabled, QBTN_Ok, QBTN_Ok);
		GUIQuestionPage(Controller.TopPage()).OnButtonClick = OnOkButtonClick;
		return;
    }
    lb_PlayerListBox.List.OnDblClick = PlayerListDblClick;
    KickVoteMultiColumnList(lb_PlayerListBox.List).LoadPlayerList(MVRI);
    f_Chat.OnSubmit = SendKickVote;

	f_Chat.WinTop = 0.561457;
	f_Chat.WinHeight=0.432031;
}
//------------------------------------------------------------------------------------------------
function OnOkButtonClick(byte bButton) // triggered by th GUIQuestionPage Ok Button
{
	Controller.CloseAll(true,true);
}
//------------------------------------------------------------------------------------------------
function UpdateKickVoteCount(VotingHandler.KickVoteScore KVCData)
{
	KickVoteMultiColumnList(lb_PlayerListBox.List).UpdatedVoteCount(KVCData.PlayerID, KVCData.KickVoteCount);
}
//------------------------------------------------------------------------------------------------
function bool PlayerListDblClick(GUIComponent Sender)
{
	SendKickVote();
    return true;
}
//------------------------------------------------------------------------------------------------
function SendKickVote()
{
    local int PlayerID;

    PlayerID = KickVoteMultiColumnList(lb_PlayerListBox.List).GetSelectedPlayerID();
    if( PlayerID > -1 )
        MVRI.SendKickVote(PlayerID);
}
//------------------------------------------------------------------------------------------------

function bool InfoClick(GUIComponent Sender)
{
	lb_PlayerListBox.InternalOnClick(lb_PlayerListBox.ContextMenu,1);
	return true;
}


function bool KickClick(GUIComponent Sender)
{
	lb_PlayerListBox.InternalOnClick(lb_PlayerListBox.ContextMenu,0);
	return true;
}

defaultproperties
{
     Begin Object Class=AltSectionBackground Name=listbackground
         bFillClient=True
         WinTop=0.052083
         WinLeft=0.023438
         WinWidth=0.953125
         WinHeight=0.461357
         bBoundToParent=True
         bScaleToParent=True
         OnPreDraw=listbackground.InternalPreDraw
     End Object
     sb_List=AltSectionBackground'xVoting.KickVotingPage.listbackground'

     Begin Object Class=KickVoteMultiColumnListBox Name=PlayerListBoxControl
         bVisibleWhenEmpty=True
         OnCreateComponent=PlayerListBoxControl.InternalOnCreateComponent
         StyleName="ServerBrowserGrid"
         WinTop=0.162239
         WinLeft=0.254141
         WinWidth=0.473047
         WinHeight=0.481758
         OnRightClick=PlayerListBoxControl.InternalOnRightClick
     End Object
     lb_PlayerListBox=KickVoteMultiColumnListBox'xVoting.KickVotingPage.PlayerListBoxControl'

     Begin Object Class=GUIButton Name=InfoButton
         Caption="Info"
         WinTop=0.511082
         WinLeft=0.550634
         WinWidth=0.160075
         TabOrder=1
         bStandardized=True
         OnClick=KickVotingPage.InfoClick
         OnKeyEvent=InfoButton.InternalOnKeyEvent
     End Object
     b_Info=GUIButton'xVoting.KickVotingPage.InfoButton'

     Begin Object Class=GUIButton Name=KickButton
         Caption="Kick"
         WinTop=0.511082
         WinLeft=0.715411
         WinWidth=0.137744
         TabOrder=1
         bStandardized=True
         OnClick=KickVotingPage.KickClick
         OnKeyEvent=KickButton.InternalOnKeyEvent
     End Object
     b_Kick=GUIButton'xVoting.KickVotingPage.KickButton'

     lmsgKickVotingDisabled="Sorry, Kick Voting has been disabled by the server administrator."
     WindowName="Kick Voting"
     OnOpen=KickVotingPage.InternalOnOpen
}
