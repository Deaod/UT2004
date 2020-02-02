//====================================================================
//  Online message of the day page.
//
//  Written by Joe Wilcox
//	Updated by Ron Prestenback
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class UT2K4Browser_MOTD extends UT2K4Browser_Page;

var automated GUIScrollTextBox		lb_MOTD;
var automated GUILabel				l_Version;
var automated GUIButton             b_QuickConnect;

var String MOTD;
var bool bUpgrade, bOptionalUpgrade;
var bool GotMOTD;

var float 	ReReadyPause;
var int		RetryCount;
var() config int RetryMax;

var localized string UpgradeCaption;
var localized string VersionString;

var config string QuickConnectMenu;
var localized string ConnectFailed;
var localized string ConnectTimeout;
var localized string MOTDHeader;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	lb_MOTD.MyScrollText.bClickText=true;
	lb_MOTD.MyScrollText.OnDblClick=LaunchURL;
}

function bool LaunchURL(GUIComponent Sender)
{
    local string ClickString;

    ClickString = StripColorCodes(lb_MOTD.MyScrollText.ClickedString);
   	Controller.LaunchURL(ClickString);
    return true;
}


event Timer()
{
	if (RetryCount++ < RetryMax)
	{
		SetFooterCaption( RetryString, True );
		Browser.Uplink().StartQuery(CTM_GetMOTD);
	}
	else
	{
		SetFooterCaption( ReadyString );
		KillTimer();
	}
}

event Opened(GUIComponent Sender)
{
	l_Version.Caption = VersionString@PlayerOwner().Level.EngineVersion;
	if ( !GotMOTD )
	{
		DisableComponent(b_QuickConnect);
		Refresh();
	}

	Super.Opened(Sender);
}

function ShowPanel( bool bShow )
{
	Super.ShowPanel(bShow);
	if ( bShow && !bInit )
		BindQueryClient(Browser.Uplink());
}

function Refresh()
{
	KillTimer();
	bUpgrade = false;

	CheckJoinButton(False);

	lb_MOTD.Stop();
	RetryCount = 0;
	ResetQueryClient( Browser.Uplink() );
	SetFooterCaption( StartQueryString );
	Browser.Uplink().StartQuery(CTM_GetMOTD);
}

// delegates
function ReceivedMOTD( MasterServerClient.EMOTDResponse Command, string Data )
{
	switch( Command )
	{
	case MR_MOTD:
		GotMOTD = true;

		if (MOTDHeader!="")
		{
			ReplaceText(MOTDHeader,"|",chr(13));
			MOTDHeader = MOTDHeader$chr(13);
		}

		EnableComponent(b_QuickConnect);
		lb_MOTD.SetContent(MOTDHeader$Data, Chr(13));
		break;

	case MR_OptionalUpgrade:
		bOptionalUpgrade = True;
		CheckJoinButton(True);
		break;

	case MR_MandatoryUpgrade:
		bUpgrade = true;
		CheckJoinButton(True);
		break;

	case MR_NewServer:
		break;
	case MR_IniSetting:
		break;
	case MR_Command:
		break;
	}
}

function OpenStatusMessage(string Code, optional string data)
{
		if (!Browser.bHideNetworkMessage)
			Controller.OpenMenu(Controller.NetworkMsgMenu,Code,Data);

		Browser.bHideNetworkMessage=true;
		SetFooterCaption(AuthFailString);
		SetTimer(ReReadyPause, false);
}


function QueryComplete( MasterServerClient.EResponseInfo ResponseInfo, int Info )
{
	switch( ResponseInfo )
	{
	case RI_Success:
		if ( Info == 1 )  // CTM_GetMOTD
		{
			if ( Browser.Uplink().ModRevLevel >0 )
			{
				class'GUI2K4.UT2K4Community'.default.ModRevLevel = Browser.Uplink().ModRevLevel;
				class'GUI2K4.UT2K4Community'.static.staticsaveconfig();
			}

			SetFooterCaption(QueryCompleteString);

			// Allow a few seconds to display the "Query Complete" message, then set the caption to "Ready"
			RetryCount = RetryMax;
			SetTimer(ReReadyPause, false);

			if( !bUpgrade && !Browser.Verified)
				Browser.MOTDVerified(true);
		}
		break;

	case RI_AuthenticationFailed:
		OpenStatusMessage("RI_AuthenticationFailed");break;
	case RI_DevClient:
		OpenStatusMessage("RI_DevClient");break;
    case RI_BadClient:
         OpenStatusMessage("RI_BadClient");break;
    case RI_UTANBan:
    	 OpenStatusMessage("RI_UTANBAN");break;
    case RI_BannedClient:
         OpenStatusMessage("RI_BannedClient",ResponseInfo$Browser.Uplink().OptionalResult);break;
	case RI_ConnectionFailed:
		lb_MOTD.SetContent(ConnectFailed);
		Browser.MOTDVerified(false);
		break;
	case RI_ConnectionTimeout:
		lb_MOTD.SetContent(ConnectTimeout);
		Browser.MOTDVerified(false);
		break;
	}
}

function JoinClicked()
{
	Browser.Uplink().LaunchAutoUpdate();
}

function bool IsSpectateAvailable( out string ButtonCaption )
{
	ButtonCaption = SpectateCaption;
	return false;
}

function bool IsJoinAvailable( out string ButtonCaption )
{
	ButtonCaption = UpgradeCaption;
	return bUpgrade || bOptionalUpgrade;
}

function bool IsRefreshAvailable( out string ButtonCaption )
{
	ButtonCaption = RefreshCaption;
	return true;
}

function bool InternalOnClick(GUIComponent Sender)
{
	if ( Sender == b_QuickConnect )
	{
		if ( Controller.OpenMenu(QuickConnectMenu) )
			Controller.ActivePage.HandleObject( Browser.Uplink() );


		return true;
	}

	return false;
}

function ResetQueryClient( ServerQueryClient Client )
{
	Super.ResetQueryClient(Client);

	if ( MasterServerClient(Client) != None )
		MasterServerClient(Client).Query.Length = 0;
}

function BindQueryClient( ServerQueryClient Client )
{
	Super.BindQueryClient(Client);
	if ( MasterServerClient(Client) != None )
	{
		MasterServerClient(Client).OnReceivedMOTDData = ReceivedMOTD;
		MasterServerClient(Client).OnQueryFinished    = QueryComplete;
	}
}

defaultproperties
{
     Begin Object Class=GUIScrollTextBox Name=MyMOTDText
         bNoTeletype=True
         CharDelay=0.050000
         EOLDelay=0.100000
         bVisibleWhenEmpty=True
         OnCreateComponent=MyMOTDText.InternalOnCreateComponent
         StyleName="ListBox"
         WinTop=0.002679
         WinHeight=0.833203
         RenderWeight=0.600000
         TabOrder=1
         bNeverFocus=True
     End Object
     lb_MOTD=GUIScrollTextBox'GUI2K4.UT2k4Browser_MOTD.MyMOTDText'

     Begin Object Class=GUILabel Name=VersionNum
         TextAlign=TXTA_Right
         StyleName="TextLabel"
         WinTop=-0.043415
         WinLeft=0.793500
         WinWidth=0.202128
         WinHeight=0.040000
         RenderWeight=20.700001
     End Object
     l_Version=GUILabel'GUI2K4.UT2k4Browser_MOTD.VersionNum'

     Begin Object Class=GUIButton Name=QuickPlay
         Caption="QUICK PLAY"
         bAutoSize=True
         Hint="Open a dialog that can help you easily find the best online server based on your criteria"
         WinTop=0.866146
         WinLeft=0.425180
         WinWidth=0.161994
         WinHeight=0.079063
         TabOrder=2
         OnClick=UT2k4Browser_MOTD.InternalOnClick
         OnKeyEvent=QuickPlay.InternalOnKeyEvent
     End Object
     b_QuickConnect=GUIButton'GUI2K4.UT2k4Browser_MOTD.QuickPlay'

     ReReadyPause=3.000000
     RetryMax=10
     UpgradeCaption="UPGRADE"
     VersionString="Version"
     QuickConnectMenu="GUI2K4.UT2K4QuickPlay"
     ConnectFailed="The UT2004 master server could not be reached.  Please try again later."
     ConnectTimeout="Your connection to the UT2004 master server has timed out"
     PanelCaption="News from Epic"
}
