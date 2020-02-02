// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class moFloatEdit extends GUIMenuOption;

var(Option)                     float       MinValue, MaxValue, Step;
var(Option) noexport editconst GUIFloatEdit	MyNumericEdit;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
	MyNumericEdit = GUIFloatEdit(MyComponent);
	MyNumericEdit.MinValue = MinValue;
	MyNumericEdit.MaxValue = MaxValue;
    MyNumericEdit.Step = Step;
	MyNumericEdit.CalcMaxLen();
	MyNumericEdit.SetReadOnly(bValueReadOnly);
}

function SetComponentValue(coerce string NewValue, optional bool bNoChange)
{
	if ( bNoChange )
		bIgnoreChange = True;

	SetValue(NewValue);
	bIgnoreChange = False;
}

function string GetComponentValue()
{
	return string(GetValue());
}

function SetValue(coerce float V)
{
	MyNumericEdit.SetValue(v);
}

function float GetValue()
{
	return float(MyNumericEdit.Value);
}

function Setup(coerce float NewMin, coerce float NewMax, coerce float NewStep)
{
	MinValue = NewMin;
	MaxValue = NewMax;
	Step     = NewStep;

	MyNumericEdit.MinValue = MinValue;
	MyNumericEdit.MaxValue = MaxValue;
	MyNumericEdit.Step     = Step;

	MyNumericEdit.MyEditBox.bIncludeSign = NewMin < 0;
	MyNumericEdit.CalcMaxLen();

	SetValue( FClamp(GetValue(), MinValue, MaxValue) );
}

function SetReadOnly(bool b)
{
	Super.SetReadOnly(b);
	MyNumericEdit.SetReadOnly(b);
}

defaultproperties
{
     MinValue=-9999.000000
     MaxValue=9999.000000
     Step=0.100000
     ComponentClassName="XInterface.GUIFloatEdit"
}
