// ====================================================================
// Tab for server info menu that shows server's current map rotation
//
// (C) 2003, Epic Games, Inc. All Rights Reserved.
// ====================================================================

class Tab_ServerMapList extends UT2K3TabPanel;

var bool bClean;
var GUIScrollTextBox MyScrollText;
var localized string DefaultText;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
 	Super.InitComponent(MyController, MyOwner);

    MyScrollText = GUIScrollTextBox(Controls[0]);

    WinWidth = Controller.ActivePage.WinWidth;
    WinHeight = Controller.ActivePage.WinHeight *0.7;
    WinLeft = Controller.ActivePage.WinLeft;
   	bClean = true;
   	MyScrollText.SetContent(DefaultText);

    if (XPlayer(PlayerOwner())!=None)
    {
	XPlayer(PlayerOwner()).ProcessMapName = ProcessMapName;
	XPlayer(PlayerOwner()).ServerRequestMapList();
    }
}

function ProcessMapName(string NewMap)
{
	if (NewMap=="")
	{
		bClean = true;
		MyScrollText.SetContent(DefaultText);
	}
	else
	{
		if (bClean)
			MyScrollText.SetContent(NewMap);
		else
			MyScrollText.AddText(NewMap);

		bClean = false;
	}
}

defaultproperties
{
     DefaultText="Receiving Map Rotation from Server...||This feature requires that the server be running the latest patch"
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
     Controls(0)=GUIScrollTextBox'XInterface.Tab_ServerMapList.InfoText'

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
     Controls(1)=GUIImage'XInterface.Tab_ServerMapList.ServerInfoBK1'

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
     Controls(2)=GUIImage'XInterface.Tab_ServerMapList.ServerInfoBK2'

     Begin Object Class=GUILabel Name=ServerInfoLabel
         Caption="Maps"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.027083
         WinHeight=32.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(3)=GUILabel'XInterface.Tab_ServerMapList.ServerInfoLabel'

     WinHeight=0.700000
}
