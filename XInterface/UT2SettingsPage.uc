// ====================================================================
//  Class:  XInterface.UT2SettingsPage
//  Parent: XInterface.GUIPage
//
//  <Enter a description here>
// ====================================================================

class UT2SettingsPage extends UT2K3GUIPage;

#exec OBJ LOAD FILE=InterfaceContent.utx

var localized string	VideoTabLabel,
						VideoTabHint,
						DetailsTabLabel,
						DetailsTabHint,
						AudioTabLabel,
						AudioTabHint,
						PlayerTabLabel,
						PlayerTabHint,
						NetworkTabLabel,
						NetworkTabHint,
						ControlsTabLabel,
						ControlsTabHint,
						IForceTabLabel,
						IForceTabHint,
						WeaponsTabLabel,
						WeaponsTabHint,
						GameTabLabel,
						GameTabHint,
                        HudTabLabel,
                        HudTabHint,
						SpeechBinderTabLabel,
						SpeechBinderTabHint;

var Tab_WeaponPref 		pWeaponPref;
var Tab_PlayerSettings  pPlayer;
var Tab_NetworkSettings	pNetwork;

var float				SavedPitch;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local GUITabControl TabC;
	local rotator PlayerRot;

	Super.Initcomponent(MyController, MyOwner);

	// Set camera's pitch to zero when menu initialised (otherwise spinny weap goes kooky)
	PlayerRot = PlayerOwner().Rotation;
	SavedPitch = PlayerRot.Pitch;
	PlayerRot.Pitch = 0;
	PlayerOwner().SetRotation(PlayerRot);

	TabC = GUITabControl(Controls[1]);
	GUITitleBar(Controls[0]).DockedTabs = TabC;

	TabC.AddTab(VideoTabLabel,"xinterface.Tab_VideoSettings",,VideoTabHint,true);
	TabC.AddTab(DetailsTabLabel,"xinterface.Tab_DetailSettings",,DetailsTabHint);
	TabC.AddTab(AudioTabLabel,"xinterface.Tab_AudioSettings",,AudioTabHint);
	pPlayer = Tab_PlayerSettings(TabC.AddTab(PlayerTabLabel,"xinterface.Tab_PlayerSettings",,PlayerTabHint));
	pNetwork = Tab_NetworkSettings(TabC.AddTab(NetworkTabLabel,"xinterface.Tab_NetworkSettings",,NetworkTabHint));
	TabC.AddTab(ControlsTabLabel,"xinterface.Tab_ControlSettings",,ControlsTabHint);
//	if ( MyPlayer.ForceFeedbackSupported() )	-- Restore later
	TabC.AddTab(IForceTabLabel,"xinterface.Tab_IForceSettings",,IForceTabHint);
	pWeaponPref = Tab_WeaponPref(TabC.AddTab(WeaponsTabLabel,"xinterface.Tab_WeaponPref",,WeaponsTabHint));
    TabC.AddTab(HudTabLabel,"xinterface.Tab_HudSettings",,HudTabHint);
	TabC.AddTab(GameTabLabel,"xinterface.Tab_GameSettings",,GameTabHint);
	TabC.AddTab(SpeechBinderTabLabel,"xinterface.Tab_SpeechBinder",,SpeechBinderTabHint);
}

function TabChange(GUIComponent Sender)
{
	if (GUITabButton(Sender)==none)
		return;

	GUITitleBar(Controls[0]).SetCaption(GUITitleBar(default.Controls[0]).GetCaption()@"|"@GUITabButton(Sender).Caption);
}

event ChangeHint(string NewHint)
{
	GUITitleBar(Controls[2]).SetCaption(NewHint);
}


function InternalOnReOpen()
{
	local GUITabControl TabC;
	TabC = GUITabControl(Controls[1]);

	if ( (TabC.ActiveTab!=None) && (TabC.ActiveTab.MyPanel!=None) )
		TabC.ActiveTab.MyPanel.Refresh();
}

function bool ButtonClicked(GUIComponent Sender)
{
	if(InternalOnCanClose(false))
    {
    	GUITabControl(Controls[1]).ActiveTab.OnDeActivate();
		Controller.CloseMenu(true);
    }

	return true;
}

function bool InternalOnCanClose(optional bool bCanceled)
{
	if(!pNetwork.ValidStatConfig())
	{
		GUITabControl(Controls[1]).ActivateTabByName(NetworkTabLabel,true);
		return false;
	}
	else
		return true;
}

function bool NotifyLevelChange()
{
	Controller.CloseMenu(true);
	return Super.NotifyLevelChange();
}

function InternalOnClose(optional Bool bCanceled)
{
	local rotator NewRot;

	// Destroy spinning weapon actor
	if(pWeaponPref.SpinnyWeap != None)
	{
		pWeaponPref.SpinnyWeap.Destroy();
		pWeaponPref = None;
	}

	// Destroy spinning player model actor
	if(pPlayer.SpinnyDude != None)
	{
		pPlayer.SpinnyDude.Destroy();
		pPlayer.SpinnyDude = None;
	}

	// Reset player
	NewRot = PlayerOwner().Rotation;
	NewRot.Pitch = SavedPitch;
	PlayerOwner().SetRotation(NewRot);

	// Save config.
	pNetwork.ApplyStatConfig();
	pPlayer.InternalApply(none);
	pWeaponPref.WeapApply(none);

	Super.OnClose(bCanceled);
}

defaultproperties
{
     VideoTabLabel="Video"
     VideoTabHint="Select your resolution and change your brightness..."
     DetailsTabLabel="Details"
     DetailsTabHint="Adjust the detail settings for better graphics or faster framerate..."
     AudioTabLabel="Audio"
     AudioTabHint="Adjust your audio experience..."
     PlayerTabLabel="Player"
     PlayerTabHint="Configure your UT2003 Avatar..."
     NetworkTabLabel="Network"
     NetworkTabHint="Configure UT2003 for Online and Lan play..."
     ControlsTabLabel="Controls"
     ControlsTabHint="Configure your controls..."
     IForceTabLabel="Input"
     IForceTabHint="Configure misc. input options..."
     WeaponsTabLabel="Weapons"
     WeaponsTabHint="Adjust your weapon priorities and settings..."
     GameTabLabel="Game"
     GameTabHint="Adjust various game related settings..."
     HudTabLabel="Hud"
     HudTabHint="Customize your hud..."
     SpeechBinderTabLabel="Speech"
     SpeechBinderTabHint="Bind messages to keys..."
     Background=Texture'InterfaceContent.Backgrounds.bg11'
     OnReOpen=UT2SettingsPage.InternalOnReOpen
     OnClose=UT2SettingsPage.InternalOnClose
     OnCanClose=UT2SettingsPage.InternalOnCanClose
     Begin Object Class=GUITitleBar Name=SettingHeader
         Effect=FinalBlend'InterfaceContent.Menu.CO_Final'
         Caption="Settings"
         StyleName="Header"
         WinTop=0.036406
         WinHeight=46.000000
     End Object
     Controls(0)=GUITitleBar'XInterface.UT2SettingsPage.SettingHeader'

     Begin Object Class=GUITabControl Name=SettingTabs
         bDockPanels=True
         TabHeight=0.040000
         WinTop=0.250000
         WinHeight=48.000000
         bAcceptsInput=True
         OnActivate=SettingTabs.InternalOnActivate
         OnChange=UT2SettingsPage.TabChange
     End Object
     Controls(1)=GUITabControl'XInterface.UT2SettingsPage.SettingTabs'

     Begin Object Class=GUITitleBar Name=SettingFooter
         bUseTextHeight=False
         StyleName="Footer"
         WinTop=0.930000
         WinLeft=0.120000
         WinWidth=0.880000
         WinHeight=0.055000
     End Object
     Controls(2)=GUITitleBar'XInterface.UT2SettingsPage.SettingFooter'

     Begin Object Class=GUIButton Name=BackButton
         Caption="BACK"
         StyleName="SquareMenuButton"
         Hint="Return to Previous Menu"
         WinTop=0.930000
         WinWidth=0.120000
         WinHeight=0.055000
         OnClick=UT2SettingsPage.ButtonClicked
         OnKeyEvent=BackButton.InternalOnKeyEvent
     End Object
     Controls(3)=GUIButton'XInterface.UT2SettingsPage.BackButton'

     Begin Object Class=GUIImage Name=LogoSymbol
         Image=FinalBlend'InterfaceContent.Logos.fbSymbolShader'
         ImageStyle=ISTY_Scaled
         WinTop=0.800782
         WinLeft=0.830079
         WinWidth=0.260000
         WinHeight=0.130000
         bVisible=False
     End Object
     Controls(4)=GUIImage'XInterface.UT2SettingsPage.LogoSymbol'

     WinHeight=1.000000
}
