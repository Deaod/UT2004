// ====================================================================
//  Class:  XInterface.Tab_SPRoster
//  Parent: XInterface.GUITabPanel
//  Single player menu for fussing with the player roster.  Choose
//  lineup and give orders.
//  author:  capps 8/24/02
// ====================================================================

class Tab_SPRoster extends Tab_SPPanelBase;

const MatesCount = 4;
const MatesBase = 8;
const MatesCtrls = 5;

var array<GUIPanel>		pnlMates;		// 1 Panel per mate
var array<GUIGfxButton>	imgMates;		// TeamMate Image button
var array<GUILabel>		lblMates;		// TeamMate Name display
var array<GUIComboBox>	cboMates;		// TeamMate Fight Position
var array<GUIButton>	btnMates;		// TeamMate Assign Button
var array<GUILabel>		lblNA;		// 'spot not available'
var GUIListBox			lboStats, lboTeamStats;
var GUIImage			imgPortrait;
var GUILabel			lblMatchData;
var GUIScrollTextBox	stbPlayerData;
var GUICharacterListTeam cltMyTeam;

var localized string	MessageNoInfo, PreStatsMessage, PostStatsMessage;


function Created()
{
local GUIPanel Pnl;
local int i;

	for (i = 0; i<MatesCount; i++)
	{
		Pnl = GUIPanel(Controls[i+MatesBase]);
		pnlMates[i] = Pnl;
		imgMates[i] = GUIGfxButton(Pnl.Controls[1]);
		lblMates[i] = GUILabel(Pnl.Controls[2]);
		cboMates[i] = GUIComboBox(Pnl.Controls[3]);
		btnMates[i] = GUIButton(Pnl.Controls[4]);
		lblNA[i]	= GUILabel(Pnl.Controls[5]);
	}
	imgPortrait = GUIImage(Controls[1]);
	lblMatchData = GUILabel(Controls[3]);
	stbPlayerData = GUIScrollTextBox(Controls[4]);
	lboStats = GUIListBox(Controls[5]);
	cltMyTeam = GUICharacterListTeam(Controls[6]);
	lboTeamStats = GUIListBox(Controls[12]);
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
local int i, j;

	MyController.RegisterStyle(class'STY_RosterButton');

	Super.Initcomponent(MyController, MyOwner);

	lboStats.List.bAcceptsInput = false;
	lboTeamStats.List.bAcceptsInput = false;

	for (i = 0; i<MatesCount; i++)
	{
		cboMates[i].OnChange=none;
		cboMates[i].ReadOnly(true);
		for (j = 0; j < class'GameProfile'.static.GetNumPositions(); j++)
			cboMates[i].AddItem(class'GameProfile'.static.TextPositionDescription(j));
		cboMates[i].OnChange=PositionChange;
		imgMates[i].OnClick=ClickLineup;
	}
	OnProfileUpdated();
}

// if no gameprofile loaded, or no team, can't show profile
function bool CanShowPanel ()
{
	if ( GetProfile() == none )
		return false;

	if ( GetProfile().PlayerTeam[0] == "" )		// indicates hasn't drafted team
		return false;

	return Super.CanShowPanel();
}

function OnProfileUpdated()
{
	ReloadPortraits();
	ChangePortraits();
	UpdateMatchInfo();
	BuildTeamStats(lboTeamStats);
}

// Called when Match has changed
function OnMatchUpdated(int iLadder, int iMatch)
{
	UpdateMatchInfo();
}

// if user clicks on a lineup picture, change the portrait/description
function bool ClickLineup(GUIComponent Sender) {

	local int i, teammate;

	teammate = -1;
	for (i=0; i< MatesCount; i++) 
	{
		if (Sender == imgMates[i])
		{
			teammate = i;
			break;
		}
	}

	if (teammate < 0)
		return false;

	cltMyTeam.Find(lblMates[teammate].Caption);

	ChangePortraits();

	return true;
}

function bool FixLineup(GUIComponent Sender)
{
	if (GetProfile() != None)
	{
		GetProfile().SetLineup(Sender.Tag, cltMyTeam.Index);
		if (!PlayerOwner().Level.Game.SavePackage(GetProfile().PackageName))
		{
			Log("SINGLEPLAYER couldn't save profile package!");
		}
		UpdateMatchInfo();
	}
	return true;
}

// update the match data
// includes removing characters when match doesn't need 'em
function UpdateMatchInfo()
{
local GameProfile GP;
local int nummates, i;

	GP = GetProfile();
	if ( GP == none )
		return;

	lblMatchData.Caption = GP.GetMatchDescription();
	nummates = GP.GetNumTeammatesForMatch();

	for (i = 0; i<MatesCount; i++)
	{
		imgMates[i].bVisible = (nummates > i);
		lblMates[i].bVisible = (nummates > i);
		cboMates[i].bVisible = (nummates > i);
		lblNA[i].bVisible = !(nummates > i);
		btnMates[i].bVisible = false;
		
		// Dont update unnecessarily
		if (nummates > i)
		{
			imgMates[i].Graphic = cltMyTeam.PlayerList[GP.PlayerLineup[i]].Portrait;
			lblMates[i].Caption = cltMyTeam.PlayerList[GP.PlayerLineup[i]].DefaultName;
			cboMates[i].OnChange = None;
			cboMates[i].SetText(GP.GetPositionDescription(GP.PlayerLineup[i]));
			//Log("Mate "$i$" named "$GP.PlayerTeam[GP.PlayerLineup[i]]$" has description "$GP.GetPositionDescription(GP.PlayerLineup[i]));
			cboMates[i].OnChange = PositionChange;
			
			// See if we should enable the assign button
			if (cltMyTeam.Index != -1 && cltMyTeam.Index != GP.PlayerLineup[i])
			{
				btnMates[i].bVisible = true;
				btnMates[i].OnChange = PositionChange;
				imgMates[i].WinLeft = btnMates[i].WinLeft + btnMates[i].WinWidth * 1.35;
			}
			else
				imgMates[i].WinLeft = btnMates[i].WinLeft;
		}
	}
}

function ReloadPortraits()
{
local GameProfile GP;
local array<xUtil.PlayerRecord> PlayerRecords;
local int i;

	GP = GetProfile();
	if (GP != None)
	{
		for ( i=0; i<GP.PlayerTeam.Length; i++ )
		{
			PlayerRecords[i] = class'xUtil'.static.FindPlayerRecord(GP.PlayerTeam[i]);
		}
		cltMyTeam.ResetList(PlayerRecords, GP.PlayerTeam.Length);
	}
}

function CharListClick(GUIComponent Sender)
{
	ChangePortraits();
	UpdateMatchInfo();
}

function ChangePortraits(/*GUIComponent Sender*/)
{
local GameProfile GP;
//local int i;
local string str;

	GP = GetProfile();
	if ( GP == none ) {
		//Log ("Tab_SPRoster::ChangePortraits could not find game profile.");
		return;
	}

	if ( cltMyTeam.Index < 0  && cltMyteam.PlayerList.Length > 0 )
		cltMyTeam.SetIndex(0);

	if (cltMyTeam.Index != -1)
	{
		// selected-bot portrait
		imgPortrait.Image = cltMyTeam.GetPortrait();

		// selected-bot sound, only if this tab is active
		if (MyButton != none && MyButton.bActive){
			PlayerOwner().ClientPlaySound(cltMyTeam.GetSound(),,,SLOT_Interface);
		}

		// selected-bot decotext
		str = Mid(cltMyTeam.PlayerList[(cltMyTeam.Index)].TextName, Max(InStr(cltMyTeam.PlayerList[(cltMyTeam.Index)].TextName, ".")+1, 0));

		if (str == "")
			str = MessageNoInfo;

		stbPlayerData.SetContent(Controller.LoadDecoText("xPlayers", str));

		// selected-bot stats
		self.BuildCharStats(cltMyTeam.PlayerList[cltMyTeam.Index], lboStats);
	}
	else
	{
		// Clear the image
		imgPortrait.Image = None;
		// clear the decotext
		stbPlayerData.SetContent (MessageNoInfo);
		// Clear the stats listbox
		lboStats.List.Clear();
	}
}

function BuildCharStats ( out xUtil.PlayerRecord PR, GUIListBox box )
{
	local string str;
	box.List.Clear();
	str = class'xUtil'.static.GetFavoriteWeaponFor(PR);
	box.List.Add(str);
	str = class'xUtil'.Default.AccuracyString@class'xUtil'.static.AccuracyRating(PR);
	box.List.Add(str);
	str = class'xUtil'.Default.AggressivenessString@class'xUtil'.static.AggressivenessRating(PR);
	box.List.Add(str);
	str = class'xUtil'.Default.AgilityString@class'xUtil'.static.AgilityRating(PR);
	box.List.Add(str);
	str = class'xUtil'.Default.TacticsString@class'xUtil'.static.TacticsRating(PR);
	box.List.Add(str);
	box.List.Index = -1;	// to avoid highlight of first line
	//str = "Salary:"@class'xUtil'.static.GetSalaryFor(PR)$"M";
	//box.List.Add(str);
}

function BuildTeamStats ( GUIListBox teambox )
{
	local string str;
	local GameProfile GP;
	GP = GetProfile();
	if ( GP == none ) 
		return;
	// team stats
	teambox.List.Clear();
	str = PreStatsMessage@GP.TeamName@PostStatsMessage;
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

// update a position 
function PositionChange(GUIComponent Sender) 
{
	local int lineupnum, i;
	local string posn;

	lineupnum = -1;
	for ( i = 0; i < 4; i++ ) 
	{
		if ( Sender == cboMates[i] ) 
		{
			lineupnum = i;
			break;
		}
	}

	posn = GUIComboBox(Sender).GetText();
	if (GetProfile() != None)
	{
		GetProfile().SetPosition(lineupnum, posn);
		if (!PlayerOwner().Level.Game.SavePackage(GetProfile().PackageName))
		{
			Log("SINGLEPLAYER couldn't save profile package!");
		}
	}
}

defaultproperties
{
     MessageNoInfo="No information available."
     PostStatsMessage="Stats"
     bFillHeight=True
     Begin Object Class=GUIImage Name=SPRosterBK0
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.015000
         WinLeft=0.007187
         WinWidth=0.565117
         WinHeight=0.700000
     End Object
     Controls(0)=GUIImage'XInterface.Tab_SPRoster.SPRosterBK0'

     Begin Object Class=GUIImage Name=SPRosterPortrait
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         WinTop=0.031077
         WinLeft=0.016562
         WinWidth=0.130957
         WinHeight=0.395000
     End Object
     Controls(1)=GUIImage'XInterface.Tab_SPRoster.SPRosterPortrait'

     Begin Object Class=GUIImage Name=SPRosterPortraitBorder
         Image=Texture'InterfaceContent.Menu.BorderBoxA1'
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.030000
         WinLeft=0.015000
         WinWidth=0.133300
         WinHeight=0.400000
     End Object
     Controls(2)=GUIImage'XInterface.Tab_SPRoster.SPRosterPortraitBorder'

     Begin Object Class=GUILabel Name=SPMatchData
         Caption="No Game Profile => No MatchData"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2LargeFont"
         WinTop=-0.120000
         WinLeft=0.100000
         WinWidth=0.800000
         WinHeight=0.100000
         bVisible=False
     End Object
     Controls(3)=GUILabel'XInterface.Tab_SPRoster.SPMatchData'

     Begin Object Class=GUIScrollTextBox Name=SPCharData
         CharDelay=0.040000
         EOLDelay=0.250000
         OnCreateComponent=SPCharData.InternalOnCreateComponent
         Hint="Team members profile"
         WinTop=0.030000
         WinLeft=0.150000
         WinWidth=0.412500
         WinHeight=0.400000
         bNeverFocus=True
     End Object
     Controls(4)=GUIScrollTextBox'XInterface.Tab_SPRoster.SPCharData'

     Begin Object Class=GUIListBox Name=SPCharStats
         OnCreateComponent=SPCharStats.InternalOnCreateComponent
         WinTop=0.440000
         WinLeft=0.015000
         WinWidth=0.510000
         WinHeight=0.267500
         bAcceptsInput=False
         bNeverFocus=True
     End Object
     Controls(5)=GUIListBox'XInterface.Tab_SPRoster.SPCharStats'

     Begin Object Class=GUICharacterListTeam Name=SPRosterCharList
         bLocked=True
         DefaultPortrait=TexPanner'InterfaceContent.Menu.pEmptySlot'
         bFillBounds=True
         bAllowSelectEmpty=False
         FixedItemsPerPage=7
         StyleName="CharButton"
         Hint="Choose a teammate to play in the next match"
         WinTop=0.730000
         WinLeft=0.004688
         WinWidth=0.670315
         WinHeight=0.170000
         OnClick=SPRosterCharList.InternalOnClick
         OnRightClick=SPRosterCharList.InternalOnRightClick
         OnMousePressed=SPRosterCharList.InternalOnMousePressed
         OnMouseRelease=SPRosterCharList.InternalOnMouseRelease
         OnChange=Tab_SPRoster.CharListClick
         OnKeyEvent=SPRosterCharList.InternalOnKeyEvent
         OnBeginDrag=SPRosterCharList.InternalOnBeginDrag
         OnEndDrag=SPRosterCharList.InternalOnEndDrag
         OnDragDrop=SPRosterCharList.InternalOnDragDrop
         OnDragEnter=SPRosterCharList.InternalOnDragEnter
         OnDragLeave=SPRosterCharList.InternalOnDragLeave
         OnDragOver=SPRosterCharList.InternalOnDragOver
     End Object
     Controls(6)=GUICharacterListTeam'XInterface.Tab_SPRoster.SPRosterCharList'

     Begin Object Class=GUIImage Name=SPCharListBox
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.722000
         WinLeft=0.006836
         WinWidth=0.622268
         WinHeight=0.186797
     End Object
     Controls(7)=GUIImage'XInterface.Tab_SPRoster.SPCharListBox'

     Begin Object Class=GUIPanel Name=pnlMates1
         Begin Object Class=GUIImage Name=Mate1Back
             Image=Texture'InterfaceContent.Menu.BorderBoxD'
             ImageColor=(A=160)
             ImageStyle=ISTY_Stretched
             WinHeight=1.000000
             Tag=0
         End Object
         Controls(0)=GUIImage'XInterface.Tab_SPRoster.Mate1Back'

         Begin Object Class=GUIGFXButton Name=imgMate1
             Graphic=Texture'InterfaceContent.Menu.BorderBoxD'
             Position=ICP_Scaled
             WinTop=0.052442
             WinLeft=0.018244
             WinWidth=0.140000
             WinHeight=0.896118
             OnKeyEvent=imgMate1.InternalOnKeyEvent
         End Object
         Controls(1)=GUIGFXButton'XInterface.Tab_SPRoster.imgMate1'

         Begin Object Class=GUILabel Name=lblMate1
             Caption="Name"
             TextAlign=TXTA_Center
             TextColor=(B=255,G=255,R=255)
             TextFont="UT2SmallFont"
             WinTop=0.249487
             WinLeft=0.174012
             WinWidth=0.797917
             WinHeight=0.213511
         End Object
         Controls(2)=GUILabel'XInterface.Tab_SPRoster.lblMate1'

         Begin Object Class=GUIComboBox Name=cboMate1
             Hint="Set starting position - change with voice menu during match"
             WinTop=0.567351
             WinLeft=0.323564
             WinWidth=0.554010
             WinHeight=0.234660
             OnChange=Tab_SPRoster.PositionChange
             OnKeyEvent=cboMate1.InternalOnKeyEvent
         End Object
         Controls(3)=GUIComboBox'XInterface.Tab_SPRoster.cboMate1'

         Begin Object Class=GUIGFXButton Name=btnMate1
             Graphic=Texture'InterfaceContent.SPMenu.YellowArrowVBand'
             Position=ICP_Scaled
             bClientBound=True
             StyleName="RosterButton"
             Hint="Assign the selected team member to this roster"
             WinTop=0.046398
             WinLeft=0.012050
             WinWidth=0.058350
             WinHeight=0.901195
             Tag=0
             OnClick=Tab_SPRoster.FixLineup
             OnKeyEvent=btnMate1.InternalOnKeyEvent
         End Object
         Controls(4)=GUIGFXButton'XInterface.Tab_SPRoster.btnMate1'

         Begin Object Class=GUILabel Name=lblNA1
             Caption="SLOT NOT AVAILABLE"
             TextAlign=TXTA_Center
             TextColor=(B=255,G=255,R=255)
             TextFont="UT2SmallFont"
             WinTop=0.420000
             WinHeight=0.210000
         End Object
         Controls(5)=GUILabel'XInterface.Tab_SPRoster.lblNA1'

         StyleName="NoBackground"
         WinTop=0.015000
         WinLeft=0.590000
         WinWidth=0.400000
         WinHeight=0.175000
     End Object
     Controls(8)=GUIPanel'XInterface.Tab_SPRoster.pnlMates1'

     Begin Object Class=GUIPanel Name=pnlMates2
         Begin Object Class=GUIImage Name=Mate2Back
             Image=Texture'InterfaceContent.Menu.BorderBoxD'
             ImageColor=(A=160)
             ImageStyle=ISTY_Stretched
             WinHeight=1.000000
             Tag=1
         End Object
         Controls(0)=GUIImage'XInterface.Tab_SPRoster.Mate2Back'

         Begin Object Class=GUIGFXButton Name=imgMate2
             Graphic=Texture'InterfaceContent.Menu.BorderBoxD'
             Position=ICP_Scaled
             WinTop=0.052442
             WinLeft=0.018244
             WinWidth=0.140000
             WinHeight=0.896118
             OnKeyEvent=imgMate2.InternalOnKeyEvent
         End Object
         Controls(1)=GUIGFXButton'XInterface.Tab_SPRoster.imgMate2'

         Begin Object Class=GUILabel Name=lblMate2
             Caption="Name"
             TextAlign=TXTA_Center
             TextColor=(B=255,G=255,R=255)
             TextFont="UT2SmallFont"
             WinTop=0.249487
             WinLeft=0.174012
             WinWidth=0.797917
             WinHeight=0.213511
         End Object
         Controls(2)=GUILabel'XInterface.Tab_SPRoster.lblMate2'

         Begin Object Class=GUIComboBox Name=cboMate2
             Hint="Set starting position - change with voice menu during match"
             WinTop=0.567351
             WinLeft=0.323564
             WinWidth=0.554010
             WinHeight=0.234660
             OnChange=Tab_SPRoster.PositionChange
             OnKeyEvent=cboMate2.InternalOnKeyEvent
         End Object
         Controls(3)=GUIComboBox'XInterface.Tab_SPRoster.cboMate2'

         Begin Object Class=GUIGFXButton Name=btnMate2
             Graphic=Texture'InterfaceContent.SPMenu.YellowArrowVBand'
             Position=ICP_Scaled
             bClientBound=True
             StyleName="RosterButton"
             Hint="Assign the selected team member to this roster"
             WinTop=0.046398
             WinLeft=0.012050
             WinWidth=0.058350
             WinHeight=0.901195
             Tag=1
             OnClick=Tab_SPRoster.FixLineup
             OnKeyEvent=btnMate2.InternalOnKeyEvent
         End Object
         Controls(4)=GUIGFXButton'XInterface.Tab_SPRoster.btnMate2'

         Begin Object Class=GUILabel Name=lblNA2
             Caption="SLOT NOT AVAILABLE"
             TextAlign=TXTA_Center
             TextColor=(B=255,G=255,R=255)
             TextFont="UT2SmallFont"
             WinTop=0.420000
             WinHeight=0.210000
         End Object
         Controls(5)=GUILabel'XInterface.Tab_SPRoster.lblNA2'

         StyleName="NoBackground"
         WinTop=0.190000
         WinLeft=0.590000
         WinWidth=0.400000
         WinHeight=0.175000
     End Object
     Controls(9)=GUIPanel'XInterface.Tab_SPRoster.pnlMates2'

     Begin Object Class=GUIPanel Name=pnlMates3
         Begin Object Class=GUIImage Name=Mate3Back
             Image=Texture'InterfaceContent.Menu.BorderBoxD'
             ImageColor=(A=160)
             ImageStyle=ISTY_Stretched
             WinHeight=1.000000
         End Object
         Controls(0)=GUIImage'XInterface.Tab_SPRoster.Mate3Back'

         Begin Object Class=GUIGFXButton Name=imgMate3
             Graphic=Texture'InterfaceContent.Menu.BorderBoxD'
             Position=ICP_Scaled
             WinTop=0.052442
             WinLeft=0.018244
             WinWidth=0.140000
             WinHeight=0.896118
             OnKeyEvent=imgMate3.InternalOnKeyEvent
         End Object
         Controls(1)=GUIGFXButton'XInterface.Tab_SPRoster.imgMate3'

         Begin Object Class=GUILabel Name=lblMate3
             Caption="Name"
             TextAlign=TXTA_Center
             TextColor=(B=255,G=255,R=255)
             TextFont="UT2SmallFont"
             WinTop=0.249487
             WinLeft=0.174012
             WinWidth=0.797917
             WinHeight=0.213511
         End Object
         Controls(2)=GUILabel'XInterface.Tab_SPRoster.lblMate3'

         Begin Object Class=GUIComboBox Name=cboMate3
             Hint="Set starting position - change with voice menu during match"
             WinTop=0.567351
             WinLeft=0.323564
             WinWidth=0.554010
             WinHeight=0.234660
             OnChange=Tab_SPRoster.PositionChange
             OnKeyEvent=cboMate3.InternalOnKeyEvent
         End Object
         Controls(3)=GUIComboBox'XInterface.Tab_SPRoster.cboMate3'

         Begin Object Class=GUIGFXButton Name=btnMate3
             Graphic=Texture'InterfaceContent.SPMenu.YellowArrowVBand'
             Position=ICP_Scaled
             bClientBound=True
             StyleName="RosterButton"
             Hint="Assign the selected team member to this roster"
             WinTop=0.046398
             WinLeft=0.012050
             WinWidth=0.058350
             WinHeight=0.901195
             Tag=2
             OnClick=Tab_SPRoster.FixLineup
             OnKeyEvent=btnMate3.InternalOnKeyEvent
         End Object
         Controls(4)=GUIGFXButton'XInterface.Tab_SPRoster.btnMate3'

         Begin Object Class=GUILabel Name=lblNA3
             Caption="SLOT NOT AVAILABLE"
             TextAlign=TXTA_Center
             TextColor=(B=255,G=255,R=255)
             TextFont="UT2SmallFont"
             WinTop=0.420000
             WinHeight=0.210000
         End Object
         Controls(5)=GUILabel'XInterface.Tab_SPRoster.lblNA3'

         StyleName="NoBackground"
         WinTop=0.365000
         WinLeft=0.590000
         WinWidth=0.400000
         WinHeight=0.175000
     End Object
     Controls(10)=GUIPanel'XInterface.Tab_SPRoster.pnlMates3'

     Begin Object Class=GUIPanel Name=pnlMates4
         Begin Object Class=GUIImage Name=Mate4Back
             Image=Texture'InterfaceContent.Menu.BorderBoxD'
             ImageColor=(A=160)
             ImageStyle=ISTY_Stretched
             WinHeight=1.000000
             Tag=3
         End Object
         Controls(0)=GUIImage'XInterface.Tab_SPRoster.Mate4Back'

         Begin Object Class=GUIGFXButton Name=imgMate4
             Graphic=Texture'InterfaceContent.Menu.BorderBoxD'
             Position=ICP_Scaled
             WinTop=0.052442
             WinLeft=0.018244
             WinWidth=0.140000
             WinHeight=0.896118
             OnKeyEvent=imgMate4.InternalOnKeyEvent
         End Object
         Controls(1)=GUIGFXButton'XInterface.Tab_SPRoster.imgMate4'

         Begin Object Class=GUILabel Name=lblMate4
             Caption="Name"
             TextAlign=TXTA_Center
             TextColor=(B=255,G=255,R=255)
             TextFont="UT2SmallFont"
             WinTop=0.249487
             WinLeft=0.174012
             WinWidth=0.797917
             WinHeight=0.213511
         End Object
         Controls(2)=GUILabel'XInterface.Tab_SPRoster.lblMate4'

         Begin Object Class=GUIComboBox Name=cboMate4
             Hint="Set starting position - change with voice menu during match"
             WinTop=0.567351
             WinLeft=0.323564
             WinWidth=0.554010
             WinHeight=0.234660
             OnChange=Tab_SPRoster.PositionChange
             OnKeyEvent=cboMate4.InternalOnKeyEvent
         End Object
         Controls(3)=GUIComboBox'XInterface.Tab_SPRoster.cboMate4'

         Begin Object Class=GUIGFXButton Name=btnMate4
             Graphic=Texture'InterfaceContent.SPMenu.YellowArrowVBand'
             Position=ICP_Scaled
             bClientBound=True
             StyleName="RosterButton"
             Hint="Assign the selected team member to this roster"
             WinTop=0.046398
             WinLeft=0.012050
             WinWidth=0.058350
             WinHeight=0.901195
             Tag=3
             OnClick=Tab_SPRoster.FixLineup
             OnKeyEvent=btnMate4.InternalOnKeyEvent
         End Object
         Controls(4)=GUIGFXButton'XInterface.Tab_SPRoster.btnMate4'

         Begin Object Class=GUILabel Name=lblNA4
             Caption="SLOT NOT AVAILABLE"
             TextAlign=TXTA_Center
             TextColor=(B=255,G=255,R=255)
             TextFont="UT2SmallFont"
             WinTop=0.420000
             WinHeight=0.210000
         End Object
         Controls(5)=GUILabel'XInterface.Tab_SPRoster.lblNA4'

         StyleName="NoBackground"
         WinTop=0.540000
         WinLeft=0.590000
         WinWidth=0.400000
         WinHeight=0.175000
     End Object
     Controls(11)=GUIPanel'XInterface.Tab_SPRoster.pnlMates4'

     Begin Object Class=GUIListBox Name=SPRTeamStats
         OnCreateComponent=SPRTeamStats.InternalOnCreateComponent
         WinTop=0.722000
         WinLeft=0.654063
         WinWidth=0.338750
         WinHeight=0.186797
         bAcceptsInput=False
         bNeverFocus=True
     End Object
     Controls(12)=GUIListBox'XInterface.Tab_SPRoster.SPRTeamStats'

     WinTop=0.150000
     WinHeight=0.770000
}
