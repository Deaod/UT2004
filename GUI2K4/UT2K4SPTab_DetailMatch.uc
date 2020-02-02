//==============================================================================
// Overview of the last match played
//
// Written by Michiel Hendriks
// (c) 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4SPTab_DetailMatch extends UT2K4SPTab_Base;

var automated GUISectionBackground sbgChallengeBg, sbgOwnTeamBg, sbgEnemyTeamBg, sbgDetailsBg;
var automated GUI2K4MultiColumnListBox mclOwnTeam, mclEnemyTeam;
var automated GUILabel lblMatchTitle;
var automated GUIScrollTextBox stDescription;

var localized string MatchTitleCaption;
var localized string msgWon, msgLost, msgTeamPayment, msgInjury, msgSpecialAwards, msgBalanceChangeUp,
                     msgBalanceChangeDown, msgPayCheck, msgEarns, msgBonusMoneyWon, msgBonusMoneyLost,
					 msgBonusOverview, msgBonusOverviewItem;

var automated GUIImage imgChallengeBg;
var automated GUILabel lblChallengeTitle;
var automated GUIComboBox cbChallenges;

var localized string ColumnHeadings[4];
var localized string msgSelectChal;

var array<UT2K4GameProfile.PlayerMatchDetailsRecord> PlayerList1, PlayerList2;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;
	Super.Initcomponent(MyController, MyOwner);
	if (GP != none)
	{
		cbChallenges.AddItem(msgSelectChal);
		if (!GP.lmdTeamGame)
		{
			cbChallenges.DisableComponent(cbChallenges);
		}
		else {
			for (i = 0; i < GP.UT2K4GameLadder.default.ChallengeGames.length; i++)
			{
				if (GP.UT2K4GameLadder.default.ChallengeGames[i].static.canChallenge(GP))
					cbChallenges.AddItem(GP.UT2K4GameLadder.default.ChallengeGames[i].default.ChallengeName,,GP.UT2K4GameLadder.default.ChallengeGames[i].default.ChallengeMenu);
			}
		}
		FillData();
	}
}


function FillData()
{
	local int i;
	local string detailContent, tmp, tmp2, tmp3;
	local array<string> TeamName;
	local class<UT2K4TeamRoster> ETIclass;

	PlayerList1.Length = 0;
	PlayerList2.Length = 0;

	lblMatchTitle.Caption = repl(repl(MatchTitleCaption, "%gametype%", GP.lmdGameType), "%map%", GP.lmdMap);

	sbgOwnTeamBg.Caption = GP.TeamName;

	TeamName.length = 2;
	TeamName[GP.lmdMyTeam] = sbgOwnTeamBg.Caption;

	mclOwnTeam.List.OnDrawItem = OnDrawPlayerList1;
	mclOwnTeam.List.ExpandLastColumn = true;
	mclOwnTeam.List.ColumnHeadings[0] = ColumnHeadings[0];
	mclOwnTeam.List.ColumnHeadings[1] = ColumnHeadings[1];
	mclOwnTeam.List.ColumnHeadings[2] = ColumnHeadings[2];
	mclOwnTeam.List.ColumnHeadings[3] = ColumnHeadings[3];
	mclOwnTeam.List.InitColumnPerc[0]=0.37;
	mclOwnTeam.List.InitColumnPerc[1]=0.20;
	mclOwnTeam.List.InitColumnPerc[2]=0.20;
	mclOwnTeam.List.InitColumnPerc[3]=0.23;
	mclOwnTeam.List.SortColumn = 1;
	mclOwnTeam.List.SortDescending = true;

	if (!GP.lmdTeamGame)
	{
		mclOwnTeam.WinLeft = 0.305102;
		sbgOwnTeamBg.WinLeft = 0.287245;

		mclEnemyTeam.bVisible = false;
		sbgEnemyTeamBg.bVisible = false;

		PlayerList1 = GP.PlayerMatchDetails;
		for (i = 0; i < PlayerList1.length; i++)
		{
			mclOwnTeam.List.AddedItem();
		}
	}
	else {
		ETIclass = class<UT2K4TeamRoster>(DynamicLoadObject(GP.lmdEnemyTeam, class'Class'));
		sbgEnemyTeamBg.Caption = ETIclass.default.TeamName;
		TeamName[(GP.lmdMyTeam+1) % 2] = sbgEnemyTeamBg.Caption;

		mclEnemyTeam.List.OnDrawItem = OnDrawPlayerList2;
		mclEnemyTeam.List.ExpandLastColumn = true;
		mclEnemyTeam.List.ColumnHeadings[0] = ColumnHeadings[0];
		mclEnemyTeam.List.ColumnHeadings[1] = ColumnHeadings[1];
		mclEnemyTeam.List.ColumnHeadings[2] = ColumnHeadings[2];
		mclEnemyTeam.List.ColumnHeadings[3] = ColumnHeadings[3];
		mclEnemyTeam.List.InitColumnPerc[0]=0.37;
		mclEnemyTeam.List.InitColumnPerc[1]=0.20;
		mclEnemyTeam.List.InitColumnPerc[2]=0.20;
		mclEnemyTeam.List.InitColumnPerc[3]=0.23;
		mclEnemyTeam.List.SortColumn = 1;
		mclEnemyTeam.List.SortDescending = true;

		for (i = 0; i < GP.PlayerMatchDetails.length; i++)
		{
			if (GP.PlayerMatchDetails[i].Team == GP.lmdMyTeam)
			{
				PlayerList1[PlayerList1.length] = GP.PlayerMatchDetails[i];
				mclOwnTeam.List.AddedItem();
			}
			else {
				PlayerList2[PlayerList2.length] = GP.PlayerMatchDetails[i];
				mclEnemyTeam.List.AddedItem();
			}
		}
	}

	// fill details
	detailContent = "";
	if (GP.lmdWonMatch) tmp = msgWon; else tmp = msgLost;
	tmp = repl(repl(tmp, "%gametype%", GP.lmdGameType), "%map%", GP.lmdMap);
	tmp = repl(repl(tmp, "%gametime%", string(GP.lmdGameTime/60)), "%PrizeMoney%", GP.MoneyToString(GP.lmdPrizeMoney));
	if (GP.lmdTotalBonusMoney > 0)
	{
		if (GP.lmdWonMatch)	tmp = repl(tmp, "%BonusMoney%", repl(msgBonusMoneyWon, "%BonusMoney%", GP.MoneyToString(GP.lmdTotalBonusMoney)));
			else tmp = repl(tmp, "%BonusMoney%", repl(msgBonusMoneyLost, "%BonusMoney%", GP.MoneyToString(GP.lmdTotalBonusMoney)));
	}
	else tmp = repl(tmp, "%BonusMoney%", "");
	if (GP.lmdTeamGame) tmp = repl(tmp, "%enemies%", PlayerList2.length);
		else tmp = repl(tmp, "%enemies%", PlayerList1.length-1);
	if (GP.PayCheck.Length > 0) tmp = repl(tmp, "%team_payment%", msgTeamPayment);
		else tmp = repl(tmp, "%team_payment%", "");
	if (GP.lmdBalanceChange > 0) tmp2 = repl(msgBalanceChangeUp, "%balance_absolute%", GP.MoneyToString(abs(GP.lmdBalanceChange)));
		else tmp2 = repl(msgBalanceChangeDown, "%balance_absolute%", GP.MoneyToString(abs(GP.lmdBalanceChange)));
	tmp = repl(tmp, "%balance_change%", tmp2);

	detailContent $= tmp;

	if (GP.lmdInjury > -1)
	{
		tmp = repl(msgInjury, "%player%", GP.BotStats[GP.lmdInjury].Name);
		tmp = repl(tmp, "%health%", GP.lmdInjuryHealth);
		tmp = repl(tmp, "%treatment%", GP.MoneyToString(GP.lmdInjuryTreatment));
		detailContent $= "||"$tmp;
	}

	tmp = "";
	for (i = 0; i < GP.PlayerMatchDetails.length; i++)
	{
		if (GP.PlayerMatchDetails[i].SpecialAwards.length > 0)
		{
			tmp3 = GP.PlayerMatchDetails[i].Name;
			if ((GP.PlayerMatchDetails[i].Team > -1)  && (GP.lmdTeamGame)) tmp3 @= "("$TeamName[GP.PlayerMatchDetails[i].Team]$")";
			tmp2 = repl(msgSpecialAwards, "%player%", tmp3);
			tmp2 = repl(tmp2, "%awards%", JoinArray(GP.PlayerMatchDetails[i].SpecialAwards, ", ", true));
			tmp $= "|"$tmp2;
		}
	}
	if (tmp != "") detailContent $= "|"$tmp;

	if (GP.PayCheck.Length > 0)
	{
		detailContent $= "||"$msgPayCheck;
		for (i = 0; i < GP.PayCheck.Length; i++)
		{
			detailContent $= "|"$repl(repl(msgEarns, "%player%", GP.BotStats[GP.PayCheck[i].BotId].Name), "%payment%", GP.MoneyToString(GP.PayCheck[i].Payment));
		}
	}

	tmp = "";
	for (i = 0; i < 6; i++)
	{
		if (GP.lmdSpree[i] > 0)
		{
			tmp2 = msgBonusOverviewItem;
			tmp2 = repl(tmp2, "%bonusname%", class'UT2K4SPTab_Profile'.default.SpreeLabel[i]);
			tmp2 = repl(tmp2, "%bonuscount%", GP.lmdSpree[i]);
			tmp2 = repl(tmp2, "%bonusmoney%", GP.MoneyToString(GP.SpreeBonus[i]));
			tmp $= "|"$tmp2;
		}
	}
	for (i = 0; i < 7; i++)
	{
		if (GP.lmdMultiKills[i] > 0)
		{
			tmp2 = msgBonusOverviewItem;
			tmp2 = repl(tmp2, "%bonusname%", class'UT2K4SPTab_Profile'.default.MultiKillsLabel[i]);
			tmp2 = repl(tmp2, "%bonuscount%", GP.lmdMultiKills[i]);
			tmp2 = repl(tmp2, "%bonusmoney%", GP.MoneyToString(GP.MultiKillBonus[i]));
			tmp $= "|"$tmp2;
		}
	}
	if (tmp != "") detailContent $= "||"$msgBonusOverview$tmp;

	stDescription.setContent(detailContent);

	mclOwnTeam.List.SortList();
	mclEnemyTeam.List.SortList();
}

/** Draw own team list/or complete player list when not a team game */
function OnDrawPlayerList1(Canvas Canvas, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
	local float CellLeft, CellWidth;
	local float XL, YL;

	i = mclOwnTeam.List.SortData[i].SortItem;
	if (PlayerList1.length <= i) return;

	mclOwnTeam.List.GetCellLeftWidth( 0, CellLeft, CellWidth );
	mclOwnTeam.List.Style.DrawText( Canvas, mclOwnTeam.List.MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, PlayerList1[i].Name, mclOwnTeam.List.FontScale );

	mclOwnTeam.List.GetCellLeftWidth( 1, CellLeft, CellWidth );
	mclOwnTeam.List.Style.TextSize(Canvas, mclOwnTeam.List.MenuState, string(int(PlayerList1[i].Score)), XL, YL, mclOwnTeam.List.FontScale);
	if (CellLeft + XL <= mclOwnTeam.List.ActualLeft() + mclOwnTeam.List.ActualWidth())
		mclOwnTeam.List.Style.DrawText( Canvas, mclOwnTeam.List.MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, string(int(PlayerList1[i].Score)), mclOwnTeam.List.FontScale );

	mclOwnTeam.List.GetCellLeftWidth( 2, CellLeft, CellWidth );
	mclOwnTeam.List.Style.TextSize(Canvas, mclOwnTeam.List.MenuState, string(int(PlayerList1[i].Kills)), XL, YL, mclOwnTeam.List.FontScale);
	if (CellLeft + XL <= mclOwnTeam.List.ActualLeft() + mclOwnTeam.List.ActualWidth())
		mclOwnTeam.List.Style.DrawText( Canvas, mclOwnTeam.List.MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, string(int(PlayerList1[i].Kills)), mclOwnTeam.List.FontScale );

	mclOwnTeam.List.GetCellLeftWidth( 3, CellLeft, CellWidth );
	mclOwnTeam.List.Style.TextSize(Canvas, mclOwnTeam.List.MenuState, string(int(PlayerList1[i].Deaths)), XL, YL, mclOwnTeam.List.FontScale);
	if (CellLeft + XL <= mclOwnTeam.List.ActualLeft() + mclOwnTeam.List.ActualWidth())
		mclOwnTeam.List.Style.DrawText( Canvas, mclOwnTeam.List.MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, string(int(PlayerList1[i].Deaths)), mclOwnTeam.List.FontScale );
}

/** Draw enemy team list */
function OnDrawPlayerList2(Canvas Canvas, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
	local float CellLeft, CellWidth;
	local float XL, YL;

	i = mclEnemyTeam.List.SortData[i].SortItem;
	if (PlayerList2.length <= i) return;

	mclEnemyTeam.List.GetCellLeftWidth( 0, CellLeft, CellWidth );
	mclEnemyTeam.List.Style.DrawText( Canvas, mclEnemyTeam.List.MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, PlayerList2[i].Name, mclEnemyTeam.List.FontScale );

	mclEnemyTeam.List.GetCellLeftWidth( 1, CellLeft, CellWidth );
	mclEnemyTeam.List.Style.TextSize(Canvas, mclEnemyTeam.List.MenuState, string(int(PlayerList2[i].Score)), XL, YL, mclEnemyTeam.List.FontScale);
	if (CellLeft + XL <= mclEnemyTeam.List.ActualLeft() + mclEnemyTeam.List.ActualWidth())
		mclEnemyTeam.List.Style.DrawText( Canvas, mclEnemyTeam.List.MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, string(int(PlayerList2[i].Score)), mclEnemyTeam.List.FontScale );

	mclEnemyTeam.List.GetCellLeftWidth( 2, CellLeft, CellWidth );
	mclEnemyTeam.List.Style.TextSize(Canvas, mclEnemyTeam.List.MenuState, string(int(PlayerList2[i].Kills)), XL, YL, mclEnemyTeam.List.FontScale);
	if (CellLeft + XL <= mclEnemyTeam.List.ActualLeft() + mclEnemyTeam.List.ActualWidth())
		mclEnemyTeam.List.Style.DrawText( Canvas, mclEnemyTeam.List.MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, string(int(PlayerList2[i].Kills)), mclEnemyTeam.List.FontScale );

	mclEnemyTeam.List.GetCellLeftWidth( 3, CellLeft, CellWidth );
	mclEnemyTeam.List.Style.TextSize(Canvas, mclEnemyTeam.List.MenuState, string(int(PlayerList2[i].Deaths)), XL, YL, mclEnemyTeam.List.FontScale);
	if (CellLeft + XL <= mclEnemyTeam.List.ActualLeft() + mclEnemyTeam.List.ActualWidth())
		mclEnemyTeam.List.Style.DrawText( Canvas, mclEnemyTeam.List.MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, string(int(PlayerList2[i].Deaths)), mclEnemyTeam.List.FontScale );
}

function OnChallengeSelect(GUIComponent Sender)
{
	local string tmp;
	tmp = cbChallenges.GetExtra();
	if (tmp != "") Controller.OpenMenu(tmp, GP.lmdEnemyTeam);
	cbChallenges.SetIndex(0);
}

function string mclPlayersOnGetSortString(GUIComponent Sender, int item, int column)
{
	local string s;
	local array<UT2K4GameProfile.PlayerMatchDetailsRecord> list;
	if (Sender == mclOwnTeam) list = PlayerList1;
	else list = PlayerList2;

	switch (column)
	{
		case 0: s = list[item].Name; break;
		case 1: s = string(int(list[item].Score));
						PadLeft(S, 5, "0");
						break;
		case 2: s = string(int(list[item].Kills));
						PadLeft(S, 5, "0");
						break;
		case 3: s = string(int(list[item].Deaths));
						PadLeft(S, 5, "0");
						break;
	}
	return s;
}

defaultproperties
{
     Begin Object Class=AltSectionBackground Name=SPLsbgChallengeBg
         Caption="Challenges"
         WinTop=0.422675
         WinLeft=0.281250
         WinWidth=0.443750
         WinHeight=0.140306
         bBoundToParent=True
         OnPreDraw=SPLsbgChallengeBg.InternalPreDraw
     End Object
     sbgChallengeBg=AltSectionBackground'GUI2K4.UT2K4SPTab_DetailMatch.SPLsbgChallengeBg'

     Begin Object Class=GUISectionBackground Name=SPDMimgOwnTeamBg
         WinTop=0.075000
         WinLeft=0.050000
         WinWidth=0.431888
         WinHeight=0.343750
         bBoundToParent=True
         OnPreDraw=SPDMimgOwnTeamBg.InternalPreDraw
     End Object
     sbgOwnTeamBg=GUISectionBackground'GUI2K4.UT2K4SPTab_DetailMatch.SPDMimgOwnTeamBg'

     Begin Object Class=GUISectionBackground Name=SPDMimgEnemyTeamBg
         WinTop=0.075000
         WinLeft=0.533418
         WinWidth=0.431888
         WinHeight=0.343750
         bBoundToParent=True
         OnPreDraw=SPDMimgEnemyTeamBg.InternalPreDraw
     End Object
     sbgEnemyTeamBg=GUISectionBackground'GUI2K4.UT2K4SPTab_DetailMatch.SPDMimgEnemyTeamBg'

     Begin Object Class=GUISectionBackground Name=SPDMimgDetailsBg
         Caption="Details"
         WinTop=0.566667
         WinLeft=0.050000
         WinWidth=0.900000
         WinHeight=0.425000
         bBoundToParent=True
         OnPreDraw=SPDMimgDetailsBg.InternalPreDraw
     End Object
     sbgDetailsBg=GUISectionBackground'GUI2K4.UT2K4SPTab_DetailMatch.SPDMimgDetailsBg'

     Begin Object Class=GUI2K4MultiColumnListBox Name=SPDMmclOwnTeam
         OnGetSortString=UT2K4SPTab_DetailMatch.mclPlayersOnGetSortString
         bVisibleWhenEmpty=True
         OnCreateComponent=SPDMmclOwnTeam.InternalOnCreateComponent
         StyleName="ServerBrowserGrid"
         WinTop=0.133333
         WinLeft=0.067832
         WinWidth=0.397500
         WinHeight=0.254056
         RenderWeight=0.200000
         bBoundToParent=True
     End Object
     mclOwnTeam=GUI2K4MultiColumnListBox'GUI2K4.UT2K4SPTab_DetailMatch.SPDMmclOwnTeam'

     Begin Object Class=GUI2K4MultiColumnListBox Name=SPDMmclEnemyTeam
         OnGetSortString=UT2K4SPTab_DetailMatch.mclPlayersOnGetSortString
         bVisibleWhenEmpty=True
         OnCreateComponent=SPDMmclEnemyTeam.InternalOnCreateComponent
         StyleName="ServerBrowserGrid"
         WinTop=0.133333
         WinLeft=0.551250
         WinWidth=0.397500
         WinHeight=0.254056
         RenderWeight=0.200000
         bBoundToParent=True
     End Object
     mclEnemyTeam=GUI2K4MultiColumnListBox'GUI2K4.UT2K4SPTab_DetailMatch.SPDMmclEnemyTeam'

     Begin Object Class=GUILabel Name=SPDMlblMatchTitle
         TextAlign=TXTA_Center
         FontScale=FNS_Large
         StyleName="NoBackground"
         WinLeft=0.050000
         WinWidth=0.900000
         WinHeight=0.082500
         RenderWeight=0.110000
         bBoundToParent=True
     End Object
     lblMatchTitle=GUILabel'GUI2K4.UT2K4SPTab_DetailMatch.SPDMlblMatchTitle'

     Begin Object Class=GUIScrollTextBox Name=SPDMstDescription
         bNoTeletype=True
         OnCreateComponent=SPDMstDescription.InternalOnCreateComponent
         WinTop=0.636876
         WinLeft=0.072883
         WinWidth=0.852908
         WinHeight=0.330230
         bBoundToParent=True
     End Object
     stDescription=GUIScrollTextBox'GUI2K4.UT2K4SPTab_DetailMatch.SPDMstDescription'

     MatchTitleCaption="%gametype% in %map%"
     msgWon="After %gametime% minutes you won the %gametype% against %enemies% enemies in %map%.|The prize money for this match was %PrizeMoney%%BonusMoney%. %team_payment%"
     msgLost="After %gametime% minutes you lost the %gametype% against %enemies% enemies in %map%%BonusMoney%. %team_payment%"
     msgTeamPayment="After paying your team mates %balance_change%."
     msgInjury="During the last match %player% got injured, health dropped to %health%%. Treatment of the injuries costs %treatment%"
     msgSpecialAwards="%player% earned the following special awards:|        %awards%"
     msgBalanceChangeUp="your balance increased by %balance_absolute%"
     msgBalanceChangeDown="your balance decreased by %balance_absolute%"
     msgPayCheck="Pay check overview:"
     msgEarns="    %player% earned %payment%."
     msgBonusMoneyWon=" additionally you won %BonusMoney% in bonus money"
     msgBonusMoneyLost=", however you won %BonusMoney% in bonus money"
     msgBonusOverview="You won the following bonuses:"
     msgBonusOverviewItem="    %bonuscount% x %bonusname% %bonusmoney%"
     Begin Object Class=GUIComboBox Name=SPLcbChallenges
         bReadOnly=True
         bShowListOnFocus=True
         Hint="Challenge another team"
         WinTop=0.478253
         WinLeft=0.294985
         WinWidth=0.417347
         WinHeight=0.048648
         TabOrder=2
         bBoundToParent=True
         OnChange=UT2K4SPTab_DetailMatch.OnChallengeSelect
         OnKeyEvent=SPLcbChallenges.InternalOnKeyEvent
     End Object
     cbChallenges=GUIComboBox'GUI2K4.UT2K4SPTab_DetailMatch.SPLcbChallenges'

     ColumnHeadings(0)="Name"
     ColumnHeadings(1)="Score"
     ColumnHeadings(2)="Kills"
     ColumnHeadings(3)="Deaths"
     msgSelectChal="Select a challenge"
     PanelCaption="Last Match Played"
     PropagateVisibility=False
}
