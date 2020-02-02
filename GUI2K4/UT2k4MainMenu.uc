// ====================================================================
// 	The Main Menu
//
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
//	Updated by Ron Prestenback
// ====================================================================

class UT2k4MainMenu extends UT2K4GUIPage;

#exec OBJ LOAD FILE=InterfaceContent.utx
#exec OBJ LOAD FIlE=2K4Menus.utx
#exec OBJ LOAD FIlE=2K4MenuSounds.uax
/*
	Variable Name Legend

	l_ 	GUILabel			lb_	GUIListBox
	i_ 	GUIImage			li_	GUIList
	b_	GUIButton			tp_	GUITabPanel
	t_	GUITitleBar			sp_	GUISplitter
	c_	GUITabControl
	p_	GUIPanel

	ch_	moCheckBox
	co_	moComboBox
	nu_	moNumericEdit
	ed_	moEditBox
	fl_	moFloatEdit
	sl_ moSlider
*/

var automated   BackgroundImage i_BkChar,
								i_Background;
var automated	GUIImage 	    i_UT2Logo,
								i_PanHuge,
								i_PanBig,
                                i_PanSmall,
                                i_UT2Shader,
								i_TV;

var automated 	GUIButton	b_SinglePlayer, b_MultiPlayer, b_Host,
							b_InstantAction, b_ModsAndDemo,  b_Settings, b_Quit;



var bool	bAllowClose;

var array<material> CharShots;

var float CharFade, DesiredCharFade;
var float CharFadeTime;

var GUIButton Selected;
var() bool bNoInitDelay;

var() config string MenuSong;

var bool bNewNews;
var float FadeTime;
var bool  FadeOut;

var localized string NewNewsMsg,FireWallTitle, FireWallMsg;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	Background=MyController.DefaultPens[0];
	if (PlayerOwner().Level.IsDemoBuild())
	{
		b_SinglePlayer.DisableMe();
		b_MultiPlayer.SetFocus(none);
	}

	i_BkChar.Image = CharShots[rand(CharShots.Length)];
}

event Timer()
{
	bNoInitDelay = true;
    if (!Controller.bQuietMenu)
	    PlayerOwner().PlaySound(SlideInSound,SLOT_None);
    i_TV.Animate(-0.000977, 0.332292, 0.35);
    i_UT2Logo.Animate(0.007226,0.016926,0.35);
    i_UT2Shader.Animate(0.249023,0.180988,0.35);
    i_TV.OnEndAnimation = MenuIn_OnArrival;
    i_UT2Logo.OnEndAnimation = MenuIn_OnArrival;
    i_UT2Shader.OnEndAnimation = MenuIn_OnArrival;
}

function MenuIn_OnArrival(GUIComponent Sender, EAnimationType Type)
{
	Sender.OnArrival = none;
	if ( bAnimating )
		return;

	i_UT2Shader.OnDraw = MyOnDraw;
    DesiredCharFade=255;
    CharFadeTime = 0.75;

    if (!Controller.bQuietMenu)
	    PlayerOwner().PlaySound(FadeInSound);

    b_SinglePlayer.Animate(0.315359,0.368813,0.35);
    b_SinglePlayer.OnArrival = PlayPopSound;
	b_Multiplayer.Animate(0.363246,0.449282,0.40);
    b_Multiplayer.OnArrival = PlayPopSound;
	b_Host.Animate(0.395097,0.534027,0.45);
    b_Host.OnArrival = PlayPopSound;
	b_InstantAction.Animate(0.423640,0.618619,0.5);
    b_InstantAction.OnArrival = PlayPopSound;
    b_ModsAndDemo.Animate(0.433406,0.705859,0.55);
    b_ModsAndDemo.OnArrival = PlayPopSound;
	b_Settings.Animate(0.434477,0.800327,0.6);
    b_Settings.OnArrival = PlayPopSound;
	b_Quit.Animate(0.424711,0.887567,0.65);
    b_Quit.OnArrival = MenuIn_Done;
}

event Opened(GUIComponent Sender)
{
	if ( bDebugging )
		log(Name$".Opened()   Sender:"$Sender,'Debug');

    if ( Sender != None && PlayerOwner().Level.IsPendingConnection() )
    	PlayerOwner().ConsoleCommand("CANCEL");

    Super.Opened(Sender);

	bNewNews = class'GUI2K4.UT2K4Community'.default.ModRevLevel != class'GUI2K4.UT2K4Community'.default.LastModRevLevel;
	FadeTime=0;
	FadeOut=true;

    Selected = none;

    // Reset the animations of all components
    i_TV.Animate(-0.000977, 1.668619, 0);
    i_UT2Logo.Animate(0.007226,-0.392579,0);
    i_UT2Shader.Animate(0.249023,-0.105470,0);
    b_SinglePlayer.Animate(1,0.368813,0);
	b_Multiplayer.Animate(1.15,0.449282,0);
	b_Host.Animate(1.3,0.534027,0);
	b_InstantAction.Animate(1.45,0.618619,0);
    b_ModsAndDemo.Animate(1.6,0.705859,0);
	b_Settings.Animate(1.75,0.800327,0);
	b_Quit.Animate(1.9,0.887567,0);
}

function MenuIn_Done(GUIComponent Sender, EAnimationType Type)
{
	Sender.OnArrival = none;
    PlayPopSound(Sender,Type);
}

function PlayPopSound(GUIComponent Sender, EAnimationType Type)
{
    if (!Controller.bQuietMenu)
		PlayerOwner().PlaySound(PopInSound);
}

function bool PanHugeDraw(Canvas Canvas)
{
	i_PanHuge.ImageColor.A  = 40 * (CharFade/255);
	i_PanBig.ImageColor.A   = 75 * (CharFade/255);
	i_PanSmall.ImageColor.A = i_BKChar.ImageColor.A;

    return false;
}

function bool BkCharDraw(Canvas Canvas)
{

	if (CharFadeTime>0)
    {
    	CharFade += (DesiredCharFade - CharFade) * (Controller.RenderDelta / CharFadeTime);
        CharFadeTime -= Controller.RenderDelta;
        if (CharFadeTime<=0.0)
        {
        	CharFade = DesiredCharFade;
            CharFadeTime=0.0;
        }
    }

    i_BKChar.ImageColor.A = int(CharFade);

 	return false;
}

function MainReopened()
{
	if ( !PlayerOwner().Level.IsPendingConnection() )
	{
		i_BkChar.Image = CharShots[rand(CharShots.Length)];
		Opened(none);
		Timer();
	}
}

function InternalOnOpen()
{
    if (bNoInitDelay)
    	Timer();
    else
	    SetTimer(0.5,false);

	Controller.PerformRestore();
    PlayerOwner().ClientSetInitialMusic(MenuSong,MTRAN_Segue);
}

function OnClose(optional Bool bCancelled)
{
}

function bool MyKeyEvent(out byte Key,out byte State,float delta)
{
	if(Key == 0x1B && state == 1)	// Escape pressed
		bAllowClose = true;

	return false;
}

function bool CanClose(optional bool bCancelled)
{
	if(bAllowClose)
		ButtonClick(b_Quit);

	bAllowClose = False;
	return PlayerOwner().Level.IsPendingConnection();
}

function MoveOn()
{
	switch (Selected)
	{
		case b_SinglePlayer:
			Profile("SinglePlayer");
			Controller.OpenMenu(Controller.GetSinglePlayerPage());
			Profile("SinglePlayer");
			return;

		case b_MultiPlayer:
			if ( !Controller.AuthroizeFirewall() )
			{
				Controller.OpenMenu("GUI2K4.UT2K4GenericMessageBox",FireWallTitle,FireWallMsg);
				return;
			}
			Profile("ServerBrowser");
			Controller.OpenMenu(Controller.GetServerBrowserPage());
			Profile("ServerBrowser");
			return;

		case b_Host:
			if ( !Controller.AuthroizeFirewall() )
			{
				Controller.OpenMenu("GUI2K4.UT2K4GenericMessageBox",FireWallTitle,FireWallMsg);
				return;
			}
			Profile("MPHost");
			Controller.OpenMenu(Controller.GetMultiplayerPage());
			Profile("MPHost");
			return;

		case b_InstantAction:
			Profile("InstantAction");
			Controller.OpenMenu(Controller.GetInstantActionPage());
			Profile("InstantAction");
			return;

		case b_ModsAndDemo:
			if ( !Controller.AuthroizeFirewall() )
			{
				Controller.OpenMenu("GUI2K4.UT2K4GenericMessageBox",FireWallTitle,FireWallMsg);
				return;
			}
			Profile("ModsandDemos");
			Controller.OpenMenu(Controller.GetModPage());
			Profile("ModsandDemos");
			return;

		case b_Settings:
			Profile("Settings");
        	Controller.OpenMenu(Controller.GetSettingsPage());
			Profile("Settings");
			return;

		case b_Quit:
			Profile("Quit");
			Controller.OpenMenu(Controller.GetQuitPage());
			Profile("Quit");
			return;

		default:
			StopWatch(True);
	}
}

function bool ButtonClick(GUIComponent Sender)
{
	if (GUIButton(Sender) != None)
		Selected = GUIButton(Sender);

	if (Selected==None)
    	return false;

	InitAnimOut( i_TV, -0.000977, 1.668619, 0.35);
    InitAnimOut(i_UT2Logo, 0.007226,-0.392579,0.35);
    InitAnimOut(i_UT2Shader,0.249023,-0.105470,0.35);
    InitAnimOut(b_SinglePlayer,1,0.368813,0.35);
	InitAnimOut(b_Multiplayer,1.15,0.449282,0.35);
	InitAnimOut(b_Host,1.3,0.534027,0.35);
	InitAnimOut(b_InstantAction,1.45,0.618619,0.35);
    InitAnimOut(b_ModsAndDemo,1.6,0.705859,0.35);
	InitAnimOut(b_Settings,1.75,0.800327,0.35);
	InitAnimOut(b_Quit,1.9,0.887567,0.35);

    DesiredCharFade=0;
    CharFadeTime = 0.35;
    return true;
}

function InitAnimOut( GUIComponent C, float X, float Y, float Z )
{
	if ( C == None )
	{
		Warn("UT2K4MainMenu.InitAnimOut called with null component!");
		return;
	}

	C.Animate(X,Y,Z);
	C.OnEndAnimation = MenuOut_Done;
}

function MenuOut_Done(GUIComponent Sender, EAnimationType Type)
{
	Sender.OnArrival = none;
	if ( bAnimating )
		return;

    MoveOn();
}

function bool MyOnDraw(Canvas Canvas)
{
	local GUIButton FButton;
    local int i,x2;
    local float XL,YL;
	local float DeltaTime;

    if (bAnimating || !Controller.bCurMenuInitialized )
    	return false;

    DeltaTime=Controller.RenderDelta;

    for (i=0;i<Controls.Length;i++)
    {
    	if ( (GUIButton(Controls[i])!=None) )
        {

 			FButton = GUIButton(Controls[i]);
            if (FButton.Tag>0 && FButton.MenuState!=MSAT_Focused)
            {
            	FButton.Tag -= 784*DeltaTime;
                if (FButton.Tag<0)
                	FButton.Tag=0;
            }
			else if (FButton.MenuState==MSAT_Focused)
            	FButton.Tag=200;

            if (FButton.Tag>0)
            {
	            fButton.Style.TextSize(Canvas,MSAT_Focused, FButton.Caption,XL,YL,FButton.FontScale);
	            x2 = FButton.ActualLeft() + XL + 16;
	            Canvas.Style=5;
	            Canvas.SetDrawColor(255,255,255,FButton.Tag);
	            Canvas.SetPos(0,fButton.ActualTop());
				Canvas.DrawTilePartialStretched(material'Highlight',x2,FButton.ActualHeight());
            }
        }
    }

    return false;
}

event bool NotifyLevelChange()
{
	if ( bDebugging )
		log(Name@"NotifyLevelChange  PendingConnection:"$PlayerOwner().Level.IsPendingConnection());

	return PlayerOwner().Level.IsPendingConnection();
}


function bool CommunityDraw(canvas c)
{
	local float x,y,xl,yl,a;
	if (bNewNews)
	{

		a = 255.0 * (FadeTime/1.0);
		if (FadeOut)
			a = 255 - a;

		FadeTime += Controller.RenderDelta;
		if (FadeTime>=1.0)
		{
			FadeTime = 0;
			FadeOut = !FadeOut;
		}

		a = fclamp(a,1.0,254.0);
		x = b_ModsAndDemo.ActualLeft();
		y = b_Settings.ActualTop();
		C.Font = Controller.GetMenuFont("UT2MenuFont").GetFont(C.ClipX);
		C.Strlen("Qz,q",xl,yl);
		y -= yl - 5;
		C.Style=5;
		C.SetPos(x+1,y+1);
		C.SetDrawColor(0,0,0,A);
		C.DrawText(NewNewsMsg);

		C.SetPos(x,y);
		C.SetDrawColor(207,185,103,A);
		C.DrawText(NewNewsMsg);
	}

	return false;
}

defaultproperties
{
     Begin Object Class=BackgroundImage Name=ImgBkChar
         ImageColor=(A=160)
         ImageRenderStyle=MSTY_Alpha
         X1=0
         Y1=0
         X2=1024
         Y2=768
         RenderWeight=0.040000
         Tag=0
         OnDraw=UT2k4MainMenu.BkCharDraw
     End Object
     i_bkChar=BackgroundImage'GUI2K4.UT2k4MainMenu.ImgBkChar'

     Begin Object Class=BackgroundImage Name=PageBackground
         Image=Texture'2K4Menus.MainMenu.mmbgnd'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Alpha
         X1=0
         Y1=0
         X2=1024
         Y2=768
     End Object
     i_Background=BackgroundImage'GUI2K4.UT2k4MainMenu.PageBackground'

     Begin Object Class=GUIImage Name=ImgUT2Logo
         Image=Texture'2K4Menus.MainMenu.2K4Logo'
         ImageStyle=ISTY_Scaled
         WinTop=0.016926
         WinLeft=0.007226
         WinWidth=0.638868
         WinHeight=0.392579
         RenderWeight=0.050000
     End Object
     i_UT2Logo=GUIImage'GUI2K4.UT2k4MainMenu.ImgUT2Logo'

     Begin Object Class=GUIImage Name=iPanHuge
         Image=TexPanner'2K4Menus.MainMenu.PanHuge'
         ImageColor=(A=40)
         ImageStyle=ISTY_Scaled
         WinTop=0.001719
         WinHeight=0.367969
         RenderWeight=0.020000
         OnDraw=UT2k4MainMenu.PanHugeDraw
     End Object
     i_PanHuge=GUIImage'GUI2K4.UT2k4MainMenu.iPanHuge'

     Begin Object Class=GUIImage Name=iPanBig
         Image=TexPanner'2K4Menus.MainMenu.PanBig'
         ImageColor=(A=75)
         ImageStyle=ISTY_Scaled
         WinTop=0.081771
         WinHeight=0.152422
         RenderWeight=0.023000
     End Object
     i_PanBig=GUIImage'GUI2K4.UT2k4MainMenu.iPanBig'

     Begin Object Class=GUIImage Name=iPanSmall
         Image=TexPanner'2K4Menus.MainMenu.PanSmall'
         ImageStyle=ISTY_Scaled
         WinTop=0.226042
         WinHeight=0.040000
         RenderWeight=0.026000
     End Object
     i_PanSmall=GUIImage'GUI2K4.UT2k4MainMenu.iPanSmall'

     Begin Object Class=GUIImage Name=ImgUT2Shader
         Image=FinalBlend'InterfaceContent.Logos.fbSymbolShader'
         ImageStyle=ISTY_Scaled
         WinTop=0.180988
         WinLeft=0.249023
         WinWidth=0.155273
         WinHeight=0.105470
         RenderWeight=0.060000
     End Object
     i_UT2Shader=GUIImage'GUI2K4.UT2k4MainMenu.ImgUT2Shader'

     Begin Object Class=GUIImage Name=ImgTV
         Image=FinalBlend'ULogo.MainMenu.CornerMenuFinal'
         ImageStyle=ISTY_Scaled
         X1=0
         Y1=1
         X2=512
         Y2=511
         WinTop=0.332292
         WinLeft=-0.000977
         WinWidth=0.500000
         WinHeight=0.668619
         RenderWeight=5.070000
     End Object
     i_TV=GUIImage'GUI2K4.UT2k4MainMenu.ImgTV'

     Begin Object Class=GUIButton Name=SinglePlayerButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Single Player"
         bUseCaptionHeight=True
         FontScale=FNS_Small
         StyleName="TextButton"
         Hint="Play through the Tournament"
         WinTop=0.368813
         WinLeft=0.315359
         WinWidth=0.715022
         WinHeight=0.075000
         TabOrder=0
         bFocusOnWatch=True
         OnClick=UT2k4MainMenu.ButtonClick
         OnKeyEvent=SinglePlayerButton.InternalOnKeyEvent
     End Object
     b_SinglePlayer=GUIButton'GUI2K4.UT2k4MainMenu.SinglePlayerButton'

     Begin Object Class=GUIButton Name=MultiplayerButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Join Game"
         bUseCaptionHeight=True
         FontScale=FNS_Small
         StyleName="TextButton"
         Hint="Play with human opponents over a LAN or the internet"
         WinTop=0.449282
         WinLeft=0.363246
         WinWidth=0.659899
         WinHeight=0.075000
         TabOrder=1
         bFocusOnWatch=True
         OnClick=UT2k4MainMenu.ButtonClick
         OnKeyEvent=MultiplayerButton.InternalOnKeyEvent
     End Object
     b_MultiPlayer=GUIButton'GUI2K4.UT2k4MainMenu.MultiplayerButton'

     Begin Object Class=GUIButton Name=HostButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Host Game"
         bUseCaptionHeight=True
         FontScale=FNS_Small
         StyleName="TextButton"
         Hint="Start a server and invite others to join your game"
         WinTop=0.534027
         WinLeft=0.395097
         WinWidth=0.627131
         WinHeight=0.075000
         TabOrder=2
         bFocusOnWatch=True
         OnClick=UT2k4MainMenu.ButtonClick
         OnKeyEvent=HostButton.InternalOnKeyEvent
     End Object
     b_Host=GUIButton'GUI2K4.UT2k4MainMenu.HostButton'

     Begin Object Class=GUIButton Name=InstantActionButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Instant Action"
         bUseCaptionHeight=True
         FontScale=FNS_Small
         StyleName="TextButton"
         Hint="Play a practice match"
         WinTop=0.618619
         WinLeft=0.423640
         WinWidth=0.593666
         WinHeight=0.075000
         TabOrder=3
         bFocusOnWatch=True
         OnClick=UT2k4MainMenu.ButtonClick
         OnKeyEvent=InstantActionButton.InternalOnKeyEvent
     End Object
     b_InstantAction=GUIButton'GUI2K4.UT2k4MainMenu.InstantActionButton'

     Begin Object Class=GUIButton Name=ModsAndDemosButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Community"
         bUseCaptionHeight=True
         FontScale=FNS_Small
         StyleName="TextButton"
         Hint="Get the latest news, demos and mods from the UT2004 community"
         WinTop=0.705859
         WinLeft=0.433406
         WinWidth=0.574135
         WinHeight=0.075000
         TabOrder=4
         bFocusOnWatch=True
         OnDraw=UT2k4MainMenu.CommunityDraw
         OnClick=UT2k4MainMenu.ButtonClick
         OnKeyEvent=ModsAndDemosButton.InternalOnKeyEvent
     End Object
     b_ModsAndDemo=GUIButton'GUI2K4.UT2k4MainMenu.ModsAndDemosButton'

     Begin Object Class=GUIButton Name=SettingsButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Settings"
         bUseCaptionHeight=True
         FontScale=FNS_Small
         StyleName="TextButton"
         Hint="Change your controls and settings"
         WinTop=0.800327
         WinLeft=0.434477
         WinWidth=0.580478
         WinHeight=0.075000
         TabOrder=5
         bFocusOnWatch=True
         OnClick=UT2k4MainMenu.ButtonClick
         OnKeyEvent=SettingsButton.InternalOnKeyEvent
     End Object
     b_Settings=GUIButton'GUI2K4.UT2k4MainMenu.SettingsButton'

     Begin Object Class=GUIButton Name=QuitButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Exit UT2004"
         bUseCaptionHeight=True
         FontScale=FNS_Small
         StyleName="TextButton"
         Hint="Exit the game"
         WinTop=0.887567
         WinLeft=0.424711
         WinWidth=0.526767
         WinHeight=0.075000
         TabOrder=6
         bFocusOnWatch=True
         OnClick=UT2k4MainMenu.ButtonClick
         OnKeyEvent=QuitButton.InternalOnKeyEvent
     End Object
     b_Quit=GUIButton'GUI2K4.UT2k4MainMenu.QuitButton'

     CharShots(0)=Texture'2K4Menus.MainMenu.Char01'
     CharShots(1)=Texture'2K4Menus.MainMenu.char02'
     CharShots(2)=Texture'2K4Menus.MainMenu.char03'
     MenuSong="KR-UT2004-Menu"
     NewNewsMsg="  (New Update Available)"
     FireWallTitle="Important"
     FireWallMsg="It has been determined that the Window's Firewall is enabled and that UT2004 is not yet authorized to connect to the internet.  Authorization is required in order to use the online components of the game.  Please refer to the README.TXT for more information."
     bDisconnectOnOpen=True
     bAllowedAsLast=True
     OnOpen=UT2k4MainMenu.InternalOnOpen
     OnReOpen=UT2k4MainMenu.MainReopened
     OnCanClose=UT2k4MainMenu.CanClose
     WinTop=0.000000
     WinHeight=1.000000
     bDebugging=True
     OnKeyEvent=UT2k4MainMenu.MyKeyEvent
}
