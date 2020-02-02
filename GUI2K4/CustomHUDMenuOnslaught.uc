//==============================================================================
//	Created on: 09/22/2003
//	Custom HUD settings menu for Onslaught.ONSOnslaughtGame
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class CustomHUDMenuOnslaught extends UT2K4CustomHUDMenu;

var class<ONSHUDOnslaught> HUDClass;

var automated GUIImage             i_Preview, i_PreviewBlend;
var automated GUISectionBackground sb_Options, sb_Preview, sb_Position;
var automated GUILabel             l_RadarPosition;
var automated moCheckbox           ch_RadarMap, ch_NodeBeams;
var automated moSlider             sl_RadarScale, sl_IconScale, sl_RadarTrans;
var automated moFloatEdit          fl_PositionX, fl_PositionY;

var automated GUIButton            b_TogglePreview;
var() bool bPreviewRadar;

var() bool  bMapEnabled, bNodeBeams;
var() float fRadarScale, fPosX, fPosY, fIconScale, fRadarTrans;

var() localized string ShowRadarText, ShowScreenText;

// This will be used if not currently in an Onslaught map
var() string DefaultRadarTextureName;

var() Material RadarTexture;

/*
	switch ( Sender )
	{
	case ch_RadarMap:
	case ch_NodeBeams:
	case sl_IconScale:
	case sl_RadarScale:
	case sl_RadarTrans:
	case fl_PositionX:
	case fl_PositionY:
	}
*/
// =====================================================================================================================
// =====================================================================================================================
//  GUI Interface
// =====================================================================================================================
// =====================================================================================================================
function InitComponent( GUIController InController, GUIComponent InOwner )
{
	Super.InitComponent(InController,InOwner);
	UpdateToggleStatus();
}

function bool InitializeGameClass( string GameClassName )
{
	sb_Preview.ManageComponent(i_Preview);

	RadarTexture = PlayerOwner().Level.RadarMapImage;
	if ( RadarTexture == None )
		RadarTexture = material(DynamicLoadObject(DefaultRadarTextureName, class'Material'));

	i_Preview.Image = RadarTexture;
	UpdateToggleStatus();

	sb_Options.ManageComponent(ch_RadarMap);
	sb_Options.ManageComponent(ch_NodeBeams);
	sb_Options.ManageComponent(sl_RadarScale);
	sb_Options.ManageComponent(sl_IconScale);
	sb_Options.ManageComponent(sl_RadarTrans);

	if ( GameClassName != "" )
		GameClass = class<GameInfo>(DynamicLoadObject( GameClassName, class'Class' ));

	if ( GameClass == None )
	{
		Warn(Name@"could not load specified gametype:"@GameClassName);
		return False;
	}

	if ( GameClass != None )
	{
		HUDClass = class<ONSHudOnslaught>(DynamicLoadObject(GameClass.default.HUDType, class'Class'));
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
	local ONSHUDOnslaught ONSHUD;

	ONSHUD = ONSHUDOnslaught(PlayerOwner().myHUD);
	ch_NodeBeams.SetComponentValue( class'ONSPowerCore'.default.bShowNodeBeams, true );
	if ( ONSHUD == none )
	{
		bMapEnabled = !HUDClass.default.bMapDisabled;
		ch_RadarMap.SetComponentValue( bMapEnabled, true );

		bNodeBeams = class'ONSPowerCore'.default.bShowNodeBeams;
		ch_NodeBeams.SetComponentValue( bNodeBeams, true );

		fIconScale = HUDClass.default.IconScale;
		sl_IconScale.SetComponentValue( fIconScale, true );

		fRadarScale = HUDClass.default.RadarScale;
		sl_RadarScale.SetComponentValue( fRadarScale, true );
		fl_PositionX.Setup(fRadarScale, fl_PositionX.MaxValue, fl_PositionX.Step);

		fRadarTrans = HUDClass.default.RadarTrans;
		sl_RadarTrans.SetComponentValue( fRadarTrans, true );

		fPosX = HUDClass.default.RadarPosX;
		fl_PositionX.SetComponentValue( fPosX, true );

		fPosY = HUDClass.default.RadarPosY;
		fl_PositionY.SetComponentValue( fPosY, true );
	}
	else
	{
		bMapEnabled = !ONSHUD.bMapDisabled;
		ch_RadarMap.SetComponentValue( bMapEnabled, true );

		bNodeBeams = class'ONSPowerCore'.default.bShowNodeBeams;
		ch_NodeBeams.SetComponentValue( bNodeBeams, true );

		fIconScale = ONSHUD.IconScale;
		sl_IconScale.SetComponentValue( fIconScale, true );

		fRadarScale = ONSHUD.RadarScale;
		sl_RadarScale.SetComponentValue( fRadarScale, true );
		fl_PositionX.Setup(fRadarScale, fl_PositionX.MaxValue, fl_PositionX.Step);

		fRadarTrans = ONSHUD.RadarTrans;
		sl_RadarTrans.SetComponentValue( fRadarTrans, true );

		fPosX = ONSHUD.RadarPosX;
		fl_PositionX.SetComponentValue( fPosX, true );

		fPosY = ONSHUD.RadarPosY;
		fl_PositionY.SetComponentValue( fPosY, true );
	}
}

function InternalOnChange( GUIComponent Sender )
{
	switch ( Sender )
	{
	case ch_RadarMap:
		bMapEnabled = ch_RadarMap.IsChecked();
		break;

	case ch_NodeBeams:
		bNodeBeams = ch_NodeBeams.IsChecked();
		break;

	case sl_IconScale:
		fIconScale = sl_IconScale.GetValue();
		break;

	case sl_RadarScale:
		fRadarScale = sl_RadarScale.GetValue();
		fl_PositionX.Setup(fRadarScale, fl_PositionX.MaxValue, fl_PositionX.Step);
		break;

	case sl_RadarTrans:
		fRadarTrans = sl_RadarTrans.GetValue();
		break;

	case fl_PositionX:
		fPosX = fl_PositionX.GetValue();
		break;

	case fl_PositionY:
		fPosY = fl_PositionY.GetValue();
		break;
	}
}

function SaveSettings()
{
	local bool bSave, bTemp;
	local ONSPowerCore Core;
	local ONSHUDOnslaught HUD;

	super.SaveSettings();
	HUD = ONSHUDOnslaught(PlayerOwner().myHUD);

	if ( HUD == None )
	{
		if ( HUDClass.default.bMapDisabled == bMapEnabled )
		{
			HUDClass.default.bMapDisabled = !bMapEnabled;
			bSave = true;
		}

		if ( HUDClass.default.IconScale != fIconScale )
		{
			HUDClass.default.IconScale = fIconScale;
			bSave = true;
		}

		if ( HUDClass.default.RadarScale != fRadarScale )
		{
			HUDClass.default.RadarScale = fRadarScale;
			bSave = true;
		}

		if ( HUDClass.default.RadarTrans != fRadarTrans )
		{
			HUDClass.default.RadarTrans = fRadarTrans;
			bSave = true;
		}

		if ( HUDClass.default.RadarPosX != fPosX )
		{
			HUDClass.default.RadarPosX = fPosX;
			bSave = true;
		}

		if ( HUDClass.default.RadarPosY != fPosY )
		{
			HUDClass.default.RadarPosY = fPosY;
			bSave = true;
		}
	}
	else
	{
		if ( HUD.bMapDisabled == ch_RadarMap.IsChecked() )
		{
			HUD.bMapDisabled = !bMapEnabled;
			bSave = true;
		}

		if ( HUD.IconScale != fIconScale )
		{
			HUD.IconScale = fIconScale;
			bSave = true;
		}

		if ( HUD.RadarScale != fRadarScale )
		{
			HUD.RadarScale = fRadarScale;
			bSave = true;
		}

		if ( HUD.RadarTrans != fRadarTrans )
		{
			HUD.RadarTrans = fRadarTrans;
			bSave = true;
		}

		if ( HUD.RadarPosX != fPosX )
		{
			HUD.RadarPosX = fPosX;
			bSave = true;
		}

		if ( HUD.RadarPosY != fPosY )
		{
			HUD.RadarPosY = fPosY;
			bSave = true;
		}
	}

	if ( bSave )
	{
		if ( HUD != None )
			HUD.SaveConfig();
		else HUDClass.static.StaticSaveConfig();
	}

	bTemp = ch_NodeBeams.IsChecked();
	if ( class'ONSPowerCore'.default.bShowNodeBeams != bTemp )
	{
		class'ONSPowerCore'.default.bShowNodeBeams = bTemp;
		class'ONSPowerCore'.static.StaticSaveConfig();

		foreach PlayerOwner().AllActors( class'ONSPowerCore', Core )
		{
			Core.bShowNodeBeams = bTemp;
			Core.CheckShield();
		}
	}
}

function RestoreDefaults()
{
	if ( HudClass != None )
	{
		HUDClass.static.ResetConfig("bMapDisabled");
		HUDClass.static.ResetConfig("IconScale");
		HUDClass.static.ResetConfig("RadarScale");
		HUDClass.static.ResetConfig("RadarTrans");
		HUDClass.static.ResetConfig("RadarPosX");
		HUDClass.static.ResetConfig("RadarPosY");
		class'ONSPowerCore'.static.ResetConfig("bShowNodeBeams");
		UpdateToggleStatus();

		Super.RestoreDefaults();
	}
}

// =====================================================================================================================
// =====================================================================================================================
//  Map Preview
// =====================================================================================================================
// =====================================================================================================================
function bool DrawMap( Canvas C )
{
	if ( bPreviewRadar )
	{
		DrawRadar(C);
		return true;
	}

	else
	{
		DrawScreen(C);
		return false;
	}
}

function DrawRadar( Canvas C )
{
	local float HUDScale;
	local ONSHUDOnslaught ONSHUD;
	local ONSPowerCore Core;
	local PlayerController PC;
	local float AL, AT, AW, AH, X, Y, XL;
	local vector V;

	AL = i_Preview.ActualLeft();
	AT = i_Preview.ActualTop();
	AW = i_Preview.ActualWidth();
	AH = i_Preview.ActualHeight();

	PC = PlayerOwner();
	ONSHUD = ONSHUDOnslaught(PC.myHUD);
	X = AL + AW / 2.0;
	Y = AT + AH / 2.0;
	XL = FMin(AW,AH) / 2.0;

	C.Style = 5;
	if ( ONSHUD == None )
	{
		HUDScale = HUDClass.default.HUDScale;

		V.X = XL;
		V.Y = HUDClass.default.RadarMaxRange;
		V.Z = fRadarTrans;

		HUDClass.static.DrawMapImage(C,i_PreviewBlend.Image,X,Y,0,0,V);
		HUDClass.static.DrawMapImage(C,RadarTexture,X,Y,0,0,V);

		V.X = AL + AW * 0.25;
		V.Y = AT + AH * 0.25;
		HUDClass.static.DrawCoreIcon(C, V, false, fIconScale, PC.myHUD.HudScale, 1.0);

		V.X = AL + AW * 0.75;
		V.Y = AT + AH * 0.75;
		HUDClass.static.DrawCoreIcon(C, V, false, fIconScale, PC.myHUD.HudScale, 1.0);
	}
	else
	{
		HUDScale = ONSHUD.HUDScale;

		V.X = XL;
		V.Y = ONSHUD.RadarRange;
		V.Z = fRadarTrans;

		ONSHUD.DrawMapImage(C,i_PreviewBlend.Image,X,Y,0,0,V);
		ONSHUD.DrawMapImage(C, RadarTexture, X, Y, 0, 0, V);

		Core = ONSHUD.Node;
		do
		{
			ONSHUD.CoreWorldToScreen( Core, V, X, Y, XL, ONSHUD.RadarRange, vect(0,0,0) );

    	    if (Core.bUnderAttack || (Core.CoreStage == 0 && Core.bSevered))
    	    	ONSHUD.DrawAttackIcon( C, Core, V, fIconScale, ONSHUD.HUDScale, ONSHUD.ColorPercent );

    		if (Core.bFinalCore)
    			ONSHUD.DrawCoreIcon( C, V, ONSHUD.PowerCoreAttackable(Core), fIconScale, ONSHUD.HUDScale, ONSHUD.ColorPercent );
    		else
    			ONSHUD.DrawNodeIcon( C, V, ONSHUD.PowerCoreAttackable(Core), Core.CoreStage, fIconScale, ONSHUD.HUDScale, ONSHUD.ColorPercent );

			Core = Core.NextCore;
		} until ( Core == ONSHUD.Node );
	}
}

function DrawScreen(Canvas C)
{
	local ONSHUDOnslaught ONSHUD;
	local float HUDScale, RadarScale, RadarWidth, RadarPosX, RadarPosY, SizeX, SizeY;

	ONSHUD = ONSHUDOnslaught(PlayerOwner().myHUD);

	i_PreviewBlend.bBoundToParent = False;
	i_PreviewBlend.bScaleToParent = False;

	SizeX = i_PreviewBlend.ActualWidth();
	SizeY = i_PreviewBlend.ActualHeight();

	if ( ONSHUD == None )
		HUDScale = HUDClass.default.HUDScale;
	else HUDScale = ONSHUD.HUDScale;

	RadarScale = fRadarScale * HUDScale;
	RadarWidth = RadarScale * SizeX * 0.5;
	RadarPosX = i_PreviewBlend.ActualLeft() + ((fPosX * SizeX) - RadarWidth);
	RadarPosY = i_PreviewBlend.ActualTop() + ((fPosY * SizeY) + RadarWidth);

	i_Preview.SetPosition( RadarPosX, RadarPosY, RadarWidth * 2, RadarWidth * 2 );
}

function bool TogglePreview( GUIComponent c )
{
	bPreviewRadar = !bPreviewRadar;
	UpdateToggleStatus();
	return true;
}

function bool DrawBlend(Canvas C)
{
	return true;
}

function UpdateToggleStatus()
{
	if ( bPreviewRadar )
	{
		b_TogglePreview.Caption = ShowScreenText;
		DisableComponent(sl_RadarScale);
		DisableComponent(fl_PositionX);
		DisableComponent(fl_PositionY);

		EnableComponent(sl_IconScale);
		EnableComponent(sl_RadarTrans);

		i_Preview.bNeverScale = false;
		sb_Preview.bInit = true;

		i_PreviewBlend.OnDraw = DrawBlend;
	}

	else
	{
		b_TogglePreview.Caption = ShowRadarText;
		EnableComponent(sl_RadarScale);
		EnableComponent(fl_PositionX);
		EnableComponent(fl_PositionY);

		DisableComponent(sl_IconScale);
		DisableComponent(sl_RadarTrans);

		i_Preview.bNeverScale = true;
		i_PreviewBlend.OnDraw = None;
	}
}

event ResolutionChanged(int ResX, int ResY)
{
	UpdateToggleStatus();
	Super.ResolutionChanged(ResX,ResY);
}

defaultproperties
{
     Begin Object Class=GUIImage Name=RadarPreviewImage
         Image=Texture'Engine.MenuWhite'
         ImageStyle=ISTY_Scaled
         ImageAlign=IMGA_Center
         RenderWeight=0.110000
         OnDraw=CustomHUDMenuOnslaught.DrawMap
     End Object
     i_Preview=GUIImage'GUI2K4.CustomHUDMenuOnslaught.RadarPreviewImage'

     Begin Object Class=GUIImage Name=RadarPreviewBlend
         Image=Texture'Engine.MenuGray'
         ImageStyle=ISTY_Stretched
         ImageAlign=IMGA_Center
         WinTop=0.195204
         WinLeft=0.076300
         WinWidth=0.311700
         WinHeight=0.311700
     End Object
     i_PreviewBlend=GUIImage'GUI2K4.CustomHUDMenuOnslaught.RadarPreviewBlend'

     Begin Object Class=GUISectionBackground Name=OptionBackground
         Caption="Onslaught HUD Options"
         WinTop=0.040869
         WinLeft=0.416250
         WinWidth=0.562501
         WinHeight=0.931115
         bBoundToParent=True
         bScaleToParent=True
         OnPreDraw=OptionBackground.InternalPreDraw
     End Object
     sb_Options=GUISectionBackground'GUI2K4.CustomHUDMenuOnslaught.OptionBackground'

     Begin Object Class=GUISectionBackground Name=PreviewBackground
         bFillClient=True
         Caption="Preview"
         WinTop=0.040869
         WinLeft=0.022134
         WinWidth=0.385772
         WinHeight=0.699076
         bBoundToParent=True
         bScaleToParent=True
         OnPreDraw=PreviewBackground.InternalPreDraw
     End Object
     sb_Preview=GUISectionBackground'GUI2K4.CustomHUDMenuOnslaught.PreviewBackground'

     Begin Object Class=GUISectionBackground Name=RadarPositionBackground
         Caption="Radar Position"
         NumColumns=2
         WinTop=0.749726
         WinLeft=0.022134
         WinWidth=0.385772
         WinHeight=0.221081
         bBoundToParent=True
         bScaleToParent=True
         OnPreDraw=RadarPositionBackground.InternalPreDraw
     End Object
     sb_Position=GUISectionBackground'GUI2K4.CustomHUDMenuOnslaught.RadarPositionBackground'

     Begin Object Class=moCheckBox Name=EnableMap
         Caption="Enable Radar Map"
         OnCreateComponent=EnableMap.InternalOnCreateComponent
         Hint="The radar map is an bird's eye view of the current map, showing indicators for node positions and status"
         WinTop=0.116915
         WinLeft=0.479238
         WinWidth=0.436524
         WinHeight=0.060000
         TabOrder=3
         bBoundToParent=True
         bScaleToParent=True
         OnChange=CustomHUDMenuOnslaught.InternalOnChange
     End Object
     ch_RadarMap=moCheckBox'GUI2K4.CustomHUDMenuOnslaught.EnableMap'

     Begin Object Class=moCheckBox Name=NodeBeamCheck
         Caption="Show Node Beams"
         OnCreateComponent=NodeBeamCheck.InternalOnCreateComponent
         Hint="Display beams of light above nodes which are vulnerable to attack"
         WinTop=0.225805
         WinLeft=0.479238
         WinWidth=0.436524
         WinHeight=0.060000
         TabOrder=4
         bBoundToParent=True
         bScaleToParent=True
         OnChange=CustomHUDMenuOnslaught.InternalOnChange
     End Object
     ch_NodeBeams=moCheckBox'GUI2K4.CustomHUDMenuOnslaught.NodeBeamCheck'

     Begin Object Class=moSlider Name=RadarScaleSlider
         MaxValue=0.500000
         MinValue=0.100000
         Caption="Radar Map Scale"
         OnCreateComponent=RadarScaleSlider.InternalOnCreateComponent
         Hint="Change the size of the radar map on the HUD"
         WinTop=0.482552
         WinLeft=0.431807
         WinWidth=0.528751
         WinHeight=0.069779
         TabOrder=5
         bBoundToParent=True
         bScaleToParent=True
         OnChange=CustomHUDMenuOnslaught.InternalOnChange
     End Object
     sl_RadarScale=moSlider'GUI2K4.CustomHUDMenuOnslaught.RadarScaleSlider'

     Begin Object Class=moSlider Name=IconScaleSlider
         MaxValue=4.000000
         Caption="Radar Map Icon Scale"
         OnCreateComponent=IconScaleSlider.InternalOnCreateComponent
         Hint="Changes the scaling of the icons displayed on the radar map"
         WinTop=0.591833
         WinLeft=0.431807
         WinWidth=0.528751
         WinHeight=0.069779
         TabOrder=6
         bBoundToParent=True
         bScaleToParent=True
         OnChange=CustomHUDMenuOnslaught.InternalOnChange
     End Object
     sl_IconScale=moSlider'GUI2K4.CustomHUDMenuOnslaught.IconScaleSlider'

     Begin Object Class=moSlider Name=RadarTransparencySlider
         MaxValue=255.000000
         bIntSlider=True
         Caption="Radar Map Opacity"
         OnCreateComponent=RadarTransparencySlider.InternalOnCreateComponent
         Hint="Change the opacity of the radar map's background"
         WinTop=0.369622
         WinLeft=0.431807
         WinWidth=0.528751
         WinHeight=0.069779
         TabOrder=7
         bBoundToParent=True
         bScaleToParent=True
         OnChange=CustomHUDMenuOnslaught.InternalOnChange
     End Object
     sl_RadarTrans=moSlider'GUI2K4.CustomHUDMenuOnslaught.RadarTransparencySlider'

     Begin Object Class=moFloatEdit Name=RadarPosXFloat
         MinValue=0.075000
         MaxValue=1.000000
         Step=0.050000
         CaptionWidth=0.010000
         Caption="X:"
         OnCreateComponent=RadarPosXFloat.InternalOnCreateComponent
         Hint="Adjust the position (left-to-right) of the radar map"
         WinTop=0.848623
         WinLeft=0.056826
         WinWidth=0.139523
         WinHeight=0.034570
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         OnChange=CustomHUDMenuOnslaught.InternalOnChange
     End Object
     fl_PositionX=moFloatEdit'GUI2K4.CustomHUDMenuOnslaught.RadarPosXFloat'

     Begin Object Class=moFloatEdit Name=RadarPosYFloat
         MinValue=0.000000
         MaxValue=0.730000
         Step=0.050000
         CaptionWidth=0.010000
         Caption="Y:"
         OnCreateComponent=RadarPosYFloat.InternalOnCreateComponent
         Hint="Adjust the position (top-to-bottom) of the radar map"
         WinTop=0.896968
         WinLeft=0.056826
         WinWidth=0.139523
         WinHeight=0.034570
         TabOrder=1
         bBoundToParent=True
         bScaleToParent=True
         OnChange=CustomHUDMenuOnslaught.InternalOnChange
     End Object
     fl_PositionY=moFloatEdit'GUI2K4.CustomHUDMenuOnslaught.RadarPosYFloat'

     Begin Object Class=GUIButton Name=ToggleButton
         bWrapCaption=True
         WinTop=0.771852
         WinLeft=0.218035
         WinWidth=0.160937
         WinHeight=0.098412
         TabOrder=2
         OnClick=CustomHUDMenuOnslaught.TogglePreview
         OnKeyEvent=ToggleButton.InternalOnKeyEvent
     End Object
     b_TogglePreview=GUIButton'GUI2K4.CustomHUDMenuOnslaught.ToggleButton'

     bPreviewRadar=True
     ShowRadarText="Show Only Radar"
     ShowScreenText="Show Entire Screen"
     DefaultRadarTextureName="ONS-Torlan.myLevel.BackgroundImage"
     Begin Object Class=GUIButton Name=CancelButton
         Caption="Cancel"
         Hint="Click to close this menu, discarding changes."
         WinTop=0.898800
         WinLeft=0.658306
         WinWidth=0.136349
         WinHeight=0.063881
         TabOrder=9
         bBoundToParent=True
         bScaleToParent=True
         bStandardized=True
         OnClick=CustomHUDMenuOnslaught.InternalOnClick
         OnKeyEvent=CancelButton.InternalOnKeyEvent
     End Object
     b_Cancel=GUIButton'GUI2K4.CustomHUDMenuOnslaught.CancelButton'

     Begin Object Class=GUIButton Name=ResetButton
         Caption="Defaults"
         Hint="Restore all settings to their default value."
         WinTop=0.898800
         WinLeft=0.465241
         WinWidth=0.136349
         WinHeight=0.063881
         TabOrder=8
         bBoundToParent=True
         bScaleToParent=True
         bStandardized=True
         OnClick=CustomHUDMenuOnslaught.InternalOnClick
         OnKeyEvent=ResetButton.InternalOnKeyEvent
     End Object
     b_Reset=GUIButton'GUI2K4.CustomHUDMenuOnslaught.ResetButton'

     Begin Object Class=GUIButton Name=OkButton
         Caption="OK"
         Hint="Click to close this menu, saving changes."
         WinTop=0.898800
         WinLeft=0.802881
         WinWidth=0.136349
         WinHeight=0.063881
         TabOrder=10
         bBoundToParent=True
         bScaleToParent=True
         bStandardized=True
         OnClick=CustomHUDMenuOnslaught.InternalOnClick
         OnKeyEvent=OkButton.InternalOnKeyEvent
     End Object
     b_OK=GUIButton'GUI2K4.CustomHUDMenuOnslaught.OkButton'

     WinTop=0.050000
     WinLeft=0.029688
     WinWidth=0.944062
     WinHeight=0.867814
}
