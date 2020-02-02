//==============================================================================
//	Created on: 09/16/2003
//	Support for creating circular lists like the character lists, using other materials
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class GUICircularImageList extends GUICircularList
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)


var() editconst editconstarray protected array<GUIListElem> Elements;

function Add( Material Img, optional string Str )
{
	local int NewIndex;

	if ( !bAllowEmptyItems && Img == None && Str == "" )
		return;

	if (bSorted && Elements.Length > 0)
	{
		while (NewIndex < Elements.Length && Elements[NewIndex].Item < Str)
			NewIndex++;
	}
	else NewIndex = Elements.Length;

	Elements.Insert(NewIndex, 1);

	Elements[NewIndex].Item = Str;
	Elements[NewIndex].ExtraData = Img;

	ItemCount = Elements.Length;
	if (Elements.Length == 1 && bInitializeList)
		SetIndex(0);
	else CheckLinkedObjects(Self);
}

function Replace(int i, Material Img, optional string Str)
{
	if ( !IsValidIndex(i) )
		Add(img,Str);
	else
	{
		if ( !bAllowEmptyItems && img == None && Str == "" )
			return;

		Elements[i].Item = Str;
		Elements[i].ExtraData = img;

		if ( bNotify )
			OnChange(self);
	}
}

function Insert(int i, Material Img, optional string Str)
{
	if ( !IsValidIndex(i) )
		Add(Img,Str);
	else
	{
		if ( !bAllowEmptyItems && Img == None && Str == "" )
			return;

		Elements.Insert(i,1);
		Elements[i].Item=Str;
		Elements[i].ExtraData=Img;
		ItemCount=Elements.Length;

		if ( bNotify )
			OnChange(self);
	}
}

event Swap(int IndexA, int IndexB)
{
	local GUI.GUIListElem elem;

	if ( IsValidIndex(IndexA) && IsValidIndex(IndexB) )
	{
		elem = Elements[IndexA];
		Elements[IndexA] = Elements[IndexB];
		Elements[IndexB] = elem;
	}
}

function LoadFrom(GUICircularImageList Source, optional bool bClearFirst)
{
	local string t1,t2;
	local object obj;
	local int i;

	if (bClearfirst)
		Clear();

	for (i=0;i<Source.Elements.Length;i++)
	{
		Source.GetAtIndex(i,t1,obj,t2);
		Add(material(obj),t1);
	}
}

function int RemoveSilent(int i, optional int Count)
{
	bNotify = False;
	i = Remove(i, Count);
	bNotify = True;
	return i;
}

function int Remove(int i, optional int Count)
{
	Count = Max( Count, 1 );
	if (!IsValidIndex(i))
		return Index;

	Elements.Remove(i, Min(Count, Elements.Length - i));

	ItemCount = Elements.Length;

	// In case we now have an invalid index
	SetIndex(Index);

	return Index;
}

function int RemoveElement(GUIListElem Elem, optional int Count)
{
	local int i;

	Count = Max(Count, 1);
	for ( i = 0; i < Elements.Length; i++ )
	{
		if ( Elements[i] == Elem )
		{
			Elements.Remove(i, Min(Count, Elements.Length - i));
			break;
		}
	}

	ItemCount = Elements.Length;

	// In case we now have an invalid index
	SetIndex(Index);

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

//##############################################################################
//
// Query functions
//

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

function Material GetImage(optional bool bGuarantee)
{
	if ( !IsValid() )
	{
		if ( bGuarantee && Elements.Length > 0 )
			return Material(Elements[0].ExtraData);

		return none;
	}

	return Material(Elements[Index].ExtraData);
}

// Arbitrary list Item
function string GetItemAtIndex(int i)
{
	if (!IsValidIndex(i))
		return "";

	return Elements[i].Item;
}

function Material GetImageAtIndex(int i)
{
	if (!IsValidIndex(i))
		return None;

	return Material(Elements[i].ExtraData);
}

function GetAtIndex(int i, out string ItemStr, out Object Img, out string ExtraStr)
{
	if (!IsValidIndex(i))
		return;

	ItemStr = Elements[i].Item;
	Img = Elements[i].ExtraData;
	ExtraStr = Elements[i].ExtraStrData;
}

// Specify true for bGuarantee to receive the selected item if there are no "pending" items
function array<string> GetPendingItems(optional bool bGuarantee)
{
	local int i;
	local array<string> Items;

	if ( (DropState == DRP_Source && Controller.DropSource == Self ) || bGuarantee )
	{
		for ( i = 0; i < SelectedItems.Length; i++ )
			if ( IsValidIndex(SelectedItems[i]) )
				Items[Items.Length] = Elements[SelectedItems[i]].Item;

		if ( Items.Length == 0 && IsValid() )
			Items[0] = Get();
	}

	return Items;
}

function array<GUIListElem> GetPendingElements(optional bool bGuarantee)
{
	local int i;
	local array<GUIListElem> PendingItem;

	if ( (DropState == DRP_Source && Controller.DropSource == Self) || bGuarantee )
	{
		for (i = 0; i < SelectedItems.Length; i++)
			if (IsValidIndex(SelectedItems[i]))
				PendingItem[PendingItem.Length] = Elements[SelectedItems[i]];

		if ( PendingItem.Length == 0 && IsValid() )
		{
			PendingItem.Length = PendingItem.Length + 1;
			GetAtIndex(Index, PendingItem[0].Item, PendingItem[0].ExtraData, PendingItem[0].ExtraStrData);
		}

	}
	return PendingItem;
}

//##############################################################################
//
// Assignment functions
//

function SetItemAtIndex(int i, string NewItem)
{
	if (!IsValidIndex(i))
		return;

	Elements[i].Item = NewItem;
}

function SetImageAtIndex(int i, Material Img)
{
	if (!IsValidIndex(i))
		return;

	Elements[i].ExtraData = Img;
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
}

function RemoveImage(Material Img)
{
	local int i;

	while (i < Elements.Length)
	{
		if (Img == Elements[i].ExtraData)
			Elements.Remove(i, 1);
		else i++;
	}

	ItemCount = Elements.Length;
	SetIndex(-1);
}


//##############################################################################
//
// Search functions
//

function int FindIndex(Material Img, optional string Test)
{
	local int i;

	if (Img != None)
	{
		for (i = 0; i < Elements.Length; i++)
			if ( Img == Elements[i].ExtraData )
				return i;
	}

	else if (Test != "")
	{
		for ( i = 0; i < Elements.Length; i++)
			if ( Elements[i].Item ~= Test )
				return i;
	}

	return -1;
}

// Called on the drop source when when an Item has been dropped.  bAccepted tells it whether
// the operation was successful or not.
function InternalOnEndDrag(GUIComponent Accepting, bool bAccepted)
{
	local int i;
	local array<GUIListElem> TempElem;

	if (bAccepted && Accepting != None)
	{
		for (i = 0; i < SelectedItems.Length; i++)
			TempElem[TempElem.Length] = Elements[SelectedItems[i]];

		for (i = 0; i < TempElem.Length; i++)
			RemoveElement(TempElem[i]);

		bRepeatClick = False;
//		InternalOnMouseRelease(Accepting);
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

	if (Controller.DropTarget == Self)
	{
		if (Controller.DropSource != None && GUIList(Controller.DropSource) != None)
		{
			NewItem = GUIList(Controller.DropSource).GetPendingElements();

			if (DropIndex >= 0 && DropIndex < ItemCount)
			{
				for (i = NewItem.Length - 1; i >= 0; i--)
					Insert(DropIndex, Material(NewItem[i].ExtraData), NewItem[i].Item);
			}
			else
			{
				DropIndex = ItemCount;
				for (i = 0; i < NewItem.Length; i++)
					Add(Material(NewItem[i].ExtraData), NewItem[i].Item);
			}

			SetIndex(DropIndex);
//			InternalOnMouseRelease(Self);

			return true;
		}
	}
	return false;
}

defaultproperties
{
}
