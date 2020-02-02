class Browser_OpenIP extends UT2K3GUIPage;

var moEditBox	MyIpAddress;
var	Browser_ServerListPageFavorites	MyFavoritesPage;

function InitComponent(GUIController pMyController, GUIComponent MyOwner)
{
	Super.InitComponent(pMyController, MyOwner);

	MyIpAddress = moEditBox(Controls[1]);
	MyIpAddress.MyEditBox.AllowedCharSet="0123456789.:";
}

function bool InternalOnClick(GUIComponent Sender)
{
	local GameInfo.ServerResponseLine S;
	local string address, ipString, portString;
	local int colonPos, portNum;

	if(Sender == Controls[4])
	{
		address = MyIpAddress.GetText();

		if(address == "")
			return true;

		// Parse text to find IP and possibly port number
		colonPos = InStr(address, ":");
		if(colonPos < 0)
		{
			// No colon
			ipString = address;
			portNum = 7777;
		}
		else
		{
			ipString = Left(address, colonPos);
			portString = Mid(address, colonPos+1);
			portNum = int(portString);
		}
		
		S.IP = ipString;
		S.Port = portNum;
		S.QueryPort = portNum+1;
		S.ServerName = "Unknown";

		MyFavoritesPage.MyAddFavorite(S);
	}

	Controller.CloseMenu(false);

	return true;
}
		

defaultproperties
{
     Begin Object Class=GUIButton Name=VidOKBackground
         StyleName="SquareBar"
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=False
         bNeverFocus=True
         OnKeyEvent=VidOKBackground.InternalOnKeyEvent
     End Object
     Controls(0)=GUIButton'XInterface.Browser_OpenIP.VidOKBackground'

     Begin Object Class=moEditBox Name=IpEntryBox
         LabelJustification=TXTA_Right
         CaptionWidth=0.550000
         Caption="IP Address: "
         LabelFont="UT2SmallFont"
         LabelColor=(B=255,G=255,R=255)
         OnCreateComponent=IpEntryBox.InternalOnCreateComponent
         WinTop=0.466667
         WinLeft=0.160000
         WinHeight=0.050000
     End Object
     Controls(1)=moEditBox'XInterface.Browser_OpenIP.IpEntryBox'

     Begin Object Class=GUIButton Name=CancelButton
         Caption="CANCEL"
         WinTop=0.750000
         WinLeft=0.650000
         WinWidth=0.200000
         bBoundToParent=True
         OnClick=Browser_OpenIP.InternalOnClick
         OnKeyEvent=CancelButton.InternalOnKeyEvent
     End Object
     Controls(2)=GUIButton'XInterface.Browser_OpenIP.CancelButton'

     Begin Object Class=GUILabel Name=OpenIPDesc
         Caption="Enter New IP Address"
         TextAlign=TXTA_Center
         TextColor=(B=0,G=200,R=230)
         TextFont="UT2HeaderFont"
         WinTop=0.400000
         WinHeight=32.000000
     End Object
     Controls(3)=GUILabel'XInterface.Browser_OpenIP.OpenIPDesc'

     Begin Object Class=GUIButton Name=OkButton
         Caption="OK"
         WinTop=0.750000
         WinLeft=0.125000
         WinWidth=0.200000
         bBoundToParent=True
         OnClick=Browser_OpenIP.InternalOnClick
         OnKeyEvent=OkButton.InternalOnKeyEvent
     End Object
     Controls(4)=GUIButton'XInterface.Browser_OpenIP.OkButton'

     WinTop=0.375000
     WinHeight=0.250000
}
