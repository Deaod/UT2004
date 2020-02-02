//==============================================================================
//  Created on: 01/21/2004
//  This is a combination of the Rules & Maplist panels
//  Used for full-screen mid-game menus.
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4Tab_MidGameRulesCombo extends MidGamePanel;

struct AServerRule
{
	var string RuleName, RuleValue;
};

var() noexport array<AServerRule> ServerRules;

var noexport  GUIList    li_Maps;
var noexport  GUIMultiColumnList li_Rules;
var automated GUISectionBackground sb_Rules, sb_Maps;
var automated GUIListBox lb_Maps;
var automated GUIMultiColumnListBox lb_Rules;

var() localized string DefaultRulesText, DefaultMapsText;

var() bool bReceivedRules, bReceivedMaps;
var() bool bClient;

function InitComponent(GUIController InController, GUIComponent InOwner)
{
	Super.InitComponent(InController, InOwner);

	li_Rules = lb_Rules.List;
	li_Maps = lb_Maps.List;

	li_Rules.bInitializeList = false;
	li_Maps.bInitializeList = false;

	li_Maps.TextAlign = TXTA_Center;
	li_Maps.Add(DefaultMapsText);

	li_Rules.SortColumn = -1;
	li_Rules.OnDrawItem = DrawServerRule;

	sb_Rules.ManageComponent(lb_Rules);
	sb_Maps.Managecomponent(lb_Maps);
}

function ShowPanel(bool bShow)
{
	Super.ShowPanel(bShow);
	if ( bShow && (!bReceivedRules || !bReceivedMaps) )
	{
		SetTimer(1.0, True);
		Timer();
    }
}

function Timer()
{
	local xPlayer PC;

	PC = xPlayer(PlayerOwner());

	if ( PC == None )
	{
		bReceivedMaps = true;
		bReceivedRules = true;
		KillTimer();
		return;
	}

	if ( !bReceivedRules )
	{
		PC.ProcessRule = ProcessRule;
		PC.ServerRequestRules();
	}

	else if ( !bReceivedMaps )
	{
		PC.ProcessMapName = ProcessMapName;
		PC.ServerRequestMapList();
	}
}

function ProcessRule(string NewRule)
{
	local AServerRule Rule;

	bReceivedRules = true;
	if ( NewRule == "" )
	{
		ServerRules.Remove(0, ServerRules.Length);
		li_Rules.Clear();
	}
	else
	{
		if ( Divide(NewRule, "=", Rule.RuleName, Rule.RuleValue) )
		{
			ServerRules[ServerRules.Length] = Rule;
			li_Rules.AddedItem();
		}
	}
}

function ProcessMapName( string MapName )
{
	bReceivedMaps = true;
	if ( MapName == "" )
		li_Maps.Clear();
	else li_Maps.Add(MapName);
}

function bool RightClick( GUIComponent Sender )
{
	local PlayerController PC;

	if ( Controller.ActiveControl != li_Maps )
		return false;

	PC = PlayerOwner();
	if ( PC.Level.NetMode == NM_StandAlone )
		return true;

	if ( PC.PlayerReplicationInfo != None && PC.PlayerReplicationInfo.bAdmin )
		return true;

	return false;
}

function ContextClick(GUIContextMenu Sender, int Index)
{
	local PlayerController PC;
	local string MapName;

	PC = PlayerOwner();
	MapName = li_Maps.Get();

	// TODO Add handler for response from server
	if (MapName != "")
	{
		if ( Index == 0 )
		{
			if ( PC.Level.NetMode == NM_StandAlone )
				Console(Controller.Master.Console).DelayedConsoleCommand("open"@MapName);
			else if ( PC.Level.NetMode == NM_ListenServer )
				Console(Controller.Master.Console).DelayedConsoleCommand("switch"@MapName);
			else PC.AdminCommand("switch"@MapName);

			Controller.CloseAll(False,True);
		}
		else if ( Index == 1 )
			PC.AdminCommand("maplist del"@MapName);
	}
}

function DrawServerRule(Canvas Canvas, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
	local float CellLeft, CellWidth;

	li_Rules.GetCellLeftWidth( 0, CellLeft, CellWidth );
	li_Rules.Style.DrawText( Canvas, li_Rules.MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, ServerRules[i].RuleName, li_Rules.FontScale );

	li_Rules.GetCellLeftWidth( 1, CellLeft, CellWidth );
	li_Rules.Style.DrawText( Canvas, li_Rules.MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, ServerRules[i].RuleValue, li_Rules.FontScale );
}

defaultproperties
{
     Begin Object Class=AltSectionBackground Name=sbRules
         bFillClient=True
         Caption="Server Rules"
         WinTop=0.020438
         WinLeft=0.023625
         WinWidth=0.944875
         WinHeight=0.455783
         bBoundToParent=True
         bScaleToParent=True
         OnPreDraw=sbRules.InternalPreDraw
     End Object
     sb_Rules=AltSectionBackground'GUI2K4.UT2K4Tab_MidGameRulesCombo.sbRules'

     Begin Object Class=AltSectionBackground Name=sbMaps
         bFillClient=True
         Caption="Map Rotation"
         WinTop=0.482921
         WinLeft=0.055125
         WinWidth=0.881875
         WinHeight=0.436125
         bBoundToParent=True
         bScaleToParent=True
         OnPreDraw=sbMaps.InternalPreDraw
     End Object
     sb_Maps=AltSectionBackground'GUI2K4.UT2K4Tab_MidGameRulesCombo.sbMaps'

     Begin Object Class=GUIListBox Name=ComboMaplistBox
         SelectedStyleName="BrowserListSelection"
         bVisibleWhenEmpty=True
         OnCreateComponent=ComboMaplistBox.InternalOnCreateComponent
         StyleName="ServerBrowserGrid"
         WinTop=0.045905
         WinLeft=0.517829
         WinWidth=0.478167
         WinHeight=0.922516
         bBoundToParent=True
         bScaleToParent=True
     End Object
     lb_Maps=GUIListBox'GUI2K4.UT2K4Tab_MidGameRulesCombo.ComboMaplistBox'

     Begin Object Class=GUIMultiColumnListBox Name=ComboRulesListbox
         bDisplayHeader=False
         HeaderColumnPerc(0)=0.600000
         HeaderColumnPerc(1)=0.400000
         SelectedStyleName="BrowserListSelection"
         bVisibleWhenEmpty=True
         OnCreateComponent=ComboRulesListbox.InternalOnCreateComponent
         StyleName="ServerBrowserGrid"
         WinTop=0.045905
         WinLeft=0.008213
         WinWidth=0.478167
         WinHeight=0.922516
         bBoundToParent=True
         bScaleToParent=True
     End Object
     lb_Rules=GUIMultiColumnListBox'GUI2K4.UT2K4Tab_MidGameRulesCombo.ComboRulesListbox'

     DefaultRulesText="Receiving game rules from server"
     DefaultMapsText="Receiving maplist from server"
     Begin Object Class=GUIContextMenu Name=ComboContextMenu
         ContextItems(0)="Switch to this map"
         ContextItems(1)="Remove this map from rotation"
         OnSelect=UT2K4Tab_MidGameRulesCombo.ContextClick
     End Object
     ContextMenu=GUIContextMenu'GUI2K4.UT2K4Tab_MidGameRulesCombo.ComboContextMenu'

     OnRightClick=UT2K4Tab_MidGameRulesCombo.RightClick
}
