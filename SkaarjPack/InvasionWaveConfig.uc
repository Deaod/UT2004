// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class InvasionWaveConfig extends UT2K3GUIPage
	DependsOn(Invasion);

var bool bInitialized;
var moNumericEdit WaveNo;
var GUISlider MySkill;
var moNumericEdit MyTime;

var Invasion.WaveInfo Waves[16];	// Defaults


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

    WaveNo = moNumericEdit(Controls[4]);
    MySkill = GUISlider(Controls[6]);
    MyTime = moNumericEdit(Controls[7]);

    GUIEditBox(WaveNo.MyNumericEdit.Controls[0]).bReadOnly = true;

    bInitialized = true;
    WaveNo.SetValue(1);
}

function WaveChanged(GUIComponent Sender)
{
	local int i;
    local byte Wave;
    local int wMask;

	if (!bInitialized)
    	return;

/*
struct WaveInfo
{
	var int WaveMask;	// bit fields for which monsterclasses
	var int WaveMaxMonsters;
	var float WaveMonsterInterval;
	var float WaveDifficulty;
	var float WaveDuration;
	var class<Monster> WaveFallbackMonster;
};
*/

	bInitialized = false;

    Wave = WaveNo.GetValue()-1;

    MySkill.SetValue(class'Invasion'.default.Waves[Wave].WaveDifficulty);
    MyTime.SetValue(class'Invasion'.default.Waves[Wave].WaveDuration);

    wMask = class'Invasion'.default.Waves[Wave].WaveMask;
    for (i=8;i<24;i++)
    	moCheckBox(Controls[i]).Checked(bool(wMask & moCheckBox(Controls[i]).Tag));

    bInitialized = true;

}

function SkillChanged(GUIComponent Sender)
{
	if (!bInitialized)
    	return;

	class'Invasion'.default.Waves[WaveNo.GetValue()-1].WaveDifficulty = MySkill.Value;
    class'Invasion'.static.staticsaveconfig();

}

function DurationChanged(GUIComponent Sender)
{
	if (!bInitialized)
    	return;

	class'Invasion'.default.Waves[WaveNo.GetValue()-1].WaveDuration = MyTime.GetValue();
    class'Invasion'.static.staticsaveconfig();

}

function CheckChanged(GUIComponent Sender)
{
	local int mask,mod;

    if (!bInitialized || moCheckBox(Sender)==None)
    	return;

	Mask = 0;
	for (Mod=8;Mod<24;Mod++)
    	if (moCheckBox(Controls[Mod]).IsChecked())
        	Mask += Controls[Mod].Tag;

    class'Invasion'.default.Waves[WaveNo.GetValue()-1].WaveMask = Mask;
    class'Invasion'.static.staticsaveconfig();
}

function bool CloseClicked(GUIComponent Sender)
{
	Controller.CloseMenu();
    return true;
}

function bool ResetClicked(GUIComponent Sender)
{
	local int i;

    for (i=0;i<16;i++)
		class'Invasion'.default.Waves[i] = Waves[i];

    class'Invasion'.static.staticsaveconfig();
    WaveNo.SetValue(1);

    return true;
}

defaultproperties
{
     Waves(0)=(WaveMask=20491,WaveMaxMonsters=16,WaveDuration=90)
     Waves(1)=(WaveMask=60,WaveMaxMonsters=12,WaveDuration=90)
     Waves(2)=(WaveMask=105,WaveMaxMonsters=12,WaveDuration=90,WaveDifficulty=0.500000)
     Waves(3)=(WaveMask=186,WaveMaxMonsters=12,WaveDuration=90,WaveDifficulty=0.500000)
     Waves(4)=(WaveMask=225,WaveMaxMonsters=12,WaveDuration=90,WaveDifficulty=0.500000)
     Waves(5)=(WaveMask=966,WaveMaxMonsters=12,WaveDuration=90,WaveDifficulty=1.000000)
     Waves(6)=(WaveMask=4771,WaveMaxMonsters=12,WaveDuration=120,WaveDifficulty=1.000000)
     Waves(7)=(WaveMask=917,WaveMaxMonsters=12,WaveDuration=120,WaveDifficulty=1.000000)
     Waves(8)=(WaveMask=1689,WaveMaxMonsters=12,WaveDuration=120,WaveDifficulty=1.500000)
     Waves(9)=(WaveMask=18260,WaveMaxMonsters=12,WaveDuration=120,WaveDifficulty=1.500000)
     Waves(10)=(WaveMask=14340,WaveMaxMonsters=12,WaveDuration=180,WaveDifficulty=1.500000)
     Waves(11)=(WaveMask=4021,WaveMaxMonsters=12,WaveDuration=180,WaveDifficulty=2.000000)
     Waves(12)=(WaveMask=3729,WaveMaxMonsters=12,WaveDuration=180,WaveDifficulty=2.000000)
     Waves(13)=(WaveMask=3972,WaveMaxMonsters=12,WaveDuration=180,WaveDifficulty=2.000000)
     Waves(14)=(WaveMask=3712,WaveMaxMonsters=12,WaveDuration=180,WaveDifficulty=2.000000)
     Waves(15)=(WaveMask=2048,WaveMaxMonsters=8,WaveDuration=255,WaveDifficulty=2.000000)
     Begin Object Class=GUIImage Name=WCFGBackground
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageStyle=ISTY_Stretched
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     Controls(0)=GUIImage'SkaarjPack.InvasionWaveConfig.WCFGBackground'

     Begin Object Class=GUIImage Name=WCFGBackground1
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageStyle=ISTY_Stretched
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     Controls(1)=GUIImage'SkaarjPack.InvasionWaveConfig.WCFGBackground1'

     Begin Object Class=GUIImage Name=WCFGBackground2
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageStyle=ISTY_Stretched
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     Controls(2)=GUIImage'SkaarjPack.InvasionWaveConfig.WCFGBackground2'

     Begin Object Class=GUILabel Name=WCFGLabel1
         Caption="Configure each wave..."
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.028385
         WinLeft=0.004883
         WinWidth=0.496094
         WinHeight=32.000000
         bBoundToParent=True
     End Object
     Controls(3)=GUILabel'SkaarjPack.InvasionWaveConfig.WCFGLabel1'

     Begin Object Class=moNumericEdit Name=WCFGWaveNo
         MinValue=1
         MaxValue=16
         ComponentJustification=TXTA_Left
         CaptionWidth=0.600000
         Caption="Wave No"
         OnCreateComponent=WCFGWaveNo.InternalOnCreateComponent
         Hint="Select which wave to adjust."
         WinTop=0.139323
         WinLeft=0.332031
         WinWidth=0.333008
         WinHeight=0.060000
         bBoundToParent=True
         bScaleToParent=True
         OnChange=InvasionWaveConfig.WaveChanged
     End Object
     Controls(4)=moNumericEdit'SkaarjPack.InvasionWaveConfig.WCFGWaveNo'

     Begin Object Class=GUIImage Name=WCFGBackground3
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageStyle=ISTY_Stretched
         WinTop=0.230468
         WinLeft=0.030273
         WinWidth=0.944336
         WinHeight=0.637695
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     Controls(5)=GUIImage'SkaarjPack.InvasionWaveConfig.WCFGBackground3'

     Begin Object Class=GUISlider Name=WCFGDifficulty
         MaxValue=3.000000
         Hint="How hard should the monsters on this wave be."
         WinTop=0.307812
         WinLeft=0.100000
         WinWidth=0.363477
         bBoundToParent=True
         bScaleToParent=True
         OnClick=WCFGDifficulty.InternalOnClick
         OnMousePressed=WCFGDifficulty.InternalOnMousePressed
         OnMouseRelease=WCFGDifficulty.InternalOnMouseRelease
         OnChange=InvasionWaveConfig.SkillChanged
         OnKeyEvent=WCFGDifficulty.InternalOnKeyEvent
         OnCapturedMouseMove=WCFGDifficulty.InternalCapturedMouseMove
     End Object
     Controls(6)=GUISlider'SkaarjPack.InvasionWaveConfig.WCFGDifficulty'

     Begin Object Class=moNumericEdit Name=WCFGDuration
         MinValue=1
         MaxValue=255
         ComponentJustification=TXTA_Left
         Caption="Duration"
         OnCreateComponent=WCFGDuration.InternalOnCreateComponent
         Hint="How long should each wave last."
         WinTop=0.288281
         WinLeft=0.563867
         WinWidth=0.363477
         WinHeight=0.069766
         bBoundToParent=True
         bScaleToParent=True
         OnChange=InvasionWaveConfig.DurationChanged
     End Object
     Controls(7)=moNumericEdit'SkaarjPack.InvasionWaveConfig.WCFGDuration'

     Begin Object Class=moCheckBox Name=WCFGCreat01
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Pupae"
         OnCreateComponent=WCFGCreat01.InternalOnCreateComponent
         Hint="The Skaarj Pupae."
         WinTop=0.408854
         WinLeft=0.100000
         WinWidth=0.300000
         WinHeight=0.040000
         Tag=1
         bBoundToParent=True
         bScaleToParent=True
         OnChange=InvasionWaveConfig.CheckChanged
     End Object
     Controls(8)=moCheckBox'SkaarjPack.InvasionWaveConfig.WCFGCreat01'

     Begin Object Class=moCheckBox Name=WCFGCreat02
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Razor Fly"
         OnCreateComponent=WCFGCreat02.InternalOnCreateComponent
         Hint="The Razor Fly."
         WinTop=0.408854
         WinLeft=0.539453
         WinWidth=0.300000
         WinHeight=0.040000
         Tag=2
         bBoundToParent=True
         bScaleToParent=True
         OnChange=InvasionWaveConfig.CheckChanged
     End Object
     Controls(9)=moCheckBox'SkaarjPack.InvasionWaveConfig.WCFGCreat02'

     Begin Object Class=moCheckBox Name=WCFGCreat03
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Manta"
         OnCreateComponent=WCFGCreat03.InternalOnCreateComponent
         Hint="The Manta."
         WinTop=0.467917
         WinLeft=0.100000
         WinWidth=0.300000
         WinHeight=0.040000
         Tag=4
         bBoundToParent=True
         bScaleToParent=True
         OnChange=InvasionWaveConfig.CheckChanged
     End Object
     Controls(10)=moCheckBox'SkaarjPack.InvasionWaveConfig.WCFGCreat03'

     Begin Object Class=moCheckBox Name=WCFGCreat04
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Krall"
         OnCreateComponent=WCFGCreat04.InternalOnCreateComponent
         Hint="The Krall."
         WinTop=0.467917
         WinLeft=0.539453
         WinWidth=0.300000
         WinHeight=0.040000
         Tag=8
         bBoundToParent=True
         bScaleToParent=True
         OnChange=InvasionWaveConfig.CheckChanged
     End Object
     Controls(11)=moCheckBox'SkaarjPack.InvasionWaveConfig.WCFGCreat04'

     Begin Object Class=moCheckBox Name=WCFGCreat05
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Elite Krall"
         OnCreateComponent=WCFGCreat05.InternalOnCreateComponent
         Hint="The Elite Krall."
         WinTop=0.526042
         WinLeft=0.100000
         WinWidth=0.300000
         WinHeight=0.040000
         Tag=16
         bBoundToParent=True
         bScaleToParent=True
         OnChange=InvasionWaveConfig.CheckChanged
     End Object
     Controls(12)=moCheckBox'SkaarjPack.InvasionWaveConfig.WCFGCreat05'

     Begin Object Class=moCheckBox Name=WCFGCreat06
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Gasbag"
         OnCreateComponent=WCFGCreat06.InternalOnCreateComponent
         Hint="The Gasbag."
         WinTop=0.526042
         WinLeft=0.539453
         WinWidth=0.300000
         WinHeight=0.040000
         Tag=32
         bBoundToParent=True
         bScaleToParent=True
         OnChange=InvasionWaveConfig.CheckChanged
     End Object
     Controls(13)=moCheckBox'SkaarjPack.InvasionWaveConfig.WCFGCreat06'

     Begin Object Class=moCheckBox Name=WCFGCreat07
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Brute"
         OnCreateComponent=WCFGCreat07.InternalOnCreateComponent
         Hint="The Brute."
         WinTop=0.582552
         WinLeft=0.100000
         WinWidth=0.300000
         WinHeight=0.040000
         Tag=64
         bBoundToParent=True
         bScaleToParent=True
         OnChange=InvasionWaveConfig.CheckChanged
     End Object
     Controls(14)=moCheckBox'SkaarjPack.InvasionWaveConfig.WCFGCreat07'

     Begin Object Class=moCheckBox Name=WCFGCreat08
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Skaarj"
         OnCreateComponent=WCFGCreat08.InternalOnCreateComponent
         Hint="The Skaarj."
         WinTop=0.582552
         WinLeft=0.539453
         WinWidth=0.300000
         WinHeight=0.040000
         Tag=128
         bBoundToParent=True
         bScaleToParent=True
         OnChange=InvasionWaveConfig.CheckChanged
     End Object
     Controls(15)=moCheckBox'SkaarjPack.InvasionWaveConfig.WCFGCreat08'

     Begin Object Class=moCheckBox Name=WCFGCreat09
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Behemoth"
         OnCreateComponent=WCFGCreat09.InternalOnCreateComponent
         Hint="The Behemoth."
         WinTop=0.639063
         WinLeft=0.100000
         WinWidth=0.300000
         WinHeight=0.040000
         Tag=256
         bBoundToParent=True
         bScaleToParent=True
         OnChange=InvasionWaveConfig.CheckChanged
     End Object
     Controls(16)=moCheckBox'SkaarjPack.InvasionWaveConfig.WCFGCreat09'

     Begin Object Class=moCheckBox Name=WCFGCreat10
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Ice Skaarj"
         OnCreateComponent=WCFGCreat10.InternalOnCreateComponent
         Hint="Ice Skaarj."
         WinTop=0.639063
         WinLeft=0.539453
         WinWidth=0.300000
         WinHeight=0.040000
         Tag=512
         bBoundToParent=True
         bScaleToParent=True
         OnChange=InvasionWaveConfig.CheckChanged
     End Object
     Controls(17)=moCheckBox'SkaarjPack.InvasionWaveConfig.WCFGCreat10'

     Begin Object Class=moCheckBox Name=WCFGCreat11
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Fire Skaarj"
         OnCreateComponent=WCFGCreat11.InternalOnCreateComponent
         Hint="The Fire Skaarj."
         WinTop=0.695573
         WinLeft=0.100000
         WinWidth=0.300000
         WinHeight=0.040000
         Tag=1024
         bBoundToParent=True
         bScaleToParent=True
         OnChange=InvasionWaveConfig.CheckChanged
     End Object
     Controls(18)=moCheckBox'SkaarjPack.InvasionWaveConfig.WCFGCreat11'

     Begin Object Class=moCheckBox Name=WCFGCreat12
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Warlord"
         OnCreateComponent=WCFGCreat12.InternalOnCreateComponent
         Hint="The Warlord."
         WinTop=0.695573
         WinLeft=0.539453
         WinWidth=0.300000
         WinHeight=0.040000
         Tag=2048
         bBoundToParent=True
         bScaleToParent=True
         OnChange=InvasionWaveConfig.CheckChanged
     End Object
     Controls(19)=moCheckBox'SkaarjPack.InvasionWaveConfig.WCFGCreat12'

     Begin Object Class=moCheckBox Name=WCFGCreat13
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Pupae"
         OnCreateComponent=WCFGCreat13.InternalOnCreateComponent
         Hint="The Skaarj Pupae."
         WinTop=0.752083
         WinLeft=0.100000
         WinWidth=0.300000
         WinHeight=0.040000
         Tag=4096
         bBoundToParent=True
         bScaleToParent=True
         OnChange=InvasionWaveConfig.CheckChanged
     End Object
     Controls(20)=moCheckBox'SkaarjPack.InvasionWaveConfig.WCFGCreat13'

     Begin Object Class=moCheckBox Name=WCFGCreat14
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Pupae"
         OnCreateComponent=WCFGCreat14.InternalOnCreateComponent
         Hint="The Skaarj Pupae."
         WinTop=0.752083
         WinLeft=0.539453
         WinWidth=0.300000
         WinHeight=0.040000
         Tag=8192
         bBoundToParent=True
         bScaleToParent=True
         OnChange=InvasionWaveConfig.CheckChanged
     End Object
     Controls(21)=moCheckBox'SkaarjPack.InvasionWaveConfig.WCFGCreat14'

     Begin Object Class=moCheckBox Name=WCFGCreat15
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Razor Fly"
         OnCreateComponent=WCFGCreat15.InternalOnCreateComponent
         Hint="The Razor Fly."
         WinTop=0.808594
         WinLeft=0.100000
         WinWidth=0.300000
         WinHeight=0.040000
         Tag=16384
         bBoundToParent=True
         bScaleToParent=True
         OnChange=InvasionWaveConfig.CheckChanged
     End Object
     Controls(22)=moCheckBox'SkaarjPack.InvasionWaveConfig.WCFGCreat15'

     Begin Object Class=moCheckBox Name=WCFGCreat16
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Razor Fly"
         OnCreateComponent=WCFGCreat16.InternalOnCreateComponent
         Hint="The Razor Fly."
         WinTop=0.808594
         WinLeft=0.539453
         WinWidth=0.300000
         WinHeight=0.040000
         Tag=32768
         bBoundToParent=True
         bScaleToParent=True
         OnChange=InvasionWaveConfig.CheckChanged
     End Object
     Controls(23)=moCheckBox'SkaarjPack.InvasionWaveConfig.WCFGCreat16'

     Begin Object Class=GUILabel Name=WCFGLabel2
         Caption="Difficulty"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.249739
         WinLeft=0.126953
         WinWidth=0.152344
         WinHeight=32.000000
         bBoundToParent=True
     End Object
     Controls(24)=GUILabel'SkaarjPack.InvasionWaveConfig.WCFGLabel2'

     Begin Object Class=GUIButton Name=WCFGClose
         Caption="Close"
         StyleName="SquareMenuButton"
         WinTop=0.876042
         WinLeft=0.805664
         WinWidth=0.152344
         WinHeight=32.000000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=InvasionWaveConfig.CloseClicked
         OnKeyEvent=WCFGClose.InternalOnKeyEvent
     End Object
     Controls(25)=GUIButton'SkaarjPack.InvasionWaveConfig.WCFGClose'

     Begin Object Class=GUIButton Name=WCFGReset
         Caption="Reset"
         StyleName="SquareMenuButton"
         WinTop=0.876042
         WinLeft=0.605664
         WinWidth=0.152344
         WinHeight=32.000000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=InvasionWaveConfig.ResetClicked
         OnKeyEvent=WCFGReset.InternalOnKeyEvent
     End Object
     Controls(26)=GUIButton'SkaarjPack.InvasionWaveConfig.WCFGReset'

     WinTop=0.200000
     WinLeft=0.250000
     WinWidth=0.500000
     WinHeight=0.650000
}
