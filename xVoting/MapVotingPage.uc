//====================================================================
//  xVoting.MapVotingPage
//  Map Voting page.
//
//  Written by Bruce Bickar
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class MapVotingPage extends VotingPage;

var automated MapVoteMultiColumnListBox      lb_MapListBox;
var automated MapVoteCountMultiColumnListBox lb_VoteCountListBox;
var automated moComboBox                     co_GameType;
var automated GUILabel                       l_Mode;
var automated GUIImage                       i_MapListBackground, i_MapCountListBackground;

// Localization
var localized string lmsgMapVotingDisabled, lmsgReplicationNotFinished, lmsgMapDisabled,
                     lmsgTotalMaps, lmsgMode[8];



//------------------------------------------------------------------------------------------------
function InternalOnOpen()
{
	local int i, d;

    if( MVRI == none || (MVRI != none && !MVRI.bMapVote) )
    {
		Controller.OpenMenu("GUI2K4.GUI2K4QuestionPage");
		GUIQuestionPage(Controller.TopPage()).SetupQuestion(lmsgMapVotingDisabled, QBTN_Ok, QBTN_Ok);
		GUIQuestionPage(Controller.TopPage()).OnButtonClick = OnOkButtonClick;
		return;
    }

	// check if all maps and gametypes have replicated
    if( MVRI.GameConfig.Length < MVRI.GameConfigCount || MVRI.MapList.Length < MVRI.MapCount )
    {
		Controller.OpenMenu("GUI2K4.GUI2K4QuestionPage");
		GUIQuestionPage(Controller.TopPage()).SetupQuestion(lmsgReplicationNotFinished, QBTN_Ok, QBTN_Ok);
		GUIQuestionPage(Controller.TopPage()).OnButtonClick = OnOkButtonClick;
		return;
    }

    for( i=0; i<MVRI.GameConfig.Length; i++ )
    	co_GameType.AddItem( MVRI.GameConfig[i].GameName, none, string(i));
    co_GameType.MyComboBox.List.SortList();

	t_WindowTitle.Caption = t_WindowTitle.Caption@"("$lmsgMode[MVRI.Mode]$")";

   	lb_MapListBox.LoadList(MVRI);
   	MapVoteCountMultiColumnList(lb_VoteCountListBox.List).LoadList(MVRI);

    lb_VoteCountListBox.List.OnDblClick = MapListDblClick;
    lb_VoteCountListBox.List.bDropTarget = True;

    lb_MapListBox.List.OnDblClick = MapListDblClick;
    lb_MaplistBox.List.bDropSource = True;
    co_GameType.OnChange = GameTypeChanged;
    f_Chat.OnSubmit = Submit;

    // set starting gametype to current
    d = co_GameType.MyComboBox.List.FindExtra(string(MVRI.CurrentGameConfig));
    if( d > -1 )
	   	co_GameType.SetIndex(d);
}
//------------------------------------------------------------------------------------------------
function Submit()
{
    SendVote(none);
}
//------------------------------------------------------------------------------------------------
function GameTypeChanged(GUIComponent Sender)
{
	local int GameTypeIndex;

	GameTypeIndex = int(co_GameType.GetExtra());
	if( GameTypeIndex > -1 )
	{
		lb_MapListBox.ChangeGameType( GameTypeIndex );
	    lb_MapListBox.List.OnDblClick = MapListDblClick;
	}
}
//------------------------------------------------------------------------------------------------
function OnOkButtonClick(byte bButton) // triggered by th GUIQuestionPage Ok Button
{
	Controller.CloseMenu(true);
}
//------------------------------------------------------------------------------------------------
function UpdateMapVoteCount(int UpdatedIndex, bool bRemoved)
{
	MapVoteCountMultiColumnList(lb_VoteCountListBox.List).UpdatedVoteCount(UpdatedIndex, bRemoved);
}
//------------------------------------------------------------------------------------------------
function bool MapListDblClick(GUIComponent Sender)
{
    SendVote(Sender);
    return true;
}
//------------------------------------------------------------------------------------------------
function SendVote(GUIComponent Sender)
{
    local int MapIndex,GameConfigIndex;

	if( Sender == lb_VoteCountListBox.List )
	{
		MapIndex = MapVoteCountMultiColumnList(lb_VoteCountListBox.List).GetSelectedMapIndex();
		if( MapIndex > -1)
	    {
		    GameConfigIndex = MapVoteCountMultiColumnList(lb_VoteCountListBox.List).GetSelectedGameConfigIndex();
		    if(MVRI.MapList[MapIndex].bEnabled || PlayerOwner().PlayerReplicationInfo.bAdmin)
		        MVRI.SendMapVote(MapIndex,GameConfigIndex);
		    else
				PlayerOwner().ClientMessage(lmsgMapDisabled);
		}
	}
	else
	{
    	MapIndex = MapVoteMultiColumnList(lb_MapListBox.List).GetSelectedMapIndex();
		if( MapIndex > -1)
	    {
		    GameConfigIndex = int(co_GameType.GetExtra());
		    if(MVRI.MapList[MapIndex].bEnabled || PlayerOwner().PlayerReplicationInfo.bAdmin)
		        MVRI.SendMapVote(MapIndex,GameConfigIndex);
		    else
				PlayerOwner().ClientMessage(lmsgMapDisabled);
		}
    }
}

function bool AlignBK(Canvas C)
{

	i_MapCountListBackground.WinWidth  = lb_VoteCountListbox.MyList.ActualWidth();
	i_MapCountListBackground.WinHeight = lb_VoteCountListbox.MyList.ActualHeight();
	i_MapCountListBackground.WinLeft   = lb_VoteCountListbox.MyList.ActualLeft();
	i_MapCountListBackground.WinTop    = lb_VoteCountListbox.MyList.ActualTop();

	i_MapListBackground.WinWidth  	= lb_MapListBox.MyList.ActualWidth();
	i_MapListBackground.WinHeight 	= lb_MapListBox.MyList.ActualHeight();
	i_MapListBackground.WinLeft  	= lb_MapListBox.MyList.ActualLeft();
	i_MapListBackground.WinTop	 	= lb_MapListBox.MyList.ActualTop();

	return false;
}
//------------------------------------------------------------------------------------------------

defaultproperties
{
     Begin Object Class=MapVoteMultiColumnListBox Name=MapListBox
         HeaderColumnPerc(0)=0.600000
         HeaderColumnPerc(1)=0.200000
         HeaderColumnPerc(2)=0.200000
         bVisibleWhenEmpty=True
         OnCreateComponent=MapListBox.InternalOnCreateComponent
         StyleName="ServerBrowserGrid"
         WinTop=0.371020
         WinLeft=0.020000
         WinWidth=0.960000
         WinHeight=0.293104
         bBoundToParent=True
         bScaleToParent=True
         OnRightClick=MapListBox.InternalOnRightClick
     End Object
     lb_MapListBox=MapVoteMultiColumnListBox'xVoting.MapVotingPage.MapListBox'

     Begin Object Class=MapVoteCountMultiColumnListBox Name=VoteCountListBox
         HeaderColumnPerc(0)=0.400000
         HeaderColumnPerc(1)=0.400000
         HeaderColumnPerc(2)=0.200000
         bVisibleWhenEmpty=True
         OnCreateComponent=VoteCountListBox.InternalOnCreateComponent
         WinTop=0.052930
         WinLeft=0.020000
         WinWidth=0.960000
         WinHeight=0.223770
         bBoundToParent=True
         bScaleToParent=True
         OnRightClick=VoteCountListBox.InternalOnRightClick
     End Object
     lb_VoteCountListBox=MapVoteCountMultiColumnListBox'xVoting.MapVotingPage.VoteCountListBox'

     Begin Object Class=moComboBox Name=GameTypeCombo
         CaptionWidth=0.350000
         Caption="Filter Game Type:"
         OnCreateComponent=GameTypeCombo.InternalOnCreateComponent
         WinTop=0.334309
         WinLeft=0.199219
         WinWidth=0.757809
         WinHeight=0.037500
         bScaleToParent=True
     End Object
     co_GameType=moComboBox'xVoting.MapVotingPage.GameTypeCombo'

     Begin Object Class=GUIImage Name=MapListBackground
         Image=Texture'2K4Menus.NewControls.NewFooter'
         ImageStyle=ISTY_Stretched
         WinTop=0.371020
         WinLeft=0.010000
         WinWidth=0.980000
         WinHeight=0.316542
     End Object
     i_MapListBackground=GUIImage'xVoting.MapVotingPage.MapListBackground'

     Begin Object Class=GUIImage Name=MapCountListBackground
         Image=Texture'2K4Menus.NewControls.NewFooter'
         ImageStyle=ISTY_Stretched
         WinTop=0.052930
         WinLeft=0.010000
         WinWidth=0.980000
         WinHeight=0.223770
         OnDraw=MapVotingPage.AlignBK
     End Object
     i_MapCountListBackground=GUIImage'xVoting.MapVotingPage.MapCountListBackground'

     lmsgMapVotingDisabled="Sorry, Map Voting has been disabled by the server administrator."
     lmsgReplicationNotFinished="Map data download in progress. Please try again later."
     lmsgMapDisabled="The selected Map is disabled."
     lmsgTotalMaps="%mapcount% Total Maps"
     lmsgMode(0)="Majority Mode"
     lmsgMode(1)="Majority & Elimination Mode"
     lmsgMode(2)="Score Mode"
     lmsgMode(3)="Score & Elimination Mode"
     lmsgMode(4)="Majority & Accumulation Mode"
     lmsgMode(5)="Majority & Accumulation & Elimination Mode"
     lmsgMode(6)="Score & Accumulation Mode"
     lmsgMode(7)="Score & Accumulation & Elimination Mode"
     WindowName="Map Voting"
     OnOpen=MapVotingPage.InternalOnOpen
}
