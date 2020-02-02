/*==============================================================================
	Vertical list containing multiple GUIMenuOptions

	The inherent problem with GUIMultiOptionList is that is actually a GUIMultiComponent, in that it is a component
	that will be the MenuOwner for other components.  However, it is a list, which is not a subclass of GUIMultiComponent.

	When designing this class, I had to choose whether to derive it from GUIListBase, thus inheriting all the behavior
	of GUIListBase, but requiring the behavior of GUIMultiComponent to be reimplemented, or vice versa.   I decided to
	go with subclassing GUIListBase, since all other components of the menu should see this class as a list, and treat
	it as such.  Having to deal with passing input, focus and drawing to all its inner components is something that only
	concerns GUIMultiOptionList, while having an interface consistent with other lists is very much a concern for the
	rest of the GUI.

	Since we do not have the benefits of the FocusedControl property of GUIMultiComponent, among which are things like:
	always drawn last to ensure that it is always on top, chance to process input first, etc., I need some other method
	to represent which of the elements are currently my "FocusedControl".

	GUI lists normally use the Index property to indicate the element which is currently selected, and this would work
	really well for the most part.  However, this is not 100% reliable for indicating which of the elements of the
	GUIMultiOptionList should be the "FocusedControl".  If the list has hot tracking enabled, this index will be changed
	constantly, meaning that the user would always need to have the mouse over the element that they are interacting
	with in order for that element to correctly receive input and focus.

	To solve this, I use the FocusInstead property to represent the list element that is the "FocusedControl" (receiving
	input, being drawn last, etc.).  Index is used in the same manner as it is used in other GUI lists, with the exception
	that for rendering, the "selected" item is always the one that corresponds to FocusInstead, rather than the element
	at Index.

	Created by Ron Prestenback
	© 2003, Epic Games, Inc.  All Rights Reserved

==============================================================================*/
class GUIMultiOptionList extends GUIVertList
	native;

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
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var() editconst editconstarray array<GUIMenuOption>	Elements;
var() float					ItemScaling;		// Used to scale the total item height of the list elements

// Controls amount of border drawn around each item
// ItemHeight (after ItemScaling is applied) is further reduced by this value, and elements are centered vertically
var() float					ItemPadding;

// Support for multiple columns
var() float				ColumnWidth;
var() int				NumColumns;
var() editconst	int     ItemsPerColumn;

// Only DRD_LefttoRight & DRD_TopToBottom supported - indicates direction of increment
// LeftToRight -           TopToBottom
// 1 2 3 4                 1 3 5 7
// 5 6 7 8                 2 4 6 8

var() bool                  bVerticalLayout;

delegate OnCreateComponent(GUIMenuOption NewComp, GUIMultiOptionList Sender);

function InitComponent(GUIController InController, GUIComponent InOwner)
{
	Super.InitComponent(InController, InOwner);

	MyScrollBar.AlignThumb = ScrollAlignThumb;
}


event int CalculateIndex( optional bool bRequireValidIndex )
{
	local int NewIndex, i;
	local float X, Y;

	NewIndex = -1;
	if ( IsInClientBounds() )
	{
		X = ClientBounds[0];
		Y = ClientBounds[1];
		NewIndex = Top;
		if ( bVerticalLayout )
			i = 1;

		while ( NewIndex < ItemCount )
		{
			if ( !ElementVisible(NewIndex) )
			{
				NewIndex++;
				continue;
			}

			if ( Controller.MouseX >= X && Controller.MouseX <= X + ItemWidth &&
			     Controller.MouseY >= Y && Controller.MouseY <= Y + ItemHeight )
			    break;

			if ( bVerticalLayout )
			{
				NewIndex += ItemsPerColumn;
				X += ItemWidth;

				if ( NewIndex >= ItemCount )
				{
					X = ClientBounds[0];
					Y += ItemHeight;
					NewIndex = Top + i++;
					if ( NewIndex >= Top + Min(ItemsPerPage, ItemCount) / NumColumns )
					{
						if ( bRequireValidIndex )
							NewIndex = -1;
						break;
					}
				}
			}

			else
			{
				X += ItemWidth;
				if ( ++i >= NumColumns )
				{
					i = 0;
					X = ClientBounds[0];
					Y += ItemHeight;
				}
			}

			NewIndex++;
		}
	}

	if ( NewIndex >= ItemCount && bRequireValidIndex )
		NewIndex = -1;

	return Min(NewIndex, ItemCount - 1);
}

event bool ElementVisible( int Idx )
{
	local int i;

	if ( bVerticalLayout )
	{
		i = Idx - (ItemsPerColumn * (Idx / ItemsPerColumn));
		return i >= Top && i < Min(Top + ItemsPerPage / NumColumns, ItemCount - 1);
	}

	else return Idx >= Top && Idx < Top + ItemsPerPage;
}

function bool InternalOnClick(GUIComponent Sender)
{
	local int NewIndex;

	if ( ItemsPerPage==0 )
		return false;

	NewIndex = CalculateIndex();
	if ( !IsValidIndex(NewIndex) )
		return false;

	SilentSetIndex(NewIndex);

	// We must intercept the menu options's OnClick delegate, since most don't handle the click event unless
	// the click was on their component
	// However, we need to know when the option is clicked, so that I can send the notification upwards
	// Using the normal OnChange() chain of events is no good here, since GUIMultiOptionList passes OnChange()
	// to indicate that a component's value has changed

	// But I still need to allow a way for modders MenuOption subclasses to receive the OnClick as well
	if ( GUIMenuOption(Sender) != None && !GUIMenuOption(Sender).MenuOptionClicked(Sender) )
		return true;

	if ( Sender != Self )
		OnClick(Self);

	return true;
}

protected function GenerateMenuOption(out string NewOptionClass, out GUIMenuOption NewComp, out string Caption)
{
	local class<GUIMenuOption>	MOClass;

	if (NewOptionClass == "" && NewComp == None)
	{
		Warn("Must specify a menu option class to add item to list!");
		return;
	}

	else if (NewComp == None)
	{
		MOClass = class<GUIMenuOption>(Controller.AddComponentClass(NewOptionClass));
		if (MOClass == None)
		{
			Warn("Could not create new menu option for list:"@NewOptionClass);
			return;
		}

		NewComp = new(None) MOClass;
	}

	else NewOptionClass = string(NewComp.Class);

	if (Caption != "")
		NewComp.Caption = Caption;

	else Caption = NewComp.Caption;

	NewComp.ComponentJustification = TXTA_Left;
	NewComp.LabelJustification = TXTA_Center;
	NewComp.bAutoSizeCaption = true;

	if (NewComp.LabelStyleName == "")
		NewComp.LabelStyleName = StyleName;

//	NewComp.OnClick = InternalOnClick;
	NewComp.OnChange = InternalOnChange;
	NewComp.bHeightFromComponent = False;
	OnCreateComponent(NewComp, Self);
	NewComp.InitComponent(Controller, Self);
	NewComp.OnClick = InternalOnClick;

	// If hot tracking is enabled, set the friendly label of the component so that the label's
	// state gets updated correctly when we mouse over the component
//	if ( bHotTrack )
//		NewComp.SetFriendlyLabel(NewComp.MyLabel);
}

function GUIMenuOption AddItem(string NewOptionClass, optional GUIMenuOption NewComp, optional string Caption, optional bool bUnique)
{
	local int i;

	if (Caption != "" && bUnique)
	{
		for (i = 0; i < Elements.Length; i++)
			if (Elements[i].Caption == Caption)
				return None;
	}
	GenerateMenuOption(NewOptionClass, NewComp, Caption);

	if (NewComp != None)
	{
		Elements[Elements.Length] = NewComp;

		NewComp.Opened(Self);
		if (MyScrollBar != None)
			MyScrollBar.AlignThumb();
	}

	ItemCount = Elements.Length;
	CheckLinkedObjects(Self);
	return NewComp;
}

function GUIMenuOption ReplaceItem(int idx, string NewOptionClass, optional GUIMenuOption NewComp, optional string Caption, optional bool bUnique)
{
	local int i;

	if ( !ValidIndex(Idx) )
		return AddItem(NewOptionClass, NewComp, Caption, bUnique);

	if (Caption != "" && bUnique)
		for (i = 0; i < Elements.Length; i++)
			if (Caption == Elements[i].Caption)
				return None;

	GenerateMenuOption(NewOptionClass, NewComp,  Caption);
	if (NewComp != None)
	{
		if (NewComp != Elements[Index])
		{
			NewComp.TabOrder = Elements[Index].TabOrder;
			Elements[Index].Free();
			Elements[Index] = NewComp;
			NewComp.Opened(Self);
			if (Controller.bCurMenuInitialized)
				OnChange(Self);
		}
	}

	return NewComp;
}

function GUIMenuOption InsertItem(int Idx, string NewOptionClass, optional GUIMenuOption NewComp, optional string Caption, optional bool bUnique)
{
	local int i;

	if ( !ValidIndex(Idx) )
		return AddItem(NewOptionClass, NewComp, Caption, bUnique);

	if (Caption != "" && bUnique)
		for (i = 0; i < Elements.Length; i++)
			if (Caption == Elements[i].Caption)
				return None;

	GenerateMenuOption(NewOptionClass, NewComp, Caption);
	if (NewComp != None)
	{
		NewComp.TabOrder = Idx;

		Elements.Insert(Idx, 1);
		Elements[Idx] = NewComp;
		NewComp.Opened(Self);

		while (++Idx < Elements.Length)
			Elements[Idx].TabOrder = Idx;

		if (MyScrollBar != None)
			MyScrollBar.AlignThumb();

		if (Controller.bCurMenuInitialized)
			OnChange(Self);
	}

	ItemCount = Elements.Length;
	return NewComp;
}

function RemoveItem(int Idx)
{
	if ( ValidIndex(Idx) )
	{
		Elements[Idx].Free();
		Elements.Remove(Idx, 1);

	// Run through the remaining items and update their tab orders.
		while (Idx < Elements.Length)
			Elements[Idx].TabOrder = Idx++;

		SetIndex(-1);
		if (MyScrollBar != None)
			MyScrollBar.AlignThumb();
	}

	ItemCount = Elements.Length;
}

function Clear()
{
	local int i;

	for (i = 0; i < Elements.Length; i++)
		Elements[i].Free();

	Elements.Remove(0, Elements.Length);

	Super.Clear();
}

event bool ValidIndex(int Idx)
{
	if (Idx < 0 || Idx >= Elements.Length)
		return false;

	return true;
}

function GUIMenuOption Get()
{
	if (ValidIndex(Index))
		return Elements[Index];

	return none;
}

function GUIMenuOption GetItem(int Idx)
{
	if (ValidIndex(Idx))
		return Elements[Idx];
	return None;
}

function int Find(string Caption)
{
	local int i;

	for (i = 0; i < Elements.Length; i++)
		if (Elements[i].Caption ~= Caption)
			return i;

	return -1;
}

function int FindComp(GUIMenuOption Comp)
{
	local int i;

	for (i = 0; i < Elements.Length; i++)
		if (Elements[i] == Comp)
			return i;

	return -1;
}

function InternalOnChange(GUIComponent Sender)
{
	if (Controller.bCurMenuInitialized)
	{
		if (GUIMenuOption(Sender) != None)
			SilentSetIndex(FindComp(GUIMenuOption(Sender)));
		OnChange(Self);
	}
}

function ShowList()
{
	local int i;

	for (i = 0; i < Elements.Length; i++)
		Elements[i].Show();
}

function HideList()
{
	local int i;

	for (i = 0; i < Elements.Length; i++)
		Elements[i].Hide();
}

// Hack to prevent recursion
function int SetIndex(int NewIndex)
{
	if (NewIndex == Index)
	{
		if (ValidIndex(NewIndex) && CanFocusElement(Elements[NewIndex]))
			Elements[NewIndex].SetFocus(None);

		return NewIndex;
	}

	if (NewIndex < 0 || NewIndex >= ItemCount)
		Index = -1;
	else
		Index = NewIndex;

	if ( Index >= 0 && ItemsPerPage > 0 && !ElementVisible(Index) )
		SetTopItem(Index);

//		if (ItemsPerPage > 0 && !ElementVisible(Index))
//			SetTopItem( (Index - (ItemsPerPage / NumColumns)) + 1);
//	}

	IndexChanged(Self);
	bNotify = True;

	if ( ElementVisible(Index) && Index < ItemCount && CanFocusElement(Elements[NewIndex]) )
		Elements[Index].SetFocus(None);

	return Index;
}

event SetFocus(GUIComponent Who)
{
    if (Who==None)
	{
		Super.SetFocus(None);
		return;
	}

	MenuStateChange(MSAT_Focused);
	FocusInstead = Who;
	Index = FindComp(GUIMenuOption(Who));

	if (MenuOwner != None)
		MenuOwner.SetFocus(Self);
}

event LoseFocus(GUIComponent Sender)
{
	if ( bHotTrack )
		FocusInstead = None;

	Super.LoseFocus(Sender);
}

function ScrollAlignThumb()
{
	local float NewPos;

	if (ItemCount==0)
		NewPos = 0;
	else
	{
		if ( bVerticalLayout )
			NewPos = float(Top) / (float(ItemsPerColumn) - (ItemsPerPage / NumColumns));

		else NewPos = float(Top) / float(ItemCount-ItemsPerPage);
	}

	MyScrollBar.GripPos = FClamp(NewPos,0.0,1.0);
}

function MakeVisible(float Perc)
{
	local float MaxTop, ModResult;
	local int NewTop, Change;

	if ( !bVerticalLayout )
	{
		MaxTop = ItemCount - ItemsPerPage;
		ModResult = MaxTop % NumColumns;
		if ( ModResult > 0 )
			MaxTop = (MaxTop - ModResult) + NumColumns;

		// NewItem is number of hidden items * Perc we want to show
		// Round off result before adjusting top to prevent constant flipping back and forth between two items
		// or if we're attempting to view the last row
		NewTop = Round(MaxTop * Perc);
		Change = Abs(Top - NewTop);
		if ( Change < NumColumns && Perc < 1.0)
			return;
	}
	else
	{
		MaxTop = ItemsPerColumn - (ItemsPerPage / NumColumns);
		NewTop = Round(MaxTop * Perc);
	}

	SetTopItem(NewTop);
}

function SetTopItem(int Item)
{
	local int ModResult;

	if ( bVerticalLayout )
	{
		while ( Item > ItemsPerColumn )
			Item -= ItemsPerColumn;

		Item = Clamp( Item, 0, ItemsPerColumn - (ItemsPerPage / NumColumns) );

		// Adjust the result to fall on the first column - otherwise, elements might get shifted to a different column
	}

	else
	{
		// clamp new top to prevent displaying space below last items of list
//		Item = Clamp(Item, 0, ItemCount - ItemsPerPage);
		Item = Clamp(Item, 0, ItemCount - 1);

		// Adjust the result to fall on the first column - otherwise, elements might get shifted to a different column
		ModResult = Item % NumColumns;
		if ( ModResult > 0 )
		{
			// If we had leftover items, we'll need another row
			if ( Item > Top )
				Item += NumColumns;

			Item -= ModResult;
		}

		// But if we went too far (more than itemcount + numcolumns), then back it up
		while ( (Item + ItemsPerPage > ItemCount + NumColumns) && Item >= 0)
			Item -= NumColumns;
	}

	Top = Max( 0, Item );
	OnAdjustTop(Self);
}

function InternalOnAdjustTop(GUIComponent Sender)
{
	if ( !bHotTrack && !ElementVisible(Index) )
		FocusInstead = None;

	else if (bHotTrack && ElementVisible(Index) && Index < Elements.Length && CanFocusElement(Elements[Index]) )
		FocusInstead = Elements[Index];
}

function WheelDown()
{
	if (MyScrollBar!=None)
	{
		if (Controller.CtrlPressed)
			MyScrollBar.MoveGripBy(ItemsPerPage);
		else MyScrollBar.MoveGripBy(NumColumns);
	}
	else
	{
		if (!Controller.CtrlPressed)
			Down();
		else
			PgDn();
	}
}

function PgUp()
{
	if (ItemCount<2)	return;

	if ( bVerticalLayout )
		SetIndex( Max(0, Index - ItemsPerPage / NumColumns) );
	else Super.PgUp();
}

function PgDn()
{
	if (ItemCount<2)	return;

	if ( bVerticalLayout )
		SetIndex( Min(Index + ItemsPerPage / NumColumns, ItemCount - 1) );
	else Super.PgDn();
}

function bool Up()
{
	local int NewIndex;

	if ( bVerticalLayout )
	{
		if ( Index > 0 && Index % ItemsPerColumn > 0 )
		{
			NewIndex = Index - 1;
			while ( NewIndex > 0 && !CanFocusElement(Elements[NewIndex]) && NewIndex % ItemsPerColumn > 0 )
				NewIndex--;

			NewIndex = Max(0, NewIndex);
			// Check once more that element can accept focus, in case we're at 0 and 0 is a title bar
			if ( CanFocusElement(Elements[NewIndex]) )
				SetIndex( NewIndex );
		}

		if ( MyScrollBar != None )
			MyScrollBar.AlignThumb();

		return true;
	}

	if ( Index - NumColumns >= 0 )
	{
		NewIndex = Index - NumColumns;
		while ( NewIndex - NumColumns >= 0 && !CanFocusElement(Elements[NewIndex]) )
			NewIndex -= NumColumns;

		NewIndex = Max(0, NewIndex);

		// Check once more that element can accept focus, in case we're at 0 and 0 is a title bar
		if ( CanFocusElement(Elements[NewIndex]) )
			SetIndex( NewIndex );
	}

	if ( MyScrollBar != None )
		MyScrollBar.AlignThumb();

	return true;
}

function bool Down()
{
	local int NewIndex;

	if ( bVerticalLayout )
	{
		NewIndex = Index + 1;
		if ( NewIndex % ItemsPerColumn > 0 && NewIndex < ItemCount )
		{
			while ( NewIndex < ItemCount && NewIndex % ItemsPerColumn > 0 && !CanFocusElement(Elements[NewIndex]) )
				NewIndex++;

			NewIndex = Min(NewIndex, ItemCount - 1);

			if ( CanFocusElement(Elements[NewIndex]) )
				SetIndex( NewIndex );
		}

		if ( MyScrollBar != None )
			MyScrollBar.AlignThumb();

		return true;
	}

	if ( Index + NumColumns < ItemCount )
	{
		NewIndex = Index + NumColumns;
		while ( NewIndex + NumColumns < ItemCount && !CanFocusElement(Elements[NewIndex]) )
			NewIndex += NumColumns;

		NewIndex = Min(NewIndex, ItemCount - 1);
		if ( CanFocusElement(Elements[NewIndex]) )
			SetIndex( NewIndex );
	}

	if ( MyScrollBar != None )
		MyScrollBar.AlignThumb();

	return true;
}

function bool MoveRight()
{
	local int NewIndex, Avail;

	if ( bVerticalLayout )
	{
		NewIndex = Index + ItemsPerColumn;
		if ( Index + ItemsPerColumn >= ItemCount )
			return true;

		while ( NewIndex + ItemsPerColumn < ItemCount && !CanFocusElement(Elements[NewIndex]) )
			NewIndex += ItemsPerColumn;

		NewIndex = Min(NewIndex, ItemCount - 1);

		if ( CanFocusElement(Elements[NewIndex]) )
			SetIndex(NewIndex);

		return true;
	}

	Avail = NumColumns - (Index % NumColumns) - 1;
	NewIndex = Index + 1;
	if ( Avail > 0 && NewIndex < ItemCount && ItemCount > 0 )
	{
		while ( NewIndex - Index <= Avail && NewIndex < ItemCount && !CanFocusElement(Elements[NewIndex]) )
			NewIndex++;

		NewIndex = Min(NewIndex, ItemCount - 1);

		if ( CanFocusElement(Elements[NewIndex]) )
			SetIndex( NewIndex );

		return true;
	}

	return true;
}

function bool MoveLeft()
{
	local int NewIndex, Avail;

	if ( bVerticalLayout )
	{
		NewIndex = Index - ItemsPerColumn;
		if ( NewIndex < 0 )
			return true;

		while ( NewIndex - ItemsPerColumn >= 0 && !CanFocusElement(Elements[NewIndex]) )
			NewIndex -= ItemsPerColumn;

		NewIndex = Max(0, NewIndex);

		if ( CanFocusElement(Elements[NewIndex]) )
			SetIndex(NewIndex);
		return true;
	}

	Avail = Index % NumColumns;
	if ( Avail > 0 && Index > 0 && ItemCount > 0 )
	{
		NewIndex = Index - 1;
		while ( Index - NewIndex <= Avail && NewIndex > 0 && !CanFocusElement(Elements[NewIndex]) )
			NewIndex--;

		NewIndex = Max(0, NewIndex);
		if ( CanFocusElement(Elements[NewIndex]) )
			SetIndex( NewIndex );
		return true;
	}

	return true;
}

event bool NextControl(GUIComponent Sender)
{
	if (Controller.CtrlPressed	||
		Controller.AltPressed	||
		Controller.ShiftPressed	||
	   (ItemCount > 1 && Index == ItemCount - 1) )
	{
		if (MenuOwner != None)
			return MenuOwner.NextControl(Self);
	}

	if ( bVerticalLayout )
		return Down();

	return MoveRight();
}

event bool PrevControl(GUIComponent Sender)
{
	if (Controller.CtrlPressed	||
		Controller.AltPressed	||
		Controller.ShiftPressed	||
	   (ItemCount > 1 && Index <= 0) )
	{
		if (MenuOwner != None)
			return MenuOwner.PrevControl(Self);
	}

	if ( bVerticalLayout )
		return Up();

	else return MoveLeft();
}

protected event bool CanFocusElement( GUIMenuOption Elem )
{
	return Elem != None && Elem.MenuState != MSAT_Disabled && GUIListSpacer(Elem) == None;
}

function CenterMouse()
{
	local GUIMenuOption mo;

	mo = Get();
	if ( CanFocusElement(mo) )
	{
		mo.CenterMouse();
		return;
	}

	Super.CenterMouse();
}

defaultproperties
{
     ItemScaling=0.045000
     ItemPadding=0.100000
     ColumnWidth=1.000000
     NumColumns=1
     OnAdjustTop=GUIMultiOptionList.InternalOnAdjustTop
}
