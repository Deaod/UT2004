// ====================================================================
//  Class:  UT2K4UI.GUIMoComboBox
//
//  Written by Joe Wilcox
//	Updated by Ron Prestenback
//  (c) 2002, 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class moComboBox extends GUIMenuOption;

var(Option)                     bool        bReadOnly;
var(Option)                     bool        bAlwaysNotify;	// Always pass OnChange events, even when selecting currently selected item
var(Option) editconst noexport GUIComboBox MyComboBox;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
	MyComboBox = GUIComboBox(MyComponent);
	MyComboBox.Edit.bAlwaysNotify = bAlwaysNotify;

	SetReadOnly(bValueReadOnly);
	ReadOnly(bReadOnly);
}

function SetComponentValue(coerce string NewValue, optional bool bNoChange)
{
	local int i;

	i = FindIndex(NewValue,,True);
	if (i != -1)
	{
		if ( bNoChange )
			bIgnoreChange = True;

		SetIndex(i);
		bIgnoreChange = False;
	}
}

function string GetComponentValue()
{
	return GetExtra();
}

function int ItemCount()
{
	return MyComboBox.ItemCount();
}

function SetIndex(int I)
{
	MyComboBox.SetIndex(i);
}

function SilentSetIndex(int i)
{
	bIgnoreChange = True;
	MyComboBox.SetIndex(i);
	bIgnoreChange = False;
}

function int GetIndex()
{
	return MyComboBox.GetIndex();
}

function int FindIndex(string Test, optional bool bExact, optional bool bExtra, optional Object Obj)
{
	return MyComboBox.FindIndex(Test, bExact, bExtra, Obj);
}

function string Find(string Test, optional bool bExact, optional bool bExtra)
{
	return MyComboBox.Find(Test,bExact,bExtra);
}

function int FindExtra(string Test, optional bool bExact)
{
	return MyComboBox.FindExtra(Test, bExact);
}

function AddItem(string Item, optional object Extra, optional string Str)
{
	MyComboBox.AddItem(Item,Extra,str);
}

function RemoveItem(int item, optional int Count)
{
	MyComboBox.RemoveItem(item, Count);
}

function string GetItem(int index)
{
	return MyComboBox.GetItem(index);
}

function object GetItemObject(int index)
{
	return MyComboBox.GetItemObject(index);
}

function string GetText()
{
	return MyComboBox.Get();
}

function object GetObject()
{
	return MyComboBox.GetObject();
}

function string GetExtra()
{
	return MyComboBox.GetExtra();
}


function SetText(string NewText, optional bool bListItemsOnly)
{
	MyComboBox.SetText(NewText, bListItemsOnly);
}

function SetExtra(string NewExtra, optional bool bListItemsOnly)
{
	MyComboBox.SetExtra(NewExtra, bListItemsOnly);
}

function ReadOnly(bool b)
{
	MyComboBox.ReadOnly(b);
}

function SetReadOnly(bool b)
{
	Super.SetReadOnly(b);
	MyComboBox.bValueReadOnly = b;
}

function ResetComponent()
{
	local bool bTemp;

	bTemp = bIgnoreChange;
	bIgnoreChange = True;

	MyComboBox.List.Clear();
	bIgnoreChange = bTemp;
}

function bool FocusFirst(GUIComponent Sender)
{
	local bool bResult;

	bResult = Super.FocusFirst(Sender);

	// Hackilicious
	if ( bResult && MyComboBox != None )
		MyComboBox.HideListBox();

	return bResult;
}

defaultproperties
{
     ComponentClassName="XInterface.GUIComboBox"
}
