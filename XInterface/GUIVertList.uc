class GUIVertList extends GUIListBase
		Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

delegate float GetItemHeight(Canvas C);

function CenterMouse()
{
	local PlayerController PC;
	local float X, Y;

	if ( IsValid() )
	{
		PC = PlayerOwner();
		if ( PC != None )
		{
			SetTopItem(Index);
			X = ActualLeft() + ActualWidth() / 2;
			Y = (Index - Top) * ItemHeight;
			PC.ConsoleCommand("SETMOUSE" @ X @ Y);
		}

		return;
	}

	Super.CenterMouse();
}

event int CalculateIndex( optional bool bRequireValidIndex )
{
	local int i, NewIndex;

	//  Figure out which Item we're clicking on
	i = Top + ((Controller.MouseY - ClientBounds[1]) / ItemHeight);
	if ( i >= ItemCount && bRequireValidIndex )
		i = -1;

	NewIndex = Min( i, ItemCount - 1 );
	return NewIndex;
}

function bool InternalOnClick(GUIComponent Sender)
{
	local int NewIndex;

	if ( !IsInClientBounds() || ItemsPerPage==0 )
		return false;

	// Get the Row..
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
		GUIVertScrollBar(MyScrollBar).WheelUp();
	else
	{
		if (!Controller.CtrlPressed)
			Up();
		else
			PgUp();
	}
}

function WheelDown()
{
	if (MyScrollBar!=None)
		GUIVertScrollBar(MyScrollBar).WheelDown();
	else
	{
		if (!Controller.CtrlPressed)
			Down();
		else
			PgDn();
	}
}


function bool Up()
{
	if ( (ItemCount<2) || (Index==0) ) return true;

	SetIndex(Max(0,Index-1));
	if ( MyScrollBar != None )
		MyScrollBar.AlignThumb();
	return true;
}

function bool Down()
{
	if ( (ItemCount<2) || (Index==ItemCount-1) ) return true;

	SetIndex( Min(Index+1, ItemCount - 1) );
	if ( MyScrollBar != None )
		MyScrollBar.AlignThumb();
	return true;
}

function Home()
{
	if (ItemCount<2) return;

	SetIndex(0);
	if ( MyScrollBar != None )
		MyScrollBar.AlignThumb();
}

function End()
{
	if (ItemCount<2)	return;

	SetIndex(ItemCount-1);
	if ( MyScrollBar != None )
		MyScrollBar.AlignThumb();
}

function PgUp()
{
	if (ItemCount<2)	return;

	SetIndex( Max(0, Index - ItemsPerPage) );
	if ( MyScrollBar != None )
		MyScrollBar.AlignThumb();
}

function PgDn()
{

	if (ItemCount<2)	return;

	SetIndex( Min(Index + ItemsPerPage, ItemCount - 1) );
	if ( MyScrollBar != None )
		MyScrollBar.AlignThumb();
}

defaultproperties
{
     OnClick=GUIVertList.InternalOnClick
}
