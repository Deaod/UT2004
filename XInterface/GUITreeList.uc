// ====================================================================
//  Class:  GUITreeList
//
//  The GUITree is a part of a tree control.
//
//  Written by Bruce Bickar
//  (Cloned from GUIList)
//  (c) 2002, 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUITreeList extends GUIVertList Native;

#exec OBJ LOAD FILE=InterfaceContent.utx

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var() eTextAlign TextAlign;
var() editconstarray editconst noexport array<GUITreeNode> Elements;
var() editconstarray editconst noexport array<GUITreeNode> SelectedElements;
var() editconst const noexport int VisibleCount;	// How many elements are currently visible
var() const editconst float PrefixWidth, SelectedPrefixWidth;
var() bool bAllowParentSelection, bAllowDuplicateCaption;
var() bool bGroupItems; // really bad hack to get onslaught link setups working

native final function UpdateVisibleCount();
native final function SortList();

// Used by SortList.
delegate int CompareItem(GUITreeNode ElemA, GUITreeNode ElemB)
{
	return StrCmp(ElemA.Caption, ElemB.Caption);
}

function int AddItem(string Caption, string Value, optional string ParentCaption, optional bool bEnabled, optional string ExtraInfo)
{
	local int i;
	local int idx;

	if ( !bAllowEmptyItems && Caption == "" && ParentCaption == "" )
		return -1;

	if ( !bAllowDuplicateCaption && FindIndex(Caption) != -1 )
		return -1;

	if ( ParentCaption == "" )
		idx = HardInsert( Elements.Length, Caption, Value, "", 0, True, ExtraInfo );
	else
	{
		// find parent
		if ( bGroupItems )
		{
			i = FindIndex(ParentCaption,true);
			if ( i == -1 )
				i = FindIndex(ParentCaption);

			// Implicitly create the entry for the parent, if it wasn't found
			if ( i == -1 )
				i = HardInsert( Elements.Length, ParentCaption, "", "", 0, True );
		}
		else if ( ParentCaption != "" )
			i = HardInsert(Elements.Length, ParentCaption, Value, "", 0, True, ExtraInfo);

		idx = HardInsert( i+1, Caption, Value, ParentCaption, Elements[i].Level + 1, bEnabled, ExtraInfo );
	}

	if (Elements.Length == 1 && bInitializeList)
		SetIndex(0);
	else if ( bNotify )
		CheckLinkedObjects(Self);

	UpdateVisibleCount();
	if (MyScrollBar != None)
		MyScrollBar.AlignThumb();

	return idx;
}

function int AddElement( GUITreeNode Node )
{
	return AddItem(Node.Caption, Node.Value, Node.ParentCaption, Node.bEnabled, Node.ExtraInfo);
}

function Replace(int i, string NewItem, string NewValue, optional string ParentCaption, optional bool bNoSort, optional string ExtraInfo)
{
	if ( !IsValidIndex(i) )
		AddItem(NewItem,NewValue,ParentCaption);
	else
	{
		if ( !bAllowEmptyItems && NewItem == "" && NewValue == "" && ParentCaption == "" )
			return;

		Elements[i].Caption = NewItem;
		Elements[i].Value = NewValue;
		Elements[i].ExtraInfo = ExtraInfo;
		if ( bSorted && !bNoSort )
			Sort();

		SetIndex(Index);
	}
}

function int InsertItem( int idx, string Caption, string Value, string ParentCaption, int Level, bool bEnabled, optional string ExtraInfo )
{
	local int ParentIndex, ChildIndex;

	if ( !IsValidIndex(idx) )
		return AddItem(Caption, Value, ParentCaption, bEnabled, ExtraInfo);

	if ( bGroupItems )
	{
		ParentIndex = FindParentIndex(idx);
		if ( IsValidIndex(ParentIndex) && Elements[ParentIndex].Caption == ParentCaption )
		{
			ChildIndex = FindAvailableChildIndex(ParentIndex);
			if ( idx > ParentIndex && idx <= ChildIndex )
				return HardInsert(idx, Caption, Value, ParentCaption, Elements[ParentIndex].Level + 1, bEnabled, ExtraInfo);
			else return HardInsert(ChildIndex, Caption, Value, ParentCaption, Elements[ParentIndex].Level + 1, bEnabled, ExtraInfo);
		}
		else if ( ParentCaption == "" )
		{
			idx = FindNextAvailableRootIndex(idx);
			return HardInsert(idx,Caption,Value,ParentCaption,Level,True,ExtraInfo);
		}
	}
	else
	{
		ParentIndex = FindNextAvailableRootIndex(idx);
		if ( ParentCaption != "" )
			idx = HardInsert(idx,ParentCaption,Value,"",Level++,True,ExtraInfo);

		return HardInsert(idx+1, Caption, Value, ParentCaption, Level, True, ExtraInfo);
	}

	return AddItem(Caption, Value, ParentCaption, bEnabled);
}

protected function int HardInsert( int idx, string Caption, string Value, string ParentCaption, int Level, bool bEnabled, optional string ExtraInfo )
{
	Elements.Insert(idx,1);

	Elements[idx].Caption = Caption;
	Elements[idx].Value = Value;
	Elements[idx].ParentCaption = ParentCaption;
	Elements[idx].ExtraInfo = ExtraInfo;
	Elements[idx].Level = Level;
	Elements[idx].bEnabled = bEnabled;

	ItemCount = Elements.Length;

	return idx;
}

function LoadFrom(GUITreeList Source, optional bool bClearFirst)
{
	local int i, Level;
	local byte bEnabled;
	local string Caption, Value, ParentCaption, ExtraInfo;

	if (bClearfirst)
		Clear();

	for ( i = 0; i < Source.ItemCount; i++ )
	{
		if ( Source.ValidSelectionAt(i) )
		{
			Source.GetAtIndex(i,Caption,Value,ParentCaption,Level,bEnabled, ExtraInfo);
			AddItem(Caption, Value, ParentCaption, bool(bEnabled), ExtraInfo);
		}
	}
}

function int RemoveSilent( string Caption )
{
	local int i;

	bNotify = False;
	i = RemoveItem(Caption);
	bNotify = True;

	return i;
}

function int RemoveItem(string Caption)
{
	local int i;

	i = FindIndex(Caption, True);
	if ( i == -1 )
		i = FindIndex(Caption);

	return RemoveItemAt(i);
}

function int RemoveItemAt( int idx, optional bool bNoSort, optional bool bSkipCleanup )
{
	local int Level, ParentIndex;

	if ( IsValidIndex(idx) )
	{
		Level = Elements[idx].Level + 1;
		ParentIndex = FindParentIndex(idx);

		// Remove all children of this element
		Elements.Remove(idx,1);
		ItemCount--;

		while ( idx < ItemCount && Elements[idx].Level == Level )
		{
			if ( RemoveItemAt(idx,True,True) == -2 )
				break;
		}

		// If parent selection isn't allowed, we should remove the entry for the parent if we're the last child
		// bSkipCleanup should probably only be used when recursing within this function
		if ( !bAllowParentSelection && !bSkipCleanup && IsValidIndex(ParentIndex) && !HasChildren(ParentIndex) )
			RemoveItemAt(ParentIndex,True);

		UpdateVisibleCount();
		if ( bSorted && !bNoSort )
			Sort();

		// In case we now have an invalid index
		SetIndex(Index);
		if ( MyScrollBar != None )
			MyScrollBar.AlignThumb();

		return Index;
	}

	return -2;
}

function int RemoveElement( GUITreeNode Node, optional int Count, optional bool bNoSort )
{
	local int i;

	// TODO Hook up count
	Count = Max(Count, 1);
	for ( i = 0; i < Elements.Length; i++ )
		if ( Elements[i] == Node )
			return RemoveItemAt(i, bNoSort);

	return -1;
}

function Clear()
{
	if (Elements.Length == 0)
		return;

	Elements.Remove(0,Elements.Length);
	ItemCount = 0;

	UpdateVisibleCount();
	Super.Clear();
}

event bool Swap(int IndexA, int IndexB)
{
	local int ParentIndexA, ParentIndexB;

	ParentIndexA = FindParentIndex(IndexA);
	ParentIndexB = FindParentIndex(IndexB);

	// TODO handle cases of attempting to swap elements at different levels
	if ( bGroupItems )
	{
		if ( IsValidIndex(ParentIndexA) )
		{
			if ( IsValidIndex(ParentIndexB) )
			{
				if ( ParentIndexA != ParentIndexB )
					return false;
			}

			else return false;
		}
		else if ( IsValidIndex(ParentIndexB) )
			return false;
	}

	// TODO Support swapping elements that contain children
	if ( IsValidIndex(IndexA) && IsValidIndex(IndexB) )
	{
		if ( !bGroupItems )
		{
			if ( IndexA > IndexB )
			{
				if ( Elements[IndexA].Level > 0 )
					IndexA = ParentIndexA;

				if ( Elements[IndexB].Level > 0 )
					IndexB = ParentIndexB;

				if ( IndexA == IndexB )
				{
					IndexA = FindNextAvailableRootIndex(IndexB-1);
					if ( !IsValidIndex(IndexA) )
						return False;
				}

			}
			else
			{
				if ( Elements[IndexA].Level > 0 )
					IndexA = ParentIndexA;

				if ( Elements[IndexB].Level > 0 )
					IndexB = ParentIndexB;

				if ( IndexA == IndexB )
					IndexB = FindAvailableChildIndex(IndexA);

				if ( !IsValidIndex(IndexB) )
					return False;
			}
		}

		HardSwap(IndexA,IndexB);
		return True;
	}

	return False;
}

protected function HardSwap( int IndexA, int IndexB )
{
	local array<int> chIdxA, chIdxB;
	local int i;
	local array<GUITreeNode> NodesA, NodesB;

	NodesA[NodesA.Length] = Elements[IndexA];
	NodesB[NodesB.Length] = Elements[IndexB];

	if ( HasChildren(IndexA) )
	{
		chIdxA = GetChildIndexList(IndexA);
		for ( i = 0; i < chIdxA.Length; i++ )
			NodesA[NodesA.Length] = Elements[chIdxA[i]];
	}

	if ( HasChildren(IndexB) )
	{
		chIdxB = GetChildIndexList(IndexB);
		for ( i = 0; i < chIdxB.Length; i++ )
			NodesB[NodesB.Length] = Elements[chIdxB[i]];
	}

	if ( IndexA > IndexB )
	{
		Elements.Remove( IndexA, NodesA.Length );
		Elements.Insert( IndexA, NodesB.Length );
		for ( i = 0; i < NodesB.Length; i++ )
			Elements[IndexA + i] = NodesB[i];

		Elements.Remove( IndexB, NodesB.Length );
		Elements.Insert( IndexB, NodesA.Length );
		for ( i = 0; i < NodesB.Length; i++ )
			Elements[IndexB + i] = NodesA[i];

	}
	else
	{
		Elements.Remove( IndexB, NodesB.Length );
		Elements.Insert( IndexB, NodesA.Length );
		for ( i = 0; i < NodesA.Length; i++ )
			Elements[IndexB + i] = NodesA[i];

		Elements.Remove( IndexA, NodesA.Length );
		Elements.Insert( IndexA, NodesB.Length );
		for ( i = 0; i < NodesB.Length; i++ )
			Elements[IndexA + i] = NodesB[i];
	}

	if ( bNotify )
		CheckLinkedObjects(Self);

	if ( bSorted )
		Sort();
}


// =====================================================================================================================
// =====================================================================================================================
//  Query Functions
// =====================================================================================================================
// =====================================================================================================================

function string GetCaption()
{
	return GetCaptionAtIndex(Index);
}

function string GetParentCaption()
{
	return GetParentCaptionAtIndex(Index);
}

function string GetValue()
{
	return GetValueAtIndex(Index);
}

function int GetLevel()
{
	return GetLevelAtIndex(Index);
}

function string GetExtra()
{
	return GetExtraAtIndex(Index);
}

function string GetCaptionAtIndex(int i)
{
	if (!IsValidIndex(i))
		return "";

	return Elements[i].Caption;
}

function string GetParentCaptionAtIndex(int idx)
{
	if ( !IsValidIndex(idx) )
		return "";

	// TODO this is not a good way to do this...gah
	if ( Elements[idx].ParentCaption == "" )
		return Elements[idx].Caption;

	return Elements[idx].ParentCaption;
}

function string GetValueAtIndex(int i)
{
	if (!IsValidIndex(i))
		return "";

	return Elements[i].Value;
}

function int GetLevelAtIndex(int i)
{
	if (!IsValidIndex(i))
		return -1;

	return Elements[i].Level;
}

function string GetExtraAtIndex( int idx )
{
	if ( !IsValidIndex(idx) )
		return "";

	return Elements[idx].ExtraInfo;
}

function bool GetElementAtIndex( int i, out GUITreeNode Node )
{
	if ( !IsValidIndex(i) )
		return False;

	Node = Elements[i];
	return True;
}

function bool GetAtIndex(int i, out string Caption, out string Value, out string ParentCaption, out int Level, out byte bEnabled, out string ExtraInfo)
{
	if (!IsValidIndex(i))
		return false;

	Caption = Elements[i].Caption;
	Value = Elements[i].Value;
	Level = Elements[i].Level;
	ParentCaption = Elements[i].ParentCaption;
	bEnabled = byte(Elements[i].bEnabled);
	ExtraInfo = Elements[i].ExtraInfo;
	return True;
}


function array<int> GetIndexList()
{
	local array<int> Indexes;
	local int i;

	for ( i = 0; i < ItemCount; i++ )
		if ( ValidSelectionAt(i) )
			Indexes[Indexes.Length] = i;

	return Indexes;
}

function array<int> GetChildIndexList( int idx, optional bool bNoRecurse )
{
	local array<int> Indexes;
	local int Level;

	if ( IsValidIndex(idx) )
	{
		Level = Elements[idx].Level + 1;
		while ( ++idx < ItemCount )
		{
			if ( Elements[idx].Level < Level )
				break;

			if ( bNoRecurse && Elements[idx].Level > Level )
				break;

			Indexes[Indexes.Length] = idx;
		}
	}

	return Indexes;
}

event bool ValidSelection()
{
	return ValidSelectionAt(Index);
}

event bool ValidSelectionAt( int idx )
{
	if ( !IsValidIndex(idx) )
		return False;

	return bAllowParentSelection || !HasChildren(idx);
}

event bool HasChildren( int ParentIndex )
{
	if ( !IsValidIndex(ParentIndex) )
		return False;

	if ( ParentIndex < ItemCount - 1 )
		return Elements[ParentIndex+1].Level > Elements[ParentIndex].Level;

	return False;
}

event bool IsExpanded( int ParentIndex )
{
	if ( !HasChildren(ParentIndex) )
		return True;

	return Elements[ParentIndex+1].bEnabled;
}

// =====================================================================================================================
// =====================================================================================================================
//  Assignment functions
// =====================================================================================================================
// =====================================================================================================================

function SetCaptionAtIndex(int i, string NewCaption)
{
	if (!IsValidIndex(i))
		return;

	Elements[i].Caption = NewCaption;
}

function SetValueAtIndex(int i, string NewValue)
{
	if (!IsValidIndex(i))
		return;

	Elements[i].Value = NewValue;
}

function SetLevelAtIndex(int i, int NewLevel)
{
	if (!IsValidIndex(i))
		return;

	Elements[i].Level = NewLevel;
}

function bool Expand(int idx, optional bool bRecursive)
{
	local int i;
	local array<int> Indexes;

	if (!IsValidIndex(idx))
		return false;

	// Make sure all other elements on this level, as well as all parent items, are also visible
	Expand(FindParentIndex(idx));

	// Then enable all children, perhaps with recursion
	Indexes = GetChildIndexList(idx, !bRecursive);
	for ( i = 0; i < Indexes.Length; i++ )
		Elements[Indexes[i]].bEnabled = True;

	return True;
}

function bool Collapse(int idx)
{
	local int i;
	local array<int> Indexes;

	if (!IsValidIndex(idx))
		return false;

	Indexes = GetChildIndexList(idx);
	for ( i = 0; i < Indexes.Length; i++ )
		Elements[Indexes[i]].bEnabled = False;

	return True;
}

function ToggleExpand(int idx, optional bool bRecursive)
{
	if (!IsValidIndex(idx))
		return;

	if ( IsExpanded(idx) )
		Collapse(idx);
	else Expand(idx, bRecursive);
}

function bool IsToggleClick(int idx)
{
	local float PrefixOffset, CaptionOffset;

	if ( !IsValidIndex(idx) )
		return false;

	if ( !HasChildren(idx) )
		return false;

	// Calculate the position of the plus/minus
	PrefixOffset = ClientBounds[0] + (SelectedPrefixWidth * GetLevelAtIndex(idx));
	CaptionOffset = PrefixOffset + SelectedPrefixWidth;

	// if we were clicking on the plus/minus, toggle the item
	if ( Controller.MouseX >= PrefixOffset && Controller.MouseX <= CaptionOffset )
		return true;

	return false;
}

function bool InternalOnClick( GUIComponent Sender )
{
	local bool bResult;

	bResult = Super.InternalOnClick(Sender);
	if ( bResult && IsToggleClick(Index) )
		ToggleExpand(Index);

	return bResult;
}

function bool InternalDblClick( GUIComponent Sender )
{
	ToggleExpand(Index);
	return True;
}

// =====================================================================================================================
// =====================================================================================================================
//  Search functions
// =====================================================================================================================
// =====================================================================================================================
function int FindIndex(string Caption, optional bool bExact)
{
	local int i;

	for ( i = 0; i < Elements.Length; i++)
		if ( (bExact && Elements[i].Caption == Caption) || (!bExact && Elements[i].Caption ~= Caption) )
			return i;

	return -1;
}

function int FindFullIndex( string Caption, string Value, string ParentCaption )
{
	local int i;

	for ( i = 0; i < Elements.Length; i++ )
		if ( Elements[i].Caption == Caption && Elements[i].Value == Value && Elements[i].ParentCaption == ParentCaption )
			return i;

	return -1;
}

function int FindParentIndex( int ChildIndex )
{
	local int Level;

	if ( !IsValidIndex(ChildIndex) )
		return -1;

	if ( Elements[ChildIndex].Level == 0 )
		return -1;

	Level = Elements[ChildIndex].Level - 1;
	while ( --ChildIndex >= 0 && Elements[ChildIndex].Level > Level );
	return ChildIndex;
}

function int FindNextAvailableRootIndex( int Target )
{
	if ( !IsValidIndex(Target) )
		return Elements.Length;

	if ( Elements[Target].Level == 0 )
		return Target;

	while ( --Target > 0 && Elements[Target].Level > 0 );
	return Target;
}

// This function calculates the appropriate index to use for adding a child node
function int FindAvailableChildIndex( int ParentIndex )
{
	local int ParentLevel;

	if ( IsValidIndex(ParentIndex) )
	{
		ParentLevel = Elements[ParentIndex].Level + 1;
		while ( ++ParentIndex < ItemCount && Elements[ParentIndex].Level >= ParentLevel );
		return ParentIndex;
	}

	return -1;
}

function int FindIndexByValue(string Value, optional bool bExact)
{
	local int i;

	for ( i = 0; i < Elements.Length; i++)
		if ( (bExact && Elements[i].Value == Value) || (!bExact && Elements[i].Value ~= Value) )
			return i;

	return -1;
}

function int FindElement( string Caption, string Value, int Level, optional bool bCaseSensitive )
{
	local int i;

	if ( bCaseSensitive )
		for ( i = 0; i < Elements.Length; i++ )
			if ( Elements[i].Caption == Caption && Elements[i].Value == Value && Elements[i].Level == Level )
				return i;

	else for ( i = 0; i < Elements.Length; i++ )
		if ( Elements[i].Caption ~= Caption && Elements[i].Value ~= Value && Elements[i].Level == Level )
			return i;

	return -1;
}

// Find the node index that is distance away from node specified by idx, considering only visible nodes
function int FindVisibleIndex( int Idx, int Distance )
{
	local int Count, i, increment;

	if ( Distance == 0 )
		return Idx;
	else if ( Distance < 0 )
		increment = -1;
	else increment = 1;

	for ( i = Idx; IsValidIndex(i); i += increment )
	{
		if ( Elements[i].bEnabled )
			Count++;

		if ( Count >= Abs(Distance) )
			break;
	}

	return i;
}

// =====================================================================================================================
// =====================================================================================================================
//  GUIListBase Interface
// =====================================================================================================================
// =====================================================================================================================
event int CalculateIndex( optional bool bRequireValidIndex )
{
	local int Row, NewIndex;

	//  Figure out which Item we're clicking on
	Row = Ceil( (Controller.MouseY - ClientBounds[1]) / ItemHeight );

	NewIndex = FindVisibleIndex(Top, Row);
	return Min( NewIndex, ItemCount - 1 );
}

function Sort()
{
	SortList();
}

function int SetIndex(int NewIndex)
{
	if ( IsValidIndex(NewIndex) && !Elements[NewIndex].bEnabled )
	{
		Expand(NewIndex);
		UpdateVisibleCount();
	}

	return Super.SetIndex(NewIndex);
}

function SetTopItem(int Item)
{
    Top = Item;

	if ( Top < 0 )
		Top = 0;
	else if ( FindVisibleIndex(Top,ItemsPerPage) >= ItemCount )
    	Top = FindVisibleIndex(ItemCount - 1, -ItemsPerPage);

	if ( ItemCount <= 0 )
		Top = 0;
	else Top = Clamp(Top, 0, ItemCount - 1);

	if ( bNotify )
	    CheckLinkedObjects(Self);

    OnAdjustTop(Self);

	if ( MyScrollBar != None )
    	MyScrollBar.AlignThumb();
}

function bool Up()
{
	local int NewIndex;

	if ( ItemCount < 2 || Index == 0 )
		return True;

	NewIndex = Index;
	while ( --NewIndex >= 0 && !Elements[NewIndex].bEnabled );

	SetIndex( Max(0, NewIndex) );
	if ( MyScrollBar != None )
		MyScrollBar.AlignThumb();

	return true;
}

function bool Down()
{
	local int NewIndex;

	if ( ItemCount < 2 || Index == ItemCount - 1 )
		return true;

	// Scan down until an enabled element is found
	NewIndex = Index;
	while ( ++NewIndex < ItemCount && !Elements[NewIndex].bEnabled );

	SetIndex(Min(NewIndex, ItemCount - 1));
	if ( MyScrollBar != None )
		MyScrollBar.AlignThumb();

	return true;
}

function End()
{
	local int NewIndex;

	if ( ItemCount < 2 )
		return;

	// Scan up from bottom until enabled element found
	NewIndex = FindVisibleIndex(ItemCount - 1, 1);
	if ( IsValidIndex(NewIndex) )
	{
		SetIndex(NewIndex);
		if ( MyScrollBar != None )
			MyScrollBar.AlignThumb();
	}
}

function PgUp()
{
	if ( ItemCount < 2 )
		return;

	UpdateVisibleCount();
	Super.PgUp();
}

function PgDn()
{
	if ( ItemCount < 2 )
		return;

	UpdateVisibleCount();
	Super.PgDn();
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
	local array<GUITreeNode> NewItem;
	local GUITreeList SourceTree;
	local int i;
//	log(Name@"InternalOnDragDrop Sender:"$ Sender);

	if (Controller.DropTarget == Self)
	{
		if (Controller.DropSource != None && GUITreeList(Controller.DropSource) != None)
		{
			SourceTree = GUITreeList(Controller.DropSource);
			NewItem = SourceTree.GetPendingElements();

			// Special case for drag-n-drop between the same list.
			if ( Controller.DropSource == Self )
			{
				for ( i = NewItem.Length - 1; i >= 0; i-- )
					RemoveElement(NewItem[i],,True);
			}

			if ( !IsValidIndex(DropIndex) )
				DropIndex = ItemCount;

			for ( i = NewItem.Length-1; i >= 0; i-- )
				InsertItem(DropIndex, NewItem[i].Caption, NewItem[i].Value, NewItem[i].ParentCaption, NewItem[i].Level, NewItem[i].bEnabled, NewItem[i].ExtraInfo);

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

function array<GUITreeNode> GetPendingElements(optional bool bGuarantee)
{
	local int i;

	if ( (DropState == DRP_Source && Controller.DropSource == Self) || bGuarantee )
	{
		if ( SelectedElements.Length == 0 )
		{
			for (i = 0; i < SelectedItems.Length; i++)
				if (IsValidIndex(SelectedItems[i]) && ValidSelectionAt(SelectedItems[i]))
					SelectedElements[SelectedElements.Length] = Elements[SelectedItems[i]];

			if ( SelectedElements.Length == 0 && IsValid() && ValidSelection() )
			{
				SelectedElements.Length = SelectedElements.Length + 1;
				GetElementAtIndex(Index,SelectedElements[0]);
			}
		}

		return SelectedElements;
	}
}

defaultproperties
{
     bAllowDuplicateCaption=True
     bGroupItems=True
}
