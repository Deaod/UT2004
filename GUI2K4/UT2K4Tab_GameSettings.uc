//==============================================================================
//  Contains all client-side (mostly) game configuration properties
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UT2K4Tab_GameSettings extends Settings_Tabs;

var automated GUISectionBackground i_BG1, i_BG2, i_BG3, i_BG4, i_BG5;
var automated moCheckBox    ch_WeaponBob, ch_AutoSwitch, ch_Speech,
                            ch_Dodging, ch_AutoAim, ch_ClassicTrans, ch_LandShake;
var automated moComboBox    co_GoreLevel;

var GUIComponent LastGameOption;  // Hack

var bool    bBob, bDodge, bAim, bAuto, bClassicTrans, bLandShake, bLandShakeD, bSpeechRec;
var int     iGore;

// From network tab
var localized string    NetSpeedText[4];

var localized string    StatsURL;
var localized string    EpicIDMsg;

var automated GUILabel  l_Warning, l_ID;
var automated GUIButton b_Stats;
var automated moCheckBox    ch_TrackStats, ch_DynNetspeed, ch_Precache;
var automated moComboBox    co_Netspeed;
var automated moEditBox     ed_Name, ed_Password;

var int iNetspeed, iNetSpeedD;
var string sPassword, sName;
var bool bStats, bDynNet, bPrecache;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;

    Super.InitComponent(MyController, MyOwner);
    if ( class'GameInfo'.Default.bAlternateMode )
    	RemoveComponent(co_GoreLevel);
    else
    {
    	for (i = 0; i < ArrayCount(class'GameInfo'.default.GoreLevelText); i++)
    		co_GoreLevel.AddItem(class'GameInfo'.default.GoreLevelText[i]);
    }

    LastGameOption = ch_LandShake;

    // Network
    for(i = 0;i < ArrayCount(NetSpeedText);i++)
        co_Netspeed.AddItem(NetSpeedText[i]);

    ed_Name.MyEditBox.bConvertSpaces = true;
    ed_Name.MyEditBox.MaxWidth=14;

    ed_Password.MyEditBox.MaxWidth=14;

    ed_Password.MaskText(true);
    l_ID.Caption = FormatID(PlayerOwner().GetPlayerIDHash());

}

function string FormatID(string id)
{
    id=Caps(id);
    return mid(id,0,8)$"-"$mid(id,8,8)$"-"$mid(id,16,8)$"-"$mid(id,24,8);
}

function ShowPanel(bool bShow)
{
    Super.ShowPanel(bShow);
    if ( bShow )
	{
		if ( bInit )
	    {
            i_BG1.ManageComponent(ch_WeaponBob);
            i_BG1.Managecomponent(ch_AutoSwitch);
            i_BG1.ManageComponent(ch_Dodging);
            i_BG1.ManageComponent(ch_AutoAim);
            i_BG1.ManageComponent(ch_ClassicTrans);
            i_BG1.ManageComponent(ch_LandShake);
	        i_BG1.Managecomponent(co_GoreLevel);

            // No speech recognition except on win32... --ryan.
            if ( (!PlatformIsWindows()) || (PlatformIs64Bit()) )
                ch_Speech.DisableMe();

	    }
    	UpdateStatsItems();
    }
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
	local int i;
    local PlayerController PC;

    if (GUIMenuOption(Sender) != None)
    {
        PC = PlayerOwner();

        switch (GUIMenuOption(Sender))
        {
            case ch_AutoSwitch:
                bAuto = !PC.bNeverSwitchOnPickup;
                ch_AutoSwitch.Checked(bAuto);
                break;

            case ch_WeaponBob:
            	if ( PC.Pawn != None )
            		bBob = PC.Pawn.bWeaponBob;
            	else bBob = class'Pawn'.default.bWeaponBob;
                ch_WeaponBob.Checked(bBob);
                break;

            case co_GoreLevel:
            	if ( PC.Level.Game != None )
            		iGore = PC.Level.Game.GoreLevel;
                else iGore = class'GameInfo'.default.GoreLevel;
                co_GoreLevel.SetIndex(iGore);
                break;

            case ch_Dodging:
                bDodge = PC.DodgingIsEnabled();
                ch_Dodging.Checked(bDodge);
                break;

            case ch_AutoAim:
                bAim = PC.bAimingHelp;
                ch_AutoAim.Checked(bAim);
                break;

            case ch_ClassicTrans:
            	if ( xPlayer(PC) != None )
            		bClassicTrans = xPlayer(PC).bClassicTrans;
                else bClassicTrans = class'xPlayer'.default.bClassicTrans;
                ch_ClassicTrans.Checked(bClassicTrans);
                break;

			case ch_LandShake:
				bLandShake = PC.bLandingShake;
				ch_LandShake.Checked(bLandShake);
				break;

            case ch_Speech:
            	bSpeechRec = bool(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager UseSpeechRecognition"));
            	ch_Speech.SetComponentValue(bSpeechRec, True);
            	break;

        // Network
        	case ch_Precache:
        		bPrecache = PC.Level.bDesireSkinPreload;
        		ch_Precache.Checked(bPrecache);
        		break;

            case co_Netspeed:
            	if ( PC.Player != None )
            		i = PC.Player.ConfiguredInternetSpeed;
            	else i = class'Player'.default.ConfiguredInternetSpeed;

                if (i <= 2600)
                    iNetSpeed = 0;

                else if (i <= 5000)
                    iNetSpeed = 1;

                else if (i <= 10000)
                    iNetSpeed = 2;

                else iNetSpeed = 3;

				iNetSpeedD = iNetSpeed;
                co_NetSpeed.SetIndex(iNetSpeed);
                break;

            case ed_Name:
                sName = PC.StatsUserName;
                ed_Name.SetText(sName);
                break;

            case ed_Password:
                sPassword = PC.StatsPassword;
                ed_Password.SetText(sPassword);
                break;

            case ch_TrackStats:
            	bStats = PC.bEnableStatsTracking;
                ch_TrackStats.Checked(bStats);
                UpdateStatsItems();
                break;

            case ch_DynNetspeed:
                bDynNet = PC.bDynamicNetSpeed;
                ch_DynNetspeed.Checked(bDynNet);
                break;

        }
    }
}

function SaveSettings()
{
    local PlayerController PC;
    local bool bSave;

	Super.SaveSettings();
    PC = PlayerOwner();

    if ( bSpeechRec != bool(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager UseSpeechRecognition")) )
    	PC.ConsoleCommand("set ini:Engine.Engine.ViewportManager UseSpeechRecognition"@bSpeechRec);

    if ( xPlayer(PC) != None && xPlayer(PC).bClassicTrans != bClassicTrans)
    {
        xPlayer(PC).bClassicTrans = bClassicTrans;
        xPlayer(PC).ServerSetClassicTrans(bClassicTrans);
        bSave = True;
    }

    if (class'XGame.xPlayer'.default.bClassicTrans != bClassicTrans)
    {
        class'XGame.xPlayer'.default.bClassicTrans = bClassicTrans;
        class'XGame.xPlayer'.static.StaticSaveConfig();
    }

	if (PC.bLandingShake != bLandShake)
	{
		PC.bLandingShake = bLandShake;
		bSave = True;
	}

    if (PC.DodgingIsEnabled() != bDodge)
    {
        PC.SetDodging(bDodge);
        bSave = True;
    }

    if (PC.bNeverSwitchOnPickup == bAuto)
    {
        PC.bNeverSwitchOnPickup = !bAuto;
        bSave = True;
    }

    if ( PC.bAimingHelp != bAim )
    {
    	PC.bAimingHelp = bAim;
    	bSave = True;
    }

    if (PC.Pawn != None)
    {

        PC.Pawn.bWeaponBob = bBob;
        PC.Pawn.SaveConfig();
    }
    else if (class'Engine.Pawn'.default.bWeaponBob != bBob)
    {
        class'Engine.Pawn'.default.bWeaponBob = bBob;
        class'Engine.Pawn'.static.StaticSaveConfig();
    }

    if (PC.Level != None && PC.Level.Game != None)
    {
    	if ( PC.Level.Game.GoreLevel != iGore )
    	{
	        PC.Level.Game.GoreLevel = iGore;
	        PC.Level.Game.SaveConfig();
	    }
    }
    else
    {
		if ( class'Engine.GameInfo'.default.GoreLevel != iGore )
		{
	        class'Engine.GameInfo'.default.GoreLevel = iGore;
	        class'Engine.GameInfo'.static.StaticSaveConfig();
	    }
    }

	// Network
	if ( bPrecache != PC.Level.bDesireSkinPreload )
	{
		PC.Level.bDesireSkinPreload = bPrecache;
		PC.Level.SaveConfig();
	}

	if ( iNetSpeed != iNetSpeedD || (class'Player'.default.ConfiguredInternetSpeed == 9636) )
	{
		if ( PC.Player != None )
		{
			switch (iNetSpeed)
			{
				case 0: PC.Player.ConfiguredInternetSpeed = 2600; break;
				case 1: PC.Player.ConfiguredInternetSpeed = 5000; break;
				case 2: PC.Player.ConfiguredInternetSpeed = 10000; break;
				case 3: PC.Player.ConfiguredInternetSpeed = 15000; break;
			}

			PC.Player.SaveConfig();
		}

		else
		{
			switch (iNetSpeed)
			{
				case 0: class'Player'.default.ConfiguredInternetSpeed = 2600; break;
				case 1: class'Player'.default.ConfiguredInternetSpeed = 5000; break;
				case 2: class'Player'.default.ConfiguredInternetSpeed = 10000; break;
				case 3: class'Player'.default.ConfiguredInternetSpeed = 15000; break;
			}

			class'Player'.static.StaticSaveConfig();
		}
	}

	if ( bStats != PC.bEnableStatsTracking )
	{
		PC.bEnableStatsTracking = bStats;
		bSave = True;
	}

	if ( sName != PC.StatsUserName )
	{
		PC.StatsUserName = sName;
		bSave = True;
	}

	if ( PC.StatsPassword != sPassword )
	{
		PC.StatsPassword = sPassword;
		bSave = True;
	}

	if ( PC.bDynamicNetSpeed != bDynNet )
	{
		PC.bDynamicNetSpeed = bDynNet;
		bSave = True;
	}


    if (bSave)
        PC.SaveConfig();
}

function ResetClicked()
{
    local class<Client> ViewportClass;
    local bool bTemp;
    local PlayerController PC;
    local int i;

    Super.ResetClicked();

	PC = PlayerOwner();
    ViewportClass = class<Client>(DynamicLoadObject(GetNativeClassName("Engine.Engine.ViewportManager"), class'Class'));

    ViewportClass.static.ResetConfig("UseSpeechRecognition");
    ViewportClass.static.ResetConfig("ScreenFlashes");
    class'XGame.xPlayer'.static.ResetConfig("bClassicTrans");

    PC.ResetConfig("bNeverSwitchOnPickup");
    PC.ResetConfig("bEnableDodging");
	PC.ResetConfig("bLandingShake");
	PC.ResetConfig("bAimingHelp");

    class'Engine.Pawn'.static.ResetConfig("bWeaponBob");
    class'Engine.GameInfo'.static.ResetConfig("GoreLevel");

    // Network
    class'Engine.Player'.static.ResetConfig("ConfiguredInternetSpeed");
    class'Engine.LevelInfo'.static.ResetConfig("bDesireSkinPreload");
    PC.ResetConfig("bEnableStatsTracking");
    PC.ClearConfig("StatsUserName");
    PC.ClearConfig("StatsPassword");
    PC.ResetConfig("bDynamicNetSpeed");

    bTemp = Controller.bCurMenuInitialized;
    Controller.bCurMenuInitialized = False;

    for (i = 0; i < Components.Length; i++)
        Components[i].LoadINI();

    Controller.bCurMenuInitialized = bTemp;
}

function InternalOnChange(GUIComponent Sender)
{
    local PlayerController PC;

	Super.InternalOnChange(Sender);
    if (GUIMenuOption(Sender) != None)
    {
        PC = PlayerOwner();

        switch (GUIMenuOption(Sender))
        {
            case ch_Speech:
            	bSpeechRec = ch_Speech.IsChecked();
            	break;

            case ch_AutoSwitch:
                bAuto = ch_AutoSwitch.IsChecked();
                break;

            case ch_WeaponBob:
                bBob = ch_WeaponBob.IsChecked();
                break;

            case co_GoreLevel:
                iGore = co_GoreLevel.GetIndex();
                break;

            case ch_Dodging:
                bDodge = ch_Dodging.IsChecked();
                break;

            case ch_AutoAim:
                bAim = ch_AutoAim.IsChecked();
                break;

            case ch_ClassicTrans:
                bClassicTrans = ch_ClassicTrans.IsChecked();
                break;

			case ch_LandShake:
				bLandShake = ch_LandShake.IsChecked();
				break;

		// Network
        	case ch_Precache:
        		bPrecache = ch_Precache.IsChecked();
        		break;

            case co_Netspeed:
                iNetSpeed = co_NetSpeed.GetIndex();
                break;

            case ed_Name:
                sName = ed_Name.GetText();
                break;

            case ed_Password:
                sPassword = ed_Password.GetText();
                break;

            case ch_TrackStats:
            	bStats = ch_TrackStats.IsChecked();
                UpdateStatsItems();
                break;

            case ch_DynNetspeed:
                bDynNet = ch_DynNetspeed.IsChecked();
                break;

        }
    }

    l_Warning.SetVisibility(!ValidStatConfig());
}

function bool ValidStatConfig()
{
    if(bStats)
    {
        if(Len(ed_Name.GetText()) < 4)
            return false;

        if(Len(ed_Password.GetText()) < 6)
            return false;
    }

    return true;
}

function bool OnViewStats(GUIComponent Sender)
{
    PlayerOwner().ConsoleCommand("start"@StatsURL);
    return true;
}

function UpdateStatsItems()
{
	if ( bStats )
	{
		EnableComponent(ed_Name);
		EnableComponent(ed_Password);
		EnableComponent(b_Stats);
	}
	else
	{
		DisableComponent(ed_Name);
		DisableComponent(ed_Password);
		DisableComponent(b_Stats);
	}

	l_Warning.SetVisibility(!ValidStatConfig());
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=GameBK1
         Caption="Gameplay"
         WinTop=0.033853
         WinLeft=0.014649
         WinWidth=0.449609
         WinHeight=0.748936
         RenderWeight=0.100100
         OnPreDraw=GameBK1.InternalPreDraw
     End Object
     i_BG1=GUISectionBackground'GUI2K4.UT2K4Tab_GameSettings.GameBK1'

     Begin Object Class=GUISectionBackground Name=GameBK2
         Caption="Network"
         WinTop=0.033853
         WinLeft=0.486328
         WinWidth=0.496484
         WinHeight=0.199610
         RenderWeight=0.100200
         OnPreDraw=GameBK2.InternalPreDraw
     End Object
     i_BG2=GUISectionBackground'GUI2K4.UT2K4Tab_GameSettings.GameBK2'

     Begin Object Class=GUISectionBackground Name=GameBK3
         Caption="Stats"
         WinTop=0.240491
         WinLeft=0.486328
         WinWidth=0.496484
         WinHeight=0.308985
         RenderWeight=0.100200
         OnPreDraw=GameBK3.InternalPreDraw
     End Object
     i_BG3=GUISectionBackground'GUI2K4.UT2K4Tab_GameSettings.GameBK3'

     Begin Object Class=GUISectionBackground Name=GameBK4
         Caption="Misc"
         WinTop=0.559889
         WinLeft=0.486328
         WinWidth=0.496484
         WinHeight=0.219141
         RenderWeight=0.100200
         OnPreDraw=GameBK4.InternalPreDraw
     End Object
     i_BG4=GUISectionBackground'GUI2K4.UT2K4Tab_GameSettings.GameBK4'

     Begin Object Class=GUISectionBackground Name=GameBK5
         Caption="Unique ID / Messages"
         WinTop=0.791393
         WinLeft=0.017419
         WinWidth=0.965712
         WinHeight=0.200706
         RenderWeight=0.100200
         OnPreDraw=GameBK5.InternalPreDraw
     End Object
     i_BG5=GUISectionBackground'GUI2K4.UT2K4Tab_GameSettings.GameBK5'

     Begin Object Class=moCheckBox Name=GameWeaponBob
         Caption="Weapon Bob"
         OnCreateComponent=GameWeaponBob.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Prevent your weapon from bobbing up and down while moving"
         WinTop=0.290780
         WinLeft=0.050000
         WinWidth=0.400000
         RenderWeight=1.040000
         TabOrder=1
         OnChange=UT2K4Tab_GameSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_GameSettings.InternalOnLoadINI
     End Object
     ch_WeaponBob=moCheckBox'GUI2K4.UT2K4Tab_GameSettings.GameWeaponBob'

     Begin Object Class=moCheckBox Name=WeaponAutoSwitch
         Caption="Weapon Switch On Pickup"
         OnCreateComponent=WeaponAutoSwitch.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Automatically change weapons when you pick up a better one."
         RenderWeight=1.040000
         TabOrder=6
         OnChange=UT2K4Tab_GameSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_GameSettings.InternalOnLoadINI
     End Object
     ch_AutoSwitch=moCheckBox'GUI2K4.UT2K4Tab_GameSettings.WeaponAutoSwitch'

     Begin Object Class=moCheckBox Name=SpeechRecognition
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Speech Recognition"
         OnCreateComponent=SpeechRecognition.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Enable speech recognition"
         WinTop=0.654527
         WinLeft=0.540058
         WinWidth=0.403353
         TabOrder=14
         bBoundToParent=True
         bScaleToParent=True
         OnChange=UT2K4Tab_GameSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_GameSettings.InternalOnLoadINI
     End Object
     ch_Speech=moCheckBox'GUI2K4.UT2K4Tab_GameSettings.SpeechRecognition'

     Begin Object Class=moCheckBox Name=GameDodging
         Caption="Dodging"
         OnCreateComponent=GameDodging.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Turn this option off to disable special dodge moves."
         WinTop=0.541563
         WinLeft=0.050000
         WinWidth=0.400000
         RenderWeight=1.040000
         TabOrder=3
         OnChange=UT2K4Tab_GameSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_GameSettings.InternalOnLoadINI
     End Object
     ch_Dodging=moCheckBox'GUI2K4.UT2K4Tab_GameSettings.GameDodging'

     Begin Object Class=moCheckBox Name=GameAutoAim
         Caption="Auto Aim"
         OnCreateComponent=GameAutoAim.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Enabling this option will activate computer-assisted aiming in single player games."
         WinTop=0.692344
         WinLeft=0.050000
         WinWidth=0.400000
         RenderWeight=1.040000
         TabOrder=4
         OnChange=UT2K4Tab_GameSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_GameSettings.InternalOnLoadINI
     End Object
     ch_AutoAim=moCheckBox'GUI2K4.UT2K4Tab_GameSettings.GameAutoAim'

     Begin Object Class=moCheckBox Name=GameClassicTrans
         Caption="High Beacon Trajectory"
         OnCreateComponent=GameClassicTrans.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Enable to use traditional-style high translocator beacon toss trajectory"
         RenderWeight=1.040000
         TabOrder=5
         OnChange=UT2K4Tab_GameSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_GameSettings.InternalOnLoadINI
     End Object
     ch_ClassicTrans=moCheckBox'GUI2K4.UT2K4Tab_GameSettings.GameClassicTrans'

     Begin Object Class=moCheckBox Name=LandShaking
         CaptionWidth=0.900000
         Caption="Landing Viewshake"
         OnCreateComponent=LandShaking.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Enable view shaking upon landing."
         WinTop=0.150261
         WinLeft=0.705430
         WinWidth=0.266797
         TabOrder=7
         OnChange=UT2K4Tab_GameSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_GameSettings.InternalOnLoadINI
     End Object
     ch_LandShake=moCheckBox'GUI2K4.UT2K4Tab_GameSettings.LandShaking'

     Begin Object Class=moComboBox Name=GameGoreLevel
         bReadOnly=True
         Caption="Gore Level"
         OnCreateComponent=GameGoreLevel.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Configure the amount of blood and gore you see while playing the game"
         WinTop=0.415521
         WinLeft=0.050000
         WinWidth=0.400000
         RenderWeight=1.040000
         TabOrder=2
         OnChange=UT2K4Tab_GameSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_GameSettings.InternalOnLoadINI
     End Object
     co_GoreLevel=moComboBox'GUI2K4.UT2K4Tab_GameSettings.GameGoreLevel'

     NetSpeedText(0)="Modem"
     NetSpeedText(1)="ISDN"
     NetSpeedText(2)="Cable/ADSL"
     NetSpeedText(3)="LAN/T1"
     StatsURL="http://ut2004stats.epicgames.com/"
     EpicIDMsg="Your Unique id is:"
     Begin Object Class=GUILabel Name=InvalidWarning
         Caption="Your stats username or password is invalid.  Your username must be at least 4 characters long, and your password must be at least 6 characters long."
         TextAlign=TXTA_Center
         TextColor=(B=0,G=255,R=255)
         TextFont="UT2SmallFont"
         bMultiLine=True
         WinTop=0.916002
         WinLeft=0.057183
         WinWidth=0.887965
         WinHeight=0.058335
     End Object
     l_Warning=GUILabel'GUI2K4.UT2K4Tab_GameSettings.InvalidWarning'

     Begin Object Class=GUILabel Name=EpicID
         Caption="Your Unique id is:"
         TextAlign=TXTA_Center
         StyleName="TextLabel"
         WinTop=0.858220
         WinLeft=0.054907
         WinWidth=0.888991
         WinHeight=0.067703
         RenderWeight=0.200000
     End Object
     l_ID=GUILabel'GUI2K4.UT2K4Tab_GameSettings.EpicID'

     Begin Object Class=GUIButton Name=ViewOnlineStats
         Caption="View Stats"
         Hint="Click to launch the UT stats website."
         WinTop=0.469391
         WinLeft=0.780383
         WinWidth=0.166055
         WinHeight=0.050000
         TabOrder=13
         OnClick=UT2K4Tab_GameSettings.OnViewStats
         OnKeyEvent=ViewOnlineStats.InternalOnKeyEvent
     End Object
     b_Stats=GUIButton'GUI2K4.UT2K4Tab_GameSettings.ViewOnlineStats'

     Begin Object Class=moCheckBox Name=OnlineTrackStats
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Track Stats"
         OnCreateComponent=OnlineTrackStats.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="True"
         Hint="Enable this option to join the online ranking system."
         WinTop=0.321733
         WinLeft=0.642597
         WinWidth=0.170273
         TabOrder=10
         OnChange=UT2K4Tab_GameSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_GameSettings.InternalOnLoadINI
     End Object
     ch_TrackStats=moCheckBox'GUI2K4.UT2K4Tab_GameSettings.OnlineTrackStats'

     Begin Object Class=moCheckBox Name=NetworkDynamicNetspeed
         ComponentJustification=TXTA_Left
         CaptionWidth=0.940000
         Caption="Dynamic Netspeed"
         OnCreateComponent=NetworkDynamicNetspeed.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Netspeed is automatically adjusted based on the speed of your network connection"
         WinTop=0.166017
         WinLeft=0.528997
         WinWidth=0.419297
         TabOrder=9
         OnChange=UT2K4Tab_GameSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_GameSettings.InternalOnLoadINI
     End Object
     ch_DynNetspeed=moCheckBox'GUI2K4.UT2K4Tab_GameSettings.NetworkDynamicNetspeed'

     Begin Object Class=moCheckBox Name=PrecacheSkins
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Preload all player skins"
         OnCreateComponent=PrecacheSkins.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Preloads all player skins, increasing level load time but reducing hitches during network games.  You must have at least 512 MB of system memory to use this option."
         WinTop=0.707553
         WinLeft=0.540058
         WinWidth=0.403353
         TabOrder=15
         OnChange=UT2K4Tab_GameSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_GameSettings.InternalOnLoadINI
     End Object
     ch_Precache=moCheckBox'GUI2K4.UT2K4Tab_GameSettings.PrecacheSkins'

     Begin Object Class=moComboBox Name=OnlineNetSpeed
         bReadOnly=True
         ComponentJustification=TXTA_Left
         CaptionWidth=0.550000
         Caption="Connection"
         OnCreateComponent=OnlineNetSpeed.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="Cable Modem/DSL"
         Hint="How fast is your connection?"
         WinTop=0.122944
         WinLeft=0.528997
         WinWidth=0.419297
         TabOrder=8
         OnChange=UT2K4Tab_GameSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_GameSettings.InternalOnLoadINI
     End Object
     co_Netspeed=moComboBox'GUI2K4.UT2K4Tab_GameSettings.OnlineNetSpeed'

     Begin Object Class=moEditBox Name=OnlineStatsName
         CaptionWidth=0.400000
         Caption="UserName"
         OnCreateComponent=OnlineStatsName.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Please select a name to use for UT Stats!"
         WinTop=0.373349
         WinLeft=0.524912
         WinWidth=0.419316
         TabOrder=11
         OnChange=UT2K4Tab_GameSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_GameSettings.InternalOnLoadINI
     End Object
     ed_Name=moEditBox'GUI2K4.UT2K4Tab_GameSettings.OnlineStatsName'

     Begin Object Class=moEditBox Name=OnlineStatsPW
         CaptionWidth=0.400000
         Caption="Password"
         OnCreateComponent=OnlineStatsPW.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Please select a password that will secure your UT Stats!"
         WinTop=0.430677
         WinLeft=0.524912
         WinWidth=0.419316
         TabOrder=12
         OnChange=UT2K4Tab_GameSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_GameSettings.InternalOnLoadINI
     End Object
     ed_Password=moEditBox'GUI2K4.UT2K4Tab_GameSettings.OnlineStatsPW'

     PanelCaption="Game"
     WinTop=0.150000
     WinHeight=0.740000
}
