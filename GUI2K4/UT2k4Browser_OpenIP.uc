//==============================================================================
//	Created on: 09/16/2003
//	Handles opening an IP directly
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UT2K4Browser_OpenIP extends UT2K4GetDataMenu;

var localized string OKButtonHint;
var localized string CancelButtonHint;
var localized string EditBoxHint;

function InitComponent(GUIController pMyController, GUIComponent MyOwner)
{
	Super.InitComponent(pMyController, MyOwner);

	ed_Data.MyEditBox.OnKeyEvent = InternalOnKeyEvent;
	b_OK.SetHint(OKButtonHint);
	b_Cancel.SetHint(CancelButtonHint);
	ed_Data.SetHint(EditBoxHint);
}

function HandleParameters(string s, string s2)
{
	if (s != "")
		ed_Data.SetText( StripProtocol(s) );
}

function bool InternalOnClick(GUIComponent Sender)
{
	if ( Sender == b_OK )
		Execute();
	else Controller.CloseMenu(true);

	return true;
}

function Execute()
{
	local string URL;

	URL = ed_Data.GetText();
	if ( URL == "" )
		return;

	URL = StripProtocol(URL);
	if ( InStr( URL, ":" ) == -1 )
		URL $= ":7777";

	ApplyURL( URL );
}

function ApplyURL(string URL )
{
	if ( URL == "" || Left(URL,1) == ":" )
		return;

	PlayerOwner().ClientTravel( URL, TRAVEL_Absolute, false );
	Controller.CloseAll(false,True);
}

function bool InternalOnKeyEvent( out byte Key, out byte State, float Delta )
{
	if ( !Super.InternalOnKeyEvent(Key,State,Delta) )
		return ed_Data.MyEditBox.InternalOnKeyEvent(Key,State,Delta);
}

function string StripProtocol( string s )
{
	local string Protocol;

	Protocol = PlayerOwner().GetURLProtocol();

	ReplaceText(s, Protocol $ "://", "");
	ReplaceText(s, Protocol, "");

	return s;
}

defaultproperties
{
     OKButtonHint="Open a connection to this IP address."
     CancelButtonHint="Close this page without connecting to a server."
     EditBoxHint="Enter the address for the server you'd like to connect to - separate the IP and port with the  :  symbol"
     Begin Object Class=moEditBox Name=IpEntryBox
         LabelJustification=TXTA_Right
         CaptionWidth=0.550000
         Caption="IP Address: "
         OnCreateComponent=IpEntryBox.InternalOnCreateComponent
         WinTop=0.466667
         WinLeft=0.160000
         WinHeight=0.040000
         TabOrder=0
     End Object
     ed_Data=moEditBox'GUI2K4.UT2k4Browser_OpenIP.IpEntryBox'

     Begin Object Class=GUILabel Name=IPDesc
         Caption="Enter New IP Address"
         TextAlign=TXTA_Center
         FontScale=FNS_Large
         StyleName="TextLabel"
         WinTop=0.400000
         WinHeight=32.000000
     End Object
     l_Text=GUILabel'GUI2K4.UT2k4Browser_OpenIP.IPDesc'

}
