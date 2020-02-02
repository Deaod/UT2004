// ====================================================================
//  Class:  MultiSelectList
//
//  The MultiSelectList is a list component that allows selection of
//  more than one Item.
//
//  Written by Bruce Bickar
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class MultiSelectList extends GUIList
		Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var	array<MultiSelectListElem> MElements;

function Add(string NewItem, optional Object obj, optional string Str, optional bool bSection)
{
	local int NewIndex;

	if ( !bAllowEmptyItems && NewItem == "" && Obj == None && Str == "" )
		return;

	if (bSorted && MElements.Length > 0)
	{
		while (NewIndex < MElements.Length && MElements[NewIndex].Item < NewItem)
			NewIndex++;
	}
	else NewIndex = MElements.Length;

	MElements.Insert(NewIndex, 1);

	MElements[NewIndex].Item=NewItem;
	MElements[NewIndex].ExtraData=obj;
	MElements[NewIndex].ExtraStrData=Str;
	MElements[NewIndex].bSelected=False;
	MElements[NewIndex].bSection=bSection;

	ItemCount = MElements.Length;

	//if (MElements.Length == 1)
	//	SetIndex(0);
	//else
	//	OnChange(self);

	if (MyScrollBar != None)
		MyScrollBar.AlignThumb();
}

function Replace(int index, string NewItem, optional Object obj, optional string Str, optional bool bNoSort)
{
	if ( !IsValidIndex(Index) )
		Add(NewItem,Obj,Str);
	else
	{
		if ( !bAllowEmptyItems && NewItem == "" && Obj == None && Str == "" )
			return;

		MElements[Index].Item = NewItem;
		MElements[Index].ExtraData = obj;
		MElements[Index].ExtraStrData = Str;
		MElements[Index].bSelected = false;
		if (bSorted)
			Sort();

		OnChange(Self);
	}
}

function Insert(int Index, string NewItem, optional Object obj, optional string Str, optional bool bNoSort, optional bool bSection)
{
	if ( !IsValidIndex(Index) )
		Add(NewItem,Obj,Str);
	else
	{
		if ( !bAllowEmptyItems && NewItem == "" && Obj == None && Str == "" )
			return;

		MElements.Insert(index,1);
		MElements[Index].Item=NewItem;
		MElements[Index].ExtraData=obj;
		MElements[Index].ExtraStrData=Str;
		MElements[Index].bSection=bSection;
		MElements[Index].bSelected=false;

		ItemCount=MElements.Length;
		if (bSorted)
			Sort();

		OnChange(self);
		if (MyScrollBar != None)
			MyScrollBar.AlignThumb();
	}
}

event Swap(int IndexA, int IndexB)
{
	local MultiSelectListElem elem;

	if ( IsValidIndex(IndexA) && IsValidIndex(IndexB) )
	{
		elem = MElements[IndexA];
		MElements[IndexA] = MElements[IndexB];
		MElements[IndexB] = elem;

		if (bSorted)
			Sort();
	}
}

function LoadFrom(GUIList Source, optional bool bClearFirst)
{
	local string t1,t2;
	local object t;
	local int i;

    if(MultiSelectList(Source) == None)
		return;  // Source must be a MultiSelectList also

	if (bClearfirst)
		Clear();

	for (i=0;i<MultiSelectList(Source).MElements.Length;i++)
	{
		MultiSelectList(Source).GetAtIndex(i,t1,t,t2);
		Add(t1,t,t2);
	}
}

function int Remove(int i, int Count, bool bNoSort)
{
	if (Count==0)
		Count=1;

	if (!IsValidIndex(i))
		return Index;

	MElements.Remove(i, Count);

	ItemCount = MElements.Length;

	if (bSorted)
		Sort();

	SetIndex(-1);
	if (MyScrollBar != None)
		MyScrollBar.AlignThumb();

	return Index;
}

function Clear()
{
	if (MElements.Length == 0)
		return;

	MElements.Remove(0,MElements.Length);
	ItemCount = 0;
	Super.Clear();
}

function string Get(optional bool bGuarantee)
{
	local string CSVString;
	local int i;

	for(i=0; i<MElements.Length; i++)
	{
		if(MElements[i].bSelected)
		{
			if(CSVString == "")
				CSVString = MElements[i].Item;
			else
				CSVString = CSVString $ "," $ MElements[i].Item;
		}
	}

	return CSVString;
}

function object GetObject()
{
	if ( !IsValid() )
		return none;
	else
		return MElements[Index].ExtraData;
}

function bool IsSection()
{
	if ( !IsValid() )
		return false;
	else
		return MElements[Index].bSection;
}
function string GetExtra()
{
	local string CSVString;
	local int i;

	for(i=0; i<MElements.Length; i++)
	{
		if(MElements[i].bSelected)
		{
			if(CSVString == "")
				CSVString = MElements[i].ExtraStrData;
			else
				CSVString = CSVString $ "," $ MElements[i].ExtraStrData;
		}
	}

	return CSVString;
}

function string GetItemAtIndex(int i)
{
	if (!IsValidIndex(i))
		return "";

	return MElements[i].Item;
}

function object GetObjectAtIndex(int i)
{
	if (!IsValidIndex(i))
		return None;

	return MElements[i].ExtraData;
}

function string GetExtraAtIndex(int i)
{
	if (!IsValidIndex(i))
		return "";

	return MElements[i].ExtraStrData;
}

function GetAtIndex(int i, out string ItemStr, out object ExtraObj, out string ExtraStr)
{
	if (!IsValidIndex(i))
		return;

	ItemStr = MElements[i].Item;
	ExtraObj = MElements[i].ExtraData;
	ExtraStr = MElements[i].ExtraStrData;
}

function array<string> GetPendingItems(optional bool bGuarantee)
{
	local array<string> Items;
/*	local int i;

	for ( i = 0; i < SourceIndex.Length; i++ )
		if ( IsValidIndex(SourceIndex[i]) )
			Items[Items.Length] = Elements[SourceIndex[i]].Item;

	if ( Items.Length == 0 && IsValid() )
		Items[0] = Get();
*/
	return Items;
}

function array<GUIListElem> GetPendingElements(optional bool bGuarantee)
{
	local array<GUIListElem> PendingItem;
/*	local int i;

	for (i = 0; i < SourceIndex.Length; i++)
		if (IsValidIndex(SourceIndex[i]))
			PendingItem[PendingItem.Length] = Elements[SourceIndex[i]];
*/
	return PendingItem;
}

function SetItemAtIndex(int i, string NewItem)
{
	if (!IsValidIndex(i))
		return;

	MElements[i].Item = NewItem;
}

function SetObjectAtIndex(int i, Object NewObject)
{
	if (!IsValidIndex(i))
		return;

	MElements[i].ExtraData = NewObject;
}

function SetExtraAtIndex(int i, string NewExtra)
{
	if (!IsValidIndex(i))
		return;

	MElements[i].ExtraStrData = NewExtra;
}

function RemoveItem(string Item)
{
	local int i;

	// Work through array. If we find it, remove it (will reduce Elements.Length).
	// If we don't, move on to next one.
	while( i < MElements.Length)
	{
		if(Item ~= MElements[i].Item)
			MElements.Remove(i, 1);
		else
			i++;
	}

	ItemCount = MElements.Length;

	SetIndex(-1);
	if (MyScrollBar != None)
		MyScrollBar.AlignThumb();
}

function RemoveObject(Object Obj)
{
	local int i;

	while (i < MElements.Length)
	{
		if (Obj == MElements[i].ExtraData)
			MElements.Remove(i, 1);
		else i++;
	}

	ItemCount = MElements.Length;

	SetIndex(-1);
	if (MyScrollBar != None)
		MyScrollBar.AlignThumb();
}

function RemoveExtra(string Str)
{
	local int i;

	while (i < MElements.Length)
	{
		if (Str ~= MElements[i].ExtraStrData)
			MElements.Remove(i, 1);
		else i++;
	}

	ItemCount = MElements.Length;

	SetIndex(-1);
	if (MyScrollBar != None)
		MyScrollBar.AlignThumb();
}

function string Find(string Text, optional bool bExact, optional bool bExtra)
{
	local int i;

	i = FindIndex(Text, bExact, bExtra);
	if (i != -1)
	{
		SetIndex(i);
		return MElements[i].Item;
	}

	return "";
}

function int FindIndex(string Test, optional bool bExact, optional bool bExtra, optional Object TestObject)
{
	local int i;

	if (TestObject != None)
	{
		for (i = 0; i < MElements.Length; i++)
			if ( TestObject == MElements[i].ExtraData )
				return i;
	}

	else if (Test != "")
	{
		if (bExtra)
		{
			for (i = 0; i < MElements.Length; i++)
				if ( (bExact && MElements[i].ExtraStrData == Test) || (!bExact && MElements[i].ExtraStrData ~= Test) )
					return i;
		}

		else
		{
			for ( i = 0; i < MElements.Length; i++)
				if ( (bExact && MElements[i].Item == Test) || (!bExact && MElements[i].Item ~= Test) )
					return i;
		}
	}

	return -1;
}

function int SetIndex(int NewIndex)
{
    if (NewIndex < 0 || NewIndex >= ItemCount)
        Index = -1;
    else
	{
        Index = NewIndex;
		MElements[Index].bSelected = !MElements[Index].bSelected;
	}

    if ( (index>=0) && (ItemsPerPage>0) )
    {
        if (Index<top)
            SetTopItem(Index);

        if (ItemsPerPage != 0 && Index==Top+ItemsPerPage)
            SetTopItem(Index - ItemsPerPage + 1);
    }

    OnChange(self);
    return Index;
}

defaultproperties
{
}
