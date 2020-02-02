//==============================================================================
//	This panel lists all the rules for the currently active custom filter
//
//	Created by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UT2K4FilterRulesPanel extends GUIFilterPanel;

var localized string EnableRule, MaxText, MinText;

function InitComponent(GUIController MyC, GUIComponent MyO)
{
	Super.InitComponent(MyC, MyO);

	li_Rules = lb_Rules.List;
	li_Rules.bDrawSelectionBorder = False;
	li_Rules.NumColumns = 3;
}

// Called when gametype has been changed
function LoadRules()
{
	local int i;

	if (GamePI == None || FilterMaster == None)
		return;

	GamePI.GetSettings(MyButton.Caption, InfoRules);
	for (i = 0; i < InfoRules.Length; i++)
		AddRule(InfoRules[i],i);

	Super.LoadRules();
}

function EnableClick(GUIComponent Sender)
{
	local int i;
	for (i = 0; i < li_Rules.Elements.Length; i++)
	{
	}
}
/*
function AddRule(PlayInfo.PlayInfoData NewRule, int Index)
{
	local moCheckbox	check;

	check = moCheckBox(li_Rules.AddItem("XInterface.moCheckBox",,NewRule.DisplayName,True));
	assert(Check != None);
	check.ComponentWidth = 0.1;
	check.bAutoSizeCaption = True;
	check.bFlipped = True;
	check.Hint = EnableRule;
	check.Tag = Index;
	check.OnChange = EnableClick;

	if ( NewRule.RenderType == PIT_Check )
	{
		spc
	Super.AddRule(NewRule, Index);

	switch (NewRule.RenderType)
	{
		case PIT_Check:
			spc = GUIListSpacer(li_Rules.AddItem("XInterface.GUIListSpacer"));
			spc.Tag = Index;
			ch = moCheckbox(li_Rules.AddItem("XInterface.moCheckbox"));
			if (ch == None)
				break;

			ch.Tag = Index;
			break;

		case PIT_Select:
			spc = GUIListSpacer(li_Rules.AddItem("XInterface.GUIListSpacer"));
			spc.ComponentWidth=0.01;
			spc.CaptionWidth=0.01;
			spc.Tag = Index;

			co = moCombobox(li_Rules.AddItem("XInterface.moComboBox"));
			if (co == None)
				break;

			co.ReadOnly(True);
			GamePI.SplitStringToArray(Range, NewRule.Data, ";");
			for (i = 0; i+1 < Range.Length; i += 2)
				co.AddItem(Range[i+1],,Range[i]);

			co.Tag = Index;
			break;

		case PIT_Text:
			Divide(NewRule.Data, ";", Width, Op);
			pos = InStr(Width, ",");
			if (pos != -1)
				Width = Left(Width, pos);

			if (Width != "")
				i = int(Width);
			else i = -1;
			GamePI.SplitStringToArray(Range, Op, ":");
			if (Range.Length > 1)
			{
				// Ranged data
				if (InStr(Range[0], ".") != -1)
				{
					// float edit
					fl = moFloatEdit(li_Rules.AddItem("XInterface.moFloatEdit",,MinText));
					fl.bAutoSizeCaption = True;
					fl.ComponentWidth = 0.25;
					if (i != -1)
						fl.Setup( float(Range[0]), float(Range[1]) - fl.MyNumericEdit.Step, fl.MyNumericEdit.Step);

					fl.Tag = Index;
					fl = moFloatEdit(li_Rules.AddItem("XInterface.moFloatEdit",,MaxText));
					fl.bAutoSizeCaption = True;
					fl.ComponentWidth = 0.25;
					if (i != -1)
						fl.Setup( float(Range[0]) + fl.MyNumericEdit.Step, float(Range[1]), fl.MyNumericEdit.Step);
					fl.Tag = Index;
				}

				else
				{
					nu = moNumericEdit(li_Rules.AddItem("XInterface.moNumericEdit",,MinText));
					nu.bAutoSizeCaption = True;
					nu.ComponentWidth = 0.25;
					if (i != -1)
						nu.Setup( int(Range[0]), int(Range[1]) - nu.MyNumericEdit.Step, nu.MyNumericEdit.Step);
					nu.Tag = Index;

					nu = moNumericEdit(li_Rules.AddItem("XInterface.moNumericEdit",,MaxText));
					nu.bAutoSizeCaption = True;
					nu.ComponentWidth = 0.25;
					if (i != -1)
						nu.Setup( int(Range[0]) + nu.MyNumericEdit.Step, int(Range[1]), nu.MyNumericEdit.Step);
					nu.Tag = Index;
				}
			}

			else if (ArrayProperty(NewRule.ThisProp) == None)
			{
				spc = GUIListSpacer(li_Rules.AddItem("Xinterface.GUIListSpacer"));
				spc.Tag = Index;
				ed = moEditbox(li_Rules.AddItem("XInterface.moEditBox"));
				if (ed == None) break;

				ed.bAutoSizeCaption = True;
				if (i != -1)
					ed.MyEditBox.MaxWidth = i;

				ed.Tag = Index;
			}
			break;
	}
}
*/
// Called when a different custom filter has been selected
function UpdateRules()
{
	local int i, idx, RuleIdx;
	local string Data, AllV, MinV, MaxV;
	local array<string> Range;
	local GUIMenuOption comp, lastcomp;

	local moFloatEdit fl;
	local moEditBox	ed;
	local moNumericEdit nu;
	local bool bTempInit;

	if (li_Rules.Elements.Length == 0)
		return;

	if (bUpdate)
		GamePI.GetSettings(MyButton.Caption, InfoRules);

	// GUIMenuOptions don't pass OnChange if the current menu isn't initialized
	// Let's fake it so that we don't get OnChange events while adding the components
	bTempInit = Controller.bCurMenuInitialized;
	Controller.bCurMenuInitialized = False;

	Super.UpdateRules();
	for (i = 0; i < li_Rules.Elements.Length; i+=li_Rules.NumColumns)
	{
		comp = li_Rules.GetItem(i);
		lastcomp = li_Rules.GetItem(i + li_Rules.NumColumns - 1);
		idx = comp.Tag;
//log("Updating element"@i$":"@comp.caption);
		Assert(InfoRules[idx].DisplayName == li_Rules.Elements[i].Caption);
/*		for (idx = 0; idx < InfoRules.Length; idx++)
			if (InStr(comp.Caption, InfoRules[idx].DisplayName) != -1)
				break;
		if (idx == InfoRules.Length)
		{
			Warn("Could not find matching PlayInfo rule for '"$Comp.Caption$"'");
			return;
		}
*/
//log("UpdateSettings Name:"$InfoRules[idx].SettingName@"Value:"$InfoRules[idx].Value@"Data:"$InfoRules[idx].Data);
		switch (InfoRules[idx].RenderType)
		{
			case PIT_Check:
				RuleIdx = FilterMaster.AllFilters[p_Anchor.Index].FindRuleIndex(InfoRules[Idx].SettingName);
				lastcomp.SetComponentValue(InfoRules[idx].Value);
				break;

			case PIT_Select:
				RuleIdx = FilterMaster.AllFilters[p_Anchor.Index].FindRuleIndex(InfoRules[Idx].SettingName);
				lastcomp.SetComponentValue(InfoRules[Idx].Value);
				break;

			case PIT_Text:

				if (moNumericEdit(lastcomp) != None)
				{
					Divide(InfoRules[idx].Data, ";", Data, AllV);
					GamePI.SplitStringToArray(Range, Data, ",");
					Divide(AllV, ":", MinV, MaxV);

					nu = moNumericEdit(li_Rules.GetItem(i + li_Rules.NumColumns - 2));
					RuleIdx = FilterMaster.AllFilters[p_Anchor.Index].FindRuleIndex(InfoRules[Idx].SettingName);
					if (Range.Length > 1)
						nu.SetValue(int(Range[1]));
					else nu.SetValue(int(MinV));

					nu = moNumericEdit(lastcomp);
					RuleIdx = FilterMaster.AllFilters[p_Anchor.Index].FindRuleIndex(InfoRules[Idx].SettingName, "1");
					if (Range.Length > 2)
						nu.SetValue(int(Range[2]));
					else nu.SetValue(int(MaxV));
				}

				else if (moFloatEdit(lastcomp) != None)
				{
					Divide(InfoRules[idx].Data, ";", Data, AllV);
					GamePI.SplitStringToArray(Range, Data, ",");
					Divide(AllV, ":", MinV, MaxV);

					fl = moFloatEdit(li_Rules.GetItem(i + li_Rules.NumColumns - 2));
					RuleIdx = FilterMaster.AllFilters[p_Anchor.Index].FindRuleIndex(InfoRules[Idx].SettingName);
					if (Range.Length > 1)
						fl.SetValue(float(Range[1]));
					else fl.SetValue(float(MinV));

					fl = moFloatEdit(lastcomp);
					RuleIdx = FilterMaster.AllFilters[p_Anchor.Index].FindRuleIndex(InfoRules[Idx].SettingName, "1");
					if (Range.Length > 2)
						fl.SetValue(float(Range[2]));
					else fl.SetValue(float(MaxV));
				}

				else if (moEditBox(comp) != None)
				{
					ed = moEditBox(comp);
					ed.SetText(InfoRules[idx].Value);
				}
				break;
		}

//		if (RuleIdx >= 0)
//			j = moComboBox(li_RuleFilter.Elements[i]).FindIndex(class'CustomFilter'.static.GetQueryString(FilterMaster.AllFilters[p_Anchor.Index].AllRules[RuleIdx].Item.FilterItem.QueryType),False,True);
//		else j = 0;
//		moComboBox(li_RuleFilter.Elements[i]).SetIndex(j);
	}

	Controller.bCurMenuInitialized = bTempInit;
}
/*
function InternalOnChange(GUIComponent Sender)
{
	local int i, RuleIdx;
	local string Str, DataStr, QueryStr, Width, MinMax, MinV, MaxV;
	local array<string> Ar;
	local GUIMenuOption Changed;

//SetUTracing(True);
	Changed = li_Rules.Get();
	if (Changed == None)
		return;
	log("Changed:"$changed$" caption:"$changed.Caption);

	for (i = 0; i < GamePI.Settings.Length; i++)
		if (InStr(Changed.Caption, GamePI.Settings[i].DisplayName) != -1)
			break;

	if (i == GamePI.Settings.Length)
	{
		Warn("Could not find a PlayInfo setting matching caption:"$Changed.Caption);
		return;
	}

	if ( moCheckBox(Changed) != None )
	{
		RuleIdx = FilterMaster.AllFilters[p_Anchor.Index].FindRuleIndex(GamePI.Settings[i].SettingName);
		DataStr = "DT_Unique";
		Str = string(moCheckbox(Changed).IsChecked());
		GamePI.StoreSetting(i, Str);
	}

	else if ( moComboBox(Changed) != None )
	{
		RuleIdx = FilterMaster.AllFilters[p_Anchor.Index].FindRuleIndex(GamePI.Settings[i].SettingName);
		DataStr = "DT_Unique";
		Str = moComboBox(Changed).GetExtra();
		GamePI.StoreSetting(i, Str);
	}

	else if ( moEditBox(Changed) != None )
	{
		RuleIdx = FilterMaster.AllFilters[p_Anchor.Index].FindRuleIndex(GamePI.Settings[i].SettingName);
		DataStr = "DT_Unique";
		Str = moEditbox(Changed).GetText();
		GamePI.StoreSetting(i, Str);
	}

	else if ( moNumericEdit(Changed) != None )
	{
		DataStr = "DT_Ranged";
		Str = string(moNumericEdit(Changed).GetValue());

		// Disassemble the stored PlayInfo data
		Divide(GamePI.Settings[i].Data, ";", Width, MinMax);
		Divide(MinMax, ":", MinV, MaxV);
		GamePI.SplitStringToArray(Ar, Width, ",");

		if (Right(Changed.Caption, 3) == "Min")
		{
			RuleIdx = FilterMaster.AllFilters[p_Anchor.Index].FindRuleIndex(GamePI.Settings[i].SettingName, "0");

			Ar[1] = Str;
			if (Ar.Length < 3)
				Ar[2] = MaxV;

			Str = "0";
		}

		else if (Right(Changed.Caption, 3) == "Max")
		{
			RuleIdx = FilterMaster.AllFilters[p_Anchor.Index].FindRuleIndex(GamePI.Settings[i].SettingName, "1");
			if (Ar.Length < 3)
				Ar[1] = MinV;

			Ar[2] = Str;
			Str = "1";
		}

		GamePI.StoreSetting(i, "0", Ar[0] $ "," $ Ar[1] $ "," $ Ar[2] $ ";" $ MinV $ ":" $ MaxV);

	}

	else if ( moFloatEdit(Changed) != None )
	{
		DataStr = "DT_Ranged";
		Str = string(moFloatEdit(Changed).GetValue());

		// Disassemble the stored PlayInfo data
		Divide(GamePI.Settings[i].Data, ";", Width, MinMax);
		Divide(MinMax, ":", MinV, MaxV);
		GamePI.SplitStringToArray(Ar, Width, ",");

		if (Right(Changed.Caption, 3) == "Min")
		{
			RuleIdx = FilterMaster.AllFilters[p_Anchor.Index].FindRuleIndex(GamePI.Settings[i].SettingName, "0");
			Ar[1] = Str;
			if (Ar.Length < 3)
				Ar[2] = MaxV;

			Str = "0";
		}

		else if (Right(Changed.Caption, 3) == "Max")
		{
			RuleIdx = FilterMaster.AllFilters[p_Anchor.Index].FindRuleIndex(GamePI.Settings[i].SettingName, "1");
			if (Ar.Length < 3)
				Ar[1] = MinV;

			Ar[2] = Str;
			Str = "1";
		}

		GamePI.StoreSetting(i, "0", Ar[0] $ "," $ Ar[1] $ "," $ Ar[2] $ ";" $ MinV $ ":" $ MaxV);
	}

//	QueryStr = moCombobox(li_RuleFilter.Get()).GetExtra();
	FilterMaster.SetRule(	p_Anchor.Index, RuleIdx,
							GamePI.Settings[i].DisplayName,
							GamePI.Settings[i].SettingName,
							Str,
							DataStr,
							QueryStr,
							GamePI.Settings[i].Data	);
//SetUTracing(False);
}
*/

defaultproperties
{
     EnableRule="Enable this filter"
     MaxText="Max"
     MinText="Min"
     Begin Object Class=GUIMultiOptionListBox Name=RuleBox
         bVisibleWhenEmpty=True
         OnCreateComponent=RuleBox.InternalOnCreateComponent
         WinWidth=0.750000
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
         OnChange=UT2K4FilterRulesPanel.InternalOnChange
     End Object
     lb_Rules=GUIMultiOptionListBox'GUI2K4.UT2K4FilterRulesPanel.RuleBox'

}
