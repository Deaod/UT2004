class Browser_MOTD extends Browser_Page;

var MasterServerClient	MSC;
var String MOTD;
var GUIScrollTextBox MOTDTextBox;
var GUIButton UpgradeButton;
var bool MustUpgrade;
var bool GotMOTD;
var GUITitleBar StatusBar;

var float ReReadyPause;

var localized string VersionString;

event Timer()
{
	StatusBar.SetCaption(ReadyString);
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	StatusBar = GUITitleBar(GUIPanel(Controls[1]).Controls[3]);
	StatusBar.SetCaption(ReadyString);

	MSC = PlayerOwner().Level.Spawn( class'MasterServerClient' );
	MSC.OnReceivedMOTDData = MyReceivedMOTDData;
	MSC.OnQueryFinished    = MyQueryFinished;

	MOTDTextBox = GUIScrollTextBox(Controls[0]);
	GUIButton(GUIPanel(Controls[1]).Controls[0]).OnClick=BackClick;
	GUIButton(GUIPanel(Controls[1]).Controls[1]).OnClick=RefreshClick;
	UpgradeButton = GUIButton(GUIPanel(Controls[1]).Controls[2]);
	UpgradeButton.OnClick=UpgradeClick;

	if( !GotMOTD )
	{
		UpgradeButton.bVisible = false;
		MustUpgrade = false;
		MSC.StartQuery(CTM_GetMOTD);

		StatusBar.SetCaption(StartQueryString);
		SetTimer(0, false); // Stop it going back to ready from a previous timer!
	}
	Controls[2].bBoundToParent=false;
	GUILabel(Controls[2]).Caption = "UT2004"@VersionString@PlayerOwner().Level.EngineVersion;
}

function MyReceivedMOTDData( MasterServerClient.EMOTDResponse Command, string Data )
{
	switch( Command )
	{
	case MR_MOTD:
		GotMOTD = true;
		MOTDTextBox.SetContent(Data, Chr(13));
		break;
	case MR_OptionalUpgrade:
		UpgradeButton.bVisible = true;
		break;
	case MR_MandatoryUpgrade:
		MustUpgrade = true;
		UpgradeButton.bVisible = true;
		break;
	case MR_NewServer:
		break;
	case MR_IniSetting:
		break;
	case MR_Command:
		break;
	}
}

function MyQueryFinished( MasterServerClient.EResponseInfo ResponseInfo, int Info )
{
	switch( ResponseInfo )
	{
	case RI_Success:
		StatusBar.SetCaption(QueryCompleteString);
		SetTimer(ReReadyPause, false);

		if( !MustUpgrade )
			Browser.MOTDVerified(true);
		break;
	case RI_AuthenticationFailed:
		StatusBar.SetCaption(AuthFailString);
		SetTimer(ReReadyPause, false);
		break;
	case RI_ConnectionFailed:
		StatusBar.SetCaption(ConnFailString);
		SetTimer(ReReadyPause, false);
		Browser.MOTDVerified(false);
		// try again
		MSC.StartQuery(CTM_GetMOTD);
		break;
	case RI_ConnectionTimeout:
		StatusBar.SetCaption(ConnTimeoutString);
		Browser.MOTDVerified(false);
		SetTimer(ReReadyPause, false);
		break;
	}
}

function OnCloseBrowser()
{
	if( MSC != None )
	{
		MSC.CancelPings();
		MSC.Destroy();
		MSC = None;
	}
}

// delegates
function bool BackClick(GUIComponent Sender)
{
	Controller.CloseMenu(true);
	return true;
}

function bool RefreshClick(GUIComponent Sender)
{
	MustUpgrade = false;
	UpgradeButton.bVisible = false;
	MSC.Stop();
	MSC.StartQuery(CTM_GetMOTD);

	StatusBar.SetCaption(StartQueryString);
	SetTimer(0, false);

	return true;
}

function bool UpgradeClick(GUIComponent Sender)
{
	MSC.LaunchAutoUpdate();
	return true;
}

defaultproperties
{
     ReReadyPause=2.000000
     VersionString="Ver."
     Begin Object Class=GUIScrollTextBox Name=MyMOTDText
         CharDelay=0.004000
         EOLDelay=0.100000
         OnCreateComponent=MyMOTDText.InternalOnCreateComponent
         WinTop=0.048000
         WinLeft=0.050000
         WinWidth=0.900000
         WinHeight=0.800000
         bNeverFocus=True
     End Object
     Controls(0)=GUIScrollTextBox'XInterface.Browser_MOTD.MyMOTDText'

     Begin Object Class=GUIPanel Name=FooterPanel
         Begin Object Class=GUIButton Name=MyBackButton
             Caption="BACK"
             StyleName="SquareMenuButton"
             WinWidth=0.200000
             WinHeight=0.500000
             OnKeyEvent=MyBackButton.InternalOnKeyEvent
         End Object
         Controls(0)=GUIButton'XInterface.Browser_MOTD.MyBackButton'

         Begin Object Class=GUIButton Name=MyRefreshButton
             Caption="REFRESH"
             StyleName="SquareMenuButton"
             WinLeft=0.200000
             WinWidth=0.200000
             WinHeight=0.500000
             OnKeyEvent=MyRefreshButton.InternalOnKeyEvent
         End Object
         Controls(1)=GUIButton'XInterface.Browser_MOTD.MyRefreshButton'

         Begin Object Class=GUIButton Name=MyUpgradeButton
             Caption="UPGRADE"
             StyleName="SquareMenuButton"
             WinLeft=0.800000
             WinWidth=0.200000
             WinHeight=0.500000
             bVisible=False
             OnKeyEvent=MyUpgradeButton.InternalOnKeyEvent
         End Object
         Controls(2)=GUIButton'XInterface.Browser_MOTD.MyUpgradeButton'

         Begin Object Class=GUITitleBar Name=MyStatus
             bUseTextHeight=False
             Justification=TXTA_Left
             StyleName="SquareBar"
             WinTop=0.500000
             WinHeight=0.500000
         End Object
         Controls(3)=GUITitleBar'XInterface.Browser_MOTD.MyStatus'

         WinTop=0.900000
         WinHeight=0.100000
     End Object
     Controls(1)=GUIPanel'XInterface.Browser_MOTD.FooterPanel'

     Begin Object Class=GUILabel Name=VersionNum
         TextAlign=TXTA_Right
         TextColor=(B=160,G=100,R=100)
         WinTop=0.002500
         WinLeft=0.495000
         WinWidth=0.500000
         WinHeight=0.040000
     End Object
     Controls(2)=GUILabel'XInterface.Browser_MOTD.VersionNum'

}
