//==============================================================================
//  Created on: 12/11/2003
//  Description
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4Tab_RulesBase extends UT2K4GameTabBase;

var automated	GUITabControl			c_Rules;
//var automated	PlayInfoListBox			lb_Summary;
//var				PlayInfoList			li_Summary;

var config array<float>					HeaderColumnPerc;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	Assert(p_Anchor != None && p_Anchor.RuleInfo != None);
}

event Opened(GUIComponent Sender)
{
//log(Self@"Opened");
	Refresh();
	Super.Opened(Sender);
}

// Playinfo has been refreshed - update tabs and controls
function Refresh()
{
	local int i, j;
	Super.Refresh();

	// Update the summary list when the new settings
//	li_Summary.GamePI = p_Anchor.RuleInfo;
//	li_Summary.Refresh();

	// First, find out if we need to remove any tabs
	// This is likely to be the case if we have mutators have been removed which were adding new groups to playinfo
	for (i = 0; i < c_Rules.TabStack.Length; i++)
	{
		j = FindGroupIndex(c_Rules.TabStack[i].Caption);
		if (j < 0)
			c_Rules.RemoveTab(,c_Rules.TabStack[i--]);
	}

	// Then, go through and tag all panels to refresh themselves the next time they are shown
	for (i = 0; i < c_Rules.TabStack.Length; i++)
		if (InstantActionRulesPanel(c_Rules.TabStack[i].MyPanel) != None)
		{
			InstantActionRulesPanel(c_Rules.TabStack[i].MyPanel).GamePI = p_Anchor.RuleInfo;
			InstantActionRulesPanel(c_Rules.TabStack[i].MyPanel).bRefresh = True;
		}

	// Next, find out if we need to add any tabs
	for (i = 0; i < p_Anchor.RuleInfo.Groups.Length; i++)
	{
		j = c_Rules.TabIndex(p_Anchor.RuleInfo.Groups[i]);
		if (j < 0)
			c_Rules.AddTab(p_Anchor.RuleInfo.Groups[i], "GUI2K4.InstantActionRulesPanel",,p_Anchor.RuleInfo.Groups[i]@"Settings");
	}

	// Finally, go through and tag all panels to update themselves with the fresh
	// information from PlayInfo
	for (i = 0; i < c_Rules.TabStack.Length; i++)
		if (InstantActionRulesPanel(c_Rules.TabStack[i].MyPanel) != None)
			InstantActionRulesPanel(c_Rules.TabStack[i].MyPanel).bUpdate = True;
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
	if (Sender == c_Rules)
	{
		if (InstantActionRulesPanel(NewComp) != None)
		{
			InstantActionRulesPanel(NewComp).tp_Anchor = Self;
			InstantActionRulesPanel(NewComp).GamePI = p_Anchor.RuleInfo;
		}
	}

//	else if (Sender == lb_Summary)
//	{
//		li_Summary = PlayInfoList(NewComp);
//		lb_Summary.InternalOnCreateComponent(NewComp, Sender);
//	}
}


function int FindGroupIndex(string Group)
{
	local int i;

	Assert(p_Anchor != None && p_Anchor.RuleInfo != None);
	for (i = 0; i < p_Anchor.RuleInfo.Groups.Length; i++)
		if (p_Anchor.RuleInfo.Groups[i] ~= Group)
			return i;

	return -1;
}
/*
function string InternalOnSaveINI(GUIComponent Sender)
{
	HeaderColumnPerc = lb_Summary.HeaderColumnPerc;
	SaveConfig();
	return "";
}
*/

defaultproperties
{
     Begin Object Class=GUITabControl Name=RuleTabControl
         bFillSpace=True
         bDockPanels=True
         bDrawTabAbove=False
         TabHeight=0.040000
         BackgroundStyleName="TabBackground"
         OnCreateComponent=UT2K4Tab_RulesBase.InternalOnCreateComponent
         WinHeight=1.000000
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         OnActivate=RuleTabControl.InternalOnActivate
     End Object
     c_Rules=GUITabControl'GUI2K4.UT2K4Tab_RulesBase.RuleTabControl'

     HeaderColumnPerc(0)=0.750000
     HeaderColumnPerc(1)=0.250000
}
