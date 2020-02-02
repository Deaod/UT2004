//==============================================================================
//	This panel contains all custom filter items, such as mutators, etc.
//
//	Created by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UT2K4CustomRulesPanel extends GUIFilterPanel;

var array<CacheManager.MutatorRecord>			MutRecords;
function InitComponent(GUIController MyC, GUIComponent MyO)
{
	class'CacheManager'.static.GetMutatorList(MutRecords);
	Super.InitComponent(MyC, MyO);

	lb_Rules.OnChange = InternalOnChange;
}

function Refresh()
{
	if (p_Anchor.Index < 0)
		return;

	Super.Refresh();
}

function LoadRules()
{
	local int i;
	local moComboBox co;
	local bool bTempInit;

	if (p_Anchor.Index < 0)
		return;

	// Do not want notification from components when adding them
	bTempInit = Controller.bCurMenuInitialized;
	Controller.bCurMenuInitialized = False;
	for (i = 0; i < MutRecords.Length; i++)
	{
		co = moComboBox(li_Rules.AddItem("XInterface.moComboBox",,MutRecords[i].FriendlyName));
		PopulateFilterTypes(co, False);
	}

	Super.LoadRules();

	Controller.bCurMenuInitialized = bTempInit;
}

function UpdateRules()
{
	local array<CustomFilter.CurrentFilter> Muts;
	local moComboBox co;
	local int i, idx, j;
	local bool bTemp;

	bTemp = Controller.bCurMenuInitialized;
	Controller.bCurMenuInitialized = False;

	Muts = FilterMaster.AllFilters[p_Anchor.Index].GetRuleSet("mutator");
	for (i = 0; i < li_Rules.Elements.Length; i++)
	{
		co = moComboBox(li_Rules.GetItem(i));

		for (j = 0; j < Muts.Length; j++)
		{
			if (Muts[i].Item.ItemName ~= co.Caption)
			{
				idx = co.FindIndex(class'CustomFilter'.static.GetQueryString(Muts[i].Item.FilterItem.QueryType), True, True);
				Assert(idx >= 0);

				co.SetIndex(idx);
			}
		}
	}

	Controller.bCurMenuInitialized = bTemp;
}

function ListOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
	if (GUIMultiOptionListBox(Sender) != None)
	{
		if (GUIMultiOptionList(NewComp) != None)
			li_Rules = GUIMultiOptionList(NewComp);

		GUIMultiOptionListBox(Sender).InternalOnCreateComponent(NewComp,Sender);
	}
}

function InternalOnChange(GUIComponent Sender)
{
	local moComboBox Changed;
	local int RuleIdx, Inner;
	local string ClsName, InnerStr, Str;

	if (GUIMultiOptionList(Sender) != None)
	{
		Changed = moComboBox(GUIMultiOptionList(Sender).Get());
		if (Changed != None)
		{
			ClsName = GetMutClassName(Changed.Caption);
			if (ClsName != "")
			{
				Inner = FilterMaster.AllFilters[p_Anchor.Index].FindInnerIndex("mutator", ClsName);
				if (Inner != -1)
					InnerStr = string(Inner);
				RuleIdx = FilterMaster.AllFilters[p_Anchor.Index].FindRuleIndex("mutator", InnerStr);
			}
			Str = Changed.GetExtra();
		}

		FilterMaster.SetRule(p_Anchor.Index, RuleIdx, Changed.Caption, "mutator", ClsName, "DT_Multiple", Str);
	}
}

function string GetMutClassName(string FriendlyName)
{
	local int i;

	for (i = 0; i < MutRecords.Length; i++)
		if (MutRecords[i].FriendlyName ~= FriendlyName)
			return MutRecords[i].ClassName;

	return "";
}

function string GetMutFriendlyName(string ClassName)
{
	local int i;

	for (i = 0; i < MutRecords.Length; i++)
		if (MutRecords[i].ClassName ~= ClassName)
			return MutRecords[i].FriendlyName;

	return "";
}

defaultproperties
{
     Begin Object Class=GUIMultiOptionListBox Name=CustomListBox
         bVisibleWhenEmpty=True
         OnCreateComponent=UT2K4CustomRulesPanel.ListOnCreateComponent
         WinLeft=0.050000
         WinWidth=0.900000
         WinHeight=1.000000
     End Object
     lb_Rules=GUIMultiOptionListBox'GUI2K4.UT2K4CustomRulesPanel.CustomListBox'

     OnCreateComponent=UT2K4CustomRulesPanel.InternalOnCreateComponent
}
