// ====================================================================
//  Class:  XInterface.GUIScrollBarBase
//  Parent: XInterface.GUIMultiComponent
//
//  Base class for scroll bar assemblies
// ====================================================================

class GUIScrollBarBase extends GUIMultiComponent
		Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var()   EOrientation    Orientation;
var()   int             Step;			// How many elements to consider a single line
var     float           GripPos;		// Where in the ScrollZone is the grip	- Set Natively
var     float           GripSize;		// How big is the grip - Set Natively
var     float           GrabOffset;		// distance from top of button that the user started their drag. Set natively.
var()   int             MinGripPixels;	// Minimum size (in pixels) to draw the grip.

var		GUIListBase		MyList;			// The list this Scrollbar is attached to

// only to be used when MyList == none
var() 	int 			BigStep;		// big step, by default one page
var() 	int 			ItemCount;		// total number of items
var() 	int 			ItemsPerPage;	// number of visible items per page
var 	int 			CurPos;			// current possition

var Automated GUIScrollZoneBase   MyScrollZone;
var Automated GUIScrollButtonBase MyIncreaseButton;
var Automated GUIScrollButtonBase MyDecreaseButton;
var Automated GUIGripButtonBase   MyGripButton;

delegate PositionChanged(int NewPos);

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

    if (MyList != none)
	{
		ReFocus(MyList);
		BigStep = MyList.ItemsPerPage * Step;
		ItemCount = MyList.ItemCount;
		CurPos = MyList.Top;
	}

	MyScrollZone.bNeverScale = True;
	MyIncreaseButton.bNeverScale = True;
	MyDecreaseButton.bNeverScale = True;
	MyGripButton.bNeverScale = True;
}

function SetList( GUIListBase List )
{
    MyList = List;
    Refocus(List);

    if ( List != None )
    {
    	BigStep = List.ItemsPerPage;
    	ItemCount = List.ItemCount;
    	CurPos = MyList.Top;
    }
    else
	{
		BigStep = 0;
		ItemCount = 0;
		CurPos = 0;
	}
}

function UpdateGripPosition(float NewPos)
{
	if (MyList != none)
	{
		MyList.MakeVisible(NewPos);
		ItemCount = MyList.ItemCount;
	}
	GripPos = NewPos;
	CurPos = (ItemCount-ItemsPerPage)*GripPos;
	PositionChanged(CurPos);
}

delegate MoveGripBy(int items)
{
	local int NewItem;

	if (MyList != none)
	{
		NewItem = MyList.Top + items;
		ItemCount = MyList.ItemCount;
		if (MyList.ItemCount > 0)
		{
			MyList.SetTopItem(NewItem);
			AlignThumb();
		}
	}

	CurPos += items;
	if (CurPos < 0) CurPos = 0;
	if (CurPos > ItemCount-ItemsPerPage) CurPos = ItemCount-ItemsPerPage;
	if (MyList == none) if (ItemCount > 0) AlignThumb();
	PositionChanged(CurPos);
}

function bool DecreaseClick(GUIComponent Sender)
{
	WheelUp();
	return true;
}

function bool IncreaseClick(GUIComponent Sender)
{
	WheelDown();
	return true;
}

function WheelUp()
{
	if (!Controller.CtrlPressed)
		MoveGripBy(-Step);
	else
		MoveGripBy(-BigStep);
}

function WheelDown()
{
	if (!Controller.CtrlPressed)
		MoveGripBy(Step);
	else
		MoveGripBy(BigStep);
}

delegate AlignThumb()
{
	local float NewPos;

	if (MyList != none)
	{
		BigStep = MyList.ItemsPerPage * Step;
		if (MyList.ItemCount==0)
			NewPos = 0;
		else
			NewPos = float(MyList.Top) / float(MyList.ItemCount-MyList.ItemsPerPage);
	}
	else {
		if (ItemCount==0)
			NewPos = 0;
		else
			NewPos = CurPos / float(ItemCount-ItemsPerPage);
	}

	GripPos = FClamp(NewPos, 0.0, 1.0);
}

function Refocus(GUIComponent Who)
{
	local int i;

	if (Who != None && Controls.Length > 0)
		for (i=0;i<Controls.Length;i++)
	    {
	    	Controls[i].FocusInstead = Who;
	        Controls[i].bNeverFocus=true;
	    }
}

// Stub
function bool GripPreDraw( GUIComponent Sender ) { return false; }

function SetFriendlyLabel( GUILabel NewLabel )
{
	Super.SetFriendlyLabel(NewLabel);

	if ( MyScrollZone != None )
		MyScrollZone.SetFriendlyLabel(NewLabel);

	if ( MyIncreaseButton != None )
		MyIncreaseButton.SetFriendlyLabel(NewLabel);

	if ( MyDecreaseButton != None )
		MyDecreaseButton.SetFriendlyLabel(NewLabel);

	if ( MyGripButton != None )
		MyGripButton.SetFriendlyLabel(NewLabel);
}

/*
function bool FocusFirst(GUIComponent Sender)
{
}

function bool FocusLast(GUIComponent Sender)
{
}
*/

defaultproperties
{
     Step=1
     PropagateVisibility=True
     bTabStop=False
}
