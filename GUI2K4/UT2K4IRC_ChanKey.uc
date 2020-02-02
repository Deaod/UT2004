//==============================================================================
// dialog to prompt for the channel key
//
// Written by Michiel Hendriks
// (c) 2004, Epic Games, Inc. All Rights Reserved
//==============================================================================
class UT2K4IRC_ChanKey extends UT2K4GetDataMenu;

var localized string EditCaption, EditHint, msgCaption;
var string kchan;

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

/** A = the channel */
function HandleParameters( string A, string B )
{
	kchan = A;
	l_Text.Caption = repl(msgCaption, "%chan%", A);
}

function string GetDataString()
{
	return kchan@ed_Data.GetText();
}

defaultproperties
{
     EditCaption="Channel key: "
     EditHint="Enter the channel key"
     msgCaption="%chan% is protected with a key."
     OnCreateComponent=UT2K4IRC_ChanKey.InternalOnCreateComponent
}
