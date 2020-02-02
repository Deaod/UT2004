//==============================================================================
//	Created on: 09/22/2003
//	Custom HUD settings menu for UT2K4Assault.ASGameInfo
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class CustomHUDMenuAssault extends UT2K4CustomHUDMenu;

var class<HUD_Assault> HUDClass;

var automated moCheckbox       		ch_Reticles, ch_InfoPods, ch_bShow3DArrow, ch_bDrawAllObjectives, ch_bObjectiveReminder, ch_bShowWillowWhisp;
var automated moSlider         		sl_ReticleSize;
var automated moNumericEdit   		nu_PulseTime;
var automated GUISectionBackground  sb_Main, sb_Misc;

var bool    bReticle, bInfoPods, bShow3DArrow, bDrawAllObjectives, bObjectiveReminder, bShowWillowWhisp;
var float   fReticle;
var int     iPulseTime;

var localized string MainCaption;

function bool InitializeGameClass( string GameClassName )
{
	sb_Main.ManageComponent(ch_Reticles);
	sb_Main.ManageComponent(sl_ReticleSize);

	sb_Misc.ManageComponent(ch_InfoPods);
	sb_Misc.ManageComponent(ch_bDrawAllObjectives);
	sb_Misc.ManageComponent(ch_bShow3DArrow);
	sb_Misc.Managecomponent(ch_bObjectiveReminder);
	sb_Misc.ManageComponent(nu_PulseTime);
	sb_Misc.ManageComponent(ch_bShowWillowWhisp);

	if ( GameClassName != "" )
		GameClass = class<GameInfo>(DynamicLoadObject( GameClassName, class'Class' ));

	if ( GameClass == None )
	{
		Warn(Name@"could not load specified gametype:"@GameClassName);
		return False;
	}

	if ( GameClass.default.HUDType != "" )
	{
		HUDClass = class<HUD_Assault>(DynamicLoadObject(GameClass.default.HUDType, class'Class'));
		if ( HUDClass == None )
		{
			Warn(Name@"could not load specified HUD type:"@GameClass.default.HUDType);
			return False;
		}
	}

	return True;
}

function LoadSettings()
{
	local HUD_Assault ASHUD;

	ASHUD = HUD_Assault(PlayerOwner().myHUD);
	if ( ASHUD == None )
	{
		bReticle = HUDClass.default.bOnHUDObjectiveNotification;
		ch_Reticles.SetComponentValue( bReticle, True );

		bInfoPods = HUDClass.default.bShowInfoPods;
		ch_InfoPods.SetComponentValue( bInfoPods, True );

		fReticle = HUDClass.default.ObjectiveScale;
		sl_ReticleSize.SetComponentValue( fReticle, True );

		iPulseTime = HUDClass.default.ObjectiveProgressPulseTime;
		nu_PulseTime.SetComponentValue( iPulseTime, True );

		bShow3DArrow = HUDClass.default.bShow3DArrow;
		ch_bShow3DArrow.SetComponentValue( bShow3DArrow, True );

		bObjectiveReminder = HUDClass.default.bObjectiveReminder;
		ch_bObjectiveReminder.SetComponentValue( bObjectiveReminder, True );

		bDrawAllObjectives = HUDClass.default.bDrawAllObjectives;
		ch_bDrawAllObjectives.SetComponentValue( bDrawAllObjectives, True );

		bShowWillowWhisp = HUDClass.default.bShowWillowWhisp;
		ch_bShowWillowWhisp.SetComponentValue( bShowWillowWhisp, True );
		
	}
	else
	{
		bReticle = ASHUD.bOnHUDObjectiveNotification;
		ch_Reticles.SetComponentValue( bReticle, True );

		bInfoPods = ASHUD.bShowInfoPods;
		ch_InfoPods.SetComponentValue( bInfoPods, True );

		fReticle = ASHUD.ObjectiveScale;
		sl_ReticleSize.SetComponentValue( fReticle, True );

		iPulseTime = ASHUD.ObjectiveProgressPulseTime;
		nu_PulseTime.SetComponentValue( iPulseTime, True );

		bShow3DArrow = ASHUD.bShow3DArrow;
		ch_bShow3DArrow.SetComponentValue( bShow3DArrow, True );

		bObjectiveReminder = ASHUD.bObjectiveReminder;
		ch_bObjectiveReminder.SetComponentValue( bObjectiveReminder, True );

		bDrawAllObjectives = ASHUD.bDrawAllObjectives;
		ch_bDrawAllObjectives.SetComponentValue( bDrawAllObjectives, True );

		bShowWillowWhisp = ASHUD.bShowWillowWhisp;
		ch_bShowWillowWhisp.SetComponentValue( bShowWillowWhisp, True );
	}
}

function InternalOnChange(GUIComponent Sender)
{
	switch ( Sender )
	{
	case ch_Reticles:
		bReticle = ch_Reticles.IsChecked();
		break;

	case ch_InfoPods:
		bInfoPods = ch_InfoPods.IsChecked();
		break;

	case sl_ReticleSize:
		fReticle = sl_ReticleSize.GetValue();
		break;

	case nu_PulseTime:
		iPulseTime = nu_PulseTime.GetValue();
		break;

	case ch_bShow3DArrow:
		bShow3DArrow = ch_bShow3DArrow.IsChecked();
		break;

	case ch_bObjectiveReminder:
		bObjectiveReminder = ch_bObjectiveReminder.IsChecked();
		break;

	case ch_bDrawAllObjectives:
		bDrawAllObjectives = ch_bDrawAllObjectives.IsChecked();
		break;

	case ch_bShowWillowWhisp:
		bShowWillowWhisp = ch_bShowWillowWhisp.IsChecked();
		break;
	}

	Super.InternalOnChange( Sender );
}

function SaveSettings()
{
	local bool bSave;
	local HUD_Assault ASHUD;

	Super.SaveSettings();

	ASHUD = HUD_Assault(PlayerOwner().myHUD);
	if ( ASHUD == None )
	{
		if ( HUDClass.default.bOnHUDObjectiveNotification != bReticle )
		{
			HUDClass.default.bOnHUDObjectiveNotification = bReticle;
			bSave = True;
		}

		if ( HUDClass.default.bShowInfoPods != bInfoPods )
		{
			HUDClass.default.bShowInfoPods = bInfoPods;
			bSave = True;
		}

		if ( HUDClass.default.ObjectiveScale != fReticle )
		{
			HUDClass.default.ObjectiveScale = fReticle;
			bSave = True;
		}

		if ( HUDClass.default.ObjectiveProgressPulseTime != iPulseTime )
		{
			HUDClass.default.ObjectiveProgressPulseTime = iPulseTime;
			bSave = True;
		}

		if ( HUDClass.default.bShow3DArrow != bShow3DArrow )
		{
			HUDClass.default.bShow3DArrow = bShow3DArrow;
			bSave = True;
		}

		if ( HUDClass.default.bObjectiveReminder != bObjectiveReminder )
		{
			HUDClass.default.bObjectiveReminder = bObjectiveReminder;
			bSave = True;
		}

		if ( HUDClass.default.bDrawAllObjectives != bDrawAllObjectives )
		{
			HUDClass.default.bDrawAllObjectives = bDrawAllObjectives;
			bSave = True;
		}

		if ( HUDClass.default.bShowWillowWhisp != bShowWillowWhisp )
		{
			HUDClass.default.bShowWillowWhisp = bShowWillowWhisp;
			bSave = True;
		}

		if ( bSave )
			HUDClass.static.StaticSaveConfig();
	}

	else
	{
		if ( ASHUD.bOnHUDObjectiveNotification != bReticle )
		{
			ASHUD.bOnHUDObjectiveNotification = bReticle;
			bSave = True;
		}

		if ( ASHUD.bShowInfoPods != bInfoPods )
		{
			ASHUD.bShowInfoPods = bInfoPods;
			bSave = True;
		}

		if ( ASHUD.ObjectiveScale != fReticle )
		{
			ASHUD.ObjectiveScale = fReticle;
			bSave = True;
		}

		if ( ASHUD.ObjectiveProgressPulseTime != iPulseTime )
		{
			ASHUD.ObjectiveProgressPulseTime = iPulseTime;
			bSave = True;
		}

		if ( ASHUD.bShow3DArrow != bShow3DArrow )
		{
			ASHUD.bShow3DArrow = bShow3DArrow;
			bSave = True;
		}

		if ( ASHUD.bObjectiveReminder != bObjectiveReminder )
		{
			ASHUD.bObjectiveReminder = bObjectiveReminder;
			bSave = True;
		}

		if ( ASHUD.bDrawAllObjectives != bDrawAllObjectives )
		{
			ASHUD.bDrawAllObjectives = bDrawAllObjectives;
			bSave = True;
		}

		if ( ASHUD.bShowWillowWhisp != bShowWillowWhisp )
		{
			ASHUD.bShowWillowWhisp = bShowWillowWhisp;
			bSave = True;
		}

		if ( bSave )
			ASHUD.SaveConfig();
	}
}

function RestoreDefaults()
{
	if ( HudClass != None )
	{
		HudClass.static.ResetConfig("bOnHUDObjectiveNotification");
		HudClass.static.ResetConfig("bShowInfoPods");
		HudClass.static.ResetConfig("ObjectiveScale");
		HudClass.static.ResetConfig("ObjectiveProgressPulseTime");
		HudClass.static.ResetConfig("bShow3DArrow");
		HudClass.static.ResetConfig("bObjectiveReminder");
		HudClass.static.ResetConfig("bDrawAllObjectives");
		HudClass.static.ResetConfig("bShowWillowWhisp");
		Super.RestoreDefaults();
	}
}

defaultproperties
{
     Begin Object Class=moCheckBox Name=Reticles
         ComponentJustification=TXTA_Center
         CaptionWidth=0.100000
         Caption="Objective Reticles"
         OnCreateComponent=Reticles.InternalOnCreateComponent
         Hint="Draw Objective tracking indicators."
         WinTop=0.200000
         WinLeft=0.024219
         WinWidth=0.450000
         TabOrder=0
         OnChange=CustomHUDMenuAssault.InternalOnChange
     End Object
     ch_Reticles=moCheckBox'GUI2K4.CustomHUDMenuAssault.Reticles'

     Begin Object Class=moCheckBox Name=InfoPods
         ComponentJustification=TXTA_Center
         CaptionWidth=0.100000
         Caption="Display Info Pods"
         OnCreateComponent=InfoPods.InternalOnCreateComponent
         Hint="Show Info Pods."
         WinTop=0.150000
         WinLeft=0.517383
         WinWidth=0.450000
         TabOrder=2
         OnChange=CustomHUDMenuAssault.InternalOnChange
     End Object
     ch_InfoPods=moCheckBox'GUI2K4.CustomHUDMenuAssault.InfoPods'

     Begin Object Class=moCheckBox Name=Show3DArrow
         ComponentJustification=TXTA_Center
         CaptionWidth=0.100000
         Caption="Show 3D Arrow"
         OnCreateComponent=Show3DArrow.InternalOnCreateComponent
         Hint="Draw 3D Objective tracking arrow."
         WinTop=0.450000
         WinLeft=0.024219
         WinWidth=0.450000
         TabOrder=4
         OnChange=CustomHUDMenuAssault.InternalOnChange
     End Object
     ch_bShow3DArrow=moCheckBox'GUI2K4.CustomHUDMenuAssault.Show3DArrow'

     Begin Object Class=moCheckBox Name=DrawAllObjectives
         ComponentJustification=TXTA_Center
         CaptionWidth=0.100000
         Caption="Show Full Indicators"
         OnCreateComponent=DrawAllObjectives.InternalOnCreateComponent
         Hint="Draw Indicators when Objective is behind player."
         WinTop=0.600000
         WinLeft=0.024219
         WinWidth=0.450000
         TabOrder=5
         OnChange=CustomHUDMenuAssault.InternalOnChange
     End Object
     ch_bDrawAllObjectives=moCheckBox'GUI2K4.CustomHUDMenuAssault.DrawAllObjectives'

     Begin Object Class=moCheckBox Name=ObjectiveReminder
         ComponentJustification=TXTA_Center
         CaptionWidth=0.100000
         Caption="Objective Reminder Announcer"
         OnCreateComponent=ObjectiveReminder.InternalOnCreateComponent
         Hint="Remind objective goals at respawn."
         WinTop=0.750000
         WinWidth=0.450000
         WinHeight=0.072727
         TabOrder=6
         OnChange=CustomHUDMenuAssault.InternalOnChange
     End Object
     ch_bObjectiveReminder=moCheckBox'GUI2K4.CustomHUDMenuAssault.ObjectiveReminder'

     Begin Object Class=moCheckBox Name=ShowWillowWhisp
         ComponentJustification=TXTA_Center
         CaptionWidth=0.100000
         Caption="Enable Willow Whisp"
         OnCreateComponent=ShowWillowWhisp.InternalOnCreateComponent
         Hint="Enable particle trail, showing path to objective."
         WinTop=0.600000
         WinLeft=0.024219
         WinWidth=0.450000
         TabOrder=7
         OnChange=CustomHUDMenuAssault.InternalOnChange
     End Object
     ch_bShowWillowWhisp=moCheckBox'GUI2K4.CustomHUDMenuAssault.ShowWillowWhisp'

     Begin Object Class=moSlider Name=ReticleSize
         MaxValue=4.000000
         CaptionWidth=0.100000
         Caption="Objective Indicators Scale"
         OnCreateComponent=ReticleSize.InternalOnCreateComponent
         Hint="Size scale of on HUD Objective Indicators."
         WinTop=0.400000
         WinLeft=0.024219
         WinWidth=0.450000
         TabOrder=1
         OnChange=CustomHUDMenuAssault.InternalOnChange
     End Object
     sl_ReticleSize=moSlider'GUI2K4.CustomHUDMenuAssault.ReticleSize'

     Begin Object Class=moNumericEdit Name=PulseTime
         MinValue=0
         MaxValue=99
         CaptionWidth=0.700000
         ComponentWidth=0.300000
         Caption="Objective Update Time"
         OnCreateComponent=PulseTime.InternalOnCreateComponent
         Hint="Number of seconds current Objective will be highlighted."
         WinTop=0.300000
         WinLeft=0.517383
         WinWidth=0.450000
         TabOrder=3
         OnChange=CustomHUDMenuAssault.InternalOnChange
     End Object
     nu_PulseTime=moNumericEdit'GUI2K4.CustomHUDMenuAssault.PulseTime'

     Begin Object Class=GUISectionBackground Name=ObjectiveBackground
         Caption="Objectives"
         WinTop=0.122136
         WinLeft=0.171485
         WinWidth=0.631835
         WinHeight=0.229493
         OnPreDraw=ObjectiveBackground.InternalPreDraw
     End Object
     sb_Main=GUISectionBackground'GUI2K4.CustomHUDMenuAssault.ObjectiveBackground'

     Begin Object Class=GUISectionBackground Name=MiscBackground
         Caption="Misc."
         WinTop=0.372135
         WinLeft=0.171485
         WinWidth=0.630273
         WinHeight=0.402735
         OnPreDraw=MiscBackground.InternalPreDraw
     End Object
     sb_Misc=GUISectionBackground'GUI2K4.CustomHUDMenuAssault.MiscBackground'

     Begin Object Class=GUIButton Name=CancelButton
         Caption="Cancel"
         Hint="Click to close this menu, discarding changes."
         WinTop=0.792153
         WinLeft=0.496436
         WinWidth=0.139474
         WinHeight=0.052944
         TabOrder=8
         OnClick=CustomHUDMenuAssault.InternalOnClick
         OnKeyEvent=CancelButton.InternalOnKeyEvent
     End Object
     b_Cancel=GUIButton'GUI2K4.CustomHUDMenuAssault.CancelButton'

     Begin Object Class=GUIButton Name=ResetButton
         Caption="Defaults"
         Hint="Restore all settings to their default value."
         WinTop=0.792153
         WinLeft=0.288892
         WinWidth=0.139474
         WinHeight=0.052944
         TabOrder=7
         OnClick=CustomHUDMenuAssault.InternalOnClick
         OnKeyEvent=ResetButton.InternalOnKeyEvent
     End Object
     b_Reset=GUIButton'GUI2K4.CustomHUDMenuAssault.ResetButton'

     Begin Object Class=GUIButton Name=OkButton
         Caption="OK"
         Hint="Click to close this menu, saving changes."
         WinTop=0.792153
         WinLeft=0.640437
         WinWidth=0.139474
         WinHeight=0.052944
         TabOrder=9
         OnClick=CustomHUDMenuAssault.InternalOnClick
         OnKeyEvent=OkButton.InternalOnKeyEvent
     End Object
     b_OK=GUIButton'GUI2K4.CustomHUDMenuAssault.OkButton'

     WindowName="Assault HUD Configuration"
     WinTop=0.072917
     WinLeft=0.140625
     WinWidth=0.690941
     WinHeight=0.824065
}
