// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class Tab_ServerInfo extends UT2K3TabPanel;

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
	    XPlayer(PlayerOwner()).ProcessRule = ProcessRule;
        XPlayer(PlayerOwner()).ServerRequestRules();
    }
}

function ProcessRule(string NewRule)
{
	if (NewRule=="")
    {
    	bClean = true;
    	MyScrollText.SetContent(DefaultText);
    }
    else
    {
    	if (bClean)
        	MyScrollText.SetContent(NewRule);
        else
        	MyScrollText.AddText(NewRule);

        bClean = false;
    }
}

defaultproperties
{
     DefaultText="Receiving Rules from Server...||This feature requires that the server be running the latest patch"
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
     Controls(0)=GUIScrollTextBox'XInterface.Tab_ServerInfo.InfoText'

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
     Controls(1)=GUIImage'XInterface.Tab_ServerInfo.ServerInfoBK1'

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
     Controls(2)=GUIImage'XInterface.Tab_ServerInfo.ServerInfoBK2'

     Begin Object Class=GUILabel Name=ServerInfoLabel
         Caption="Rules"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.027083
         WinHeight=32.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(3)=GUILabel'XInterface.Tab_ServerInfo.ServerInfoLabel'

     WinHeight=0.700000
}
