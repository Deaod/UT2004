//-----------------------------------------------------------
//
//-----------------------------------------------------------
class utvPrimaryMenu extends ut2k3guIPage;

var float BoxHeight;
var float BoxWidth;
var float MarginWidth;
var float ItemHeight;
var float ItemGap;

var utvInteraction ui;
var utvReplication ur;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int a, prev, mark;
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
	Controls[1].WinTop = Controls[0].WinTop + 0.002; // + ItemGap * 5;
	Controls[1].WinLeft = Controls[0].WinLeft + MarginWidth;

	//label total clients
	Controls[2].WinHeight = ItemHeight;
	Controls[2].WinWidth = BoxWidth*0.4;
	Controls[2].WinTop = Controls[1].WinTop + ItemGap + ItemHeight;
	Controls[2].WinLeft = Controls[1].WinLeft + MarginWidth;


	///mmuuu

	//label mute
	Controls[24].WinHeight = ItemHeight;
	Controls[24].WinWidth = BoxWidth*0.4;
	Controls[24].WinTop = Controls[2].WinTop + ItemGap + ItemHeight;
	Controls[24].WinLeft = Controls[2].WinLeft;

	//divider
	Controls[26].WinHeight = 0.005;
	Controls[26].WinWidth = BoxWidth - (MarginWidth * 2);
	Controls[26].WinTop = Controls[24].WinTop + ItemGap + ItemHeight;
	Controls[26].WinLeft = Controls[1].WinLeft;



	//label serveraddress
	Controls[3].WinHeight = ItemHeight;
	Controls[3].WinWidth = Controls[24].WinWidth;
	Controls[3].WinTop = Controls[24].WinTop + ItemGap * 3 + ItemHeight;
	Controls[3].WinLeft = Controls[24].WinLeft;

	//rest of the labels
	prev=3;
	mark=0;
	for(a=4;a<11;++a){
		if ((a == 8) && (mark == 0)) {		//would renumbering have been easier? :)
			a = 22;
			mark = 1;
		}
		Controls[a].WinHeight = ItemHeight;
		Controls[a].WinWidth = Controls[prev].WinWidth;
		Controls[a].WinTop = Controls[prev].WinTop + ItemGap + ItemHeight;
		Controls[a].WinLeft = Controls[prev].WinLeft;

		prev=a;
		if ((a == 22) && (mark == 1))
			a = 7;
	}

	//ok button
	Controls[11].WinHeight = ItemHeight;
	Controls[11].WinWidth = Controls[10].WinWidth;
	Controls[11].WinTop = Controls[10].WinTop + ItemHeight * 2;
	Controls[11].WinLeft = Controls[10].WinLeft;

	//textbox total clients
	Controls[12].WinHeight = ItemHeight;
	Controls[12].WinWidth = BoxWidth*0.5;
	Controls[12].WinTop = Controls[1].WinTop + ItemGap * 2 + ItemHeight;
	Controls[12].WinLeft = Controls[0].WinLeft+BoxWidth*0.5;


	//muu
	//checkbox mute chat
	Controls[25].WinHeight = ItemHeight;
	Controls[25].WinWidth = ItemHeight;
	Controls[25].WinTop = Controls[12].WinTop + ItemHeight;
	Controls[25].WinLeft = Controls[12].WinLeft;

	//textbox serveraddress
	Controls[13].WinHeight = ItemHeight;
	Controls[13].WinWidth = BoxWidth*0.4;
	Controls[13].WinTop = Controls[25].WinTop + ItemGap * 3 + ItemHeight;
	Controls[13].WinLeft = Controls[25].WinLeft;

	//rest of the textboxes
	prev=13;
	mark=0;
	for(a=14;a<21;++a){
		if ((a == 18) && (mark == 0)) {
			a = 23;
			mark = 1;
		}
		Controls[a].WinHeight = ItemHeight;
		Controls[a].WinWidth = Controls[prev].WinWidth;
		Controls[a].WinTop = Controls[prev].WinTop + ItemGap + ItemHeight;
		Controls[a].WinLeft = Controls[prev].WinLeft;
		Controls[a].TabOrder = Controls[prev].TabOrder + 1;

		prev=a;
		if ((a == 23) && (mark == 1))
			a = 17;
	}

	//reset button
	Controls[21].WinHeight = ItemHeight;
	Controls[21].WinWidth = Controls[20].WinWidth;
	Controls[21].WinTop = Controls[20].WinTop + ItemHeight * 2;
	Controls[21].WinLeft = Controls[20].WinLeft;

	foreach AllObjects (class'utvInteraction', tui) {
		ui = tui;
	}
	foreach AllObjects (class'utvReplication', tur) {
		ur = tur;
	}

	GUILabel(Controls[12]).Caption=string(ui.Clients);
	GUIEditBox(Controls[13]).TextStr=ui.ServerAddress;
	GUIEditBox(Controls[14]).TextStr=string(ui.ServerPort);
	GUIEditBox(Controls[15]).TextStr=string(ui.ListenPort);
	GUIEditBox(Controls[16]).TextStr=ui.JoinPassword;
	GUIEditBox(Controls[17]).TextStr=ui.PrimaryPassword;
	GUIEditBox(Controls[18]).TextStr=ui.NormalPassword;
	GUIEditBox(Controls[19]).TextStr=string(ui.Delay);
	GUIEditBox(Controls[20]).TextStr=string(ui.MaxClients);
	GUIEditBox(Controls[23]).TextStr=ui.VipPassword;
	GUICheckBoxButton(Controls[25]).bChecked=!ur.MuteChat;

	OnClose = InternalOnClose;

	RemapComponents();
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
	if (Sender == Controls[11])	//Ok button
	{
		ur.MuteChat=!GUICheckBoxButton(Controls[25]).bChecked;
        SendChanges ();
		Controller.CloseMenu ();
	}
	if (Sender == Controls[21])	//Reset button
	{
		ui.p.ClientMessage ("Resetting server");
        SendChanges ();
        ResetServer ();
		Controller.CloseMenu ();
	}

	return true;
}

function InternalOnChange(GUIComponent Sender)
{
}

function SendChanges ()
{
	local string s;

	ui.ServerAddress=GUIEditBox(Controls[13]).TextStr;
	ui.ServerPort=int(GUIEditBox(Controls[14]).TextStr);
	ui.ListenPort=int(GUIEditBox(Controls[15]).TextStr);
	ui.JoinPassword=GUIEditBox(Controls[16]).TextStr;
	ui.PrimaryPassword=GUIEditBox(Controls[17]).TextStr;
	ui.NormalPassword=GUIEditBox(Controls[18]).TextStr;
	ui.Delay=float(GUIEditBox(Controls[19]).TextStr);
	ui.MaxClients=int(GUIEditBox(Controls[20]).TextStr);
	ui.VipPassword=GUIEditBox(Controls[23]).TextStr;

	s="5 serveraddress=" $ ui.ServerAddress;
	s=s $ " serverport=" $ ui.ServerPort;
	s=s $ " listenport=" $ ui.ListenPort;
	s=s $ " joinpassword=" $ ui.JoinPassword;
	s=s $ " primarypassword=" $ ui.PrimaryPassword;
	s=s $ " vippassword=" $ ui.VipPassword;
	s=s $ " normalpassword=" $ ui.NormalPassword;
	s=s $ " delay=" $ ui.Delay;
	s=s $ " maxclients=" $ ui.maxclients;

	ur.SendToServer(s);
}

function ResetServer ()
{
	local string s;

	s="6 ";
	ur.SendToServer(s);
}

/*
	Begin Object Class=GUIButton name=Background
		bAcceptsInput=false
		bNeverFocus=true
		StyleName="SquareBar"
	End Object
*/

//display95 99

defaultproperties
{
     BoxHeight=0.740000
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
     Controls(0)=GUIImage'UTV2004c.utvPrimaryMenu.Background'

     Begin Object Class=GUILabel Name=TitleText
         Caption="UTV2004 Primary settings"
         TextAlign=TXTA_Center
         TextColor=(B=0,G=255,R=255)
     End Object
     Controls(1)=GUILabel'UTV2004c.utvPrimaryMenu.TitleText'

     Begin Object Class=GUILabel Name=Label1
         Caption="Total clients"
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2MidGameFont"
     End Object
     Controls(2)=GUILabel'UTV2004c.utvPrimaryMenu.Label1'

     Begin Object Class=GUILabel Name=LabelSA
         Caption="Server address"
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2MidGameFont"
     End Object
     Controls(3)=GUILabel'UTV2004c.utvPrimaryMenu.LabelSA'

     Begin Object Class=GUILabel Name=LabelSP
         Caption="Server port"
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2MidGameFont"
     End Object
     Controls(4)=GUILabel'UTV2004c.utvPrimaryMenu.LabelSP'

     Begin Object Class=GUILabel Name=LabelLP
         Caption="Listen port"
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2MidGameFont"
     End Object
     Controls(5)=GUILabel'UTV2004c.utvPrimaryMenu.LabelLP'

     Begin Object Class=GUILabel Name=LabelJP
         Caption="Join password"
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2MidGameFont"
     End Object
     Controls(6)=GUILabel'UTV2004c.utvPrimaryMenu.LabelJP'

     Begin Object Class=GUILabel Name=LabelPP
         Caption="Primary password"
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2MidGameFont"
     End Object
     Controls(7)=GUILabel'UTV2004c.utvPrimaryMenu.LabelPP'

     Begin Object Class=GUILabel Name=LabelNP
         Caption="Normal password"
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2MidGameFont"
     End Object
     Controls(8)=GUILabel'UTV2004c.utvPrimaryMenu.LabelNP'

     Begin Object Class=GUILabel Name=LabelD
         Caption="Delay"
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2MidGameFont"
     End Object
     Controls(9)=GUILabel'UTV2004c.utvPrimaryMenu.LabelD'

     Begin Object Class=GUILabel Name=LabelMC
         Caption="Max clients"
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2MidGameFont"
     End Object
     Controls(10)=GUILabel'UTV2004c.utvPrimaryMenu.LabelMC'

     Begin Object Class=GUIButton Name=OkButton
         Caption="OK"
         StyleName="MidGameButton"
         TabOrder=50
         OnClick=utvPrimaryMenu.InternalOnClick
         OnKeyEvent=OkButton.InternalOnKeyEvent
     End Object
     Controls(11)=GUIButton'UTV2004c.utvPrimaryMenu.OkButton'

     Begin Object Class=GUILabel Name=LabelTC
         Caption="tc"
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2MidGameFont"
         bMultiLine=True
     End Object
     Controls(12)=GUILabel'UTV2004c.utvPrimaryMenu.LabelTC'

     Begin Object Class=GUIEditBox Name=BoxSA
         TabOrder=1
         OnActivate=BoxSA.InternalActivate
         OnDeActivate=BoxSA.InternalDeactivate
         OnKeyType=BoxSA.InternalOnKeyType
         OnKeyEvent=BoxSA.InternalOnKeyEvent
     End Object
     Controls(13)=GUIEditBox'UTV2004c.utvPrimaryMenu.BoxSA'

     Begin Object Class=GUIEditBox Name=BoxSP
         bIntOnly=True
         OnActivate=BoxSP.InternalActivate
         OnDeActivate=BoxSP.InternalDeactivate
         OnKeyType=BoxSP.InternalOnKeyType
         OnKeyEvent=BoxSP.InternalOnKeyEvent
     End Object
     Controls(14)=GUIEditBox'UTV2004c.utvPrimaryMenu.BoxSP'

     Begin Object Class=GUIEditBox Name=BoxLP
         bIntOnly=True
         OnActivate=BoxLP.InternalActivate
         OnDeActivate=BoxLP.InternalDeactivate
         OnKeyType=BoxLP.InternalOnKeyType
         OnKeyEvent=BoxLP.InternalOnKeyEvent
     End Object
     Controls(15)=GUIEditBox'UTV2004c.utvPrimaryMenu.BoxLP'

     Begin Object Class=GUIEditBox Name=BoxJP
         OnActivate=BoxJP.InternalActivate
         OnDeActivate=BoxJP.InternalDeactivate
         OnKeyType=BoxJP.InternalOnKeyType
         OnKeyEvent=BoxJP.InternalOnKeyEvent
     End Object
     Controls(16)=GUIEditBox'UTV2004c.utvPrimaryMenu.BoxJP'

     Begin Object Class=GUIEditBox Name=BoxPP
         OnActivate=BoxPP.InternalActivate
         OnDeActivate=BoxPP.InternalDeactivate
         OnKeyType=BoxPP.InternalOnKeyType
         OnKeyEvent=BoxPP.InternalOnKeyEvent
     End Object
     Controls(17)=GUIEditBox'UTV2004c.utvPrimaryMenu.BoxPP'

     Begin Object Class=GUIEditBox Name=BoxNP
         OnActivate=BoxNP.InternalActivate
         OnDeActivate=BoxNP.InternalDeactivate
         OnKeyType=BoxNP.InternalOnKeyType
         OnKeyEvent=BoxNP.InternalOnKeyEvent
     End Object
     Controls(18)=GUIEditBox'UTV2004c.utvPrimaryMenu.BoxNP'

     Begin Object Class=GUIEditBox Name=BoxD
         bFloatOnly=True
         OnActivate=BoxD.InternalActivate
         OnDeActivate=BoxD.InternalDeactivate
         OnKeyType=BoxD.InternalOnKeyType
         OnKeyEvent=BoxD.InternalOnKeyEvent
     End Object
     Controls(19)=GUIEditBox'UTV2004c.utvPrimaryMenu.BoxD'

     Begin Object Class=GUIEditBox Name=BoxMC
         bIntOnly=True
         OnActivate=BoxMC.InternalActivate
         OnDeActivate=BoxMC.InternalDeactivate
         OnKeyType=BoxMC.InternalOnKeyType
         OnKeyEvent=BoxMC.InternalOnKeyEvent
     End Object
     Controls(20)=GUIEditBox'UTV2004c.utvPrimaryMenu.BoxMC'

     Begin Object Class=GUIButton Name=ResetButton
         Caption="Reset"
         StyleName="MidGameButton"
         TabOrder=51
         OnClick=utvPrimaryMenu.InternalOnClick
         OnKeyEvent=ResetButton.InternalOnKeyEvent
     End Object
     Controls(21)=GUIButton'UTV2004c.utvPrimaryMenu.ResetButton'

     Begin Object Class=GUILabel Name=LabelVP
         Caption="VIP password"
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2MidGameFont"
     End Object
     Controls(22)=GUILabel'UTV2004c.utvPrimaryMenu.LabelVP'

     Begin Object Class=GUIEditBox Name=BoxVP
         OnActivate=BoxVP.InternalActivate
         OnDeActivate=BoxVP.InternalDeactivate
         OnKeyType=BoxVP.InternalOnKeyType
         OnKeyEvent=BoxVP.InternalOnKeyEvent
     End Object
     Controls(23)=GUIEditBox'UTV2004c.utvPrimaryMenu.BoxVP'

     Begin Object Class=GUILabel Name=LabelMute
         Caption="Show UTV Chat"
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2MidGameFont"
     End Object
     Controls(24)=GUILabel'UTV2004c.utvPrimaryMenu.LabelMute'

     Begin Object Class=GUICheckBoxButton Name=MuteButton
         TabOrder=100
         OnKeyEvent=MuteButton.InternalOnKeyEvent
     End Object
     Controls(25)=GUICheckBoxButton'UTV2004c.utvPrimaryMenu.MuteButton'

     Begin Object Class=GUIEditBox Name=HorizLine
         bAcceptsInput=False
         bNeverFocus=True
         OnActivate=HorizLine.InternalActivate
         OnDeActivate=HorizLine.InternalDeactivate
         OnKeyType=HorizLine.InternalOnKeyType
         OnKeyEvent=HorizLine.InternalOnKeyEvent
     End Object
     Controls(26)=GUIEditBox'UTV2004c.utvPrimaryMenu.HorizLine'

}
