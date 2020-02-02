// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class UT2K4Tab_AdminPlayerList extends UT2K4TabPanel;


var  AdminPlayerList MyPlayerList;
var  GUIMultiColumnListbox MyListBox;
var  bool bAdvancedAdmin;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController,MyOwner);

	MyListBox = GUIMultiColumnListbox(Controls[1]);
    MyPlayerList = AdminPlayerList(MyListBox.Controls[0]);
	MyPlayerList.Initcomponent(MyController,self);

    WinWidth = Controller.ActivePage.WinWidth;
    WinLeft = Controller.ActivePage.WinLeft;

}

function ProcessRule(string NewRule)
{
	if (NewRule=="Done")
    	XPlayer(PlayerOwner()).ProcessRule = None;
	else
      MyPlayerList.Add(NewRule);
}

function ReloadList()
{
	MyPlayerList.Clear();
	if (XPlayer(PlayerOwner())!=None)
    {
	    XPlayer(PlayerOwner()).ProcessRule = ProcessRule;
       	XPlayer(PlayerOwner()).ServerRequestPlayerInfo();
    }
}


function bool KickClicked(GUIComponent Sender)
{
	PlayerOwner().ConsoleCommand("Admin Kick"@MyPlayerList.MyPlayers[MyPlayerList.Index].PlayerName);
	ReloadList();
    return true;
}

function bool BanClicked(GUIComponent Sender)
{
	if (bAdvancedAdmin)
		PlayerOwner().ConsoleCommand("Admin Kick Ban"@MyPlayerList.MyPlayers[MyPlayerList.Index].PlayerName);
	else PlayerOwner().ConsoleCommand("Admin KickBan"@MyPlayerList.MyPlayers[MyPlayerList.Index].PlayerName);
    ReloadList();
    return true;
}

defaultproperties
{
     Begin Object Class=GUIImage Name=AdminBackground
         Image=Texture'InterfaceContent.Menu.SquareBoxA'
         ImageStyle=ISTY_Stretched
         WinHeight=1.000000
         bNeverFocus=True
     End Object
     Controls(0)=GUIImage'GUI2K4.UT2K4Tab_AdminPlayerList.AdminBackground'

     Begin Object Class=GUIMultiColumnListBox Name=AdminPlayersListBox
         bVisibleWhenEmpty=True
         Begin Object Class=AdminPlayerList Name=AdminList
             OnPreDraw=AdminList.InternalOnPreDraw
             OnClick=AdminList.InternalOnClick
             OnRightClick=AdminList.InternalOnRightClick
             OnMousePressed=AdminList.InternalOnMousePressed
             OnMouseRelease=AdminList.InternalOnMouseRelease
             OnKeyEvent=AdminList.InternalOnKeyEvent
             OnBeginDrag=AdminList.InternalOnBeginDrag
             OnEndDrag=AdminList.InternalOnEndDrag
             OnDragDrop=AdminList.InternalOnDragDrop
             OnDragEnter=AdminList.InternalOnDragEnter
             OnDragLeave=AdminList.InternalOnDragLeave
             OnDragOver=AdminList.InternalOnDragOver
         End Object
         Controls(0)=AdminPlayerList'GUI2K4.UT2K4Tab_AdminPlayerList.AdminList'

         OnCreateComponent=AdminPlayersListBox.InternalOnCreateComponent
         StyleName="ServerBrowserGrid"
         WinHeight=0.878127
     End Object
     Controls(1)=GUIMultiColumnListBox'GUI2K4.UT2K4Tab_AdminPlayerList.AdminPlayersListBox'

     Begin Object Class=GUIButton Name=AdminPlayerKick
         Caption="Kick"
         StyleName="SquareMenuButton"
         Hint="Kick this Player"
         WinTop=0.900000
         WinLeft=0.743750
         WinWidth=0.120000
         WinHeight=0.070625
         OnClick=UT2K4Tab_AdminPlayerList.KickClicked
         OnKeyEvent=AdminPlayerKick.InternalOnKeyEvent
     End Object
     Controls(2)=GUIButton'GUI2K4.UT2K4Tab_AdminPlayerList.AdminPlayerKick'

     Begin Object Class=GUIButton Name=AdminPlayerBan
         Caption="Ban"
         StyleName="SquareMenuButton"
         Hint="Ban this player"
         WinTop=0.900000
         WinLeft=0.868750
         WinWidth=0.120000
         WinHeight=0.070625
         OnClick=UT2K4Tab_AdminPlayerList.BanClicked
         OnKeyEvent=AdminPlayerBan.InternalOnKeyEvent
     End Object
     Controls(3)=GUIButton'GUI2K4.UT2K4Tab_AdminPlayerList.AdminPlayerBan'

     WinHeight=0.625003
}
