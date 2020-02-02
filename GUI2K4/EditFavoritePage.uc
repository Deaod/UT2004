//==============================================================================
//	Created on: 09/16/2003
//	Edit the IP and port of an existing favorite
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class EditFavoritePage extends UT2k4Browser_OpenIP;

var automated GUILabel l_name;
var GameInfo.ServerResponseLine Server;

var localized string UnknownText;

function HandleParameters(string ServerIP, string ServerName)
{
	if (ServerIP != "")
		ed_Data.SetText(StripProtocol(ServerIP));

	if ( ServerName == "" )
		ServerName = UnknownText;

	l_Name.Caption = ServerName;
}

function ApplyURL( string URL )
{
	local string IP, port;

	if ( URL == "" )
		return;

	URL = StripProtocol(URL);
	if ( !Divide( URL, ":", IP, Port ) )
	{
		IP = URL;
		Port = "7777";
	}

	Server.IP = IP;
	Server.Port = int(Port);
	Server.QueryPort = Server.Port + 1;
	Server.ServerName = l_name.Caption;
	Controller.CloseMenu(False);
}

defaultproperties
{
     Begin Object Class=GUILabel Name=ServerName
         TextAlign=TXTA_Center
         StyleName="TextLabel"
         WinTop=0.299479
         WinLeft=0.070313
         WinWidth=0.854492
         WinHeight=0.050000
     End Object
     l_name=GUILabel'GUI2K4.EditFavoritePage.ServerName'

     UnknownText="Unknown Server"
     OKButtonHint="Close the page and save the new IP to your favorites list."
     CancelButtonHint="Close the page and discard any changes."
     EditBoxHint="Enter the URL for this favorite - separate IP and port with the   :   symbol"
     Begin Object Class=moEditBox Name=IpEntryBox
         ComponentJustification=TXTA_Left
         CaptionWidth=0.350000
         Caption="IP Address: "
         OnCreateComponent=IpEntryBox.InternalOnCreateComponent
         WinTop=0.487500
         WinLeft=0.192383
         WinWidth=0.590820
         TabOrder=0
     End Object
     ed_Data=moEditBox'GUI2K4.EditFavoritePage.IpEntryBox'

}
