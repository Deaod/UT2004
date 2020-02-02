// ====================================================================
//  Class:  XInterface.Tab_DetailSettings
//  Parent: XInterface.GUITabPanel
//
//  <Enter a description here>
// ====================================================================

class Tab_GameSettings extends UT2K3TabPanel;

var localized string	CrosshairNames[15];

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{

	local int i;
	Super.Initcomponent(MyController, MyOwner);

	for (i=0;i<Controls.Length;i++)
		Controls[i].OnChange=InternalOnChange;

	for(i = 0;i < ArrayCount(CrosshairNames);i++)
		moComboBox(Controls[8]).AddItem(CrosshairNames[i]);
	moComboBox(Controls[8]).ReadOnly(true);

	if ( class'GameInfo'.Default.bAlternateMode )
		Controls[4].bVisible = false;



}

function InternalOnLoadINI(GUIComponent Sender, string s)
{

	local int i;

	if (Sender==Controls[2])
		moCheckBox(Sender).Checked(bool(s));

	else if (Sender==Controls[3])
		moCheckBox(Sender).Checked(class'Pawn'.default.bWeaponBob);

	else if (Sender==Controls[4])
		moCheckBox(Sender).Checked(class'GameInfo'.static.UseLowGore());

	else if (Sender==controls[5])
		moCheckBox(Sender).Checked(PlayerOwner().DodgingIsEnabled());

	else if (Sender==Controls[6])
		moCheckBox(Sender).Checked(class'GameInfo'.default.AutoAim > 0);

	else if (Sender==Controls[7])
		moCheckBox(Sender).Checked(class'xGame.xDeathMessage'.default.bNoConsoleDeathMessages);

	else if (Sender==Controls[8])
	{

		if (!class'HUD'.default.bCrosshairShow )
			i = 0;
		else
			i = class'HUD'.default.CrosshairStyle +1;

		moComboBox(Sender).SetText(CrosshairNames[i]);
		SetCrossHairGraphic(i);
	}

    else if (Sender==Controls[12])
    	GUISlider(Sender).Value = Class'HUD'.Default.CrossHairColor.R;

    else if (Sender==Controls[14])
    	GUISlider(Sender).Value = Class'HUD'.Default.CrossHairColor.G;

    else if (Sender==Controls[16])
    	GUISlider(Sender).Value = Class'HUD'.Default.CrossHairColor.B;

    else if (Sender==Controls[18])
    {
    	GUISlider(Sender).Value = Class'HUD'.Default.CrossHairColor.A;
        GUIImage(Controls[9]).ImageColor=PlayerOwner().MyHud.CrossHairColor;
    }


}

function string InternalOnSaveINI(GUIComponent Sender); 		// Do the actual work here

function InternalOnChange(GUIComponent Sender)
{
	local bool b;

	if (!Controller.bCurMenuInitialized)
		return;

	if (Sender==Controls[2])
		PlayerOwner().ConsoleCommand("set"@Sender.INIOption@moCheckBox(Sender).IsChecked());

	else if (Sender==Controls[3])
	{
		PlayerOwner().ConsoleCommand("set Pawn bWeaponBob "$moCheckBox(Sender).IsChecked());
		class'Pawn'.default.bWeaponBob = moCheckBox(Sender).IsChecked();
		class'Pawn'.static.StaticSaveConfig();
	}

	else if (Sender==Controls[4])
	{
		class'GameInfo'.default.bLowGore = moCheckBox(Sender).IsChecked();
		class'GameInfo'.static.StaticSaveConfig();
	}

	else if (Sender==controls[5])
	{
		if( !moCheckBox(Sender).IsChecked() )
			PlayerOwner().SetDodging( false );
		else
			PlayerOwner().SetDodging( true );
	}

	else if (Sender==Controls[6])
	{
		if ( moCheckBox(Sender).IsChecked() )
			class'GameInfo'.Default.AutoAim = 0.5;
		else
			class'GameInfo'.Default.AutoAim = 0;

		class'GameInfo'.static.StaticSaveConfig();
	}

 	else if (Sender==Controls[7])
	{
		Log("xgame bNoConsoleDeathMessages was="$class'xgame.xdeathmessage'.default.bNoConsoleDeathMessages);
		b = moCheckBox(Sender).IsChecked();
		class'XGame.xDeathMessage'.default.bNoConsoleDeathMessages=b;
		Log("xgame bNoConsoleDeathMessages now="$class'xgame.xdeathmessage'.default.bNoConsoleDeathMessages);
		class'XGame.xDeathMessage'.static.StaticSaveConfig();
		Log("xgame bNoConsoleDeathMessages then="$class'xgame.xdeathmessage'.default.bNoConsoleDeathMessages);
	}

    else if (Sender==Controls[8])
	{
		SetCrossHairGraphic(moComboBox(Sender).GetIndex());

		if (moComboBox(Sender).GetText() == "Hidden")
		{
			PlayerOwner().MyHud.bCrosshairShow = false;
			PlayerOwner().MyHud.SaveConfig();

			return;
		}

		PlayerOwner().MyHud.bCrosshairShow = true;
		PlayerOwner().MyHud.CrosshairStyle = moComboBox(Sender).GetIndex()-1;
		PlayerOwner().MyHud.SaveConfig();
	}


   else if (Sender==Controls[12])
   {
   		PlayerOwner().MyHud.CrossHairColor.R = GUISlider(Sender).Value;
        PlayerOwner().MyHud.SaveConfig();
        GUIImage(Controls[9]).ImageColor=PlayerOwner().MyHud.CrossHairColor;
   }

    else if (Sender==Controls[14])
   {
   		PlayerOwner().MyHud.CrossHairColor.G = GUISlider(Sender).Value;
        PlayerOwner().MyHud.SaveConfig();
        GUIImage(Controls[9]).ImageColor=PlayerOwner().MyHud.CrossHairColor;
   }

    else if (Sender==Controls[16])
   {
   		PlayerOwner().MyHud.CrossHairColor.B = GUISlider(Sender).Value;
        PlayerOwner().MyHud.SaveConfig();
        GUIImage(Controls[9]).ImageColor=PlayerOwner().MyHud.CrossHairColor;
   }

    else if (Sender==Controls[18])
   {
   		PlayerOwner().MyHud.CrossHairColor.A = GUISlider(Sender).Value;
        PlayerOwner().MyHud.SaveConfig();
        GUIImage(Controls[9]).ImageColor=PlayerOwner().MyHud.CrossHairColor;
   }

}

function SetCrossHairGraphic(int Index)
{
	local GUIImage img;

	Img = GUIImage(Controls[9]);

	Img.Image = class'HudBDeathMatch'.default.Crosshairs[Index - 1].WidgetTexture;
	Img.bVisible = (Index!=0);

}

defaultproperties
{
     CrosshairNames(0)="Hidden"
     CrosshairNames(1)="Cross (1)"
     CrosshairNames(2)="Cross (2)"
     CrosshairNames(3)="Cross (3)"
     CrosshairNames(4)="Cross (4)"
     CrosshairNames(5)="Cross (5)"
     CrosshairNames(6)="Dot"
     CrosshairNames(7)="Pointer"
     CrosshairNames(8)="Triad (1)"
     CrosshairNames(9)="Triad (2)"
     CrosshairNames(10)="Triad (3)"
     CrosshairNames(11)="Bracket (1)"
     CrosshairNames(12)="Bracket (2)"
     CrosshairNames(13)="Circle (1)"
     CrosshairNames(14)="Circle (2)"
     Begin Object Class=GUIImage Name=GameBK
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.130208
         WinLeft=0.029297
         WinWidth=0.427148
         WinHeight=0.803125
     End Object
     Controls(0)=GUIImage'XInterface.Tab_GameSettings.GameBK'

     Begin Object Class=GUIImage Name=GameBK1
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.130208
         WinLeft=0.517578
         WinWidth=0.448633
         WinHeight=0.803125
     End Object
     Controls(1)=GUIImage'XInterface.Tab_GameSettings.GameBK1'

     Begin Object Class=moCheckBox Name=GameScreenFlashes
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Screen Flashes"
         OnCreateComponent=GameScreenFlashes.InternalOnCreateComponent
         IniOption="ini:Engine.Engine.ViewportManager ScreenFlashes"
         Hint="Turn this option off to disable screen flashes when you take damage."
         WinTop=0.168385
         WinLeft=0.050000
         WinWidth=0.400000
         WinHeight=0.040000
         OnLoadINI=Tab_GameSettings.InternalOnLoadINI
     End Object
     Controls(2)=moCheckBox'XInterface.Tab_GameSettings.GameScreenFlashes'

     Begin Object Class=moCheckBox Name=GameWeaponBob
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Weapon Bob"
         OnCreateComponent=GameWeaponBob.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Prevent your weapon from bobbing up and down while moving."
         WinTop=0.290780
         WinLeft=0.050000
         WinWidth=0.400000
         WinHeight=0.040000
         OnLoadINI=Tab_GameSettings.InternalOnLoadINI
     End Object
     Controls(3)=moCheckBox'XInterface.Tab_GameSettings.GameWeaponBob'

     Begin Object Class=moCheckBox Name=GameReduceGore
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Reduce Gore"
         OnCreateComponent=GameReduceGore.InternalOnCreateComponent
         IniOption="ini:Engine.Engine.AudioDevice ReverseStereo"
         Hint="Turn this option On to reduce the amount of blood and guts you see."
         WinTop=0.415521
         WinLeft=0.050000
         WinWidth=0.400000
         WinHeight=0.040000
         OnLoadINI=Tab_GameSettings.InternalOnLoadINI
     End Object
     Controls(4)=moCheckBox'XInterface.Tab_GameSettings.GameReduceGore'

     Begin Object Class=moCheckBox Name=GameDodging
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Dodging"
         OnCreateComponent=GameDodging.InternalOnCreateComponent
         IniOption="ini:Engine.Engine.AudioDevice ReverseStereo"
         Hint="Turn this option off to disable special dodge moves."
         WinTop=0.541563
         WinLeft=0.050000
         WinWidth=0.400000
         WinHeight=0.040000
         OnLoadINI=Tab_GameSettings.InternalOnLoadINI
     End Object
     Controls(5)=moCheckBox'XInterface.Tab_GameSettings.GameDodging'

     Begin Object Class=moCheckBox Name=GameAutoAim
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Auto Aim"
         OnCreateComponent=GameAutoAim.InternalOnCreateComponent
         IniOption="ini:Engine.Engine.AudioDevice ReverseStereo"
         Hint="Turn this option on to have UT2004 help you aim (not available in Multiplayer)."
         WinTop=0.692344
         WinLeft=0.050000
         WinWidth=0.400000
         WinHeight=0.040000
         OnLoadINI=Tab_GameSettings.InternalOnLoadINI
     End Object
     Controls(6)=moCheckBox'XInterface.Tab_GameSettings.GameAutoAim'

     Begin Object Class=moCheckBox Name=GameDeathMsgs
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="No Console Death Messages"
         OnCreateComponent=GameDeathMsgs.InternalOnCreateComponent
         IniOption="ini:Engine.XGame.xDeathMessage bNoConsoleDeathMessages"
         IniDefault="False"
         Hint="Turn off reporting of death messages in console"
         WinTop=0.832553
         WinLeft=0.047460
         WinWidth=0.403711
         WinHeight=0.040000
         OnLoadINI=Tab_GameSettings.InternalOnLoadINI
     End Object
     Controls(7)=moCheckBox'XInterface.Tab_GameSettings.GameDeathMsgs'

     Begin Object Class=moComboBox Name=GameCrossHair
         ComponentJustification=TXTA_Left
         CaptionWidth=0.300000
         Caption="Crosshair"
         OnCreateComponent=GameCrossHair.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Please select your crosshair!"
         WinTop=0.186719
         WinLeft=0.552148
         WinWidth=0.383398
         WinHeight=0.060000
         OnLoadINI=Tab_GameSettings.InternalOnLoadINI
     End Object
     Controls(8)=moComboBox'XInterface.Tab_GameSettings.GameCrossHair'

     Begin Object Class=GUIImage Name=GameCrossHairImage
         ImageAlign=IMGA_Center
         X1=0
         Y1=0
         X2=64
         Y2=64
         WinTop=0.817969
         WinLeft=0.744334
         WinWidth=0.055273
         WinHeight=0.060000
     End Object
     Controls(9)=GUIImage'XInterface.Tab_GameSettings.GameCrossHairImage'

     Begin Object Class=GUIImage Name=CrosshairBK
         Image=Texture'InterfaceContent.Menu.BorderBoxA'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.741667
         WinLeft=0.699062
         WinWidth=0.090000
         WinHeight=0.150000
     End Object
     Controls(10)=GUIImage'XInterface.Tab_GameSettings.CrosshairBK'

     Begin Object Class=GUILabel Name=GameHudCrossHairRLabel
         Caption="Red:"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.306250
         WinLeft=0.610353
         WinWidth=0.081251
         WinHeight=32.000000
     End Object
     Controls(11)=GUILabel'XInterface.Tab_GameSettings.GameHudCrossHairRLabel'

     Begin Object Class=GUISlider Name=GameHudCrossHairR
         MaxValue=255.000000
         bIntSlider=True
         IniOption="@Internal"
         Hint="Changes the color of your crosshair."
         WinTop=0.333228
         WinLeft=0.678126
         WinWidth=0.214062
         OnClick=GameHudCrossHairR.InternalOnClick
         OnMousePressed=GameHudCrossHairR.InternalOnMousePressed
         OnMouseRelease=GameHudCrossHairR.InternalOnMouseRelease
         OnKeyEvent=GameHudCrossHairR.InternalOnKeyEvent
         OnCapturedMouseMove=GameHudCrossHairR.InternalCapturedMouseMove
         OnLoadINI=Tab_GameSettings.InternalOnLoadINI
     End Object
     Controls(12)=GUISlider'XInterface.Tab_GameSettings.GameHudCrossHairR'

     Begin Object Class=GUILabel Name=GameHudCrossHairGLabel
         Caption="Green:"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.408333
         WinLeft=0.580664
         WinWidth=0.120313
         WinHeight=32.000000
     End Object
     Controls(13)=GUILabel'XInterface.Tab_GameSettings.GameHudCrossHairGLabel'

     Begin Object Class=GUISlider Name=GameHudCrossHairG
         MaxValue=255.000000
         bIntSlider=True
         IniOption="@Internal"
         Hint="Changes the color of your crosshair."
         WinTop=0.437395
         WinLeft=0.678126
         WinWidth=0.214062
         OnClick=GameHudCrossHairG.InternalOnClick
         OnMousePressed=GameHudCrossHairG.InternalOnMousePressed
         OnMouseRelease=GameHudCrossHairG.InternalOnMouseRelease
         OnKeyEvent=GameHudCrossHairG.InternalOnKeyEvent
         OnCapturedMouseMove=GameHudCrossHairG.InternalCapturedMouseMove
         OnLoadINI=Tab_GameSettings.InternalOnLoadINI
     End Object
     Controls(14)=GUISlider'XInterface.Tab_GameSettings.GameHudCrossHairG'

     Begin Object Class=GUILabel Name=GameHudCrossHairBLabel
         Caption="Blue:"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.514583
         WinLeft=0.599414
         WinWidth=0.096876
         WinHeight=32.000000
     End Object
     Controls(15)=GUILabel'XInterface.Tab_GameSettings.GameHudCrossHairBLabel'

     Begin Object Class=GUISlider Name=GameHudCrossHairB
         MaxValue=255.000000
         bIntSlider=True
         IniOption="@Internal"
         Hint="Changes the color of your crosshair."
         WinTop=0.541562
         WinLeft=0.678126
         WinWidth=0.214062
         OnClick=GameHudCrossHairB.InternalOnClick
         OnMousePressed=GameHudCrossHairB.InternalOnMousePressed
         OnMouseRelease=GameHudCrossHairB.InternalOnMouseRelease
         OnKeyEvent=GameHudCrossHairB.InternalOnKeyEvent
         OnCapturedMouseMove=GameHudCrossHairB.InternalCapturedMouseMove
         OnLoadINI=Tab_GameSettings.InternalOnLoadINI
     End Object
     Controls(16)=GUISlider'XInterface.Tab_GameSettings.GameHudCrossHairB'

     Begin Object Class=GUILabel Name=GameHudCrossHairALabel
         Caption="Opacity:"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.616667
         WinLeft=0.571289
         WinWidth=0.120313
         WinHeight=32.000000
     End Object
     Controls(17)=GUILabel'XInterface.Tab_GameSettings.GameHudCrossHairALabel'

     Begin Object Class=GUISlider Name=GameHudCrossHairA
         MaxValue=255.000000
         bIntSlider=True
         IniOption="@Internal"
         Hint="Changes the color of your crosshair."
         WinTop=0.645729
         WinLeft=0.678126
         WinWidth=0.214062
         OnClick=GameHudCrossHairA.InternalOnClick
         OnMousePressed=GameHudCrossHairA.InternalOnMousePressed
         OnMouseRelease=GameHudCrossHairA.InternalOnMouseRelease
         OnKeyEvent=GameHudCrossHairA.InternalOnKeyEvent
         OnCapturedMouseMove=GameHudCrossHairA.InternalCapturedMouseMove
         OnLoadINI=Tab_GameSettings.InternalOnLoadINI
     End Object
     Controls(18)=GUISlider'XInterface.Tab_GameSettings.GameHudCrossHairA'

     WinTop=0.150000
     WinHeight=0.740000
}
