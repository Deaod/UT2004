//==============================================================================
//	Created on: 07/10/03
//	HUD Configuration Menu
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================

class UT2K4Tab_HudSettings extends Settings_Tabs;

var automated GUISectionBackground i_BG1, i_BG2;
var automated GUIImage	i_Scale, i_PreviewBG, i_Preview;
var automated moSlider	sl_Scale, sl_Opacity, sl_Red, sl_Green, sl_Blue;
var automated moNumericEdit	nu_MsgCount, nu_MsgScale, nu_MsgOffset;
var automated moCheckBox	ch_Visible, ch_Weapons, ch_Personal, ch_Score, ch_WeaponBar,
							ch_Portraits,  ch_VCPortraits, ch_DeathMsgs, ch_EnemyNames, ch_CustomColor;


var automated GUIComboBox co_CustomHUD;
var automated GUIButton b_CustomHUD;

var() bool bVis, bWeapons, bPersonal, bScore, bPortraits, bVCPortraits, bNames, bCustomColor, bNoMsgs, bWeaponBar;
var() int iCount, iScale, iOffset;
var() float fScale, fOpacity;
var() color cCustom;

var() floatbox DefaultBGPos, DefaultHealthPos;

var array<CacheManager.GameRecord> Games;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;

	Super.InitComponent(MyController, MyOwner);

	class'CacheManager'.static.GetGameTypeList( Games );
	for ( i = 0; i < Games.Length; i++ )
	{
		if ( Games[i].HUDMenu != "" )
			co_CustomHUD.AddItem( Games[i].GameName, , string(i) );
	}

	if ( co_CustomHUD.ItemCount() == 0 )
	{
		RemoveComponent(co_CustomHUD);
		RemoveComponent(b_CustomHUD);
	}

	i_BG1.ManageComponent(ch_Visible);
    i_BG1.ManageComponent(ch_EnemyNames);
    i_BG1.ManageComponent(ch_WeaponBar);
    i_BG1.ManageComponent(ch_Weapons);
    i_BG1.ManageComponent(ch_Personal);
    i_BG1.ManageComponent(ch_Score);
    i_BG1.ManageComponent(ch_Portraits);
    i_BG1.ManageComponent(ch_VCPortraits);
    i_BG1.ManageComponent(ch_DeathMsgs);
    i_BG1.ManageComponent(nu_MsgCount);
    i_BG1.ManageComponent(nu_MsgScale);
    i_BG1.ManageComponent(nu_MsgOffset);

    sl_Opacity.MySlider.bDrawPercentSign = True;
    sl_Scale.MySlider.bDrawPercentSign = True;
}

function bool InternalOnClick(GUIComponent Sender)
{
	local int i;

	if ( Sender == b_CustomHUD )
	{
		i = int(co_CustomHUD.GetExtra());

		Controller.OpenMenu(Games[i].HUDMenu,Games[i].ClassName);
	}

	return true;
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
	local HUD H;

	H = PlayerOwner().myHUD;
	switch (Sender)
	{
    case ch_DeathMsgs:
        bNoMsgs = class'XGame.xDeathMessage'.default.bNoConsoleDeathMessages;
        ch_DeathMsgs.SetComponentValue(bNoMsgs,true);
        break;

	case ch_Visible:
		bVis = H.bHideHUD;
		ch_Visible.SetComponentValue(bVis,true);
		break;

	case ch_Weapons:
		bWeapons = H.bShowWeaponInfo;
		ch_Weapons.SetComponentValue(bWeapons,true);
		break;

	case ch_Personal:
		bPersonal = H.bShowPersonalInfo;
		ch_Personal.SetComponentValue(bPersonal,true);
		break;

	case ch_Score:
		bScore = H.bShowPoints;
		ch_Score.SetComponentValue(bScore,true);
		break;

	case ch_WeaponBar:
		bWeaponBar = H.bShowWeaponBar;
		ch_WeaponBar.SetComponentValue(bWeaponBar,true);
		break;

	case ch_Portraits:
		bPortraits = H.bShowPortrait;
		ch_Portraits.SetComponentValue(bPortraits,true);
		break;

	case ch_EnemyNames:
		bNames = !H.bNoEnemyNames;
		ch_EnemyNames.SetComponentValue(bNames,true);
		break;

	case nu_MsgCount:
		iCount = H.ConsoleMessageCount;
		nu_MsgCount.SetComponentValue(iCount,true);
		break;

	case nu_MsgScale:
		iScale = 8 - H.ConsoleFontSize;
		nu_MsgScale.SetComponentValue(iScale,true);
		break;

	case nu_MsgOffset:
		iOffset = H.MessageFontOffset+4;
		nu_MsgOffset.SetComponentValue(iOffset,true);
		break;

	case ch_CustomColor:
		bCustomColor = UsingCustomColor();
		ch_CustomColor.SetComponentValue(bCustomColor,true);
		InitializeHUDColor();
		break;

	case ch_VCPortraits:
		bVCPortraits = H.bShowPortraitVC;
		ch_VCPortraits.SetComponentValue(bVCPortraits,true);
		break;

	default:
		log(Name@"Unknown component calling LoadINI:"$ GUIMenuOption(Sender).Caption);
		GUIMenuOption(Sender).SetComponentValue(s,true);
	}
}

function InitializeHUDColor()
{
	if (bCustomColor)
		cCustom = class'HudBase'.default.CustomHUDColor;

	else
	{	cCustom = GetDefaultColor();
		sl_Red.DisableMe();
		sl_Blue.DisableMe();
		sl_Green.DisableMe();
	}

	fScale = PlayerOwner().myHUD.HudScale * 100;
	fOpacity = (PlayerOwner().myHUD.HudOpacity / 255) * 100;

	sl_Scale.SetValue(fScale);
	sl_Opacity.SetValue(fOpacity);

	sl_Red.SetValue(cCustom.R);
	sl_Blue.SetValue(cCustom.B);
	sl_Green.SetValue(cCustom.G);


	UpdatePreviewColor();
}

function bool UsingCustomColor()
{
	if ( PlayerOwner() != None && PlayerOwner().myHUD != None && HudBase(PlayerOwner().myHUD) != None )
		return HudBase(PlayerOwner().myHUD).bUsingCustomHUDColor;

	return
	class'HudBase'.default.CustomHUDColor.R != 0 ||
	class'HudBase'.default.CustomHUDColor.B != 0 ||
	class'HudBase'.default.CustomHUDColor.G != 0 ||
	class'HudBase'.default.CustomHUDColor.A != 0;
}

function color GetDefaultColor()
{
	local int i;
	local PlayerController PC;

	PC = PlayerOwner();
	if (PC.PlayerReplicationInfo == None || PC.PlayerReplicationInfo.Team == None)
		i = int(PC.GetUrlOption("Team"));
	else i = PC.PlayerReplicationInfo.Team.TeamIndex;

	if (HudBase(PC.myHUD) != None)
		return HudBase(PC.myHUD).GetTeamColor(i);

	return class'HudBase'.static.GetTeamColor(i);
}

function SaveSettings()
{
	local PlayerController PC;
	local HUD H;
	local bool bSave;

	Super.SaveSettings();
	PC = PlayerOwner();
	H = PC.myHUD;

	if ( H.bHideHud != bVis )
	{
		H.bHideHUD = bVis;
		bSave = True;
	}

	if ( H.bShowWeaponInfo != bWeapons )
	{
		H.bShowWeaponInfo = bWeapons;
		bSave = True;
	}

	if ( H.bShowPersonalInfo != bPersonal )
	{
		H.bShowPersonalInfo = bPersonal;
		bSave = True;
	}

	if ( H.bShowPoints != bScore )
	{
		H.bShowPoints = bScore;
		bSave = True;
	}

	if ( H.bShowWeaponBar != bWeaponBar)
	{
		H.bShowWeaponBar = bWeaponBar;
		bSave = True;
	}

	if ( H.bShowPortrait != bPortraits )
	{
		H.bShowPortrait = bPortraits;
		bSave = True;
	}

	if ( H.bShowPortraitVC != bVCPortraits )
	{
		H.bShowPortraitVC = bVCPortraits;
		bSave = True;
	}

	if ( H.bNoEnemyNames == bNames )
	{
		H.bNoEnemyNames = !bNames;
		bSave = True;
	}

	if ( H.ConsoleMessageCount != iCount )
	{
		H.ConsoleMessageCount = iCount;
		bSave = True;
	}

	if ( H.ConsoleFontSize != Abs(iScale - 8) )
	{
		H.ConsoleFontSize = Abs(iScale - 8);
		bSave = True;
	}

	if ( H.MessageFontOffset != iOffset - 4 )
	{
		H.MessageFontOffset = iOffset - 4;
		bSave = True;
	}

	if ( H.HudScale != fScale / 100.0 )
	{
		H.HudScale = fScale / 100.0;
		bSave = True;
	}

	if ( H.HudOpacity != (fOpacity / 100.0) * 255.0 )
	{
		H.HudOpacity = (fOpacity / 100.0) * 255.0;
		bSave = True;
	}

	if ( HudBase(H) != None )
	{
		if ( SaveCustomHUDColor() || bSave )
			H.SaveConfig();
	}

	else
	{
		if ( bSave )
			H.SaveConfig();

		SaveCustomHUDColor();
	}

    if ( class'XGame.xDeathMessage'.default.bNoConsoleDeathMessages != bNoMsgs )
    {
		class'XGame.xDeathMessage'.default.bNoConsoleDeathMessages = bNoMsgs;
		class'XGame.xDeathMessage'.static.StaticSaveConfig();
	}
}

function ResetClicked()
{
	local int i;

	Super.ResetClicked();

	class'HUD'.static.ResetConfig("bHideHUD");
	class'HUD'.static.ResetConfig("bShowWeaponInfo");
	class'HUD'.static.ResetConfig("bShowPersonalInfo");
	class'HUD'.static.ResetConfig("bShowPoints");
	class'HUD'.static.ResetConfig("bShowWeaponBar");
	class'HUD'.static.ResetConfig("bShowPortrait");
	class'HUD'.static.ResetConfig("bShowPortraitVC");
	class'HUD'.static.ResetConfig("bNoEnemyNames");
	class'HUD'.static.ResetConfig("ConsoleMessageCount");
	class'HUD'.static.ResetConfig("ConsoleFontSize");
	class'HUD'.static.ResetConfig("MessageFontOffset");
	class'HUD'.static.ResetConfig("HudScale");
	class'HUD'.static.ResetConfig("HudOpacity");

	class'HudBase'.static.ResetConfig("CustomHudColor");
    class'XGame.xDeathMessage'.static.ResetConfig("bNoConsoleDeathMessages");

	for (i = 0; i < Components.Length; i++)
		Components[i].LoadINI();
}

function bool SaveCustomHUDColor()
{
	local color Temp;
	local HudBase Base;

	Base = HudBase(PlayerOwner().myHUD);
	if ( Base != None )
	{
		if ( bCustomColor )
		{
			if ( Base.CustomHUDColor != cCustom )
			{
				Base.CustomHUDColor = cCustom;
				Base.SetCustomHUDColor();
				return true;
			}
		}
		else if ( Base.CustomHUDColor != Temp )
		{
			Base.CustomHUDColor = Temp;
			Base.SetCustomHUDColor();
			return true;
		}
	}
	else
	{
		if ( bCustomColor )
		{
			if ( class'HudBase'.default.CustomHUDColor != cCustom )
			{
				class'HudBase'.default.CustomHUDColor = cCustom;
				class'HudBase'.static.StaticSaveConfig();
				return false;
			}
		}
		else if ( class'HudBase'.default.CustomHUDColor != Temp )
		{
			class'HudBase'.default.CustomHUDColor = Temp;
			class'HudBase'.static.StaticSaveConfig();
			return false;
		}
	}

	return false;
}

function InternalOnChange(GUIComponent Sender)
{
	Super.InternalOnChange(Sender);
	switch (Sender)
	{
	case ch_Visible:
		bVis = ch_Visible.IsChecked();
		break;

	case ch_Weapons:
		bWeapons = ch_Weapons.IsChecked();
		break;

	case ch_Personal:
		bPersonal = ch_Personal.IsChecked();
		break;

	case ch_Score:
		bScore = ch_Score.IsChecked();
		break;

	case ch_WeaponBar:
		bWeaponBar = ch_WeaponBar.IsChecked();
		break;

    case ch_DeathMsgs:
        bNoMsgs = ch_DeathMsgs.IsChecked();
        break;

	case ch_Portraits:
		bPortraits = ch_Portraits.IsChecked();
		break;

	case ch_VCPortraits:
		bVCPortraits = ch_VCPortraits.IsChecked();
		break;

	case ch_EnemyNames:
		bNames = ch_EnemyNames.IsChecked();
		break;

	case nu_MsgCount:
		iCount = nu_MsgCount.GetValue();
		break;

	case nu_MsgScale:
		iScale = nu_MsgScale.GetValue();
		break;

	case nu_MsgOffset:
		iOffset = nu_MsgOffset.GetValue();
		break;

	case sl_Scale:
		fScale = sl_Scale.GetValue();
		UpdatePreviewColor();
		break;

	case sl_Opacity:
		fOpacity = sl_Opacity.GetValue();
		UpdatePreviewColor();
		break;

	case ch_CustomColor:
		bCustomColor = ch_CustomColor.IsChecked();
		ChangeCustomStatus();
		UpdatePreviewColor();
		break;

	case sl_Red:
		cCustom.R = sl_Red.GetValue();
		UpdatePreviewColor();
		break;

	case sl_Blue:
		cCustom.B = sl_Blue.GetValue();
		UpdatePreviewColor();
		break;

	case sl_Green:
		cCustom.G = sl_Green.GetValue();
		UpdatePreviewColor();
		break;
	}
}

function ChangeCustomStatus()
{
	if (bCustomColor)
	{
		sl_Red.EnableMe();
		sl_Blue.EnableMe();
		sl_Green.EnableMe();

		cCustom.R = sl_Red.GetValue();
		cCustom.G = sl_Green.GetValue();
		cCustom.B = sl_Blue.GetValue();
	}
	else
	{
		sl_Red.DisableMe();
		sl_Blue.DisableMe();
		sl_Green.DisableMe();

		cCustom = GetDefaultColor();
	}
}

function UpdatePreviewColor()
{
	local float o, s;

	i_PreviewBG.ImageColor = cCustom;

	o = 255.0 * (fOpacity / 100.0);
	i_PreviewBG.ImageColor.A = o;
	i_Preview.ImageColor.A = o;

	s = fScale / 100.0;
	i_PreviewBG.WinWidth = DefaultBGPos.X2 * s;
	i_PreviewBG.WinHeight = DefaultBGPos.Y2 * s;

	i_Preview.WinWidth = DefaultHealthPos.X2 * s;
	i_Preview.WinHeight = DefaultHealthPos.Y2 * s;

	i_Scale.WinWidth =  i_PreviewBG.WinWidth;
	i_Scale.WinHeight = i_PreviewBG.WinHeight;

}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=GameBK
         Caption="Options"
         WinTop=0.057604
         WinLeft=0.031797
         WinWidth=0.448633
         WinHeight=0.901485
         RenderWeight=0.001000
         OnPreDraw=GameBK.InternalPreDraw
     End Object
     i_BG1=GUISectionBackground'GUI2K4.UT2K4Tab_HudSettings.GameBK'

     Begin Object Class=GUISectionBackground Name=GameBK1
         Caption="Visuals"
         WinTop=0.060208
         WinLeft=0.517578
         WinWidth=0.448633
         WinHeight=0.901485
         RenderWeight=0.001000
         OnPreDraw=GameBK1.InternalPreDraw
     End Object
     i_BG2=GUISectionBackground'GUI2K4.UT2K4Tab_HudSettings.GameBK1'

     Begin Object Class=GUIImage Name=PreviewBK
         Image=Texture'2K4Menus.NewControls.NewTabBk'
         ImageStyle=ISTY_Scaled
         ImageAlign=IMGA_Center
         WinTop=0.211713
         WinLeft=0.749335
         WinWidth=0.163437
         WinHeight=0.121797
         RenderWeight=1.001000
     End Object
     i_Scale=GUIImage'GUI2K4.UT2K4Tab_HudSettings.PreviewBK'

     Begin Object Class=GUIImage Name=PreviewBackground
         Image=Texture'HUDContent.Generic.HUD'
         ImageStyle=ISTY_Scaled
         ImageAlign=IMGA_Center
         X1=0
         Y1=110
         X2=166
         Y2=163
         WinTop=0.211713
         WinLeft=0.749335
         WinWidth=0.163437
         WinHeight=0.121797
         RenderWeight=1.002000
     End Object
     i_PreviewBG=GUIImage'GUI2K4.UT2K4Tab_HudSettings.PreviewBackground'

     Begin Object Class=GUIImage Name=Preview
         Image=Texture'HUDContent.Generic.HUD'
         ImageStyle=ISTY_Scaled
         ImageAlign=IMGA_Center
         X1=74
         Y1=165
         X2=123
         Y2=216
         WinTop=0.211559
         WinLeft=0.749828
         WinWidth=0.063241
         WinHeight=0.099531
         RenderWeight=1.003000
     End Object
     i_Preview=GUIImage'GUI2K4.UT2K4Tab_HudSettings.Preview'

     Begin Object Class=moSlider Name=GameHudScale
         MaxValue=100.000000
         MinValue=50.000000
         LabelJustification=TXTA_Center
         ComponentJustification=TXTA_Left
         CaptionWidth=0.450000
         Caption="HUD Scaling"
         LabelColor=(B=255,G=255,R=255)
         OnCreateComponent=GameHudScale.InternalOnCreateComponent
         Hint="Adjust the size of the HUD"
         WinTop=0.309670
         WinLeft=0.555313
         WinWidth=0.373749
         TabOrder=12
         OnChange=UT2K4Tab_HudSettings.InternalOnChange
     End Object
     sl_Scale=moSlider'GUI2K4.UT2K4Tab_HudSettings.GameHudScale'

     Begin Object Class=moSlider Name=GameHudOpacity
         MaxValue=100.000000
         MinValue=51.000000
         LabelJustification=TXTA_Center
         ComponentJustification=TXTA_Left
         CaptionWidth=0.450000
         Caption="HUD Opacity"
         LabelColor=(B=255,G=255,R=255)
         OnCreateComponent=GameHudOpacity.InternalOnCreateComponent
         Hint="Adjust the transparency of the HUD"
         WinTop=0.361753
         WinLeft=0.555313
         WinWidth=0.373749
         TabOrder=13
         OnChange=UT2K4Tab_HudSettings.InternalOnChange
     End Object
     sl_Opacity=moSlider'GUI2K4.UT2K4Tab_HudSettings.GameHudOpacity'

     Begin Object Class=moSlider Name=HudColorR
         MaxValue=255.000000
         bIntSlider=True
         CaptionWidth=0.350000
         Caption="Red:"
         LabelColor=(B=0,R=255)
         OnCreateComponent=HudColorR.InternalOnCreateComponent
         Hint="Adjust the amount of red in the HUD."
         WinTop=0.572917
         WinLeft=0.610000
         WinWidth=0.272187
         TabOrder=15
         OnChange=UT2K4Tab_HudSettings.InternalOnChange
     End Object
     sl_Red=moSlider'GUI2K4.UT2K4Tab_HudSettings.HudColorR'

     Begin Object Class=moSlider Name=HudColorG
         MaxValue=255.000000
         bIntSlider=True
         CaptionWidth=0.350000
         Caption="Green:"
         LabelColor=(B=0,G=255)
         OnCreateComponent=HudColorG.InternalOnCreateComponent
         Hint="Adjust the amount of green in the HUD."
         WinTop=0.660417
         WinLeft=0.610000
         WinWidth=0.272187
         TabOrder=17
         OnChange=UT2K4Tab_HudSettings.InternalOnChange
     End Object
     sl_Green=moSlider'GUI2K4.UT2K4Tab_HudSettings.HudColorG'

     Begin Object Class=moSlider Name=HudColorB
         MaxValue=255.000000
         bIntSlider=True
         CaptionWidth=0.350000
         Caption="Blue:"
         LabelColor=(B=255)
         OnCreateComponent=HudColorB.InternalOnCreateComponent
         Hint="Adjust the amount of blue in the HUD."
         WinTop=0.752500
         WinLeft=0.610000
         WinWidth=0.272187
         TabOrder=16
         OnChange=UT2K4Tab_HudSettings.InternalOnChange
     End Object
     sl_Blue=moSlider'GUI2K4.UT2K4Tab_HudSettings.HudColorB'

     Begin Object Class=moNumericEdit Name=GameHudMessageCount
         MinValue=0
         MaxValue=8
         ComponentJustification=TXTA_Left
         CaptionWidth=0.700000
         Caption="Max. Chat Count"
         OnCreateComponent=GameHudMessageCount.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Number of lines of chat to display at once"
         WinTop=0.196875
         WinLeft=0.550781
         WinWidth=0.381250
         TabOrder=9
         OnChange=UT2K4Tab_HudSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_HudSettings.InternalOnLoadINI
     End Object
     nu_MsgCount=moNumericEdit'GUI2K4.UT2K4Tab_HudSettings.GameHudMessageCount'

     Begin Object Class=moNumericEdit Name=GameHudMessageScale
         MinValue=0
         MaxValue=8
         ComponentJustification=TXTA_Left
         CaptionWidth=0.700000
         Caption="Chat Font Size"
         OnCreateComponent=GameHudMessageScale.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Adjust the size of chat messages."
         WinTop=0.321874
         WinLeft=0.550781
         WinWidth=0.381250
         TabOrder=10
         OnChange=UT2K4Tab_HudSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_HudSettings.InternalOnLoadINI
     End Object
     nu_MsgScale=moNumericEdit'GUI2K4.UT2K4Tab_HudSettings.GameHudMessageScale'

     Begin Object Class=moNumericEdit Name=GameHudMessageOffset
         MinValue=0
         MaxValue=4
         ComponentJustification=TXTA_Left
         CaptionWidth=0.700000
         Caption="Message Font Offset"
         OnCreateComponent=GameHudMessageOffset.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Adjust the size of game messages."
         WinTop=0.436457
         WinLeft=0.550781
         WinWidth=0.381250
         TabOrder=11
         OnChange=UT2K4Tab_HudSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_HudSettings.InternalOnLoadINI
     End Object
     nu_MsgOffset=moNumericEdit'GUI2K4.UT2K4Tab_HudSettings.GameHudMessageOffset'

     Begin Object Class=moCheckBox Name=GameHudVisible
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Hide HUD"
         OnCreateComponent=GameHudVisible.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Hide the HUD while playing"
         WinTop=0.043906
         WinLeft=0.379297
         WinWidth=0.196875
         TabOrder=0
         OnChange=UT2K4Tab_HudSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_HudSettings.InternalOnLoadINI
     End Object
     ch_Visible=moCheckBox'GUI2K4.UT2K4Tab_HudSettings.GameHudVisible'

     Begin Object Class=moCheckBox Name=GameHudShowWeaponInfo
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Show Weapon Info"
         OnCreateComponent=GameHudShowWeaponInfo.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Show current weapon ammunition status."
         WinTop=0.181927
         WinLeft=0.050000
         WinWidth=0.378125
         TabOrder=3
         OnChange=UT2K4Tab_HudSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_HudSettings.InternalOnLoadINI
     End Object
     ch_Weapons=moCheckBox'GUI2K4.UT2K4Tab_HudSettings.GameHudShowWeaponInfo'

     Begin Object Class=moCheckBox Name=GameHudShowPersonalInfo
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Show Personal Info"
         OnCreateComponent=GameHudShowPersonalInfo.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Display health and armor on the HUD."
         WinTop=0.317343
         WinLeft=0.050000
         WinWidth=0.378125
         TabOrder=4
         OnChange=UT2K4Tab_HudSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_HudSettings.InternalOnLoadINI
     End Object
     ch_Personal=moCheckBox'GUI2K4.UT2K4Tab_HudSettings.GameHudShowPersonalInfo'

     Begin Object Class=moCheckBox Name=GameHudShowScore
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Show Score"
         OnCreateComponent=GameHudShowScore.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Check to show scores on the HUD"
         WinTop=0.452760
         WinLeft=0.050000
         WinWidth=0.378125
         TabOrder=5
         OnChange=UT2K4Tab_HudSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_HudSettings.InternalOnLoadINI
     End Object
     ch_Score=moCheckBox'GUI2K4.UT2K4Tab_HudSettings.GameHudShowScore'

     Begin Object Class=moCheckBox Name=GameHudShowWeaponBar
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Weapon Bar"
         OnCreateComponent=GameHudShowWeaponBar.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Select whether the weapons bar should appear on the HUD"
         WinTop=0.598593
         WinLeft=0.050000
         WinWidth=0.378125
         TabOrder=2
         OnChange=UT2K4Tab_HudSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_HudSettings.InternalOnLoadINI
     End Object
     ch_WeaponBar=moCheckBox'GUI2K4.UT2K4Tab_HudSettings.GameHudShowWeaponBar'

     Begin Object Class=moCheckBox Name=GameHudShowPortraits
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Show Portraits"
         OnCreateComponent=GameHudShowPortraits.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Display player portraits when text messages are received"
         WinTop=0.723594
         WinLeft=0.050000
         WinWidth=0.378125
         TabOrder=6
         OnChange=UT2K4Tab_HudSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_HudSettings.InternalOnLoadINI
     End Object
     ch_Portraits=moCheckBox'GUI2K4.UT2K4Tab_HudSettings.GameHudShowPortraits'

     Begin Object Class=moCheckBox Name=GameHUDShowVCPortraits
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Show VoIP Portraits"
         OnCreateComponent=GameHUDShowVCPortraits.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Display player portraits when voice chat messages are received"
         WinTop=0.723594
         WinLeft=0.050000
         WinWidth=0.378125
         TabOrder=7
         OnChange=UT2K4Tab_HudSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_HudSettings.InternalOnLoadINI
     End Object
     ch_VCPortraits=moCheckBox'GUI2K4.UT2K4Tab_HudSettings.GameHUDShowVCPortraits'

     Begin Object Class=moCheckBox Name=GameDeathMsgs
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="No Console Death Messages"
         OnCreateComponent=GameDeathMsgs.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="False"
         Hint="Turn off reporting of death messages in console"
         WinTop=0.847553
         WinLeft=0.047460
         WinWidth=0.403711
         TabOrder=8
         OnChange=UT2K4Tab_HudSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_HudSettings.InternalOnLoadINI
     End Object
     ch_DeathMsgs=moCheckBox'GUI2K4.UT2K4Tab_HudSettings.GameDeathMsgs'

     Begin Object Class=moCheckBox Name=GameHudShowEnemyNames
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Show Enemy Names"
         OnCreateComponent=GameHudShowEnemyNames.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Display enemies' names above their heads"
         WinTop=0.848594
         WinLeft=0.050000
         WinWidth=0.378125
         TabOrder=1
         OnChange=UT2K4Tab_HudSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_HudSettings.InternalOnLoadINI
     End Object
     ch_EnemyNames=moCheckBox'GUI2K4.UT2K4Tab_HudSettings.GameHudShowEnemyNames'

     Begin Object Class=moCheckBox Name=CustomHUDColor
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Custom HUD Color"
         OnCreateComponent=CustomHUDColor.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Use configured HUD color instead of team colors"
         WinTop=0.481406
         WinLeft=0.555313
         WinWidth=0.373749
         TabOrder=14
         OnChange=UT2K4Tab_HudSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_HudSettings.InternalOnLoadINI
     End Object
     ch_CustomColor=moCheckBox'GUI2K4.UT2K4Tab_HudSettings.CustomHUDColor'

     Begin Object Class=GUIComboBox Name=CustomHUDSelect
         bReadOnly=True
         Hint="To configure settings specific to a particular gametype, select the gametype from the list, then click the button to open the menu."
         WinTop=0.878722
         WinLeft=0.553579
         WinWidth=0.227863
         WinHeight=0.030000
         TabOrder=18
         OnKeyEvent=CustomHUDSelect.InternalOnKeyEvent
     End Object
     co_CustomHUD=GUIComboBox'GUI2K4.UT2K4Tab_HudSettings.CustomHUDSelect'

     Begin Object Class=GUIButton Name=CustomHUDButton
         Caption="Configure"
         Hint="Opens the custom HUD configuration menu for the specified gametype."
         WinTop=0.869032
         WinLeft=0.792737
         WinWidth=0.138577
         WinHeight=0.050000
         TabOrder=19
         OnClick=UT2K4Tab_HudSettings.InternalOnClick
         OnKeyEvent=CustomHUDButton.InternalOnKeyEvent
     End Object
     b_CustomHUD=GUIButton'GUI2K4.UT2K4Tab_HudSettings.CustomHUDButton'

     DefaultBGPos=(X1=0.749335,Y1=0.167488,X2=0.163437,Y2=0.121797)
     DefaultHealthPos=(X1=0.748164,Y1=0.169572,X2=0.063241,Y2=0.099531)
     PanelCaption="HUD"
     WinTop=0.150000
     WinHeight=0.740000
}
