// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class GUIVertImageList extends GUIVertList
		Native;


// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var() eCellStyle CellStyle;

var() float	ImageScale;						// Scale value for the images

var() int	NoVisibleRows;					// How many rows of visible images are there
var() int 	NoVisibleCols;					// How many cols of visible images are there

var() int	HorzBorder, VertBorder;			// How much white space

var() editconstarray editconst array<ImageListElem> Elements;
var() editconstarray editconst array<ImageListElem> SelectedElements;

var() material LockedMat;

event int CalculateIndex( optional bool bRequireValidIndex )
{
	local int i;
	local int HitCol, HitRow;

	HitCol = (Controller.MouseX - ClientBounds[0]) / ItemWidth;
    HitRow = (Controller.MouseY - ClientBounds[1]) / ItemHeight;

    i = Top + HitCol + (HitRow * NoVisibleCols);
	if ( (i < 0 || i >= ItemCount) && bRequireValidIndex )
		return -1;

	return i;
}

function bool InternalOnClick(GUIComponent Sender)
{
	local int NewIndex;

	if ( !IsInClientBounds() || ItemsPerPage==0 )
		return false;

	NewIndex = CalculateIndex();
	if ( !IsValidIndex(NewIndex) )
		return false;

	SetIndex(NewIndex);
	return true;
}

function int SetIndex(int NewIndex)
{
	if (Elements[NewIndex].Locked==1)
		return Index;

	return super.SetIndex(NewIndex);
}

function bool Up()
{
	local int TargetIndex;
	if ( Index - NoVisibleCols < 0 )
		return true;

	TargetIndex = Index-NoVisibleCols;
	if ( Elements[TargetIndex].Locked==1 )
	{
		TargetIndex = TargetIndex-NoVisibleCols;
		if ( TargetIndex<0 || Elements[TargetIndex].Locked==1 )
			return true;
	}

	SetIndex(TargetIndex);

	if ( MyScrollBar != None )
		MyScrollBar.AlignThumb();
	return true;
}

function bool Down()
{
	local int TargetIndex;

	if ( Index + NoVisibleCols >= ItemCount )
		return true;

	TargetIndex = Index + NoVisibleCols;
	if ( Elements[TargetIndex].Locked==1 )
	{
		TargetIndex = TargetIndex + NoVisibleCols;
		if ( TargetIndex >= ItemCount || Elements[TargetIndex].Locked==1 )
			return true;
	}

	SetIndex(TargetIndex);
	if ( MyScrollBar != None )
		MyScrollBar.AlignThumb();

	return true;

}
function bool MoveRight()
{
	local int TargetIndex;


	TargetIndex = ( Index + 1 );
	if ( TargetIndex % NoVisibleCols == 0 )
		return true;

	if (Elements[TargetIndex].Locked==1)
	{
		TargetIndex++;
		if ( (TargetIndex % NoVisibleCols == 0 ) || (Elements[TargetIndex].Locked==1) )
			return true;
	}

	if ( TargetIndex < ItemCount )
		SetIndex(TargetIndex);


    return true;

}
function bool MoveLeft()
{
	local int TargetIndex;

	if ( Index % NoVisibleCols == 0 )
		return true;

	TargetIndex = Index - 1;
	if (Elements[TargetIndex].Locked==1)
	{
		TargetIndex--;
		if (TargetIndex<0 || TargetIndex%NoVisibleCols==NoVisibleCols-1 || Elements[TargetIndex].Locked==1)
			return true;
	}
	if ( Index > 0 )
		SetIndex(TargetIndex);

    return true;
}


function Home()
{
	local int i;
	if ( ItemCount < 2 )
		return;

	for (i=0;i<Index;i++)
		if (Elements[i].Locked!=1)
		{
			SetIndex(i);
			if ( MyScrollBar != None )
				MyScrollBar.AlignThumb();

			return;
		}
}

function End()
{
	local int i;
	if ( ItemCount < 2 )
		return;

	for (i=ItemCount-1;i>0;i--)
		if (Elements[i].Locked!=1)
		{
			SetIndex( i );
			if ( MyScrollBar != None )
				MyScrollBar.AlignThumb();

			return;
		}
}

function PgUp()
{
	local int newtop;
	if (Top > 0)
    {
    	NewTop = max(0,Top-NoVisibleRows);
    	SetTopItem(NewTop);
		if ( MyScrollBar != None )
			MyScrollBar.AlignThumb();
    }

	return;
}

function PgDn()
{
	local int newtop;
	if ( Top < (ItemCount / NoVisibleCols) - NoVisibleRows)
    {
    	NewTop = Max(0, Top+NoVisibleRows);
    	SetTopItem(NewTop);

    	if ( MyScrollBar != None )
    		MyScrollBar.AlignThumb();
    }

	return;
}

function MakeVisible(float Perc)
{
	local float MaxTop, ModResult;
	local int NewTop, Change;

	MaxTop = ItemCount - ItemsPerPage;
	ModResult = MaxTop % NoVisibleCols;
	if ( ModResult > 0 )
		MaxTop = (MaxTop - ModResult) + NoVisibleCols;

	// NewItem is number of hidden items * Perc we want to show
	// Round off result before adjusting top to prevent constant flipping back and forth between two items
	// or if we're attempting to view the last row
	NewTop = Round(MaxTop * Perc);
	Change = Abs(Top - NewTop);
	if ( Change < NoVisibleCols && Perc < 1.0)
		return;

	SetTopItem(NewTop);
}

function SetTopItem(int Item)
{
	local int ModResult;

	// clamp new top to prevent displaying space below last items of list
	Item = Clamp(Item, 0, ItemCount - 1);

	// Adjust the result to fall on the first column - otherwise, elements might get shifted to a different column
	ModResult = Item % NoVisibleCols;
	if ( ModResult > 0 )
	{
		// If we had leftover items, we'll need another row
		if ( Item > Top )
			Item += NoVisibleCols;

		Item -= ModResult;
	}

	// But if we went too far (more than itemcount + numcolumns), then back it up
	while ( (Item + ItemsPerPage > ItemCount + NoVisibleCols) && Item >= 0)
		Item -= NoVisibleCols;

	Top = Max( 0, Item );
	OnAdjustTop(Self);
}

function Add(Material Image, optional int Item, optional int Locked)
{
	local int i;

	if ( Image == None && !bAllowEmptyItems )
		return;

	i = Elements.Length;
	Elements.Length = i + 1;
	Elements[i].Image = Image;
	Elements[i].Item = Item;
	Elements[i].Locked = Locked;
	ItemCount = Elements.Length;

	if (ItemCount == 1 && bInitializeList)
		SetIndex(0);
	else CheckLinkedObjects(Self);

	if (MyScrollBar != None)
		MyScrollBar.AlignThumb();
}

function AddImage( ImageListElem NewElem, optional int Locked)
{
	Add(NewElem.Image, NewElem.Item, Locked);
}

function Replace(int i, Material NewImage, optional int NewItem, optional int Locked)
{
	if ( !IsValidIndex(i) )
		Add(NewImage, NewItem);
	else
	{
		if ( !bAllowEmptyItems && NewImage == None )
			return;

		Elements[i].Item = NewItem;
		Elements[i].Image = NewImage;
		Elements[i].Locked = Locked;
		SetIndex(Index);
		if ( MyScrollBar != None )
			MyScrollBar.AlignThumb();
	}
}

function Insert(int i, Material NewImage, optional int NewItem, optional int Locked)
{
	if ( !IsValidIndex(i) )
		Add(NewImage,NewItem);
	else
	{
		if ( !bAllowEmptyItems && NewImage == None )
			return;

		Elements.Insert(i,1);
		Elements[i].Item=NewItem;
		Elements[i].Image = NewImage;
		Elements[i].Locked = Locked;
		ItemCount = Elements.Length;

		SetIndex(Index);

		if (MyScrollBar != None)
			MyScrollBar.AlignThumb();
	}
}

function InsertElement( int i, ImageListElem NewElem, optional int Locked )
{
	Insert( i, NewElem.Image, NewElem.Item, Locked );
}

event Swap(int IndexA, int IndexB)
{
	local ImageListElem elem;

	if ( IsValidIndex(IndexA) && IsValidIndex(IndexB) )
	{
		elem = Elements[IndexA];
		Elements[IndexA] = Elements[IndexB];
		Elements[IndexB] = elem;
	}
}

function LoadFrom(GUIVertImageList Source, optional bool bClearFirst)
{
	local int i, item;
	local Material mat;
	local int l;

	if (bClearfirst)
		Clear();

	for ( i = 0; i < Source.ItemCount; i++ )
	{
		Source.GetAtIndex(i,mat,item,l);
		Add(mat,item,l);
	}
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
	if (MyScrollBar != None)
		MyScrollBar.AlignThumb();

	return Index;
}

function int RemoveSilent(int i, optional int Count)
{
	bNotify = False;
	i = Remove(i, Count);
	bNotify = True;
	return i;
}

function int RemoveElement(ImageListElem Elem, optional int Count)
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

	// In case we now have an invalid index
	SetIndex(Index);

	if ( MyScrollBar != None )
		MyScrollBar.AlignThumb();

	return Index;
}

function Clear()
{
	if (ItemCount == 0)
		return;

	Elements.Remove(0,Elements.Length);
	Super.Clear();
}

// =====================================================================================================================
// =====================================================================================================================
//  Query Functions
// =====================================================================================================================
// =====================================================================================================================

function Material Get(optional bool bGuarantee)
{
	if ( !IsValid() )
	{
		if (bGuarantee && ItemCount > 0)
			return Elements[0].Image;

		return None;
	}

	return Elements[Index].Image;
}

function int GetItem()
{
	if ( !IsValid() )
		return -1;

	return Elements[Index].Item;
}

// Arbitrary list Item
function Material GetImageAtIndex(int i)
{
	if (!IsValidIndex(i))
		return None;

	return Elements[i].Image;
}

function string GetItemAtIndex(int i)
{
	return string(GetItemIntAtIndex(i));
}

function int GetItemIntAtIndex(int i)
{
	if (!IsValidIndex(i))
		return -1;

	return Elements[i].Item;
}

function GetAtIndex(int i, out Material Image, out int Item, out int Locked)
{
	if (!IsValidIndex(i))
		return;

	Image = Elements[i].Image;
	Item = Elements[i].Item;
	Locked = Elements[i].Locked;
}

function bool IndexLocked(int i)
{
	return Elements[i].Locked==1;
}

function bool IsLocked()
{
	return Elements[Index].Locked==1;
}


function ClearPendingElements()
{
	Super.ClearPendingElements();
	SelectedElements.Remove(0, SelectedElements.Length);
}

function array<ImageListElem> GetPendingElements(optional bool bGuarantee)
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
				GetAtIndex(Index, SelectedElements[0].Image, SelectedElements[0].Item, SelectedElements[0].Locked);
			}
		}

		return SelectedElements;
	}
}

//##############################################################################
//
// Assignment functions
//

function SetImageAtIndex(int i, Material NewImage)
{
	if ( !IsValidIndex(i) )
		return;

	Elements[i].Image = NewImage;
}

function SetItemAtIndex(int i, int NewItem)
{
	if (!IsValidIndex(i))
		return;

	Elements[i].Item = NewItem;
}

function RemoveImage( Material Image )
{
	local int i;

	i = FindImage(Image);
	if ( IsValidIndex(i) )
		Remove(i);
}

function RemoveItem(int Item)
{
	local int i;

	for ( i = Elements.Length -1; i >= 0; i-- )
		if ( Elements[i].Item == Item )
			Remove(i);

	ItemCount = Elements.Length;
	SetIndex(Index);
	if (MyScrollBar != None)
		MyScrollBar.AlignThumb();
}


//##############################################################################
//
// Search functions
//

function int FindImage( Material Image )
{
	local int i;


	if ( Image == None && !bAllowEmptyItems )
		return -1;

	for ( i = 0; i < Elements.Length; i++ )
		if ( Elements[i].Image == Image )
			return i;

	return -1;
}

function int FindItem( int Item )
{
	local int i;

	for ( i = 0; i < Elements.Length; i++ )
		if ( Elements[i].Item == Item )
			return i;

	return -1;
}

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
	local array<ImageListElem> NewItem;
	local int i;
//	log(Name@"InternalOnDragDrop Sender:"$ Sender);

	if (Controller.DropTarget == Self)
	{
		if (Controller.DropSource != None && GUIVertImageList(Controller.DropSource) != None)
		{
			NewItem = GUIVertImageList(Controller.DropSource).GetPendingElements();

			// Special case for drag-n-drop between the same list.
			if ( Controller.DropSource == Self )
			{
				for ( i = NewItem.Length - 1; i >= 0; i-- )
					RemoveElement(NewItem[i]);
			}

			if ( !IsValidIndex(DropIndex) )
				DropIndex = ItemCount;

			for (i = NewItem.Length - 1; i >= 0; i--)
				Insert(DropIndex, NewItem[i].Image, NewItem[i].Item);

			SetIndex(DropIndex);
			return true;
		}
	}
	return false;
}

defaultproperties
{
     ImageScale=1.000000
     NoVisibleRows=4
     NoVisibleCols=3
     HorzBorder=5
     VertBorder=5
     StyleName=
     OnClick=GUIVertImageList.InternalOnClick
}
