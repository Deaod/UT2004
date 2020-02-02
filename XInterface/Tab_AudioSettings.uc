// ====================================================================
//  Class:  XInterface.Tab_AudioSettings
//  Parent: XInterface.GUITabPanel
//
//  <Enter a description here>
// ====================================================================

class Tab_AudioSettings extends UT2K3TabPanel;

#exec OBJ LOAD FILE=PickupSounds.uax
#exec OBJ LOAD FILE=AnnouncerMale2K4.uax


var localized string	AudioModes[4],
						VoiceModes[4],
						AnnounceModes[3];



var moComboBox APack;
var config APackInfo BonusPackInfo[4];    // Mod authors, do put anything in here since it
										  // will be overwritten by the bonus pack.  Use PackInfo instead

var config array<APackInfo> PackInfo;

var bool binitialized;
function InitComponent(GUIController MyController, GUIComponent MyOwner)
{

	local int i;
    local string DefPack;

	Super.Initcomponent(MyController, MyOwner);

    bInitialized = false;

	for (i=0;i<Controls.Length;i++)
		Controls[i].OnChange=InternalOnChange;

	for(i = 0;i < ArrayCount(AudioModes);i++)
		moComboBox(Controls[8]).AddItem(AudioModes[i]);

	for(i = 0;i < ArrayCount(VoiceModes);i++)
		moComboBox(Controls[14]).AddItem(VoiceModes[i]);


	for(i = 0;i < ArrayCount(AnnounceModes);i++)
		moComboBox(Controls[15]).AddItem(AnnounceModes[i]);

	Controls[3].FriendlyLabel = GUILabel(Controls[2]);
	Controls[5].FriendlyLabel = GUILabel(Controls[4]);

    APack = moComboBox(Controls[16]);

    DefPack = class'UnrealPlayer'.Default.CustomizedAnnouncerPack;

    for (i=0;i<4;i++)
    {
    	if (BonusPackInfo[i].Description != "")
        {
	        APack.AddItem(BonusPackInfo[i].Description,none,BonusPackInfo[i].PackageName);
	        if (BonusPackInfo[i].PackageName ~= DefPack)
	            APack.SetText(BonusPackInfo[i].Description);
        }
    }

    // Add user announcer packs

    for (i=0;i<PackInfo.Length;i++)
    {
    	APack.AddItem(PackInfo[i].Description,none,PackInfo[i].PackageName);
        if (PackInfo[i].PackageName ~= DefPack)
        	APack.SetText(PackInfo[i].Description);
    }

	bInitialized = true;

}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
	local bool b1, b2, b3;

    if ( Sender==Controls[7] )
     	GUISlider(Controls[7]).SetValue(PlayerOwner().AnnouncerVolume);

	else if ( Sender==Controls[8] )
	{
	    B1 = bool( PlayerOwner().ConsoleCommand("get ini:Engine.Engine.AudioDevice UseEAX" ) );
	    B2 = bool( PlayerOwner().ConsoleCommand("get ini:Engine.Engine.AudioDevice CompatibilityMode" ) );
	    B3 = bool( PlayerOwner().ConsoleCommand("get ini:Engine.Engine.AudioDevice Use3DSound" ) );

	    if( B2 )
	        moComboBox(Controls[8]).SetText(AudioModes[3]);
	    else if( B1 )
			moComboBox(Controls[8]).SetText(AudioModes[2]);
		else if( B3 )
			moComboBox(Controls[8]).SetText(AudioModes[1]);
		else
			moComboBox(Controls[8]).SetText(AudioModes[0]);
	}

	else if (Sender==Controls[9])
	{
		moCheckBox(Sender).Checked(bool(s));
	}

	else if (Sender==Controls[14])
	{
	    if( !PlayerOwner().bNoVoiceMessages && !PlayerOwner().bNoVoiceTaunts && !PlayerOwner().bNoAutoTaunts )
			moComboBox(Controls[14]).SetText(VoiceModes[0]);
	    else if( !PlayerOwner().bNoVoiceMessages && !PlayerOwner().bNoVoiceTaunts && PlayerOwner().bNoAutoTaunts )
			moComboBox(Controls[14]).SetText(VoiceModes[1]);
	    else if( !PlayerOwner().bNoVoiceMessages && PlayerOwner().bNoVoiceTaunts && PlayerOwner().bNoAutoTaunts )
			moComboBox(Controls[14]).SetText(VoiceModes[2]);
	    else
		 	moComboBox(Controls[14]).SetText(VoiceModes[3]);
	}

	else if (Sender==Controls[10])
		moCheckBox(Sender).Checked(class'Hud'.default.bMessageBeep);

	else if (Sender==Controls[11])
		moCheckBox(Sender).Checked(PlayerOwner().bAutoTaunt);

	else if (Sender==Controls[12])
		moCheckBox(Sender).Checked(!PlayerOwner().bNoMatureLanguage);

	else if (Sender==Controls[13])
	{
	    B1 = PlayerOwner().Level.bLowSoundDetail;
		B2 = bool( PlayerOwner().ConsoleCommand("get ini:Engine.Engine.AudioDevice LowQualitySound" ) );

		// Make sure both are the same - LevelInfo.bLowSoundDetail take priority
		if(B1 != B2)
		{
			PlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice LowQualitySound"@B1);
			PlayerOwner().ConsoleCommand("SOUND_REBOOT");

			// Restart music.
			if( PlayerOwner().Level.Song != "" && PlayerOwner().Level.Song != "None" )
				PlayerOwner().ClientSetMusic( PlayerOwner().Level.Song, MTRAN_Instant );
		}

		moCheckBox(Sender).Checked(B1);
	}

	else if (Sender==Controls[15])
		moComboBox(Sender).setIndex(PlayerOwner().AnnouncerLevel);


}

function string InternalOnSaveINI(GUIComponent Sender); 		// Do the actual work here



function InternalOnChange(GUIComponent Sender)
{
	local String t;
	local bool b1,b2,b3;

	if (!Controller.bCurMenuInitialized)
		return;

	if (Sender==Controls[3])
	{
   	    PlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice MusicVolume "$GUISlider(Sender).Value);
	}

	else if (Sender==Controls[5])
	{
   	    PlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice SoundVolume "$GUISlider(Sender).Value);
   	    PlayerOwner().ConsoleCommand("stopsounds");
		PlayerOwner().PlaySound(sound'PickupSounds.AdrenelinPickup');
	}

	else if (Sender==Controls[7])
	{
   	    PlayerOwner().AnnouncerVolume=GUISlider(Controls[7]).Value;
        PlayerOwner().SaveConfig();
        PlayerOwner().PlayRewardAnnouncement('Adrenalin', 0, true);
	}

	else if (Sender==Controls[8])
	{
		t = moComboBox(Sender).GetText();

		if (t==AudioModes[3])
		{
            PlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice UseEAX false" );
            PlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice Use3DSound false" );
            PlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice CompatibilityMode true" );
		}
		else if (t==AudioModes[0])
		{
            PlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice UseEAX false" );
            PlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice Use3DSound false" );
            PlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice CompatibilityMode false" );
		}
		else if (t==AudioModes[1])
		{
            PlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice UseEAX false" );
            PlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice Use3DSound true" );
            PlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice CompatibilityMode false" );
			Controller.OpenMenu("XInterface.UT2PerformWarn");
		}

		else if (t==AudioModes[2])
		{
            PlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice UseEAX true" );
            PlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice Use3DSound true" );
            PlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice CompatibilityMode false" );
			Controller.OpenMenu("XInterface.UT2PerformWarn");
		}

		PlayerOwner().ConsoleCommand("SOUND_REBOOT");

		// Restart music.
		if( PlayerOwner().Level.Song != "" && PlayerOwner().Level.Song != "None" )
			PlayerOwner().ClientSetMusic( PlayerOwner().Level.Song, MTRAN_Instant );

    }

	else if (Sender==Controls[9])
		PlayerOwner().ConsoleCommand("set"@Sender.INIOption@moCheckBox(Sender).IsChecked());

	else if (Sender==Controls[10])
	{
		if( PlayerOwner().MyHud != None )
			PlayerOwner().MyHud.bMessageBeep = moCheckBox(Sender).IsChecked();

		class'Hud'.default.bMessageBeep = moCheckBox(Sender).IsChecked();
		class'Hud'.static.StaticSaveConfig();
	}

	else if (Sender==Controls[11])
		PlayerOwner().SetAutoTaunt(moCheckBox(Sender).IsChecked());

	else if (Sender==Controls[12])
	{
		PlayerOwner().bNoMatureLanguage = !moCheckBox(Sender).IsChecked();
		PlayerOwner().SaveConfig();
	}

	else if (Sender==Controls[14])
	{
		t = moComboBox(Sender).GetText();

		if (t==VoiceModes[0])
		{
			b1 = false;
			b2 = false;
			b3 = false;
		}
		else if (t==VoiceModes[1])
		{
			b1 = true;
			b2 = false;
			b3 = false;
		}
		else if (t==VoiceModes[2])
		{
			b1 = true;
			b2 = true;
			b3 = false;
		}
		else
		{
			b1 = true;
			b2 = true;
			b3 = true;
		}

		PlayerOwner().bNoAutoTaunts=b1;
		PlayerOwner().bNoVoiceTaunts=b2;
		PlayerOwner().bNoVoiceMessages=b3;
		PlayerOwner().SaveConfig();
	}

	else if (Sender==Controls[13])
	{

		b1 = moCheckBox(Sender).IsChecked();

		PlayerOwner().Level.bLowSoundDetail = b1;
        PlayerOwner().Level.SaveConfig();

		PlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice LowQualitySound"@B1);
		PlayerOwner().ConsoleCommand("SOUND_REBOOT");

		// Restart music.
		if( PlayerOwner().Level.Song != "" && PlayerOwner().Level.Song != "None" )
			PlayerOwner().ClientSetMusic( PlayerOwner().Level.Song, MTRAN_Instant );
	}

	else if (Sender==Controls[15])
	{
		PlayerOwner().AnnouncerLevel = moComboBox(Sender).GetIndex();
		PlayerOwner().SaveConfig();
	}

    else if (Sender==APack)
    {
        class'UnrealPlayer'.default.CustomizedAnnouncerPack = APack.GetExtra();
        class'UnrealPlayer'.static.StaticSaveConfig();

        if (UnrealPlayer(PlayerOwner())!=None)
	    	UnrealPlayer(PlayerOwner()).CustomizedAnnouncerPack = APack.GetExtra();
    }

}

defaultproperties
{
     AudioModes(0)="Software 3D Audio"
     AudioModes(1)="Hardware 3D Audio"
     AudioModes(2)="Hardware 3D Audio + EAX"
     AudioModes(3)="Safe Mode"
     VoiceModes(0)="All"
     VoiceModes(1)="No auto-taunts"
     VoiceModes(2)="No taunts"
     VoiceModes(3)="None"
     AnnounceModes(0)="None"
     AnnounceModes(1)="Minimal"
     AnnounceModes(2)="All"
     Begin Object Class=GUIImage Name=AudioBK1
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.083281
         WinLeft=0.021641
         WinWidth=0.957500
         WinHeight=0.166289
     End Object
     Controls(0)=GUIImage'XInterface.Tab_AudioSettings.AudioBK1'

     Begin Object Class=GUIImage Name=AudioBK2
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.362446
         WinLeft=0.021641
         WinWidth=0.957500
         WinHeight=0.625897
     End Object
     Controls(1)=GUIImage'XInterface.Tab_AudioSettings.AudioBK2'

     Begin Object Class=GUILabel Name=AudioMusicVolumeLabel
         Caption="Music Volume"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.100000
         WinLeft=0.055664
         WinWidth=0.250000
         WinHeight=32.000000
     End Object
     Controls(2)=GUILabel'XInterface.Tab_AudioSettings.AudioMusicVolumeLabel'

     Begin Object Class=GUISlider Name=AudioMusicVolumeSlider
         MaxValue=1.000000
         IniOption="ini:Engine.Engine.AudioDevice MusicVolume"
         IniDefault="0.5"
         Hint="Changes the volume of the background music."
         WinTop=0.156146
         WinLeft=0.062500
         WinWidth=0.250000
         OnClick=AudioMusicVolumeSlider.InternalOnClick
         OnMousePressed=AudioMusicVolumeSlider.InternalOnMousePressed
         OnMouseRelease=AudioMusicVolumeSlider.InternalOnMouseRelease
         OnKeyEvent=AudioMusicVolumeSlider.InternalOnKeyEvent
         OnCapturedMouseMove=AudioMusicVolumeSlider.InternalCapturedMouseMove
     End Object
     Controls(3)=GUISlider'XInterface.Tab_AudioSettings.AudioMusicVolumeSlider'

     Begin Object Class=GUILabel Name=AudioEffectsVolumeLabel
         Caption="Effects Volume"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.100000
         WinLeft=0.685547
         WinWidth=0.250000
         WinHeight=32.000000
     End Object
     Controls(4)=GUILabel'XInterface.Tab_AudioSettings.AudioEffectsVolumeLabel'

     Begin Object Class=GUISlider Name=AudioEffectsVolumeSlider
         MaxValue=1.000000
         IniOption="ini:Engine.Engine.AudioDevice SoundVolume"
         IniDefault="0.9"
         Hint="Changes the volume of all in game sound effects."
         WinTop=0.156146
         WinLeft=0.687500
         WinWidth=0.250000
         OnClick=AudioEffectsVolumeSlider.InternalOnClick
         OnMousePressed=AudioEffectsVolumeSlider.InternalOnMousePressed
         OnMouseRelease=AudioEffectsVolumeSlider.InternalOnMouseRelease
         OnKeyEvent=AudioEffectsVolumeSlider.InternalOnKeyEvent
         OnCapturedMouseMove=AudioEffectsVolumeSlider.InternalCapturedMouseMove
     End Object
     Controls(5)=GUISlider'XInterface.Tab_AudioSettings.AudioEffectsVolumeSlider'

     Begin Object Class=GUILabel Name=AudioVoiceVolumeLabel
         Caption="Announcer Volume"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.100000
         WinLeft=0.369141
         WinWidth=0.250000
         WinHeight=32.000000
     End Object
     Controls(6)=GUILabel'XInterface.Tab_AudioSettings.AudioVoiceVolumeLabel'

     Begin Object Class=GUISlider Name=AudioVoiceVolumeSlider
         MinValue=1.000000
         MaxValue=4.000000
         bIntSlider=True
         IniOption="@Internal"
         Hint="Changes the volume of all in game voice messages."
         WinTop=0.156146
         WinLeft=0.375000
         WinWidth=0.250000
         OnClick=AudioVoiceVolumeSlider.InternalOnClick
         OnMousePressed=AudioVoiceVolumeSlider.InternalOnMousePressed
         OnMouseRelease=AudioVoiceVolumeSlider.InternalOnMouseRelease
         OnKeyEvent=AudioVoiceVolumeSlider.InternalOnKeyEvent
         OnCapturedMouseMove=AudioVoiceVolumeSlider.InternalCapturedMouseMove
         OnLoadINI=Tab_AudioSettings.InternalOnLoadINI
     End Object
     Controls(7)=GUISlider'XInterface.Tab_AudioSettings.AudioVoiceVolumeSlider'

     Begin Object Class=moComboBox Name=AudioMode
         bReadOnly=True
         ComponentJustification=TXTA_Left
         CaptionWidth=0.300000
         Caption="Audio Mode"
         OnCreateComponent=AudioMode.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="Software 3D Audio"
         Hint="Changes the audio system mode."
         WinTop=0.278646
         WinLeft=0.150000
         WinWidth=0.700000
         WinHeight=0.060000
         OnLoadINI=Tab_AudioSettings.InternalOnLoadINI
         OnSaveINI=Tab_AudioSettings.InternalOnSaveINI
     End Object
     Controls(8)=moComboBox'XInterface.Tab_AudioSettings.AudioMode'

     Begin Object Class=moCheckBox Name=AudioReverseStereo
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Reverse Stereo"
         OnCreateComponent=AudioReverseStereo.InternalOnCreateComponent
         IniOption="ini:Engine.Engine.AudioDevice ReverseStereo"
         IniDefault="False"
         Hint="Reverses the left and right audio channels."
         WinTop=0.433333
         WinLeft=0.100000
         WinWidth=0.300000
         WinHeight=0.040000
         OnLoadINI=Tab_AudioSettings.InternalOnLoadINI
         OnSaveINI=Tab_AudioSettings.InternalOnSaveINI
     End Object
     Controls(9)=moCheckBox'XInterface.Tab_AudioSettings.AudioReverseStereo'

     Begin Object Class=moCheckBox Name=AudioMessageBeep
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Message Beep"
         OnCreateComponent=AudioMessageBeep.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="True"
         Hint="Enables a beep when receiving a text message from other players."
         WinTop=0.433333
         WinLeft=0.600000
         WinWidth=0.300000
         WinHeight=0.040000
         OnLoadINI=Tab_AudioSettings.InternalOnLoadINI
         OnSaveINI=Tab_AudioSettings.InternalOnSaveINI
     End Object
     Controls(10)=moCheckBox'XInterface.Tab_AudioSettings.AudioMessageBeep'

     Begin Object Class=moCheckBox Name=AudioAutoTaunt
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Auto-Taunt"
         OnCreateComponent=AudioAutoTaunt.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="True"
         Hint="Enables your in-game player to automatically taunt opponents."
         WinTop=0.533333
         WinLeft=0.100000
         WinWidth=0.300000
         WinHeight=0.040000
         OnLoadINI=Tab_AudioSettings.InternalOnLoadINI
         OnSaveINI=Tab_AudioSettings.InternalOnSaveINI
     End Object
     Controls(11)=moCheckBox'XInterface.Tab_AudioSettings.AudioAutoTaunt'

     Begin Object Class=moCheckBox Name=AudioMatureTaunts
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Mature Taunts"
         OnCreateComponent=AudioMatureTaunts.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="True"
         Hint="Enables off-color commentary."
         WinTop=0.533330
         WinLeft=0.600000
         WinWidth=0.300000
         WinHeight=0.040000
         OnLoadINI=Tab_AudioSettings.InternalOnLoadINI
         OnSaveINI=Tab_AudioSettings.InternalOnSaveINI
     End Object
     Controls(12)=moCheckBox'XInterface.Tab_AudioSettings.AudioMatureTaunts'

     Begin Object Class=moCheckBox Name=AudioLowDetail
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Low Sound Detail"
         OnCreateComponent=AudioLowDetail.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="False"
         Hint="Lowers quality of sound."
         WinTop=0.633330
         WinLeft=0.100000
         WinWidth=0.300000
         WinHeight=0.040000
         OnLoadINI=Tab_AudioSettings.InternalOnLoadINI
         OnSaveINI=Tab_AudioSettings.InternalOnSaveINI
     End Object
     Controls(13)=moCheckBox'XInterface.Tab_AudioSettings.AudioLowDetail'

     Begin Object Class=moComboBox Name=AudioPlayVoices
         bReadOnly=True
         ComponentJustification=TXTA_Left
         Caption="Play Voices"
         OnCreateComponent=AudioPlayVoices.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="All"
         Hint="Defines the types of voice messages to play."
         WinTop=0.733291
         WinLeft=0.260352
         WinWidth=0.468750
         WinHeight=0.060000
         OnLoadINI=Tab_AudioSettings.InternalOnLoadINI
         OnSaveINI=Tab_AudioSettings.InternalOnSaveINI
     End Object
     Controls(14)=moComboBox'XInterface.Tab_AudioSettings.AudioPlayVoices'

     Begin Object Class=moComboBox Name=AudioAnnounce
         bReadOnly=True
         ComponentJustification=TXTA_Left
         Caption="Announcements"
         OnCreateComponent=AudioAnnounce.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="All"
         Hint="Adjusts the amount of in-game announcements."
         WinTop=0.816597
         WinLeft=0.260352
         WinWidth=0.468750
         WinHeight=0.060000
         OnLoadINI=Tab_AudioSettings.InternalOnLoadINI
         OnSaveINI=Tab_AudioSettings.InternalOnSaveINI
     End Object
     Controls(15)=moComboBox'XInterface.Tab_AudioSettings.AudioAnnounce'

     Begin Object Class=moComboBox Name=AudioAnnouncerPack
         bReadOnly=True
         ComponentJustification=TXTA_Left
         Caption="Announcer Voice"
         OnCreateComponent=AudioAnnouncerPack.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Select the Announcer for tonight's game."
         WinTop=0.900069
         WinLeft=0.260352
         WinWidth=0.468750
         WinHeight=0.060000
         OnLoadINI=Tab_AudioSettings.InternalOnLoadINI
         OnSaveINI=Tab_AudioSettings.InternalOnSaveINI
     End Object
     Controls(16)=moComboBox'XInterface.Tab_AudioSettings.AudioAnnouncerPack'

     WinTop=0.150000
     WinHeight=0.740000
}
