//-----------------------------------------------------------
//
//-----------------------------------------------------------
class utvWatcherMenu extends GUIPage;

var float BoxHeight;
var float BoxWidth;
var float MarginWidth;
var float ItemHeight;
var float ItemGap;

var utvInteraction ui;
var utvReplication ur;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local utvInteraction tui;
	local utvReplication tur;

	super.InitComponent(MyController, MyOwner);

	//The window
	Controls[0].WinHeight = BoxHeight;
	Controls[0].WinWidth = BoxWidth;
	Controls[0].WinTop = 0.5 - (0.5 * BoxHeight);
	Controls[0].WinLeft = 0.5 - (0.5 * BoxWidth);

	//Headline
	Controls[1].WinHeight = ItemHeight;
	Controls[1].WinWidth = BoxWidth - (MarginWidth * 2);
	Controls[1].WinTop = Controls[0].WinTop + 0.01; //+ ItemGap * 2;
	Controls[1].WinLeft = Controls[0].WinLeft + MarginWidth;

	//label
	Controls[2].WinHeight = ItemHeight;
	Controls[2].WinWidth = Controls[1].WinWidth;
	Controls[2].WinTop = Controls[1].WinTop + ItemGap * 2 + ItemHeight;
	Controls[2].WinLeft = Controls[1].WinLeft;

	//combobox
	Controls[3].WinHeight = ItemHeight;
	Controls[3].WinWidth = Controls[1].WinWidth;
	Controls[3].WinTop = Controls[2].WinTop + ItemHeight - ItemGap;
	Controls[3].WinLeft = Controls[1].WinLeft;
	moComboBox (Controls[3]).AddItem ("Locked during free flight");
	moComboBox (Controls[3]).AddItem ("Completely locked");
	moComboBox (Controls[3]).AddItem ("Completely free");
	moComboBox (Controls[3]).ReadOnly (true);
	moComboBox (Controls[3]).SetIndex (class'utvReplication'.default.ViewMode);

	//label delay
	Controls[4].WinHeight = ItemHeight;
	Controls[4].WinWidth = Controls[3].WinWidth;
	Controls[4].WinTop = Controls[3].WinTop + ItemGap * 2 + ItemHeight;
	Controls[4].WinLeft = Controls[3].WinLeft;

	//label clients
	Controls[5].WinHeight = ItemHeight;
	Controls[5].WinWidth = Controls[4].WinWidth;
	Controls[5].WinTop = Controls[4].WinTop + ItemGap + ItemHeight;
	Controls[5].WinLeft = Controls[4].WinLeft;

	//ok button
	Controls[6].WinHeight = ItemHeight;
	Controls[6].WinWidth = Controls[1].WinWidth / 2;
	Controls[6].WinTop = Controls[5].WinTop + ItemHeight * 4 + ItemGap;
	Controls[6].WinLeft = 0.5 - (0.5 * Controls[6].WinWidth);

	//label follow primary
	Controls[7].WinHeight = ItemHeight;
	Controls[7].WinWidth = Controls[5].WinWidth;
	Controls[7].WinTop = Controls[5].WinTop + ItemGap + ItemHeight;
	Controls[7].WinLeft = Controls[5].WinLeft;

	//button follow primary
	Controls[8].WinHeight = ItemHeight;
	Controls[8].WinWidth = ItemHeight;
	Controls[8].WinTop = Controls[5].WinTop + ItemHeight;
	Controls[8].WinLeft = Controls[5].WinLeft+Controls[5].WinWidth/2;

	//label show utv chat
	Controls[9].WinHeight = ItemHeight;
	Controls[9].WinWidth = Controls[7].WinWidth;
	Controls[9].WinTop = Controls[7].WinTop + ItemGap + ItemHeight;
	Controls[9].WinLeft = Controls[7].WinLeft;

	//button show utv chat
	Controls[10].WinHeight = ItemHeight;
	Controls[10].WinWidth = ItemHeight;
	Controls[10].WinTop = Controls[7].WinTop + ItemHeight;
	Controls[10].WinLeft = Controls[7].WinLeft+Controls[7].WinWidth/2;

	OnClose = InternalOnClose;

	foreach AllObjects (class'utvInteraction', tui) {
		ui = tui;
	}
	foreach AllObjects (class'utvReplication', tur) {
		ur = tur;
	}

	GUILabel(Controls[4]).Caption='Delay ' $ string(ui.Delay);
	GUILabel(Controls[5]).Caption='Total clients ' $ string(ui.Clients);
	GUICheckBoxButton(Controls[8]).bChecked=ur.FollowPrimary;
	GUICheckBoxButton(Controls[10]).bChecked=!ur.MuteChat;
	if(!ur.SeeAll){
		GUILabel(Controls[7]).Caption="See all mode disabled";
		Controls[8].WinHeight = 0;
		Controls[8].WinWidth = 0;
	}
	if(ur.NoPrimary){
		GUILabel(Controls[7]).Caption="See all mode without primary client";
		Controls[8].WinHeight = 0;
		Controls[8].WinWidth = 0;
	}

	if (ur.IsDemo) {
        if (ur.SeeAll)
    		GUILabel(Controls[7]).Caption="Watching server side demo";
    	else
    		GUILabel(Controls[7]).Caption="Watching client side demo";
		Controls[8].WinHeight = 0;
		Controls[8].WinWidth = 0;
	}
}

function InternalOnClose(optional bool bCanceled)
{
	local PlayerController pc;

	pc = PlayerOwner();

	if(pc != None && pc.Level.Pauser != None)
		pc.SetPause(false);

	Super.OnClose(bCanceled);
}

function bool InternalOnClick(GUIComponent Sender)
{
	if (Sender == Controls[6])	//Ok button
	{
		if(!ur.NoPrimary) {
			ur.FollowPrimary=GUICheckBoxButton(Controls[8]).bChecked;
		}
		ur.MuteChat=!GUICheckBoxButton(Controls[10]).bChecked;
        SaveDefaults ();
		Controller.CloseMenu ();
	}

	return true;
}

function InternalOnChange(GUIComponent Sender)
{
}

function SaveDefaults ()
{
	class 'utvReplication'.default.ViewMode = moComboBox(Controls[3]).GetIndex ();
	class 'utvReplication'.static.StaticSaveConfig ();
}

defaultproperties
{
     BoxHeight=0.470000
     BoxWidth=0.500000
     MarginWidth=0.020000
     ItemHeight=0.040000
     ItemGap=0.010000
     bRenderWorld=True
     bRequire640x480=False
     bAllowedAsLast=True
     Begin Object Class=GUIImage Name=Background
         Image=Texture'2K4Menus.NewControls.Display95'
         ImageStyle=ISTY_Stretched
         bNeverFocus=True
     End Object
     Controls(0)=GUIImage'UTV2004c.utvWatcherMenu.Background'

     Begin Object Class=GUILabel Name=TitleText
         Caption="UTV2004 Watcher settings"
         TextAlign=TXTA_Center
         TextColor=(B=0,G=255,R=255)
         bMultiLine=True
     End Object
     Controls(1)=GUILabel'UTV2004c.utvWatcherMenu.TitleText'

     Begin Object Class=GUILabel Name=Label1
         Caption="View rotation"
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2MidGameFont"
         bMultiLine=True
     End Object
     Controls(2)=GUILabel'UTV2004c.utvWatcherMenu.Label1'

     Begin Object Class=moComboBox Name=ComboBox
         CaptionWidth=0.000000
         OnCreateComponent=ComboBox.InternalOnCreateComponent
         OnChange=utvWatcherMenu.InternalOnChange
     End Object
     Controls(3)=moComboBox'UTV2004c.utvWatcherMenu.ComboBox'

     Controls(4)=GUILabel'UTV2004c.utvWatcherMenu.Label1'

     Controls(5)=GUILabel'UTV2004c.utvWatcherMenu.Label1'

     Begin Object Class=GUIButton Name=OkButton
         Caption="OK"
         StyleName="MidGameButton"
         OnClick=utvWatcherMenu.InternalOnClick
         OnKeyEvent=OkButton.InternalOnKeyEvent
     End Object
     Controls(6)=GUIButton'UTV2004c.utvWatcherMenu.OkButton'

     Begin Object Class=GUILabel Name=Label2
         Caption="Follow primary"
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2MidGameFont"
         bMultiLine=True
     End Object
     Controls(7)=GUILabel'UTV2004c.utvWatcherMenu.Label2'

     Begin Object Class=GUICheckBoxButton Name=Button2
         OnKeyEvent=Button2.InternalOnKeyEvent
     End Object
     Controls(8)=GUICheckBoxButton'UTV2004c.utvWatcherMenu.Button2'

     Begin Object Class=GUILabel Name=Label3
         Caption="Show UTV Chat"
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2MidGameFont"
         bMultiLine=True
     End Object
     Controls(9)=GUILabel'UTV2004c.utvWatcherMenu.Label3'

     Begin Object Class=GUICheckBoxButton Name=Button3
         OnKeyEvent=Button3.InternalOnKeyEvent
     End Object
     Controls(10)=GUICheckBoxButton'UTV2004c.utvWatcherMenu.Button3'

}
