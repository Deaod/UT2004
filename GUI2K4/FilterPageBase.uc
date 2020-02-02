//==============================================================================
//	Base Class for different filter layouts
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class FilterPageBase extends LargeWindow;

var globalconfig		float			FilterSplitterPosition;
var	BrowserFilters 						FM;
var	GUIMultiOptionList					li_Filter;
var UT2K4FilterControlPanel				cp_Filter;
var int									Index;		// BrowserFilter index of selected filter
var array<CacheManager.MutatorRecord> 			MutatorRecords;
var automated	GUISplitter				sp_Filter;
var	automated	GUIImage				i_BG;

var bool								bNeedRefresh;
var localized	string					SaveString;
var string								CurrentGameType;

function InitComponent(GUIController MyC, GUIComponent MyO)
{
	Super.InitComponent(MyC, MyO);
	li_Filter = cp_Filter.li_Filters;
}

function ApplyRules(int FilterIndex, optional bool bRefresh);
function int FindFilterMasterIndex(int i)
{
	return FM.FindFilterIndex(li_Filter.GetItem(i).Caption);
}

event Opened(GUIComponent Sender)
{
	CheckFM();
	Super.Opened(Sender);

	InitFilterList();
}

// TODO: this function needs to be improved.
function CreateTemplateFilter(string TemplateName, array<GameInfo.KeyValuePair> RuleSet)
{
	local int i, idx;
	local string QueryType, RuleType;


	AddNewFilter(TemplateName);
	idx = FM.FindFilterIndex(TemplateName);

	for (i = 0; i < RuleSet.Length; i++)
	{
		if ( !CreateTemplateRule( RuleSet[i], QueryType, RuleType ) )
			continue;

		FM.SetRule(idx, -1, "", RuleSet[i].Key, RuleSet[i].Value, RuleType, QueryType);
	}

	li_Filter.SetIndex(idx);
}

// If valid parameters are updated in the master server, they must also be updated here.
function bool CreateTemplateRule( out GameInfo.KeyValuePair Rule, out string QueryType, out string RuleType )
{
	if ( Rule.Key ~= "IP" || Rule.Key ~= "adminname" || Rule.Key ~= "adminemail" )
		return false;

	if ( IsNumber(Rule.Value) )
	{
		RuleType = "DT_Ranged";
		QueryType = "QT_LessThanEquals";
	}

	else if ( Rule.Value ~= "true" || Rule.Value ~= "false" )
	{
		RuleType = "DT_Unique";
		QueryType = "QT_Equals";
	}

	else if ( Rule.Key ~= "mutator" )
	{
		RuleType = "DT_Multiple";
		QueryType = "QT_Equals";
	}

	else
	{
		RuleType = "DT_Unique";
		QueryType = "QT_Equals";
	}

	return true;
}

function bool IsNumber(string Test)
{
	if (int(Test) == 0 && Left(Test,1) != "0")
		return false;

	return true;
}

function InitFilterList()
{
	local array<string> FilterNames;
	local moCheckbox ch;
	local int i;

	li_Filter.Clear();
	FilterNames = FM.GetFilterNames();
	for (i = 0; i < FilterNames.Length; i++)
	{
		ch = moCheckBox(li_Filter.AddItem("XInterface.moCheckbox",,FilterNames[i]));
		if (ch != None)
			ch.Checked(FM.IsActiveAt(i));
	}
}

function bool AddNewFilter(out string NewFilterName, optional bool bFocus)
{
	if ( FM.AddCustomFilter(NewFilterName) )
	{
		li_Filter.AddItem( "XInterface.moCheckBox",,NewFilterName );
		if ( bFocus )
			li_Filter.SetIndex( li_Filter.Find(NewFilterName) );

		return true;
	}

	return false;
}

function bool RemoveExistingFilter(string FilterName)
{
	if (FilterName != "" && li_Filter.ValidIndex(li_Filter.Index))
	{
		if ( FM.RemoveFilter(FilterName) )
		{
			li_Filter.RemoveItem(li_Filter.Index);
			return true;
		}
	}

	return false;
}

function bool RenameFilter(int Index, string NewName)
{
	if (li_Filter.ValidIndex(Index) && NewName != "")
	{
		if (FM.RenameFilter(Index, NewName))
		{
			li_Filter.Get().SetCaption(NewName);
			return true;
		}
	}

	return false;
}

function bool CopyFilter( int Index, out string NewName )
{
	if ( li_Filter.ValidIndex(Index) && NewName != "" )
	{
		if ( FM.CopyFilter(Index, NewName) )
		{
			li_Filter.AddItem( "XInterface.moCheckbox",,NewName );
			li_Filter.SetIndex( li_Filter.Find(NewName) );
			return true;
		}
	}

	return false;
}

function SaveFilters()
{
	FM.SaveFilters();
}

function ResetFilters()
{
	FM.ResetFilters();
	InitFilterList();
}

function CheckFM()
{
	if (FM == None)
		FM = UT2K4ServerBrowser(ParentPage).FilterMaster;
}

function InternalOnChange(GUIComponent Sender)
{
	local int i;
	local moCheckbox Sent;

	if (Sender == li_Filter)	// selected a different filter
	{
		if (li_Filter.ValidIndex(li_Filter.Index))
		{
			Sent = moCheckbox(li_Filter.Get());

			i = FM.FindFilterIndex(Sent.Caption);
			if (Sent.IsChecked() != FM.IsActiveAt(i))
				FM.ActivateFilter(i,Sent.IsChecked());

			ApplyRules(i);
		}

		else ApplyRules(-1);
	}
}

event Closed(GUIComponent Sender, bool bCancelled)
{
	if ( bCancelled )
		FM.ResetFilters();

	else
	{
		SaveFilters();
		Index = -1;
		bNeedRefresh = True;
	}

	Super.Closed(Sender,bCancelled);
}

// Splitter delegates
function InternalOnLoad(GUIComponent Sender, string S)
{
	if (Sender == sp_Filter)
		sp_Filter.SplitPosition = FilterSplitterPosition;
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
	if (GUISplitter(Sender) != None)
	{
		if (UT2K4FilterControlPanel(NewComp) != None)
		{
			cp_Filter = UT2K4FilterControlPanel(NewComp);
			cp_Filter.p_Anchor = Self;
			cp_Filter.OnChange = InternalOnChange;
		}
	}

	if ( Sender == Self )
		Super.InternalOnCreateComponent(NewComp,Sender);
}

defaultproperties
{
     FilterSplitterPosition=0.369766
     Index=-1
     SaveString="Setting saved successfully!"
     OnCreateComponent=FilterPageBase.InternalOnCreateComponent
     StyleName="TabBackground"
     WinTop=0.036198
     WinLeft=0.040430
     WinWidth=0.909375
     WinHeight=0.904492
}
