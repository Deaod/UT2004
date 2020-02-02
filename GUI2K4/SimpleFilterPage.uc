//==============================================================================
//	Description
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class SimpleFilterPage extends FilterPageBase;

var SimpleFilterPanel					p_Simple;

event Opened(GUIComponent Sender)
{
	Super.Opened(Sender);

	p_Simple = SimpleFilterPanel(sp_Filter.Panels[0]);
	p_Simple.FilterMaster = FM;
	p_Simple.FilterSelectionChanged(False);

	cp_Filter.RemoveComponent(cp_Filter.co_GameType);
}

function SaveFilters()
{
	local int i, j;

	for (i = 0; i < FM.AllFilters.Length; i++)
	{
		for (j = 0; j < FM.AllFilters[i].Count(); j++)
		{
			if ( FM.AllFilters[i].GetRuleQueryType(j) == "QT_Disabled" )
				FM.AllFilters[i].RemoveRuleAt(j--);
		}
	}

	Super.SaveFilters();
}

function ApplyRules(int FilterIndex, optional bool bRefresh)
{
//	log("ApplyRules FilterIndex:"$FilterIndex@"bRefresh:"$bRefresh);
	if (FilterIndex >= 0)
	{
		FM.LoadSettings( FilterIndex );
		if (FilterIndex < FM.AllFilters.Length)
		{
			p_Simple.FilterSelectionChanged(True);
			p_Simple.Refresh(FilterIndex);
		}
	}

	else if (p_Simple != None)
		p_Simple.FilterSelectionChanged(False);
}

function InitFilterList()
{
	Super.InitFilterList();

	if (p_Simple != None)
		p_Simple.Refresh(-1);
}

function bool CreateTemplateRule( out GameInfo.KeyValuePair Rule, out string QueryType, out string RuleType )
{
	if ( Rule.Key ~= "TimeLimit" || Rule.Key ~= "GoalScore" )
		return false;

	if ( Rule.Key ~= "gamestats" )
		Rule.Key = "stats";

	else if ( Rule.Key ~= "translocator" )
		Rule.Key = "transloc";

	else if ( Rule.Key ~= "GamePassword" )
		Rule.Key = "password";

	else if ( Rule.Key ~= "MinPlayers" )
	{
		if ( Rule.Value ~= "0" )
		{
			Rule.Key = "nobots";
			Rule.Value = "true";
		}

		else
		{
			QueryType = "QT_GreaterThanEquals";
			RuleType = "DT_Unique";
			return true;
		}
	}

	else if ( Rule.Key ~= "ServerVersion" )
	{
		Rule.Key = "custom";
		Rule.Value = "version="$Rule.Value;
	}

	return Super.CreateTemplateRule(Rule, QueryType, RuleType);
}

defaultproperties
{
     Begin Object Class=GUISplitter Name=FilterSplitter
         SplitOrientation=SPLIT_Horizontal
         SplitPosition=0.609100
         bFixedSplitter=True
         bDrawSplitter=False
         DefaultPanels(0)="GUI2K4.SimpleFilterPanel"
         DefaultPanels(1)="GUI2K4.UT2K4FilterControlPanel"
         OnCreateComponent=SimpleFilterPage.InternalOnCreateComponent
         IniOption="@Internal"
         WinTop=0.033593
         WinLeft=0.009812
         WinWidth=0.976014
         WinHeight=0.936763
         RenderWeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     sp_Filter=GUISplitter'GUI2K4.SimpleFilterPage.FilterSplitter'

}
