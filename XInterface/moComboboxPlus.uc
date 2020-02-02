//==============================================================================
//	Created on: 08/16/2003
//	moComboBox plus another component - probably a checkbox
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class moComboboxPlus extends moComboBox;

var string		 ExtraCompClass;
var GUIComponent ExtraComp;
var float        ExtraCompSize;

var array<string>  ExtraData;	// corresponds to index in GUIComboBox

function InitComponent(GUIController InController, GUIComponent InOwner)
{
	Super.InitComponent(InController, InOwner);

	if ( ExtraCompClass != "" )
		ExtraComp = AddComponent(ExtraCompClass);

	ExtraComp.bBoundToParent = False;
	ExtraComp.bScaleToParent = False;
}

function InternalOnChange(GUIComponent Sender)
{
	local int i;

	if ( Sender != None )
	{
		i = MyComboBox.GetIndex();
		if ( i < 0 || i >= ExtraData.Length )
			return;

		if ( Sender == ExtraComp )
			SetExtraValue( i, ExtraData[i] );

		else if ( Sender == MyComboBox )
			UpdateExtraValue(i);
	}
}

function SetExtraValue(int i, string Data);
function UpdateExtraValue(int i);

function AddItem(string Item, optional object Extra, optional string Str)
{
	Super.AddItem(Item,Extra,Str);

	ExtraData.Length = MyComboBox.ItemCount();
}

function RemoveItem(int item, optional int Count)
{
	Super.RemoveItem(Item,Count);
	if ( Count == 0 )
		Count = 1;

	if ( Item >= 0 && Item <= ExtraData.Length - Count )
		ExtraData.Remove(item,Count);
}

function bool InternalOnPreDraw(Canvas C)
{
	local float AH, AW, NewScale;

	if ( ExtraComp == None )
		return false;

	AH = ActualHeight();
	AW = ActualWidth();

	if ( bVerticalLayout )
	{
		ExtraComp.WinWidth = AW;
		if ( bSquare )
			ExtraComp.WinHeight = AW;

		else ExtraComp.WinHeight = ExtraCompSize;

		NewScale = AH - ExtraComp.ActualHeight();

		MyLabel.WinHeight *= NewScale;
		MyComponent.WinHeight *= NewScale;
	}
	else
	{
		ExtraComp.WinHeight = AH;
		if ( bSquare )
			ExtraComp.WinWidth = AH;

		else ExtraComp.WinWidth = ExtraCompSize;
		NewScale = AW - ExtraComp.ActualWidth();

		MyLabel.WinWidth *= NewScale;
		MyComponent.WinWidth *= NewScale;
	}

	return false;
}

defaultproperties
{
     ExtraCompClass="XInterface.GUICheckBox"
     bSquare=True
     OnPreDraw=moComboboxPlus.InternalOnPreDraw
}
