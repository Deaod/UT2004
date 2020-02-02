// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class UT2K4ModsAndDemos extends Ut2K4MainPage;

#exec OBJ LOAD FILE=InterfaceContent.utx

var Ut2K4Community				tp_Community;
var UT2K4UserMods				tp_UserMods;
var UT2K4Ownage					tp_Ownage;
var UT2K4Demos					tp_Demos;
var UT2K4Movies					tp_Movies;

var MasterServerClient			MSC;

var UT2K4ModFooter				MyFooter;

var localized string ConnectFailed;
var localized string ConnectTimeout;
var localized string CommunityMessageHeader;

var bool bAlreadyNotified;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;

	MyFooter = UT2K4ModFooter(t_Footer);

    Super.InitComponent(MyController, MyOwner);

    tp_Community = Ut2K4Community(	c_Tabs.AddTab(PanelCaption[i],"GUI2K4.Ut2K4Community",,	PanelHint[i++]));
    tp_UserMods  = UT2K4UserMods(	c_Tabs.AddTab(PanelCaption[i],"GUI2K4.UT2K4UserMods",,	PanelHint[i++]));
    tp_Ownage    = UT2K4Ownage(		c_Tabs.AddTab(PanelCaption[i],"GUI2K4.UT2K4Ownage",,	PanelHint[i++]));
    tp_Demos     = UT2K4Demos(   	c_Tabs.AddTab(PanelCaption[i],"GUI2K4.UT2K4Demos",,   	PanelHint[i++]));
    tp_Movies	 = UT2K4Movies( 	c_Tabs.AddTab(PanelCaption[i],"GUI2K4.UT2K4Movies",,	PanelHint[i++]));

	if ( tp_Demos.lb_DemoList.List.ItemCount<=0 )
		tp_Demos.MyButton.DisableMe();

	MSC = PlayerOwner().Level.Spawn( class'MasterServerClient' );

    MSC.OwnageLevel  = tp_Ownage.OwnageLevel;
	MSC.OnReceivedModMOTDData 	= MyReceivedModMOTDData;
    MSC.OnReceivedOwnageItem	= MyReceivedOwnageItem;
    MSC.OnQueryFinished			= MyOnQueryFinished;

	MSC.StartQuery(CTM_GetModMOTD);
}

function MyOnQueryFinished( MasterServerClient.EResponseInfo ResponseInfo, int Info )
{
	if (ResponseInfo==RI_Success)
	{
		tp_Community.ModRevLevel     = MSC.ModRevLevel;
		tp_Community.LastModRevLevel = tp_Community.ModRevLevel;
		tp_Community.saveconfig();
    	return;
    }

    switch (ResponseInfo)
    {
   	case RI_AuthenticationFailed: 	Controller.OpenMenu(Controller.NetworkMsgMenu,"RI_AuthenticationFailed","");break;
   	case RI_ConnectionFailed:
		tp_Community.CommunityNews.SetContent(ConnectFailed);
		break;

   	case RI_ConnectionTimeout: 		Controller.OpenMenu(Controller.NetworkMsgMenu,"RI_ConnectionTimeout","");break;
		tp_Community.CommunityNews.SetContent(ConnectTimeout);
		break;

   	case RI_MustUpgrade:			Controller.OpenMenu(Controller.NetworkMsgMenu,"RI_MustUpgrade","");break;
   	case RI_DevClient:				Controller.OpenMenu(Controller.NetworkMsgMenu,"RI_DevClient","");break;
   	case RI_BadClient:				Controller.OpenMenu(Controller.NetworkMsgMenu,"RI_BadClient","");break;
   	case RI_BannedClient:			Controller.OpenMenu(Controller.NetworkMsgMenu,"RI_BannedClient",MSC.OptionalResult);break;
    case RI_UTANBan:				Controller.OpenMenu(Controller.NetworkMsgMenu,"RI_UTANBan","");break;

	}


}

function MyReceivedModMOTDData(string data )
{
	if (Data!="" && tp_Community!=None)
	{
		if (CommunityMessageHeader!="")
		{
			ReplaceText(CommunityMessageHeader,"|",chr(13));
			CommunityMessageHeader = CommunityMessageHeader$chr(13);
		}

		tp_Community.CommunityNews.SetContent(CommunityMessageHeader$Data, Chr(13));
	}
}

function MyReceivedOwnageItem(int Level, string ItemName, string ItemDesc, string ItemURL)
{
	tp_Ownage.AddMap(Level,ItemName,ItemDesc,ItemURL);
}

event Closed(GUIComponent Sender, bool bCancelled)
{
	if (MSC!=None)
		MSC.Destroy();
}

function HandleClick(int Button)
{
}

defaultproperties
{
     ConnectFailed="The UT2004 master server could not be reached.  Please try again later."
     ConnectTimeout="Your connection to the UT2004 master server has timed out"
     Begin Object Class=GUIHeader Name=ModHeader
         Caption="The UT2004 Community"
         RenderWeight=0.300000
     End Object
     t_Header=GUIHeader'GUI2K4.UT2K4ModsAndDemos.ModHeader'

     Begin Object Class=UT2K4ModFooter Name=ModFooter
         WinTop=0.957943
         RenderWeight=0.300000
         OnPreDraw=ModFooter.InternalOnPreDraw
     End Object
     t_Footer=UT2K4ModFooter'GUI2K4.UT2K4ModsAndDemos.ModFooter'

     PanelCaption(0)="News"
     PanelCaption(1)="User Mods"
     PanelCaption(2)="Ownage Maps"
     PanelCaption(3)="Demos"
     PanelCaption(4)="Movies"
     PanelHint(0)="Get the latest news from the UT2004 community..."
     PanelHint(1)="Activate a user mod that is already installed..."
     PanelHint(2)="Epic recommends..."
     PanelHint(3)="Replay a pre-recorded demo file..."
     PanelHint(4)="View fan movies created with UnrealEd and Matinee"
     bPersistent=False
}
