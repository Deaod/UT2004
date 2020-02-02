//==============================================================================
// Notification of a team mate injury
//
// Written by Michiel Hendriks
// (c) 2003, 2004, Epic Games, Inc.  All Rights Reserved
//==============================================================================

class UT2K4SP_Injury extends LargeWindow;

var automated GUIImage	imgPictureBg, imgPicture;
var automated GUIButton btnCancel, btnTreat;
var automated GUILabel lblTitle, lblMessage;

var UT2K4GameProfile GP;
/** price to heal the injured player */
var int TreatmentCost;
/** the offset in the GameProfile's botstats array, set in HandleParameters */
var int InjuredPlayer;

event HandleParameters(string Param1, string Param2)
{
	local XUtil.PlayerRecord PR;
	InjuredPlayer = int(Param1);
	GP = UT2K4GameProfile(PlayerOwner().Level.Game.CurrentGameProfile);
	if ((GP == none) || (InjuredPlayer < 0) || (InjuredPlayer >= GP.BotStats.length))
	{
		Warn("Invalid injury menu request:"@(GP == none)@(InjuredPlayer < 0)@(InjuredPlayer >= GP.BotStats.length));
		Controller.CloseMenu(true);
		return;
	}
	if (GP.BotStats[InjuredPlayer].Health >= 100)
	{
		Controller.CloseMenu(true);
		return;
	}
	lblMessage.Caption = repl(lblMessage.Caption, "%player%", GP.BotStats[InjuredPlayer].Name);
	lblMessage.Caption = repl(lblMessage.Caption, "%health%", GP.BotStats[InjuredPlayer].Health);
	TreatmentCost = round((100-GP.BotStats[InjuredPlayer].Health)*GP.BotStats[InjuredPlayer].Price/100*GP.InjuryTreatment);
	lblMessage.Caption = repl(lblMessage.Caption, "%treatment%", GP.MoneyToString(TreatmentCost));
	lblMessage.Caption = repl(lblMessage.Caption, "%balance%", GP.MoneyToString(GP.Balance));
	PR = class'xGame.xUtil'.static.FindPlayerRecord(GP.BotStats[InjuredPlayer].Name);
	imgPicture.Image = PR.Portrait;
	if (TreatmentCost > GP.Balance-GP.MinBalance) btnTreat.DisableMe(); // cant afford it, but still report
}

function bool btnCancelOnClick(GUIComponent Sender)
{
	Controller.CloseMenu(true);
	return true;
}

function bool btnTreatOnClick(GUIComponent Sender)
{
	GP.BotStats[InjuredPlayer].Health = 100;
	GP.Balance -= TreatmentCost;
	Controller.CloseMenu(false);
	return true;
}

defaultproperties
{
     Begin Object Class=GUIImage Name=SPMimgPictureBg
         Image=Texture'2K4Menus.Controls.sectionback'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         WinTop=0.136499
         WinLeft=0.057750
         WinWidth=0.177000
         WinHeight=0.464500
         RenderWeight=0.200000
         bBoundToParent=True
     End Object
     imgPictureBg=GUIImage'GUI2K4.UT2K4SP_Injury.SPMimgPictureBg'

     Begin Object Class=GUIImage Name=SPMimgPicture
         Image=Texture'2K4Menus.Controls.thinpipe_b'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         WinTop=0.146500
         WinLeft=0.059000
         WinWidth=0.174500
         WinHeight=0.452000
         RenderWeight=0.300000
         bBoundToParent=True
     End Object
     imgPicture=GUIImage'GUI2K4.UT2K4SP_Injury.SPMimgPicture'

     Begin Object Class=GUIButton Name=SPMbtnCancel
         Caption="CANCEL"
         FontScale=FNS_Small
         WinTop=0.857292
         WinLeft=0.051563
         WinWidth=0.200000
         bBoundToParent=True
         OnClick=UT2K4SP_Injury.btnCancelOnClick
         OnKeyEvent=SPMbtnCancel.InternalOnKeyEvent
     End Object
     btnCancel=GUIButton'GUI2K4.UT2K4SP_Injury.SPMbtnCancel'

     Begin Object Class=GUIButton Name=SPMbtnTreat
         Caption="TREAT NOW"
         FontScale=FNS_Small
         WinTop=0.857292
         WinLeft=0.664063
         WinWidth=0.200000
         bBoundToParent=True
         OnClick=UT2K4SP_Injury.btnTreatOnClick
         OnKeyEvent=SPMbtnTreat.InternalOnKeyEvent
     End Object
     btnTreat=GUIButton'GUI2K4.UT2K4SP_Injury.SPMbtnTreat'

     Begin Object Class=GUILabel Name=SPLlblTitle
         Caption="Injury"
         TextAlign=TXTA_Center
         FontScale=FNS_Large
         StyleName="TextLabel"
         WinTop=0.051667
         WinLeft=0.028750
         WinWidth=0.661250
         WinHeight=0.072500
         bBoundToParent=True
     End Object
     lblTitle=GUILabel'GUI2K4.UT2K4SP_Injury.SPLlblTitle'

     Begin Object Class=GUILabel Name=SPLlblMessage
         Caption="%player% got injured in the last match.|%player%'s health is down to %health%%, treatment of the injuries costs %treatment%.|Balance: %balance%."
         bMultiLine=True
         StyleName="TextLabel"
         WinTop=0.176667
         WinLeft=0.372500
         WinWidth=0.373749
         WinHeight=0.391250
         bBoundToParent=True
     End Object
     lblMessage=GUILabel'GUI2K4.UT2K4SP_Injury.SPLlblMessage'

     DefaultLeft=0.150000
     DefaultTop=0.150000
     DefaultWidth=0.700000
     DefaultHeight=0.700000
     WinTop=0.150000
     WinLeft=0.150000
     WinWidth=0.700000
     WinHeight=0.700000
}
