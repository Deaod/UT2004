// ====================================================================
//  Class:  XInterface.Tab_VideoSettings
//  Parent: XInterface.GUITabPanel
//
//  <Enter a description here>
// ====================================================================

class Tab_VideoSettings extends UT2K3TabPanel;

#exec OBJ LOAD FILE=InterfaceContent.utx

var		bool ShowSShot;

struct DisplayMode
{
	var int	Width,
			Height;
};

var DisplayMode DisplayModes[23];

var localized string	BitDepthText[2];

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;
	Super.Initcomponent(MyController, MyOwner);

	for (i=0;i<Controls.Length;i++)
		Controls[i].OnChange=InternalOnChange;

	moComboBox(Controls[1]).AddItem(BitDepthText[0]);
	moComboBox(Controls[1]).AddItem(BitDepthText[1]);
	moComboBox(Controls[1]).ReadOnly(true);
	
	CheckSupportedResolutions();
	
	Controls[6].FriendlyLabel  = GUILabel(Controls[5]);
	Controls[8].FriendlyLabel  = GUILabel(Controls[7]);
	Controls[10].FriendlyLabel = GUILabel(Controls[9]);
	
}

function CheckSupportedResolutions()
{
	local int		HighestRes;
	local int		Index;
	local int		BitDepth;
	local string	CurrentSelection;

	CurrentSelection = moComboBox(Controls[0]).MyComboBox.Edit.GetText();
	if(moComboBox(Controls[0]).ItemCount() > 0)
	moComboBox(Controls[0]).RemoveItem(0,moComboBox(Controls[0]).ItemCount());

	if(moComboBox(Controls[1]).GetText()==BitDepthText[0])
		BitDepth = 16;
	else
		BitDepth = 32;

	// Don't let user create non-fullscreen window bigger than highest
	//  supported resolution, or MacOS X client crashes. --ryan.
	if(!moCheckBox(Controls[2]).IsChecked()) // Controls[2] == fs toggle.
	{
		HighestRes = 0;
		for(Index = 0;Index < ArrayCount(DisplayModes);Index++)
		{
			if (PlayerOwner().ConsoleCommand(
					"SupportedResolution"$
					" WIDTH="$DisplayModes[Index].Width$
					" HEIGHT="$DisplayModes[Index].Height$
					" BITDEPTH="$BitDepth) == "1")
			{
				HighestRes = Index;   // biggest resolution hardware supports.
			}
		}

		for(Index = 0;Index <= HighestRes;Index++)
		{
			moComboBox(Controls[0]).AddItem(DisplayModes[Index].Width$"x"$DisplayModes[Index].Height);
		}
	}

	else  // Set dropdown for fullscreen modes...
	{
		for(Index = 0;Index < ArrayCount(DisplayModes);Index++)
		{
			if (PlayerOwner().ConsoleCommand(
				"SupportedResolution"$
				" WIDTH="$DisplayModes[Index].Width$
				" HEIGHT="$DisplayModes[Index].Height$
				" BITDEPTH="$BitDepth) == "1")
			{
				moComboBox(Controls[0]).AddItem(DisplayModes[Index].Width$"x"$DisplayModes[Index].Height);
			}
		}
    }

	moComboBox(Controls[0]).SetText(CurrentSelection);
}

function Refresh()
{
	InternalOnLoadINI(Controls[0],"");
	InternalOnLoadINI(Controls[1],"");
	InternalOnLoadINI(Controls[2],"");
}
	
function InternalOnLoadINI(GUIComponent Sender, string s)
{
	local string temp;

	if (Sender==Controls[0])
	{
		// Resolution
		if(Controller.GameResolution != "")
			moComboBox(Controls[0]).SetText(Controller.GameResolution);
		else
			moComboBox(Controls[0]).SetText(Controller.GetCurrentRes());
	}
	if (Sender==Controls[1])
	{
		if (PlayerOwner().ConsoleCommand("get ini:Engine.Engine.RenderDevice Use16bit") ~= "true")
			moComboBox(Sender).SetText(BitDepthText[0]);
		else
			moComboBox(Sender).SetText(BitDepthText[1]);

		CheckSupportedResolutions();
	}
	else if (Sender==Controls[2])
	{
		Temp = Sender.PlayerOwner().ConsoleCommand("ISFULLSCREEN");
		moCheckBox(Sender).Checked(bool(Temp));	
		CheckSupportedResolutions();
	}			
}		
		 
function string InternalOnSaveINI(GUIComponent Sender); 		// Do the actual work here

function InternalOnChange(GUIComponent Sender)
{
	if (!Controller.bCurMenuInitialized)
		return;

	if (Sender==Controls[0] || Sender==Controls[1] || Sender==Controls[2] )
	{
		Controls[3].bVisible=true;
		
		if(Sender != Controls[0])
			CheckSupportedResolutions();
	}

	else if (Sender==Controls[6])
		PlayerOwner().ConsoleCommand("GAMMA"@GUISlider(Controls[6]).Value);

	else if (Sender==Controls[8])
		PlayerOwner().ConsoleCommand("BRIGHTNESS"@GUISlider(Controls[8]).Value);
		
	else if (Sender==Controls[10])
		PlayerOwner().ConsoleCommand("CONTRAST"@GUISlider(Controls[10]).Value);
}			

function bool ApplyChanges(GUIComponent Sender)
{
	local string DesiredRes;

	DesiredRes = moComboBox(Controls[0]).MyComboBox.Edit.GetText();
	
	if (moComboBox(Controls[1]).GetText()==BitDepthText[0])
		DesiredRes=DesiredRes$"x16";
	else
		DesiredRes=DesiredRes$"x32";

	if (moCheckBox(Controls[2]).IsChecked())
		DesiredRes=DesiredRes$"f";
	else
		DesiredRes=DesiredRes$"w";

	Controls[3].bVisible=false;
		
	if ( Controller.OpenMenu("xinterface.UT2VideoChangeOK") )
		UT2VideoChangeOK(Controller.TopPage()).Execute(DesiredRes);

	return true;
}

function bool InternalOnClick(GUIComponent Sender)
{
	showsshot = !showsshot;
	
	Controls[12].bVisible = !ShowSShot;
	Controls[13].bVisible = !ShowSShot;
	
	if (showsshot)
		GUIImage(Controls[11]).Image = material'GammaSet1';
	else
		GUIImage(Controls[11]).Image = material'GammaSet0';
		
	return true;
}						

defaultproperties
{
     DisplayModes(0)=(Width=320,Height=240)
     DisplayModes(1)=(Width=512,Height=384)
     DisplayModes(2)=(Width=640,Height=480)
     DisplayModes(3)=(Width=720,Height=480)
     DisplayModes(4)=(Width=800,Height=500)
     DisplayModes(5)=(Width=800,Height=600)
     DisplayModes(6)=(Width=840,Height=524)
     DisplayModes(7)=(Width=896,Height=600)
     DisplayModes(8)=(Width=1024,Height=640)
     DisplayModes(9)=(Width=1024,Height=768)
     DisplayModes(10)=(Width=1152,Height=720)
     DisplayModes(11)=(Width=1152,Height=864)
     DisplayModes(12)=(Width=1280,Height=800)
     DisplayModes(13)=(Width=1280,Height=854)
     DisplayModes(14)=(Width=1280,Height=960)
     DisplayModes(15)=(Width=1280,Height=1024)
     DisplayModes(16)=(Width=1344,Height=840)
     DisplayModes(17)=(Width=1440,Height=900)
     DisplayModes(18)=(Width=1600,Height=1200)
     DisplayModes(19)=(Width=1680,Height=1050)
     DisplayModes(20)=(Width=1920,Height=1200)
     DisplayModes(21)=(Width=2048,Height=1280)
     DisplayModes(22)=(Width=2560,Height=1600)
     BitDepthText(0)="16-bit Color"
     BitDepthText(1)="32-bit Color"
     Begin Object Class=moComboBox Name=VideoResolution
         bReadOnly=True
         CaptionWidth=0.375000
         Caption="Resolution"
         OnCreateComponent=VideoResolution.InternalOnCreateComponent
         IniOption="@INTERNAL"
         IniDefault="640x480"
         Hint="Select the video resolution at which you wish to play."
         WinTop=0.047396
         WinLeft=0.124258
         WinWidth=0.390000
         WinHeight=0.050000
         OnLoadINI=Tab_VideoSettings.InternalOnLoadINI
         OnSaveINI=Tab_VideoSettings.InternalOnSaveINI
     End Object
     Controls(0)=moComboBox'XInterface.Tab_VideoSettings.VideoResolution'

     Begin Object Class=moComboBox Name=VideoColorDepth
         CaptionWidth=0.375000
         Caption="Color Depth"
         OnCreateComponent=VideoColorDepth.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="false"
         Hint="Select the maximum number of colors to display at one time."
         WinTop=0.152345
         WinLeft=0.121484
         WinWidth=0.390000
         WinHeight=0.050000
         OnLoadINI=Tab_VideoSettings.InternalOnLoadINI
         OnSaveINI=Tab_VideoSettings.InternalOnSaveINI
     End Object
     Controls(1)=moComboBox'XInterface.Tab_VideoSettings.VideoColorDepth'

     Begin Object Class=moCheckBox Name=VideoFullScreen
         ComponentJustification=TXTA_Left
         CaptionWidth=0.375000
         Caption="Full Screen"
         OnCreateComponent=VideoFullScreen.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="True"
         Hint="Check this box to run the game full screen."
         WinTop=0.047396
         WinLeft=0.667226
         WinWidth=0.350000
         WinHeight=0.040000
         OnLoadINI=Tab_VideoSettings.InternalOnLoadINI
         OnSaveINI=Tab_VideoSettings.InternalOnSaveINI
     End Object
     Controls(2)=moCheckBox'XInterface.Tab_VideoSettings.VideoFullScreen'

     Begin Object Class=GUIButton Name=VideoApply
         Caption="Apply Changes"
         Hint="Apply all changes to your video settings."
         WinTop=0.152345
         WinLeft=0.667226
         WinWidth=0.250000
         WinHeight=0.050000
         bVisible=False
         OnClick=Tab_VideoSettings.ApplyChanges
         OnKeyEvent=VideoApply.InternalOnKeyEvent
     End Object
     Controls(3)=GUIButton'XInterface.Tab_VideoSettings.VideoApply'

     Begin Object Class=GUIImage Name=GammaBK
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.280365
         WinLeft=0.021641
         WinWidth=0.957500
         WinHeight=0.697273
     End Object
     Controls(4)=GUIImage'XInterface.Tab_VideoSettings.GammaBK'

     Begin Object Class=GUILabel Name=GammaLabel
         Caption="Gamma"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         StyleName="TextLabel"
         WinTop=0.341146
         WinLeft=0.060547
         WinWidth=0.250000
         WinHeight=32.000000
     End Object
     Controls(5)=GUILabel'XInterface.Tab_VideoSettings.GammaLabel'

     Begin Object Class=GUISlider Name=GammaSlider
         MinValue=0.500000
         MaxValue=2.500000
         IniOption="ini:Engine.Engine.ViewportManager Gamma"
         IniDefault="0.8"
         Hint="Use the slider to adjust the Gamma to suit your monitor."
         WinTop=0.402345
         WinLeft=0.062500
         WinWidth=0.250000
         OnClick=GammaSlider.InternalOnClick
         OnMousePressed=GammaSlider.InternalOnMousePressed
         OnMouseRelease=GammaSlider.InternalOnMouseRelease
         OnKeyEvent=GammaSlider.InternalOnKeyEvent
         OnCapturedMouseMove=GammaSlider.InternalCapturedMouseMove
     End Object
     Controls(6)=GUISlider'XInterface.Tab_VideoSettings.GammaSlider'

     Begin Object Class=GUILabel Name=BrightnessLabel
         Caption="Brightness"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         StyleName="TextLabel"
         WinTop=0.555990
         WinLeft=0.061524
         WinWidth=0.250000
         WinHeight=32.000000
     End Object
     Controls(7)=GUILabel'XInterface.Tab_VideoSettings.BrightnessLabel'

     Begin Object Class=GUISlider Name=BrightnessSlider
         MaxValue=1.000000
         IniOption="ini:Engine.Engine.ViewportManager Brightness"
         IniDefault="0.8"
         Hint="Use the slider to adjust the Brightness to suit your monitor."
         WinTop=0.623699
         WinLeft=0.062500
         WinWidth=0.250000
         OnClick=BrightnessSlider.InternalOnClick
         OnMousePressed=BrightnessSlider.InternalOnMousePressed
         OnMouseRelease=BrightnessSlider.InternalOnMouseRelease
         OnKeyEvent=BrightnessSlider.InternalOnKeyEvent
         OnCapturedMouseMove=BrightnessSlider.InternalCapturedMouseMove
     End Object
     Controls(8)=GUISlider'XInterface.Tab_VideoSettings.BrightnessSlider'

     Begin Object Class=GUILabel Name=ContrastLabel
         Caption="Contrast"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         StyleName="TextLabel"
         WinTop=0.790365
         WinLeft=0.059570
         WinWidth=0.250000
         WinHeight=32.000000
     End Object
     Controls(9)=GUILabel'XInterface.Tab_VideoSettings.ContrastLabel'

     Begin Object Class=GUISlider Name=ContrastSlider
         MaxValue=1.000000
         IniOption="ini:Engine.Engine.ViewportManager Contrast"
         IniDefault="0.8"
         Hint="Use the slider to adjust the Contrast to suit your monitor."
         WinTop=0.851565
         WinLeft=0.062500
         WinWidth=0.250000
         OnClick=ContrastSlider.InternalOnClick
         OnMousePressed=ContrastSlider.InternalOnMousePressed
         OnMouseRelease=ContrastSlider.InternalOnMouseRelease
         OnKeyEvent=ContrastSlider.InternalOnKeyEvent
         OnCapturedMouseMove=ContrastSlider.InternalCapturedMouseMove
     End Object
     Controls(10)=GUISlider'XInterface.Tab_VideoSettings.ContrastSlider'

     Begin Object Class=GUIImage Name=GammaBar
         Image=Texture'InterfaceContent.Menu.GammaSet1'
         WinTop=0.377604
         WinLeft=0.454102
         WinWidth=0.400000
         WinHeight=0.500000
     End Object
     Controls(11)=GUIImage'XInterface.Tab_VideoSettings.GammaBar'

     Begin Object Class=GUILabel Name=BrightDesc1
         Caption="Adjust the Gamma Setting so that the"
         TextAlign=TXTA_Center
         TextColor=(B=0,G=200,R=230)
         WinTop=0.800000
         WinLeft=0.151367
         WinHeight=32.000000
         bVisible=False
     End Object
     Controls(12)=GUILabel'XInterface.Tab_VideoSettings.BrightDesc1'

     Begin Object Class=GUILabel Name=BrightDesc2
         Caption="Square is completely black."
         TextAlign=TXTA_Center
         TextColor=(B=0,G=200,R=230)
         WinTop=0.870000
         WinLeft=0.136719
         WinHeight=32.000000
         bVisible=False
     End Object
     Controls(13)=GUILabel'XInterface.Tab_VideoSettings.BrightDesc2'

     Begin Object Class=GUIButton Name=VideoLeft
         StyleName="ArrowLeft"
         WinTop=0.573959
         WinLeft=0.397656
         WinWidth=0.043555
         WinHeight=0.084414
         bVisible=False
         bNeverFocus=True
         bRepeatClick=True
         OnClick=Tab_VideoSettings.InternalOnClick
         OnKeyEvent=VideoLeft.InternalOnKeyEvent
     End Object
     Controls(14)=GUIButton'XInterface.Tab_VideoSettings.VideoLeft'

     Begin Object Class=GUIButton Name=VideoRight
         StyleName="ArrowRight"
         WinTop=0.573959
         WinLeft=0.864063
         WinWidth=0.043555
         WinHeight=0.084414
         bVisible=False
         bNeverFocus=True
         bRepeatClick=True
         OnClick=Tab_VideoSettings.InternalOnClick
         OnKeyEvent=VideoRight.InternalOnKeyEvent
     End Object
     Controls(15)=GUIButton'XInterface.Tab_VideoSettings.VideoRight'

     WinTop=0.150000
     WinHeight=0.740000
}
