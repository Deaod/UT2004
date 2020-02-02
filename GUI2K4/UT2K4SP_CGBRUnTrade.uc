//==============================================================================
// Single Player Challenge Bloodrite Trade page
// Message that you lost a player, no interaction, just a notice
//
// Written by Michiel Hendriks
// (c) 2003, 2004, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4SP_CGBRUnTrade extends LargeWindow;

var automated GUIScrollTextBox sbMessage;
var automated GUIButton btnOk;
var automated GUIImage imgPicture, imgPictureBg;
var automated GUILabel lblTitle;

/** class reference to the team this challenge was about */
var class<UT2K4TeamRoster> ETI;

/** The player this challenge was all about */
var string TargetPlayerName;

/** the message */
var localized string Message;

/**
	Param1 = enemy team class name
	Param2 = player name
*/
event HandleParameters(string Param1, string Param2)
{
	local xUtil.PlayerRecord PR;

	ETI = class<UT2K4TeamRoster>(DynamicLoadObject(Param1, class'Class'));
	TargetPlayerName = Param2;

	PR = class'xUtil'.static.FindPlayerRecord(Param2);
	imgPicture.Image = PR.Portrait;

	SetDescription();
}

function SetDescription()
{
	local string tmp;
	tmp = repl(Message, "%player%", TargetPlayerName);
	tmp = repl(tmp, "%enemyteam%", ETI.default.TeamName);
	sbMessage.SetContent(tmp);
}

function bool onOkClick(GUIComponent Sender)
{
	Controller.CloseMenu(false);
	return true;
}

defaultproperties
{
     Begin Object Class=GUIScrollTextBox Name=SPCsbDetails
         bNoTeletype=True
         OnCreateComponent=SPCsbDetails.InternalOnCreateComponent
         WinTop=0.166488
         WinLeft=0.316875
         WinWidth=0.377082
         WinHeight=0.318611
         RenderWeight=0.200000
         TabOrder=1
         bBoundToParent=True
     End Object
     sbMessage=GUIScrollTextBox'GUI2K4.UT2K4SP_CGBRUnTrade.SPCsbDetails'

     Begin Object Class=GUIButton Name=SPMbtnOk
         Caption="OK"
         FontScale=FNS_Small
         WinTop=0.821064
         WinLeft=0.310070
         WinWidth=0.222222
         WinHeight=0.050694
         TabOrder=1
         bBoundToParent=True
         OnClick=UT2K4SP_CGBRUnTrade.onOkClick
         OnKeyEvent=SPMbtnOk.InternalOnKeyEvent
     End Object
     btnOK=GUIButton'GUI2K4.UT2K4SP_CGBRUnTrade.SPMbtnOk'

     Begin Object Class=GUIImage Name=SPCimgPicture
         ImageStyle=ISTY_Scaled
         WinTop=0.172531
         WinLeft=0.060972
         WinWidth=0.116667
         WinHeight=0.312500
         RenderWeight=0.150000
         bBoundToParent=True
     End Object
     imgPicture=GUIImage'GUI2K4.UT2K4SP_CGBRUnTrade.SPCimgPicture'

     Begin Object Class=GUIImage Name=SPCimgPictureBg
         Image=Texture'2K4Menus.Controls.sectionback'
         ImageStyle=ISTY_Scaled
         WinTop=0.157531
         WinLeft=0.057222
         WinWidth=0.121667
         WinHeight=0.326250
         bBoundToParent=True
     End Object
     imgPictureBg=GUIImage'GUI2K4.UT2K4SP_CGBRUnTrade.SPCimgPictureBg'

     Begin Object Class=GUILabel Name=SPClblTitle
         Caption="Bloodrites"
         TextAlign=TXTA_Center
         FontScale=FNS_Large
         StyleName="TextLabel"
         WinTop=0.067846
         WinLeft=0.024063
         WinWidth=0.568750
         WinHeight=0.046250
         RenderWeight=0.200000
         bBoundToParent=True
     End Object
     lblTitle=GUILabel'GUI2K4.UT2K4SP_CGBRUnTrade.SPClblTitle'

     Message="Because you lost the challenge against %enemyteam% you have to give up your team mate %player%.|%player% now belongs to the %enemyteam%"
     DefaultTop=0.250000
     DefaultHeight=0.500000
     WinTop=0.250000
     WinHeight=0.500000
}
