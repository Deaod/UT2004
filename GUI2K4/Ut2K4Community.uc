// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class Ut2K4Community extends ModsAndDemosTabs;

var automated GUIScrollTextBox 	CommunityNews;
var bool 						GotNews;
var localized string 			DefaultNews;
var MasterServerClient			MSC;

var config int	ModRevLevel;
var config int  LastModRevLevel;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	CommunityNews.SetContent(DefaultNews);
	CommunityNews.MyScrollText.bClickText=true;
	CommunityNews.MyScrollText.OnDblClick=LaunchURL;
}

function bool LaunchURL(GUIComponent Sender)
{
    local string ClickString;

    ClickString = StripColorCodes(CommunityNews.MyScrollText.ClickedString);
   	Controller.LaunchURL(ClickString);
    return true;
}

defaultproperties
{
     Begin Object Class=GUIScrollTextBox Name=lbCommunityNews
         bNoTeletype=True
         bVisibleWhenEmpty=True
         OnCreateComponent=lbCommunityNews.InternalOnCreateComponent
         WinTop=0.020000
         WinLeft=0.020000
         WinWidth=0.960000
         WinHeight=0.960000
         TabOrder=0
     End Object
     CommunityNews=GUIScrollTextBox'GUI2K4.Ut2K4Community.lbCommunityNews'

     DefaultNews="Thank you for purchasing Unreal Tournament 2004||Attempting to retrieve the latest news from the Master Server, please stand by..."
     ModRevLevel=3
     LastModRevLevel=3
     Tag=0
}
