//==============================================================================
//	Description
//
//	Created by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UT2K4Tab_DetailSettings extends Settings_Tabs;

struct DisplayMode
{
	var int	Width,
			Height;
};

const RENDERMODECOUNT = 2;

var() DisplayMode 		DisplayModes[17];
var() localized string	BitDepthText[2];
var() localized string	DetailLevels[9];
var() localized string  ShadowOptions[3];
var() localized string  RenderModeText[RENDERMODECOUNT];
var() string            RenderMode[RENDERMODECOUNT];
var() string            DisplayPromptMenu;
var() bool		        bPlayedSound;

var automated GUISectionBackground sb_Section1, sb_Section2, sb_Section3;

var automated GUIImage i_Gamma, i_GammaBar;
var automated moComboBox	co_Texture, co_Char, co_World, co_Physics, co_Decal, co_MeshLOD,
							co_Resolution, co_ColorDepth, co_RenderDevice, co_Shadows;

var automated moCheckBox	ch_Decals, ch_DynLight, ch_Coronas,
							ch_Textures, ch_Projectors, ch_DecoLayers,
							ch_Trilinear, ch_FullScreen, ch_Weather;


var automated moSlider		sl_Gamma, sl_Brightness, sl_Contrast, sl_DistanceLOD;

// Instance values
var() noexport transient string sRes, sResD, sRenDev, sRenDevD;
var() noexport transient float fGamma, fBright, fContrast, fDistance, fDistanceD;
var() noexport transient bool bDecal, bDynLight, bTexture, bCorona, bTrilin,
                              bProj, bFol, bFullScreen, bWeather,
							  bDecalD, bDynLightD, bTextureD, bCoronaD, bTrilinD,
							  bProjD, bFolD, bFullScreenD, bWeatherD;
var() noexport transient int iColDepth, iTexture, iChar, iPhys, iWorld, iDecal, iShadow, iMeshLOD,
                             iColDepthD, iTextureD, iCharD, iWorldD, iPhysD, iDecalD, iShadowD, iMeshLODD;

var() private noexport editconst transient bool bDemo;
var() noexport bool bIgnoreResNotice, bInvalidRes, bIgnoreChange;
var() localized string RelaunchQuestion, InvalidSelectionText;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	bDemo = PlayerOwner().Level.IsDemoBuild();

	InitializeCombos();
	SetupPositions();
}

event Opened(GUIComponent Sender)
{
	Super.Opened(Sender);

	CheckSupportedResolutions();
}

function ShowPanel(bool bShow)
{
	Super.ShowPanel(bShow);

	if ( bShow )
		CheckSliders();
}

function InitializeCombos()
{
	local int i;
	local array<GUIListElem> Options;

	for (i = 0; i < Components.Length; i++)
	{
		if (moComboBox(Components[i]) != None)
		{
			GetComboOptions( moComboBox(Components[i]), Options );
			moComboBox(Components[i]).MyComboBox.List.Elements = Options;
			moComboBox(Components[i]).MyComboBox.List.ItemCount = Options.Length;
			moComboBox(Components[i]).ReadOnly(True);
		}
	}

	if ( !bDemo )
	{
		co_Texture.MyComboBox.MaxVisibleItems = 9;
		co_Char.MyComboBox.MaxVisibleItems = 9;
	}
}

function CheckSliders()
{
	// SDLDrv can adjust gamma ramps in a Window, WinDrv can't...  --ryan.
	if ( ( bFullscreen ) || ( !PlatformIsWindows() ) )
	{
		EnableComponent(sl_Gamma);
		EnableComponent(sl_Contrast);
		EnableComponent(sl_Brightness);
	}

	else
	{
		DisableComponent(sl_Gamma);
		DisableComponent(sl_Contrast);
		DisableComponent(sl_Brightness);
	}
}

function SetupPositions()
{
    sb_Section1.ManageComponent(co_RenderDevice);
	sb_Section1.ManageComponent(co_Resolution);
    sb_Section1.ManageComponent(co_ColorDepth);
    sb_Section1.ManageComponent(ch_Fullscreen);
    sb_Section1.ManageComponent(sl_Gamma);
    sb_Section1.ManageComponent(sl_Brightness);
    sb_Section1.ManageComponent(sl_Contrast);

    sb_Section2.Managecomponent(co_Texture);
    sb_Section2.ManageComponent(co_Char);
    sb_Section2.ManageComponent(co_World);
    sb_Section2.ManageComponent(co_Physics);
	sb_Section2.ManageComponent(co_Decal);
    sb_Section2.ManageComponent(co_Shadows);
    sb_Section2.ManageComponent(co_MeshLOD);
    sb_Section2.ManageComponent(ch_Decals);
    sb_Section2.ManageComponent(ch_DynLight);
    sb_Section2.ManageComponent(ch_Coronas);
    sb_Section2.ManageComponent(ch_Textures);
    sb_Section2.ManageComponent(ch_Projectors);
    sb_Section2.ManageComponent(ch_DecoLayers);
    sb_Section2.ManageComponent(ch_Trilinear);
    sb_Section2.ManageComponent(ch_Weather);
    sb_Section2.ManageComponent(sl_DistanceLOD);

	sb_Section3.ManageComponent(i_GammaBar);
}

function CheckSupportedResolutions()
{
	local int		i, Index, BitDepth;
	local string	CurrentSelection, Str, W, H, WH;
	local bool 		bStandard, bSupported, bOldIgnoreChange;
	local PlayerController PC;

	PC = PlayerOwner();
	CurrentSelection = co_Resolution.GetText();

	// Disable all notifications!!
	bOldIgnoreChange = bIgnoreChange;
	bIgnoreChange = True;

	if (co_ColorDepth != None && co_ColorDepth.ItemCount() > 0)
		BitDepth = int(Left(co_ColorDepth.GetText(), 2));

	// Don't let user create non-fullscreen window bigger than highest
	//  supported resolution, or MacOS X client crashes. --ryan.
	for(i = 0; i < ArrayCount(DisplayModes); i++)
	{
		W = string(DisplayModes[i].Width);
		H = string(DisplayModes[i].Height);
		WH = W $ "x" $ H;

		Str = "SUPPORTEDRESOLUTION WIDTH="$W@"HEIGHT="$H@"BITDEPTH="$BitDepth;

		if (CurrentSelection ~= WH)
			bStandard = True;

		Index = co_Resolution.FindIndex(WH);
		bSupported = bool(PC.ConsoleCommand(Str));

		if ( !bSupported && co_Resolution.MyComboBox.List.IsValidIndex(Index) )
			co_Resolution.RemoveItem(Index, 1);

		else if ( bSupported && !co_Resolution.MyComboBox.List.IsValidIndex(Index) )
			AddNewResolution(WH);
	}

	if (!bStandard)
	{
		Divide(CurrentSelection, "x", W, H);

		Str = "SUPPORTEDRESOLUTION WIDTH="$W@"HEIGHT="$H@"BITDEPTH="$BitDepth;
		bSupported = bool(PC.ConsoleCommand(Str));
		if ( !bSupported )
		{
			Index = co_Resolution.FindIndex(CurrentSelection);
			bInvalidRes = True;
		}
	}

	CheckSliders();
	co_Resolution.SetText(CurrentSelection);
	bIgnoreChange = bOldIgnoreChange;
}

function bool InternalOnPreDraw(Canvas C)
{
	if ( Controller.ActivePage == PageOwner && bInvalidRes )
	{
		bInvalidRes = False;
		Controller.OpenMenu("GUI2K4.UT2K4GenericMessageBox","",InvalidSelectionText);
	}

	return False;
}

function ResolutionChanged(int NewX, int NewY)
{
	if ( !bIgnoreResNotice )
	{
		if ( Controller.ActivePage == PageOwner )
			PageOwner.CheckResolution(false, Controller);

		Refresh();
	}
	else
		InternalOnLoadINI(co_ColorDepth,"");
}

function Refresh()
{
	InternalOnLoadINI(co_Resolution,"");
	InternalOnLoadINI(co_ColorDepth,"");
	InternalOnLoadINI(ch_FullScreen,"");
	CheckSupportedResolutions();
}

function int AddNewResolution(string NewDisplayMode)
{
	local int i, ItemW, ItemH, InWidth, InHeight;
	local bool bTemp;
	local string Str, StrW, StrH;

	bTemp = bIgnoreChange;
	bIgnoreChange = True;

	// first, find out if this resolution exists already
	i = co_Resolution.FindIndex(NewDisplayMode);
	if (i >= 0)
	{
		bIgnoreChange = bTemp;
		return i;
	}

	Divide(NewDisplayMode, "x", StrW, StrH);

	InWidth = int(StrW);
	InHeight = int(StrH);

	// not there, so add it in the appropriate spot
	for (i = 0; i < co_Resolution.ItemCount(); i++)
	{
		Str = co_Resolution.GetItem(i);
		Divide(Str, "x", StrW, StrH);

		ItemW = int(StrW);
		ItemH = int(StrH);

		if ( ItemW == InWidth )
		{
			if ( ItemH > InHeight )
				break;
		}

		else if ( ItemW > InWidth )
			break;
	}

	if (i == co_Resolution.ItemCount())
		co_Resolution.AddItem(NewDisplayMode);

	else
		co_Resolution.MyComboBox.List.Insert(i, NewDisplayMode);

	bIgnoreChange = bTemp;
	return i;
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
	local bool a, b;
	local int i;
	local PlayerController PC;
	local string tempStr;

	PC = PlayerOwner();
	switch (Sender)
	{
	case co_Texture:
		s = GetGUIString(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager TextureDetailWorld"));
		iTexture = co_Texture.FindIndex(s);
		iTextureD = iTexture;
		co_Texture.SilentSetIndex(iTexture);
		break;

	case co_Char:
		s = GetGUIString(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager TextureDetailPlayerSkin"));
		iChar = co_Char.FindIndex(s);
		iCharD = iChar;
		co_Char.SilentSetIndex(iChar);
		break;

	case co_World:
		a = bool(PC.ConsoleCommand("get ini:Engine.Engine.RenderDevice HighDetailActors"));
		b = bool(PC.ConsoleCommand("get ini:Engine.Engine.RenderDevice SuperHighDetailActors"));

		if(b)
			iWorld = 5;
		else if(a)
			iWorld = 4;
		else
			iWorld = 3;

		iWorldD = iWorld;
		i = co_World.FindIndex(DetailLevels[iWorld]);
		if ( i != -1 )
			co_World.SilentSetIndex(i);

		break;

	case co_MeshLOD:
		switch ( class'LevelInfo'.default.MeshLODDetailLevel )
		{
		case MDL_Low:    iMeshLOD = 3; break;
		case MDL_Medium: iMeshLOD = 4; break;
		case MDL_High:   iMeshLOD = 5; break;
		case MDL_Ultra:  iMeshLOD = 8; break;
		}

		iMeshLODD = iMeshLOD;

		i = co_MeshLOD.FindIndex(DetailLevels[iMeshLOD]);
		if ( i != -1 )
			co_MeshLOD.SilentSetIndex(i);
		break;


	case co_Physics:
		if(class'LevelInfo'.default.PhysicsDetailLevel == PDL_Low)
		{
			iPhys = 3;
			i = co_Physics.FindIndex(DetailLevels[3]);
			if ( i != -1 )
				co_Physics.SilentSetIndex(i);
		}
		else if(class'LevelInfo'.default.PhysicsDetailLevel == PDL_Medium)
		{
			iPhys = 4;
			i = co_Physics.FindIndex(DetailLevels[4]);
			if ( i != -1 )
				co_Physics.SilentSetIndex(i);
		}
		else
		{
			iPhys = 5;
			i = co_Physics.FindIndex(DetailLevels[5]);
			if ( i != -1 )
				co_Physics.SilentSetIndex(i);
		}

		iPhysD = iPhys;
		break;

	case co_Decal:
		iDecal = class'LevelInfo'.default.DecalStayScale;
		iDecalD = iDecal;
		co_Decal.SilentSetIndex(iDecal);
		break;

	case co_Resolution:
		// Resolution
		// GameResolution is set if menu requires 640x480 but current resolution is smaller than that
		if(Controller.GameResolution != "")
			sRes = Controller.GameResolution;
		else sRes = Controller.GetCurrentRes();
		sResD = sRes;
		i = AddNewResolution(sRes);

		if ( i >= 0 && i < co_Resolution.ItemCount() )
			co_Resolution.SilentSetIndex(i);
		break;

	case co_ColorDepth:
		if (bool(PC.ConsoleCommand("get ini:Engine.Engine.RenderDevice Use16bit")))
			iColDepth = 0;
		else iColDepth = 1;
		iColDepthD = iColDepth;
		co_ColorDepth.SilentSetIndex(iColDepth);

		if (! bool(PC.ConsoleCommand("ISFULLSCREEN")) )
			co_ColorDepth.DisableMe();
		else
			co_ColorDepth.EnableMe();

		break;

	case co_RenderDevice:
		sRenDev = GetNativeClassName("Engine.Engine.RenderDevice");
		sRenDevD = sRenDev;
		co_RenderDevice.SetComponentValue(sRenDev,true);
		break;

	case co_Shadows:
		tempStr = GetNativeClassName("Engine.Engine.RenderDevice");

		// No render-to-texture on anything but Direct3D and maybe OpenGL.
		if ((tempStr == "D3DDrv.D3DRenderDevice") ||
		    (tempStr == "D3D9Drv.D3D9RenderDevice") ||
		    (tempStr == "OpenGLDrv.OpenGLRenderDevice"))
		{
			a = bool(PC.ConsoleCommand("get UnrealGame.UnrealPawn bPlayerShadows"));
			b = bool(PC.ConsoleCommand("get UnrealGame.UnrealPawn bBlobShadow"));

			if ( b )
				iShadow = 1;
			else if (a)
				iShadow = 2;
			else
				iShadow = 0;
		}
        else
		{
			b = bool(PC.ConsoleCommand("get UnrealGame.UnrealPawn bBlobShadow"));
			if ( b )
				iShadow = 1;
			else
				iShadow = 0;
		}

		iShadowD = iShadow;
		co_Shadows.SilentSetIndex(iShadow);
		break;

	case ch_DynLight:
		bDynLight = !bool(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager NoDynamicLights"));
		bDynLightD = bDynLight;
		ch_DynLight.SetComponentValue(bDynLight,true);
		break;

	case ch_FullScreen:
		bFullScreen = bool(PC.ConsoleCommand("ISFULLSCREEN"));
		bFullScreenD = bFullScreen;
		moCheckBox(Sender).SetComponentValue(bFullScreen,true);
		break;

	case ch_Trilinear:
		bTrilin = bool(PC.ConsoleCommand("get ini:Engine.Engine.RenderDevice UseTrilinear"));
		bTrilinD = bTrilin;
		ch_Trilinear.SetComponentValue(bTrilin,true);
		break;

	case ch_Projectors:
		bProj = bool(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager Projectors"));
		bProjD = bProj;
		ch_Projectors.SetComponentValue(bProj,true);
		break;

	case ch_DecoLayers:
		bFol = bool(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager DecoLayers"));
		bFolD = bFol;
		ch_DecoLayers.SetComponentValue(bFol,true);
		break;

	case ch_Textures:
		bTexture = bool(PC.ConsoleCommand("get ini:Engine.Engine.RenderDevice DetailTextures"));
		bTextureD = bTexture;
		ch_Textures.SetComponentValue(bTexture,true);
		break;

	case ch_Coronas:
		bCorona = bool(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager Coronas"));
		bCoronaD = bCorona;
		ch_Coronas.SetComponentValue(bCorona,true);
		break;

	case ch_Decals:
		bDecal = bool(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager Decals"));
		bDecalD = bDecal;
		ch_Decals.SetComponentValue(bDecal,true);

		UpdateDecalStay();
		break;

	case sl_Gamma:
		fGamma = float(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager Gamma"));
		sl_Gamma.SetComponentValue(fGamma,true);
		break;

	case sl_Brightness:
		fBright = float(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager Brightness"));
		sl_Brightness.SetComponentValue(fBright,true);
		break;

	case sl_Contrast:
		fContrast = float(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager Contrast"));
		sl_Contrast.SetComponentValue(fContrast,true);
		break;

	case ch_Weather:
		bWeather = bool(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager WeatherEffects"));
		bWeatherD = bWeather;
		ch_Weather.SetComponentValue(bWeather,true);
		break;

	case sl_DistanceLOD:
		fDistance = float(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager DrawDistanceLOD"));
		fDistanceD = fDistance;
		sl_DistanceLOD.SetComponentValue(fDistance,true);
		break;

	default:
		log(Name@"Unknown component calling LoadINI:"$ GUIMenuOption(Sender).Caption);
		GUIMenuOption(Sender).SetComponentValue(s,true);
	}
}

function ResetClicked()
{
	local int i;

	Super.ResetClicked();

	class'LevelInfo'.static.ResetConfig("MeshLODDetailLevel");
	class'LevelInfo'.static.ResetConfig("PhysicsDetailLevel");
	class'LevelInfo'.static.ResetConfig("DecalStayScale");

	class'UnrealPawn'.static.ResetConfig("bPlayerShadows");
	class'UnrealPawn'.static.ResetConfig("bBlobShadow");

	ResetViewport();
	ResetRenderDevice();

	for (i = 0; i < Components.Length; i++)
		Components[i].LoadINI();
}

function ResetViewport()
{
	local class<Client> ViewportClass;

	ViewportClass = class<Client>(DynamicLoadObject(GetNativeClassName("Engine.Engine.ViewportManager"), class'Class'));

	ViewportClass.static.ResetConfig("WindowedViewportX");
	ViewportClass.static.ResetConfig("WindowedViewportY");
	ViewportClass.static.ResetConfig("FullscreenViewportX");
	ViewportClass.static.ResetConfig("FullscreenViewportY");
	ViewportClass.static.ResetConfig("Brightness");
	ViewportClass.static.ResetConfig("Contrast");
	ViewportClass.static.ResetConfig("Gamma");
	ViewportClass.static.ResetConfig("StartupFullScreen");
	ViewportClass.static.ResetConfig("NoLighting");
	ViewportClass.static.ResetConfig("MinDesiredFrameRate");
	ViewportClass.static.ResetConfig("Decals");
	ViewportClass.static.ResetConfig("Coronas");
	ViewportClass.static.ResetConfig("DecoLayers");
	ViewportClass.static.ResetConfig("Projectors");
	ViewportClass.static.ResetConfig("NoDynamicLights");
	ViewportClass.static.ResetConfig("ReportDynamicUploads");
	ViewportClass.static.ResetConfig("TextureDetailInterface");
	ViewportClass.static.ResetConfig("TextureDetailTerrain");
	ViewportClass.static.ResetConfig("TextureDetailWeaponSkin");
	ViewportClass.static.ResetConfig("TextureDetailPlayerSkin");
	ViewportClass.static.ResetConfig("TextureDetailWorld");
	ViewportClass.static.ResetConfig("TextureDetailRendermap");
	ViewportClass.static.ResetConfig("TextureDetailLightmap");
	ViewportClass.static.ResetConfig("NoFractalAnim");
	ViewportClass.static.ResetConfig("WeatherEffects");
	ViewportClass.static.ResetConfig("DrawDistanceLOD");
}

function ResetRenderDevice()
{
	local class<RenderDevice>	RenderClass;

	if ( !(sRenDev ~= sRenDevD) )
		Controller.SetRenderDevice(sRenDevD);

	RenderClass = class<RenderDevice>(DynamicLoadObject(sRenDevD, class'Class'));
	RenderClass.static.ResetConfig("DetailTextures");
	RenderClass.static.ResetConfig("HighDetailActors");
	RenderClass.static.ResetConfig("SuperHighDetailActors");
	RenderClass.static.ResetConfig("UsePrecaching");
	RenderClass.static.ResetConfig("UseTrilinear");
	RenderClass.static.ResetConfig("UseTripleBuffering");
	RenderClass.static.ResetConfig("UseHardwareTL");
	RenderClass.static.ResetConfig("UseHardwareVS");
	RenderClass.static.ResetConfig("UseCubemaps");
	RenderClass.static.ResetConfig("DesiredRefreshRate");
	RenderClass.static.ResetConfig("UseCompressedLightmaps");
	RenderClass.static.ResetConfig("UseStencil");
	RenderClass.static.ResetConfig("Use16bit");
	RenderClass.static.ResetConfig("Use16bitTextures");
	RenderClass.static.ResetConfig("MaxPixelShaderVersion");
	RenderClass.static.ResetConfig("UseVSync");
	RenderClass.static.ResetConfig("LevelOfAnisotropy");
	RenderClass.static.ResetConfig("DetailTexMipBias");
	RenderClass.static.ResetConfig("DefaultTexMipBias");
	RenderClass.static.ResetConfig("UseNPatches");
	RenderClass.static.ResetConfig("TesselationFactor");
	RenderClass.static.ResetConfig("CheckForOverflow");
	RenderClass.static.ResetConfig("AvoidHitches");
	RenderClass.static.ResetConfig("OverrideDesktopRefreshRate");

}

function SaveSettings()
{
	local string t, v, Str;
	local PlayerController PC;
	local bool bUnreal, bLevel;

	Super.SaveSettings();

	PC = PlayerOwner();

	if ( sRenDev != sRenDevD )
	{
		if ( Controller.SetRenderDevice(sRenDev) )
			sRenDevD = sRenDev;
	}

	if (iTexture != iTextureD)
	{
		t = "set ini:Engine.Engine.ViewportManager TextureDetail";

		Str = DetailLevels[iTexture];
		v = GetConfigString(Str);
		PC.ConsoleCommand(t$"Terrain"@v);
		PC.ConsoleCommand(t$"World"@v);
		PC.ConsoleCommand(t$"Rendermap"@v);
		PC.ConsoleCommand(t$"Lightmap"@v);
		PC.ConsoleCommand("flush");
		iTextureD = iTexture;
	}

	if (iChar != iCharD)
	{
		t = "set ini:Engine.Engine.ViewportManager TextureDetail";

		Str = DetailLevels[iChar];
		v = GetConfigString(Str);

		PC.ConsoleCommand(t$"WeaponSkin"@v);
		PC.ConsoleCommand(t$"PlayerSkin"@v);
		PC.ConsoleCommand("flush");

		iCharD = iChar;
	}

	if (iWorld != iWorldD)
	{
		Str = DetailLevels[iWorld];
		v = GetConfigString(Str);

		switch (iWorld)
		{
			case 3:
				PC.ConsoleCommand("set ini:Engine.Engine.RenderDevice HighDetailActors False");
				PC.ConsoleCommand("set ini:Engine.Engine.RenderDevice SuperHighDetailActors False");
				PC.Level.DetailChange(DM_Low);
				break;

			case 4:
				PC.ConsoleCommand("set ini:Engine.Engine.RenderDevice HighDetailActors True");
				PC.ConsoleCommand("set ini:Engine.Engine.RenderDevice SuperHighDetailActors False");
				PC.Level.DetailChange(DM_High);
				break;

			case 5:
				PC.ConsoleCommand("set ini:Engine.Engine.RenderDevice HighDetailActors True");
				PC.ConsoleCommand("set ini:Engine.Engine.RenderDevice SuperHighDetailActors True");
				PC.Level.DetailChange(DM_SuperHigh);
				break;
		}

		iWorldD = iWorld;
	}

	if ( iMeshLOD != iMeshLODD )
	{
		switch (iMeshLOD)
		{
		case 3:
			class'LevelInfo'.default.MeshLODDetailLevel = MDL_Low;
			PC.Level.MeshLODDetailLevel = MDL_Low;
			break;
		case 4:
			class'LevelInfo'.default.MeshLODDetailLevel = MDL_Medium;
			PC.Level.MeshLODDetailLevel = MDL_Medium;
			break;

		case 5:
			class'LevelInfo'.default.MeshLODDetailLevel = MDL_High;
			PC.Level.MeshLODDetailLevel = MDL_High;
			break;
		case 8:
			class'LevelInfo'.default.MeshLODDetailLevel = MDL_Ultra;
			PC.Level.MeshLODDetailLevel = MDL_Ultra;
			break;
		}

		iMeshLODD = iMeshLOD;
		bLevel = True;
	}

	if (iPhys != iPhysD)
	{
		switch (iPhys)
		{
			case 3:
				class'LevelInfo'.default.PhysicsDetailLevel = PDL_Low;
				PC.Level.PhysicsDetailLevel = PDL_Low;
				break;

			case 4:
				class'LevelInfo'.default.PhysicsDetailLevel = PDL_Medium;
				PC.Level.PhysicsDetailLevel = PDL_Medium;
				break;

			case 5:
				class'LevelInfo'.default.PhysicsDetailLevel = PDL_High;
				PC.Level.PhysicsDetailLevel = PDL_High;
				break;
		}

		iPhysD = iPhys;
		bLevel = True;
	}

	if ( iShadow != iShadowD )
	{
		if ( PC.Pawn != None && UnrealPawn(PC.Pawn) != None )
		{
			UnrealPawn(PC.Pawn).bBlobShadow = iShadow == 1;
			UnrealPawn(PC.Pawn).bPlayerShadows = iShadow > 0;
		}

		class'UnrealPawn'.default.bBlobShadow = iShadow == 1;
		class'UnrealPawn'.default.bPlayerShadows = iShadow > 0;
		iShadowD = iShadow;
		bUnreal = True;
	}

	if ( class'Vehicle'.default.bVehicleShadows != (iShadow > 0) )
	{
		class'Vehicle'.default.bVehicleShadows = iShadow > 0;
		class'Vehicle'.static.StaticSaveConfig();
	}

	if (bDynLight != bDynLightD)
	{
		PC.ConsoleCommand("set ini:Engine.Engine.ViewportManager NoDynamicLights"@!bDynLight);
		bDynLightD = bDynLight;
	}

	if (iDecal != iDecalD)
	{
		if (PC.Level != None)
			PC.Level.DecalStayScale = iDecal;

		class'LevelInfo'.default.DecalStayScale = iDecal;

		iDecalD = iDecal;
		bLevel = True;
	}

	if (bTrilin != bTrilinD)
	{
		PC.ConsoleCommand("set ini:Engine.Engine.RenderDevice UseTrilinear"@bTrilin);
		bTrilinD = bTrilin;
	}

	if (bFol != bFolD)
	{
		PC.ConsoleCommand("set ini:Engine.Engine.ViewportManager DecoLayers"@bFol);
		bFolD = bFol;
	}


	if (bProj != bProjD)
	{
		PC.ConsoleCommand("set ini:Engine.Engine.ViewportManager Projectors"@bProj);
		bProjD = bProj;
	}

	if (bTexture != bTextureD)
	{
		PC.ConsoleCommand("set ini:Engine.Engine.RenderDevice DetailTextures"@bTexture);
		bTextureD = bTexture;
	}

	if (bCorona != bCoronaD)
	{
		PC.ConsoleCommand("set ini:Engine.Engine.ViewportManager Coronas"@bCorona);
		bCoronaD = bCorona;
	}

	if (bDecal != bDecalD)
	{
		PC.ConsoleCommand("set ini:Engine.Engine.ViewportManager Decals"@bDecal);
		bDecalD = bDecal;
	}

	if (bWeather != bWeatherD)
	{
		PC.ConsoleCommand("set ini:Engine.Engine.ViewportManager WeatherEffects"@bWeather);
		bWeatherD = bWeather;
	}

	if ( fDistance != fDistanceD )
	{
		PC.ConsoleCommand("set ini:Engine.Engine.ViewportManager DrawDistanceLOD" @ fDistance);
		PC.Level.UpdateDistanceFogLOD(fDistance);
		fDistanceD = fDistance;
	}

	if (bUnreal)
	{
		if (PC.Pawn != None && UnrealPawn(PC.Pawn) != None)
			UnrealPawn(PC.Pawn).SaveConfig();

		else class'UnrealPawn'.static.StaticSaveConfig();
	}

	if (bLevel)
	{
		if (PC.Level != None)
			PC.Level.SaveConfig();
		else class'LevelInfo'.static.StaticSaveConfig();
	}
}

function InternalOnChange(GUIComponent Sender)
{
	local string str;
	local bool bGoingUp;
	local int i;
	local sound snd;

	Super.InternalOnChange(Sender);

	if ( bIgnoreChange )
		return;

	switch (Sender)
	{
		// These changes take effect immediately
		case co_Resolution:
			sRes = co_Resolution.GetText();
			if (bFullScreen)
				str = "f";
			else
				str = "w";

			if (Controller.OpenMenu(DisplayPromptMenu))
			{
				bIgnoreResNotice = True;
				UT2K4VideoChangeOK(Controller.ActivePage).OnClose = VideoChangeClose;
				UT2K4VideoChangeOK(Controller.ActivePage).Execute(sRes$"x"$Left(BitDepthText[iColDepth], 2)$str);
			}
			break;

		case ch_FullScreen:
			bFullScreen = ch_FullScreen.IsChecked();
			if (bFullScreen)
				str = "f";
			else
				str = "w";

			if (Controller.OpenMenu(DisplayPromptMenu))
			{
				bIgnoreResNotice = True;
				UT2K4VideoChangeOK(Controller.ActivePage).OnClose = VideoChangeClose;
				UT2K4VideoChangeOK(Controller.ActivePage).Execute(sRes$"x"$Left(BitDepthText[iColDepth], 2)$str);
			}
			break;

		case co_RenderDevice:
			sRenDev = co_RenderDevice.GetExtra();
			if ( sRenDev != sRenDevD && Controller.OpenMenu(Controller.QuestionMenuClass) )
			{
				GUIQuestionPage(Controller.ActivePage).SetupQuestion(RelaunchQuestion, QBTN_YesNoCancel, QBTN_Cancel);
				GUIQuestionPage(Controller.ActivePage).NewOnButtonClick = RenderDeviceClick;
			}
			break;

		case co_ColorDepth:
			iColDepth = co_ColorDepth.GetIndex();
			if (bFullScreen)
				str = "f";
			else
				str = "w";

			if (Controller.OpenMenu(DisplayPromptMenu))
			{
				bIgnoreResNotice = True;
				UT2K4VideoChangeOK(Controller.ActivePage).OnClose = VideoChangeClose;
				UT2K4VideoChangeOK(Controller.ActivePage).Execute(sRes$"x"$Left(BitDepthText[iColDepth], 2)$str);
			}
			break;


		// These changes are saved all together during SaveSettings()
		case co_Texture:
			i = co_Texture.GetIndex();
			bGoingUp = i > iTexture && i != iTextureD;
			iTexture = i;
			break;

		case co_Char:
			i = co_Char.GetIndex();
			bGoingUp = i > iChar && i != iCharD;
			iChar = i;
			break;

		case co_World:
			str = co_World.GetText();
			i = GetDetailIndex(str);
			bGoingUp = i > iWorld && i != iWorldD;
			iWorld = i;
			break;

		case co_MeshLOD:
			str = co_MeshLOD.GetText();
			i = GetDetailIndex(str);
			bGoingUp = i > iMeshLOD && i != iMeshLODD;
			iMeshLOD = i;
			break;

		case co_Physics:
			str = co_Physics.GetText();
			i = GetDetailIndex(str);
			bGoingUp = i > iPhys && i != iPhysD;
			iPhys = i;
			break;

		case co_Decal:
			iDecal = co_Decal.GetIndex();
			break;

		case co_Shadows:
			i = co_Shadows.GetIndex();
			bGoingUp = i > iShadow && i != iShadowD;
			iShadow = i;
			break;

		case ch_DynLight:
			bDynLight = ch_DynLight.IsChecked();
			bGoingUp = bDynLight && bDynLight != bDynLightD;
			break;

		case ch_Trilinear:
			bTrilin = ch_Trilinear.IsChecked();
			bGoingUp = bTrilin && bTrilin != bTrilinD;
			break;

		case ch_Projectors:
			bProj = ch_Projectors.IsChecked();
			bGoingUp = bProj && bProjD != bProj;
			break;

		case ch_DecoLayers:
			bFol = ch_DecoLayers.IsChecked();
			bGoingUp = bFol && bFol != bFolD;
			break;

		case ch_Textures:
			bTexture = ch_Textures.IsChecked();
			bGoingUp = bTexture && bTexture != bTextureD;
			break;

		case ch_Coronas:
			bCorona = ch_Coronas.IsChecked();
			bGoingUp = bCorona && bCorona != bCoronaD;
			break;

		case ch_Decals:
			bDecal = ch_Decals.IsChecked();
			bGoingUp = bDecal && bDecal != bDecalD;
			UpdateDecalStay();
			break;

		case sl_Gamma:
			fGamma = sl_Gamma.GetValue();
			PlayerOwner().ConsoleCommand("GAMMA"@fGamma);
			break;

		case sl_Brightness:
			fBright = sl_Brightness.GetValue();
			PlayerOwner().ConsoleCommand("BRIGHTNESS"@fBright);
			break;

		case sl_Contrast:
			fContrast = sl_Contrast.GetValue();
			PlayerOwner().ConsoleCommand("CONTRAST"@fContrast);
			break;

		case sl_DistanceLOD:
			fDistance = sl_DistanceLOD.GetValue();
			break;

		case ch_Weather:
			bWeather = ch_Weather.IsChecked();
			bGoingUp = bWeather && bWeather != bWeatherD;
			break;

	}

	if (bGoingUp)
		ShowPerformanceWarning();

	// Check if we are maxed out (and mature-enabled)!
	if( !bPlayedSound && !PlayerOwner().bNoMatureLanguage && iTexture == 8
		&& iChar == 8 && iWorld == 5 && iPhys == 5 && iShadow == 2 &&
		bWeather && bDecal && bDynLight && bProj && bFol &&
		bCorona && bTexture && iDecal == 2 && iMeshLOD == 8 )
	{
		snd = sound(DynamicLoadObject("AnnouncerMale2K4.HolyShit_F", class'Sound'));
		if ( snd != None ) PlayerOwner().ClientPlaySound(snd);
		bPlayedSound = true;
	}
}

function bool RenderDeviceClick( byte Btn )
{
	switch ( Btn )
	{
	case QBTN_Yes:
		SaveSettings();
		Console(Controller.Master.Console).DelayedConsoleCommand("relaunch");
		break;

	case QBTN_Cancel:
		sRenDev = sRenDevD;
		co_RenderDevice.Find(sRenDev);
		co_RenderDevice.SetComponentValue(sRenDev,true);
		break;
	}

	return true;
}

// Video change OK page was closed
function VideoChangeClose(optional bool bCancelled)
{
	local bool bTemp;
	local string NewX, NewY;

	Divide(sRes,"x",NewX,NewY);
	if (bCancelled)
	{
		// Prevent the components from sending OnChange events
		bTemp = bIgnoreChange;
		bIgnoreChange = True;

		// Reload the components values
		co_Resolution.LoadINI();
		co_ColorDepth.LoadINI();
		ch_Fullscreen.LoadINI();
		bIgnoreChange = bTemp;
	}

	else
	{
		if ( int(NewX) < 640 || int(NewY) < 480 )
			Controller.GameResolution = NewX $ "x" $ NewY;
		else Controller.GameResolution = "";

		iColDepthD = iColDepth;
		sResD = sRes;

		if ( bFullScreen != bFullScreenD )
		{
			PlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager StartupFullScreen"@bFullScreen);
			bFullScreenD = bFullScreen;
		}
	}

	CheckSliders();
	bIgnoreResNotice = False;
}

function int GetDetailIndex(string DetailString)
{
	local int i;

	for (i = 0; i < ArrayCount(DetailLevels); i++)
		if (DetailString == DetailLevels[i])
			return i;

	return 0;
}

final function string GetGUIString(string ConfigString)
{
	switch (ConfigString)
	{
		case "UltraLow":	return DetailLevels[0];
		case "VeryLow":		return DetailLevels[1];
		case "Low":			return DetailLevels[2];
		case "Lower":		return DetailLevels[3];
		case "Normal":		return DetailLevels[4];
		case "Higher":		return DetailLevels[5];
		case "High":		return DetailLevels[6];
		case "VeryHigh":	return DetailLevels[7];
		case "UltraHigh":	return DetailLevels[8];
	}
	return "";
}

final function string GetConfigString(string DetailString)
{
	switch (DetailString)
	{
		case DetailLevels[0]:	return "UltraLow";
		case DetailLevels[1]:	return "VeryLow";
		case DetailLevels[2]:	return "Low";
		case DetailLevels[3]:	return "Lower";
		case DetailLevels[4]:	return "Normal";
		case DetailLevels[5]:	return "Higher";
		case DetailLevels[6]:	return "High";
		case DetailLevels[7]:	return "VeryHigh";
		case DetailLevels[8]:	return "UltraHigh";
	}
	return "";
}

final function GetComboOptions(moComboBox Combo, out array<GUIListElem> Ar)
{
	local int i;
	local string tempStr;

	Ar.Remove(0, Ar.Length);
	if (Combo == None)
		return;

	switch (Combo)
	{
		case co_Texture:
		case co_Char:
			for (i = 0; i < ArrayCount(DetailLevels); i++)
			{
				if (bDemo && i == 5)
					break;

				Ar.Length = Ar.Length + 1;
				Ar[i].Item = DetailLevels[i];
			}
			break;

		case co_Physics:
		case co_World:
		case co_Decal:
			Ar.Length = 3;
			Ar[0].Item = DetailLevels[3];
			Ar[1].Item = DetailLevels[4];
			Ar[2].Item = DetailLevels[5];
			break;

		case co_ColorDepth:
			Ar.Length = 2;
			Ar[0].Item = BitDepthText[0];
			Ar[1].Item = BitDepthText[1];
			break;

		case co_Resolution:
			Ar.Length = ArrayCount(DisplayModes);
			for (i = 0; i < Ar.Length; i++)
				Ar[i].Item = DisplayModes[i].Width$"x"$DisplayModes[i].Height;
			break;

		case co_RenderDevice:
			// Win64 has OpenGLDrv and D3D9Drv (NOT D3DDrv!). --ryan.
			if ( ( PlatformIsWindows() ) && ( PlatformIs64Bit() ) )
			{
				Ar.Length = 2;
				Ar[0].Item = RenderModeText[0] @ "9";
				Ar[0].ExtraStrData = "D3D9Drv.D3D9RenderDevice";
				Ar[1].Item = "OpenGL";
				Ar[1].ExtraStrData = "OpenGLDrv.OpenGLRenderDevice";
			}
			else if ( PlatformIsMacOS() )  // Just OpenGLDrv on MacOSX. --ryan.
			{
				Ar.Length = 1;
				Ar[0].Item = "OpenGL";
				Ar[0].ExtraStrData = "OpenGLDrv.OpenGLRenderDevice";
			}
			else if ( PlatformIsUnix() ) // OpenGLDrv and maybe Pixomatic.
			{
				Ar.Length = 1;
				Ar[0].Item = "OpenGL";
				Ar[0].ExtraStrData = "OpenGLDrv.OpenGLRenderDevice";

				if ( !PlatformIs64Bit() )
				{
					Ar.Length = 2;
					Ar[1].Item = RenderModeText[1];
					Ar[1].ExtraStrData = "PixoDrv.PixoRenderDevice";
				}
			}
			else  // pretty much win32.
			{
				Ar.Length = RENDERMODECOUNT;
				for ( i = 0; i < RENDERMODECOUNT; i++ )
				{
					Ar[i].Item = RenderModeText[i];
					Ar[i].ExtraStrData = RenderMode[i];
				}
			}
			break;

		case co_Shadows:
			tempStr = GetNativeClassName("Engine.Engine.RenderDevice");

			// No render-to-texture on anything but Direct3D.
			if ((tempStr == "D3DDrv.D3DRenderDevice") ||
			    (tempStr == "D3D9Drv.D3D9RenderDevice"))
			{
				Ar.Length = ArrayCount(ShadowOptions);
				for ( i = 0; i < ArrayCount(ShadowOptions); i++ )
					Ar[i].Item = ShadowOptions[i];
			}
			else
			{
				Ar.Length = 2;
				Ar[0].Item = ShadowOptions[0];
				Ar[1].Item = ShadowOptions[1];
			}
			break;

		case co_MeshLOD:
			Ar.Length = 4;
			Ar[0].Item = DetailLevels[3];
			Ar[1].Item = DetailLevels[4];
			Ar[2].Item = DetailLevels[5];
			Ar[3].Item = DetailLevels[8];
			break;
	}
}

function UpdateDecalStay()
{
	if ( ch_Decals.IsChecked() )
		EnableComponent(co_Decal);
	else DisableComponent(co_Decal);
}

defaultproperties
{
     DisplayModes(0)=(Width=320,Height=240)
     DisplayModes(1)=(Width=512,Height=384)
     DisplayModes(2)=(Width=640,Height=480)
     DisplayModes(3)=(Width=800,Height=500)
     DisplayModes(4)=(Width=800,Height=600)
     DisplayModes(5)=(Width=1024,Height=640)
     DisplayModes(6)=(Width=1024,Height=768)
     DisplayModes(7)=(Width=1152,Height=768)
     DisplayModes(8)=(Width=1152,Height=864)
     DisplayModes(9)=(Width=1280,Height=800)
     DisplayModes(10)=(Width=1280,Height=854)
     DisplayModes(11)=(Width=1280,Height=960)
     DisplayModes(12)=(Width=1280,Height=1024)
     DisplayModes(13)=(Width=1600,Height=1024)
     DisplayModes(14)=(Width=1600,Height=1200)
     DisplayModes(15)=(Width=1680,Height=1050)
     DisplayModes(16)=(Width=1920,Height=1200)
     BitDepthText(0)="16-bit"
     BitDepthText(1)="32-bit"
     DetailLevels(0)="Lowest"
     DetailLevels(1)="Very Low"
     DetailLevels(2)="Lower"
     DetailLevels(3)="Low"
     DetailLevels(4)="Normal"
     DetailLevels(5)="High"
     DetailLevels(6)="Higher"
     DetailLevels(7)="Very High"
     DetailLevels(8)="Highest"
     ShadowOptions(0)="None"
     ShadowOptions(1)="Blob"
     ShadowOptions(2)="Full"
     RenderModeText(0)="Direct 3D"
     RenderModeText(1)="Software"
     RenderMode(0)="D3DDrv.D3DRenderDevice"
     RenderMode(1)="PixoDrv.PixoRenderDevice"
     DisplayPromptMenu="GUI2K4.UT2K4VideoChangeOK"
     Begin Object Class=GUISectionBackground Name=sbSection1
         Caption="Resolution"
         WinTop=0.012761
         WinLeft=0.000948
         WinWidth=0.491849
         WinHeight=0.440729
         RenderWeight=0.010000
         OnPreDraw=sbSection1.InternalPreDraw
     End Object
     sb_Section1=GUISectionBackground'GUI2K4.UT2K4Tab_DetailSettings.sbSection1'

     Begin Object Class=GUISectionBackground Name=sbSection2
         Caption="Options"
         WinTop=0.012761
         WinLeft=0.495826
         WinWidth=0.502751
         WinHeight=0.975228
         RenderWeight=0.010000
         OnPreDraw=sbSection2.InternalPreDraw
     End Object
     sb_Section2=GUISectionBackground'GUI2K4.UT2K4Tab_DetailSettings.sbSection2'

     Begin Object Class=GUISectionBackground Name=sbSection3
         bFillClient=True
         Caption="Gamma Test"
         WinTop=0.476061
         WinLeft=0.011132
         WinWidth=0.462891
         WinHeight=0.511261
         RenderWeight=0.010000
         OnPreDraw=sbSection3.InternalPreDraw
     End Object
     sb_Section3=GUISectionBackground'GUI2K4.UT2K4Tab_DetailSettings.sbSection3'

     Begin Object Class=GUIImage Name=GammaBar
         Image=Texture'2K4Menus.Controls.Gamma'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         WinTop=0.450001
         WinLeft=0.013477
         WinWidth=0.456250
         WinHeight=0.532117
         OnChange=UT2K4Tab_DetailSettings.InternalOnChange
     End Object
     i_GammaBar=GUIImage'GUI2K4.UT2K4Tab_DetailSettings.GammaBar'

     Begin Object Class=moComboBox Name=DetailTextureDetail
         ComponentJustification=TXTA_Left
         CaptionWidth=0.650000
         Caption="Texture Detail"
         OnCreateComponent=DetailTextureDetail.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="High"
         Hint="Changes how much world detail will be rendered."
         WinTop=0.063021
         WinLeft=0.550000
         WinWidth=0.400000
         TabOrder=7
         OnChange=UT2K4Tab_DetailSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_DetailSettings.InternalOnLoadINI
     End Object
     co_Texture=moComboBox'GUI2K4.UT2K4Tab_DetailSettings.DetailTextureDetail'

     Begin Object Class=moComboBox Name=DetailCharacterDetail
         ComponentJustification=TXTA_Left
         CaptionWidth=0.650000
         Caption="Character Detail"
         OnCreateComponent=DetailCharacterDetail.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="High"
         Hint="Changes how much character detail will be rendered."
         WinTop=0.116667
         WinLeft=0.550000
         WinWidth=0.400000
         TabOrder=8
         OnChange=UT2K4Tab_DetailSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_DetailSettings.InternalOnLoadINI
     End Object
     co_Char=moComboBox'GUI2K4.UT2K4Tab_DetailSettings.DetailCharacterDetail'

     Begin Object Class=moComboBox Name=DetailWorldDetail
         ComponentJustification=TXTA_Left
         CaptionWidth=0.650000
         Caption="World Detail"
         OnCreateComponent=DetailWorldDetail.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="High"
         Hint="Changes the level of detail used for optional geometry and effects."
         WinTop=0.170312
         WinLeft=0.550000
         WinWidth=0.400000
         TabOrder=9
         OnChange=UT2K4Tab_DetailSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_DetailSettings.InternalOnLoadINI
     End Object
     co_World=moComboBox'GUI2K4.UT2K4Tab_DetailSettings.DetailWorldDetail'

     Begin Object Class=moComboBox Name=DetailPhysics
         ComponentJustification=TXTA_Left
         CaptionWidth=0.650000
         Caption="Physics Detail"
         OnCreateComponent=DetailPhysics.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="High"
         Hint="Changes the physics simulation level of detail."
         WinTop=0.223958
         WinLeft=0.550000
         WinWidth=0.400000
         TabOrder=10
         OnChange=UT2K4Tab_DetailSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_DetailSettings.InternalOnLoadINI
     End Object
     co_Physics=moComboBox'GUI2K4.UT2K4Tab_DetailSettings.DetailPhysics'

     Begin Object Class=moComboBox Name=DetailDecalStay
         ComponentJustification=TXTA_Left
         CaptionWidth=0.650000
         Caption="Decal Stay"
         OnCreateComponent=DetailDecalStay.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="Normal"
         Hint="Changes how long weapon scarring effects stay around."
         WinTop=0.282032
         WinLeft=0.550000
         WinWidth=0.400000
         TabOrder=12
         OnChange=UT2K4Tab_DetailSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_DetailSettings.InternalOnLoadINI
     End Object
     co_Decal=moComboBox'GUI2K4.UT2K4Tab_DetailSettings.DetailDecalStay'

     Begin Object Class=moComboBox Name=MeshLOD
         ComponentJustification=TXTA_Left
         CaptionWidth=0.650000
         Caption="Dynamic Mesh LOD"
         OnCreateComponent=MeshLOD.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Adjusts how aggressively character and vehicle details are reduced at a distance.  Higher settings increase the distance at which details are reduced, possibly improving visual detail at a cost in performance"
         WinTop=0.223958
         WinLeft=0.550000
         WinWidth=0.400000
         TabOrder=11
         OnChange=UT2K4Tab_DetailSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_DetailSettings.InternalOnLoadINI
     End Object
     co_MeshLOD=moComboBox'GUI2K4.UT2K4Tab_DetailSettings.MeshLOD'

     Begin Object Class=moComboBox Name=VideoResolution
         bReadOnly=True
         CaptionWidth=0.550000
         Caption="Resolution"
         OnCreateComponent=VideoResolution.InternalOnCreateComponent
         IniOption="@INTERNAL"
         IniDefault="640x480"
         Hint="Select the video resolution at which you wish to play."
         WinTop=0.060417
         WinLeft=0.030508
         WinWidth=0.390000
         TabOrder=1
         OnChange=UT2K4Tab_DetailSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_DetailSettings.InternalOnLoadINI
     End Object
     co_Resolution=moComboBox'GUI2K4.UT2K4Tab_DetailSettings.VideoResolution'

     Begin Object Class=moComboBox Name=VideoColorDepth
         CaptionWidth=0.550000
         Caption="Color Depth"
         OnCreateComponent=VideoColorDepth.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="false"
         Hint="Select the maximum number of colors to display at one time."
         WinTop=0.117188
         WinLeft=0.030234
         WinWidth=0.390000
         TabOrder=2
         OnChange=UT2K4Tab_DetailSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_DetailSettings.InternalOnLoadINI
     End Object
     co_ColorDepth=moComboBox'GUI2K4.UT2K4Tab_DetailSettings.VideoColorDepth'

     Begin Object Class=moComboBox Name=RenderDeviceCombo
         ComponentJustification=TXTA_Left
         CaptionWidth=0.550000
         Caption="Render Device"
         OnCreateComponent=RenderDeviceCombo.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Alternate rendering devices may offer better performance on your machine."
         WinTop=0.335021
         WinLeft=0.547773
         WinWidth=0.401953
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         OnChange=UT2K4Tab_DetailSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_DetailSettings.InternalOnLoadINI
     End Object
     co_RenderDevice=moComboBox'GUI2K4.UT2K4Tab_DetailSettings.RenderDeviceCombo'

     Begin Object Class=moComboBox Name=DetailCharacterShadows
         ComponentJustification=TXTA_Left
         CaptionWidth=0.650000
         Caption="Character Shadows"
         OnCreateComponent=DetailCharacterShadows.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Adjust the detail of character shadows.  'Blob' or 'None' recommended for low-performance PC's"
         WinTop=0.431378
         WinLeft=0.600000
         WinWidth=0.300000
         TabOrder=13
         OnChange=UT2K4Tab_DetailSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_DetailSettings.InternalOnLoadINI
     End Object
     co_Shadows=moComboBox'GUI2K4.UT2K4Tab_DetailSettings.DetailCharacterShadows'

     Begin Object Class=moCheckBox Name=DetailDecals
         ComponentJustification=TXTA_Left
         CaptionWidth=0.940000
         Caption="Decals"
         OnCreateComponent=DetailDecals.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="True"
         Hint="Enables weapon scarring effects."
         WinTop=0.479308
         WinLeft=0.600000
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=14
         OnChange=UT2K4Tab_DetailSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_DetailSettings.InternalOnLoadINI
     End Object
     ch_Decals=moCheckBox'GUI2K4.UT2K4Tab_DetailSettings.DetailDecals'

     Begin Object Class=moCheckBox Name=DetailDynamicLighting
         ComponentJustification=TXTA_Left
         CaptionWidth=0.940000
         Caption="Dynamic Lighting"
         OnCreateComponent=DetailDynamicLighting.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="True"
         Hint="Enables dynamic lights."
         WinTop=0.526716
         WinLeft=0.600000
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=15
         OnChange=UT2K4Tab_DetailSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_DetailSettings.InternalOnLoadINI
     End Object
     ch_DynLight=moCheckBox'GUI2K4.UT2K4Tab_DetailSettings.DetailDynamicLighting'

     Begin Object Class=moCheckBox Name=DetailCoronas
         ComponentJustification=TXTA_Left
         CaptionWidth=0.940000
         Caption="Coronas"
         OnCreateComponent=DetailCoronas.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="True"
         Hint="Enables coronas."
         WinTop=0.624136
         WinLeft=0.600000
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=17
         OnChange=UT2K4Tab_DetailSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_DetailSettings.InternalOnLoadINI
     End Object
     ch_Coronas=moCheckBox'GUI2K4.UT2K4Tab_DetailSettings.DetailCoronas'

     Begin Object Class=moCheckBox Name=DetailDetailTextures
         ComponentJustification=TXTA_Left
         CaptionWidth=0.940000
         Caption="Detail Textures"
         OnCreateComponent=DetailDetailTextures.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="True"
         Hint="Enables detail textures."
         WinTop=0.575425
         WinLeft=0.600000
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=16
         OnChange=UT2K4Tab_DetailSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_DetailSettings.InternalOnLoadINI
     End Object
     ch_Textures=moCheckBox'GUI2K4.UT2K4Tab_DetailSettings.DetailDetailTextures'

     Begin Object Class=moCheckBox Name=DetailProjectors
         ComponentJustification=TXTA_Left
         CaptionWidth=0.940000
         Caption="Projectors"
         OnCreateComponent=DetailProjectors.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="True"
         Hint="Enables projectors."
         WinTop=0.721195
         WinLeft=0.600000
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=19
         OnChange=UT2K4Tab_DetailSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_DetailSettings.InternalOnLoadINI
     End Object
     ch_Projectors=moCheckBox'GUI2K4.UT2K4Tab_DetailSettings.DetailProjectors'

     Begin Object Class=moCheckBox Name=DetailDecoLayers
         ComponentJustification=TXTA_Left
         CaptionWidth=0.940000
         Caption="Foliage"
         OnCreateComponent=DetailDecoLayers.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="True"
         Hint="Enables grass and other decorative foliage."
         WinTop=0.769906
         WinLeft=0.599727
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=20
         OnChange=UT2K4Tab_DetailSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_DetailSettings.InternalOnLoadINI
     End Object
     ch_DecoLayers=moCheckBox'GUI2K4.UT2K4Tab_DetailSettings.DetailDecoLayers'

     Begin Object Class=moCheckBox Name=DetailTrilinear
         ComponentJustification=TXTA_Left
         CaptionWidth=0.940000
         Caption="Trilinear Filtering"
         OnCreateComponent=DetailTrilinear.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="False"
         Hint="Enables trilinear filtering, recommended for high-performance PCs."
         WinTop=0.673263
         WinLeft=0.600000
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=18
         OnChange=UT2K4Tab_DetailSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_DetailSettings.InternalOnLoadINI
     End Object
     ch_Trilinear=moCheckBox'GUI2K4.UT2K4Tab_DetailSettings.DetailTrilinear'

     Begin Object Class=moCheckBox Name=VideoFullScreen
         ComponentJustification=TXTA_Left
         CaptionWidth=0.940000
         Caption="Full Screen"
         OnCreateComponent=VideoFullScreen.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="True"
         Hint="Check this box to run the game full screen."
         WinTop=0.169531
         WinLeft=0.030976
         WinWidth=0.387500
         TabOrder=3
         OnChange=UT2K4Tab_DetailSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_DetailSettings.InternalOnLoadINI
     End Object
     ch_FullScreen=moCheckBox'GUI2K4.UT2K4Tab_DetailSettings.VideoFullScreen'

     Begin Object Class=moCheckBox Name=WeatherEffects
         ComponentJustification=TXTA_Left
         CaptionWidth=0.940000
         Caption="Weather Effects"
         OnCreateComponent=WeatherEffects.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="False"
         Hint="Enable weather effects like rain-drops and lightning."
         WinTop=0.864910
         WinLeft=0.599727
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=21
         OnChange=UT2K4Tab_DetailSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_DetailSettings.InternalOnLoadINI
     End Object
     ch_Weather=moCheckBox'GUI2K4.UT2K4Tab_DetailSettings.WeatherEffects'

     Begin Object Class=moSlider Name=GammaSlider
         MaxValue=2.500000
         MinValue=0.500000
         SliderCaptionStyleName=
         CaptionWidth=0.550000
         Caption="Gamma"
         OnCreateComponent=GammaSlider.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="0.8"
         Hint="Use the slider to adjust the Gamma to suit your monitor."
         WinTop=0.272918
         WinLeft=0.012501
         WinWidth=0.461133
         TabOrder=5
         OnChange=UT2K4Tab_DetailSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_DetailSettings.InternalOnLoadINI
     End Object
     sl_Gamma=moSlider'GUI2K4.UT2K4Tab_DetailSettings.GammaSlider'

     Begin Object Class=moSlider Name=BrightnessSlider
         MaxValue=1.000000
         SliderCaptionStyleName=
         CaptionWidth=0.550000
         Caption="Brightness"
         OnCreateComponent=BrightnessSlider.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="0.8"
         Hint="Use the slider to adjust the Brightness to suit your monitor."
         WinTop=0.229951
         WinLeft=0.012188
         WinWidth=0.461445
         TabOrder=4
         OnChange=UT2K4Tab_DetailSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_DetailSettings.InternalOnLoadINI
     End Object
     sl_Brightness=moSlider'GUI2K4.UT2K4Tab_DetailSettings.BrightnessSlider'

     Begin Object Class=moSlider Name=ContrastSlider
         MaxValue=1.000000
         SliderCaptionStyleName=
         CaptionWidth=0.550000
         Caption="Contrast"
         OnCreateComponent=ContrastSlider.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="0.8"
         Hint="Use the slider to adjust the Contrast to suit your monitor."
         WinTop=0.313285
         WinLeft=0.012188
         WinWidth=0.461133
         TabOrder=6
         OnChange=UT2K4Tab_DetailSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_DetailSettings.InternalOnLoadINI
     End Object
     sl_Contrast=moSlider'GUI2K4.UT2K4Tab_DetailSettings.ContrastSlider'

     Begin Object Class=moSlider Name=DistanceLODSlider
         MaxValue=1.000000
         Value=0.500000
         SliderCaptionStyleName=
         CaptionWidth=0.650000
         Caption="Fog Distance"
         OnCreateComponent=DistanceLODSlider.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Reduce the fog distance to improve performance."
         WinTop=0.910000
         WinLeft=0.560000
         WinWidth=0.400000
         TabOrder=22
         OnChange=UT2K4Tab_DetailSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_DetailSettings.InternalOnLoadINI
     End Object
     sl_DistanceLOD=moSlider'GUI2K4.UT2K4Tab_DetailSettings.DistanceLODSlider'

     RelaunchQuestion="The graphics mode has been successfully changed.  However, it will not take effect until the next time the game is started.  Would you like to restart UT2004 right now?"
     InvalidSelectionText="The selected custom resolution is reported to be incompatible with your machine.  In order to ensure maximum stability, it is recommended that you choose a compatible resolution from the 'Resolution' drop-down menu"
     PanelCaption="Display"
     WinTop=0.150000
     WinHeight=0.740000
     OnPreDraw=UT2K4Tab_DetailSettings.InternalOnPreDraw
}
