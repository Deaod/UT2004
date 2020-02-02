// ====================================================================
//  Class:  XInterface.ServerListPage
//  Parent: XInterface.GUITabPanel
//
//  <Enter a description here>
// ====================================================================

class Browser_ServerListPageBase extends Browser_Page;

// Internal
var Browser_ServersList  MyServersList;
var bool ConnectLAN;
var GUITitleBar StatusBar;
var bool bInitialized;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	if( !bInitialized )
	{
		MyServersList = Browser_ServersList(GUIMultiColumnListBox(GUIPanel(GUISplitter(Controls[0]).Controls[0]).Controls[0]).Controls[0]);
		MyServersList.MyPage		= Self;
		MyServersList.MyRulesList   = Browser_RulesList  (GUIMultiColumnListBox(GUIPanel(GUISplitter(GUISplitter(Controls[0]).Controls[1]).Controls[0]).Controls[0]).Controls[0]);
		MyServersList.MyPlayersList = Browser_PlayersList(GUIMultiColumnListBox(GUIPanel(GUISplitter(GUISplitter(Controls[0]).Controls[1]).Controls[1]).Controls[0]).Controls[0]);
		MyServersList.MyRulesList.MyPage = Self;
		MyServersList.MyRulesList.MyServersList = MyServersList;
		MyServersList.MyPlayersList.MyPage = Self;
		MyServersList.MyPlayersList.MyServersList = MyServersList;

		StatusBar = GUITitleBar(GUIPanel(Controls[1]).Controls[5]);
	}
	StatusBar.SetCaption(ReadyString);

	Super.Initcomponent(MyController, MyOwner);

	if( !bInitialized )
	{
		GUIButton(GUIPanel(Controls[1]).Controls[0]).OnClick=BackClick;
		GUIButton(GUIPanel(Controls[1]).Controls[1]).OnClick=RefreshClick;
		GUIButton(GUIPanel(Controls[1]).Controls[2]).OnClick=JoinClick;
		GUIButton(GUIPanel(Controls[1]).Controls[3]).OnClick=SpectateClick;
		GUIButton(GUIPanel(Controls[1]).Controls[4]).OnClick=AddFavoriteClick;
	}

	bInitialized = True;
}
// functions

function RefreshList()
{
}

function PingServer( int i, ServerQueryClient.EPingCause PingCause, GameInfo.ServerResponseLine s )
{
}

function CancelPings()
{
}

// delegates
function bool BackClick(GUIComponent Sender)
{
	Controller.CloseMenu(true);
	return true;
}

function bool RefreshClick(GUIComponent Sender)
{
	RefreshList();
	return true;
}

function bool JoinClick(GUIComponent Sender)
{
	MyServersList.Connect(false);
	return true;
}

function bool SpectateClick(GUIComponent Sender)
{
	MyServersList.Connect(true);
	return true;
}

function bool AddFavoriteClick(GUIComponent Sender)
{
	MyServersList.AddFavorite(Browser);
	return true;
}

defaultproperties
{
     Begin Object Class=GUISplitter Name=MainSplitter
         Begin Object Class=GUIPanel Name=ServersPanel
             Begin Object Class=GUIMultiColumnListBox Name=ServersListBox
                 bVisibleWhenEmpty=True
                 Begin Object Class=Browser_ServersList Name=TheServersList
                     OnPreDraw=TheServersList.InternalOnPreDraw
                     OnClick=TheServersList.InternalOnClick
                     OnRightClick=TheServersList.InternalOnRightClick
                     OnMousePressed=TheServersList.InternalOnMousePressed
                     OnMouseRelease=TheServersList.InternalOnMouseRelease
                     OnKeyEvent=TheServersList.InternalOnKeyEvent
                     OnBeginDrag=TheServersList.InternalOnBeginDrag
                     OnEndDrag=TheServersList.InternalOnEndDrag
                     OnDragDrop=TheServersList.InternalOnDragDrop
                     OnDragEnter=TheServersList.InternalOnDragEnter
                     OnDragLeave=TheServersList.InternalOnDragLeave
                     OnDragOver=TheServersList.InternalOnDragOver
                 End Object
                 Controls(0)=Browser_ServersList'XInterface.Browser_ServerListPageBase.TheServersList'

                 OnCreateComponent=ServersListBox.InternalOnCreateComponent
                 StyleName="ServerBrowserGrid"
                 WinHeight=1.000000
             End Object
             Controls(0)=GUIMultiColumnListBox'XInterface.Browser_ServerListPageBase.ServersListBox'

         End Object
         Controls(0)=GUIPanel'XInterface.Browser_ServerListPageBase.ServersPanel'

         Begin Object Class=GUISplitter Name=DetailsSplitter
             SplitOrientation=SPLIT_Horizontal
             Background=Texture'Engine.DefaultTexture'
             Begin Object Class=GUIPanel Name=RulesPanel
                 Begin Object Class=GUIMultiColumnListBox Name=RulesListBox
                     bVisibleWhenEmpty=True
                     Begin Object Class=Browser_RulesList Name=TheRulesList
                         OnPreDraw=TheRulesList.InternalOnPreDraw
                         OnClick=TheRulesList.InternalOnClick
                         OnRightClick=TheRulesList.InternalOnRightClick
                         OnMousePressed=TheRulesList.InternalOnMousePressed
                         OnMouseRelease=TheRulesList.InternalOnMouseRelease
                         OnKeyEvent=TheRulesList.InternalOnKeyEvent
                         OnBeginDrag=TheRulesList.InternalOnBeginDrag
                         OnEndDrag=TheRulesList.InternalOnEndDrag
                         OnDragDrop=TheRulesList.InternalOnDragDrop
                         OnDragEnter=TheRulesList.InternalOnDragEnter
                         OnDragLeave=TheRulesList.InternalOnDragLeave
                         OnDragOver=TheRulesList.InternalOnDragOver
                     End Object
                     Controls(0)=Browser_RulesList'XInterface.Browser_ServerListPageBase.TheRulesList'

                     OnCreateComponent=RulesListBox.InternalOnCreateComponent
                     StyleName="ServerBrowserGrid"
                     WinHeight=1.000000
                 End Object
                 Controls(0)=GUIMultiColumnListBox'XInterface.Browser_ServerListPageBase.RulesListBox'

             End Object
             Controls(0)=GUIPanel'XInterface.Browser_ServerListPageBase.RulesPanel'

             Begin Object Class=GUIPanel Name=PlayersPanel
                 Begin Object Class=GUIMultiColumnListBox Name=PlayersListBox
                     bVisibleWhenEmpty=True
                     Begin Object Class=Browser_PlayersList Name=ThePlayersList
                         OnPreDraw=ThePlayersList.InternalOnPreDraw
                         OnClick=ThePlayersList.InternalOnClick
                         OnRightClick=ThePlayersList.InternalOnRightClick
                         OnMousePressed=ThePlayersList.InternalOnMousePressed
                         OnMouseRelease=ThePlayersList.InternalOnMouseRelease
                         OnKeyEvent=ThePlayersList.InternalOnKeyEvent
                         OnBeginDrag=ThePlayersList.InternalOnBeginDrag
                         OnEndDrag=ThePlayersList.InternalOnEndDrag
                         OnDragDrop=ThePlayersList.InternalOnDragDrop
                         OnDragEnter=ThePlayersList.InternalOnDragEnter
                         OnDragLeave=ThePlayersList.InternalOnDragLeave
                         OnDragOver=ThePlayersList.InternalOnDragOver
                     End Object
                     Controls(0)=Browser_PlayersList'XInterface.Browser_ServerListPageBase.ThePlayersList'

                     OnCreateComponent=PlayersListBox.InternalOnCreateComponent
                     StyleName="ServerBrowserGrid"
                     WinHeight=1.000000
                 End Object
                 Controls(0)=GUIMultiColumnListBox'XInterface.Browser_ServerListPageBase.PlayersListBox'

             End Object
             Controls(1)=GUIPanel'XInterface.Browser_ServerListPageBase.PlayersPanel'

             WinHeight=1.000000
         End Object
         Controls(1)=GUISplitter'XInterface.Browser_ServerListPageBase.DetailsSplitter'

         WinHeight=0.900000
     End Object
     Controls(0)=GUISplitter'XInterface.Browser_ServerListPageBase.MainSplitter'

     Begin Object Class=GUIPanel Name=FooterPanel
         Begin Object Class=GUIButton Name=BackButton
             Caption="BACK"
             StyleName="SquareMenuButton"
             WinWidth=0.200000
             WinHeight=0.500000
             OnKeyEvent=BackButton.InternalOnKeyEvent
         End Object
         Controls(0)=GUIButton'XInterface.Browser_ServerListPageBase.BackButton'

         Begin Object Class=GUIButton Name=RefreshButton
             Caption="REFRESH LIST"
             StyleName="SquareMenuButton"
             WinLeft=0.200000
             WinWidth=0.200000
             WinHeight=0.500000
             OnKeyEvent=RefreshButton.InternalOnKeyEvent
         End Object
         Controls(1)=GUIButton'XInterface.Browser_ServerListPageBase.RefreshButton'

         Begin Object Class=GUIButton Name=JoinButton
             Caption="JOIN"
             StyleName="SquareMenuButton"
             WinLeft=0.400000
             WinWidth=0.200000
             WinHeight=0.500000
             OnKeyEvent=JoinButton.InternalOnKeyEvent
         End Object
         Controls(2)=GUIButton'XInterface.Browser_ServerListPageBase.JoinButton'

         Begin Object Class=GUIButton Name=SpectateButton
             Caption="SPECTATE"
             StyleName="SquareMenuButton"
             WinLeft=0.600000
             WinWidth=0.200000
             WinHeight=0.500000
             OnKeyEvent=SpectateButton.InternalOnKeyEvent
         End Object
         Controls(3)=GUIButton'XInterface.Browser_ServerListPageBase.SpectateButton'

         Begin Object Class=GUIButton Name=AddFavoriteButton
             Caption="ADD FAVORITE"
             StyleName="SquareMenuButton"
             WinLeft=0.800000
             WinWidth=0.200000
             WinHeight=0.500000
             OnKeyEvent=AddFavoriteButton.InternalOnKeyEvent
         End Object
         Controls(4)=GUIButton'XInterface.Browser_ServerListPageBase.AddFavoriteButton'

         Begin Object Class=GUITitleBar Name=MyStatus
             bUseTextHeight=False
             Justification=TXTA_Left
             StyleName="SquareBar"
             WinTop=0.500000
             WinWidth=0.600000
             WinHeight=0.500000
         End Object
         Controls(5)=GUITitleBar'XInterface.Browser_ServerListPageBase.MyStatus'

         Begin Object Class=GUIButton Name=UtilButtonA
             StyleName="SquareMenuButton"
             WinTop=0.500000
             WinLeft=0.600000
             WinWidth=0.200000
             WinHeight=0.500000
             OnKeyEvent=UtilButtonA.InternalOnKeyEvent
         End Object
         Controls(6)=GUIButton'XInterface.Browser_ServerListPageBase.UtilButtonA'

         Begin Object Class=GUIButton Name=UtilButtonB
             StyleName="SquareMenuButton"
             WinTop=0.500000
             WinLeft=0.800000
             WinWidth=0.200000
             WinHeight=0.500000
             OnKeyEvent=UtilButtonB.InternalOnKeyEvent
         End Object
         Controls(7)=GUIButton'XInterface.Browser_ServerListPageBase.UtilButtonB'

         WinTop=0.900000
         WinHeight=0.100000
     End Object
     Controls(1)=GUIPanel'XInterface.Browser_ServerListPageBase.FooterPanel'

}
