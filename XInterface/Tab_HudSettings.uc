// ====================================================================
//  Class:  XInterface.Tab_DetailSettings
//  Parent: XInterface.GUITabPanel
//
//  <Enter a description here>
// ====================================================================

class Tab_HudSettings extends UT2K3TabPanel;

var localized string	CrosshairNames[15];

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{

	local int i;
	Super.Initcomponent(MyController, MyOwner);

	for (i=0;i<Controls.Length;i++)
		Controls[i].OnChange=InternalOnChange;
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{

	if (Sender==Controls[2])
    	moCheckBox(Sender).Checked(class'HUD'.Default.bHideHud);

	else if (Sender==Controls[3])
    	moCheckBox(Sender).Checked(class'HUD'.Default.bShowWeaponInfo);

    else if (Sender==Controls[4])
    	moCheckBox(Sender).Checked(class'HUD'.Default.bShowPersonalInfo);

    else if (Sender==Controls[5])
    	moCheckBox(Sender).Checked(Class'HUD'.Default.bShowPoints);

    else if (Sender==Controls[6])
    	moCheckBox(Sender).Checked(Class'HUD'.Default.bShowWeaponBar);

    else if (Sender==Controls[7])
    	moCheckBox(Sender).Checked(Class'HUD'.Default.bShowPortrait);

	else if (Sender==Controls[15])
    	moCheckBox(Sender).Checked(!Class'HUD'.Default.bNoEnemyNames);

    else if (Sender==Controls[8])
    	moNumericEdit(Sender).SetValue(Class'HUD'.DEfault.ConsoleMessageCount);

    else if (Sender==Controls[9])
    	moNumericEdit(Sender).SetValue(8-Class'HUD'.Default.ConsoleFontSize);

    else if (Sender==Controls[10])
    	moNumericEdit(Sender).SetValue(Class'HUD'.Default.MessageFontOffset+4);

    else if (Sender==Controls[12])
     	GUISlider(Sender).Value = Class'HUD'.Default.HudScale*100;

    else if (Sender==Controls[14])
   		GUISlider(Sender).Value = (Class'HUD'.Default.HudOpacity/255)*100;
}

function string InternalOnSaveINI(GUIComponent Sender); 		// Do the actual work here

function InternalOnChange(GUIComponent Sender)
{
	if (!Controller.bCurMenuInitialized)
		return;

	if (Sender==Controls[2])
    	PlayerOwner().MyHud.bHideHud = moCheckBox(Sender).IsChecked();

	else if (Sender==Controls[3])
		PlayerOwner().MyHud.bShowWeaponInfo = moCheckBox(Sender).IsChecked();

	else if (Sender==Controls[4])
		PlayerOwner().MyHud.bShowPersonalInfo = moCheckBox(Sender).IsChecked();

	else if (Sender==Controls[5])
		PlayerOwner().MyHud.bShowPoints = moCheckBox(Sender).IsChecked();

	else if (Sender==Controls[6])
		PlayerOwner().MyHud.bShowWeaponBar = moCheckBox(Sender).IsChecked();

	else if (Sender==Controls[7])
		PlayerOwner().MyHud.bShowPortrait = moCheckBox(Sender).IsChecked();

	else if (Sender==Controls[15])
    	PlayerOwner().MyHud.bNoEnemyNames = !moCheckBox(Sender).Ischecked();

	else if (Sender==Controls[8])
		PlayerOwner().MyHud.ConsoleMessageCount = moNumericEdit(Sender).GetValue();

	else if (Sender==Controls[9])
		PlayerOwner().MyHud.ConsoleFontSize = abs(moNumericEdit(Sender).GetValue()-8);

	else if (Sender==Controls[10])
		PlayerOwner().MyHud.MessageFontOffset = moNumericEdit(Sender).GetValue()-4;

	else if (Sender==Controls[12])
		PlayerOwner().MyHud.HudScale = GUISlider(Sender).Value / 100;

	else if (Sender==Controls[14])
		PlayerOwner().MyHud.HudOpacity = (GUISlider(Sender).Value/100) * 255;

	PlayerOwner().MyHud.SaveConfig();

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
     Controls(0)=GUIImage'XInterface.Tab_HudSettings.GameBK'

     Begin Object Class=GUIImage Name=GameBK1
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.130208
         WinLeft=0.517578
         WinWidth=0.448633
         WinHeight=0.803125
     End Object
     Controls(1)=GUIImage'XInterface.Tab_HudSettings.GameBK1'

     Begin Object Class=moCheckBox Name=GameHudVisible
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Hide HUD"
         OnCreateComponent=GameHudVisible.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="This option will toggle drawing of the HUD."
         WinTop=0.043906
         WinLeft=0.379297
         WinWidth=0.196875
         WinHeight=0.040000
         OnLoadINI=Tab_HudSettings.InternalOnLoadINI
     End Object
     Controls(2)=moCheckBox'XInterface.Tab_HudSettings.GameHudVisible'

     Begin Object Class=moCheckBox Name=GameHudShowWeaponInfo
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Show Weapon Info"
         OnCreateComponent=GameHudShowWeaponInfo.InternalOnCreateComponent
         IniOption="@Internal"
         WinTop=0.181927
         WinLeft=0.050000
         WinWidth=0.378125
         WinHeight=0.040000
         OnLoadINI=Tab_HudSettings.InternalOnLoadINI
     End Object
     Controls(3)=moCheckBox'XInterface.Tab_HudSettings.GameHudShowWeaponInfo'

     Begin Object Class=moCheckBox Name=GameHudShowPersonalInfo
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Show Personal Info"
         OnCreateComponent=GameHudShowPersonalInfo.InternalOnCreateComponent
         IniOption="@Internal"
         WinTop=0.317343
         WinLeft=0.050000
         WinWidth=0.378125
         WinHeight=0.040000
         OnLoadINI=Tab_HudSettings.InternalOnLoadINI
     End Object
     Controls(4)=moCheckBox'XInterface.Tab_HudSettings.GameHudShowPersonalInfo'

     Begin Object Class=moCheckBox Name=GameHudShowScore
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Show Score"
         OnCreateComponent=GameHudShowScore.InternalOnCreateComponent
         IniOption="@Internal"
         WinTop=0.452760
         WinLeft=0.050000
         WinWidth=0.378125
         WinHeight=0.040000
         OnLoadINI=Tab_HudSettings.InternalOnLoadINI
     End Object
     Controls(5)=moCheckBox'XInterface.Tab_HudSettings.GameHudShowScore'

     Begin Object Class=moCheckBox Name=GameHudShowWeaponBar
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Show Weapon Bar"
         OnCreateComponent=GameHudShowWeaponBar.InternalOnCreateComponent
         IniOption="@Internal"
         WinTop=0.598593
         WinLeft=0.050000
         WinWidth=0.378125
         WinHeight=0.040000
         OnLoadINI=Tab_HudSettings.InternalOnLoadINI
     End Object
     Controls(6)=moCheckBox'XInterface.Tab_HudSettings.GameHudShowWeaponBar'

     Begin Object Class=moCheckBox Name=GameHudShowPortraits
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Show Portraits"
         OnCreateComponent=GameHudShowPortraits.InternalOnCreateComponent
         IniOption="@Internal"
         WinTop=0.723594
         WinLeft=0.050000
         WinWidth=0.378125
         WinHeight=0.040000
         OnLoadINI=Tab_HudSettings.InternalOnLoadINI
     End Object
     Controls(7)=moCheckBox'XInterface.Tab_HudSettings.GameHudShowPortraits'

     Begin Object Class=moNumericEdit Name=GameHudMessageCount
         MinValue=0
         MaxValue=8
         ComponentJustification=TXTA_Left
         CaptionWidth=0.700000
         Caption="Max. Chat Count"
         OnCreateComponent=GameHudMessageCount.InternalOnCreateComponent
         IniOption="@Internal"
         WinTop=0.196875
         WinLeft=0.550781
         WinWidth=0.381250
         WinHeight=0.060000
         OnLoadINI=Tab_HudSettings.InternalOnLoadINI
     End Object
     Controls(8)=moNumericEdit'XInterface.Tab_HudSettings.GameHudMessageCount'

     Begin Object Class=moNumericEdit Name=GameHudMessageScale
         MinValue=0
         MaxValue=8
         ComponentJustification=TXTA_Left
         CaptionWidth=0.700000
         Caption="Chat Font Size"
         OnCreateComponent=GameHudMessageScale.InternalOnCreateComponent
         IniOption="@Internal"
         WinTop=0.321874
         WinLeft=0.550781
         WinWidth=0.381250
         WinHeight=0.060000
         OnLoadINI=Tab_HudSettings.InternalOnLoadINI
     End Object
     Controls(9)=moNumericEdit'XInterface.Tab_HudSettings.GameHudMessageScale'

     Begin Object Class=moNumericEdit Name=GameHudMessageOffset
         MinValue=0
         MaxValue=4
         ComponentJustification=TXTA_Left
         CaptionWidth=0.700000
         Caption="Message Font Size"
         OnCreateComponent=GameHudMessageOffset.InternalOnCreateComponent
         IniOption="@Internal"
         WinTop=0.436457
         WinLeft=0.550781
         WinWidth=0.381250
         WinHeight=0.060000
         OnLoadINI=Tab_HudSettings.InternalOnLoadINI
     End Object
     Controls(10)=moNumericEdit'XInterface.Tab_HudSettings.GameHudMessageOffset'

     Begin Object Class=GUILabel Name=GameHudScaleLabel
         Caption="HUD Scaling"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.560417
         WinLeft=0.516602
         WinWidth=0.448438
         WinHeight=32.000000
     End Object
     Controls(11)=GUILabel'XInterface.Tab_HudSettings.GameHudScaleLabel'

     Begin Object Class=GUISlider Name=GameHudScale
         MinValue=50.000000
         IniOption="@Internal"
         Hint="Changes the opacity level of the HUD."
         WinTop=0.635312
         WinLeft=0.590626
         WinWidth=0.292187
         OnClick=GameHudScale.InternalOnClick
         OnMousePressed=GameHudScale.InternalOnMousePressed
         OnMouseRelease=GameHudScale.InternalOnMouseRelease
         OnKeyEvent=GameHudScale.InternalOnKeyEvent
         OnCapturedMouseMove=GameHudScale.InternalCapturedMouseMove
         OnLoadINI=Tab_HudSettings.InternalOnLoadINI
     End Object
     Controls(12)=GUISlider'XInterface.Tab_HudSettings.GameHudScale'

     Begin Object Class=GUILabel Name=GameHudOpacityLabel
         Caption="HUD Opacity"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.737500
         WinLeft=0.516602
         WinWidth=0.448438
         WinHeight=32.000000
     End Object
     Controls(13)=GUILabel'XInterface.Tab_HudSettings.GameHudOpacityLabel'

     Begin Object Class=GUISlider Name=GameHudOpacity
         IniOption="@Internal"
         Hint="Changes the opacity level of the HUD."
         WinTop=0.808230
         WinLeft=0.592189
         WinWidth=0.290625
         OnClick=GameHudOpacity.InternalOnClick
         OnMousePressed=GameHudOpacity.InternalOnMousePressed
         OnMouseRelease=GameHudOpacity.InternalOnMouseRelease
         OnKeyEvent=GameHudOpacity.InternalOnKeyEvent
         OnCapturedMouseMove=GameHudOpacity.InternalCapturedMouseMove
         OnLoadINI=Tab_HudSettings.InternalOnLoadINI
     End Object
     Controls(14)=GUISlider'XInterface.Tab_HudSettings.GameHudOpacity'

     Begin Object Class=moCheckBox Name=GameHudShowEnemyNames
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Show Enemy Names"
         OnCreateComponent=GameHudShowEnemyNames.InternalOnCreateComponent
         IniOption="@Internal"
         WinTop=0.848594
         WinLeft=0.050000
         WinWidth=0.378125
         WinHeight=0.040000
         OnLoadINI=Tab_HudSettings.InternalOnLoadINI
     End Object
     Controls(15)=moCheckBox'XInterface.Tab_HudSettings.GameHudShowEnemyNames'

     WinTop=0.150000
     WinHeight=0.740000
}
