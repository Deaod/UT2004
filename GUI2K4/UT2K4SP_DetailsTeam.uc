//==============================================================================
// Used on the details page to display addition team deletails
// HandleParams request the teams name as 1st param
//
// Written by Michiel Hendriks
// (c) 2003, 2004, Epic Games, Inc.  All Rights Reserved
//==============================================================================

class UT2K4SP_DetailsTeam extends LargeWindow;

var automated GUIImage imgPicture;
var automated GUIButton btnOk;
var automated GUILabel lblTitle;
var automated GUIScrollTextBox cbDescription;

/** Param1 is the fully qualified name for the team */
event HandleParameters(string Param1, string Param2)
{
	local class<UT2K4TeamRoster> ETI;

	Super.HandleParameters(Param1, Param2);
	ETI = class<UT2K4TeamRoster>(DynamicLoadObject(Param1, class'Class'));
	if (ETI == none)
	{
		Warn(Param1@"is not a valid subclass of UT2K4TeamRoster");
		return;
	}
	lblTitle.Caption = ETI.default.TeamName;
	if (ETI.default.TeamSymbolName != "") imgPicture.Image = Material(DynamicLoadObject(ETI.default.TeamSymbolName, class'Material', true));
	cbDescription.SetContent(ETI.default.TeamDescription);
	if (ETI.default.VoiceOver != none) PlayerOwner().PlayOwnedSound(ETI.default.VoiceOver, SLOT_Interface, 1.0);
	else if (ETI.default.TeamNameSound != none) PlayerOwner().PlayOwnedSound(ETI.default.TeamNameSound, SLOT_Interface, 1.0);
}

function bool btnOkOnClick(GUIComponent Sender)
{
	Controller.CloseMenu(false);
	return true;
}

defaultproperties
{
     Begin Object Class=GUIImage Name=SPDTimgPicture
         ImageStyle=ISTY_Justified
         ImageAlign=IMGA_Center
         WinTop=0.162500
         WinLeft=0.031250
         WinWidth=0.225000
         WinHeight=0.412500
         RenderWeight=0.300000
         bBoundToParent=True
     End Object
     imgPicture=GUIImage'GUI2K4.UT2K4SP_DetailsTeam.SPDTimgPicture'

     Begin Object Class=GUIButton Name=SPDTbtnOk
         Caption="CLOSE"
         FontScale=FNS_Small
         WinTop=0.865625
         WinLeft=0.337813
         WinWidth=0.200000
         bBoundToParent=True
         OnClick=UT2K4SP_DetailsTeam.btnOkOnClick
         OnKeyEvent=SPDTbtnOk.InternalOnKeyEvent
     End Object
     btnOK=GUIButton'GUI2K4.UT2K4SP_DetailsTeam.SPDTbtnOk'

     Begin Object Class=GUILabel Name=SPDTlblTitle
         TextAlign=TXTA_Center
         FontScale=FNS_Large
         StyleName="TextLabel"
         WinTop=0.068333
         WinLeft=0.027500
         WinWidth=0.567500
         WinHeight=0.053750
         bBoundToParent=True
     End Object
     lblTitle=GUILabel'GUI2K4.UT2K4SP_DetailsTeam.SPDTlblTitle'

     Begin Object Class=GUIScrollTextBox Name=SPDTcbDescription
         bNoTeletype=True
         OnCreateComponent=SPDTcbDescription.InternalOnCreateComponent
         WinTop=0.166667
         WinLeft=0.425000
         WinWidth=0.324999
         WinHeight=0.412500
         bBoundToParent=True
     End Object
     cbDescription=GUIScrollTextBox'GUI2K4.UT2K4SP_DetailsTeam.SPDTcbDescription'

     DefaultLeft=0.080000
     DefaultTop=0.193333
     DefaultWidth=0.827500
     DefaultHeight=0.598749
     WinTop=0.193333
     WinLeft=0.080000
     WinWidth=0.827500
     WinHeight=0.598749
}
