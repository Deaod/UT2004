//==============================================================================
//	GUI-wide filter manager - this class provides interaction with filter information
//	across all components that access filters
//
//	Created by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class BrowserFilters extends Object
	Within UT2K4ServerBrowser
	DependsOn(CustomFilter)
	Config(User);

var() config string					CustomFilterClass;
var class<CustomFilter>				FilterClass;

var bool							bInvalidFilterClass;	// Used to tell when we cannot use filters
var transient array<CustomFilter>	AllFilters, Deleted;

//
//	Custom Filter Management
//

// Create all filter classes
function InitCustomFilters()
{
	local int i;
	local CustomFilter Temp;
	local array<string> CustomFilterNames;

	if ( AllFilters.Length > 0 )
		AllFilters.Remove(0, AllFilters.Length);

	if (FilterClass == None)
		FilterClass = class<CustomFilter>(DynamicLoadObject(CustomFilterClass, class'Class'));

	if (FilterClass == None)
	{
		Warn("Invalid custom filter class specified:"@CustomFilterClass);
		bInvalidFilterClass = True;
		return;
	}

	// Restore any filters that were deleted (would happen if filters were deleted, but changes weren't applied)
	for ( i = 0; i < Deleted.Length; i++ )
		Deleted[i].Save(True);

	if ( Deleted.Length > 0 )
		Deleted.Remove(0, Deleted.Length);


	CustomFilterNames = GetPerObjectNames( "ServerFilters", GetItemName(CustomFilterClass) );
	for (i = 0; i < CustomFilterNames.Length && i < 1000; i++)
	{
		Temp = CreateFilter( CustomFilterNames[i] );
		AllFilters[AllFilters.Length] = Temp;
	}
}

protected function CustomFilter CreateFilter( string FilterName )
{
	if ( !ValidName(FilterName) )
		return None;

	return new(None, Repl( FilterName, " ", Chr(27))) FilterClass;
}

function bool AddCustomFilter(out string NewFilterName)
{
	local int i;
	local string Str;
	local CustomFilter NewFilter;

	if ( !ValidName(NewFilterName) )
		return false;

	Str = NewFilterName;
	while ( HasFilterNamed(NewFilterName) )
		NewFilterName = Str $ i++;

	NewFilter = CreateFilter( NewFilterName );
	if ( NewFilter == None )
		return false;

	NewFilter.SetTitle(NewFilterName);
	AllFilters[AllFilters.Length] = NewFilter;
	return true;
}

function bool CopyFilter( int Index, out string NewFilterName )
{
	local int i;

	if ( ValidIndex(Index) && AddCustomFilter(NewFilterName) )
	{
		i = FindFilterIndex(NewFilterName);
		AllFilters[i].ImportFilter( AllFilters[Index] );
		AllFilters[i].SetTitle(NewFilterName);
		return true;
	}

	return false;
}

function bool RemoveFilter(string FilterName)
{
	local int i;

	if (!ValidName(FilterName))
		return false;

	i = FindFilterIndex(FilterName);
	if (i < 0) return false;
	return RemoveFilterAt(i);
}

function bool RemoveFilterAt( int Index )
{
	Deleted[Deleted.Length] = AllFilters[Index];
	AllFilters[Index].ClearConfig();
	AllFilters.Remove(Index, 1);
	return true;
}

function SaveFilters()
{
	local int i;

	if ( Deleted.Length >  0 )
		Deleted.Remove( 0, Deleted.Length );

	for (i = 0; i < AllFilters.Length; i++)
		AllFilters[i].Save();
}

function ResetFilters()
{
	InitCustomFilters();
}

function bool RenameFilter(int Index, string NewName)
{
	local string Str;
	local CustomFilter NewFilter;
	local int i;

	if (!ValidIndex(Index) || !ValidName(NewName))
		return false;

	Str = NewName;
	while ( HasFilterNamed(NewName) )
		NewName = Str $ i++;

	NewFilter = CreateFilter(NewName);
	if ( NewFilter == None )
		return false;

	NewFilter.ImportFilter( AllFilters[Index] );
	NewFilter.SetTitle( NewName );
	RemoveFilterAt(Index);

	AllFilters.Insert(Index,1);
	AllFilters[Index] = NewFilter;

	return true;
}

function bool ActivateFilter(int Index, bool Enable)
{
	if (!ValidIndex(Index))
		return false;

	if (IsActive(AllFilters[Index]) == Enable)
		return false;

	return AllFilters[Index].SetActive(Enable);
}

function bool IsActive(CustomFilter Test)
{
	if (Test == None)
		return false;

	return Test.IsActive();
}

function bool IsActiveAt(int Index)
{
	if (!ValidIndex(Index))
		return false;

	return AllFilters[Index].IsActive();
}

//==============================================================================
//
// Loading / Saving data
//
function LoadSettings(int FilterIndex)
{
}

//==============================================================================
//
// Query functions
//

function string GetFilterName(int Index)
{
	if (!ValidIndex(Index))
		return "";

	return AllFilters[Index].GetTitle();
}

function array<CustomFilter.AFilterRule> GetFilterRules(int Index)
{
	local array<CustomFilter.AFilterRule>	FilterRules;

	if (ValidIndex(Index))
		AllFilters[Index].GetQueryRules(FilterRules);

	return FilterRules;
}

function array<CustomFilter.CurrentFilter> GetFilterARules(int Index)
{
	local array<CustomFilter.CurrentFilter>	FilterRules;

	if (ValidIndex(Index))
		AllFilters[Index].GetRules(FilterRules);

	return FilterRules;
}


function PostEdit(int Index, string NewTitle, array<CustomFilter.AFilterRule> NewRules)
{
	if (ValidIndex(Index))
		AllFilters[Index].PostEdit(NewTitle,NewRules);
}

function array<string> GetFilterNames(optional bool bActiveOnly)
{
	local int i;
	local array<string> FilterNames;

	for (i = 0; i < AllFilters.Length; i++)
	{
		if ( bActiveOnly && !AllFilters[i].IsActive() )
			continue;

		FilterNames[i] = AllFilters[i].GetTitle();
	}

	return FilterNames;
}

//==============================================================================
//
//	Assignment functions
//

function SetRule(int FilterIndex, int RuleIndex, string RuleTag, string RuleItem, string RuleValue, string DataType, string QueryType, optional string ExtraData)
{
	local int i;
	local string Data, MinMax, MinV, MaxV;
	local array<string> Ar;

//	log(Name@"SetRule FilterIndex:"$FilterIndex@"RuleIndex:"$RuleIndex@"RuleTag:"$RuleTag@"RuleItem:"$RuleItem@"RuleValue:"$RuleValue@"DataType:"$DataType@"QueryType:"$QueryType@"ExtraData:"$ExtraData);
	if (ValidIndex(FilterIndex))
	{
	// Remove the class name
		class'CustomFilter'.static.ChopClass(RuleItem);

		if (DataType == "DT_Ranged" && ExtraData != "")
		{

			Divide(ExtraData, ";", Data, MinMax);
			FilterInfo.SplitStringToArray(Ar, Data, ",");

			if (Ar.Length < 3)
			{
				Divide(MinMax, ":", MinV, MaxV);
				Ar[1] = MinV;
				Ar[2] = MaxV;
			}

			if (RuleValue == "0")
			{
				if (RuleIndex < 0)
					AllFilters[FilterIndex].AddRule(RuleTag, RuleItem, Ar[1], AllFilters[FilterIndex].GetQueryType(QueryType), AllFilters[FilterIndex].GetDataType(DataType));
				else AllFilters[FilterIndex].ChangeRule(RuleIndex, RuleTag, Ar[1], AllFilters[FilterIndex].GetQueryType(QueryType));
			}

			else if (RuleValue == "1")
			{
				if (RuleIndex < 0)
					AllFilters[FilterIndex].AddRule(RuleTag, RuleItem, Ar[2], AllFilters[FilterIndex].GetQueryType(QueryType), AllFilters[FilterIndex].GetDataType(DataType));

				else AllFilters[FilterIndex].ChangeRule(RuleIndex, RuleTag, Ar[2], AllFilters[FilterIndex].GetQueryType(QueryType));
			}
		}

		else if (DataType == "DT_Multiple")
		{
			FilterInfo.SplitStringToArray(Ar, RuleValue, ",");
			if (RuleIndex < 0)
			{
				for (i = 0; i < Ar.Length; i++)
					AllFilters[FilterIndex].AddRule(RuleTag, RuleItem, Ar[i], AllFilters[FilterIndex].GetQueryType(QueryType), AllFilters[FilterIndex].GetDataType(DataType));
			}
			else AllFilters[FilterIndex].ChangeRule(RuleIndex, RuleTag, Ar[0], AllFilters[FilterIndex].GetQueryType(QueryType));
		}

		else
		{
			if (RuleIndex < 0)
				AllFilters[FilterIndex].AddRule(RuleTag, RuleItem, RuleValue, AllFilters[FilterIndex].GetQueryType(QueryType), AllFilters[FilterIndex].GetDataType(DataType));

			else
				AllFilters[FilterIndex].ChangeRule(RuleIndex, RuleTag, RuleValue, AllFilters[FilterIndex].GetQueryType(QueryType));
		}
	}
}

//==============================================================================
//
//	Internal functions
//

protected function int AddFilter( CustomFilter Filter )
{
	local int i;

	if ( Filter == None )
		return -1;

	i = FindFilterIndex( Filter.GetTitle() );
	if ( i == -1 )
		AllFilters[AllFilters.Length] = Filter;

	return i;
}

protected function bool HasFilterNamed( string FilterName )
{
	return FindFilterIndex(FilterName) != -1;
}

function int FindFilterIndex( string FilterName )
{
	local int i;

	for ( i = 0; i < AllFilters.Length; i++ )
		if ( AllFilters[i].GetTitle() ~= FilterName )
			return i;

	return -1;
}

protected function bool ValidIndex(int Index)
{
	return (Index >= 0 && Index < AllFilters.Length && !bInvalidFilterClass);
}

protected function bool ValidName(string Test)
{
	return (Test != "" && Len(Test) < 1024 && !bInvalidFilterClass);
}

function int Count()
{
	return AllFilters.Length;
}

defaultproperties
{
     CustomFilterClass="GUI2K4.CustomFilter"
}
