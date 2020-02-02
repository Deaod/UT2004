//==============================================================================
//	Created on: 08/13/2003
//	Eventually this panel and UT2K4Tab_IAMaplist will be combined to allow server admins to switch
//  maps using context menus during online matches
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UT2K4Tab_ServerMapList extends MidGamePanel;

var() bool bClean;
var automated GUIListBoxBase lb_Maps;
var automated GUIImage i_BG, i_BG2;
var automated GUILabel l_Title;

var() localized string DefaultText;
var() bool bReceivedMaps;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
 	Super.InitComponent(MyController, MyOwner);

   	bClean = true;
   	if ( GUIScrollTextBox(lb_Maps) != None )
	   	GUIScrollTextBox(lb_Maps).SetContent(DefaultText);
}

function ShowPanel(bool bShow)
{
	Super.ShowPanel(bShow);

	if ( bShow && !bReceivedMaps )
	{
		SetTimer(3.0,True);
		Timer();
	}
}

function Timer()
{
	if ( bReceivedMaps || xPlayer(PlayerOwner()) == None )
	{
		KillTimer();
		return;
	}

	xPlayer(PlayerOwner()).ProcessMapName = ProcessMapName;
	xPlayer(PlayerOwner()).ServerRequestMapList();
}

function ProcessMapName(string NewMap)
{
	bReceivedMaps = True;
	if (NewMap=="")
	{
		bClean = true;
		GUIScrollTextBox(lb_Maps).SetContent(DefaultText);
	}
	else
	{
		if (bClean)
			GUIScrollTextBox(lb_Maps).SetContent(NewMap);
		else
			GUIScrollTextBox(lb_Maps).AddText(NewMap);

		bClean = false;
	}
}

defaultproperties
{
     Begin Object Class=GUIScrollTextBox Name=InfoText
         bNoTeletype=True
         CharDelay=0.002500
         EOLDelay=0.000000
         TextAlign=TXTA_Center
         OnCreateComponent=InfoText.InternalOnCreateComponent
         WinTop=0.143750
         WinHeight=0.834375
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     lb_Maps=GUIScrollTextBox'GUI2K4.UT2K4Tab_ServerMapList.InfoText'

     Begin Object Class=GUIImage Name=ServerInfoBK1
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.070779
         WinLeft=0.021641
         WinWidth=0.418437
         WinHeight=0.016522
         bBoundToParent=True
         bScaleToParent=True
     End Object
     i_BG=GUIImage'GUI2K4.UT2K4Tab_ServerMapList.ServerInfoBK1'

     Begin Object Class=GUIImage Name=ServerInfoBK2
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.070779
         WinLeft=0.576329
         WinWidth=0.395000
         WinHeight=0.016522
         bBoundToParent=True
         bScaleToParent=True
     End Object
     i_BG2=GUIImage'GUI2K4.UT2K4Tab_ServerMapList.ServerInfoBK2'

     Begin Object Class=GUILabel Name=ServerInfoLabel
         Caption="Maps"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.045312
         WinHeight=32.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     l_Title=GUILabel'GUI2K4.UT2K4Tab_ServerMapList.ServerInfoLabel'

     DefaultText="Receiving Map Rotation from Server..."
}
