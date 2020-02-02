//==============================================================================
//  Created on: 11/15/2003
//  Specialized array property page for dynamic arrays
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class GUIDynArrayPage extends GUIArrayPropPage;

struct ArrayControl
{
	var() GUIButton					b_New;
	var() GUIButton					b_Remove;
};

var() array<ArrayControl>				ArrayButton;

var() string SizingCaption;
var() localized string 	NewText, RemoveText;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	li_Values.OnAdjustTop = InternalOnAdjustTop;

	SizingCaption = RemoveText;
}

// Create buttons and controls for array members
function InitializeList()
{
	local int i;
	local float AW, AL, Y;

	// ItemsPerPage is set in PreDraw, so if li_Values hasn't received a call to PreDraw() yet, stop here
	if ( !li_Values.bPositioned )
		return;

	bListInitialized = True;

	// Unset bInit so that InternalOnPreDraw won't call InitializeList() again
    if (Item.RenderType == PIT_Check)
        MOType = "XInterface.moCheckBox";

    else if (Item.RenderType == PIT_Select)
        MOType = "XInterface.moComboBox";

	AW = li_Values.ActualWidth();
	AL = li_Values.ActualLeft();

	Clear();
	for (i = 0; i < PropValue.Length; i++)
		AddListItem(i);

	ArrayButton.Length = li_Values.ItemsPerPage;

	Y = li_Values.ClientBounds[1];
	for (i = 0; i < li_Values.ItemsPerPage; i++)
	{
		ArrayButton[i] = AddButton(i);

		ArrayButton[i].b_New.WinLeft = ArrayButton[i].b_New.RelativeLeft((AL + AW) + 5);
		ArrayButton[i].b_Remove.WinLeft = ArrayButton[i].b_New.WinLeft;

		ArrayButton[i].b_New.WinTop = ArrayButton[i].b_New.RelativeTop(Y);
		ArrayButton[i].b_Remove.WinTop = ArrayButton[i].b_Remove.RelativeTop(Y);

		Y += li_Values.ItemHeight;
	}

	UpdateListCaptions();
	UpdateListValues();
	UpdateButtons();
	RemapComponents();
}

function ArrayControl AddButton(int Index)
{
	local ArrayControl AC;

	AC.b_New = GUIButton(AddComponent("XInterface.GUIButton",True));
	AC.b_New.TabOrder = Index+1;
	AC.b_New.Tag = Index;
	AC.b_New.OnClick = InternalOnClick;
	AC.b_New.Caption = NewText;
	AC.b_New.SizingCaption = SizingCaption;

	AC.b_Remove = GUIButton(AddComponent("XInterface.GUIButton",True));
	AC.b_Remove.TabOrder = Index+1;
	AC.b_Remove.Tag = Index;
	AC.b_Remove.OnClick = InternalOnClick;
	AC.b_Remove.Caption = RemoveText;
	AC.b_Remove.SizingCaption = SizingCaption;

	return AC;
}

function Clear()
{
	local int i;

	for (i = 0; i < ArrayButton.Length; i++)
	{
		RemoveComponent(ArrayButton[i].b_New, True);
		RemoveComponent(ArrayButton[i].b_Remove, True);
	}

	ArrayButton.Remove(0, ArrayButton.Length);
	Super.Clear();
	RemapComponents();
}

// Resets the button captions and roles to correspond to the currently displayed array members
// (Makes sure that the last button says "New" while all others say "Remove"
function UpdateButtons()
{
	local int i, j;

	j = li_Values.Top;

	for (i = 0; i < ArrayButton.Length; i++)
	{

		SetElementState(i, j == li_Values.Elements.Length && j < li_Values.Top + li_Values.ItemsPerPage, j < li_Values.Elements.Length && j < li_Values.Top + li_Values.ItemsPerPage);
		SetElementCaption(i, j);
		j++;
	}
}

protected function SetElementState(int Index, bool bNewOn, bool bRemoveOn)
{
	if (Index < 0 || Index >= ArrayButton.Length)
		return;

	ArrayButton[Index].b_New.TabOrder = Index + 1;
	ArrayButton[Index].b_Remove.TabOrder = Index + 1;
	if (ArrayButton[Index].b_New.bVisible != bNewOn)
		ArrayButton[Index].b_New.SetVisibility(bNewOn);

	if (ArrayButton[Index].b_Remove.bVisible != bRemoveOn)
		ArrayButton[Index].b_Remove.SetVisibility(bRemoveOn);

	if (bNewOn)
		EnableComponent(ArrayButton[Index].b_New);
	else DisableComponent(ArrayButton[Index].b_New);

	if (bRemoveOn)
		EnableComponent(ArrayButton[Index].b_Remove);
	else DisableComponent(ArrayButton[Index].b_Remove);
}

protected function SetElementCaption(int ButtonArrayIndex, int ListElementIndex)
{
	ArrayButton[ButtonArrayIndex].b_New.Caption = NewText;
	ArrayButton[ButtonArrayIndex].b_New.Tag = ListElementIndex;

	ArrayButton[ButtonArrayIndex].b_Remove.Caption = RemoveText;
	ArrayButton[ButtonArrayIndex].b_Remove.Tag = ListElementIndex;
}

function bool InternalOnClick(GUIComponent Sender)
{
	local int i;

	if ( Super.InternalOnClick(Sender) )
		return true;

	if (GUIButton(Sender) != None)
	{
		for (i = 0; i < ArrayButton.Length; i++)
		{
			if (Sender == ArrayButton[i].b_New)
			{
				PropValue.Insert(ArrayButton[i].b_New.Tag, 1);
				AddListItem(ArrayButton[i].b_New.Tag).SetFocus(None);
				break;
			}

			if (Sender == ArrayButton[i].b_Remove)
			{
				if (ArrayButton[i].b_Remove.Tag != -1 && ArrayButton[i].b_Remove.Tag < li_Values.Elements.Length)
				{
					li_Values.RemoveItem(ArrayButton[i].b_Remove.Tag);
					PropValue.Remove(ArrayButton[i].b_Remove.Tag, 1);
				}
				break;
			}
		}

		if (i < ArrayButton.Length)
		{
			UpdateListCaptions();
			UpdateButtons();
			RemapComponents();
		}

	}

	return false;
}

function InternalOnAdjustTop(GUIComponent Sender)
{
	UpdateButtons();
	li_Values.InternalOnAdjustTop(Sender);
}

function bool FloatingPreDraw(Canvas C)
{
	local float XL, YL, XL2, YL2;

	if ( bInit )
	{
		b_OK.Style.TextSize(C, MSAT_Blurry, NewText, XL, YL, FNS_Medium);
		b_OK.Style.TextSize(C, MSAT_Blurry, RemoveText, XL2, YL2, FNS_Medium);

		if ( XL > XL2 )
			SizingCaption = NewText;
		else SizingCaption = RemoveText;
	}

	return Super.FloatingPreDraw(C);

}

defaultproperties
{
     NewText="New"
     RemoveText="Remove"
}
