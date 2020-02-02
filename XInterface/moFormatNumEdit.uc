//==============================================================================
// NumericEdit component with custom formatting
//
// Written by Michiel Hendriks
// (c) 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class moFormatNumEdit extends moNumericEdit;

delegate string FormatValue(int NewValue)
{
	return "$ "$NewValue; // test
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
	GUIFormatNumEdit(MyNumericEdit).FormatValue = InternalFormatValue;
}

function string InternalFormatValue(int NewValue)
{
	return FormatValue(NewValue);
}

defaultproperties
{
     ComponentClassName="XInterface.GUIFormatNumEdit"
}
