// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class UT2K4Tab_ServerInfo extends MidGamePanel;

var bool bClean;
var automated GUIScrollTextBox lb_Text;
var automated GUIImage i_BG, i_BG2;
var automated GUILabel l_Title;

var localized string DefaultText;

var bool bReceivedRules;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
 	Super.InitComponent(MyController, MyOwner);

   	bClean = true;
   	lb_Text.SetContent(DefaultText);
}

function ShowPanel(bool bShow)
{
	Super.ShowPanel(bShow);
	if ( bShow && !bReceivedRules )
	{
		SetTimer(3.0, True);
		Timer();
    }
}

function Timer()
{
	if ( bReceivedRules || xPlayer(PlayerOwner()) == None )
	{
		KillTimer();
		return;
	}

    XPlayer(PlayerOwner()).ProcessRule = ProcessRule;
    XPlayer(PlayerOwner()).ServerRequestRules();
}

function ProcessRule(string NewRule)
{
	bReceivedRules = True;
	if (NewRule=="")
    {
    	bClean = true;
    	lb_Text.SetContent(DefaultText);
    }
    else
    {
    	if (bClean)
        	lb_Text.SetContent(NewRule);
        else
        	lb_Text.AddText(NewRule);

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
         WinHeight=0.866016
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     lb_Text=GUIScrollTextBox'GUI2K4.UT2K4Tab_ServerInfo.InfoText'

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
     i_BG=GUIImage'GUI2K4.UT2K4Tab_ServerInfo.ServerInfoBK1'

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
     i_BG2=GUIImage'GUI2K4.UT2K4Tab_ServerInfo.ServerInfoBK2'

     Begin Object Class=GUILabel Name=ServerInfoLabel
         Caption="Rules"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.042708
         WinHeight=32.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     l_Title=GUILabel'GUI2K4.UT2K4Tab_ServerInfo.ServerInfoLabel'

     DefaultText="Receiving Rules from Server...||This feature requires that the server be running the latest patch"
}
