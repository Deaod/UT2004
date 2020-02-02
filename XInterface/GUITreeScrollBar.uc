// ====================================================================
//  Class:  GUITreeScrollBar
//
//  The GUITreeScrollBar is used with the GUITreeListBox.
//
//  Written by Bruce Bickar
//  (c) 2002, 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUITreeScrollBar extends GUIVertScrollBar;

var() editconst noexport GUITreeList List;

function SetList( GUIListBase InList )
{
	Super.SetList(InList);
	List = GUITreeList(InList);
	if ( List != None )
		ItemCount = List.VisibleCount;
}

function UpdateGripPosition(float NewPos)
{
	if (List != none)
	{
		List.MakeVisible(NewPos);
		ItemCount = List.VisibleCount;
	}

	GripPos = NewPos;
	CurPos = (ItemCount-ItemsPerPage)*GripPos;
	PositionChanged(CurPos);
}

delegate MoveGripBy(int items)
{
	local int NewItem;

	if (List != none)
	{
		NewItem = List.Top + items;
		ItemCount = List.VisibleCount;
		if (ItemCount > 0)
		{
			List.SetTopItem(NewItem);
//			AlignThumb();
		}
	}

	CurPos += items;
	if (CurPos < 0)
		CurPos = 0;
	if (CurPos > ItemCount-ItemsPerPage)
		CurPos = ItemCount-ItemsPerPage;
	if ( List == None && ItemCount > 0 )
		AlignThumb();
	PositionChanged(CurPos);
}

delegate AlignThumb()
{
	local float NewPos;

	if (List != none)
	{
		BigStep = List.ItemsPerPage * Step;
		if (List.ItemCount==0)
			NewPos = 0;
		else
			NewPos = float(List.Top) / float(List.VisibleCount-List.ItemsPerPage);
	}
	else {
		if (ItemCount==0)
			NewPos = 0;
		else
			NewPos = CurPos / float(ItemCount-ItemsPerPage);
	}

	GripPos = FClamp(NewPos, 0.0, 1.0);
}

defaultproperties
{
}
