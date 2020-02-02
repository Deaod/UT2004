//==============================================================================
// NumericEdit component with custom formatting
//
// Written by Michiel Hendriks
// (c) 2003, 2004, Epic Games, Inc. All Rights Reserved
//==============================================================================

class GUIFormatNumEdit extends GUINumericEdit;

var protected bool bUnformated;

delegate string FormatValue(int NewValue)
{
	return "$ "$NewValue; // test
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	MyEditBox.OnActivate = FormatToValue;
	MyEditBox.OnDeActivate = ValueToFormat;
	MySpinner.bNeverFocus = false;
	MySpinner.FocusInstead = none;
}

function CalcMaxLen(); // don't limit size

function EditOnChange(GUIComponent Sender); // no longer needed

function ValidateValue();

function ValueToFormat()
{
	if (!bUnformated) return;
	SetValue(int(MyEditBox.GetText()));
}

function FormatToValue()
{
	MyEditBox.SetText(Value);
	bUnformated = true;
}

function SetValue(int V)
{
	if (v<MinValue)
		v=MinValue;

	if (v>MaxValue)
		v=MaxValue;

	Value = string(V);
	MyEditBox.SetText(FormatValue(int(Value)));
	bUnformated = false;
	OnChange(Self);
}

function bool SpinnerPlusClick(GUIComponent Sender)
{
	local int v;

	v = int(Value) + Step;
	SetValue(v);
	return true;
}

function bool SpinnerMinusClick(GUIComponent Sender)
{
	local int v;
	v = int(Value) - Step;
	SetValue(v);
	return true;
}

defaultproperties
{
}
