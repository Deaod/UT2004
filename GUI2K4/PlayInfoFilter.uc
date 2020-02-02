//==============================================================================
//	Description
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class PlayInfoFilter extends BrowserFilters;

//==============================================================================
//
//	PlayInfo interaction
//

// Set all values in PlayInfo
function LoadSettings(int FilterIndex)
{
	local array<CustomFilter.AFilterRule> FilterRules;
	local int i, j;
//	log(Name@"LoadSettings FilterIndex:"$FilterIndex);

	FilterRules = GetPlayInfoRules(FilterIndex);
	for (j = 0; j < FilterRules.Length; j++)
	{
		i = FilterInfo.FindIndex(FilterRules[j].FilterItem.Key);
//		log(Name@"LoadSettings Name:"$FilterInfo.Settings[i].SettingName@"Settings["$i$"].Data:"$FilterInfo.Settings[i].Data);
		LoadData(FilterIndex, i, FilterRules[j]);
	}
}

function array<CustomFilter.AFilterRule> GetPlayInfoRules(int Index, optional string Group)
{
	local array<CustomFilter.AFilterRule> FilterRules;
	local array<PlayInfo.PlayInfoData>		Scope;
	local int i, j;

	if (ValidIndex(Index))
	{
		if (Group != "")
			FilterInfo.GetSettings(Group, Scope);
		else Scope = FilterInfo.Settings;

		for (i = 0; i < Scope.Length; i++)
		{
			j = AllFilters[Index].FindRuleIndex(Scope[i].SettingName);
			if ( AllFilters[Index].ValidIndex(j) )
			{
				FilterRules.Length = FilterRules.Length + 1;
				AllFilters[Index].GetRule(j,FilterRules[FilterRules.Length-1]);
			}
		}
	}

	return FilterRules;
}

// Moves the stored value of a filter rule into the PlayInfo Setting
function LoadData(int FilterIndex, int PIIndex, CustomFilter.AFilterRule FilterRule)
{
	local int i, j, pos;
	local array<CustomFilter.CurrentFilter> Stored;
	local string Min, Max, OrigRange;

	i = AllFilters[FilterIndex].FindRuleIndex(FilterRule.FilterItem.Key);
	if (i < 0)
		return;

	Stored = AllFilters[FilterIndex].GetRuleSetAt(i);
	if (Stored.Length > 1)
	{
		for (j = 0; j < Stored.Length; j++)
		{
			if (Stored[j].Item.FilterType == DT_Ranged)
			{
				if (Stored[j].ItemIndex == 1)
					Max = Stored[j].Item.FilterItem.Value;
				else Min = Stored[j].Item.FilterItem.Value;
			}
		}

		pos = InStr(FilterInfo.Settings[PIIndex].Data, ";");
		if (pos != -1)
			OrigRange = Mid(FilterInfo.Settings[PIIndex].Data, pos);
//log("Storing"@FilterInfo.Settings[PIIndex].SettingName@"Value: 0 Data:"$"3,"$Min$","$Max$OrigRange);
		FilterInfo.StoreSetting(PIIndex, "0", "3,"$Min$","$Max$OrigRange);
	}
	else if (Stored.Length > 0)
	{
		FilterInfo.StoreSetting(PIIndex, Stored[0].Item.FilterItem.Value);
	}

	else
		log("Unknown property:"$FilterRule.FilterItem.Key);
}

defaultproperties
{
}
