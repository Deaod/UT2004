//==============================================================================
//	Base class for custom server browser filters
//
//	Created by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class CustomFilter extends Object
	DependsOn(MasterServerClient)
	Config(ServerFilters)
	PerObjectConfig;

enum EDataType
{
	DT_Unique,		// Only one item with this key can exist
	DT_Ranged,		// Max of two items with this key can exist, and QueryType cannot be QT_Equals
	DT_Multiple		// Allow multiple items with the same name
};

struct AFilterRule
{
	var MasterServerClient.QueryData 	FilterItem;	// Key, Value, QueryType
	var EDataType						FilterType;
	var string							ItemName;	// FriendlyName
};

struct CurrentFilter
{
	var AFilterRule	Item;
	var int ItemIndex;			// Index of item
};

var protected config array<AFilterRule>	Rules;
var protected config string             DefaultTitle;
var protected config bool               Active;

var protected array<CurrentFilter>		AllRules;
var protected string                    Title;
var protected bool                      bEnabled;

var protected bool                      bDirty;


function Created()
{
	CancelChanges();
}

function CancelChanges()
{
	Title = DefaultTitle;
	bEnabled = Active;
	InitializeRules();

	bDirty = False;
}

// Initialize all stored rules into the instance set
protected function InitializeRules()
{
	local int i;

	if (AllRules.Length > 0)
		AllRules.Remove(0, AllRules.Length);

	// Create working set of rules from stored values
	for (i = 0; i < Rules.Length; i++)
		AddRule(Rules[i].ItemName, Rules[i].FilterItem.Key, Rules[i].FilterItem.Value, Rules[i].FilterItem.QueryType, Rules[i].FilterType);
}

function bool SetTitle( string NewTitle )
{
	bDirty = bDirty || NewTitle != Title;
	Title = NewTitle;
	return true;
}

function bool SetActive( bool NewActive )
{
	bDirty = bDirty || NewActive != bEnabled;
	bEnabled = NewActive;
	return true;
}

function SetRules( array<CurrentFilter> NewRules )
{
	AllRules = NewRules;
	bDirty = True;
}



function string GetTitle()
{
	return Title;
}

function bool IsActive()
{
	return bEnabled;
}

function GetQueryRules( out array<AFilterRule> OutRules )
{
	Save();
	OutRules = Rules;
}

function GetRules( out array<CurrentFilter> OutRules )
{
	OutRules = AllRules;
}

function Save( optional bool bForceSave )
{
	local int i;
	if ( bDirty || bForceSave )
	{
		DefaultTitle = Title;
		Active = bEnabled;

		if ( Rules.Length > 0 )
			Rules.Remove(0, Rules.Length);

		for (i = 0; i < AllRules.Length; i++)
			Rules[Rules.Length] = AllRules[i].Item;

		SaveConfig();
	}

	bDirty = False;
}

//==============================================================================
//
// Query functions
//

function int Count()
{
	return AllRules.Length;
}

function bool FindRule( out AFilterRule Rule, string ItemName, optional string Value )
{
	local int i;

	i = FindRuleIndex(ItemName,Value);
	return GetRule(i, Rule);
}

function bool GetRule( int Index, out AFilterRule Rule )
{
	if ( ValidIndex(Index) )
	{
		Rule = AllRules[Index].Item;
		return True;
	}

	return False;
}

function int FindRuleIndex(string ItemName, optional string Value)
{
	local int i, j;

	j = InStr(ItemName, ".");
	if (j != -1)
		ItemName = Mid(ItemName, j+1);

	for (i = 0; i < AllRules.Length; i++)
		if (AllRules[i].Item.FilterItem.Key ~= ItemName)
		{
			if (Value == "" || (Value != "" && Value ~= AllRules[i].Item.FilterItem.Value))
				return i;
		}

	return -1;
}

// This function returns index for an item name and ItemIndex (for finding the absolute index of multi-items)
function int FindItemIndex(string ItemName, int ItemIndex)
{
	local int i;

	for (i = 0; i < AllRules.Length; i++)
		if (AllRules[i].Item.FilterItem.Key ~= ItemName && AllRules[i].ItemIndex == ItemIndex)
			return i;

	return -1;
}

protected function int FindLastIndex(string ItemName)
{
	local int i, j;

	j = -1;
	for (i = 0; i < AllRules.Length; i++)
	{
		if (AllRules[i].Item.FilterItem.Key ~= ItemName && AllRules[i].ItemIndex > j)
			j = AllRules[i].ItemIndex;
	}

	return j;
}

function int FindInnerIndex(string ItemName, string Value)
{
	local int i, j;

	j = InStr(ItemName, ".");
	if (j != -1)
		ItemName = Mid(ItemName, j+1);

	for (i = 0; i < AllRules.Length; i++)
		if (AllRules[i].Item.FilterItem.Key ~= ItemName && AllRules[i].Item.FilterItem.Value ~= Value)
			return AllRules[i].ItemIndex;

	return -1;
}

function string GetRuleKey(int Index)
{
	if (ValidIndex(Index))
		return AllRules[Index].Item.FilterItem.Key;

	return "";
}

function string GetRuleType(int Index)
{
	if (ValidIndex(Index))
		return GetDataTypeString(AllRules[Index].Item.FilterType);

	return "";
}

function string GetRuleQueryType( int Index )
{
	if ( ValidIndex(Index) )
		return string(GetEnum(enum'EQueryType', AllRules[Index].Item.FilterItem.QueryType));

	return "";
}

// Returns all values for a rule - works for single and multiple rules
function array<string> GetRuleValues(int Index)
{
	local int i;
	local array<string> Ar;
	local array<CurrentFilter> Subset;

	Subset = GetRuleSetAt(Index);

	for (i = 0; i < Subset.Length; i++)
		Ar[i] = Subset[i].Item.FilterItem.Value;

	return Ar;
}

function array<CurrentFilter> GetRuleSet(string ItemName)
{
	local int i;
	local array<CurrentFilter> RuleAr;

	ChopClass(ItemName);

	for (i = 0; i < AllRules.Length; i++)
		if (AllRules[i].Item.FilterItem.Key ~= ItemName)
			RuleAr[RuleAr.Length] = AllRules[i];

	return RuleAr;
}

function array<CurrentFilter> GetRuleSetAt(int Index)
{
	local array<CurrentFilter> RuleAr;

	if (ValidIndex(Index))
		RuleAr = GetRuleSet(AllRules[Index].Item.FilterItem.Key);

 return RuleAr;
}

function PostEdit(string NewTitle, array<CustomFilter.AFilterRule> NewRules)
{
	local int i;
	AllRules.Remove(0,AllRules.Length);
	Title = NewTitle;
	for (i=0;i<NewRules.Length;i++)
		AddRule(NewRules[i].ItemName,NewRules[i].FilterItem.Key, NewRules[i].FilterItem.Value, NewRules[i].FilterItem.QueryType, NewRules[i].FilterType);

	bDirty = true;
	Save();
}

function float AddRule(string NewName, string NewKey, string NewValue, MasterServerClient.EQueryType QType, EDataType DType)
{
	local int i, j;
	local CurrentFilter					NewRule;
	local AFilterRule					NewItem;
	local MasterServerClient.QueryData	KeyPair;


	j = FindLastIndex(NewKey);
	NewRule.ItemIndex = j+1;

	i = AllRules.Length;

	// Not found, so just add it
	KeyPair.Key = NewKey;
	KeyPair.Value = NewValue;
	KeyPair.QueryType = QType;

	NewItem.ItemName = NewName;
	NewItem.FilterItem = KeyPair;
	NewItem.FilterType = DType;

	NewRule.Item = NewItem;
	AllRules[i] = NewRule;

	bDirty = True;
	return i;
}


function bool RemoveRule(string ItemName)
{
	local int i;
	local bool bSuccess;

	for ( i = AllRules.Length - 1; i >= 0; i-- )
	{
		if (AllRules[i].Item.FilterItem.Key ~= ItemName)
		{
			bDirty = True;
			bSuccess = True;
			AllRules.Remove(i--, 1);
		}
	}
	return bSuccess;
}

function bool RemoveRuleAt(int Index)
{
	if (ValidIndex(Index))
		return RemoveRule(AllRules[Index].Item.FilterItem.Key);

	return false;
}

//==============================================================================
//
//	Saving & Loading
//

function ImportFilter(CustomFilter ImportFrom)
{
	SetTitle( ImportFrom.GetTitle() );
	SetActive( ImportFrom.IsActive() );

	ImportFrom.GetRules( AllRules );
	bDirty = True;
}

function ResetRules()
{
	CancelChanges();
}

function bool ChangeRule(int Index, string NewTag, string NewValue, MasterServerClient.EQueryType NewType)
{
	if (!ValidIndex(Index))
		return false;

	AllRules[Index].Item.ItemName = NewTag;
	AllRules[Index].Item.FilterItem.Value = NewValue;
	AllRules[Index].Item.FilterItem.QueryType = NewType;
	bDirty = True;
	return true;
}

function bool ValidIndex(int Index)
{
	return (Index >= 0 && Index < AllRules.Length);
}

//==============================================================================
//
//	Internal functions
//

static final function EDataType GetDataType(string DT)
{
	switch (DT)
	{
		case "DT_Multiple":	return DT_Multiple;
		case "DT_Ranged":	return DT_Ranged;
		default:			return DT_Unique;
	}
}

static final function string GetDataTypeString(EDataType Type)
{
	if (Type == DT_Unique)
		return "DT_Unique";

	if (Type == DT_Ranged)
		return "DT_Ranged";

	if (Type == DT_Multiple)
		return "DT_Multiple";

	return "";
}

static final function string GetQueryString(MasterServerClient.EQueryType QT)
{
	switch (QT)
	{
		case QT_Equals:				return "QT_Equals";
		case QT_NotEquals:			return "QT_NotEquals";
		case QT_LessThan:			return "QT_LessThan";
		case QT_LessThanEquals:		return "QT_LessThanEquals";
		case QT_GreaterThan:		return "QT_GreaterThan";
		case QT_GreaterThanEquals:	return "QT_GreaterThanEquals";
		default:					return "QT_Disabled";
	}

	return "";
}

static final function MasterServerClient.EQueryType GetQueryType(string QT)
{
	switch (QT)
	{
		case "QT_Equals":				return QT_Equals;
		case "QT_NotEquals":			return QT_NotEquals;
		case "QT_LessThan":				return QT_LessThan;
		case "QT_LessThanEquals":		return QT_LessThanEquals;
		case "QT_GreaterThan":			return QT_GreaterThan;
		case "QT_GreaterThanEquals":	return QT_GreaterThanEquals;
		default:						return QT_Disabled;
	}
}

static final function AFilterRule StaticGenerateRule(string FriendlyName, string ItemName, string ItemVal, EDataType ItemDataType, MasterServerClient.EQueryType ItemQueryType)
{
	local AFilterRule					NewItem;
	local MasterServerClient.QueryData	KeyPair;

	KeyPair.Key = ItemName;
	KeyPair.Value = ItemVal;
	KeyPair.QueryType = ItemQueryType;

	NewItem.ItemName = FriendlyName;
	NewItem.FilterItem = KeyPair;
	NewItem.FilterType = ItemDataType;

	return NewItem;
}

protected function string GetUniqueName(string Test, int Index)
{
	local int i, j;
	local string S;

	for (i = 0; i < AllRules.Length; i++)
	{
		if ( AllRules[i].ItemIndex == Index && AllRules[i].Item.ItemName ~= (Test $ S) )
		{
			S = " " $ string(++j);
			i = -1;
		}
	}

	return Test $ S;
}

static final function ChopClass(out string FullName)
{
	local int i;

	i = InStr(FullName, ".");
	while (i >= 0)
	{
		FullName = Mid(FullName, i+1);
		i = InStr(FullName, ".");
	}
}

defaultproperties
{
}
