class UT2Congratulations extends UT2K3GUIPage;

function SetupPage(string PageCaption, string PageMessage, string ContinueCaption, Material CongratsPic)
{
	GUITitleBar(Controls[0]).SetCaption(PageCaption);
	GUITitleBar(Controls[2]).SetCaption(PageMessage);
	GUIButton(Controls[3]).Caption = ContinueCaption; // For localization
	GUIImage(Controls[1]).Image = CongratsPic;
}

defaultproperties
{
     Begin Object Class=GUITitleBar Name=CongratsHeader
         Caption="CONGRATULATIONS"
         StyleName="Header"
         WinTop=0.020000
     End Object
     Controls(0)=GUITitleBar'XInterface.UT2Congratulations.CongratsHeader'

     Begin Object Class=GUIImage Name=CongratsPicture
         ImageStyle=ISTY_Justified
         ImageAlign=IMGA_Center
         WinTop=0.100000
         WinLeft=0.100000
         WinWidth=0.800000
         WinHeight=0.700000
     End Object
     Controls(1)=GUIImage'XInterface.UT2Congratulations.CongratsPicture'

     Begin Object Class=GUITitleBar Name=CongratsFooter
         StyleName="Footer"
         WinTop=0.860000
     End Object
     Controls(2)=GUITitleBar'XInterface.UT2Congratulations.CongratsFooter'

     Begin Object Class=GUIButton Name=BackButton
         Caption="Continue"
         WinTop=0.940000
         WinLeft=0.790000
         WinWidth=0.300000
         OnKeyEvent=BackButton.InternalOnKeyEvent
     End Object
     Controls(3)=GUIButton'XInterface.UT2Congratulations.BackButton'

     WinTop=0.100000
     WinLeft=0.100000
     WinWidth=0.800000
     WinHeight=0.800000
}
