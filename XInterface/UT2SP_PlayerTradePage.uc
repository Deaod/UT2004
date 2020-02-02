// ====================================================================
//  Class:  XInterface.UT2SP_PlayerTradePage
//  Parent: XInterface.UT2DraftTeam
//
//  Trade a player, similar to drafting process.
//  author: capps
//  Rearranged this so that player can only make a single swap,
//  and once made, that's it.
// ====================================================================

class UT2SP_PlayerTradePage extends UT2DraftTeam;

var localized string MessageTitle, MessageTradeConfirm, MessageTradeInfo, MessageTradeCancel, CaptionBack, MessageTradePicHint;
var GUIButton butSwap;
var string TradingPlayerName;

function Created()
{
	super.Created();
	butSwap = GUIButton(Controls[17]);
}

function UpdateDraftable(bool bAffordable)
{
	// replaced with no-op
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

	MyTitleBar.SetCaption(MessageTitle);
	butSwap.OnClick=ButtonClick;
	butEnter.bVisible=true;
	butEnter.bAcceptsInput=true;
	butClear.Caption=CaptionBack;

	// get rid of buttons, labels, etc. that aren't needed
	butLeft.bVisible=false;
	butLeft.bNeverFocus=true;
	butLeft.bAcceptsInput=false;
	butRight.bVisible=false;
	butRight.bNeverFocus=true;
	butRight.bAcceptsInput=false;
	butRelease.bVisible=false;
	butRelease.bNeverFocus=true;
	butRelease.bAcceptsInput=false;
	butDraft.bVisible=false;
	butDraft.bNeverFocus=true;
	butDraft.bAcceptsInput=false;
	lblChoose.bVisible=false;
	cltPortrait.bLocked=true;
	cltPortrait.Hint=MessageTradePicHint;
	cltPortrait.OnChange=MyOnChange;
	cltMyTeam.bIgnoreBackClick=true;
	cltMyTeam.bAllowSelectEmpty=false;
	cltMyTeam.OnChange=MyOnChange;
	cltMyTeam.Index=0;
}

// check if they want to trade at all
function Initialize(string playername)
{
	local GUIQuestionPage Page;

	SetPlayer(playername);
	MyOnChange(cltPortrait);

	if (Controller.OpenMenu("XInterface.GUIQuestionPage"))
	{
		Page = GUIQuestionPage(Controller.ActivePage);
		Page.SetupQuestion(Page.Replace(MessageTradeInfo, "player", TradingPlayerName), QBTN_CONTINUE, QBTN_CONTINUE);
		Page.OnButtonClick = BeginConfirm;
	}
}

function BeginConfirm(byte bButton)
{
	bPlaySounds=true;
	PlayerOwner().ClientPlaySound(cltPortrait.GetSound(),,,SLOT_Interface);
}

function SetPlayer ( string playername )
{
	local array<xUtil.PlayerRecord> PlayerList;

	TradingPlayerName = playername;
	PlayerList[0] = class'xUtil'.static.FindPlayerRecord(playername);
	cltPortrait.ResetList(PlayerList, 1);
	cltPortrait.Index = 0;
}

function bool ButtonClick(GUIComponent Sender)
{
	local GUIQuestionPage Page;
	local string askstr;

	if ( Sender==butSwap )
	{
		// check if they're certain they want this swap
		if (Controller.OpenMenu("XInterface.GUIQuestionPage"))
		{
			Page = GUIQuestionPage(Controller.ActivePage);
			askstr = Page.Replace(MessageTradeConfirm, "new", TradingPlayerName);
			askstr = Page.Replace(askstr, "old", cltMyTeam.GetName());
			Page.SetupQuestion(askstr, QBTN_YesNo, QBTN_No);
			Page.OnButtonClick = SwapConfirm;
		}
		return true;
	}
	else if ( Sender==butEnter || Sender==butClear )
	{
		// check if they're certain they want to leave the trade screen
		if (Controller.OpenMenu("XInterface.GUIQuestionPage"))
		{
			Page = GUIQuestionPage(Controller.ActivePage);
			Page.SetupQuestion(MessageTradeCancel, QBTN_YesNo, QBTN_No);
			Page.OnButtonClick = CancelConfirm;
		}
		return true;
	}
	else
	{
		return super.ButtonClick(Sender);
	}

	FinishButtonClick();
	return true;
}

// called when button hit on the swap dialog
function SwapConfirm(byte bButton)
{
	local GameProfile GP;
	if (bButton == QBTN_Yes)
	{
		GP = PlayerOwner().Level.Game.CurrentGameProfile;
		Log("SINGLEPLAYER Teammate in spot"@cltMyTeam.Index@"is"@GP.PlayerTeam[cltMyTeam.Index]);
		GP.PlayerTeam[cltMyTeam.Index] = TradingPlayerName;
		Log("SINGLEPLAYER Teammate in spot"@cltMyTeam.Index@"is -now-"@GP.PlayerTeam[cltMyTeam.Index]);

		// inform of the update
		PlayerOwner().Level.Game.SavePackage(GP.PackageName);
		UT2SinglePlayerMain(Controller.ActivePage.ParentPage).PassThroughProfileUpdated();
		Controller.CloseMenu();
	}
}

// called when the cancel-confirm dialog pops up
function CancelConfirm(byte bButton)
{

	if ( bButton == QBTN_Yes )
	{
		Controller.CloseMenu();
	}
}

function MyOnChange(GUIComponent Sender)
{
	local xUtil.PlayerRecord PR;
	local string str;
	local GUICharacterList GCL;

	GCL = GUICharacterList(Sender);
	PR = GCL.GetRecord();

	if ( bPlaySounds )
		PlayerOwner().ClientPlaySound(GCL.GetSound(),,,SLOT_Interface);

	str = Mid(PR.TextName, Max(InStr(PR.TextName, ".")+1, 0));
	stbPlayerData.SetContent(Controller.LoadDecoText("xPlayers", str));

	BuildStats ( PR, lboStats, lboTeamStats );
}

// overrides base
function BuildStats ( out xUtil.PlayerRecord PR, GUIListBox charbox, GUIListBox teambox )
{
	local string str;
	local GameProfile GP;
	local xUtil.PlayerRecord PR2;

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

	// was team stats, include trade guy's stats instead
	teambox.List.Clear();
	PR2 = cltPortrait.GetRecord();
	str = PR2.DefaultName@StatsMessage;
	teambox.List.Add(str);
	str = class'xUtil'.static.GetFavoriteWeaponFor(PR2);
	teambox.List.Add(str);
	str = class'xUtil'.Default.AccuracyString@class'xUtil'.static.AccuracyRating(PR2);
	teambox.List.Add(str);
	str = class'xUtil'.Default.AggressivenessString@class'xUtil'.static.AggressivenessRating(PR2);
	teambox.List.Add(str);
	str = class'xUtil'.Default.AgilityString@class'xUtil'.static.AgilityRating(PR2);
	teambox.List.Add(str);
	str = class'xUtil'.Default.TacticsString@class'xUtil'.static.TacticsRating(PR2);
	teambox.List.Add(str);
}

defaultproperties
{
     MessageTitle="Single Player | Trade Opportunity"
     MessageTradeConfirm="Are you sure you want to trade %old% for %new%?"
     MessageTradeInfo="You have been offered a trade for %player%."
     MessageTradeCancel="Are you sure you want to cancel the trade?"
     CaptionBack="BACK"
     MessageTradePicHint="This player is available for trade"
     bPlaySounds=False
     Begin Object Class=GUIButton Name=SPPTSwap
         Caption="SWAP"
         Hint="Exchange this character with the active teammate"
         WinTop=0.619584
         WinLeft=0.711250
         WinWidth=0.132812
         WinHeight=0.076563
         bFocusOnWatch=True
         OnKeyEvent=SPPTSwap.InternalOnKeyEvent
     End Object
     Controls(17)=GUIButton'XInterface.UT2SP_PlayerTradePage.SPPTSwap'

}
