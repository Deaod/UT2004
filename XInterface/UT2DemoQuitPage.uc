// ====================================================================
//  Class:  XInterface.UT2DemoQuitPage
//  Parent: XInterface.GUIPage
//
//  <Enter a description here>
// ====================================================================

class UT2DemoQuitPage extends UT2K3GUIPage;

#exec OBJ LOAD FILE=ExitScreen.utx

var int	TimeLeft;
var bool bClickedBuy;  // need a tick or two for the start to take place

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
	GUIButton(Controls[17]).Caption = GUIButton(default.Controls[17]).Caption$"("$TimeLeft$")";
	SetTimer(1,true);
}

event Timer()
{

	if ( bClickedBuy )
	{
		PlayerOwner().ConsoleCommand("exit");
	}
	else
	{
		TimeLeft--;
		GUIButton(Controls[17]).Caption = GUIButton(default.Controls[17]).Caption$"("$TimeLeft$")";
		if(TimeLeft <= 0)
			OnQuitClicked(Controls[17]);
	}
}

function bool OnBuyClicked(GUIComponent Sender)
{
	PlayerOwner().ConsoleCommand("start http://www.unrealtournament.com/");
	bClickedBuy = true;
	SetTimer(0.5,true);
	return true;
}

function bool OnQuitClicked(GUIComponent Sender)
{
	PlayerOwner().ConsoleCommand("exit");
	return true;
}

defaultproperties
{
     TimeLeft=20
     Background=Texture'InterfaceContent.Backgrounds.bg09'
     Begin Object Class=GUIImage Name=QuitImageA1
         Image=Texture'ExitScreen.splash.QuitA1'
         ImageStyle=ISTY_Scaled
         WinWidth=0.250000
         WinHeight=0.250000
     End Object
     Controls(0)=GUIImage'XInterface.UT2DemoQuitPage.QuitImageA1'

     Begin Object Class=GUIImage Name=QuitImageA2
         Image=Texture'ExitScreen.splash.QuitA2'
         ImageStyle=ISTY_Scaled
         WinLeft=0.250000
         WinWidth=0.250000
         WinHeight=0.250000
     End Object
     Controls(1)=GUIImage'XInterface.UT2DemoQuitPage.QuitImageA2'

     Begin Object Class=GUIImage Name=QuitImageA3
         Image=Texture'ExitScreen.splash.QuitA3'
         ImageStyle=ISTY_Scaled
         WinLeft=0.500000
         WinWidth=0.250000
         WinHeight=0.250000
     End Object
     Controls(2)=GUIImage'XInterface.UT2DemoQuitPage.QuitImageA3'

     Begin Object Class=GUIImage Name=QuitImageA4
         Image=Texture'ExitScreen.splash.QuitA4'
         ImageStyle=ISTY_Scaled
         WinLeft=0.750000
         WinWidth=0.250000
         WinHeight=0.250000
     End Object
     Controls(3)=GUIImage'XInterface.UT2DemoQuitPage.QuitImageA4'

     Begin Object Class=GUIImage Name=QuitImageB1
         Image=Texture'ExitScreen.splash.QuitB1'
         ImageStyle=ISTY_Scaled
         WinTop=0.250000
         WinWidth=0.250000
         WinHeight=0.250000
     End Object
     Controls(4)=GUIImage'XInterface.UT2DemoQuitPage.QuitImageB1'

     Begin Object Class=GUIImage Name=QuitImageB2
         Image=Texture'ExitScreen.splash.QuitB2'
         ImageStyle=ISTY_Scaled
         WinTop=0.250000
         WinLeft=0.250000
         WinWidth=0.250000
         WinHeight=0.250000
     End Object
     Controls(5)=GUIImage'XInterface.UT2DemoQuitPage.QuitImageB2'

     Begin Object Class=GUIImage Name=QuitImageB3
         Image=Texture'ExitScreen.splash.QuitB3'
         ImageStyle=ISTY_Scaled
         WinTop=0.250000
         WinLeft=0.500000
         WinWidth=0.250000
         WinHeight=0.250000
     End Object
     Controls(6)=GUIImage'XInterface.UT2DemoQuitPage.QuitImageB3'

     Begin Object Class=GUIImage Name=QuitImageB4
         Image=Texture'ExitScreen.splash.QuitB4'
         ImageStyle=ISTY_Scaled
         WinTop=0.250000
         WinLeft=0.750000
         WinWidth=0.250000
         WinHeight=0.250000
     End Object
     Controls(7)=GUIImage'XInterface.UT2DemoQuitPage.QuitImageB4'

     Begin Object Class=GUIImage Name=QuitImageC1
         Image=Texture'ExitScreen.splash.QuitC1'
         ImageStyle=ISTY_Scaled
         WinTop=0.500000
         WinWidth=0.250000
         WinHeight=0.250000
     End Object
     Controls(8)=GUIImage'XInterface.UT2DemoQuitPage.QuitImageC1'

     Begin Object Class=GUIImage Name=QuitImageC2
         Image=Texture'ExitScreen.splash.QuitC2'
         ImageStyle=ISTY_Scaled
         WinTop=0.500000
         WinLeft=0.250000
         WinWidth=0.250000
         WinHeight=0.250000
     End Object
     Controls(9)=GUIImage'XInterface.UT2DemoQuitPage.QuitImageC2'

     Begin Object Class=GUIImage Name=QuitImageC3
         Image=Texture'ExitScreen.splash.QuitC3'
         ImageStyle=ISTY_Scaled
         WinTop=0.500000
         WinLeft=0.500000
         WinWidth=0.250000
         WinHeight=0.250000
     End Object
     Controls(10)=GUIImage'XInterface.UT2DemoQuitPage.QuitImageC3'

     Begin Object Class=GUIImage Name=QuitImageC4
         Image=Texture'ExitScreen.splash.QuitC4'
         ImageStyle=ISTY_Scaled
         WinTop=0.500000
         WinLeft=0.750000
         WinWidth=0.250000
         WinHeight=0.250000
     End Object
     Controls(11)=GUIImage'XInterface.UT2DemoQuitPage.QuitImageC4'

     Begin Object Class=GUIImage Name=QuitImageD1
         Image=Texture'ExitScreen.splash.QuitD1'
         ImageStyle=ISTY_Scaled
         WinTop=0.750000
         WinWidth=0.250000
         WinHeight=0.250000
     End Object
     Controls(12)=GUIImage'XInterface.UT2DemoQuitPage.QuitImageD1'

     Begin Object Class=GUIImage Name=QuitImageD2
         Image=Texture'ExitScreen.splash.QuitD2'
         ImageStyle=ISTY_Scaled
         WinTop=0.750000
         WinLeft=0.250000
         WinWidth=0.250000
         WinHeight=0.250000
     End Object
     Controls(13)=GUIImage'XInterface.UT2DemoQuitPage.QuitImageD2'

     Begin Object Class=GUIImage Name=QuitImageD3
         Image=Texture'ExitScreen.splash.QuitD3'
         ImageStyle=ISTY_Scaled
         WinTop=0.750000
         WinLeft=0.500000
         WinWidth=0.250000
         WinHeight=0.250000
     End Object
     Controls(14)=GUIImage'XInterface.UT2DemoQuitPage.QuitImageD3'

     Begin Object Class=GUIImage Name=QuitImageD4
         Image=Texture'ExitScreen.splash.QuitD4'
         ImageStyle=ISTY_Scaled
         WinTop=0.750000
         WinLeft=0.750000
         WinWidth=0.250000
         WinHeight=0.250000
     End Object
     Controls(15)=GUIImage'XInterface.UT2DemoQuitPage.QuitImageD4'

     Begin Object Class=GUIButton Name=BuyButton
         Caption="Buy"
         WinTop=0.850000
         WinLeft=0.800000
         WinWidth=0.150000
         OnClick=UT2DemoQuitPage.OnBuyClicked
         OnKeyEvent=BuyButton.InternalOnKeyEvent
     End Object
     Controls(16)=GUIButton'XInterface.UT2DemoQuitPage.BuyButton'

     Begin Object Class=GUIButton Name=QuitButton
         Caption="Quit"
         WinTop=0.910000
         WinLeft=0.800000
         WinWidth=0.150000
         OnClick=UT2DemoQuitPage.OnQuitClicked
         OnKeyEvent=QuitButton.InternalOnKeyEvent
     End Object
     Controls(17)=GUIButton'XInterface.UT2DemoQuitPage.QuitButton'

     WinHeight=1.000000
}
