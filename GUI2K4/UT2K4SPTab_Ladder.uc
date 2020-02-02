//==============================================================================
// Main single player ladder menu
//
// Written by Michiel Hendriks
// (c) 2003, 2004, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4SPTab_Ladder extends UT2K4SPTab_LadderBase;

var array<UT2K4LadderButton> CTFEntries;
var array<UT2K4LadderButton> BREntries;
var array<UT2K4LadderButton> DOMEntries;
var array<UT2K4LadderButton> ASEntries;
var array<UT2K4LadderButton> CHAMPEntries;
/** set to 1 if the ladder buttons have been initialized */
var byte LadderInit[5];

var automated array<GUIImage> imgChamp;
var automated array<GUIImage> imgChampBars;
var automated array<GUILabel> lblLadders;

var automated GUISectionBackground sbgLadderBg, sbgChallengeBg;
//var automated GUILabel lblLadderTitle, lblChallengeTitle;
var automated GUIComboBox cbChallenges;

var array<GUIButton> imgLadderBtns;
var array<GUIImage> imgLadderBgs;
var array<GUIImage> imgLadderImgs;

var automated UT2K4LadderButton btnChampFinal;
var automated GUIImage imgChampFinal;

var array<AnimData> animCTFEntries;
var array<AnimData> animBREntries;
var array<AnimData> animDOMEntries;
var array<AnimData> animASEntries;
var array<AnimData> animCHAMPEntries;

/**
	Used to hide the previous selected ladder
*/
var int PreviousLadder;

var Material LadderBorderNormal, LadderBorderCompleted, LadderBarCompleted;

/**
	Images to use for the ladder buttons
*/
var array<string> LadderImageCompleted, LadderImage;

/** the 1st open ladder */
var int OpenLadderIndex;

var localized string msgSelectChal;

function InitComponent(GUIController pMyController, GUIComponent MyOwner)
{
	local string tmp;
	local array<int> OpenLadders;
	local int i;

	Super.Initcomponent(pMyController, MyOwner);

	sbgMatch.WinTop = 0.415000;
	sbgMatch.WinLeft = 0.077117;
	sbgMatch.WinWidth = 0.377143;
	sbgMatch.WinHeight = 0.303750;

	imgMatchShot.WinTop = 0.469105;
	imgMatchShot.WinLeft = 0.091122;
	imgMatchShot.WinWidth = 0.350408;
	imgMatchShot.WinHeight = 0.214082;

	lblMatchPrice.WinTop = 0.644307;
	lblMatchPrice.WinLeft = 0.102500;
	lblMatchPrice.WinWidth = 0.318750;
	lblMatchPrice.WinHeight = 0.041250;

	lblMatchEntryFee.WinTop=0.608750;
	lblMatchEntryFee.WinLeft=0.102500;
	lblMatchEntryFee.WinWidth=0.318750;
	lblMatchEntryFee.WinHeight=0.041250;

	lblNoMoney.WinTop=0.465720;
	lblNoMoney.WinLeft=0.092296;
	lblNoMoney.WinWidth=0.349362;
	lblNoMoney.WinHeight=0.214796;

	sbgDetail.WinTop = 0.415000;
	sbgDetail.WinLeft = 0.465510;
	sbgDetail.WinWidth = 0.451250;
	sbgDetail.WinHeight = 0.303750;

	sbDetails.WinTop = 0.472461;
	sbDetails.WinLeft = 0.482015;
	sbDetails.WinWidth = 0.419515;
	sbDetails.WinHeight = 0.188469;

	btnChallengeMap.WinWidth=0.350765;
	btnChallengeMap.WinHeight=0.046352;
	btnChallengeMap.WinLeft=0.516377;
	btnChallengeMap.WinTop=0.664488;

	CTFEntries = CreateHButtons(GP.UT2K4GameLadder.default.LID_CTF, WinTop+0.655, WinLeft+0.05, (WinWidth*0.81), true);
	animCTFEntries = InitAnimData(CTFEntries);
	DOMEntries = CreateHButtons(GP.UT2K4GameLadder.default.LID_DOM, WinTop+0.655, WinLeft+0.05, (WinWidth*0.81), true);
	animDOMEntries = InitAnimData(DOMEntries);
	BREntries = CreateHButtons(GP.UT2K4GameLadder.default.LID_BR, WinTop+0.655, WinLeft+0.05, (WinWidth*0.81), true);
	animBREntries = InitAnimData(BREntries);
	ASEntries = CreateHButtons(GP.UT2K4GameLadder.default.LID_AS, WinTop+0.655, WinLeft+0.05, (WinWidth*0.81), true);
	animASEntries = InitAnimData(ASEntries);
	CHAMPEntries = CreateHButtons(GP.UT2K4GameLadder.default.LID_CHAMP, WinTop+0.655, WinLeft+(WinWidth/4), (WinWidth*0.81*0.5), true);
	animCHAMPEntries = InitAnimData(CHAMPEntries);
	LadderInit[4] = 1;

	tmp = GP.GetLadderDescription(GP.UT2K4GameLadder.default.LID_CTF);
	lblLadders[0].Caption = caps(tmp);
	LadderInit[0] = 1;
	CreateLadderButtons(0.041666, 0.012500, 0.1125, 0.131250, GP.UT2K4GameLadder.default.LID_CTF, tmp);
	if (SetCompletedLadder(0, (GP.UT2K4GameLadder.default.LID_CTF))) OpenLadders[OpenLadders.length] = 0;

	tmp = GP.GetLadderDescription(GP.UT2K4GameLadder.default.LID_BR);
	lblLadders[1].Caption = caps(tmp);
	LadderInit[1] = 1;
	CreateLadderButtons(0.125000, 0.131250, 0.1125, 0.131250, GP.UT2K4GameLadder.default.LID_BR, tmp);
	if (SetCompletedLadder(1, (GP.UT2K4GameLadder.default.LID_BR))) OpenLadders[OpenLadders.length] = 1;

	tmp = GP.GetLadderDescription(GP.UT2K4GameLadder.default.LID_DOM);
	lblLadders[2].Caption = caps(tmp);
	LadderInit[2] = 1;
	CreateLadderButtons(0.041666, 0.875001, 0.1125, 0.131250, GP.UT2K4GameLadder.default.LID_DOM, tmp);
	if (SetCompletedLadder(2, (GP.UT2K4GameLadder.default.LID_DOM))) OpenLadders[OpenLadders.length] = 2;

	tmp = GP.GetLadderDescription(GP.UT2K4GameLadder.default.LID_AS);
	lblLadders[3].Caption = caps(tmp);
	LadderInit[3] = 1;
	CreateLadderButtons(0.125000, 0.756251, 0.1125, 0.131250, GP.UT2K4GameLadder.default.LID_AS, tmp);
	if (SetCompletedLadder(3, (GP.UT2K4GameLadder.default.LID_AS))) OpenLadders[OpenLadders.length] = 3;

	if (OpenLadders.length > 0)
	{
		OpenLadderIndex = OpenLadders[0];
		setLadderVisibility(imgLadderBtns[OpenLadderIndex].tag, false);
	}

    cbChallenges.AddItem(msgSelectChal);
	for (i = 0; i < GP.UT2K4GameLadder.default.ChallengeGames.length; i++)
	{
		cbChallenges.AddItem(GP.UT2K4GameLadder.default.ChallengeGames[i].default.ChallengeName,,GP.UT2K4GameLadder.default.ChallengeGames[i].default.ChallengeMenu);
	}
}

function ShowPanel(bool bShow)
{
	Super.ShowPanel(bShow);
	if (bShow)
	{
		if (OpenLadderIndex < imgLadderBtns.length && OpenLadderIndex > -1) onLadderClick(imgLadderBtns[OpenLadderIndex]);
		showChampButton(GP.LadderProgress[GP.UT2K4GameLadder.default.LID_CHAMP] >= 0);
	}
	else {
		setLadderVisibility(PreviousLadder, false);
		PreviousLadder = -1; // to make sure the animation repeats
	}
}

function CreateLadderButtons(float top, float left, float width, float height, int ladderid, string title)
{
	local GUIButton btn;
	local GUIImage img;
	local GUIProgressBar pb;

	btn = new class'GUIButton';
	btn.StyleName = "NoBackground";
	btn.bFocusOnWatch = true;
	btn.WinHeight = width;
	btn.WinWidth = height;
	btn.WinTop = top;
	btn.WinLeft = left;
	btn.OnClick = onLadderClick;
	btn.tag = ladderid;
	btn.Hint = title;
	btn.RenderWeight = 0.4;
	btn.TabOrder = Controls.length+1;
	btn.bBoundToParent = true;
	imgLadderBtns[imgLadderBtns.length] = btn;
	AppendComponent(btn, true);

	img = new class'GUIImage';
	img.ImageStyle = ISTY_Stretched;
	img.WinHeight = height;
	img.WinWidth = width;
	img.WinTop = top;
	img.WinLeft = left;
	img.RenderWeight = 0.1;
	img.bBoundToParent = true;
	imgLadderBgs[imgLadderBgs.length] = img;
	AppendComponent(img, true);

	img = new class'GUIImage';
	img.ImageStyle = ISTY_Scaled;
	img.WinHeight = (height*0.64); // image aspect ratio is 4:3
	img.WinWidth = (width-0.02);
	img.WinTop = top+0.01;
	img.WinLeft = left+0.01;
	img.RenderWeight = 0.2;
	img.X1 = 0;
	img.Y1 = 0;
	img.X2 = 1023;
	img.Y2 = 767;
	img.bBoundToParent = true;
	imgLadderImgs[imgLadderImgs.length] = img;
	AppendComponent(img, true);

	pb = new class'GUIProgressBar';
	pb.WinHeight = (height*0.2);
	pb.WinWidth = (width-0.02);
	pb.WinTop = img.WinTop+img.WinHeight+0.013333;
	pb.WinLeft = left+0.01;
	pb.RenderWeight = 0.2;
	pb.Low = 0;
	pb.High = GP.LengthOfLadder(LadderId);
	pb.Value = min(GP.LadderProgress[ladderId], pb.High);
	pb.bShowLow = false;
	pb.bShowHigh = false;
	pb.bShowValue = false;
	pb.CaptionWidth = 0;
	pb.ValueRightWidth = 0;
	pb.bBoundToParent = true;
	AppendComponent(pb);
}

function bool onLadderClick(GUIComponent Sender)
{
	if (PreviousLadder == Sender.tag) return true; // same ladder -> return
	if (PreviousLadder > -1) setLadderVisibility(PreviousLadder, false);
	setLadderVisibility(Sender.tag, true);
	sbgLadderBg.Caption = GUIButton(Sender).hint;
	PreviousLadder = Sender.tag;
	return true;
}

/**
	Show/Hide a ladder
*/
function setLadderVisibility(int ladderId, bool bVisible)
{
	local array<UT2K4LadderButton> btns;
	local array<AnimData> adata;
	local int i, selBtn, linit;
	switch (ladderId)
	{
		case GP.UT2K4GameLadder.default.LID_CTF:
			btns = CTFEntries;
			adata = animCTFEntries;
			linit = 0;
			break;
		case GP.UT2K4GameLadder.default.LID_BR:
			btns = BREntries;
			adata = animBREntries;
			linit = 1;
			break;
		case GP.UT2K4GameLadder.default.LID_DOM:
			btns = DOMEntries;
			adata = animDOMEntries;
			linit = 2;
			break;
		case GP.UT2K4GameLadder.default.LID_AS:
			btns = ASEntries;
			adata = animASEntries;
			linit = 3;
			break;
		case GP.UT2K4GameLadder.default.LID_CHAMP:
			btns = CHAMPEntries;
			adata = animCHAMPEntries;
			linit = 4;
			break;
	}
	for (i = 0; i < btns.length; i++)
	{
		btns[i].SetVisibility(bVisible);
		if (btns[i].ProgresBar != none) btns[i].ProgresBar.bVisible = false;
	}
	// select next match
	if (bVisible)
	{
		if (LadderInit[linit] != 0)
		{
			LadderInit[linit] = 0;
			for (i = 0; i < btns.length; i++)
			{
				btns[i].SetState(GP.LadderProgress[LadderId]);
			}
		}
		DoAnimate(btns, adata);
		selBtn = min(GP.LadderProgress[ladderId], btns.length-1);
		if ((selBtn >= btns.length) || (selBtn < 0)) return;

		while (selBtn >= 0)
		{
			if (GP.getMinimalEntryFeeFor(btns[selBtn].MatchInfo) <= GP.Balance)
			{
				onMatchClick(btns[selBtn]);
				return;
			}
			selBtn--;
		}
		onMatchClick(btns[0]);
	}
	else {
		DoAnimate(btns, adata, true);
	}
}

/**
	return if the ladder is _open_
*/
function bool SetCompletedLadder(int offset, int LadderId)
{
	local bool isCompleted;
	isCompleted = GP.completedLadder(LadderId);
	if (!isCompleted)
	{
		imgLadderBgs[offset].Image = LadderBorderNormal;
		imgLadderImgs[offset].Image = Material(DynamicLoadObject(LadderImage[offset], class'Material'));
	}
	else {
		imgChamp[offset].Image = Material(DynamicLoadObject("InterfaceContent.SPMenu.Lock"$(offset+1)$"Hi", class'Material', true));
		imgChampBars[offset].Image = LadderBarCompleted;
		imgLadderBgs[offset].Image = LadderBorderCompleted;
		imgLadderImgs[offset].Image = Material(DynamicLoadObject(LadderImageCompleted[offset], class'Material'));
	}
	return (GP.LadderProgress[LadderId] > -1) && (!isCompleted);
}

function showChampButton(bool bActive)
{
	local Material Screenshot;
	local CacheManager.MapRecord MapRecord;

	btnChampFinal.bVisible = bActive;
	imgChampFinal.bVisible = bActive;
	btnChampFinal.bAcceptsInput = bActive;
	btnChampFinal.bNeverFocus = !bActive;

	if ( bActive )
	{
		btnChampFinal.MatchInfo = UT2K4MatchInfo(GP.GetMatchInfo(GP.UT2K4GameLadder.default.LID_CHAMP, GP.LadderProgress[GP.UT2K4GameLadder.default.LID_CHAMP]));
		btnChampFinal.MatchIndex = GP.LadderProgress[GP.UT2K4GameLadder.default.LID_CHAMP];
		btnChampFinal.LadderIndex = GP.UT2K4GameLadder.default.LID_CHAMP;

		if ( GP.completedLadder(GP.UT2K4GameLadder.default.LID_CHAMP) )
		{
			// set to final map
			btnChampFinal.MatchIndex = GP.LengthOfLadder(GP.UT2K4GameLadder.default.LID_CHAMP)-1;
			btnChampFinal.Graphic = Material(DynamicLoadObject("PlayerPictures.aDOM", class'Material', true));
		}
		else
		{
			MapRecord = class'CacheManager'.static.getMapRecord(btnChampFinal.MatchInfo.LevelName);
			Screenshot = Material(DynamicLoadObject(MapRecord.ScreenshotRef, class'Material'));
			if (Screenshot==None)	Screenshot = Material'UCGeneric.SolidColours.Black';
			if (MaterialSequence(Screenshot) != none) Screenshot = MaterialSequence(Screenshot).SequenceItems[0].Material;
			btnChampFinal.Graphic = Screenshot;
		}
		OnChampClick(btnChampFinal); // autoselect this match
	}
}

function bool OnChampClick(GUIComponent Sender)
{
	if (PreviousLadder == GP.UT2K4GameLadder.default.LID_CHAMP) return true; // same ladder -> return
	if (PreviousLadder > -1) setLadderVisibility(PreviousLadder, false);
	setLadderVisibility(GP.UT2K4GameLadder.default.LID_CHAMP, true);
	sbgLadderBg.Caption = GP.msgChampionship;
	PreviousLadder = GP.UT2K4GameLadder.default.LID_CHAMP;
	return true;
}

function OnChallengeSelect(GUIComponent Sender)
{
	local string tmp;
	tmp = cbChallenges.GetExtra();
	if (tmp != "") Controller.OpenMenu(tmp);
	cbChallenges.SetIndex(0);
}

defaultproperties
{
     imgChamp(0)=GUIImage'GUI2K4.UT2K4SPTab_Ladder.SPLimgChamp1'
     imgChamp(1)=GUIImage'GUI2K4.UT2K4SPTab_Ladder.SPLimgChamp2'
     imgChamp(2)=GUIImage'GUI2K4.UT2K4SPTab_Ladder.SPLimgChamp3'
     imgChamp(3)=GUIImage'GUI2K4.UT2K4SPTab_Ladder.SPLimgChamp4'
     imgChampBars(0)=GUIImage'GUI2K4.UT2K4SPTab_Ladder.SPLimgChampBar1'
     imgChampBars(1)=GUIImage'GUI2K4.UT2K4SPTab_Ladder.SPLimgChampBar2'
     imgChampBars(2)=GUIImage'GUI2K4.UT2K4SPTab_Ladder.SPLimgChampBar3'
     imgChampBars(3)=GUIImage'GUI2K4.UT2K4SPTab_Ladder.SPLimgChampBar4'
     lblLadders(0)=GUILabel'GUI2K4.UT2K4SPTab_Ladder.SPLlblLadder1'
     lblLadders(1)=GUILabel'GUI2K4.UT2K4SPTab_Ladder.SPLlblLadder2'
     lblLadders(2)=GUILabel'GUI2K4.UT2K4SPTab_Ladder.SPLlblLadder3'
     lblLadders(3)=GUILabel'GUI2K4.UT2K4SPTab_Ladder.SPLlblLadder4'
     Begin Object Class=GUISectionBackground Name=SPLimgLadderBg
         Caption="No ladder selected"
         WinTop=0.738729
         WinLeft=0.015000
         WinWidth=0.970002
         WinHeight=0.218750
         bBoundToParent=True
         OnPreDraw=SPLimgLadderBg.InternalPreDraw
     End Object
     sbgLadderBg=GUISectionBackground'GUI2K4.UT2K4SPTab_Ladder.SPLimgLadderBg'

     Begin Object Class=AltSectionBackground Name=SPLsbgChallengeBg
         Caption="Challenges"
         WinTop=0.259487
         WinLeft=0.281250
         WinWidth=0.443750
         WinHeight=0.140306
         bBoundToParent=True
         OnPreDraw=SPLsbgChallengeBg.InternalPreDraw
     End Object
     sbgChallengeBg=AltSectionBackground'GUI2K4.UT2K4SPTab_Ladder.SPLsbgChallengeBg'

     Begin Object Class=GUIComboBox Name=SPLcbChallenges
         bReadOnly=True
         bShowListOnFocus=True
         Hint="Challenge another team"
         WinTop=0.315065
         WinLeft=0.294985
         WinWidth=0.417347
         WinHeight=0.048648
         TabOrder=2
         bBoundToParent=True
         OnChange=UT2K4SPTab_Ladder.OnChallengeSelect
         OnKeyEvent=SPLcbChallenges.InternalOnKeyEvent
     End Object
     cbChallenges=GUIComboBox'GUI2K4.UT2K4SPTab_Ladder.SPLcbChallenges'

     Begin Object Class=UT2K4LadderButton Name=SPLbtnChampFinal
         WinTop=0.094322
         WinLeft=0.458633
         TabOrder=1
         bBoundToParent=True
         bAcceptsInput=False
         OnClick=UT2K4SPTab_Ladder.OnChampClick
         OnDblClick=UT2K4SPTab_Ladder.onMatchDblClick
         OnKeyEvent=SPLbtnChampFinal.InternalOnKeyEvent
     End Object
     btnChampFinal=UT2K4LadderButton'GUI2K4.UT2K4SPTab_Ladder.SPLbtnChampFinal'

     Begin Object Class=GUIImage Name=SPLimgChampFinal
         Image=Combiner'InterfaceContent.SPMenu.Combiner0'
         ImageStyle=ISTY_Scaled
         WinTop=0.064895
         WinLeft=0.437930
         WinWidth=0.125722
         WinHeight=0.172673
         RenderWeight=0.310000
         bBoundToParent=True
         bVisible=False
     End Object
     imgChampFinal=GUIImage'GUI2K4.UT2K4SPTab_Ladder.SPLimgChampFinal'

     PreviousLadder=-1
     LadderBorderNormal=Texture'2K4Menus.Controls.thinpipe_b'
     LadderBorderCompleted=Texture'2K4Menus.Controls.thinpipe_f'
     LadderBarCompleted=Texture'InterfaceContent.SPMenu.BarHorizontalHi'
     LadderImageCompleted(0)="LadderShots.CTFMoneyShot"
     LadderImageCompleted(1)="LadderShots.BRMoneyShot"
     LadderImageCompleted(2)="LadderShots.DOMMoneyShot"
     LadderImageCompleted(3)="LadderShots.TeamDMMoneyShot"
     LadderImage(0)="LadderShots.CTFShot"
     LadderImage(1)="LadderShots.BRShot"
     LadderImage(2)="LadderShots.DOMShot"
     LadderImage(3)="LadderShots.TeamDMShot"
     msgSelectChal="Select a challenge"
     PanelCaption="Ladder"
}
