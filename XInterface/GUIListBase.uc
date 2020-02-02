// ====================================================================
//  Class:  UT2K4UI.GUIListBase
//
//  Abstract GUIList list box component.
//
//  Written by Joe Wilcox
//  Made abstract by Jack Porter
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIListBase extends GUIComponent
        Native
        Abstract;

#exec OBJ LOAD FILE=InterfaceContent.utx

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)


var()      bool             bSorted;                // Should we sort this list
var()      bool             bHotTrack;              // Use the Mouse X/Y to always hightlight something
var()      bool             bHotTrackSound;			// Whether to make the mouse over sound when hottracking
var()      bool             bDrawSelectionBorder;   // Should we draw a selection border around the selected item
var()      bool             bVisibleWhenEmpty;      // List is still drawn when there are no items in it.
var()      bool             bNotify;				// Used to abort OnChange notification in list
var()      bool             bInitializeList;		// If true, set index to 0 when adding first item
var()      bool             bMultiSelect;           // allow multiple selections (where implemented)
var()      bool             bAllowEmptyItems;


var() noexport        GUIScrollBarBase MyScrollBar;

// Styles
var(Style)      string           SelectedStyleName;      // Name of the style to use for the selected item
var(Style)      string           SectionStyleName;       // Name of the style to use for header items
var(Style)      string           OutlineStyleName;

var(Style) noexport        GUIStyles        SelectedStyle;
var(Style) noexport        GUIStyles        SectionStyle;
var(Style) noexport        GUIStyles        OutlineStyle;            // Used for outlining a pending drag-n-drop



var()      ETextAlign       SectionJustification;
var()      Material         SelectedImage;            // Image to use when displaying
var()      color            SelectedBKColor;          // Color for a selection background

var() noexport editconst        int              Top,Index;                // Pointers in to the list
var() noexport editconst const  int              ItemsPerPage;             // # of items per Page.  Is set natively
var() noexport editconst const  float            ItemHeight;               // Size of each row.  Subclass should set in PreDraw.
var() noexport editconst const  float            ItemWidth;                // Width of each row.. Subclass should set in PreDraw.
var() noexport editconst        int              ItemCount;                // # of items in this list



// Drag-n-drop
// You must set these to enable drag-n-drop
var() noexport editconst        array<int>       SelectedItems;
var() noexport editconst        int              LastSelected;             // Last selected item
var() noexport editconst        int              LastPressX, LastPressY;   // Last position of mouse press
var() noexport editconst        int              DropIndex;                // Indicates the insertion position for the drag-n-drop operation
var() noexport editconst        int              MightRemove;              // Indicates an item that will be de-selected unless a drag operation begins

var() noexport editconstarray array<GUIComponent>     LinkedObjects;				// Objects state is changed based on whether this list has a valid index


// Not yet implemented (drag-n-drop)
// This will eventually allow you to auto-scroll a list while holding the cursor
// on the top or bottom item of the target list when moving items
delegate OnScrollBy(GUIComponent Sender);

// Owner-draw.
delegate OnDrawItem(Canvas Canvas, int Item, float X, float Y, float W, float HT, bool bSelected, bool bPending);
delegate OnAdjustTop(GUIComponent Sender);

// Called when hot tracking, and a new item is highlighted
delegate OnTrack(GUIComponent Sender, int LastIndex);

delegate CheckLinkedObjects( GUIListBase List )
{
	if ( IsValid() )
		EnableLinkedObjects();
	else DisableLinkedObjects();
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController,MyOwner);

    if (SectionStyleName != "" && SectionStyle == None)
        SectionStyle = MyController.GetStyle(SectionStyleName,FontScale);

    if (SelectedStyleName != "" && SelectedStyle == None)
        SelectedStyle = MyController.GetStyle(SelectedStyleName,FontScale);

    if (OutlineStyleName != "" && OutlineStyle == None)
        OutlineStyle = MyController.GetStyle(OutlineStyleName,FontScale);
}

function Sort();    // Add in a bit

function int SilentSetIndex(int NewIndex)
{
	local int i;

	bNotify = False;
	i = SetIndex(NewIndex);
	bNotify = True;

	return i;
}

// Should be subclassed
event int CalculateIndex(optional bool bRequireValidIndex) { return -1; }

function int SetIndex(int NewIndex)
{
    if ( !IsValidIndex(NewIndex) )
        Index = -1;
    else
        Index = NewIndex;

    if ( index >= 0 && ItemsPerPage > 0 )
    {
        if ( Index < Top )
            SetTopItem(Index);

        else if ( Index >= Top + ItemsPerPage )
            SetTopItem(Index - ItemsPerPage + 1);

        else if ( bNotify )
			CheckLinkedObjects(Self);
    }
    else
    {
    	if ( bNotify )
    		CheckLinkedObjects(Self);

    	if ( Top >= ItemCount )
    		Home();
    }

    IndexChanged(self);
    return Index;
}

function IndexChanged(GUIComponent Sender)
{
	if ( bNotify )
		OnChange(Sender);

	LastSelected = Index;
}

function ClearPendingElements()
{
//	log(Name@"ClearPendingElements()");
	if (bRepeatClick)
	{
		bRepeatClick = False;
		return;
	}

	SelectedItems.Remove(0, SelectedItems.Length);
	DropIndex = -1;
}

function Clear()
{
    Top = 0;
    ItemCount=0;
    SetIndex(-1);
    MyScrollBar.AlignThumb();
}

function MakeVisible(float Perc)
{
    SetTopItem(int((ItemCount-ItemsPerPage) * Perc));
}

function SetTopItem(int Item)
{
//log("GUIListBase::SetTopItem"@Item@"ItemsPerPage:"$ItemsPerPage);
    Top = Item;
    if (Top+ItemsPerPage>=ItemCount)
        Top = ItemCount - ItemsPerPage;

    if (Top<0)
        Top=0;

	if ( bNotify )
	    CheckLinkedObjects(Self);
    OnAdjustTop(Self);

	if ( MyScrollBar != None )
    	MyScrollBar.AlignThumb();
}

function int AddLinkObject( GUIComponent NewObj, optional bool bNoCheck )
{
	local int i;

	if ( NewObj != None )
	{
		if ( !bNoCheck )
		{
			for (i = 0; i < LinkedObjects.Length; i++)
				if ( LinkedObjects[i] == NewObj )
					return i;
		}

		i = LinkedObjects.Length;
		LinkedObjects[i] = NewObj;
		return i;
	}

	return -1;
}

function InitLinkObjects( array<GUIComponent> NewObj, optional bool bNoCheck )
{
	local int i;

	if ( !bNoCheck )
	{
		for (i = NewObj.Length - 1; i >= 0; i--)
			if ( NewObj[i] == None )
				NewObj.Remove(i,1);
	}

	LinkedObjects = NewObj;
	if ( bNotify )
		CheckLinkedObjects(Self);
}

function EnableLinkedObjects()
{
	local int i;

	for (i = 0; i < LinkedObjects.Length; i++)
		if ( LinkedObjects[i] != None )
			EnableComponent(LinkedObjects[i]);
}

function DisableLinkedObjects()
{
	local int i;

	for (i = 0; i < LinkedObjects.Length; i++)
		if ( LinkedObjects[i] != None )
			DisableComponent(LinkedObjects[i]);
}

function bool IsValid()
{
	if (Index < 0 || Index >= ItemCount)
		return false;

	return true;
}

function bool IsValidIndex( int i )
{
	if ( i < 0 || i >= ItemCount )
		return false;

	return true;
}

event string AdditionalDebugString()
{
	return " SelectedItems:"@ SelectedItems.Length;
}

function string GetItemAtIndex( int idx ) { return ""; }

// Specify true for bGuarantee to receive the selected item if there are no "pending" items
function array<string> GetPendingItems(optional bool bGuarantee)
{
	local int i;
	local array<string> Items;

	if ( (DropState == DRP_Source && Controller.DropSource == Self) || bGuarantee )
	{
		for ( i = 0; i < SelectedItems.Length; i++ )
			if ( IsValidIndex(SelectedItems[i]) )
				Items[Items.Length] = GetItemAtIndex(SelectedItems[i]);

		if ( Items.Length == 0 && IsValid() )
			Items[0] = GetItemAtIndex(Index);
	}

	return Items;
}

function bool InternalOnKeyEvent( out byte Key, out byte KeyState, float Delta )
{
	local int i;
	local Interactions.EInputKey iKey;

	if ( ItemsPerPage == 0 || ItemsPerPage == 0 ) return false;

	iKey = EInputKey(Key);
	if ( KeyState == 3 && ikey == IK_MouseWheelUp )   { WheelUp();   return true; }
	if ( KeyState == 3 && ikey == IK_MouseWheelDown ) { WheelDown(); return true; }
	if ( KeyState != 1 ) return false;

	switch ( iKey )
	{
	case IK_Up:
		if ( Up() )
			return true;

		break;

	case IK_Down:
		if ( !Controller.ShiftPressed && Down() )
			return true;

		break;

	case IK_Left:
		if ( MoveLeft() )
			return true;
		break;

	case IK_Right:
		if ( MoveRight() )
			return true;

		break;

	case IK_Home:
		Home();
		return true;

	case IK_End:
		End();
		return true;

	case IK_PageUp:
		PgUp();
		return true;

	case IK_PageDown:
		PgDn();
		return true;

	case IK_A:
		if ( Controller.CtrlPressed && bMultiSelect )
		{
			SelectedItems.Length = ItemCount;
			for ( i = 0; i < ItemCount; i++ )
				SelectedItems[i] = i;

			return true;
		}
	}


	return false;
}

function bool Up()        { return false; }
function bool Down()      { return false; }
function bool MoveRight() { return false; }
function bool MoveLeft()  { return false; }
function WheelUp();
function WheelDown();
function PgUp();
function PgDn();
function Home();
function End();

// We've received a mouse press in the drop source
function InternalOnMousePressed(GUIComponent Sender, bool IsRepeat)
{
	local int i, j, k, NewIndex;

	if ( !IsInClientBounds() || ItemsPerPage == 0 )
		return;

	// If not holding down the mouse
	if (!IsRepeat && ItemCount > 0)
	{
//		log(Name@"InternalOnMousePressed");
		NewIndex = CalculateIndex(True);
		if ( NewIndex == -1 )
			return;

		LastPressX = Controller.MouseX;
		LastPressY = Controller.MouseY;

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
				{
					if ( j == SelectedItems[k] )
						break;

					if ( j < SelectedItems[k] )
					{
						SelectedItems.Insert(k, 1);
						SelectedItems[k] = j;
						break;
					}
				}

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
		{
			for ( i = 0; i < SelectedItems.Length; i++ )
				if ( NewIndex < SelectedItems[i] )
				{
					SelectedItems.Insert(i, 1);
					SelectedItems[i] = NewIndex;
					break;
				}

			if ( i == SelectedItems.Length )
				SelectedItems[i] = NewIndex;
		}
		else if (SelectedItems.Length > 0 && MightRemove == -1)
			SelectedItems.Remove(0, SelectedItems.Length);
	}
}

// Called on both the source and target when mouse is released.
function InternalOnMouseRelease(GUIComponent Sender)
{
//	log(Name@"InternalOnMouseRelease Sender:"$Sender.Name);
	if ( MightRemove >= 0 && MightRemove < SelectedItems.Length )
		SelectedItems.Remove(MightRemove, 1);

	MightRemove = -1;

	// Stop here if we aren't doing a multi-selection
	if ( !IsMultiSelect() )
		ClearPendingElements();
}

// Called when mouse is pressed and user begins to move mouse while items are selected.
function bool InternalOnBeginDrag(GUIComponent Sender)
{
	if ( Controller == None )
		return false;

	// Must move the mouse more than 3 pixels in order to begin a drag operation
	// to account for accidentally moving the mouse a little while clicking
	if ( (Abs(LastPressX - Controller.MouseX) < 3) && (Abs(LastPressY - Controller.MouseY) < 3) )
		return false;

//	log(Name@"InternalOnBeginDrag");
	MightRemove = -1;

	if ( SelectedItems.Length == 0 )
		CheckDragSelect();

	// Assign the offset that native rendering will use to draw the hovering selection
	UpdateOffset(ClientBounds[0], ClientBounds[1], ClientBounds[2], ClientBounds[3]);
	SetOutlineAlpha(128);
	return true;
}

// Find out if we were clicking on any Item - if so, add it to SelectedItems
function CheckDragSelect()
{
	local int i;
	i = CalculateIndex(True);
	if ( i < 0 )
		return;

	SetIndex(i);
	SelectedItems[SelectedItems.Length] = i;
}

function bool InternalOnRightClick( GUIComponent Sender )
{
	if ( bDropSource && bMultiSelect && SelectedItems.Length > 0 )
		Controller.bIgnoreNextRelease = True;

	return true;
}

// Called on the drop source when when an Item has been dropped.  bAccepted tells it whether
// the operation was successful or not.
// Should be subclassed
function InternalOnEndDrag(GUIComponent Accepting, bool bAccepted);

// Called on the drop target when the mouse is released - Sender is always DropTarget
// Should be subclassed
function bool InternalOnDragDrop(GUIComponent Sender)
{
	return false;
}

// Called on whatever component the data is being dragged over
function InternalOnDragOver(GUIComponent Sender)
{
	local int NewIndex;

	if ( Controller == None )
		return;

	if (Controller.DropTarget == Self)
	{
		NewIndex = CalculateIndex(True);
		if (NewIndex == -1)
		{
			DropIndex = -1;
			return;
		}

		// Remove any items that were selected in this list
		if ( Controller.DropSource != Self && SelectedItems.Length > 0 )
			SelectedItems.Remove(0, SelectedItems.Length);

		DropIndex = NewIndex;
	}
}

function InternalOnDragEnter(GUIComponent Sender)
{
    /*
    Uncomment to add special mouse cursor
    MouseCursorIndex = -- "OK to drop here" mouse cursor -- ;
    */
    SetOutlineAlpha(255);
}

function InternalOnDragLeave(GUIComponent Sender)
{
    /* Uncomment to add special mouse cursor
    MouseCursorIndex = -- "Cannot drop here" mouse cursor --;
    */

    SetOutlineAlpha(128);
    if (DropIndex >= 0)
        DropIndex = -1;
}

event bool IsMultiSelect()
{
	if ( Controller == None )
		return false;

	return bDropSource && bMultiSelect && DropState != DRP_Source && (Controller.CtrlPressed || Controller.ShiftPressed) && OnMultiSelect(Self);
}

function SetOutlineAlpha(int NewAlpha)
{
    local int i;

    if (OutlineStyle == None)
        return;

    for (i = 0; i < 5; i++)
        OutlineStyle.ImgColors[i].A = NewAlpha;
}

defaultproperties
{
     bHotTrackSound=True
     bDrawSelectionBorder=True
     bNotify=True
     bInitializeList=True
     bMultiSelect=True
     SelectedStyleName="ListSelection"
     SectionStyleName="ListSection"
     OutlineStyleName="ItemOutline"
     SelectedBKColor=(B=200,G=255,R=255,A=255)
     FontScale=FNS_Small
     StyleName="NoBackground"
     bTabStop=True
     bAcceptsInput=True
     OnRightClick=GUIListBase.InternalOnRightClick
     OnMousePressed=GUIListBase.InternalOnMousePressed
     OnMouseRelease=GUIListBase.InternalOnMouseRelease
     OnKeyEvent=GUIListBase.InternalOnKeyEvent
     OnBeginDrag=GUIListBase.InternalOnBeginDrag
     OnEndDrag=GUIListBase.InternalOnEndDrag
     OnDragDrop=GUIListBase.InternalOnDragDrop
     OnDragEnter=GUIListBase.InternalOnDragEnter
     OnDragLeave=GUIListBase.InternalOnDragLeave
     OnDragOver=GUIListBase.InternalOnDragOver
}
