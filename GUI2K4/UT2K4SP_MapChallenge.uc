//==============================================================================
// Challenge for the alternative map
//
// Written by Michiel Hendriks
// (c) 2003, 2004, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4SP_MapChallenge extends LargeWindow;

var automated GUILabel lblTitle;
var automated GUIButton btnOk, btnCancel;
var automated GUIImage imgMapBg, imgMap;
var automated GUIScrollTextBox lblDesc;

var localized string ChallengeDesc;

var UT2K4GameProfile GP;
/** Challenge match info */
var UT2K4MatchInfo ChalMI;
var CacheManager.MapRecord ActiveMap;

var float ChangeCost;

/** called when the OK button was clicked */
delegate MapSelectionUpdate();

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local UT2K4MatchInfo MI;
	local UT2K4SP_Main MainWindow;
	local CacheManager.MapRecord MR;
	local string tmp;

	Super.Initcomponent(MyController, MyOwner);
	GP = UT2K4GameProfile(PlayerOwner().Level.Game.CurrentGameProfile);
	if (GP == none)
	{
		Warn("GP == none");
		return;
	}

	// find main window
	MainWindow = UT2K4SP_Main(Controller.FindMenuByClass(class'UT2K4SP_Main'));
/*
	for (i = Controller.MenuStack.length-1; i>=0; i--)
	{
		if (UT2K4SP_Main(Controller.MenuStack[i]) != None)
		{
			MainWindow = UT2K4SP_Main(Controller.MenuStack[i]);
			break;
		}
	}
*/
	// get alternative map info
	MI = GP.GetSelectedMatchInfo(GP.CurrentLadder, GP.CurrentMenuRung, GP.GetAltLevel(GP.CurrentLadder, GP.CurrentMenuRung), GP.GetSelectedLevel(GP.CurrentLadder, GP.CurrentMenuRung) != -1);
	MR = class'CacheManager'.static.getMapRecord(MI.LevelName);
	if (MR.FriendlyName != "") tmp = MR.FriendlyName;
		else tmp = MR.MapName;
	ChallengeDesc = repl(ChallengeDesc, "%altmap%", tmp);
	if (MR.ScreenshotRef != "")	imgMap.Image = Material(DynamicLoadObject(MR.ScreenshotRef, class'Material'));

	// get current map info
	MI = UT2K4MatchInfo(GP.GetMatchInfo(GP.CurrentLadder, GP.CurrentMenuRung));
	MR = class'CacheManager'.static.getMapRecord(MI.LevelName);
	if (MR.FriendlyName != "") tmp = MR.FriendlyName;
		else tmp = MR.MapName;
	ChallengeDesc = repl(ChallengeDesc, "%curmap%", tmp);

	ChangeCost = MI.PrizeMoney * GP.MapChallengeCost;
	ChallengeDesc = repl(ChallengeDesc, "%fee%", GP.MoneyToString(ChangeCost));

	lblDesc.setContent(ChallengeDesc);

	if (imgMap.Image==None) imgMap.Image = Material'UCGeneric.SolidColours.Black';
}

function bool OnOkClick(GUIComponent Sender)
{
	GP.Balance -= ChangeCost;
	if (GP.GetSelectedLevel(GP.CurrentLadder, GP.CurrentMenuRung) != -1) GP.ResetSelectedLevel(GP.CurrentLadder, GP.CurrentMenuRung);
	else GP.SetSelectedLevel(GP.CurrentLadder, GP.CurrentMenuRung, GP.GetAltLevel(GP.CurrentLadder, GP.CurrentMenuRung));
    MapSelectionUpdate();
	return Controller.CloseMenu(false);
}

function bool OnCancelClick(GUIComponent Sender)
{
	return Controller.CloseMenu(true);
}

defaultproperties
{
     Begin Object Class=GUILabel Name=SPClblTitle
         Caption="Change Arena"
         TextAlign=TXTA_Center
         FontScale=FNS_Large
         StyleName="TextLabel"
         WinTop=0.057847
         WinLeft=0.021563
         WinWidth=0.762501
         WinHeight=0.052500
         RenderWeight=0.200000
         bBoundToParent=True
     End Object
     lblTitle=GUILabel'GUI2K4.UT2K4SP_MapChallenge.SPClblTitle'

     Begin Object Class=GUIButton Name=SPMbtnOk
         Caption="CHANGE"
         FontScale=FNS_Small
         WinTop=0.854397
         WinLeft=0.685071
         WinWidth=0.222222
         WinHeight=0.044444
         RenderWeight=0.200000
         TabOrder=1
         bBoundToParent=True
         OnClick=UT2K4SP_MapChallenge.onOkClick
         OnKeyEvent=SPMbtnOk.InternalOnKeyEvent
     End Object
     btnOK=GUIButton'GUI2K4.UT2K4SP_MapChallenge.SPMbtnOk'

     Begin Object Class=GUIButton Name=SPCbtnCancel
         Caption="CANCEL"
         FontScale=FNS_Small
         WinTop=0.854397
         WinLeft=0.037848
         WinWidth=0.222222
         WinHeight=0.044444
         RenderWeight=0.200000
         TabOrder=2
         bBoundToParent=True
         OnClick=UT2K4SP_MapChallenge.onCancelClick
         OnKeyEvent=SPCbtnCancel.InternalOnKeyEvent
     End Object
     btnCancel=GUIButton'GUI2K4.UT2K4SP_MapChallenge.SPCbtnCancel'

     Begin Object Class=GUIImage Name=SPCimgMapBg
         Image=Texture'2K4Menus.Controls.sectionback'
         ImageStyle=ISTY_Scaled
         WinTop=0.144641
         WinLeft=0.222222
         WinWidth=0.444444
         WinHeight=0.333333
         bBoundToParent=True
     End Object
     imgMapBg=GUIImage'GUI2K4.UT2K4SP_MapChallenge.SPCimgMapBg'

     Begin Object Class=GUIImage Name=SPCimgMap
         Image=Texture'2K4Menus.Controls.sectionback'
         ImageStyle=ISTY_Scaled
         WinTop=0.155865
         WinLeft=0.224722
         WinWidth=0.441667
         WinHeight=0.321250
         RenderWeight=0.150000
         bBoundToParent=True
     End Object
     imgMap=GUIImage'GUI2K4.UT2K4SP_MapChallenge.SPCimgMap'

     Begin Object Class=GUIScrollTextBox Name=SPClblDesc
         bNoTeletype=True
         OnCreateComponent=SPClblDesc.InternalOnCreateComponent
         WinTop=0.717846
         WinLeft=0.042813
         WinWidth=0.731251
         WinHeight=0.090000
         RenderWeight=0.200000
         TabOrder=1
         bBoundToParent=True
     End Object
     lblDesc=GUIScrollTextBox'GUI2K4.UT2K4SP_MapChallenge.SPClblDesc'

     ChallengeDesc="The current arena for this match is %curmap%.|You can change this arena to %altmap% when you pay %fee%."
     DefaultLeft=0.100000
     DefaultWidth=0.800000
     WinLeft=0.100000
     WinWidth=0.800000
}
