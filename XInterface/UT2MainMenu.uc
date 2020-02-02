// ====================================================================
//  Class:  XInterface.UT2MainMenu
//
// 	The Main Menu
//
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class UT2MainMenu extends UT2K3GUIPage;

#exec OBJ LOAD FILE=InterfaceContent.utx

var bool	AllowClose;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	if (PlayerOwner().Level.IsDemoBuild())
	{
		Controls[3].SetFocus(none);
		Controls[2].MenuStateChange(MSAT_Disabled);
	}
}

function OnClose(optional Bool bCanceled)
{
}

function bool MyKeyEvent(out byte Key,out byte State,float delta)
{
	if(Key == 0x1B && State == 1)	// Escape pressed
	{
		AllowClose = true;
		return true;
	}
	else
		return false;
}

function bool CanClose(optional Bool bCanceled)
{
	if(AllowClose)
		Controller.OpenMenu("xinterface.UT2QuitPage");

	return false;
}


function bool ButtonClick(GUIComponent Sender)
{
	if ( Sender==Controls[2] )
		Controller.OpenMenu("xinterface.UT2SinglePlayerMain");
	if ( Sender==Controls[3] )
		Controller.OpenMenu("xinterface.ServerBrowser");
	if ( Sender==Controls[4] )
		Controller.OpenMenu("xinterface.UT2MultiplayerHostPage");
	if ( Sender==Controls[5] )
		Controller.OpenMenu("xinterface.UT2InstantActionPage");
	if ( Sender==Controls[6] )
		Controller.OpenMenu("xinterface.UT2SettingsPage");
	if (Sender==Controls[7] )
		Controller.OpenMenu("xinterface.UT2QuitPage");

	return true;
}

defaultproperties
{
     bDisconnectOnOpen=True
     bAllowedAsLast=True
     Background=Texture'InterfaceContent.Backgrounds.bg10'
     OnCanClose=UT2MainMenu.CanClose
     Begin Object Class=GUIImage Name=ImgUT2Logo
         Image=Texture'InterfaceContent.Logos.Logo'
         ImageStyle=ISTY_Scaled
         WinTop=-0.033854
         WinLeft=0.100000
         WinWidth=0.800000
         WinHeight=0.500000
     End Object
     Controls(0)=GUIImage'XInterface.UT2MainMenu.ImgUT2Logo'

     Begin Object Class=GUIImage Name=ImgUT2Shader
         Image=FinalBlend'InterfaceContent.Logos.fbSymbolShader'
         ImageStyle=ISTY_Scaled
         WinTop=0.223958
         WinLeft=0.399414
         WinWidth=0.198242
         WinHeight=0.132813
     End Object
     Controls(1)=GUIImage'XInterface.UT2MainMenu.ImgUT2Shader'

     Begin Object Class=GUIButton Name=SinglePlayerButton
         Caption="SINGLE PLAYER"
         StyleName="TextButton"
         Hint="Play through the Tournament"
         WinTop=0.438802
         WinLeft=0.250000
         WinWidth=0.500000
         WinHeight=0.075000
         bFocusOnWatch=True
         OnClick=UT2MainMenu.ButtonClick
         OnKeyEvent=SinglePlayerButton.InternalOnKeyEvent
     End Object
     Controls(2)=GUIButton'XInterface.UT2MainMenu.SinglePlayerButton'

     Begin Object Class=GUIButton Name=MultiplayerButton
         Caption="PLAY ON-LINE/LAN"
         StyleName="TextButton"
         Hint="Play with Human Opponents Over the Lan or the Internet"
         WinTop=0.506251
         WinLeft=0.250000
         WinWidth=0.500000
         WinHeight=0.075000
         bFocusOnWatch=True
         OnClick=UT2MainMenu.ButtonClick
         OnKeyEvent=MultiplayerButton.InternalOnKeyEvent
     End Object
     Controls(3)=GUIButton'XInterface.UT2MainMenu.MultiplayerButton'

     Begin Object Class=GUIButton Name=HostButton
         Caption="HOST MULTIPLAYER GAME"
         StyleName="TextButton"
         Hint="Start a server an invite others to join your game"
         WinTop=0.577866
         WinLeft=0.250000
         WinWidth=0.500000
         WinHeight=0.075000
         bFocusOnWatch=True
         OnClick=UT2MainMenu.ButtonClick
         OnKeyEvent=HostButton.InternalOnKeyEvent
     End Object
     Controls(4)=GUIButton'XInterface.UT2MainMenu.HostButton'

     Begin Object Class=GUIButton Name=InstantActionButton
         Caption="INSTANT ACTION"
         StyleName="TextButton"
         Hint="Play a Practice Match"
         WinTop=0.658334
         WinLeft=0.250000
         WinWidth=0.500000
         WinHeight=0.075000
         bFocusOnWatch=True
         OnClick=UT2MainMenu.ButtonClick
         OnKeyEvent=InstantActionButton.InternalOnKeyEvent
     End Object
     Controls(5)=GUIButton'XInterface.UT2MainMenu.InstantActionButton'

     Begin Object Class=GUIButton Name=SettingsButton
         Caption="SETTINGS"
         StyleName="TextButton"
         Hint="Change Your Controls and Settings"
         WinTop=0.733595
         WinLeft=0.250000
         WinWidth=0.500000
         WinHeight=0.075000
         bFocusOnWatch=True
         OnClick=UT2MainMenu.ButtonClick
         OnKeyEvent=SettingsButton.InternalOnKeyEvent
     End Object
     Controls(6)=GUIButton'XInterface.UT2MainMenu.SettingsButton'

     Begin Object Class=GUIButton Name=QuitButton
         Caption="QUIT"
         StyleName="SquareMenuButton"
         Hint="Exit Unreal Tournament 2003"
         WinTop=0.905725
         WinLeft=0.391602
         WinWidth=0.205078
         WinHeight=0.042773
         bFocusOnWatch=True
         OnClick=UT2MainMenu.ButtonClick
         OnKeyEvent=QuitButton.InternalOnKeyEvent
     End Object
     Controls(7)=GUIButton'XInterface.UT2MainMenu.QuitButton'

     WinHeight=1.000000
     OnKeyEvent=UT2MainMenu.MyKeyEvent
}
