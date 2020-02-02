// ====================================================================
//  The GUIList is a basic list component.
//
//  Written by Joe Wilcox
//	Updated by Ron Prestenback
//  (c) 2002, 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIList extends GUIVertList
		Native;

#exec OBJ LOAD FILE=InterfaceContent.utx

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var()	eTextAlign			TextAlign;			// How is text Aligned in the control
var() editconstarray editconst array<GUIListElem>	Elements;
var() editconstarray editconst array<GUIListElem>  SelectedElements;   // Used to easily support drag-n-drop between the same list

var() color			OfficialColor;		// Used to signify items standard in UT2003
var() color			Official2004Color;	// Used to signify items standard in UT2004
var() color			BonusPackColor;		// Used to signify items standard in BonusPacks

native final function SortList();

function Sort()
{
	Super.Sort();
	SortList();
}

// Used by SortList.
delegate int CompareItem(GUIListElem ElemA, GUIListElem ElemB)
{
	return StrCmp(ElemA.Item, ElemB.Item);
}

// Accessor function for the items.

// Functions for manipulating entire list elements
function Add(string NewItem, optional Object obj, optional string Str, optional bool bSection)
{
	local int NewIndex;
	local GUIListElem E;

	if ( !bAllowEmptyItems && NewItem == "" && Obj == None && Str == "" )
		return;

	E.Item = NewItem;
	E.ExtraData = Obj;
	E.ExtraStrData = Str;
	E.bSection = bSection;

	if (bSorted && Elements.Length > 0)
	{
		while (NewIndex < Elements.Length && CompareItem(Elements[NewIndex], E) < 0)
			NewIndex++;
	}
	else NewIndex = Elements.Length;

	Elements.Insert(NewIndex, 1);
	Elements[NewIndex] = E;

	ItemCount = Elements.Length;

	if (Elements.Length == 1 && bInitializeList)
		SetIndex(0);
	else if ( bNotify )
		CheckLinkedObjects(Self);

	if (MyScrollBar != None)
		MyScrollBar.AlignThumb();
}

function AddElement( GUIListElem NewElem )
{
	Add( NewElem.Item, NewElem.ExtraData, NewElem.ExtraStrData );
}

function Replace(int i, string NewItem, optional Object obj, optional string Str, optional bool bNoSort)
{
	if ( !IsValidIndex(i) )
		Add(NewItem,Obj,Str);
	else
	{
		if ( !bAllowEmptyItems && NewItem == "" && Obj == None && Str == "" )
			return;

		Elements[i].Item = NewItem;
		Elements[i].ExtraData = obj;
		Elements[i].ExtraStrData = Str;
		if ( bSorted && !bNoSort )
			Sort();

		SetIndex(Index);
	}
}

function Insert(int i, string NewItem, optional Object obj, optional string Str, optional bool bNoSort, optional bool bSection )
{
	if ( !IsValidIndex(i) )
		Add(NewItem,Obj,Str, bSection);
	else
	{
		if ( !bAllowEmptyItems && NewItem == "" && Obj == None && Str == "" )
			return;

		Elements.Insert(i,1);
		Elements[i].Item=NewItem;
		Elements[i].ExtraData=obj;
		Elements[i].ExtraStrData=Str;
		Elements[i].bSection=bSection;

		ItemCount = Elements.Length;

		if ( bSorted && !bNoSort )
			Sort();

		SetIndex(Index);

		if (MyScrollBar != None)
			MyScrollBar.AlignThumb();
	}
}

function InsertElement( int i, GUIListElem NewElem, optional bool bNoSort )
{
	Insert( i, NewElem.Item, NewElem.ExtraData, NewElem.ExtraStrData, bNoSort );
}

event Swap(int IndexA, int IndexB)
{
	local GUI.GUIListElem elem;

	if ( IsValidIndex(IndexA) && IsValidIndex(IndexB) )
	{
		elem = Elements[IndexA];
		Elements[IndexA] = Elements[IndexB];
		Elements[IndexB] = elem;

		if (bSorted)
			Sort();

		if ( bNotify )
			CheckLinkedObjects(Self);
	}
}

function LoadFrom(GUIList Source, optional bool bClearFirst)
{
	local string t1,t2;
	local object t;
	local int i;

	if (bClearfirst)
		Clear();

	for (i=0;i<Source.Elements.Length;i++)
	{
		Source.GetAtIndex(i,t1,t,t2);
		Add(t1,t,t2);
	}
}

function int Remove(int i, optional int Count, optional bool bNoSort)
{
	Count = Max( Count, 1 );

	if (!IsValidIndex(i))
		return Index;

	Elements.Remove(i, Min(Count, Elements.Length - i));
	ItemCount = Elements.Length;

	if ( bSorted && !bNoSort )
		Sort();

	// In case we now have an invalid index
	SetIndex(Index);

	if (MyScrollBar != None)
		MyScrollBar.AlignThumb();

	return Index;
}

function int RemoveSilent(int i, optional int Count)
{
	bNotify = False;
	i = Remove(i, Count, True);
	bNotify = True;
	return i;
}

function int RemoveElement(GUIListElem Elem, optional int Count, optional bool bNoSort)
{
	local int i;

	Count = Max( Count, 1 );
	for ( i = 0; i < Elements.Length; i++ )
	{
		if ( Elements[i] == Elem )
		{
			Elements.Remove(i, Min(Count, Elements.Length - i));
			break;
		}
	}

	ItemCount = Elements.Length;
	if ( bSorted && !bNoSort )
		Sort();

	// In case we now have an invalid index
	SetIndex(Index);

	if ( MyScrollBar != None )
		MyScrollBar.AlignThumb();

	return Index;
}

function Clear()
{
	if (Elements.Length == 0)
		return;

	Elements.Remove(0,Elements.Length);
	ItemCount = 0;
	Super.Clear();
}

// =====================================================================================================================
// =====================================================================================================================
//  Query Functions
// =====================================================================================================================
// =====================================================================================================================

// Backwards compatibility
function string SelectedText()
{
	return Get();
}

// Current listitem
function string Get(optional bool bGuarantee)
{
	if ( !IsValid() )
	{
		if (bGuarantee && Elements.Length > 0)
			return Elements[0].Item;

		return "";
	}

	return Elements[Index].Item;
}

function object GetObject()
{
	if ( !IsValid() )
		return none;

	return Elements[Index].ExtraData;
}

function string GetExtra()
{
	if ( !IsValid() )
		return "";

	return Elements[Index].ExtraStrData;
}

function bool IsSection()
{
	if ( !IsValid() )
		return false;

	return Elements[Index].bSection;
}

// Arbitrary list Item
function string GetItemAtIndex(int i)
{
	if (!IsValidIndex(i))
		return "";

	return Elements[i].Item;
}

function object GetObjectAtIndex(int i)
{
	if (!IsValidIndex(i))
		return None;

	return Elements[i].ExtraData;
}

function string GetExtraAtIndex(int i)
{
	if (!IsValidIndex(i))
		return "";

	return Elements[i].ExtraStrData;
}

function GetAtIndex(int i, out string ItemStr, out object ExtraObj, out string ExtraStr)
{
	if (!IsValidIndex(i))
		return;

	ItemStr = Elements[i].Item;
	ExtraObj = Elements[i].ExtraData;
	ExtraStr = Elements[i].ExtraStrData;
}

// =====================================================================================================================
// =====================================================================================================================
//  Assignment functions
// =====================================================================================================================
// =====================================================================================================================

function SetItemAtIndex(int i, string NewItem)
{
	if (!IsValidIndex(i))
		return;

	Elements[i].Item = NewItem;
	if ( bNotify )
		CheckLinkedObjects(Self);
}

function SetObjectAtIndex(int i, Object NewObject)
{
	if (!IsValidIndex(i))
		return;

	Elements[i].ExtraData = NewObject;
	if ( bNotify )
		CheckLinkedObjects(Self);
}

function SetExtraAtIndex(int i, string NewExtra)
{
	if (!IsValidIndex(i))
		return;

	Elements[i].ExtraStrData = NewExtra;
	if ( bNotify )
		CheckLinkedObjects(Self);
}

function RemoveItem(string Item)
{
	local int i;

	// Work through array. If we find it, remove it (will reduce Elements.Length).
	// If we don't, move on to next one.
	while( i < Elements.Length)
	{
		if(Item ~= Elements[i].Item)
			Elements.Remove(i, 1);
		else
			i++;
	}

	ItemCount = Elements.Length;

	SetIndex(-1);
	if (MyScrollBar != None)
		MyScrollBar.AlignThumb();
}

function RemoveObject(Object Obj)
{
	local int i;

	while (i < Elements.Length)
	{
		if (Obj == Elements[i].ExtraData)
			Elements.Remove(i, 1);
		else i++;
	}

	ItemCount = Elements.Length;

	SetIndex(-1);
	if (MyScrollBar != None)
		MyScrollBar.AlignThumb();
}

function RemoveExtra(string Str)
{
	local int i;

	while (i < Elements.Length)
	{
		if (Str ~= Elements[i].ExtraStrData)
			Elements.Remove(i, 1);
		else i++;
	}

	ItemCount = Elements.Length;

	SetIndex(-1);
	if (MyScrollBar != None)
		MyScrollBar.AlignThumb();
}


// =====================================================================================================================
// =====================================================================================================================
//  Search functions
// =====================================================================================================================
// =====================================================================================================================
function string Find(string Text, optional bool bExact, optional bool bExtra)
{
	local int i;

	i = FindIndex(Text, bExact, bExtra);
	if (i != -1)
	{
		SetIndex(i);
		return Elements[i].Item;
	}

	return "";
}

function int FindExtra(string Text, optional bool bExact)
{
	return FindIndex(Text, bExact, True);
}

function int FindItemObject(Object Obj)
{
	return FindIndex("",,,Obj);
}

function int FindIndex(string Test, optional bool bExact, optional bool bExtra, optional Object TestObject)
{
	local int i;

	if (TestObject != None)
	{
		for (i = 0; i < Elements.Length; i++)
			if ( TestObject == Elements[i].ExtraData )
				return i;
	}

	else if (Test != "")
	{
		if (bExtra)
		{
			for (i = 0; i < Elements.Length; i++)
				if ( (bExact && Elements[i].ExtraStrData == Test) || (!bExact && Elements[i].ExtraStrData ~= Test) )
					return i;
		}

		else
		{
			for ( i = 0; i < Elements.Length; i++)
				if ( (bExact && Elements[i].Item == Test) || (!bExact && Elements[i].Item ~= Test) )
					return i;
		}
	}

	return -1;
}

// =====================================================================================================================
// =====================================================================================================================
//  Drag-n-drop interface
// =====================================================================================================================
// =====================================================================================================================

// Called on the drop source when when an Item has been dropped.  bAccepted tells it whether
// the operation was successful or not.
function InternalOnEndDrag(GUIComponent Accepting, bool bAccepted)
{
	local int i;

//	log(Name@"InternalOnEndDrag Accepting:"$Accepting@"bAccepted:"$bAccepted);
	if (bAccepted && Accepting != None)
	{
		GetPendingElements();
		if ( Accepting != Self )
		{
			for ( i = 0; i < SelectedElements.Length; i++ )
				RemoveElement(SelectedElements[i]);
		}

		bRepeatClick = False;
	}

	// Simulate repeat click if the operation was a failure to prevent InternalOnMouseRelease from clearing
	// the SelectedItems array
	// This way we don't lose the items we clicked on
	if (Accepting == None)
		bRepeatClick = True;

	SetOutlineAlpha(255);
	if ( bNotify )
		CheckLinkedObjects(Self);
}

// Called on the drop target when the mouse is released - Sender is always DropTarget
function bool InternalOnDragDrop(GUIComponent Sender)
{
	local array<GUIListElem> NewItem;
	local int i;
//	log(Name@"InternalOnDragDrop Sender:"$ Sender);

	if (Controller.DropTarget == Self)
	{
		if (Controller.DropSource != None && GUIList(Controller.DropSource) != None)
		{
			NewItem = GUIList(Controller.DropSource).GetPendingElements();

			// Special case for drag-n-drop between the same list.
			if ( Controller.DropSource == Self )
			{
				for ( i = NewItem.Length - 1; i >= 0; i-- )
					RemoveElement(NewItem[i],,True);
			}

			if ( !IsValidIndex(DropIndex) )
				DropIndex = ItemCount;

			for (i = NewItem.Length - 1; i >= 0; i--)
				Insert(DropIndex, NewItem[i].Item, NewItem[i].ExtraData, NewItem[i].ExtraStrData);

			SetIndex(DropIndex);
			return true;
		}
	}
	return false;
}

function ClearPendingElements()
{
	Super.ClearPendingElements();
	if ( SelectedItems.Length == 0 )
		SelectedElements.Remove(0, SelectedElements.Length);
}

function array<GUIListElem> GetPendingElements(optional bool bGuarantee)
{
	local int i;

	if ( (DropState == DRP_Source && Controller.DropSource == Self) || bGuarantee )
	{
		if ( SelectedElements.Length == 0 )
		{
			for (i = 0; i < SelectedItems.Length; i++)
				if (IsValidIndex(SelectedItems[i]))
					SelectedElements[SelectedElements.Length] = Elements[SelectedItems[i]];

			if ( SelectedElements.Length == 0 && IsValid() )
			{
				SelectedElements.Length = SelectedElements.Length + 1;
				GetAtIndex(Index, SelectedElements[0].Item, SelectedElements[0].ExtraData, SelectedElements[0].ExtraStrData);
			}
		}

		return SelectedElements;
	}
}

defaultproperties
{
     TextAlign=TXTA_Center
}
