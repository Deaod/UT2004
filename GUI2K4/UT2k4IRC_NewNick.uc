//==============================================================================
//	Created on: 07/09/2003
//	Changes nickname on IRC
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UT2K4IRC_NewNick extends UT2K4GetDataMenu;

var localized string EditCaption, EditHint;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	ed_Data.SetText("");
	ed_Data.WinWidth=0.500000;
	ed_Data.WinHeight=0.047305;
	ed_Data.WinLeft=0.250000;

	ed_Data.SetCaption(EditCaption);
	ed_Data.SetHint(EditHint);
}

function InternalOnCreateComponent( GUIComponent NewComp, GUIComponent Owner )
{
	if ( moEditBox(NewComp) != None )
	{
		moEditBox(NewComp).LabelJustification=TXTA_Right;
		moEditBox(NewComp).CaptionWidth=0.55;
		moEditBox(NewComp).ComponentWidth=-1;
	}
}

defaultproperties
{
     EditCaption="New Nickname: "
     EditHint="Enter your desired nick, then press OK to save the changes."
     OnCreateComponent=UT2k4IRC_NewNick.InternalOnCreateComponent
}
