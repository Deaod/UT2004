// ====================================================================
//  Class:  UT2K4UI.GUIHorzList
//  Parent: UT2K4UI.GUIListBase
//
//  <Enter a description here>
// ====================================================================

class GUIHorzList extends GUIListBase
		Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

event int CalculateIndex(optional bool bRequireValidIndex)
{
	local int i, NewIndex;

	i = Top + ((Controller.MouseX - ClientBounds[0]) / ItemWidth);
	if ( i >= ItemCount && bRequireValidIndex )
		i = -1;

	NewIndex = Min( i, ItemCount - 1 );
	return NewIndex;
}

function bool InternalOnClick(GUIComponent Sender)
{
	local int NewIndex;

	if ( !IsInClientBounds() || ItemsPerPage == 0 )
		return false;

	NewIndex = CalculateIndex();
	SetIndex(NewIndex);
	return true;
}

function bool InternalOnKeyType(out byte Key, optional string Unicode)
{
	// Add code to jump to next line with Char

	return false;
}

function WheelUp()
{
	if (MyScrollBar!=None)
		GUIHorzScrollBar(MyScrollBar).WheelUp();
	else
	{
		if (!Controller.CtrlPressed)
			ScrollLeft();
		else
			PgUp();
	}
}

function WheelDown()
{
	if (MyScrollBar!=None)
		GUIHorzScrollBar(MyScrollBar).WheelDown();
	else
	{
		if (!Controller.CtrlPressed)
			ScrollRight();
		else
			PgDn();
	}
}

function bool MoveLeft()
{
	if ( (ItemCount<2) || (Index==0) ) return true;

	Index = max(0,Index-1);

	if ( (Index<Top) || (Index>Top+ItemsPerPage) )
	{
		Top = Index;
		MyScrollBar.AlignThumb();
	}
	return true;
}

function bool MoveRight()
{
	if ( (ItemCount<2) || (Index==ItemCount-1) ) return true;

	Index = min(Index+1,ItemCount-1);
	if (Index<Top)
	{
		Top = Index;
		MyScrollBar.AlignThumb();
	}
	else if (Index>=Top+ItemsPerPage)
	{
		Top = Index-ItemsPerPage+1;
		MyScrollBar.AlignThumb();
	}
	return true;
}

function ScrollLeft()
{
	MoveLeft();
}

function ScrollRight()
{
	MoveRight();
}

function Home()
{
	if (ItemCount<2) return;

	SetIndex(0);
	Top = 0;
	MyScrollBar.AlignThumb();

}

function End()
{
	if (ItemCount<2) return;

	Top = ItemCount - ItemsPerPage;
	if (Top<0)
		Top = 0;

	SetIndex(ItemCount-1);
	MyScrollBar.AlignThumb();
}

function PgUp()
{

	if (ItemCount<2) return;

	Index -= ItemsPerPage;

	// Adjust to bounds
	if (Index < 0)
		Index = 0;

	// If new index
	if (Top + ItemsPerPage <= Index)		// If index is forward but not visible, jump to it
		Top = Index;
	else if (Index + ItemsPerPage < Top)	// Item is way too far
		Top = Index;
	else if (Index < Top)	// Item is 1 page or less away
		SetTopItem(Top - ItemsPerPage);

	SetIndex(Index);
	MyScrollBar.AlignThumb();
}

function PgDn()
{

	if (ItemCount<2) return;

	// Select item 1 page away from current selection
	Index += ItemsPerPage;

	// Adjust to bounds
	if (Index >= ItemCount)
		Index = ItemCount-1;


	if (Index < Top)  // If item is still before Top Item, go to it
		Top = Index;
	else if (Index - Top - ItemsPerPage >= ItemsPerPage)	// Too far away
		SetTopItem(Index);
	else if (Index - Top >= ItemsPerPage) // Just 1 page away
		SetTopItem(Top + ItemsPerPage);

	SetIndex(Index);
	MyScrollBar.AlignThumb();
}

defaultproperties
{
     OnClick=GUIHorzList.InternalOnClick
}
