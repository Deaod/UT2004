//==============================================================================
//	This page is the interface for custom filters
//
//	Created by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UT2K4CustomFilterPage extends FilterPageBase;


var				GUITitleBar				TabDock;
var				GUITabControl			c_Info;

var PlayInfo							FilterPI;

var array<string>						PanelClass;
var localized array<string>				PanelCaption;
var localized array<string>				PanelHint;

event Opened(GUIComponent Sender)
{
	local int i;

	if (c_Info.TabStack.Length > 0)
		return;

	CheckFM();
	Super.Opened(Sender);

	InitFilterList();
	c_Info.AddTab(PanelCaption[0], PanelClass[0],,PanelHint[0]);
	c_Info.AddTab(PanelCaption[1], PanelClass[1],,PanelHint[1]);
	for (i = 0; i < FilterPI.Groups.Length; i++)
		c_Info.AddTab(FilterPI.Groups[i], PanelClass[2],, FilterPI.Groups[i]@PanelHint[2]);
}

function CheckFM()
{
	Super.CheckFM();

	FilterPI = UT2K4ServerBrowser(ParentPage).FilterInfo;
}

function ApplyRules(int FilterIndex, optional bool bRefresh)
{
	local int i;

	if (FilterIndex >= 0)
	{
		EnableComponent(c_Info);

		UT2K4ServerBrowser(ParentPage).SetFilterInfo();
		FM.LoadSettings( FilterIndex );
		for (i = 0; i < c_Info.TabStack.Length; i++)
		{
			if (c_Info.TabStack[i] != None && GUIFilterPanel(c_Info.TabStack[i].MyPanel) != None)
			{
				// Only update the bRefresh flag if we want to make it 'true'
				GUIFilterPanel(c_Info.TabStack[i].MyPanel).bRefresh = (bRefresh || GUIFilterPanel(c_Info.TabStack[i].MyPanel).bRefresh);
				GUIFilterPanel(c_Info.TabStack[i].MyPanel).bUpdate = True;
			}
		}

		// Immediately update the active tabpanel
		if (c_Info.ActiveTab != None && c_Info.ActiveTab.MyPanel != None)
			c_Info.ActivateTab(c_Info.ActiveTab, True);
		else if (c_Info.TabStack.Length > 0)
			c_Info.ActivateTab(c_Info.TabStack[0], True);

		if ( !FM.IsActiveAt(FilterIndex) )
			DisableComponent(c_Info);
	}
}

function InternalOnChange(GUIComponent Sender)
{
	Super.InternalOnChange(Sender);

	if (Sender == li_Filter)
	{
		if ( li_Filter.ValidIndex(li_Filter.Index) && Controller.bCurMenuInitialized &&
			 FM != None && FM.IsActiveAt(li_Filter.Index) )
			ToggleTabControl(True);
		else
			ToggleTabControl(False);
	}
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
	Super.InternalOnCreateComponent(NewComp, Sender);
	if (GUISplitter(Sender) != None)
	{
		if (GUITabControl(NewComp) != None)
		{
			c_Info = GUITabControl(NewComp);
			c_Info.WinHeight=0.9;
			c_Info.TabHeight=0.04;
			c_Info.bDrawTabAbove=False;
			c_Info.bFillSpace=True;
			c_Info.bAcceptsInput=True;
			c_Info.bDockPanels=True;
			c_Info.OnChange=InternalOnChange;
		    c_Info.BackgroundStyleName="TabBackground";
		}

	}
}

function ToggleTabControl(bool bEnable)
{
	if (c_Info != None)
	{
		if ( bEnable && c_Info.MenuState == MSAT_Disabled )
		{
			c_Info.EnableMe();
			c_Info.Show();
			c_Info.ActivateTab(c_Info.TabStack[0],True);
		}

		else if (!bEnable && c_Info.MenuState != MSAT_Disabled)
		{
			c_Info.DisableMe();
			c_Info.Hide();
		}
	}
}

function InternalReleaseSplitter(GUIComponent Splitter, float NewPos)
{
	if (Splitter == sp_Filter)
	{
		FilterSplitterPosition = NewPos;
		SaveConfig();
	}
}

defaultproperties
{
     PanelClass(0)="GUI2K4.UT2K4FilterSummaryPanel"
     PanelClass(1)="GUI2K4.UT2K4CustomRulesPanel"
     PanelClass(2)="GUI2K4.UT2K4FilterRulesPanel"
     PanelCaption(0)="Filter Summary"
     PanelCaption(1)="Custom Rules"
     PanelHint(0)="View currently configured rules for this filter"
     PanelHint(1)="Additional custom filters"
     PanelHint(2)="Filters"
     Begin Object Class=GUISplitter Name=FilterSplitter
         SplitOrientation=SPLIT_Horizontal
         DefaultPanels(0)="GUI2K4.UT2K4FilterControlPanel"
         DefaultPanels(1)="XInterface.GUITabControl"
         MaxPercentage=0.900000
         OnReleaseSplitter=UT2K4CustomFilterPage.InternalReleaseSplitter
         OnCreateComponent=UT2K4CustomFilterPage.InternalOnCreateComponent
         IniOption="@Internal"
         WinHeight=1.000000
         RenderWeight=1.000000
         OnLoadINI=UT2K4CustomFilterPage.InternalOnLoad
     End Object
     sp_Filter=GUISplitter'GUI2K4.UT2K4CustomFilterPage.FilterSplitter'

}
