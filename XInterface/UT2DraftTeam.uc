// ====================================================================
//  Class:  XInterface.UT2DraftTeam
//  Parent: XInterface.GUIPage
//
//  Draft the team.  Salary stuff commented out for UT2003.
// ====================================================================

class UT2DraftTeam extends UT2K3GUIPage;

var GUIListBox			lboStats, lboTeamStats;
var GUILabel			lblMatchData, lblChoose;
var GUIScrollTextBox	stbPlayerData;
var GUICharacterListTeam cltMyTeam;
var GUICharacterListTeam cltPortrait;
var GUIButton			butDraft, butRelease, butClear, butEnter, butAuto;
var GUIGfxButton		butLeft, butRight;
var GUITitleBar			MyTitleBar, MyHintBar;

var string				ButtonStyleEnabled, ButtonStyleDisabled;
var localized string	ClearConfirmMessage, EnterConfirmMessage, StatsMessage;

var bool bPlaySounds;	// whether to play the announcer/select sounds

function Created()
{
	lblMatchData = GUILabel(Controls[1]);
	stbPlayerData = GUIScrollTextBox(Controls[2]);
	lboStats = GUIListBox(Controls[3]);
	cltMyTeam = GUICharacterListTeam(Controls[4]);
	cltPortrait = GUICharacterListTeam(Controls[6]);
	butDraft = GUIButton(Controls[7]);
	butRelease = GUIButton(Controls[8]);
	butClear = GUIButton(Controls[9]);
	butEnter = GUIButton(Controls[10]);
	butLeft = GUIGfxButton(Controls[11]);
	butRight = GUIGfxButton(Controls[12]);
	lblChoose = GUILabel(Controls[13]);
	lboTeamStats = GUIListBox(Controls[14]);
	MyTitleBar = GUITitleBar(Controls[15]);
	MyHintBar = GUITitleBar(Controls[16]);
	butAuto = GUIButton(Controls[17]);
	OnKeyEvent=MyKeyEvent;
}

// capture escape-hits
function bool MyKeyEvent(out byte Key,out byte State,float delta)
{
	if ( Key == 27 )	// Escape pressed
	{
		return true;
	}
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	MyController.RegisterStyle(class'STY_RosterButton');

	Super.Initcomponent(MyController, MyOwner);
	cltPortrait.InitListInclusive("SP");
	cltPortrait.Find("Gorge");
	cltPortrait.OnChange=CharListChange;
	CharListUpdate(cltPortrait);

	ReloadPortraits();

	butEnter.bVisible = false;
	butEnter.bAcceptsInput = false;


	butDraft.OnClick=ButtonClick;
	butRelease.OnClick=ButtonClick;
	butClear.OnClick=ButtonClick;
	butEnter.OnClick=ButtonClick;
	butLeft.OnClick=ButtonClick;
	butRight.OnClick=ButtonClick;
	butAuto.OnClick=ButtonClick;

	lboStats.List.bAcceptsInput=false;
	lboTeamStats.List.bAcceptsInput=false;

	cltMyTeam.OnChange=CharListChange;
	cltMyTeam.Index = -1;
}

function ReloadPortraits()
{
	local GameProfile GP;
	local array<xUtil.PlayerRecord> PlayerRecords;
	local int i;

	GP = PlayerOwner().Level.Game.CurrentGameProfile;
	if (GP != None)
	{
		for ( i=0; i<GP.PlayerTeam.Length; i++ ) {
			PlayerRecords[i] = class'xUtil'.static.FindPlayerRecord(GP.PlayerTeam[i]);
			//Log("UT2DraftTeam::ReloadPortraits scanning"@GP.PlayerTeam[i]);
		}

		cltMyTeam.ResetList(PlayerRecords, GP.PlayerTeam.Length);
	}
}


function CharListUpdate(GUIComponent Sender)
{
	local GUICharacterList GCL;
	local xUtil.PlayerRecord PR;
	//local GameProfile GP;
	local string str;

	GCL = cltPortrait;
	PR = GCL.GetRecord();

	if ( bPlaySounds )
		PlayerOwner().ClientPlaySound(GCL.GetSound(),,,SLOT_Interface);

	str = Mid(PR.TextName, Max(InStr(PR.TextName, ".")+1, 0));
	stbPlayerData.SetContent(Controller.LoadDecoText("xPlayers", str));

	BuildStats ( PR, lboStats, lboTeamStats );
	//lblPlayerSalary.Caption = ""$class'xUtil'.static.GetSalaryFor(PR);
	//GP = PlayerOwner().Level.Game.CurrentGameProfile;
	//lblTeamSalary.Caption = ""$class'xUtil'.static.GetTeamSalaryFor(GP);
	//lblTeamSalaryCap.Caption = ""$GP.SalaryCap;

	//if (int(lblTeamSalaryCap.Caption) > int(lblTeamSalary.Caption) + int(lblPlayerSalary.Caption)) {
	//	Log("SINGLEPLAYER affordable.  teamfull = "$IsTeamFull());
	UpdateDraftable (true);
	/*} else {
	//	Log("SINGLEPLAYER not affordable. ");
	//	UpdateDraftable(false);
	//}

	lblPlayerSalary.Caption = "Salary:"@lblPlayerSalary.Caption$"M";
	lblTeamSalary.Caption = "Team Salary:"@lblTeamSalary.Caption$"M";
	lblTeamSalaryCap.Caption = "Salary Cap:"@lblTeamSalaryCap.Caption$"M";
	*/

}

function CharListChange(GUIComponent Sender)
{
	Super.OnChange(Sender);
	if ( Sender == cltMyTeam )
	{
		if ( cltMyTeam.GetName() == "" )
		{
			cltMyTeam.Index = -1;
		}
		else
		{
			cltPortrait.Find(cltMyTeam.GetName());
			CharListUpdate(Sender);
		}
	}
}

function bool IsOnTeam(string botname)
{
	local int i;
	local GameProfile GP;

	if ( botname == "" )
	{
		return false;
	}

	GP = PlayerOwner().Level.Game.CurrentGameProfile;
	if ( GP != none )
	{
		for ( i=0; i<GP.TEAM_SIZE; i++ )
		{
			if ( GP.PlayerTeam[i] ~= botname )
			{
				return true;
			}
		}
	}
	return false;
}

function bool IsTeamFull()
{
	local GameProfile GP;
	local int i;

	GP = PlayerOwner().Level.Game.CurrentGameProfile;
	if ( GP.PlayerTeam.Length < GP.TEAM_SIZE )
	{
		return false;
	}

	for ( i=0; i<GP.TEAM_SIZE; i++ )
	{
		if ( GP.PlayerTeam[i] == "" )
		{
			return false;
		}
	}

	return true;
}

// set one of the draft/release buttons effective
// depends upon various salary labels being up-to-date
function UpdateDraftable(bool bAffordable)
{
	local bool bOnTeam;
	local bool bCanDraft;

	bCanDraft = bAffordable && !IsTeamFull();

	// check if he's on team already
	bOnTeam = IsOnTeam(cltPortrait.GetName());
	butDraft.bAcceptsInput = !bOnTeam && bCanDraft;
	butRelease.bAcceptsInput = bOnTeam;

	butDraft.bVisible = butDraft.bAcceptsInput;
	butRelease.bVisible = butRelease.bAcceptsInput;
/*
	if (butDraft.bAcceptsInput)
	{
		butDraft.StyleName=ButtonStyleEnabled;
	}
	else
	{
		butDraft.StyleName=ButtonStyleDisabled;
	}
	if (butRelease.bAcceptsInput)
	{
		butRelease.StyleName=ButtonStyleEnabled;
	}
	else
	{
		butRelease.StyleName=ButtonStyleDisabled;
	}
*/
}

function BuildStats ( out xUtil.PlayerRecord PR, GUIListBox charbox, GUIListBox teambox )
{
	local string str;
	local GameProfile GP;
	GP = PlayerOwner().Level.Game.CurrentGameProfile;

	charbox.List.Clear();
	str = PR.DefaultName;
	charbox.List.Add(str);
	str = class'xUtil'.static.GetFavoriteWeaponFor(PR);
	charbox.List.Add(str);
	str = class'xUtil'.Default.AccuracyString@class'xUtil'.static.AccuracyRating(PR);
	charbox.List.Add(str);
	str = class'xUtil'.Default.AggressivenessString@class'xUtil'.static.AggressivenessRating(PR);
	charbox.List.Add(str);
	str = class'xUtil'.Default.AgilityString@class'xUtil'.static.AgilityRating(PR);
	charbox.List.Add(str);
	str = class'xUtil'.Default.TacticsString@class'xUtil'.static.TacticsRating(PR);
	charbox.List.Add(str);

	// team stats
	teambox.List.Clear();
	str = GP.TeamName@StatsMessage;
	teambox.List.Add(str);
	str = class'xUtil'.Default.AccuracyString@class'xUtil'.static.TeamAccuracyRating(GP);
	teambox.List.Add(str);
	str = class'xUtil'.Default.AggressivenessString@class'xUtil'.static.TeamAggressivenessRating(GP);
	teambox.List.Add(str);
	str = class'xUtil'.Default.AgilityString@class'xUtil'.static.TeamAgilityRating(GP);
	teambox.List.Add(str);
	str = class'xUtil'.Default.TacticsString@class'xUtil'.static.TeamTacticsRating(GP);
	teambox.List.Add(str);
}

// automatically fills the remainder of the team with random selections
function AutoFillTeam()
{
	local int nextDraft;
	local bool oldbPlaySounds;
	local GameProfile GP;
	local int listsize, i, listoffset;

	GP = PlayerOwner().Level.Game.CurrentGameProfile;
	if ( GP == none ) // pretty unlikely
		return;

	oldbPlaySounds = bPlaySounds;
	listsize = cltPortrait.PlayerList.Length;
	for ( nextDraft = 0; nextDraft < 7; nextDraft++ )
	{
		if ( GP.PlayerTeam[nextDraft] != "" )
			continue;

		// this is slow but it keeps the list happy
		listoffset = cltPortrait.Index + Rand(listsize-1);
		listoffset = listoffset % listsize;
		for ( i=0; i<listoffset; i++)
			cltPortrait.ScrollRight();

		while ( IsOnTeam(cltPortrait.GetName()) )
			cltPortrait.ScrollRight();

		GP.PlayerTeam[nextDraft] = cltPortrait.GetName();
	}
	bPlaySounds = oldbPlaySounds;

}

function bool ButtonClick(GUIComponent Sender)
{
	local GameProfile GP;
	local GUIQuestionPage Page;
	local bool oldbPlaySounds;

	GP = PlayerOwner().Level.Game.CurrentGameProfile;
	oldbPlaySounds = bPlaySounds;  // changed temporarily, only by the draft and release buttons

	if ( Sender==butDraft )
	{
		// should only be called if player is affordable and not on team
		bPlaySounds = false;
		GP.AddTeammate( cltPortrait.GetName() );
	}
	else if ( Sender==butRelease )
	{
		bPlaySounds = false;
		GP.ReleaseTeammate( cltPortrait.GetName() );
		cltMyTeam.Index = -1;
	}
	else if ( Sender==butClear )
	{
		// check if they're certain they want to clear their entire roster
		if (Controller.OpenMenu("XInterface.GUIQuestionPage"))
		{
			Page = GUIQuestionPage(Controller.ActivePage);
			Page.SetupQuestion(ClearConfirmMessage, QBTN_YesNo, QBTN_No);
			Page.OnButtonClick = ClearConfirm;
		}
		return true;
	}
	else if ( Sender==butEnter )
	{
		// check if they're certain they want to play with this team
		if (Controller.OpenMenu("XInterface.GUIQuestionPage"))
		{
			Page = GUIQuestionPage(Controller.ActivePage);
			Page.SetupQuestion(EnterConfirmMessage, QBTN_YesNo, QBTN_No);
			Page.OnButtonClick = EnterConfirm;
		}
		return true;
	}
	else if ( Sender==butLeft )
	{
		cltPortrait.ScrollLeft();
	}
	else if ( Sender==butRight )
	{
		cltPortrait.ScrollRight();
	}
	else if ( Sender==butAuto )
	{
		AutoFillTeam();
	}

	FinishButtonClick();
	bPlaySounds = oldbPlaySounds;

	return true;
}

event ChangeHint(string NewHint)
{
	MyHintBar.SetCaption(NewHint);
}


// broken out of ButtonClick for the ClearConfirm function
function FinishButtonClick()
{
	butEnter.bVisible = IsTeamFull();
	butEnter.bAcceptsInput = IsTeamFull();

	ReloadPortraits();
	CharListUpdate(cltPortrait);
}

// called when the clear-roster dialog pops up
function ClearConfirm(byte bButton)
{
	if (bButton == QBTN_Yes)
	{
		PlayerOwner().Level.Game.CurrentGameProfile.ClearTeammates();
		FinishButtonClick();
	}
}

// called when a button on the 'enter tourney' dialog is pressed
function EnterConfirm(byte bButton)
{
	if (bButton == QBTN_Yes)
	{
		PlayerOwner().Level.Game.SavePackage(PlayerOwner().Level.Game.CurrentGameProfile.PackageName);
		Controller.CloseMenu();
	}
}

defaultproperties
{
     ButtonStyleEnabled="RoundButton"
     ButtonStyleDisabled="NoBackground"
     ClearConfirmMessage="This action will empty your current roster.  Are you sure?"
     EnterConfirmMessage="Are you ready to enter the tournament?"
     StatsMessage="Stats"
     bPlaySounds=True
     Background=Texture'InterfaceContent.Backgrounds.bg10'
     Begin Object Class=GUIImage Name=SPDTRosterBK0
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.130833
         WinLeft=0.586875
         WinWidth=0.377617
         WinHeight=0.598438
     End Object
     Controls(0)=GUIImage'XInterface.UT2DraftTeam.SPDTRosterBK0'

     Begin Object Class=GUILabel Name=SPDTMatchData
         Caption="No Game Profile => No MatchData"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2LargeFont"
         WinTop=-0.120000
         WinLeft=0.100000
         WinWidth=0.800000
         WinHeight=0.100000
     End Object
     Controls(1)=GUILabel'XInterface.UT2DraftTeam.SPDTMatchData'

     Begin Object Class=GUIScrollTextBox Name=SPDTCharData
         CharDelay=0.040000
         EOLDelay=0.250000
         OnCreateComponent=SPDTCharData.InternalOnCreateComponent
         Hint="Team members profile"
         WinTop=0.129167
         WinLeft=0.024063
         WinWidth=0.520000
         WinHeight=0.359687
         bNeverFocus=True
     End Object
     Controls(2)=GUIScrollTextBox'XInterface.UT2DraftTeam.SPDTCharData'

     Begin Object Class=GUIListBox Name=SPDTCharStats
         OnCreateComponent=SPDTCharStats.InternalOnCreateComponent
         WinTop=0.491249
         WinLeft=0.024063
         WinWidth=0.520000
         WinHeight=0.237813
         bAcceptsInput=False
         bNeverFocus=True
     End Object
     Controls(3)=GUIListBox'XInterface.UT2DraftTeam.SPDTCharStats'

     Begin Object Class=GUICharacterListTeam Name=SPDTRosterCharList
         bLocked=True
         DefaultPortrait=TexPanner'InterfaceContent.Menu.pEmptySlot'
         bFillBounds=True
         bAllowSelectEmpty=False
         FixedItemsPerPage=7
         StyleName="CharButton"
         Hint="Choose a teammate to play in the next match"
         WinTop=0.750000
         WinLeft=0.004688
         WinWidth=0.670315
         WinHeight=0.170000
         OnClick=SPDTRosterCharList.InternalOnClick
         OnRightClick=SPDTRosterCharList.InternalOnRightClick
         OnMousePressed=SPDTRosterCharList.InternalOnMousePressed
         OnMouseRelease=SPDTRosterCharList.InternalOnMouseRelease
         OnKeyEvent=SPDTRosterCharList.InternalOnKeyEvent
         OnBeginDrag=SPDTRosterCharList.InternalOnBeginDrag
         OnEndDrag=SPDTRosterCharList.InternalOnEndDrag
         OnDragDrop=SPDTRosterCharList.InternalOnDragDrop
         OnDragEnter=SPDTRosterCharList.InternalOnDragEnter
         OnDragLeave=SPDTRosterCharList.InternalOnDragLeave
         OnDragOver=SPDTRosterCharList.InternalOnDragOver
     End Object
     Controls(4)=GUICharacterListTeam'XInterface.UT2DraftTeam.SPDTRosterCharList'

     Begin Object Class=GUIImage Name=SPDTCharListBox
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.741667
         WinLeft=0.007813
         WinWidth=0.639846
         WinHeight=0.185625
     End Object
     Controls(5)=GUIImage'XInterface.UT2DraftTeam.SPDTCharListBox'

     Begin Object Class=GUICharacterListTeam Name=SPDTPortrait
         DefaultPortrait=TexPanner'InterfaceContent.Menu.pEmptySlot'
         bFillBounds=True
         FixedItemsPerPage=1
         StyleName="CharButton"
         Hint="Select teammate"
         WinTop=0.190313
         WinLeft=0.687500
         WinWidth=0.133300
         WinHeight=0.400000
         OnClick=SPDTPortrait.InternalOnClick
         OnRightClick=SPDTPortrait.InternalOnRightClick
         OnMousePressed=SPDTPortrait.InternalOnMousePressed
         OnMouseRelease=SPDTPortrait.InternalOnMouseRelease
         OnKeyEvent=SPDTPortrait.InternalOnKeyEvent
         OnBeginDrag=SPDTPortrait.InternalOnBeginDrag
         OnEndDrag=SPDTPortrait.InternalOnEndDrag
         OnDragDrop=SPDTPortrait.InternalOnDragDrop
         OnDragEnter=SPDTPortrait.InternalOnDragEnter
         OnDragLeave=SPDTPortrait.InternalOnDragLeave
         OnDragOver=SPDTPortrait.InternalOnDragOver
     End Object
     Controls(6)=GUICharacterListTeam'XInterface.UT2DraftTeam.SPDTPortrait'

     Begin Object Class=GUIButton Name=SPDTDraft
         Caption="DRAFT"
         Hint="Add this character to your team"
         WinTop=0.602917
         WinLeft=0.620626
         WinWidth=0.132812
         WinHeight=0.055000
         bFocusOnWatch=True
         OnKeyEvent=SPDTDraft.InternalOnKeyEvent
     End Object
     Controls(7)=GUIButton'XInterface.UT2DraftTeam.SPDTDraft'

     Begin Object Class=GUIButton Name=SPDTRelease
         Caption="RELEASE"
         Hint="Remove this character from your team"
         WinTop=0.602917
         WinLeft=0.804998
         WinWidth=0.132812
         WinHeight=0.055000
         bFocusOnWatch=True
         OnKeyEvent=SPDTRelease.InternalOnKeyEvent
     End Object
     Controls(8)=GUIButton'XInterface.UT2DraftTeam.SPDTRelease'

     Begin Object Class=GUIButton Name=SPDTClear
         Caption="CLEAR"
         StyleName="SquareMenuButton"
         Hint="Clear your team roster"
         WinTop=0.930000
         WinWidth=0.120000
         WinHeight=0.055000
         bFocusOnWatch=True
         OnKeyEvent=SPDTClear.InternalOnKeyEvent
     End Object
     Controls(9)=GUIButton'XInterface.UT2DraftTeam.SPDTClear'

     Begin Object Class=GUIButton Name=SPDTEnter
         Caption="PLAY"
         StyleName="SquareMenuButton"
         Hint="Enter tournament with this team"
         WinTop=0.930000
         WinLeft=0.880000
         WinWidth=0.120000
         WinHeight=0.055000
         bFocusOnWatch=True
         OnKeyEvent=SPDTEnter.InternalOnKeyEvent
     End Object
     Controls(10)=GUIButton'XInterface.UT2DraftTeam.SPDTEnter'

     Begin Object Class=GUIGFXButton Name=SPDTPicLeft
         Graphic=FinalBlend'InterfaceContent.Menu.fbArrowLeft'
         Position=ICP_Scaled
         Hint="Select teammate"
         WinTop=0.335833
         WinLeft=0.601563
         WinWidth=0.080000
         WinHeight=0.080000
         bFocusOnWatch=True
         OnKeyEvent=SPDTPicLeft.InternalOnKeyEvent
     End Object
     Controls(11)=GUIGFXButton'XInterface.UT2DraftTeam.SPDTPicLeft'

     Begin Object Class=GUIGFXButton Name=SPDTPicRight
         Graphic=FinalBlend'InterfaceContent.Menu.fbArrowRight'
         Position=ICP_Scaled
         Hint="Select teammate"
         WinTop=0.335833
         WinLeft=0.870312
         WinWidth=0.080000
         WinHeight=0.080000
         bFocusOnWatch=True
         OnKeyEvent=SPDTPicRight.InternalOnKeyEvent
     End Object
     Controls(12)=GUIGFXButton'XInterface.UT2DraftTeam.SPDTPicRight'

     Begin Object Class=GUILabel Name=SPDTLblChoose
         Caption="Choose Teammate"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2HeaderFont"
         WinTop=0.122084
         WinLeft=0.592498
         WinWidth=0.368750
         WinHeight=0.079687
     End Object
     Controls(13)=GUILabel'XInterface.UT2DraftTeam.SPDTLblChoose'

     Begin Object Class=GUIListBox Name=SPDTTeamStats
         OnCreateComponent=SPDTTeamStats.InternalOnCreateComponent
         WinTop=0.739166
         WinLeft=0.654063
         WinWidth=0.338750
         WinHeight=0.189062
         bAcceptsInput=False
         bNeverFocus=True
     End Object
     Controls(14)=GUIListBox'XInterface.UT2DraftTeam.SPDTTeamStats'

     Begin Object Class=GUITitleBar Name=SPDTHeader
         Effect=FinalBlend'InterfaceContent.Menu.CO_Final'
         Caption="Single Player | Draft your team"
         StyleName="Header"
         WinTop=0.036406
         WinHeight=46.000000
     End Object
     Controls(15)=GUITitleBar'XInterface.UT2DraftTeam.SPDTHeader'

     Begin Object Class=GUITitleBar Name=SPDTHints
         bUseTextHeight=False
         StyleName="Footer"
         WinTop=0.930000
         WinLeft=0.120000
         WinWidth=0.760000
         WinHeight=0.055000
     End Object
     Controls(16)=GUITitleBar'XInterface.UT2DraftTeam.SPDTHints'

     Begin Object Class=GUIButton Name=SPDTAuto
         Caption="AUTO FILL"
         Hint="Automatically fill your team"
         WinTop=0.666667
         WinLeft=0.681245
         WinWidth=0.187500
         WinHeight=0.055000
         bFocusOnWatch=True
         OnKeyEvent=SPDTAuto.InternalOnKeyEvent
     End Object
     Controls(17)=GUIButton'XInterface.UT2DraftTeam.SPDTAuto'

     WinHeight=1.000000
     bAcceptsInput=False
}
