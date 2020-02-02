// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class MyTestPanelA extends TestPanelBase;

var Automated moCheckBox CheckTest;
var Automated moEditBox EditTest;
var Automated moFloatEdit FloatTest;
var Automated moNumericEdit NumEditTest;
var Automated GUILabel lbSliderTest;
var Automated GUISlider SliderTest;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController,MyOwner);
    SliderTest.SetFriendlyLabel(lbSliderTest);
}

defaultproperties
{
     Begin Object Class=moCheckBox Name=cTwo
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="moCheckBox Test"
         OnCreateComponent=cTwo.InternalOnCreateComponent
         Hint="This is a check Box"
         WinTop=0.200000
         WinLeft=0.250000
         WinHeight=0.050000
         TabOrder=1
     End Object
     CheckTest=moCheckBox'GUI2K4.MyTestPanelA.cTwo'

     Begin Object Class=moEditBox Name=cThree
         CaptionWidth=0.400000
         Caption="moEditBox Test"
         OnCreateComponent=cThree.InternalOnCreateComponent
         Hint="This is an Edit Box"
         WinTop=0.300000
         WinLeft=0.250000
         WinHeight=0.050000
         TabOrder=2
     End Object
     EditTest=moEditBox'GUI2K4.MyTestPanelA.cThree'

     Begin Object Class=moFloatEdit Name=cFour
         MinValue=0.000000
         MaxValue=1.000000
         Step=0.050000
         ComponentJustification=TXTA_Left
         CaptionWidth=0.725000
         Caption="moFloatEdit Test"
         OnCreateComponent=cFour.InternalOnCreateComponent
         Hint="This is a FLOAT numeric Edit Box"
         WinTop=0.500000
         WinLeft=0.250000
         WinHeight=0.050000
         TabOrder=3
     End Object
     FloatTest=moFloatEdit'GUI2K4.MyTestPanelA.cFour'

     Begin Object Class=moNumericEdit Name=cFive
         MinValue=1
         MaxValue=16
         CaptionWidth=0.600000
         Caption="moNumericEdit Test"
         OnCreateComponent=cFive.InternalOnCreateComponent
         Hint="This is an INT numeric Edit box"
         WinTop=0.400000
         WinLeft=0.250000
         WinHeight=0.050000
         TabOrder=4
     End Object
     NumEditTest=moNumericEdit'GUI2K4.MyTestPanelA.cFive'

     Begin Object Class=GUILabel Name=laSix
         Caption="Slider Test"
         TextAlign=TXTA_Center
         WinTop=0.654545
         WinLeft=0.375000
         WinWidth=0.226563
         WinHeight=0.050000
     End Object
     lbSliderTest=GUILabel'GUI2K4.MyTestPanelA.laSix'

     Begin Object Class=GUISlider Name=cSix
         MaxValue=1.000000
         Hint="This is a Slider Test."
         WinTop=0.713997
         WinLeft=0.367188
         WinWidth=0.250000
         TabOrder=5
         OnClick=cSix.InternalOnClick
         OnMousePressed=cSix.InternalOnMousePressed
         OnMouseRelease=cSix.InternalOnMouseRelease
         OnKeyEvent=cSix.InternalOnKeyEvent
         OnCapturedMouseMove=cSix.InternalCapturedMouseMove
     End Object
     SliderTest=GUISlider'GUI2K4.MyTestPanelA.cSix'

     Background=Texture'InterfaceContent.Backgrounds.bg11'
     WinTop=55.980499
     WinHeight=0.807813
}
