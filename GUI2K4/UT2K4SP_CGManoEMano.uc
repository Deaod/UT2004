//==============================================================================
// Challenge a team for a 1vs1 game
//
// Written by Michiel Hendriks
// (c) 2003, 2004, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4SP_CGManoEMano extends LargeWindow;

var automated GUIImage imgMap1, imgMap2, imgMapBg1, imgMapBg2;
var automated GUIButton btnOk, btnCancel;
var automated GUILabel lblTitle, lblNoPreview1, lblNoPreview2, lblMinMaxBet, lblBalance;
var automated GUIGFXButton cbMap1, cbMap2;
var automated moComboBox cbEnemyTeam;
var automated moFormatNumEdit neBet;
var automated GUIScrollTextBox sbDetails;

var UT2K4GameProfile GP;

/** the penalty we pay when we cancel the challenge */
var int CancelPenalty;

/** The two maps to choose from */
var CacheManager.MapRecord MapOptions[2];

/** Minimal bet you may place */
var int MinimalBet;

/** set to the preselect/challenged team */
var string ChallengedBy;
/** true if we have been challenged */
var bool bChallenged;

var localized string PenaltyWarning, YouveBeenChallenged, SelectAMap,
					 msgChallenge, msgChallenged, NotEnoughCash, msgMinMaxBet;
/** always append this to the url */
var string DefaultUrl;

/** available maps */
var array<string> ChalMaps;

struct ChallengeSettingRecord
{
	var string Acronym;
	var int GoalScore;
	var string GameType;
};
/** per acronym settings */
var array<ChallengeSettingRecord> ChallengeSettings;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;
	local class<UT2K4TeamRoster> ET;

	Super.Initcomponent(MyController, MyOwner);
	GP = UT2K4GameProfile(PlayerOwner().Level.Game.CurrentGameProfile);
	for ( i = 0; i < Controls.Length; i++ )
	{
		Controls[i].bScaleToParent=True;
		Controls[i].bBoundToParent=True;
	}

	cbEnemyTeam.MyComboBox.List.Clear();
	for (i = 0; i < GP.TeamStats.length; i++)
	{
		if (GP.TeamStats[i].Matches > 0)
		{
			if (GP.TeamStats[i].Level >=3) continue; // never add strong team in 1vs1
			ET = class<UT2K4TeamRoster>(DynamicLoadObject(GP.TeamStats[i].Name, class'Class'));
			if (ET != none) cbEnemyTeam.AddItem(ET.Default.TeamName@"("$class'UT2K4SPTab_DetailEnemies'.default.StrengthLabels[ET.Default.TeamLevel]$")",,GP.TeamStats[i].Name);
		}
	}

	cbEnemyTeam.MyComboBox.List.Sort();
	cbEnemyTeam.SetIndex(0);

	SetupNoPreview(lblNoPreview1, imgMap1);
	SetupNoPreview(lblNoPreview2, imgMap2);

	sbDetails.SetContent(SelectAMap);

	lblBalance.Caption = class'UT2K4SPTab_LadderBase'.default.BalanceLabel@GP.MoneyToString(GP.Balance);
}

function GetRandomMaps()
{
	local int m1, m2;
	m1 = -1;
	m2 = -1;
	if (MapOptions[0].MapName == "") m1 = rand(ChalMaps.Length);
	do {
		if (MapOptions[1].MapName == "") m2 = rand(ChalMaps.Length);
		else break;
	} until (m1 != m2);
	if (m1 > -1) MapOptions[0] = class'CacheManager'.static.GetMapRecord(ChalMaps[m1]);
	if (m2 > -1) MapOptions[1] = class'CacheManager'.static.GetMapRecord(ChalMaps[m2]);

	if (MapOptions[0].ScreenshotRef != "") imgMap1.Image = Material(DynamicLoadObject(MapOptions[0].ScreenshotRef, class'Material'));
	lblNoPreview1.bVisible = MapOptions[0].ScreenshotRef == "";
	cbMap1.Caption = MapOptions[0].MapName;
	if (MapOptions[1].ScreenshotRef != "") imgMap2.Image = Material(DynamicLoadObject(MapOptions[1].ScreenshotRef, class'Material'));
	lblNoPreview2.bVisible = MapOptions[1].ScreenshotRef == "";
	cbMap2.Caption = MapOptions[1].MapName;
}

function setChallengeInfo(int selectedMap)
{
	local string desc;
	local class<UT2K4TeamRoster> ETI;
	local CacheManager.GameRecord GR;
	local int chalset;

	for (chalset = 0; chalset < ChallengeSettings.length; chalset++)
	{
		if (ChallengeSettings[chalset].Acronym ~= MapOptions[selectedMap].Acronym) break;
	}
	GR = class'CacheManager'.static.getGameRecord(ChallengeSettings[chalset].GameType);
	ETI = class<UT2K4TeamRoster>(DynamicLoadObject(cbEnemyTeam.GetExtra(), class'Class'));

	GP.ChallengeInfo.LevelName = MapOptions[selectedMap].MapName;
	GP.ChallengeInfo.NumBots = 1; // always 1 on 1
	GP.ChallengeInfo.DifficultyModifier = ETI.default.TeamLevel / 1.2;
	if (GP.ChallengeInfo.LevelName ~= "CTF-1on1-Joust") GP.ChallengeInfo.DifficultyModifier += 2;
	GP.ChallengeInfo.PrizeMoney = neBet.GetValue()*2;
	GP.ChallengeInfo.GameType = ChallengeSettings[chalset].GameType;
	GP.ChallengeInfo.GoalScore = ChallengeSettings[chalset].GoalScore;
	GP.ChallengeInfo.EntryFee = neBet.GetValue();
	GP.ChallengeInfo.URLString = DefaultUrl;

	if (bChallenged) desc = msgChallenged;
	else desc = msgChallenge;
	desc = repl(desc, "%map%", MapOptions[selectedMap].MapName);
	desc = repl(desc, "%teamname%", cbEnemyTeam.GetText());
	if (ETI.default.TeamLeader != "") desc = repl(desc, "%teamleader%", ETI.default.TeamLeader);
	else desc = repl(desc, "%teamleader%", ETI.default.RosterNames[0]);
	desc = repl(desc, "%prizemoney%", GP.MoneyToString(GP.ChallengeInfo.PrizeMoney));
	desc = repl(desc, "%entryfee%", GP.MoneyToString(GP.ChallengeInfo.EntryFee));
	desc = repl(desc, "%gametype%", GR.GameName);
	desc = repl(desc, "%penalty%", GP.MoneyToString(CancelPenalty));
	sbDetails.SetContent(desc);

	if ((GP.ChallengeInfo.LevelName != "") && (GP.Balance > GP.getMinimalEntryFeeFor(GP.ChallengeInfo)+GP.MinBalance)) btnOk.EnableMe();
		else btnOk.DisableMe();
}

/**
	param1 = preselect enemy team, fully qualified classname.
	param2 = not empty -> lock team change controlls
*/
event HandleParameters(string Param1, string Param2)
{
	local GUIController MyController;

	ChallengedBy = Param1;
	if (ChallengedBy != "") cbEnemyTeam.SetIndex(cbEnemyTeam.FindExtra(ChallengedBy));
	bChallenged = (Param2 != "");
	if (bChallenged)
	{
		MinimalBet = MinimalBet+rand(MinimalBet);
		CancelPenalty = MinimalBet*1.5;
		cbEnemyTeam.disableme();

		if (GP.CurrentLadder == GP.UT2K4GameLadder.default.LID_CTF)
		{
			if (frand() > 0.5)
			{
				MapOptions[rand(2)] = class'CacheManager'.static.GetMapRecord("CTF-1on1-Joust");
			}
		}
	}
	else {
		ChalMaps.Length = ChalMaps.Length+1;
		ChalMaps[ChalMaps.length-1] = "CTF-1on1-Joust";
	}

	neBet.Setup(MinimalBet, GP.Balance, (GP.Balance-MinimalBet)/20);
	UpdateTeamDetails(cbEnemyTeam);

	if ((GP.Balance-GP.MinBalance < MinimalBet) || (GP.Balance-GP.MinBalance < CancelPenalty))
	{
		CancelPenalty = 0;
		MyController = Controller;
		Controller.CloseMenu(true);
		if (bChallenged) return;

		MyController.ShowQuestionDialog(NotEnoughCash);
		return;
	}
	GetRandomMaps();
}

/**
	Play the selected match, first check if we need to assign team mates
*/
function bool onOkClick(GUIComponent Sender)
{
	GP.EnemyTeam = cbEnemyTeam.GetExtra();
	GP.ChallengeInfo.EnemyTeamName = GP.EnemyTeam;
	GP.bGotChallenged = bChallenged;
	GP.ChallengeVariable = GP.MoneyToString(neBet.GetValue());
	class'xGame.ManoEMano'.static.StartChallenge(GP, PlayerOwner().Level);
	Controller.CloseAll(false,true);
	return true;
}

/**
	Cancel button pressed
*/
function bool onCancelClick(GUIComponent Sender)
{
	if (OnCanWindowClose(true)) return Controller.CloseMenu(true);
	else return false;
}

/** Player accepts to pay the penalty */
function OnConfirmCancel(byte bButton)
{
	if (bButton == QBTN_Yes)
	{
		GP.Balance -= CancelPenalty;
		CancelPenalty = 0;
		Controller.CloseMenu(true);
	}
}

function OnMapSelect(GUIComponent Sender)
{
	if (Sender == cbMap1)
	{
		GP.ActiveMap = MapOptions[0];
		cbMap1.bChecked = true;
		cbMap2.bChecked = false;
		setChallengeInfo(0);
	}
	else {
		GP.ActiveMap = MapOptions[1];
		cbMap1.bChecked = false;
		cbMap2.bChecked = true;
		setChallengeInfo(1);
	}
	return;
}

function OnWindowClose(optional Bool bCancelled)
{
	GP.bIsChallenge = !bCancelled;
}

function bool OnCanWindowClose(optional Bool bCancelled)
{
	local GUIQuestionPage QPage;
	if (!bCancelled) return true;
	if (CancelPenalty > 0)
	{
		if (Controller.OpenMenu("GUI2K4.GUI2K4QuestionPage"))
		{
			QPage=GUIQuestionPage(Controller.TopPage());
			QPage.SetupQuestion(repl(PenaltyWarning, "%cancelpenalty%", GP.MoneyToString(CancelPenalty)), QBTN_YesNo, QBTN_No);
			QPage.OnButtonClick = OnConfirmCancel;
		}
		return false;
	}
	return true;
}

function UpdateDetails(GUIComponent Sender)
{
	if (cbMap1.bChecked) setChallengeInfo(0);
	else if (cbMap2.bChecked) setChallengeInfo(1);
}

function UpdateTeamDetails(GUIComponent Sender)
{
	local class<UT2K4TeamRoster> ETI;
	ETI = class<UT2K4TeamRoster>(DynamicLoadObject(cbEnemyTeam.GetExtra(), class'Class'));
	neBet.MyNumericEdit.MaxValue = min(GP.Balance, MinimalBet*(ETI.default.TeamLevel+1)*2);
	neBet.MyNumericEdit.Step = (neBet.MyNumericEdit.MaxValue-neBet.MyNumericEdit.MinValue) / 20;
	neBet.SetValue(neBet.GetValue());
	lblMinMaxBet.Caption = repl(repl(msgMinMaxBet, "%min%", GP.MoneyToString(MinimalBet)), "%max%", GP.MoneyToString(neBet.MyNumericEdit.MaxValue));
}


event SetVisibility(bool bIsVisible)
{
	Super.SetVisibility(bIsVisible);
	if ( imgMap1 != None )
	{
		imgMap1.SetVisibility(imgMap1.Image != None);
		if ( lblNoPreview1 != None ) lblNoPreview1.SetVisibility(imgMap1.Image == None);
	}
	if ( imgMap2 != None )
	{
		imgMap2.SetVisibility(imgMap2.Image != None);
		if ( lblNoPreview2 != None ) lblNoPreview2.SetVisibility(imgMap2.Image == None);
	}
}

protected function SetupNoPreview( GUILabel lbl, GUIImage img )
{
	if ( lbl == None || img == None ) return;
	lbl.WinLeft   = img.WinLeft;
	lbl.WinTop    = img.WinTop;
	lbl.WinWidth  = img.WinWidth;
	lbl.WinHeight = img.WinHeight;
}

function bool XButtonClicked( GUIComponent Sender )
{
	Controller.CloseMenu(true);
	return true;
}

function string FormatMoney(int NewValue)
{
	return GP.MoneyToString(NewValue);
}

defaultproperties
{
     Begin Object Class=GUIImage Name=SPCimgMap1
         Image=Texture'2K4Menus.Controls.sectionback'
         ImageStyle=ISTY_Scaled
         WinTop=0.122531
         WinLeft=0.022222
         WinWidth=0.441667
         WinHeight=0.312500
         RenderWeight=0.150000
         bBoundToParent=True
     End Object
     imgMap1=GUIImage'GUI2K4.UT2K4SP_CGManoEMano.SPCimgMap1'

     Begin Object Class=GUIImage Name=SPCimgMap2
         Image=Texture'2K4Menus.Controls.sectionback'
         ImageStyle=ISTY_Scaled
         WinTop=0.122531
         WinLeft=0.536111
         WinWidth=0.441667
         WinHeight=0.312500
         RenderWeight=0.150000
         bBoundToParent=True
     End Object
     imgMap2=GUIImage'GUI2K4.UT2K4SP_CGManoEMano.SPCimgMap2'

     Begin Object Class=GUIImage Name=SPCimgMapBg1
         Image=Texture'2K4Menus.Controls.sectionback'
         ImageStyle=ISTY_Scaled
         WinTop=0.111308
         WinLeft=0.020833
         WinWidth=0.444444
         WinHeight=0.333333
         bBoundToParent=True
     End Object
     imgMapBg1=GUIImage'GUI2K4.UT2K4SP_CGManoEMano.SPCimgMapBg1'

     Begin Object Class=GUIImage Name=SPCimgMapBg2
         Image=Texture'2K4Menus.Controls.sectionback'
         ImageStyle=ISTY_Scaled
         WinTop=0.111308
         WinLeft=0.534722
         WinWidth=0.444444
         WinHeight=0.333333
         bBoundToParent=True
     End Object
     imgMapBg2=GUIImage'GUI2K4.UT2K4SP_CGManoEMano.SPCimgMapBg2'

     Begin Object Class=GUIButton Name=SPMbtnOk
         Caption="ACCEPT"
         FontScale=FNS_Small
         WinTop=0.904398
         WinLeft=0.710071
         WinWidth=0.222222
         WinHeight=0.056944
         RenderWeight=0.200000
         TabOrder=1
         bBoundToParent=True
         OnClick=UT2K4SP_CGManoEMano.onOkClick
         OnKeyEvent=SPMbtnOk.InternalOnKeyEvent
     End Object
     btnOK=GUIButton'GUI2K4.UT2K4SP_CGManoEMano.SPMbtnOk'

     Begin Object Class=GUIButton Name=SPCbtnCancel
         Caption="REFUSE"
         FontScale=FNS_Small
         WinTop=0.904398
         WinLeft=0.050348
         WinWidth=0.222222
         WinHeight=0.056944
         RenderWeight=0.200000
         TabOrder=2
         bBoundToParent=True
         OnClick=UT2K4SP_CGManoEMano.onCancelClick
         OnKeyEvent=SPCbtnCancel.InternalOnKeyEvent
     End Object
     btnCancel=GUIButton'GUI2K4.UT2K4SP_CGManoEMano.SPCbtnCancel'

     Begin Object Class=GUILabel Name=SPClblTitle
         Caption="Head to Head"
         TextAlign=TXTA_Center
         FontScale=FNS_Large
         StyleName="TextLabel"
         WinTop=0.026180
         WinLeft=0.067813
         WinWidth=0.862501
         WinHeight=0.077500
         RenderWeight=0.200000
         bBoundToParent=True
     End Object
     lblTitle=GUILabel'GUI2K4.UT2K4SP_CGManoEMano.SPClblTitle'

     Begin Object Class=GUILabel Name=NoPreview
         Caption="No Preview Available"
         TextAlign=TXTA_Center
         TextColor=(B=0,G=255,R=247)
         TextFont="UT2HeaderFont"
         bTransparent=False
         bMultiLine=True
         VertAlign=TXTA_Center
         WinTop=0.197531
         WinLeft=0.022222
         WinWidth=0.441667
         WinHeight=0.312500
         bBoundToParent=True
     End Object
     lblNoPreview1=GUILabel'GUI2K4.UT2K4SP_CGManoEMano.NoPreview'

     lblNoPreview2=GUILabel'GUI2K4.UT2K4SP_CGManoEMano.NoPreview'

     Begin Object Class=GUILabel Name=SPClblMinMax
         FontScale=FNS_Small
         StyleName="TextLabel"
         WinTop=0.619930
         WinLeft=0.026146
         WinWidth=0.952778
         WinHeight=0.042778
         RenderWeight=0.200000
         bBoundToParent=True
     End Object
     lblMinMaxBet=GUILabel'GUI2K4.UT2K4SP_CGManoEMano.SPClblMinMax'

     Begin Object Class=GUILabel Name=SPLlblBalance
         TextAlign=TXTA_Right
         StyleName="TextLabel"
         WinTop=0.046667
         WinLeft=0.532360
         WinWidth=0.450000
         WinHeight=0.041250
         RenderWeight=0.250000
         bBoundToParent=True
     End Object
     lblBalance=GUILabel'GUI2K4.UT2K4SP_CGManoEMano.SPLlblBalance'

     Begin Object Class=GUIGFXButton Name=SPCcbMap1
         bCheckBox=True
         WinTop=0.452974
         WinLeft=0.020833
         WinWidth=0.444444
         WinHeight=0.062500
         bBoundToParent=True
         OnChange=UT2K4SP_CGManoEMano.OnMapSelect
         OnKeyEvent=SPCcbMap1.InternalOnKeyEvent
     End Object
     cbMap1=GUIGFXButton'GUI2K4.UT2K4SP_CGManoEMano.SPCcbMap1'

     Begin Object Class=GUIGFXButton Name=SPCcbMap2
         bCheckBox=True
         WinTop=0.452974
         WinLeft=0.534722
         WinWidth=0.444444
         WinHeight=0.062500
         bBoundToParent=True
         OnChange=UT2K4SP_CGManoEMano.OnMapSelect
         OnKeyEvent=SPCcbMap2.InternalOnKeyEvent
     End Object
     cbMap2=GUIGFXButton'GUI2K4.UT2K4SP_CGManoEMano.SPCcbMap2'

     Begin Object Class=moComboBox Name=SPCcbEnemyTeam
         bReadOnly=True
         Caption="Challenge team:"
         OnCreateComponent=SPCcbEnemyTeam.InternalOnCreateComponent
         Hint="Challenge this team for a match"
         WinTop=0.536447
         WinLeft=0.024306
         WinWidth=0.952779
         WinHeight=0.059722
         TabOrder=3
         bBoundToParent=True
         OnChange=UT2K4SP_CGManoEMano.UpdateTeamDetails
     End Object
     cbEnemyTeam=moComboBox'GUI2K4.UT2K4SP_CGManoEMano.SPCcbEnemyTeam'

     Begin Object Class=moFormatNumEdit Name=SPCneBet
         FormatValue=UT2K4SP_CGManoEMano.FormatMoney
         Caption="Challenge bet:"
         OnCreateComponent=SPCneBet.InternalOnCreateComponent
         Hint="The bet for this challenge"
         WinTop=0.590614
         WinLeft=0.024306
         WinWidth=0.952779
         WinHeight=0.037500
         TabOrder=4
         bBoundToParent=True
         OnChange=UT2K4SP_CGManoEMano.UpdateDetails
     End Object
     neBet=moFormatNumEdit'GUI2K4.UT2K4SP_CGManoEMano.SPCneBet'

     Begin Object Class=GUIScrollTextBox Name=SPCsbDetails
         bNoTeletype=True
         OnCreateComponent=SPCsbDetails.InternalOnCreateComponent
         WinTop=0.674643
         WinLeft=0.019792
         WinWidth=0.958334
         WinHeight=0.217361
         RenderWeight=0.200000
         TabOrder=1
         bBoundToParent=True
     End Object
     sbDetails=GUIScrollTextBox'GUI2K4.UT2K4SP_CGManoEMano.SPCsbDetails'

     MinimalBet=150
     PenaltyWarning="When you refuse you will have to pay a penalty of %cancelpenalty%.||Are you sure you want to refuse?"
     YouveBeenChallenged="You've been challenged!"
     SelectAMap="Please select an area for the challenge."
     msgChallenge="You have selected to play a %gametype% match in %map%. You will play against %teamleader% of the %teamname%.|You will have to pay %entryfee% to participate in this challenge, if you win you will earn %prizemoney%"
     msgChallenged="You have been challenged by %teamname% for a Head to Head match. You will play against %teamleader%.|When you win you will earn %prizemoney%, but you have to pay up %entryfee% to join this challenge.|You will play a %gametype% game in %map%.|If you refuse the match you will have to pay %penalty%."
     NotEnoughCash="You do not have enough money to pay the minimal bet for this challenge."
     msgMinMaxBet="minimum: %min%, maximum: %max%"
     DefaultUrl="?TeamScreen=true"
     ChalMaps(0)="DM-1on1-Albatross"
     ChalMaps(1)="DM-1on1-Crash"
     ChalMaps(2)="DM-1on1-Idoma"
     ChalMaps(3)="DM-1on1-Irondust"
     ChalMaps(4)="DM-1on1-Mixer"
     ChalMaps(5)="DM-1on1-Roughinery"
     ChalMaps(6)="DM-1on1-Serpentine"
     ChalMaps(7)="DM-1on1-Spirit"
     ChalMaps(8)="DM-1on1-Squader"
     ChalMaps(9)="DM-1on1-Trite"
     ChallengeSettings(0)=(Acronym="DM",GoalScore=15,GameType="xGame.xTeamGame")
     ChallengeSettings(1)=(Acronym="CTF",GoalScore=3,GameType="xGame.xCTFGame")
     DefaultLeft=0.050000
     DefaultTop=0.100000
     DefaultWidth=0.900000
     DefaultHeight=0.800000
     OnClose=UT2K4SP_CGManoEMano.OnWindowClose
     OnCanClose=UT2K4SP_CGManoEMano.OnCanWindowClose
     WinTop=0.100000
     WinLeft=0.050000
     WinWidth=0.900000
     WinHeight=0.800000
}
