//==============================================================================
//	Description
//
//	Created by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UT2K4Tab_IForceSettings extends Settings_Tabs;

var automated GUISectionBackground i_BG1, i_BG2, i_BG3;
var automated GUILabel	l_IForce;
var automated moCheckbox ch_AutoSlope, ch_InvertMouse,
						ch_MouseSmoothing, ch_Joystick, ch_WeaponEffects,
						ch_PickupEffects, ch_DamageEffects, ch_GUIEffects,
						ch_MouseLag;
var automated moFloatEdit	fl_Sensitivity, fl_MenuSensitivity, fl_MouseAccel,
							fl_SmoothingStrength, fl_DodgeTime;

var automated GUIButton b_Controls, b_Speech;

var bool bAim, bSlope, bInvert, bSmoothing, bJoystick, bWFX, bPFX, bDFX, bGFX, bLag;
var float fSens, fMSens, fAccel, fSmoothing, fDodge;

var config string ControlBindMenu, SpeechBindMenu;

event InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

    i_BG1.ManageComponent(ch_AutoSlope);
    i_BG1.ManageComponent(ch_InvertMouse);
    i_BG1.ManageComponent(ch_MouseSmoothing);
    i_BG1.ManageComponent(ch_MouseLag);
    i_BG1.ManageComponent(ch_Joystick);
    i_BG1.ManageComponent(b_Controls);
    i_BG1.ManageComponent(b_Speech);

    i_BG3.ManageComponent(fl_Sensitivity);
    i_BG3.ManageComponent(fl_MenuSensitivity);
    i_BG3.ManageComponent(fl_SmoothingStrength);
    i_BG3.ManageComponent(fl_MouseAccel);
    i_BG3.ManageComponent(fl_DodgeTime);

    // Disable force feedback options on non-win32 platforms...  --ryan.
    if ( (!PlatformIsWindows()) || (PlatformIs64Bit()) )
    {
        ch_WeaponEffects.DisableMe();
        ch_PickupEffects.DisableMe();
        ch_DamageEffects.DisableMe();
        ch_GUIEffects.DisableMe();
    }
}


function InternalOnLoadINI(GUIComponent Sender, string s)
{
	local PlayerController PC;

	PC = PlayerOwner();

	switch (Sender)
	{
	case ch_AutoSlope:
		bSlope = PC.bSnapToLevel;
		ch_AutoSlope.SetComponentValue(bSlope,true);
		break;

	case ch_InvertMouse:
		bInvert = class'PlayerInput'.default.bInvertMouse;
		ch_InvertMouse.SetComponentValue(bInvert,true);
		break;

	case ch_MouseSmoothing:
		bSmoothing = class'PlayerInput'.default.MouseSmoothingMode > 0;
		ch_MouseSmoothing.SetComponentValue(bSmoothing,true);
		break;

	case ch_Joystick:
		bJoystick = bool(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager UseJoystick"));
		ch_Joystick.SetComponentValue(bJoystick,true);
		break;

	case ch_WeaponEffects:
		bWFX = PC.bEnableWeaponForceFeedback;
		ch_WeaponEffects.SetComponentValue(bWFX,true);
		break;

	case ch_PickupEffects:
		bPFX = PC.bEnablePickupForceFeedback;
		ch_PickupEffects.SetComponentValue(bPFX,true);
		break;

	case ch_DamageEffects:
		bDFX = PC.bEnableDamageForceFeedback;
		ch_DamageEffects.SetComponentValue(bDFX,true);
		break;

	case ch_GUIEffects:
		bGFX = PC.bEnableGUIForceFeedback;
		ch_GUIEffects.SetComponentValue(bGFX,true);
		break;

	case ch_MouseLag:
		bLag = bool(PC.ConsoleCommand("get ini:Engine.Engine.RenderDevice ReduceMouseLag"));
		ch_MouseLag.Checked(bLag);
		break;

	case fl_Sensitivity:
		fSens = class'PlayerInput'.default.MouseSensitivity;
		fl_Sensitivity.SetComponentValue(fSens,true);
		break;

	case fl_MenuSensitivity:
		fMSens = Controller.MenuMouseSens;
		fl_MenuSensitivity.SetComponentValue(fMSens,true);
		break;

	case fl_MouseAccel:
		fAccel = class'PlayerInput'.Default.MouseAccelThreshold;
		fl_MouseAccel.SetComponentValue(fAccel,true);
		break;

	case fl_SmoothingStrength:
		fSmoothing = class'PlayerInput'.Default.MouseSmoothingStrength;
		fl_SmoothingStrength.SetComponentValue(fSmoothing,true);
		break;

	case fl_DodgeTime:
		fDodge = class'PlayerInput'.Default.DoubleClickTime;
		fl_DodgeTime.SetComponentValue(fDodge,true);
		break;

	default:
		log(Name@"Unknown component calling LoadINI:"$ GUIMenuOption(Sender).Caption);
		GUIMenuOption(Sender).SetComponentValue(s,true);
	}
}

function SaveSettings()
{
	local PlayerController PC;
	local bool bSave, bInputSave, bIForce;

	Super.SaveSettings();

	PC = PlayerOwner();

	if ( bool(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager UseJoystick")) != bJoystick )
		PC.ConsoleCommand("set ini:Engine.Engine.ViewportManager UseJoystick" @ bJoystick);

	if ( bool(PC.ConsoleCommand("get ini:Engine.Engine.RenderDevice ReduceMouseLag")) != bLag )
		PC.ConsoleCommand("set ini:Engine.Engine.RenderDevice ReduceMouseLag"@bLag);

	if ( PC.bSnapToLevel != bSlope )
	{
		PC.bSnapToLevel = bSlope;
		bSave = True;
	}

	if ( PC.bEnableWeaponForceFeedback != bWFX )
	{
		PC.bEnableWeaponForceFeedback = bWFX;
		bSave = True;
		bIForce = True;
	}

	if ( PC.bEnablePickupForceFeedback != bPFX )
	{
		PC.bEnablePickupForceFeedback = bPFX;
		bIForce = True;
		bSave = True;
	}

	if ( PC.bEnableDamageForceFeedback != bDFX )
	{
		PC.bEnableDamageForceFeedback = bDFX;
		bIForce = True;
		bSave = True;
	}

	if ( PC.bEnableGUIForceFeedback != bGFX )
	{
		PC.bEnableGUIForceFeedback = bGFX;
		bIForce = True;
		bSave = True;
	}

	if ( Controller.MenuMouseSens != FMax(0.0, fMSens) )
		Controller.SaveConfig();

	if ( class'PlayerInput'.default.DoubleClickTime != FMax(0.0, fDodge) )
	{
		class'PlayerInput'.default.DoubleClickTime = fDodge;
		bInputSave = True;
	}

	if ( class'PlayerInput'.default.MouseAccelThreshold != FMax(0.0, fAccel) )
	{
		PC.SetMouseAccel(fAccel);
		bInputSave = False;
	}

	if ( class'PlayerInput'.default.MouseSmoothingStrength != FMax(0.0, fSmoothing) )
	{
		PC.ConsoleCommand("SetSmoothingStrength"@fSmoothing);
		bInputSave = False;
	}

	if ( class'PlayerInput'.default.bInvertMouse != bInvert )
	{
		PC.InvertMouse( string(bInvert) );
		bInputSave = False;
	}

	if ( class'PlayerInput'.default.MouseSmoothingMode != byte(bSmoothing) )
	{
		PC.SetMouseSmoothing(int(bSmoothing));
		bInputSave = False;
	}

	if ( class'PlayerInput'.default.MouseSensitivity != FMax(0.0, fSens) )
	{
		PC.SetSensitivity(fSens);
		bInputSave = False;
	}

	if (bInputSave)
		class'PlayerInput'.static.StaticSaveConfig();

	if ( bIForce )
		PC.bForceFeedbackSupported = PC.ForceFeedbackSupported(bGFX || bWFX || bPFX || bDFX);

	if (bSave)
		PC.SaveConfig();
}

function ResetClicked()
{
	local int i;
	local string Str;
	local class					 	ViewportClass;
	local class<RenderDevice>		RenderClass;

	Super.ResetClicked();
	Str = PlayerOwner().ConsoleCommand("get ini:Engine.Engine.ViewportManager Class");
	Str = Mid(Str, InStr(Str, "'") + 1);
	Str = Left(Str, Len(Str) - 1);
	ViewportClass = class(DynamicLoadObject(Str, class'Class'));

	Str = PlayerOwner().ConsoleCommand("get ini:Engine.Engine.RenderDevice Class");
	Str = Mid(Str, InStr(Str, "'") + 1);
	Str = Left(Str, Len(Str) - 1);
	RenderClass = class<RenderDevice>(DynamicLoadObject(Str, class'Class'));

	ViewportClass.static.ResetConfig("UseJoystick");
	RenderClass.static.ResetConfig("ReduceMouseLag");
	Controller.static.ResetConfig("MenuMouseSens");
	class'PlayerController'.static.ResetConfig("bSnapToLevel");
	class'PlayerController'.static.ResetConfig("bEnableWeaponForceFeedback");
	class'PlayerController'.static.ResetConfig("bEnablePickupForceFeedback");
	class'PlayerController'.static.ResetConfig("bEnableDamageForceFeedback");
	class'PlayerController'.static.ResetConfig("bEnableGUIForceFeedback");

	class'PlayerInput'.static.ResetConfig("bInvertMouse");
	class'PlayerInput'.static.ResetConfig("MouseSmoothingMode");
	class'PlayerInput'.static.ResetConfig("MouseSensitivity");
	class'PlayerInput'.static.ResetConfig("MouseSmoothingStrength");
	class'PlayerInput'.static.ResetConfig("DoubleClickTime");
	class'PlayerInput'.static.ResetConfig("MouseAccelThreshold");

	for (i = 0; i < Components.Length; i++)
		Components[i].LoadINI();
}

function InternalOnChange(GUIComponent Sender)
{
	Super.InternalOnChange(Sender);
	switch (Sender)
	{
	case ch_AutoSlope:
		bSlope= ch_AutoSlope.IsChecked();
		break;

	case ch_InvertMouse:
		bInvert = ch_InvertMouse.IsChecked();
		break;

	case ch_MouseSmoothing:
		bSmoothing = ch_MouseSmoothing.IsChecked();
		break;

	case ch_Joystick:
		bJoystick = ch_Joystick.IsChecked();
		break;

	case ch_WeaponEffects:
		bWFX = ch_WeaponEffects.IsChecked();
		break;

	case ch_PickupEffects:
		bPFX = ch_PickupEffects.IsChecked();
		break;

	case ch_DamageEffects:
		bDFX = ch_DamageEffects.IsChecked();
		break;

	case ch_GUIEffects:
		bGFX = ch_GUIEffects.IsChecked();
		break;

	case ch_MouseLag:
		bLag = ch_MouseLag.IsChecked();
		break;

	case fl_Sensitivity:
		fSens = fl_Sensitivity.GetValue();
		break;

	case fl_MenuSensitivity:
		Controller.MenuMouseSens = fl_MenuSensitivity.GetValue();
		break;

	case fl_MouseAccel:
		fAccel = fl_MouseAccel.GetValue();
		break;

	case fl_SmoothingStrength:
		fSmoothing = fl_SmoothingStrength.GetValue();
		break;

	case fl_DodgeTime:
		fDodge = fl_DodgeTime.GetValue();
		break;
	}
}

function bool InternalOnClick(GUIComponent Sender)
{
	local GUITabControl C;
	local int i;

	if ( Sender == b_Controls )
	{
		Controller.OpenMenu(ControlBindMenu);
	}

	else if ( Sender == b_Speech )
	{
		// Hack - need to update the players character and voice options before opening the speechbind menu
		C = GUITabControl(MenuOwner);
		if ( C != None )
		{
			for ( i = 0; i < C.TabStack.Length; i++ )
			{
				if ( C.TabStack[i] != None && UT2K4Tab_PlayerSettings(C.TabStack[i].MyPanel) != None )
				{
					UT2K4Tab_PlayerSettings(C.TabStack[i].MyPanel).SaveSettings();
					break;
				}
			}
		}

		Controller.OpenMenu(SpeechBindMenu);
	}

	return true;
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=InputBK1
         Caption="Options"
         WinTop=0.028176
         WinLeft=0.021641
         WinWidth=0.381328
         WinHeight=0.655039
         OnPreDraw=InputBK1.InternalPreDraw
     End Object
     i_BG1=GUISectionBackground'GUI2K4.UT2K4Tab_IForceSettings.InputBK1'

     Begin Object Class=GUISectionBackground Name=InputBK2
         Caption="TouchSense Force Feedback"
         WinTop=0.730000
         WinLeft=0.021641
         WinWidth=0.957500
         WinHeight=0.240977
         OnPreDraw=InputBK2.InternalPreDraw
     End Object
     i_BG2=GUISectionBackground'GUI2K4.UT2K4Tab_IForceSettings.InputBK2'

     Begin Object Class=GUISectionBackground Name=InputBK3
         Caption="Fine Tuning"
         WinTop=0.028176
         WinLeft=0.451289
         WinWidth=0.527812
         WinHeight=0.655039
         OnPreDraw=InputBK3.InternalPreDraw
     End Object
     i_BG3=GUISectionBackground'GUI2K4.UT2K4Tab_IForceSettings.InputBK3'

     Begin Object Class=moCheckBox Name=InputAutoSlope
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Auto Slope"
         OnCreateComponent=InputAutoSlope.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="When enabled, your view will automatically pitch up/down when on a slope."
         WinTop=0.105365
         WinLeft=0.060937
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=2
         OnChange=UT2K4Tab_IForceSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_IForceSettings.InternalOnLoadINI
     End Object
     ch_AutoSlope=moCheckBox'GUI2K4.UT2K4Tab_IForceSettings.InputAutoSlope'

     Begin Object Class=moCheckBox Name=InputInvertMouse
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Invert Mouse"
         OnCreateComponent=InputInvertMouse.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="When enabled, the Y axis of your mouse will be inverted."
         WinTop=0.188698
         WinLeft=0.060938
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=3
         OnChange=UT2K4Tab_IForceSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_IForceSettings.InternalOnLoadINI
     End Object
     ch_InvertMouse=moCheckBox'GUI2K4.UT2K4Tab_IForceSettings.InputInvertMouse'

     Begin Object Class=moCheckBox Name=InputMouseSmoothing
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Mouse Smoothing"
         OnCreateComponent=InputMouseSmoothing.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Enable this option to automatically smooth out movements in your mouse."
         WinTop=0.324167
         WinLeft=0.060938
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=4
         OnChange=UT2K4Tab_IForceSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_IForceSettings.InternalOnLoadINI
     End Object
     ch_MouseSmoothing=moCheckBox'GUI2K4.UT2K4Tab_IForceSettings.InputMouseSmoothing'

     Begin Object Class=moCheckBox Name=InputUseJoystick
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Enable Joystick"
         OnCreateComponent=InputUseJoystick.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Enable this option to enable joystick support."
         WinTop=0.582083
         WinLeft=0.060938
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=6
         OnChange=UT2K4Tab_IForceSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_IForceSettings.InternalOnLoadINI
     End Object
     ch_Joystick=moCheckBox'GUI2K4.UT2K4Tab_IForceSettings.InputUseJoystick'

     Begin Object Class=moCheckBox Name=InputIFWeaponEffects
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Weapon Effects"
         OnCreateComponent=InputIFWeaponEffects.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Turn this option On/Off to feel the weapons you fire."
         WinTop=0.815333
         WinLeft=0.100000
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=12
         OnChange=UT2K4Tab_IForceSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_IForceSettings.InternalOnLoadINI
     End Object
     ch_WeaponEffects=moCheckBox'GUI2K4.UT2K4Tab_IForceSettings.InputIFWeaponEffects'

     Begin Object Class=moCheckBox Name=InputIFPickupEffects
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Pickup Effects"
         OnCreateComponent=InputIFPickupEffects.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Turn this option On/Off to feel the items you pick up."
         WinTop=0.906333
         WinLeft=0.100000
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=13
         OnChange=UT2K4Tab_IForceSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_IForceSettings.InternalOnLoadINI
     End Object
     ch_PickupEffects=moCheckBox'GUI2K4.UT2K4Tab_IForceSettings.InputIFPickupEffects'

     Begin Object Class=moCheckBox Name=InputIFDamageEffects
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Damage Effects"
         OnCreateComponent=InputIFDamageEffects.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Turn this option On/Off to feel the damage you take."
         WinTop=0.815333
         WinLeft=0.563867
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=14
         OnChange=UT2K4Tab_IForceSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_IForceSettings.InternalOnLoadINI
     End Object
     ch_DamageEffects=moCheckBox'GUI2K4.UT2K4Tab_IForceSettings.InputIFDamageEffects'

     Begin Object Class=moCheckBox Name=InputIFGUIEffects
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Vehicle Effects"
         OnCreateComponent=InputIFGUIEffects.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Turn this option On/Off to feel the vehicle effects."
         WinTop=0.906333
         WinLeft=0.563867
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=15
         OnChange=UT2K4Tab_IForceSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_IForceSettings.InternalOnLoadINI
     End Object
     ch_GUIEffects=moCheckBox'GUI2K4.UT2K4Tab_IForceSettings.InputIFGUIEffects'

     Begin Object Class=moCheckBox Name=InputMouseLag
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Reduce Mouse Lag"
         OnCreateComponent=InputMouseLag.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Enable this option will reduce the amount of lag in your mouse."
         WinTop=0.405000
         WinLeft=0.060938
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=5
         OnChange=UT2K4Tab_IForceSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_IForceSettings.InternalOnLoadINI
     End Object
     ch_MouseLag=moCheckBox'GUI2K4.UT2K4Tab_IForceSettings.InputMouseLag'

     Begin Object Class=moFloatEdit Name=InputMouseSensitivity
         MinValue=0.250000
         MaxValue=25.000000
         Step=0.250000
         ComponentJustification=TXTA_Left
         CaptionWidth=0.725000
         Caption="Mouse Sensitivity (Game)"
         OnCreateComponent=InputMouseSensitivity.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Adjust mouse sensitivity"
         WinTop=0.105365
         WinLeft=0.502344
         WinWidth=0.421680
         WinHeight=0.045352
         TabOrder=7
         OnChange=UT2K4Tab_IForceSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_IForceSettings.InternalOnLoadINI
     End Object
     fl_Sensitivity=moFloatEdit'GUI2K4.UT2K4Tab_IForceSettings.InputMouseSensitivity'

     Begin Object Class=moFloatEdit Name=InputMenuSensitivity
         MinValue=1.000000
         MaxValue=6.000000
         Step=0.250000
         ComponentJustification=TXTA_Left
         CaptionWidth=0.725000
         Caption="Mouse Sensitivity (Menus)"
         OnCreateComponent=InputMenuSensitivity.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Adjust mouse speed within the menus"
         WinTop=0.188698
         WinLeft=0.502344
         WinWidth=0.421875
         WinHeight=0.045352
         TabOrder=8
         OnChange=UT2K4Tab_IForceSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_IForceSettings.InternalOnLoadINI
     End Object
     fl_MenuSensitivity=moFloatEdit'GUI2K4.UT2K4Tab_IForceSettings.InputMenuSensitivity'

     Begin Object Class=moFloatEdit Name=InputMouseAccel
         MinValue=0.000000
         MaxValue=100.000000
         Step=5.000000
         ComponentJustification=TXTA_Left
         CaptionWidth=0.725000
         Caption="Mouse Accel. Threshold"
         OnCreateComponent=InputMouseAccel.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Adjust to determine the amount of movement needed before acceleration is applied"
         WinTop=0.405000
         WinLeft=0.502344
         WinWidth=0.421875
         WinHeight=0.045352
         TabOrder=10
         OnChange=UT2K4Tab_IForceSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_IForceSettings.InternalOnLoadINI
     End Object
     fl_MouseAccel=moFloatEdit'GUI2K4.UT2K4Tab_IForceSettings.InputMouseAccel'

     Begin Object Class=moFloatEdit Name=InputMouseSmoothStr
         MinValue=0.000000
         MaxValue=1.000000
         Step=0.050000
         ComponentJustification=TXTA_Left
         CaptionWidth=0.725000
         Caption="Mouse Smoothing Strength"
         OnCreateComponent=InputMouseSmoothStr.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Adjust the amount of smoothing that is applied to mouse movements"
         WinTop=0.324167
         WinLeft=0.502344
         WinWidth=0.421875
         WinHeight=0.045352
         TabOrder=9
         OnChange=UT2K4Tab_IForceSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_IForceSettings.InternalOnLoadINI
     End Object
     fl_SmoothingStrength=moFloatEdit'GUI2K4.UT2K4Tab_IForceSettings.InputMouseSmoothStr'

     Begin Object Class=moFloatEdit Name=InputDodgeTime
         MinValue=0.000000
         MaxValue=1.000000
         Step=0.050000
         ComponentJustification=TXTA_Left
         CaptionWidth=0.725000
         Caption="Dodge Double-Click Time"
         OnCreateComponent=InputDodgeTime.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Determines how fast you have to double click to dodge"
         WinTop=0.582083
         WinLeft=0.502344
         WinWidth=0.421875
         WinHeight=0.045352
         TabOrder=11
         OnChange=UT2K4Tab_IForceSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_IForceSettings.InternalOnLoadINI
     End Object
     fl_DodgeTime=moFloatEdit'GUI2K4.UT2K4Tab_IForceSettings.InputDodgeTime'

     Begin Object Class=GUIButton Name=ControlBindButton
         Caption="Configure Controls"
         SizingCaption="XXXXXXXXXX"
         Hint="Configure controls and keybinds"
         WinTop=0.018333
         WinLeft=0.130000
         WinWidth=0.153281
         WinHeight=0.043750
         TabOrder=0
         OnClick=UT2K4Tab_IForceSettings.InternalOnClick
         OnKeyEvent=ControlBindButton.InternalOnKeyEvent
     End Object
     b_Controls=GUIButton'GUI2K4.UT2K4Tab_IForceSettings.ControlBindButton'

     Begin Object Class=GUIButton Name=SpeechBindButton
         Caption="Speech Binder"
         SizingCaption="XXXXXXXXXX"
         Hint="Configure custom keybinds for in-game messages"
         WinTop=0.018333
         WinLeft=0.670000
         WinWidth=0.153281
         WinHeight=0.043750
         TabOrder=1
         OnClick=UT2K4Tab_IForceSettings.InternalOnClick
         OnKeyEvent=SpeechBindButton.InternalOnKeyEvent
     End Object
     b_Speech=GUIButton'GUI2K4.UT2K4Tab_IForceSettings.SpeechBindButton'

     ControlBindMenu="GUI2K4.ControlBinder"
     SpeechBindMenu="GUI2K4.SpeechBinder"
     PanelCaption="Input"
     PropagateVisibility=False
     WinTop=0.150000
     WinHeight=0.740000
}
