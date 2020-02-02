// ====================================================================
//  Class:  UT2K4UI.GUICircularList
//  Parent: UT2K4UI.GUIListBase
//
//  <Enter a description here>
// ====================================================================

class GUICircularList extends GUIListBase
	Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var()   bool		bCenterInBounds;		// Center the list in the bounding box
var()	bool		bFillBounds;			// If true, the list will take up the whole bounding box
var()	bool		bIgnoreBackClick;		// If true, will ignore any click on back region
var()	bool		bAllowSelectEmpty;		// If true, allows selection of empty slots
var()	int			FixedItemsPerPage;		// There are a fixed number of items in the list
var()   bool        bWrapItems;             // If itemcount < ItemsPerPage, should items be wrapped?

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

	// Sanity

	if (bFillBounds)
		bCenterInBounds=false;

	if (!bAllowSelectEmpty && ItemCount == 0)
		Index = -1;
}

function float CalculateOffset(float MouseX)
{
	local float x,x1,x2,Width,xMod;
	local int i;

	x1 = ClientBounds[0];
	x2 = ClientBounds[2];

	if ( (MouseX<x1) || (MouseX>x2) )
		return -1.0;

	width = x2-x1;

	if ( (bCenterInBounds) && (ItemsPerPage*ItemWidth<Width) )
	{

		xMod = (Width - (ItemsPerPage*ItemWidth)) / 2;
		x1+=xMod;
		x2-=xMod;

		if ( (MouseX>=x1) && (MouseX<=x2) )
			return (MouseX-x1) / ItemWidth;
		else
			return -1;
	}

	if ( (bFillBounds) && (ItemsPerPage*ItemWidth<Width) )
	{
		xMod = (Width - (ItemsPerPage*ItemWidth)) / ItemsPerPage;

		i = 0;
		x = x1;
		while (x<=x2)
		{
			if ((MouseX>=x) && (MouseX<=x+ItemWidth) )
				return i;

			i++;
			x+= ItemWidth+xmod;
		}

		return -1;
	}

	return (MouseX-x1)/ItemWidth;

}

event int CalculateIndex( optional bool bRequireValidIndex )
{
	local int i, NewIndex;

	i = (Top + CalculateOffset(Controller.MouseX)) % ItemCount;
	if ( bRequireValidIndex && !IsValidIndex(i) )
		i = -1;

	NewIndex = Min( i, ItemCount - 1 );
	return NewIndex;
}

function bool InternalOnClick(GUIComponent Sender)
{
	local int NewIndex;

	if ( ( !IsInClientBounds() ) || (ItemsPerPage==0) )
		return false;

	// Get the Col
	NewIndex = CalculateIndex(True);

	// Keep selected index in range
	if (NewIndex < 0 && bIgnoreBackClick)
		return false;

	// check if allowed to go out of range
	if ( !bAllowSelectEmpty && !IsValidIndex(NewIndex) )
		return false;

	SetIndex(NewIndex);
	return true;
}


function WheelUp()
{
	MoveLeft();
}

function WheelDown()
{
	MoveRight();
}

function bool MoveLeft()
{
	local int last;

	if (ItemCount<2)  return true;

	Last = Index;

	if (Index==0)
		Index=ItemCount-1;
	else
		Index--;

	if (Last==Top)
		Top=Index;

	OnChange(self);
	return true;
}

function bool MoveRight()
{
	local int last;

	if (ItemCount<2)  return true;

	Last = Index;

	Index++;
	if (Index==ItemCOunt)
		Index = 0;

	if (Last==(Top+ItemsPerPage-1)%ItemCount)
	{
		Top++;
		if (Top==ItemCount)
		  Top=0;
	}

	OnChange(self);
	return true;
}

function Home()
{
	if (ItemCount<2)	return;

	SetIndex(0);
	Top = 0;

	OnChange(self);
}

function End()
{
	if (ItemCount<2)	return;

	Top = ItemCount - ItemsPerPage;
	if (Top<0)
		Top = 0;

	SetIndex(ItemCount-1);
}

function PgUp()
{
	local int moveCount, Last;

	if (ItemCount<2)  return;

	for(moveCount=0; moveCount<ItemsPerPage-1; moveCount++)
	{
		Last = Index;

		if (Index==0)
			Index=ItemCount-1;
		else
			Index--;

		if (Last==Top)
			Top=Index;
	}

	OnChange(self);
}

function PgDown()
{
	local int moveCount, Last;

	if (ItemCount<2)  return;

	for(moveCount=0; moveCount<ItemsPerPage-1; moveCount++)
	{
		Last = Index;

		Index++;
		if (Index==ItemCOunt)
			Index = 0;

		if (Last==(Top+ItemsPerPage-1)%ItemCount)
		{
			Top++;
			if (Top==ItemCount)
				Top=0;
		}
	}

	OnChange(self);
}

function bool IsValid()
{
	return Index != -1;
}

// We've received a mouse click in the drop source
function InternalOnMousePressed(GUIComponent Sender, bool IsRepeat)
{
	local int NewIndex, i, j, k;

	if ( !IsInClientBounds() || ItemsPerPage == 0 )
		return;

	// If not holding down the mouse
	if (!IsRepeat && ItemCount > 0)
	{
		NewIndex = CalculateIndex( True );
		if (NewIndex == -1 && bIgnoreBackClick)
			return;

		LastPressX = Controller.MouseX;
		LastPressY = Controller.MouseY;

		if (NewIndex >= ItemCount)
			NewIndex = ItemCount - 1;

		// If we had an Item selected, go ahead and add it to the drag-n-drop list
		if ( Controller.CtrlPressed && bMultiSelect && SelectedItems.Length == 0 && NewIndex != Index )
			SelectedItems[SelectedItems.Length] = Index;

		// If shift is pressed, do shift selection
		if ( Controller.ShiftPressed && IsMultiSelect() )
		{
			if ( LastSelected == -1 )
				LastSelected = 0;

			// If not pressing Ctrl, clear out the SelectedItems array
			if ( !Controller.CtrlPressed )
				for ( j = SelectedItems.Length - 1; j >= 0; j-- )
					if ( SelectedItems[j] != Index )
						SelectedItems.Remove(j,1);

			for ( j = Min(LastSelected, NewIndex); j <= Max(LastSelected, NewIndex); j++ )
			{
				for ( k = 0; k < SelectedItems.Length; k++ )
					if ( SelectedItems[k] == j )
						break;

				if ( k == SelectedItems.Length )
					SelectedItems[k] = j;
			}

			return;
		}
		else
		{
			LastSelected = NewIndex;
			if ( IsMultiSelect() )
				Index = NewIndex;
		}

		// Find out if the this index is already in our selected list
		for (i = 0; i < SelectedItems.Length; i++)
			if (SelectedItems[i] == NewIndex)
				break;

		// If it was found, remove it (allows toggling an Item's selectedness)
		// don't remove it immediately, but set MightRemove.  This way, if the user drags
		// the selected Item, instead of releasing the mouse, we won't deselect it.
		if (i < SelectedItems.Length)
			MightRemove = i;
		else if (Controller.CtrlPressed && bMultiSelect)
			SelectedItems[i] = NewIndex;
		else if (SelectedItems.Length > 0 && MightRemove == -1)
			SelectedItems.Remove(0, SelectedItems.Length);
	}
}

// Find out if we were clicking on any Item - if so, add it to SelectedItems
function CheckDragSelect()
{
	local int i;

	i = CalculateIndex(True);
	if (i < 0 && bIgnoreBackClick)
		return;

	if (i >= ItemCount)
		i = ItemCount - 1;

	SetIndex(i);
	SelectedItems[SelectedItems.Length] = i;
}

// Called on whatever component the data is being dragged over
function InternalOnDragOver(GUIComponent Sender)
{
	local int NewIndex;

	if (Controller.DropTarget == Self)
	{
		NewIndex = CalculateIndex(True);

		// Keep selected index in range
		if (NewIndex == -1 && bIgnoreBackClick)
			return;

		if (NewIndex >= ItemCount)
		{
			DropIndex = -1;
			return;
		}

		if (Controller.DropSource != Self && SelectedItems.Length > 0)
			SelectedItems.Remove(0, SelectedItems.Length);

		DropIndex = NewIndex;
	}
}

defaultproperties
{
     bCenterInBounds=True
     bIgnoreBackClick=True
     bAllowSelectEmpty=True
     bWrapItems=True
     OnClick=GUICircularList.InternalOnClick
}
