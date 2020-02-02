class Browser_Page extends UT2K3TabPanel;

var ServerBrowser Browser;

var localized string StartQueryString;
var localized string AuthFailString;
var localized string ConnFailString;
var localized string ConnTimeoutString;
var localized string QueryCompleteString;
var localized string RefreshCompleteString;
var localized string ReadyString;
var localized string PageCaption;


function OnCloseBrowser();

defaultproperties
{
     StartQueryString="Querying Master Server"
     AuthFailString="Authentication Failed"
     ConnFailString="Connection Failed - Retrying"
     ConnTimeoutString="Connection Timed Out"
     QueryCompleteString="Query Complete!"
     RefreshCompleteString="Refresh Complete!"
     ReadyString="Ready"
     bFillHeight=True
     WinTop=0.150000
     WinHeight=0.850000
}
