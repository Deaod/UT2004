//==============================================================================
//  Created on: 02/06/2004
//  Allows player to quickly change playername & netspeed from internet page
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4InternetSettingsPage extends MessageWindow;

var automated GUIButton b_OK, b_Cancel;
var automated moEditbox ed_PlayerName;
var automated moComboBox co_Netspeed;

function InitComponent(GUIController InController, GUIComponent InOwner)
{
	Super.InitComponent(InController, InOwner);

	SetupPlayerName();
	SetupNetspeedCombo();
}

function SetupPlayerName()
{
	local PlayerController PC;

	ed_PlayerName.MyEditBox.bConvertSpaces = True;

	PC = PlayerOwner();
	if ( PC.PlayerReplicationInfo != None )
		ed_PlayerName.SetText(PC.PlayerReplicationInfo.PlayerName);
	else ed_PlayerName.SetText( PC.GetURLOption("Name") );
}

function SetupNetspeedCombo()
{
	local int i;

	for ( i = 0; i < ArrayCount(class'UT2K4Tab_GameSettings'.default.NetspeedText); i++ )
		co_Netspeed.AddItem( class'UT2K4Tab_GameSettings'.default.NetspeedText[i], , GetNetspeedValue(i) );

	co_Netspeed.SetIndex( GetNetspeedIndex(class'Player'.default.ConfiguredInternetSpeed) );
}

function bool InternalOnClick( GUIComponent Sender )
{
	Controller.CloseMenu( Sender == b_Cancel );
	return True;
}

event Closed( GUIComponent Sender, bool bCancelled )
{
	local string NewName;

	if ( !bCancelled )
	{
		NewName = Repl(ed_PlayerName.GetText(), "\"", "");
		NewName = Repl(NewName, " ", "_");

		if ( NewName == "" )
			NewName = "Player";

		PlayerOwner().ConsoleCommand("SetName"@NewName);
		PlayerOwner().ConsoleCommand("NetSpeed"@co_Netspeed.GetExtra());
	}

	Super.Closed(Sender,bCancelled);
}

function string GetNetspeedValue( int i )
{
	switch ( i )
	{
	case 0: return "2600";
	case 1: return "5000";
	case 2: return "10000";
	case 3: return "15000";
	}

	return "10000";
}

function int GetNetspeedIndex( int Netspeed )
{
	if ( NetSpeed < 3500 )
		return 0;
	if ( NetSpeed < 7500 )
		return 1;
	if ( Netspeed < 12500 )
		return 2;

	return 3;
}

defaultproperties
{
     Begin Object Class=GUIButton Name=InternetSettingsOKButton
         Caption="OK"
         WinTop=0.556666
         WinLeft=0.741251
         WinWidth=0.136250
         WinHeight=0.045000
         OnClick=UT2K4InternetSettingsPage.InternalOnClick
         OnKeyEvent=InternetSettingsOKButton.InternalOnKeyEvent
     End Object
     b_OK=GUIButton'GUI2K4.UT2K4InternetSettingsPage.InternetSettingsOKButton'

     Begin Object Class=GUIButton Name=InternetSettingsCancelButton
         Caption="CANCEL"
         WinTop=0.556666
         WinLeft=0.595000
         WinWidth=0.130000
         WinHeight=0.045000
         OnClick=UT2K4InternetSettingsPage.InternalOnClick
         OnKeyEvent=InternetSettingsCancelButton.InternalOnKeyEvent
     End Object
     b_Cancel=GUIButton'GUI2K4.UT2K4InternetSettingsPage.InternetSettingsCancelButton'

     Begin Object Class=moEditBox Name=PlayerNameEditbox
         bVerticalLayout=True
         LabelJustification=TXTA_Center
         ComponentJustification=TXTA_Center
         Caption="Player Name: "
         OnCreateComponent=PlayerNameEditbox.InternalOnCreateComponent
         WinTop=0.401666
         WinLeft=0.085000
         WinWidth=0.381250
         WinHeight=0.090000
         bStandardized=False
     End Object
     ed_PlayerName=moEditBox'GUI2K4.UT2K4InternetSettingsPage.PlayerNameEditbox'

     Begin Object Class=moComboBox Name=NetspeedComboBox
         bReadOnly=True
         bVerticalLayout=True
         LabelJustification=TXTA_Center
         ComponentJustification=TXTA_Center
         Caption="Netspeed: "
         OnCreateComponent=NetspeedComboBox.InternalOnCreateComponent
         WinTop=0.401666
         WinLeft=0.537500
         WinWidth=0.341250
         WinHeight=0.090000
         bStandardized=False
     End Object
     co_Netspeed=moComboBox'GUI2K4.UT2K4InternetSettingsPage.NetspeedComboBox'

}
