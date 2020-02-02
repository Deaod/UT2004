//-----------------------------------------------------------
//
//-----------------------------------------------------------
class UT2K4Demo2AVI extends LockedFloatingWindow;

var automated GUILabel lb_SavePos;
var automated moEditBox  eb_Filename;
var automated moComboBox co_Resolution;
var automated moSlider   so_Quality;

var string demoname;

function InitComponent(GUIController Controller, GUIComponent Owner)
{
	super.InitComponent(Controller, Owner);
	sb_Main.bFillClient=true;
	sb_Main.TopPadding=0.05;
	sb_Main.SetPosition(0.033750,0.100000,0.650859,0.344726);
	sb_Main.ManageComponent(eb_Filename);
	sb_Main.Managecomponent(co_Resolution);
	sb_Main.ManageComponent(so_Quality);

	co_Resolution.AddItem("160x120");
	co_Resolution.AddItem("320x240");
	co_Resolution.AddItem("640x480");
	co_Resolution.AddItem("800x600");
	co_Resolution.AddItem("1280x720");
	co_Resolution.SetIndex(1);
	so_Quality.SetValue(1);

	b_Ok.OnCLick=okClick;

}

event HandleParameters(string Param1, string Param2)
{
	local string s;
	local int p;

	DemoName=Param1;

	p = instr(Caps(Param1),".DEMO4");
	if (p>=0)
		s = left(Param1,p);
	else
		s = Param1;

	s = s$".AVI";
	eb_Filename.SetText(s);
}

function bool OkClick(GUIComponent Sender)
{
	local string s;
 	local int p;
 	local int x,y;

 	s = Caps(co_Resolution.GetText());
 	p = instr(s,"X");
 	x=320;
 	y=240;
 	if (p>=0)
 	{
	 	x = int(Left(s,p));
	 	y = int(right(s,len(s)-p-1));
	}

	PlayerOwner().ConsoleCommand("demodump DEMO="$DemoName@"FILENAME="$eb_Filename.GetText()@"QUALITY="$so_Quality.GetValue()@"FPS=30 Width="$X@"Height="$Y);
	return true;
}

defaultproperties
{
     Begin Object Class=GUILabel Name=lbSavePos
         Caption="AVI's saved to ..\UserMovies"
         TextAlign=TXTA_Center
         StyleName="ServerBrowserGrid"
         WinTop=0.715625
         WinLeft=0.117857
         WinWidth=0.764286
         WinHeight=0.061864
         bBoundToParent=True
         bScaleToParent=True
     End Object
     lb_SavePos=GUILabel'GUI2K4.UT2K4Demo2AVI.lbSavePos'

     Begin Object Class=moEditBox Name=ebFilename
         Caption="Filename: "
         OnCreateComponent=ebFilename.InternalOnCreateComponent
         Hint="The name of the AVI file to create"
         WinTop=0.091667
         WinLeft=0.089063
         WinWidth=0.895312
         WinHeight=0.098438
         bBoundToParent=True
         bScaleToParent=True
     End Object
     eb_Filename=moEditBox'GUI2K4.UT2K4Demo2AVI.ebFilename'

     Begin Object Class=moComboBox Name=coResolution
         ComponentJustification=TXTA_Left
         Caption="Resolution"
         OnCreateComponent=coResolution.InternalOnCreateComponent
         Hint="The resolution of the final movie."
         WinTop=0.079339
         WinLeft=0.031250
         WinHeight=0.060000
         TabOrder=0
     End Object
     co_Resolution=moComboBox'GUI2K4.UT2K4Demo2AVI.coResolution'

     Begin Object Class=moSlider Name=soQuality
         MaxValue=1.000000
         SliderCaptionStyleName="TextLabel"
         Caption="Quality"
         OnCreateComponent=soQuality.InternalOnCreateComponent
         Hint="The quality level of the compression used"
         WinTop=0.107618
         WinLeft=0.345313
         WinWidth=0.598438
         WinHeight=0.037500
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
     End Object
     so_Quality=moSlider'GUI2K4.UT2K4Demo2AVI.soQuality'

     WindowName="Output to AVI..."
     DefaultLeft=0.150000
     DefaultTop=0.250000
     DefaultWidth=0.700000
     DefaultHeight=0.500000
     WinTop=0.250000
     WinLeft=0.150000
     WinWidth=0.700000
     WinHeight=0.500000
}
